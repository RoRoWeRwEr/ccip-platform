# Recommended Main Branch Protection

Configure a ruleset for `main` in GitHub repository settings with these requirements:

- Require a pull request before merging and at least one explicit human approval.
- Require successful **Database CI / migrate-and-test** when its path filter applies and **Repository Policy / policy** on every PR.
- Require all conversations to be resolved.
- Dismiss stale approvals when new commits are pushed.
- Prevent direct pushes, including by administrators unless a documented break-glass procedure is used.
- Block force pushes and branch deletion.
- Require linear history if compatible with the chosen squash/rebase merge strategy.
- Do not allow agents or automation to bypass protections.
- Preserve final human approval; do not treat Claude, Codex, or a green workflow as approval.
- Do not enable automatic merge for migrations or security changes.

Also enable GitHub secret scanning and push protection where the repository plan supports them, and review Dependabot alerts. Repository settings must be applied and verified manually by the owner; committing this document does not change GitHub settings.
