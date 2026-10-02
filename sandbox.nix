{
  self,
  nixpkgs,
  pkgs,
  lib,
  system,
  opencode-sandbox ? {},
  ...
}: let
  configuration = nixpkgs.lib.nixosSystem {
    inherit system;

    modules = [
      self.nixosModules.microvm
      self.nixosModules.sandbox

      ({...}: {
        config.opencode-sandbox = opencode-sandbox;
      })
    ];
  };
in
  configuration.config.opencode-sandbox.sandbox
