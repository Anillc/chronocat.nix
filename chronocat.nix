{
fetchzip,
qq,
jq,
lib,
...
}: let
  version = "0.0.50";
  chronocat = fetchzip {
    url = "https://github.com/chrononeko/chronocat/releases/download/v${version}/chronocat-iife-v${version}.zip";
    sha256 = "sha256-lMZkRDdW1RLw9PXkEiTpieSZhAb4+u/XfBRnEp7eiAM=";
  };
in qq.overrideAttrs (old: {
  postFixup = ''
    echo "require('${chronocat}/chronocat.js')" >> $out/opt/QQ/resources/app/app_launcher/launcher.js
  '';
  meta = {};
})