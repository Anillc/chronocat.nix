{
  description = "Description for the project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages.chronocat = pkgs.callPackage ./chronocat.nix {};
        packages.default = pkgs.callPackage ./sandbox.nix {
          inherit (self'.packages) chronocat;
        };
      };
    };
}
