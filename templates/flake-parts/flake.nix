{
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      inputs.nodal.flakeModules.modules

      # import additional flake-parts here, e.g.:
      #./my-host.nix
    ];
  };
  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nodal = {
      url = "github:synace/nodal";
      inputs = {
        flake-parts = {
          follows = "flake-parts";
          inputs.nixpkgs-lib.follows = "nixpkgs";
        };
        nixpkgs.follows = "nixpkgs";
      };
    };
  };
}
