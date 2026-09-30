{
  pkgs,
  lib,
  ...
}: {
  options.opencode-sandbox = {
    mem = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 8192;
      description = ''
        Amount of RAM made available to the sandbox in megabytes.

        Setting the limit too low won't cause the sandbox to crash but might
        result in certain processes being unexpectadly terminated.
      '';
    };

    vcpu = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 4;
      description = ''
        Number of virtual CPU cores made available to the sandbox.
      '';
    };

    storeSize = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 32768;
      description = ''
        Host storage reserved for the sandbox's nix store in megabytes.

        Data stored here is not persisted and is wiped on shutdown and restart.
        Make sure to set a high enough limit in accordance to your usecase as
        nix evalution will fail if the store is full.
      '';
    };

    forwardPorts = lib.mkOption {
      type = lib.types.listOf lib.types.ints.u16;
      default = [];
      example = lib.literalExpression "[8888]";
      description = ''
        Ports to forward for sandbox-to-host communication.

        This is mostly useful when exposing host services such as a local
        inference server which would be too impractical to run inside of a
        sandboxed environment. Special care should be taken when using this
        option not to expose any sensitive services.
      '';
    };

    baseEnv = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [busybox git];
      description = ''
        Base packages which make up the agent's default set of tools.

        When adding new tooling, it is preferrable to edit `extraEnv` instead.
        Only edit `baseEnv` if you wish to _remove_ certain tools which you do
        not want the agent to have access to.
      '';
    };

    extraEnv = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      example = lib.literalExpression "[pkgs.cowsay]";
      description = ''
        Extra packages which are used to augment the agent's available tooling.

        Use this to add project-specific tooling. It is a generally good idea to
        have `extraEnv` match your own development environment to make it easier
        for you to apply the agent's changes on the host.
      '';
    };

    opencode = lib.mkOption {
      type = lib.types.submodule {
        options = {
          package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.opencode;
            description = ''
              Opencode package in use inside of the sandbox.
            '';
          };

          config = lib.mkOption {
            type = lib.types.nullOr (lib.types.coercedTo lib.types.path builtins.readFile lib.types.str);
            default = null;
            example = lib.literalMD ''
              ```json
              {
                "$schema": "https://opencode.ai/config.json",
                "model": "anthropic/claude-sonnet-4-5",
              }
              ```
            '';
            description = ''
              Opencode configuration, either as a path to a file or as raw JSON/JSONC.

              When set, the configuration is written to `opencode.jsonc` in the shared
              work directory before opencode starts and removed again once it exits.
              Any pre-existing `opencode.jsonc` or `opencode.json` is backed up first
              and restored afterwards, so user configurations are never modified.
            '';
          };
        };
      };
    };

    volumeName = lib.mkOption {
      type = lib.types.str;
      default = "nix-store-overlay";
      internal = true;
    };
  };
}
