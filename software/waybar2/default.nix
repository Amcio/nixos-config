{
  pkgs,
  config,
  ...
}: {

  home.file.".config/waybar/config.jsonc".source = ./config.jsonc;
  programs.waybar = {
    enable = true;
    style = builtins.readFile ./style.css;
  }; 

}
