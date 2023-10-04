{
lib,
chronocat,
bubblewrap,
writeScript,
writeScriptBin,
runtimeShell,
busybox,
cacert,
makeFontsConf,
source-han-sans,
...
}:

let
  fonts = makeFontsConf {
    fontDirectories = [ source-han-sans ];
  };
in writeScriptBin "chronocat" ''
  #!${runtimeShell}
  export PATH=$PATH:${lib.makeBinPath [ bubblewrap ]}
  mkdir -p data
  bwrap \
    --ro-bind /nix/store /nix/store \
    --ro-bind /run /run \
    --bind ./data /sandbox \
    --proc /proc \
    --dev /dev \
    --tmpfs /tmp \
    ${writeScript "sandbox" ''
      #!${runtimeShell}
      export PATH=${busybox}/bin
      export HOME=/sandbox
      export XDG_DATA_HOME=/sandbox/.local/share
      export XDG_CONFIG_HOME=/sandbox/.config
      mkdir -p /sandbox/{.local/share,.config} /etc/{ssl/certs,fonts}
      echo "sandbox:x:$(id -u):$(id -g)::/sandbox:${runtimeShell}" > /etc/passwd
      echo "sandbox:x:$(id -g):" > /etc/group
      echo "nameserver 223.5.5.5" > /etc/resolv.conf
      ln -s ${cacert}/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-bundle.crt
      ln -s ${cacert}/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
      ln -s ${fonts} /etc/fonts/fonts.conf
      ${chronocat}/bin/qq "$@"
    ''} "$@"
''