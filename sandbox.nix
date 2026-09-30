{
  self,
  nixpkgs,
  system,
  pkgs,
  lib,
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

  runner = configuration.config.microvm.declaredRunner;
  volumeName = configuration.config.opencode-sandbox.volumeName;
in
  pkgs.writeShellScriptBin "sandbox" ''
    rm -f ${volumeName}.img
    ${lib.getExe runner}
    rm -f ${volumeName}.img
  ''
