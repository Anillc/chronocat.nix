{ config, pkgs, lib, ... }: {
  options.chronocat.docker = lib.mkOption {
    type = lib.types.path;
    description = "docker image";
  };
  config.chronocat.docker = pkgs.dockerTools.buildLayeredImage {
    name = "chronocat";
    tag = "latest";
    contents = [
      config.chronocat.chronocat
      (pkgs.writeScriptBin "entrypoint.sh" ''
        #!${pkgs.runtimeShell}
        ${pkgs.busybox}/bin/mkdir -p /tmp
        exec /bin/chronocat
      '')
    ];
    config.Entrypoint = [ "/bin/entrypoint.sh" ];
  };
}