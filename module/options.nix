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
      type = lib.types.listOf lib.types.ints.u16;
      default = [];
    };

    baseEnv = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        busybox
        git
      ];
    };

    extraEnv = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
    };

    opencodePackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.opencode;
    };

    opencodeConfig = lib.mkOption {
      type = lib.types.nullOr (lib.types.coercedTo lib.types.path builtins.readFile lib.types.str);
      default = null;
      description = ''
        Opencode configuration, either as a path to a file or as raw JSON/JSONC.

        When set, the configuration is written to `opencode.jsonc` in the shared
        work directory before opencode starts and removed again once it exits.
        Any pre-existing `opencode.jsonc` or `opencode.json` is backed up first
        and restored afterwards, so user configurations are never modified.
      '';
    };

    volumeName = lib.mkOption {
      type = lib.types.str;
      default = "nix-store-overlay";
    };
  };
}
