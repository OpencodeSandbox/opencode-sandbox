# Introduction

**Opencode Sandbox** is a simple [QEMU]-based sandbox for running your [opencode] agents in a safe
environment which is isolated from the host. It provides:

- A fully virtualized environment for your agents to run in
- The ability for your agents to download any missing packages at runtime from [`nixpkgs`]
- Easy sandbox configuration using the [`nix`] programming language
- Automatic feature branch creation on startup
- Support for locally run LLMS
- Built-in github authentication
- Access to virtualization tools such as Docker

It is primarily intended for parallel development, where you have a local agent focus on some small
bug or feature while you work on another branch.

## Limitations

The sandbox can be configured to automatically push any uncommitted changes to remote on shutdown
via the [`git.shutdown.pushOnExit`] option, which is disabled by default. Other than that, no files
are ever persisted on the host.

> [!CAUTION]
> Opencode Sandbox treats each agent's sessions as _ephemeral_. **Nothing** is persisted between
> runs: all agent files, conversation info and any local changes _will be deleted_ on shutdown.
> There is no option to change this, and will never be. **Untrusted code which has been written by
> an agent should never be run on the host until it has been properly reviewed**.

Opencode Sandbox does not currently support a graphical environment, and can only run backend or TUI
applications. This might change in the future, as QEMU makes graphic support easy, however this is
not a priority for the moment.

[QEMU]: https://www.qemu.org/
[opencode]: https://opencode.ai/
[`nix`]: https://nixos.org/
[`nixpkgs`]: https://search.nixos.org/packages
[`git.shutdown.pushOnExit`]: ./options.md#gitshutdownpushonexit
