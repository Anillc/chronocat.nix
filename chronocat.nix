{
fetchzip,
qq,
jq,
lib,
...
}: let
  version = "0.0.49";
  chronocat = fetchzip {
    url = "https://github.com/chrononeko/chronocat/releases/download/v${version}/chronocat-iife-v${version}.zip";
    sha256 = "sha256-jcRSMkJ14m7Ghix89DG1uRAlh+vrBN1gqYOshK4VcAI=";
  };
in qq.overrideAttrs (old: {
  postFixup = ''
    echo "require('${chronocat}/chronocat.js')" >> $out/opt/QQ/resources/app/app_launcher/launcher.js
  '';
  meta = {};
})