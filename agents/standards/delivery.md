# Delivery

## Repositories

- A new contributor must be able to clone, build, and run the tests in under 10 minutes by following the README.
- Provide one entry point, such as a Makefile, for `install`, `build`, `run`, `test`, and `clean`. CI runs the same commands.
- Keep the README to what the service does in two or three sentences, how to start it, and every environment variable.
- Keep dependencies minimal. Each one adds upgrade work and CVE exposure. Automate dependency updates.
- Use pre-commit hooks for lint and format only, under 15 seconds. Run build and tests in pre-push.

## CI/CD

- Use trunk-based development with short-lived branches. Do not use branches per environment.
- Treat CI as an orchestrator. Put logic in scripts that also run locally, not in pipeline YAML.
- Require lint, format, type, and test checks to pass before merge.
- Keep the pipeline from commit to production under 15 minutes.
- Build one immutable artifact and promote it through environments with configuration from the environment.
- Deploy small changes often. Separate deploy from release: ship code dark and release it with a feature flag.
- Use staged rollouts with automated rollback on key metrics.
- Make every change safe to roll back. Keep state changes forward and backward compatible.
- Keep a release checklist for checks you cannot automate. Add an item whenever a problem escapes to production (SQLite §10).

## Issues

- Open issues only for reproducible bugs and accepted, scoped features. Use discussions for questions and ideas (Ghostty `CONTRIBUTING.md`).
- In projects with an issue tracker, link every pull request to an accepted issue.

## Commits

- Write Conventional Commits; see the `commit` skill.
- Commit small, focused changes. Squash on merge and rebase onto the main branch.

## Pull requests

- Keep pull requests small. Aim to open at least one a day, and use stacked pull requests for large features.
- Read your own diff before you open a pull request.
- In the description, state the goal, link the issue or spec, and list what is out of scope and any follow-up work. Attach screenshots for UI changes.
- For a bug fix, describe the old behaviour and its cause, then give reproduction steps with before and after output (Ghostty `a2e4403`, `7db25f9`).
- For a change that affects performance, include a benchmark table with the command, input, and before and after numbers. State the cost you accepted (Ghostty `a2e4403`).
- State known limitations and the options you chose not to implement.
- Say which agent helped and what you verified yourself (Ghostty `AI_POLICY.md`).
- Open a draft pull request early for work that takes more than a day.
- Do not submit code you have not run and verified yourself. Review any agent-written description before you post it.

## Code review

- Check that the change meets the requirements and works.
- Comment only on real problems: functionality, performance, reliability, or a significant bug risk. Let stylistic preferences go unless they are egregious.
- Do not leave style comments. If the linter allows it, it is valid; propose a lint rule instead.
- Check that tests sit at the right level and that new code is instrumented.
- Raise architectural disagreements before code review. If a change needs major rework, suggest a call instead of many comments.
- Frame feedback as suggestions, and be kind. Prefer a follow-up pull request to blocking on minor issues.
- Review within a few hours, and aim to merge within a day.
