{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  home.file.".config/hypr/scripts" = {
    source = ./scripts;
    recursive = true;
    executable = true;
  };
}
