# Skills

Vendor-agnostic agent skills. `install.sh` symlinks this directory to
`~/.claude/skills` and `~/.agents/skills`; `agents-here` links it into a project.

Every skill here carries `disable-model-invocation: true` — nothing fires on its
own, invoke by name. Keep that line when adding or updating a skill.

## Original

| Skill | What |
| --- | --- |
| `commit` | Conventional Commits subject, mitchellh-style body. |
| `judge` | Adversarial review — assume the code is broken until proven otherwise. |
| `typography-audit` | Audit or set type against Butterick's *Practical Typography*. |
| `bro` | Restate the last message in plain language. |
| `eli5` | Explain a topic for a total beginner, as an HTML artifact. |
| `calldiff` | Walk the changed call trees to explain what changed behaviorally. |

## Created by others

### Installed via `npx skills`

The registry is [skills.sh](https://skills.sh/). Installed with `--copy` so the
files live in this repo rather than symlinking into a clone.

| Skill | Source | Reinstall |
| --- | --- | --- |
| `show-me` | HumanLayer — [post](https://www.humanlayer.com/blog/show-me-skill), [repo](https://github.com/humanlayer/skills) | `npx skills add humanlayer/skills --skill show-me --agent claude-code --global --copy` |

### Other sources

| Skill | Source |
| --- | --- |
| `audit-your-codebase` | Aaron Francis — [gist](https://gist.github.com/aarondfrancis/8735edbe48532f97ee5ea818db4dbd47) |
| `arena` | Unrecorded. |
| `thermo-nuclear-code-quality-review` | Unrecorded. Added in `3c0ed71`. |

Matt Pocock, attributed from `@total-typescript` and `ai-hero-cli` references in
the wider set these came from. They expect a `CONTEXT.md` domain glossary and
ADRs in `docs/adr/`, and degrade to generic advice without them.

| Skill | What |
| --- | --- |
| `tdd` | Red-green-refactor, integration-style tests through public interfaces. |
| `improve-codebase-architecture` | Find deepening opportunities — shallow modules into deep ones. |
| `grill-me` | Interview the user about a plan until shared understanding. |

## Removed

Kept as a record in case a real use case turns up. Recover with
`git show <commit>:agents/disabled-skills/<name>/SKILL.md` — all three were
disabled in `d4b1bb2` and deleted in the commit that added this README.

| Skill | Source |
| --- | --- |
| `tufte-viz` | aparente — [gist](https://gist.github.com/aparente/e48c353755958621b3c0004593105a90). This copy predates the eraser and collision tests in [GarrettMooney/tufte-viz](https://github.com/GarrettMooney/tufte-viz), a credited redistribution. |
| `caveman` | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman). This copy is a single-file condensation of it. |
| `ponytail` | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) — `ponytail-review`, `ponytail-audit`, `ponytail-debt`, `ponytail-help`. |
