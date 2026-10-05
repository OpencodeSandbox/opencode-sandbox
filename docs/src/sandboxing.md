# Sandboxing strategy

Opencode Sandbox uses [microvm.nix] for declarative sandbox management. The current sandbox strategy
is quite simple and works by spawning a new, throw-away [QEMU] VM on each new session.

All local files, **including any which are `.gitignore`d**, are copied over to a new `.sandbox`
folder in the current working directory which is given its own randomized branch name. All existing
remotes are removed, and [`git.remote.url`] is configured as the default origin for the current
branch. The VM is then given access to `.sandbox` via a shared volume, with any other files on the
host remain inaccessible to the agent.

On shutdown, leftover changes are staged, committed and pushed to remote if and only if
[`git.shutdown.pushOnExit`] is set to `true`. Finally, `.sandbox` is removed along with the agent's
local branch, leaving remote as the only lasting source of truth.

[microvm.nix]: https://github.com/microvm-nix/microvm.nix
[QEMU]: https://www.qemu.org/
[`git.remote.url`]: ./options.md#gitremoteurl
[`git.shutdown.pushOnExit`]: ./options.md#gitshutdownpushonexit
