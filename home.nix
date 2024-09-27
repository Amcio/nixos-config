{ inputs, config, pkgs, ... }:

let
  wlprop = pkgs.callPackage ./wlprop {};
in
{
  home.username = "amcio";
  home.homeDirectory = "/home/amcio";

  imports = [
    ./waybar
    ./wofi
    ./spicetify.nix
  ];

  home.packages = with pkgs; [

#    spotify
    libreoffice
    quodlibet # Audio Player
    mpv
    obsidian
    plex-media-player
    element-desktop
    prismlauncher
    vesktop
    inputs.swww.packages.${pkgs.system}.swww
    (vivaldi.override {
      proprietaryCodecs = true;
      enableWidevine = true;
    })
    remmina # RDP connections

    # gaming
    melonDS

    # archives
    zip
    xz
    unzip
    p7zip
    zstd

    # utils
    pavucontrol
    ripgrep
    jq
    pdftk
    fzf
    rclone
    yt-dlp
    powertop

    # networking
    dnsutils
    mtr

    # misc
    glow
    btop

    # system
    lsof
    lm_sensors
    ethtool
    procps

    # hyprland
    swaynotificationcenter
    libnotify
    brightnessctl
    blueman
    wl-clipboard
    wofi  # TODO: Remove
    rofi-wayland
    networkmanagerapplet
    gammastep  
    wlogout
    hyprshot
    hyprlock
    hypridle
    wlprop
    inputs.mcmojave-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.rofi-obsidian.packages.${pkgs.system}.default
  ];

  programs.git = {
    enable = true;
    userName = "Amcio";
    userEmail = "amcio122@gmail.com";
    extraConfig = 
      { 
        init = {
	  defaultBranch = "main";  
        };
      };
  };

  programs.zathura.enable = true;

  programs.kitty = {
    enable = true;
    # TODO: Change font
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      background_opacity = "0.5";
      font_size = 10;
      confirm_os_window_close = 0;
      copy_on_select = "clipboard";
      strip_trailing_spaces = "smart";
      shell_integration = "no-rc no-cursor";
      enable_audio_bell = "no";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      la = "ls -a";
      rebuild = "nixos-rebuild switch --show-trace --use-remote-sudo";
    };

    # plugins = []; 

    oh-my-zsh = {
      enable = true;
      plugins = ["git" "z" "podman"];
    };
  };

  programs.starship = {
    enable = true;
    # settings = {};
  };



  # Apparently has no effect, perhaps this should be "override"?
  nixpkgs.config.element-web.conf = {
    show_labs_settings = true;
    default_theme = "dark";
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk = {
    enable = true;

    theme = {
      # package = (pkgs.orchis-theme.override { tweaks = [  ]; });
      package = (pkgs.tokyonight-gtk-theme.overrideAttrs (finalAttrs: previousAttrs: {
        version = "unstable-2024-08-05";
	src = pkgs.fetchFromGitHub {
	  owner = "Fausto-Korpsvart";
	  repo = "Tokyo-Night-GTK-Theme";
	  rev = "a9a25010e9fbfca783c3c27258dbad76a9cc7842";
	  hash = "sha256-HbrDDiMej4DjvskGItele/iCUY1NzlWlu3ZneA76feM=";
        };
      }));
      name = "Tokyonight-Dark-B";
    };
    iconTheme = {
      package = (pkgs.catppuccin-papirus-folders.override { accent = "sapphire"; });
      name = "Papirus-Dark";
    };
    # Fix so it uses the x theme
    cursorTheme = {
      package = null;
      name = "McMojave-x";
      size = 24;
    };
  };

  # libadwaita fixes for Tokyonight
  xdg.configFile = {
    "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };

  # Environment variables
  home.sessionVariables.HYPRCURSOR_THEME = "McMojave";
  home.sessionVariables.XCURSOR_THEME = "McMojave";
  home.sessionVariables.HYPRCURSOR_SIZE = 28;
  home.sessionVariables.XCURSOR_SIZE = 28;

  home.sessionVariables.GTK_THEME = "Tokyonight-Dark-B";

  home.sessionVariables.TERMINAL = "kitty";

  #let homeManagerSessionVars = "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh";
  #in {
  #  environment.extraInit = "[[ -f ${homeManagerSessionVars} ]] && source ${homeManagerSessionVars}";
  #}

  systemd.user.services.rclone-nc-mount = {
    Unit = {
      Description = "Service that connects to Nextcloud";
      After = [ "network-online.target" ];
      Requires = [ "network-online.target" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    
    Service = let
      gdriveDir = "/home/amcio/Documents/Nextcloud";
      in
      {
        Type = "simple";
        ExecStartPre = "/run/current-system/sw/bin/mkdir -p ${gdriveDir}";
        ExecStart = "${pkgs.rclone}/bin/rclone mount --vfs-cache-mode full nextcloud: ${gdriveDir}";
        ExecStop = "/run/current-system/sw/bin/fusermount -u ${gdriveDir}";
        Restart = "on-failure";
        RestartSec = "10s";
        Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
      };
    };

  systemd.user.services.polkit-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  programs.home-manager.enable = true;

  # DO NOT CHANGE
  home.stateVersion = "24.05";
}