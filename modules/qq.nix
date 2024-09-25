{ config, pkgs, lib, ... }: let
  js-ti-bin = pkgs.fetchurl {
    url = "https://github.com/chrononeko/chronocat/releases/download/v0.2.16/chronocat.js.ti-v0.2.16.bin";
    hash = "sha256-ErOwtKXoL2aglDjbPL7gmaGHTAeYG2Pf36GoLcY6EPs=";
  };
  patched = pkgs.qq.overrideAttrs (old : {
    postFixup = ''
      dd bs=1024 skip=1 if=${js-ti-bin} of=$out/opt/QQ/resources/app/app_launcher/chronocat.js
      echo "require('./chronocat.js')" >> $out/opt/QQ/resources/app/app_launcher/launcher.js
    '';
    meta = {};
  });
in {
  options.chronocat.qq = lib.mkOption {
    type = lib.types.path;
    description = "qq";
  };
  config.chronocat.qq = patched;
}