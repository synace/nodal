{
  # imported in top-level flake module as inputs.nodal.modules.flake."nodal/home-manager"
  flake.modules.flake."nodal/home-manager" = { inputs, lib, ... }: lib.optionalAttrs (inputs ? flake-file) {
    # add home-manager to the consumer's inputs
    flake-file.inputs = {
      home-manager.url = lib.mkDefault "github:nix-community/home-manager";
      home-manager.inputs.nixpkgs.follows = lib.mkDefault "nixpkgs";
    };

    # guard inputs.home-manager until consumer or .#write-flake provides it
    imports = lib.optionals (inputs ? home-manager) [
      inputs.home-manager.flakeModules.home-manager
    ];
  };

  # imported in nixosConfiguration as inputs.nodal.modules.nixos."nodal/home-manager"
  # guard inputs.home-manager until consumer or .#write-flake provides it
  flake.modules.nixos."nodal/home-manager" = { inputs, lib, ... }: lib.optionalAttrs (inputs ? home-manager) {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    home-manager.useGlobalPkgs = lib.mkDefault true;
    home-manager.useUserPackages = lib.mkDefault true;
  };
}
