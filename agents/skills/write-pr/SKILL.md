---
name: write-pr
description: Write a pull request title and body.
disable-model-invocation: true
---

dont write essays, dont include that you ran tests. rather, write a concise body. use bullet points for the text you do write. 'validation/i ran tests' is not needed

focus on visuals that show the change. pick the smallest view that makes the key point clear:

- mermaid for interaction, control flow, or data flow
- a call tree, component tree, file tree, or short pseudocode when the new shape is the point
- a `diff` of that same shape when the point is what changed. match the diff shape to the topic — component tree, file layout, call tree, or control flow:

```diff
 submitForm
   createSession
     persistPrompt
+    expandSkillMention
     launchAgent
-  navigateToSession
+  navigateToSession
+    subscribeToEvents
```

- a code snippet for internals or sample usage. show the whole block when most of it is new, when omitted context would hide ownership or order, or when showing sample usage

you may use one of these, you may use several, it is unlikely you will use all of them. place each visual next to the short text it supports.

for visual changes (either directly or indirectly) show a table of before and after with uploaded images/videos.

for benchmarks, always show tables of before/after (baseline from target branch, candidate from the PR)

dont at intermidate PR details - e.g. if we reduced PR size from +6k lines to +1k lines, dont even mention it lol. if we refactored from one commit to another it doesnt matter. only the final aggregate squash merge commit is what matters for commentary

for truely impressive, difficult, or high risk/wide scoped changes you might write the body like a technical blog (again with context, storytelling, code samples/before/after etc diagrams, images, whatever.

feel free to use code refs
