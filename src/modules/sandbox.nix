{ config, pkgs, lib, ... }: let
  cfg = config.sandbox;
  fonts = pkgs.makeFontsConf {
    fontDirectories = with pkgs; [ source-han-sans ];
  };
in {
  options.sandbox = {
    name = lib.mkOption {
      type = lib.types.str;
      description = "name of output executable";
    };
    program = lib.mkOption {
      type = lib.types.pathInStore;
      description = "program runs in sandbox";
    };
    dns = lib.mkOption {
      type = lib.types.str;
      description = "dns server used in sandbox";
      default = "223.5.5.5";
    };
    display = lib.mkOption {
      type = lib.types.int;
      description = "DISPLAY used by Xvfb and x11vnc";
      default = 114;
    };
    port = lib.mkOption {
      type = lib.types.int;
      description = "listen port of x11vnc";
      default = 5900;
    };
    sandbox = lib.mkOption {
      type = lib.types.path;
      description = "sandbox";
    };
    password = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "password of x11vnc";
      default = null;
    };
    novnc = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      description = "listen port of noVNC";
      default = null;
    };
  };
  config.sandbox.sandbox = (pkgs.writeScriptBin cfg.name ''
    #!${pkgs.runtimeShell}
    ${pkgs.busybox}/bin/mkdir -p data
    ${pkgs.bubblewrap}/bin/bwrap \
      --unshare-all \
      --share-net \
      --as-pid-1 \
      --uid 0 --gid 0 \
      --clearenv \
      --ro-bind /nix/store /nix/store \
      --bind ./data /root \
      --proc /proc \
      --dev /dev \
      --tmpfs /tmp \
      ${pkgs.writeScript "sandbox" ''
        #!${pkgs.runtimeShell}

        createService() {
          mkdir -p /services/$1
          echo -e "#!${pkgs.runtimeShell}\n$2" > /services/$1/run
          chmod +x /services/$1/run
        }

        export PATH=${lib.makeBinPath (with pkgs;
          [ busybox xorg.xorgserver x11vnc dbus dunst ]
          ++ lib.optional (cfg.novnc != null) novnc
        )}
        export HOME=/root
        export XDG_DATA_HOME=/root/.local/share
        export XDG_CONFIG_HOME=/root/.config
        export TERM=xterm
        mkdir -p /root/{.local/share,.config} /etc/{ssl/certs,fonts,dbus} /run/dbus
        mkdir -p /usr/bin /bin
        echo "root:x:0:0::/root:${pkgs.runtimeShell}" > /etc/passwd
        echo "root:x:0:" > /etc/group
        echo "nameserver ${cfg.dns}" > /etc/resolv.conf
        ln -s ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-bundle.crt
        ln -s ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
        ln -s ${fonts} /etc/fonts/fonts.conf
        ln -s $(which env) /usr/bin/env
        ln -s $(which sh) /bin/sh
        cp ${pkgs.dbus}/share/dbus-1/system.conf /etc/dbus/system.conf
        sed -i 's/<user>messagebus<\/user>/<user>root<\/user>/' /etc/dbus/system.conf
        sed -i 's/<deny/<allow/' /etc/dbus/system.conf
        export DBUS_SESSION_BUS_ADDRESS='unix:path=/run/dbus/system_bus_socket'
        export DISPLAY=':${toString cfg.display}'
        createService xvfb 'Xvfb :${toString cfg.display}'
        createService x11vnc 'x11vnc ${lib.concatStringsSep " " [
          "-forever" "-display :${toString cfg.display}"
          "-rfbport ${toString cfg.port}"
          (lib.optionalString (cfg.password != null) "-passwd ${cfg.password}")
        ]}'
        ${lib.optionalString (cfg.novnc != null) ''
          createService novnc "novnc --vnc localhost:${toString cfg.port} --listen ${toString cfg.novnc} --file-only"
        '' }
        createService dbus 'dbus-daemon --nofork --config-file=/etc/dbus/system.conf'
        createService dunst 'dunst'
        createService program "${cfg.program} $@"
        runsvdir /services
      ''} "$@"
  '').overrideAttrs (old: {
    passthru.docker = config.docker;
  });
}
