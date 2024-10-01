{ config, pkgs, lib, ... }: {
  options.chronocat.docker = lib.mkOption {
    type = lib.types.path;
    description = "docker image";
  };
  config.chronocat.docker = pkgs.dockerTools.buildLayeredImage {
    name = "chronocat";
    tag = "latest";
    contents = [ config.chronocat.script ];
    config.ENTRYPOINT = [ "/bin/script" ];
  };
}