{ inputs, ... }: {
  flake-file.inputs = {
    nodal.url = "github:synace/nodal";
  };
  imports = [
    inputs.nodal.flakeModules.default
  ];
}
