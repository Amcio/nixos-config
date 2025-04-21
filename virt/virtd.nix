{
  config,
  pkgs,
  ...
}: {
  users.users.amcio = {
    extraGroups = ["libvirtd"];
  };

  # Should already be enabled but let's be safe
  programs.dconf.enable = true;

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        ovmf.enable = true;
        # possibly switch to OVMFFull (space savings?)
        ovmf.packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          })
          .fd
        ];
      };
    };
    # Note that this allows users arbitrary access to USB devices.
    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;

  # A hypervisor is inherently installed on a OS-level.
  # There's no point in isolating the packages to a user
  environment.systemPackages = with pkgs; [
    spice
    spice-gtk
    virt-viewer
    virtio-win
    win-spice
  ];

  # uses home-manager
  home-manager.users.amcio.dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
