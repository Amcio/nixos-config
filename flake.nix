{
  description = "NixOS System flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, swww, rofi-obsidian, ... }: {
    nixosConfigurations.thor = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
	./virt
	# Make home-manager a NixOS module
	home-manager.nixosModules.home-manager
	{
          home-manager.useGlobalPkgs = true;
	  home-manager.useUserPackages = true;
	  home-manager.users.amcio = import ./home.nix;
	  home-manager.extraSpecialArgs = { inherit inputs; };
	}
      ];
    };
  };
}
