{
  description = "NixOS System flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nix-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      # Same version of nixpkgs as for the whole flake.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # swww
    swww.url = "github:LGFae/swww";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mcmojave-hyprcursor.url = "github:libadoxon/mcmojave-hyprcursor";
    rofi-obsidian = {
      url = "github:Nydragon/rofi-obsidian";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazi.url = "github:sxyazi/yazi";
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    swww,
    sops-nix,
    ...
  }: {
    nixosConfigurations.thor = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        ./configuration.nix
        ./virt
        sops-nix.nixosModules.sops
        # Make home-manager a NixOS module
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.amcio = import ./home.nix;
          home-manager.extraSpecialArgs = {inherit inputs;};
        }
      ];
    };
  };
}
