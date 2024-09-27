# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 2w";
  };

  nixpkgs.config.allowUnfree = true;
  services.fwupd.enable = true;

  hardware.firmware = with pkgs; [
    (sof-firmware.overrideAttrs (finalAttrs: previousAttrs: {
	version = "2024.06";
        src = fetchurl {
          url = "https://github.com/thesofproject/sof-bin/releases/download/v${finalAttrs.version}/sof-bin-${finalAttrs.version}.tar.gz";
          sha256 = "sha256-WByjKFu1aDeolUlT9inr3c5kQVK2c+zUu/rhUEMG19Y=";
        };
    }))
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 11;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "i915.force_probe=!46a8"
    "xe.force_probe=46a8"
  ];

  networking.hostName = "thor"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";
  
  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable hyprland
  programs.hyprland.enable = true;

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
    ];
  };

  xdg.portal = {
    enable = true;
    # extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "pl";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";
  services.xserver.xkb.options = "caps:super";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  hardware.pulseaudio.enable = false;
  # OR
  #sound.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.amcio = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "input" "gamemode" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCv26kRwZ/KGVYw0sBdfKsp/pdrjTZ1wW0BdD7TirnL9AJKyAplRT9zmgHHWINPeoGX1nY1Z1QM2zdAjB53KTBUsfVgyKM0cKmzwBRPuQ5spl5d0ySYhFmlIMumVwfflk0cCF8sj9j6U/UllMX+4ZPtEyt5/i1C8lFT9xioO0yIfqSyvWLJ7TCsqsiDPxJrE9qb44Mm5XaEFFheRJS5c7ZQTp2IvFiZ/DpbcW6pMmvtc+Ig/F87TMgzkaXXdSG04UsfYAXiuTS7J3SmqYr9nDonHt5b7CXSho6IY3dcPiIERuIsp5NoHACb6byeA3taKZBN1wtOPywh2a8+/NiHYwTF/jp5DfTsEmQSeEt4hOqN8jxtvKMSjmY0OJ7Zn4xFIgeD18uvzmu3zparHdLFw2eZgoQugFFdKn9uoRyO0Y8PbhzHA2Jb13eK1sG7Xq2ZYFwyodoqxH+EHP3fEpzNHNJXdA90BXirGkJdje1d5sinGj2ZsoMbmmO3vE7mb5NYZz9UKuGvzfLs9We2rgNSaGT97aYqZUntXEAx+/5qPqxfCVEQTZHiHJYkHjTDATwPSPX3InqHc7UHpZKj+LOPMy9acNen6Lv6RwjXIQniI/ZYvJdF9KCF6mgTqp8KRM1XA8tD3VhUP38OaFgfhS4gNKajnrOYQMuJs67EX++CEw1i0Q== amcio"
    ];
    packages = with pkgs; [
      firefox
    ];
    shell = pkgs.zsh;
  };

  # Fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [
    "IBMPlexMono"
    "JetBrainsMono"
    "Iosevka"
    ]; })
    icomoon-feather
  ];


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    git
    tree
    pciutils # lspci
    usbutils # lsusb
    polkit_gnome
  ];

  environment.shells = with pkgs; [ zsh ];
  environment.pathsToLink = [ "/share/zsh" ]; # Completion for system packages?

  environment.variables.EDITOR = "neovim";
  # Enable Ozone Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # Enable VAAPI
  environment.variables.LIBVA_DRIVER_NAME = "iHD";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.neovim = {
    enable = true;
    vimAlias = true;
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.zsh.enable = true;

  # List services that you want to enable:

  services.fprintd.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    openFirewall = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  security.rtkit.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}

