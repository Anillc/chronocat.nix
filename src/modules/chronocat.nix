{ config, pkgs, lib, ... }: let
  patched = pkgs.qq.overrideAttrs (old : {
    # postFixup = ''
    #   echo "require('${chronocat}/chronocat.js')" >> $out/opt/QQ/resources/app/app_launcher/launcher.js
    # '';
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
      program = "${patched}/bin/qq --no-sandbox";
    };
    chronocat = config.sandbox.sandbox;
  };
}