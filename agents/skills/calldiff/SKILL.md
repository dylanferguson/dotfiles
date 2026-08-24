---
name: calldiff
description: Explain what changed behaviorally between two revisions, not just line diffs, by walking the changed call trees.
disable-model-invocation: true
---

Run `npx calldiff@latest [from] [to]` (defaults: from=HEAD, to=working tree) and walk through the changed call trees it reports. It supports TypeScript/TSX, JavaScript, Python, Go, Rust, Java, Ruby, C, C++, C#, PHP, Kotlin, Swift, Scala, Lua, Elixir, Bash, Haskell, Zig, Solidity, and OCaml. For an unsupported language, delegate to an Explore agent: list the functions the diff touches, then grep each for its callers/callees before and after to reconstruct the same call-tree diff by hand, sticking to function signatures — do not read into function bodies beyond that.
