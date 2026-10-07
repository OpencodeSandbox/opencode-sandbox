# Opencode Sandbox

A simple [qemu]-based sandbox for running your [opencode] agents. This project uses [microvm.nix]
under the hood for declarative VM management.

New sandboxes are configured using the [nix] programming language, allowing you to bundle in any
arbitrary dependency you might need for development.

> [!TIP]
> Check out the [docs] for more information and an extended setup guide.

## Getting started

Simply add `opencode-sandbox` to your flake inputs:

```nix
{
  inputs.opencode-sandbox.url = "github:OpencodeSandbox/opencode-sandbox";

  outputs = {nixpkgs, opencode-sandbox, ...}: {
    # ...
  }
}
```

From there you can configure your own sandbox environments by overriding the `sandbox` package:

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
          git.remote.url = "https://github.com/OpencodeSandbox/opencode-sandbox.git";
          env.extend = with pkgs; [nodejs prettier];
        };
      };
    };
  };

```

Check out the [opencode docs] for information on how to configure opencode. You can also find a few
self-contained examples under the `examples/` folder.

```bash
nix run ./examples/shared-env
```

[qemu]: https://www.qemu.org/
[opencode]: https://opencode.ai/
[microvm.nix]: https://github.com/microvm-nix/microvm.nix
[docs]: https://opencodesandbox.github.io/opencode-sandbox/
[nix]: https://nixos.org/
[opencode docs]: https://opencode.ai/docs
