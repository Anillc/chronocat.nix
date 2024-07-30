{
  outputs = {
    self, nixpkgs, flake-utils,
  }: flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs { inherit system; };
  in rec {
    packages = {
      chronocat = pkgs.callPackage ./chronocat.nix packages;
      default = pkgs.callPackage ./sandbox.nix packages;
    };
    devShells.default = pkgs.mkShell {};
  });
}
