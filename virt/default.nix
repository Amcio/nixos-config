{ config, pkgs, ...}:

{
  imports = [
    ./virtd.nix
    ./podman.nix
  ];
}
