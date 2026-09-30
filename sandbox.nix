{
  self,
  nixpkgs,
  system,
  pkgs,
  lib,
  mem ? 8192,
  vcpu ? 4,
  storeSize ? 32768,
  forwardPorts ? [],
  baseEnv ? [pkgs.busybox],
  extraEnv ? [],
  volumeName ? "nix-store-overlay",
  opencode ? {
    package = pkgs.opencode;
    config = null;
  },
  ...
}: let
  configuration = nixpkgs.lib.nixosSystem {
    inherit system;

    modules = [
      self.nixosModules.microvm
      self.nixosModules.sandbox

      ({...}: {
        config.opencode-sandbox = {
          inherit
            mem
            vcpu
            storeSize
            forwardPorts
            baseEnv
            extraEnv
            volumeName
            opencode
            ;
        };
      })
    ];
  };

  runner = configuration.config.microvm.declaredRunner;
in
  pkgs.writeShellScriptBin "sandbox" ''
    rm -f ${volumeName}.img
    ${lib.getExe runner}
    rm -f ${volumeName}.img
  ''
