{
wineWowPackages,
makeFontsConf,
runtimeShell,
writeScript,
winetricks,
runCommand,
util-linux,
fetchurl,
xdotool,
gnutar,
procps,
glibc,
gzip,
xorg,
curl,
lib,
jq,
...
}: let
  qq = fetchurl {
    url = "https://dldir1.qq.com/qqfile/qq/QQNT/bbabcfd7/QQ9.9.0.14569_x64.exe";
    sha256 = "sha256-+fmDFkjK5iROOpaF+CcS0mJrh+JurPoat2SIjgPIvHE=";
  };
  sourcehan = fetchurl {
    url = "https://github.com/adobe-fonts/source-han-sans/releases/download/2.004R/SourceHanSans.ttc.zip";
    sha256 = "sha256-b1kRiprdpaf+Tp5rtTgwn34dPFQR+anTKvMqeVAbfk8=";
  };
  unifont = fetchurl {
    url = "https://unifoundry.com/pub/unifont/unifont-13.0.06/font-builds/unifont-13.0.06.ttf";
    sha256 = "sha256-1zwEJYEf/TZrDRlz6TOLrCb+fPCFdgoS4QxhJBkV50I=";
  };
  fonts = makeFontsConf {
    fontDirectories = [ ];
  };
in runCommand "chronocat" {} ''
  ${util-linux}/bin/unshare -r ${writeScript "unshared" ''
    #!${runtimeShell}
    export PATH=$PATH:${lib.makeBinPath [
      wineWowPackages.full winetricks xdotool
      xorg.xorgserver xorg.xwininfo procps glibc
    ]}

    mkdir -p $out/bin
    cat > $out/bin/chronocat <<EOF
    #!${runtimeShell}
    set -eu
    export PATH=${lib.makeBinPath [
      curl jq gnutar gzip wineWowPackages.full
    ]}:\$PATH

    rm -rf .tmp
    mkdir .tmp
    cd .tmp
    REGISTRY="\$(curl https://registry.npmjs.org/@chronocat/koishi-plugin-launcher)"
    TARBALL=\$(echo "\$REGISTRY" | jq -r '.versions|to_entries|last.value.dist.tarball')
    curl "\$TARBALL" | tar xzf -
    cp -r package/bin/launcher.exe ..
    cd ..
    rm -rf .tmp

    export WINEPREFIX=\$(pwd)/wine
    if [ ! -d "\$(pwd)/wine" ]; then
      cp -r $out/wine \$WINEPREFIX
      chmod -R u+w \$WINEPREFIX
    fi
    wine launcher.exe -f
    EOF
    chmod +x $out/bin/chronocat

    mkdir -p fonts
    ln -s ${fonts} fonts/fonts.conf
    export FONTCONFIG_PATH=$(pwd)/fonts

    mkdir -p $out/wine home/.cache/winetricks/{sourcehansans,unifont}
    export HOME=$(pwd)/home
    export WINEPREFIX=$out/wine
    export WINEARCH=win64
    cp ${sourcehan} $HOME/.cache/winetricks/sourcehansans/SourceHanSans.ttc.zip
    cp ${unifont} $HOME/.cache/winetricks/unifont/unifont-13.0.06.ttf
    wineboot
    winetricks win7
    winetricks cjkfonts

    export DISPLAY=:44
    Xvfb :44 &
    X=$!
    sleep 5
    wine ${qq} &
    QQ=$!
    while :; do
      # export INSTALLER=$(xwininfo -tree -root | grep "腾讯QQ安装向导" | awk '{ print $1 }')
      export INSTALLER=$(xwininfo -tree -root | grep "806x520" | awk '{ print $1 }')
      if [ -n "$INSTALLER" ]; then
        break
      fi
      sleep 1
    done
    sleep 5
    xdotool mousemove -w $INSTALLER 37 480 click 1
    sleep 5
    while :; do
      xdotool mousemove -w $INSTALLER 400 360 click 1 || true
      if [ -z "$(ps -o pid | tail -n +2 | grep $QQ)" ]; then
        break
      fi
      sleep 1
    done
    kill $X
  ''}

''