# chronocat.nix

如果你不想用默认参数：

```nix
{
  inputs.chronocat-nix.url = "github:Anillc/chronocat.nix";
  outputs = inputs@{
    self, nixpkgs, flake-parts, chronocat-nix
  }: let
    pkgs = import nixpkgs { system = "x86_64-linux"; };
  in {
    packages.x86_64-linux.chronocat = (flake-parts.lib.evalFlakeModule {
      inherit inputs;
      specialArgs = { inherit pkgs; };
    } {
      imports = [ inputs.chronocat-nix.flakeModules.default ];
      chronocat = {
        dns = "223.5.5.5"; # 沙盒内使用的 dns
        display = 114; # 沙盒中 X 的 DISPLAY
        port = 5900; # x11vnc 的端口
        password = null; # vnc 的密码，null 为没有密码
        novnc = null; # novnc 的端口，null 为不开启
      };
    }).config.chronocat.chronocat;
  };
}
```
