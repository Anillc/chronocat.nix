{ config, pkgs, lib, ... }: {
  options.docker = lib.mkOption {
    type = lib.types.path;
    description = "docker image";
  };
  config.docker = pkgs.dockerTools.buildLayeredImage {
    name = "chronocat";
    tag = "latest";
    contents = [
      config.chronocat
      (pkgs.writeScriptBin "entrypoint.sh" ''
        #!${pkgs.runtimeShell}
        ${pkgs.busybox}/bin/mkdir -p /tmp
        exec /bin/chronocat
      '')
    ];
    config.Entrypoint = [ "/bin/entrypoint.sh" ];
  };
}