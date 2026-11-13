## Using it in new projects

### New nodal dendritic layout project

- recommended for consumer simplicity

- make a new project using the nodal dendritic layout structure and library:

  ```shell
  nix flake init -t github:synace/nodal#dendritic
  ```

---

#### Usage instructions

  - [Features](#features)
  - [Importing nodal modules](#importing-nodal-modules)
  - [Step by step example](#step-by-step-example)


  - [Manual configuration](#manual-configuration)
    - [New flake-parts project](#new-flake-parts-project)
    - [Existing project nodal dendritic usage](#existing-project-nodal-dendritic-usage)
    - [Existing project flake-parts usage](#existing-project-flake-parts-usage)
---

## Features

- follows the dendritic pattern and provides the boilerplate needed to apply it

- includes a handful of easy to apply modules in your project's `./modules/` 
  from this library's feature aspects in `./modules/nodal/`, such as:
  ```nix
  inputs.nodal.modules.flake."nodal/home-manager"
  inputs.nodal.modules.nixos."nodal/home-manager"
  inputs.nodal.modules.nixos."nodal/experimental"
  ```

- uses flake-parts module structure and imports them from the `./modules/` folder

- adds `nix run .#write-flake` support to create your `flake.nix` file from the contents of the `./modules/` folder

  - use `flake-file.inputs = {};` to add new inputs (see `denful/flake-file` docs for more info)

  - then `nix run .#write-flake` to update your root `flake.nix` file

  - then run `nix flake check` to see the new inputs applied

  - then add your modules and configuration options that the module and input provides

### Importing nodal modules

- for modules defined in nodal's `./modules/nodal/`:

  - ### `inputs.nodal.modules.<class>.<name>`
    for classes: `flake`, `nixos`, `homeManager`, `darwin`, `generic`, and more


  - `nodal/home-manager.nix` defines a top-level `flake` module that can be imported into the top level of your flake
    - e.g. to bring home-manager into your top-level flake, import it as:

      `inputs.nodal.modules.flake."nodal/home-manager"`

  - `nodal/home-manager.nix` also defines a lower-level `nixos` module that can be imported into nixosConfigurations 
    - e.g. to configure home-manager in your nixosConfiguration, pass along inputs via **specialArgs** (or otherwise), and import it as:
  
      `inputs.nodal.modules.nixos."nodal/home-manager"`
      - for **specialArgs**, see [Step by step example](#step-by-step-example) section 3.

### Step by step example

1. import into a top-level aspect, e.g. `./modules/home-manager.nix`:

    ```nix
    { inputs, ... }:
    {
      imports = [
        # nodal: import into this top-level module from nodal/home-manager.nix flake.modules.flake."nodal/home-manager"
        inputs.nodal.modules.flake."nodal/home-manager"
      ];
    }
    ```

2. update your inputs to include any required by the module 

    - **dendritic**: update the dynamic flake-file by running `nix run .#write-flake`

    - **flake-parts**: add them to your inputs manually


3. import into a "host" configuration, e.g. `./modules/my-host.nix`:

    ```nix
    { inputs, ... }:
    {
      flake.nixosConfigurations.my-host = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; }; # pass inputs to the nodal modules
        modules = [
          {
            imports = [
              # nodal: import into this nixosConfiguration from nodal/home-manager.nix flake.modules.nixos."nodal/home-manager"
              inputs.nodal.modules.nixos."nodal/home-manager"
              # nodal: import into this nixosConfiguration from nodal/experimental.nix: flake.modules.nixos."nodal/experimental"
              inputs.nodal.modules.nixos."nodal/experimental"
            ];
            # example minimal config, use your own instead
            system.stateVersion = "26.05";
            fileSystems."/".device = "/dev/disk/by-label/nixos";
            fileSystems."/".fsType = "ext4";
            boot.loader.grub.device = "nodev";
          }
        ];
        system = "x86_64-linux";
      };
    }
    ```

## Manual configuration

#### New flake-parts project

- for manual flake.nix management without flake-file and import-tree

- make a new project  flake.nix with **nixpkgs** and **flake-parts** inputs

  ```shell
  nix flake init -t github:synace/nodal#flake-parts
  ```

#### Existing project nodal dendritic usage

- adds inputs: **nixpkgs**, **flake-parts**, **flake-file** and **import-tree**

- brings along the dynamic `flake.nix` and dendritic `./modules` import support

- may require a temporary `flake.nix` file if you don't already use `nix run .#write-flake`

- read `denful/flake-file` docs on how to migrate first or go back to [New nodal dendritic layout project](#new-nodal-dendritic-layout-project)

  #### configuration

  - add the input and import the flakeModule

    ```nix
    flake-file.inputs.nodal.url = "github:synace/nodal";
    imports = [ inputs.nodal.flakeModules.default ];
    ```

#### Existing project flake-parts usage

- manual flake.nix management without flake-file and import-tree

- just import nodal modules to import where needed

  #### configuration

  - requires inputs: **nixpkgs** and **flake-parts**

  - add nodal input, import the `inputs.nodal.flakeModules.modules` flake module

    ```nix
    inputs.nodal.url = "github:synace/nodal";
    imports = [ inputs.nodal.flakeModules.modules ];
    ```

  #### de-duplicating inputs with follows

  - set `follows` on nodal's inputs to de-duplicate and prevent override and prevent "_2" entries in your flake.lock

    ```nix
      inputs.nodal = {
        url = "github:synace/nodal";
        inputs = {
          flake-parts = {
            follows = "flake-parts";
            inputs.nixpkgs-lib.follows = "nixpkgs";
          };
          nixpkgs.follows = "nixpkgs";
        };
      };
      ```