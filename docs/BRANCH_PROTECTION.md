# Recommended Main Branch Protection (Direct-to-Main Workflow)

The repository owner has authorized direct pushes to `main` for routine migration delivery, provided the workflow in `docs/DEVELOPMENT_WORKFLOW.md` is followed. Configure a ruleset for `main` in GitHub repository settings with these requirements:

- Do not require a pull request before pushing to `main`; a direct push of one cohesive, locally validated migration is the normal delivery path.
- Restrict who can push directly to `main` to the repository owner and explicitly authorized delivering agents or accounts. Do not extend this to arbitrary collaborators.
- Block force pushes and branch deletion on `main`, without exception.
- Require **Database CI / migrate-and-test** and **Repository Policy / policy** to run on every push to `main` that touches the relevant paths. Because these run after the push lands (there is no pre-merge PR gate in this workflow), a failure is a stop-and-forward-fix event per `docs/DEVELOPMENT_WORKFLOW.md`, not a blocked merge.
- Preserve migration immutability: `scripts/validate_repository_policy.sh` rejects any change that renames, reorders, or deletes an already-merged migration file; do not disable or weaken this check.
- Do not allow agents or automation to bypass migration-immutability, forward-fix, or one-migration-per-delivery requirements, even when they are authorized to push directly.
- If a Pull Request is opened for the exceptional path described in `docs/DEVELOPMENT_WORKFLOW.md`, require at least one explicit human approval and all conversations resolved before that PR is merged, and do not enable automatic merge for migrations or security changes.
- Preserve final human authority over the workflow itself; do not treat Claude, Codex, or a green GitHub Actions run as a substitute for the owner's standing authorization or for their ability to revoke or narrow it at any time.

Also enable GitHub secret scanning and push protection where the repository plan supports them, and review Dependabot alerts. Repository settings must be applied and verified manually by the owner; committing this document does not change GitHub settings.
