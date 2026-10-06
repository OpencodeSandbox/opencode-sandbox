{
  config,
  pkgs,
  lib,
  ...
}: {
  options.opencode-sandbox = {
    forwardPorts = lib.mkOption {
      description = ''
        Ports to forward for sandbox-to-host communication.

        This is mostly useful when exposing host services such as a local
        inference server which would be too impractical to run inside of a
        sandboxed environment. Special care should be taken when using this
        option not to expose any sensitive or privileged services.

        When port forwarding is active, **ports will be made available inside of
        the sandbox at address 10.0.2.10**.
      '';

      type = lib.types.listOf lib.types.ints.u16;
      default = [];
      example = "[8888]";
    };

    env = lib.mkOption {
      description = ''
        Virtual machine development environment.
      '';

      type = lib.types.submodule {
        options = {
          base = lib.mkOption {
            description = ''
              Base packages which make up the agent's default set of tools.

              When adding new tooling, it is preferable to edit `env.extend` instead.
              Only edit `env.base` if you wish to _remove_ certain tools which you do
              not want the agent to have access to.
            '';

            type = lib.types.listOf lib.types.package;
            default = with pkgs; [busybox git];
          };

          extend = lib.mkOption {
            description = ''
              Extra packages which are used to augment the agent's available tooling.

              Use this to add project-specific tooling. It is generally a good idea to
              have `env.extend` match your own development environment to make it easier
              for you to apply the agent's changes on the host.
            '';

            type = lib.types.listOf lib.types.package;
            default = [];
            example = "[pkgs.cowsay]";
          };
        };
      };
    };

    limits = lib.mkOption {
      description = ''
        Virtual machine resource constraints
      '';

      type = lib.types.submodule {
        options = {
          mem = lib.mkOption {
            description = ''
              Amount of RAM made available to the sandbox, in megabytes.

              Setting the limit too low won't cause the sandbox to crash but might
              result in certain processes being unexpectedly terminated.
            '';

            type = lib.types.ints.unsigned;
            default = 8192;
          };

          vcpu = lib.mkOption {
            description = ''
              Number of virtual CPU cores made available to the sandbox.
            '';

            type = lib.types.ints.unsigned;
            default = 4;
          };

          store = lib.mkOption {
            description = ''
              Host storage reserved for the sandbox's nix store, in megabytes.

              Data stored here is not persisted and is wiped on shutdown and restart.
              Make sure to set a high enough limit in accordance to your use case as
              nix evaluation will fail if the store is full.
            '';

            type = lib.types.ints.unsigned;
            default = 32768;
          };
        };
      };
    };

    opencode = lib.mkOption {
      description = ''
        Opencode configuration options.
      '';

      type = lib.types.submodule {
        options = {
          package = lib.mkOption {
            description = ''
              Opencode package in use inside of the sandbox.
            '';

            type = lib.types.package;
            default = pkgs.opencode;
          };

          config = lib.mkOption {
            description = ''
              Opencode configuration, either as a path to a file or as raw JSON/JSONC.
            '';
            example = ''
              {
                "$schema": "https://opencode.ai/config.json",
                "model": "anthropic/claude-sonnet-4-5",
              }'';

            type = lib.types.nullOr (lib.types.coercedTo lib.types.path builtins.readFile lib.types.str);
          };
        };
      };
    };

    git = lib.mkOption {
      description = ''
        Git configuration options
      '';

      type = lib.types.submodule {
        options = {
          withLocalChanges = lib.mkOption {
            description = ''
              Whether or not to include local changes in the sandbox state.

              Keep in mind that using this option in combination with
              [`git.shutdown.pushOnExit`](./options.md#gitshutdownpushonexit)
              will result in any local changes also being pushed on VM shutdown!
            '';

            type = lib.types.bool;
            default = false;
          };

          remote = lib.mkOption {
            description = ''
              Remote repository configuration options.
            '';

            type = lib.types.submodule {
              options = {
                url = lib.mkOption {
                  description = ''
                    Remote repository url.
                  '';

                  type = lib.types.str;
                  example = "https://github.com/OpencodeSandbox/opencode-sandbox.git";
                };

                name = lib.mkOption {
                  description = ''
                    Remote repository used by the angent in the sandbox.

                    All other remotes are removed on startup.
                  '';

                  type = lib.types.str;
                  default = "origin";
                };
              };
            };
          };

          auth = lib.mkOption {
            description = ''
              Git authentication options.

              By default this is setup for use with github.
            '';

            type = lib.types.submodule {
              options = {
                enabled = lib.mkOption {
                  description = ''
                    Whether or not to configure git authentication.

                    Keep in mind that if the agent has access to the required
                    tokens as part of the project `.env` it will still be able
                    to setup authentication itself. If you wish to prevent your
                    agent from pushing to remote you will need to set up
                    appropriate branch and repository protection rules yourself.
                  '';

                  type = lib.types.bool;
                  default = true;
                };

                token = lib.mkOption {
                  description = ''
                    Environment variable used to source the authentication token.

                    This should be set in the root project `.env` so the sandbox
                    can load it.
                  '';

                  type = lib.types.str;
                  default = "GH_TOKEN";
                };

                credentials = lib.mkOption {
                  description = ''
                    Credential information to be passed to git.

                    This will be handed directly to `git credential approve` on
                    startup.
                  '';

                  type = lib.types.lines;
                  default = ''
                    protocol=https
                    host=github.com
                    username=x-access-token
                    password=${"$"}${config.opencode-sandbox.git.auth.token}'';
                };
              };
            };
          };

          shutdown = lib.mkOption {
            description = ''
              Git commands to run on sandbox shutdown after having closed
              Opencode.
            '';

            type = lib.types.submodule {
              options = {
                pushOnExit = lib.mkOption {
                  description = ''
                    Whether to commit and push any local changes to remote on shutdown.

                    If this option is set to false, any uncommited changes will NOT be persisted.
                  '';

                  type = lib.types.bool;
                  default = false;
                };

                message = lib.mkOption {
                  description = ''
                    Default commit message used if `pushOnExit` is enabled.
                  '';

                  type = lib.types.str;
                  default = "chore(opencode-sandbox): shutting down, persisting state";
                };
              };
            };
          };

          user = lib.mkOption {
            description = ''
              The agent's git user.

              By default this is set to point to the [OpencodeSandbox](https://github.com/OpencodeSandbox)
              github account.
            '';

            type = lib.types.submodule {
              options = {
                name = lib.mkOption {
                  description = ''
                    The agent's git username.
                  '';

                  type = lib.types.str;
                  default = "OpencodeSandbox";
                };

                email = lib.mkOption {
                  description = ''
                    The agent's git user email.
                  '';

                  type = lib.types.str;
                  default = "336851712+OpencodeSandbox@users.noreply.github.com";
                };
              };
            };
          };

          # TODO: commit signing?
        };
      };
    };

    volume = lib.mkOption {
      description = ''
        Nix store overlay volume configuration.

        Opencode Sandbox uses a QEMU volume to provide the VM with a writable nix store.
      '';

      type = lib.types.submodule {
        options = {
          dir = lib.mkOption {
            description = ''
              Where to store the nix store volume.
            '';

            type = lib.types.str;
            default = "./";
          };

          name = lib.mkOption {
            description = ''
              Nix store volume name.

              Will have `.img` appended at the end. The full volume path is:

              ```nix
              "''${config.opencode-sandbox.volume.dir}/''${config.opencode-sandbox.volume.name}.img"
              ```
            '';

            type = lib.types.str;
            default = "nix-store-overlay";
          };

          path = lib.mkOption {
            internal = true;

            type = lib.types.str;
            default = "${config.opencode-sandbox.volume.dir}/${config.opencode-sandbox.volume.name}.img";
          };
        };
      };
    };

    sandbox = lib.mkOption {
      description = ''
        Sandbox folder configuration.

        By default, any files the sandbox has access to are stored in a local
        folder `.sandbox` under the current working directory.
      '';

      type = lib.types.submodule {
        options = {
          dir = lib.mkOption {
            description = ''
              Where to store the sandbox folder.
            '';

            type = lib.types.str;
            default = "./";
          };

          name = lib.mkOption {
            description = ''
              Sandbox folder name.

              The full sandbox path is"

              ```nix
              "''${config.opencode-sandbox.sandbox.dir}/''${config.opencode-sandbox.sandbox.name}"
              ```
              "
            '';

            type = lib.types.str;
            default = ".sandbox";
          };

          path = lib.mkOption {
            internal = true;

            type = lib.types.str;
            default = "${config.opencode-sandbox.sandbox.dir}/${config.opencode-sandbox.sandbox.name}";
          };

          package = lib.mkOption {
            internal = true;

            type = lib.types.package;
          };
        };
      };
    };
  };
}
