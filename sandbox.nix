{
lib,
# chronocat,
bubblewrap,
writeScript,
writeScriptBin,
runtimeShell,
busybox,
xorg,
x11vnc,
bash,
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
  mkdir -p data
  ${bubblewrap}/bin/bwrap \
    --unshare-user \
    --unshare-pid \
    --as-pid-1 \
    --uid 0 --gid 0 \
    --clearenv \
    --ro-bind /nix/store /nix/store \
    --ro-bind /run /run \
    --bind ./data /root \
    --proc /proc \
    --dev /dev \
    --tmpfs /tmp \
    ${writeScript "sandbox" ''
      #!${runtimeShell}

      createService() {
        mkdir -p /services/$1
        echo -e "#!/bin/sh\n$2" > /services/$1/run
        chmod +x /services/$1/run
      }

      export PATH=${lib.makeBinPath [
        busybox xorg.xorgserver x11vnc bash
      ]}
      export HOME=/root
      export XDG_DATA_HOME=/root/.local/share
      export XDG_CONFIG_HOME=/root/.config
      export TERM=xterm
      mkdir -p /root/{.local/share,.config} /etc/{ssl/certs,fonts}
      mkdir -p /usr/bin /bin
      echo "root:x:0:0::/root:${runtimeShell}" > /etc/passwd
      echo "root:x:0:" > /etc/group
      echo "nameserver 223.5.5.5" > /etc/resolv.conf
      ln -s ${cacert}/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-bundle.crt
      ln -s ${cacert}/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
      ln -s ${fonts} /etc/fonts/fonts.conf
      ln -s $(which env) /usr/bin/env
      ln -s $(which sh) /bin/sh
      export DISPLAY=':114'
      createService xvfb 'Xvfb :114'
      createService x11vnc 'x11vnc -forever -display :114'
      runsvdir /services
    ''} "$@"
''


# ${chronocat}/bin/qq "$@"
