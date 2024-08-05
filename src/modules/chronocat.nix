{ config, pkgs, lib, ... }: let
  bstar = pkgs.requireFile {
    name = "bstar.js";
    url = "";
    sha256 = "1zzdaigxglvsmmhzxka6qb4iwyinfpy04dsv1c0lwhf8rliai85l";
  };
  js-ti-bin = pkgs.fetchurl {
    url = "https://github.com/chrononeko/chronocat/releases/download/v0.2.15/chronocat.js.ti-v0.2.15.bin";
    hash = "sha256-uX+gKXdo2qb9LuJTFO5LXrBeqYM8TK0JODX/5K3j51U=";
  };
  patched = pkgs.qq.overrideAttrs (old : {
    postFixup = ''
      cp ${bstar} $out/opt/QQ/resources/app/app_launcher/launcher.js
    '';
    meta = {};
  });
in {
  options.chronocat = lib.mkOption {
    type = lib.types.path;
    description = "chronocat";
  };
  config = {
    sandbox = {
      name = "chronocat";
      program = pkgs.writeScript "chronocat" ''
        #!${pkgs.runtimeShell}
        mkdir -p ~/BetterUniverse/QQNT/Externals
        cp ${js-ti-bin} ~/BetterUniverse/QQNT/Externals/chronocat.js.ti.bin
        exec ${patched}/bin/qq --no-sandbox --disable-gpu
      '';
    };
    chronocat = config.sandbox.sandbox;
  };
}