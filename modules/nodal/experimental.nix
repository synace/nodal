{
  # imported in nixosConfiguration as config.flake.modules.nixos."nodal/experimental"
  flake.modules.nixos."nodal/experimental" = { ... }: {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
}
