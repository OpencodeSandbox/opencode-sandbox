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
      sandbox = import ./module;
    };

    packages = util.forEachSystem ({
      pkgs,
      lib,
      system,
      ...
    }: rec {
      sandbox = pkgs.callPackage ./sandbox.nix {inherit self nixpkgs;};
      docs = pkgs.callPackage ./docs {};

      default = sandbox;
    });
  };
}
