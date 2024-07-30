{
  outputs = {
    self, nixpkgs, flake-utils,
  }: flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs { inherit system; };
  in rec {
    devShells.default = pkgs.mkShell {};
    lib.buildChronocat = module: pkgs.callPackage ./src {
      extraModules = [ module ];
    };
    packages.default = lib.buildChronocat {};
  });
}
