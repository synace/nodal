{ inputs, lib, ... }:
let
  nodalInputs = inputs;
in {
  imports = [
    inputs.flake-file.flakeModules.dendritic
  ];

  systems = lib.mkDefault lib.systems.flakeExposed;

  flake-file.inputs = {
    nixpkgs.url = lib.mkOverride 500 "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = lib.mkOverride 500 "github:hercules-ci/flake-parts";
    flake-file.url = lib.mkOverride 500 "github:denful/flake-file";
    import-tree.url = lib.mkOverride 500 "github:denful/import-tree";
  };

  flake.flakeModules = {
    modules = { inputs, ... }:
    let
      # only require flake-parts, make import-tree optional
      mergedInputs = nodalInputs // inputs;
    in
    {
      imports = [
        mergedInputs.flake-parts.flakeModules.modules
        ( mergedInputs.import-tree ./nodal )
      ];

      # fallback for non-dendritic, without flake-file, user provides their own inputs
      options = lib.optionalAttrs (!(inputs ? flake-file)) {
        flake-file = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          internal = true;
        };
      };
    };
    default = { inputs, lib, ... }: {
      imports = [
        inputs.flake-file.flakeModules.dendritic
        ( inputs.import-tree ./nodal )
      ];

      flake-file.inputs = {
        nixpkgs.url = lib.mkOverride 500 "github:NixOS/nixpkgs/nixos-unstable";
        flake-file.url = lib.mkOverride 500 "github:denful/flake-file";
        flake-parts.url = lib.mkOverride 500 "github:hercules-ci/flake-parts";
        import-tree.url = lib.mkOverride 500 "github:denful/import-tree";

        nodal.inputs.nixpkgs.follows = lib.mkDefault "nixpkgs";
        nodal.inputs.flake-file.follows = lib.mkDefault "flake-file";
        nodal.inputs.flake-parts.follows = lib.mkDefault "flake-parts";
        nodal.inputs.flake-parts.inputs.nixpkgs-lib.follows = lib.mkDefault "nixpkgs";
        nodal.inputs.import-tree.follows = lib.mkDefault "import-tree";
      };
    };
  };

  flake.templates = {
    dendritic = {
      description = "dendritic template";
      path = ./../templates/dendritic;
    };
    flake-parts = {
      description = "flake-parts template";
      path = ./../templates/flake-parts;
    };
  };
}
