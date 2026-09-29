{
  pkgs,
  lib,
  ...
}: {
  options.opencode-sandbox = {
    mem = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 4096;
    };

    vcpu = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 4;
    };

    storeSize = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 8192;
    };

    forwardPorts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };

    baseEnv = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [pkgs.busybox];
    };

    extraEnv = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
    };

    opencodePackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.opencode;
    };

    volumeName = lib.mkOption {
      type = lib.types.str;
      default = "nix-store-overlay";
    };
  };
}
