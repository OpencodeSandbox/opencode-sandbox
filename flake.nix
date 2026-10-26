{
  description = "Micro-vm based opencode sandbox running NixOs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixlib.url = "github:nix-util/nixlib";

    microvm.url = "github:microvm-nix/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

    opencode.url = "github:anomalyco/opencode";
    opencode.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {nixlib, ...} @ inputs:
    nixlib.flake inputs ({
      self,
      opencode,
      ...
    }: {
      systems = ["x86_64-linux"];

      nixosModules = {
        inherit (inputs.microvm.nixosModules) microvm;

        sandbox = {...}: {
          imports = [./module];
          _module.args.opencode = opencode;
        };
      };

      perSystem = {
        self',
        opencode',
        pkgs,
        lib,
        libmodules,
        libpkgs,
        ...
      }: {
        formatter = pkgs.alejandra;

        packages = rec {
          inherit (opencode'.packages) opencode;

          # Base sandbox package, see `module` for options and package configuration
          sandbox = libpkgs.mkOverride ({opencode-sandbox ? {}, ...}: (libmodules.build {
            name = "opencode-sandbox.sandbox.package";

            modules = [
              self.nixosModules.microvm
              self.nixosModules.sandbox

              ({...}: {
                inherit opencode-sandbox;
                system.stateVersion = "26.11";
              })
            ];
          }));

          # Auto-generates module option documentation off `module/options.nix`
          docs = libmodules.docs {
            modules = lib.attrValues self.nixosModules;
            name = "opencode-sandbox";
          };

          # CI dependencies, can be installed with `nix profile install .#ci`
          ci = libpkgs.mkEnv {
            packages = with pkgs; [
              mdbook
              typos
              markdownlint-cli2
              lychee
            ];
          };

          default = sandbox;
        };

        devShells = {
          default = pkgs.mkShell {
            packages = [self'.packages.ci];
          };
        };
      };
    });
}
