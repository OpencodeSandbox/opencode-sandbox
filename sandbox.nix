{
  self,
  nixpkgs,
  pkgs,
  lib,
  stdenv,
  opencode-sandbox ? {},
  ...
}: let
  configuration = nixpkgs.lib.nixosSystem {
    inherit (stdenv.hostPlatform) system;

    modules = [
      self.nixosModules.microvm
      self.nixosModules.sandbox

      ({...}: {
        opencode-sandbox = opencode-sandbox;
        system.stateVersion = "26.11";
      })
    ];
  };
in
  configuration.config.opencode-sandbox.sandbox.package
