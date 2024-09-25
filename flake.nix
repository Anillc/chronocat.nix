{
  outputs = inputs@{
    self, nixpkgs, flake-parts,
  }: let
    modules = map (x: ./modules/${x}) (nixpkgs.lib.attrNames (builtins.readDir ./modules));
  in flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    perSystem = { config, pkgs, lib, ... }: {
      imports = modules;
      packages.default = config.chronocat.chronocat;
      packages.docker = config.chronocat.docker;
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [];
      };
    };
    flake.flakeModules.default = {
      imports = modules;
    };
  };
}
