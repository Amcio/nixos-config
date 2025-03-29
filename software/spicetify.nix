{
  pkgs,
  config,
  inputs,
  ...
}: {

  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  programs.spicetify =
   let
     spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
   in
   {
     enable = true;
     #spicetifyPackage = inputs.nix-unstable.legacyPackages.${pkgs.system}.spicetify-cli;
     enabledExtensions = with spicePkgs.extensions; [
       # shuffle # shuffle+ (special characters are sanitized out of extension names)
       keyboardShortcut
       fullAppDisplay
       beautifulLyrics
       playingSource
       powerBar
     ];
     enabledCustomApps = with spicePkgs.apps; [
       marketplace
     ];
     theme = spicePkgs.themes.text;
     colorScheme = "TokyoNight";
   };

}
