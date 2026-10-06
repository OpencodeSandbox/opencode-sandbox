# Connecting to Github

Opencode Sandbox supports connecting your agents to a remote Github repository by default.

## Fine-grained PAT

Fine-grained Personal Access Tokens are the recommended way to connect your agent to a Github
repository. Head over to the [PAT creation page] on Github. From there, choose **"only select
repositories"**.

Agents require at minimum a permission scope of _read_ and _write_ on `Contents` to be able to
create new branches and commits. It is recommended to limit yourself to this scope and perform all
other operations (pull request creation, review and merging) manually.

Once you are done, simply add the resulting PAT to the root-level `.env` in your selected
repository.

> [!CAUTION]
> The name of the env variable you store your token in must match that declared by the
> [`git.auth.token`] option (defaults to `GH_TOKEN`).

```bash
GH_TOKEN=github_pat_xxx
```

[PAT creation page]: https://github.com/settings/personal-access-tokens/new
[`git.auth.token`]: ./options.md#gitauthtoken
