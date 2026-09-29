{
  self,
  nixpkgs,
  system,
  pkgs,
  lib,
  busybox,
  opencode,
  mem ? 4096,
  vcpu ? 4,
  storeSize ? 8192,
  forwardPorts ? [],
  baseEnv ? [busybox],
  extraEnv ? [],
  opencodePackage ? opencode,
  volumeName ? "nix-store-overlay",
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
            opencodePackage
            volumeName
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
