---
name: commit
description: Write a commit message using Conventional Commits with a mitchellh-style body.
disable-model-invocation: true
---

# Commit

Subject line follows [Conventional Commits](https://www.conventionalcommits.org):
`type(scope): summary` — imperative, lowercase, no trailing period, under 72
characters.

Body follows Mitchell Hashimoto's style: prose paragraphs wrapped at 72
columns, explaining the problem that existed before this commit, why the change
is the right fix, and anything a reader would otherwise have to reconstruct from
the diff — alternatives rejected, edge cases, follow-up work left undone. Write
for someone reading `git log` in two years with no memory of this work.

The diff already says what changed. The body says why.

Skip the body when the change is genuinely self-explanatory: a typo fix, a
version bump, a rename. Don't pad one to satisfy the form.

No emoji. No "Generated with" trailers unless the repo already uses them.
