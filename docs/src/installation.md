# Installation

> [!CAUTION]
> It is recommended NOT to override `opencode-sandbox`'s `nixpkgs` input as this can lead to using
> an out-of-date or dysfunctional version of Opencode inside the sandbox.

Opencode Sandbox is available as both a _flake package_ and _nixos module_. Start by adding it to
your flake inputs:

```nix
{
  # Add this to your flake inputs
  inputs.opencode-sandbox.url = "github:OpencodeSandbox/opencode-sandbox";

  outputs = {nixpkgs, opencode-sandbox, ...}: {
    # ...
  }
}
```

## Flake package

The project flake exposes a `sandbox` package which you can use directly to configure your own
virtual environments. See the [options reference](./options.md) for a list of all configuration
options.

> [!NOTE]
> The `sandbox` package requires you to specify `git.remote.url` in order to work. **Set this to the
> remote url you want your agent to use when calling `git push`**.

```nix
  outputs = {
    nixpkgs,
    opencode-sandbox,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system} = rec {
      sandbox = opencode-sandbox.packages.${system}.sandbox.override {
        opencode-sandbox = {
          # REQUIRED: the origin used by your agent when calling `git push`
          git.remote.url = "https://github.com/OpencodeSandbox/opencode-sandbox.git";
        };
      };
    };
  };
```

## NixOS Module

Alternatively, Opencode Sandbox also exposes a NixOS module which you can use to invoke `sandbox`
declaratively.

> [!WARNING]
> It is recommended to use the `sandbox` flake package instead. The NixOS module is mostly intended
> for internal configuration but might be useful in some advanced declarative setups. Only reach for
> it if your use case is not already satisfied by the `sandbox` package.
>
> You can find an example of how to use the `sandbox` module under [`examples/nixos-module`].

```nix
  outputs = {
    self,
    nixpkgs,
    opencode-sandbox,
    ...
  }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations.sandbox = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        opencode-sandbox.nixosModules.sandbox

        ({...}: {
          # opencode-sandbox automatically configures the default login user
          # and runs opencode on startup.
          opencode-sandbox.git.remote.url = ''
            https://github.com/OpencodeSandbox/opencode-sandbox.git
          '';

          system.stateVersion = "26.11";
        })
      ];
    };

    packages.${system} = let
      configuration = self.nixosConfigurations.sandbox.config;
    in rec {
      sandbox = configuration.opencode-sandbox.sandbox.package;
      default = sandbox;
    };
  };
```

[`examples/nixos-module`]: https://github.com/OpencodeSandbox/opencode-sandbox/tree/main/examples/nixos-module
