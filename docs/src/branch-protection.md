# Branch protection

While Opencode Sandbox protects your local environment, it does nothing to safeguard remote. A rogue
agent may still force-push, force-merge, or just generally invalidate history.

> [!NOTE]
> The following assumes a remote `Github` repository, however the same practices should also apply
> to other git hosting services.

The single most important safeguard you can enable are [Github branch rulesets]. Apply the following
settings:

## For the default branch

The goal of this rule is to prevent a rogue agent from overwriting `main`. Ideally these settings
should already be enabled.

- Restrict creations
- Restrict updates
- Restrict deletions
- Block force pushes
- Require a pull request before merging
- Required approvals > 0
- Require approval of the most recent reviewable push
- Require status checks to pass (include any important CI jobs, such as security scans)
- Require code scanning results (if code scanning is enabled, ex: vulnerabilities detection)

## For all branches

Exclude `sandbox*` branches by pattern so that this protection rule only applies to all branches
which are _not_ created by the sandboxed agent. The goal of this rule is to safeguard the work of
other committers from being overwritten by a rogue agent.

- Restrict creations
- Restrict updates
- Restrict deletions
- Block force pushes
- Require a pull request before merging
- Required approvals > 0

Then, give all other contributors bypass permission _except_ for the sandboxed agent. This makes it
so human contributors are able to push commits to their own branches as usual but an agent must ask
for permission first via a pull request.

[Github branch rulesets]: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets#branch-and-tag-rulesets
