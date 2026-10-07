# Option reference

## `env`

_type_: `submodule`

Virtual machine development environment.

## `env.base`

_type_: `list of package`

_default_: `[pkgs.busybox pkgs.git]`

Base packages which make up the agent's default set of tools.

When adding new tooling, it is preferable to edit [`env.extend`]
instead. Only edit this option if you wish to _remove_ certain
tools which you do not want the agent to have access to.

[`env.extend`]: ./options.md#envextend

## `env.extend`

_type_: `list of package`

_default_: `[]`

Extra packages which are used to augment the agent's available
tooling.

Use this to add project-specific tooling. It is generally a good
idea to have this option match your own development environment to
make it easier for you to apply the agent's changes on the host.

### Example

```nix
opencode-sandbox = {
  env.extend = [pkgs.cowsay];
};
```

## `forwardPorts`

_type_: `list of 16 bit unsigned integer; between 0 and 65535 (both inclusive)`

_default_: `[]`

Ports to forward for sandbox-to-host communication.

This is mostly useful when exposing host services such as a local
inference server which would be too impractical to run inside of a
sandboxed environment. Special care should be taken when using this
option not to expose any sensitive or privileged services.

When port forwarding is active, **ports will be made available inside of
the sandbox at address 10.0.2.10**.

### Example

```nix
opencode-sandbox = {
  forwardPorts = [8888];
};
```

## `git`

_type_: `submodule`

Git configuration options

## `git.auth`

_type_: `submodule`

Git authentication options.

By default this is setup for use with github.

## `git.auth.credentials`

_type_: `strings concatenated with "\n"`

_default_:

```ini
protocol=https
host=github.com
username=x-access-token
password=$GH_TOKEN
```

Credential information to be passed to git.

This will be handed directly to `git credential approve` on
startup.

## `git.auth.enabled`

_type_: `boolean`

_default_: `true`

Whether or not to configure git authentication.

Keep in mind that if the agent has access to the required
tokens as part of the project `.env` it will still be able
to setup authentication itself. If you wish to prevent your
agent from pushing to remote you will need to set up
appropriate branch and repository protection rules yourself.

## `git.auth.token`

_type_: `string`

_default_: `GH_TOKEN`

Environment variable used to source the authentication token.

This should be set in the root project `.env` so the sandbox
can load it.

## `git.remote`

_type_: `submodule`

Remote repository configuration options.

## `git.remote.name`

_type_: `string`

_default_: `origin`

Remote repository used by the angent in the sandbox.

All other remotes are removed on startup.

## `git.remote.url`

_type_: `string`

Remote repository url.

### Example

```nix
opencode-sandbox = {
  git.remote.url = https://github.com/OpencodeSandbox/opencode-sandbox.git;
};
```

## `git.shutdown`

_type_: `submodule`

Git commands to run on sandbox shutdown after having closed
Opencode.

## `git.shutdown.message`

_type_: `string`

_default_: `chore(opencode-sandbox): shutting down, persisting state`

Default commit message used if [`pushOnExit`] is enabled.

[`pushOnExit`]: ./options.md#gitshutdownpushonexit

## `git.shutdown.pushOnExit`

_type_: `boolean`

_default_: `false`

Whether to commit and push any local changes to remote on
shutdown.

If this option is set to false, any uncommitted changes will
NOT be persisted.

## `git.user`

_type_: `submodule`

The agent's git user.

By default this is set to point to the [OpencodeSandbox] github
account.

[OpencodeSandbox]: https://github.com/OpencodeSandbox

## `git.user.email`

_type_: `string`

_default_: `336851712+OpencodeSandbox@users.noreply.github.com`

The agent's git user email.

## `git.user.name`

_type_: `string`

_default_: `OpencodeSandbox`

The agent's git username.

## `git.withLocalChanges`

_type_: `boolean`

_default_: `false`

Whether or not to include local changes in the sandbox state.

Keep in mind that using this option in combination with
[`git.shutdown.pushOnExit`] will result in any local changes also
being pushed on VM shutdown!

[`git.shutdown.pushOnExit`]: ./options.md#gitshutdownpushonexit

## `limits`

_type_: `submodule`

Virtual machine resource constraints

## `limits.mem`

_type_: `unsigned integer, meaning >=0`

_default_: `8192`

Amount of RAM made available to the sandbox, in megabytes.

Setting the limit too low won't cause the sandbox to crash but
might result in certain processes being unexpectedly terminated.

## `limits.store`

_type_: `unsigned integer, meaning >=0`

_default_: `32768`

Host storage reserved for the sandbox's nix store, in megabytes.

Data stored here is not persisted and is wiped on shutdown and
restart. Make sure to set a high enough limit in accordance to
your use case as nix evaluation will fail if the store is full.

## `limits.vcpu`

_type_: `unsigned integer, meaning >=0`

_default_: `4`

Number of virtual CPU cores made available to the sandbox.

## `opencode`

_type_: `submodule`

Opencode configuration options.

## `opencode.config`

_type_: `null or (string or absolute path convertible to it)`

Opencode configuration, either as a path to a file or as raw
JSON/JSONC.

### Example

```nix
opencode-sandbox = {
  opencode.config = {
    "$schema": "https://opencode.ai/config.json",
    "model": "anthropic/claude-sonnet-4-5",
  };
};
```

## `opencode.package`

_type_: `package`

_default_: `pkgs.opencode`

Opencode package in use inside of the sandbox.

## `sandbox`

_type_: `submodule`

Sandbox folder configuration.

By default, any files the sandbox has access to are stored in a local
folder `.sandbox` under the current working directory.

## `sandbox.dir`

_type_: `string`

_default_: `./`

Where to store the sandbox folder.

## `sandbox.name`

_type_: `string`

_default_: `.sandbox`

Sandbox folder name.

The full sandbox path is:

```nix
"${config.opencode-sandbox.sandbox.dir}/${config.opencode-sandbox.sandbox.name}"
```

## `volume`

_type_: `submodule`

Nix store overlay volume configuration.

Opencode Sandbox uses a QEMU volume to provide the VM with a writable
nix store.

## `volume.dir`

_type_: `string`

_default_: `./`

Where to store the nix store volume.

## `volume.name`

_type_: `string`

_default_: `nix-store-overlay`

Nix store volume name.

Will have `.img` appended at the end. The full volume path is:

```nix
"${config.opencode-sandbox.volume.dir}/${config.opencode-sandbox.volume.name}.img"
```
