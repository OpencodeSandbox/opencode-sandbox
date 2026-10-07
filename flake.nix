{
  description = "Micro-vm based opencode sandbox running NixOs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    microvm.url = "github:microvm-nix/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    microvm,
    ...
  }: let
    systems = ["x86_64-linux"];
    util = import ./util.nix {inherit nixpkgs systems;};
  in {
    formatter = util.forEachSystem ({pkgs, ...}: pkgs.alejandra);

    nixosModules = {
      inherit (microvm.nixosModules) microvm;
      sandbox = import ./module {inherit self;};
    };

    packages = util.forEachSystem ({
      pkgs,
      lib,
      system,
      ...
    }: rec {
      # Base sandbox package, see `module` for options and package configuration
      sandbox = pkgs.callPackage ./sandbox.nix {inherit self nixpkgs;};

      # Auto-generates module option documentation off `module/options.nix`
      docs = pkgs.callPackage ./docs {};

      # CI dependencies, can be installed with `nix profile install .#ci`
      ci = pkgs.buildEnv {
        name = "ci";
        paths = with pkgs; [
          mdbook
          typos
          markdownlint-cli2
          lychee
        ];
      };

      default = sandbox;
    });

    devShells = util.forEachSystem ({
      pkgs,
      system,
      ...
    }: {
      default = pkgs.mkShell {
        packages = [self.packages.${system}.ci];
      };
    });
  };
}
