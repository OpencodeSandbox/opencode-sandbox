# Getting started

> [!CAUTION]
> **Closing Opencode inside the sandbox will terminate the VM and wipe all session storage!**
> Changes are only pushed on shutdown if the [`git.shutdown.pushOnExit`] option is explicitly
> enabled, _which it is not by default_. Remember to ask your agent to push any local changes before
> exiting.

Opencode Sandbox is configured via overrides on the `sandbox` package. Some common configuration
options include:

| Name                        | Usage                                                                        |
|-----------------------------|------------------------------------------------------------------------------|
| [`git.remote.url`]          | Specifies the remote your agent will use for `git` commands                  |
| [`git.shutdown.pushOnExit`] | Stages, commits and pushes any leftover local changes on shutdown            |
| [`env.extend`]              | Allows you to add new packages to your agent's sandbox runtime environment   |
| [`limits.mem`]              | Amount of RAM made available to the sandbox in megabytes.                    |
| [`limits.vcpu`]             | Number of virtual CPU cores made available to the sandbox.                   |
| [`limits.store`]            | Host storage reserved for the sandbox’s nix store, in megabytes.             |
| [`opencode.config`]         | Opencode configuration, either as a path to a file or as raw JSON/JSONC.     |

See the [options reference](./options.md) for a list of all configuration
options.

<details>
    <summary>Example configuration</summary>

```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  # Step 1: add opencode-sandbox to your flake inputs
  inputs.opencode-sandbox.url = "github:OpencodeSandbox/opencode-sandbox";

  outputs = {
    nixpkgs,
    opencode-sandbox,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system} = rec {
      # Step 2: add your own sandbox package to your flake's outputs
      sandbox = opencode-sandbox.packages.${system}.sandbox.override {
        # Step 3: configure opencode-sandbox with a remote url and custom env
        opencode-sandbox = {
          git.remote.url = "https://github.com/OpencodeSandbox/opencode-sandbox.git";
          env.extend = with pkgs; [nodejs prettier]
        };
      };

      # Optional: set your custom sandbox as the flake's default package.
      default = sandbox;
    };
  };
}
```

</details>

## Environment values

Opencode Sandbox will automatically source any `.env` file found at the root of the current working
directory. This can be used to authenticate with remote model providers or just give your agent
controlled access to certain local APIs it needs as part of its development workflow.

## Configuring Opencode

> [!TIP]
> Opencode will automatically load any `opencode.jsonc` at the root of your repository.
> You can also load a custom `opencode.jsonc` using [`opencode-sandbox.opencode.config`].

By default Opencode will ask for user confirmations when accessing folders outside of its project
directory. This makes sense on the host machine but ends up being a hindrance when running inside of
a sandboxed environment. To disable this, add the following to your `opencode.jsonc` config:

```json
{

  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "external_directory": {
      "*": "allow"
    }
  }
}
```

Opencode Sandbox uses the latest stable version of Opencode. For more info on how to configure
Opencode, check its [v1 docs].

## Running Opencode Sandbox

Once you have your agent's environment configured, you can start the VM by invoking your own
`sandbox` package:

```bash
nix run .#sandbox
```

This will open up an interactive Opencode TUI session which you can use to send prompts to the model.
To exit the sandbox, simply shutdown Opencode with `:q`.

[`git.shutdown.pushOnExit`]: ./options.md#gitshutdownpushonexit
[`git.remote.url`]: ./options.md#gitremoteurl
[`env.extend`]: ./options.md#envextend
[`limits.mem`]: ./options.md#limitsmem
[`limits.vcpu`]: ./options.md#limitsvcpu
[`limits.store`]: ./options.md#limitsstore
[`opencode.config`]: ./options.md#opencodeconfig
[`opencode-sandbox.opencode.config`]: ./options.md#opencodeconfig
[v1 docs]: https://opencode.ai/docs
