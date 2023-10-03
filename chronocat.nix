{
fetchzip,
qq,
jq,
lib,
...
}: let
  chronocat = fetchzip {
    url = "https://github.com/chrononeko/chronocat/releases/download/v0.0.48/chronocat-iife-v0.0.48.zip";
    sha256 = "sha256-yHKQ3AWkXn+JXFqjgD5LV9bIJqx7rgNJGXg/waHjysU=";
  };
in qq.overrideAttrs (old: {
  postFixup = ''
    echo "require('${chronocat}/chronocat.js')" >> $out/opt/QQ/resources/app/app_launcher/launcher.js
  '';
  meta = {};
})