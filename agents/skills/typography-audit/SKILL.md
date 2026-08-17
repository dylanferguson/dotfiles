---
name: typography-audit
description: |
  Audit a webpage or document against Butterick's Practical Typography. Measures body text size, line spacing, line length and font choice from the rendered page, runs deterministic checks for quote, dash, spacing and symbol errors in the source, then reports findings ranked by impact with a citation to practicaltypography.com for each one.
  Use only when explicitly asked to audit, review or check the typography of a specific page, site or document. Do not use for general design, layout or CSS work.
---

# Typography Audit

Audit a target against the rules in Butterick's *Practical Typography*, reporting
measured values rather than opinions.

## Cite, never reproduce

The book is free to read and reader-supported. This skill stores thresholds and
check logic only. It does not store Butterick's prose, and neither should any
report it produces.

Every finding carries the URL of the page it comes from, so the reader can go
read the argument. If you have not paid for the book, see
<https://practicaltypography.com/how-to-pay-for-this-book.html>.

## Grading order

Body text is most of typography, so audit it first and report it first. The four
decisions that matter most, in order:

1. Point size
2. Line spacing
3. Line length
4. Font choice

Only after those are settled do you report quotes, dashes, symbols and spacing.
A report that leads with em-dash corrections while the measure sits at 120
characters is a failed report.

Thresholds and citation URLs: `references/rules.md`.

## Workflow

### Web pages

1. Open the target. Use `preview_start` with `{name}` for a local dev server, or
   `{url}` for a deployed site.
2. Measure the rendered page: read `scripts/measure.js` and run its contents
   through `javascript_tool`. It returns computed point size, line spacing ratio,
   measured characters per line, font stack, and underline or all-caps
   violations. Source files cannot tell you these numbers — measure the render.
3. Repeat at mobile width with `resize_window`, then re-run. Line length and
   point size commonly pass on desktop and fail on mobile.
4. Screenshot both widths for the judgment pass.
5. Run the source checks over the content files:

   ```bash
   node scripts/mechanics.mjs src/**/*.astro data/*.json5
   ```

### Documents

Run `scripts/mechanics.mjs` over the source, then read the text for structure,
hierarchy and whitespace. Skip the rendered measurement steps unless the document
has a rendered form you can open.

## What the script cannot judge

`mechanics.mjs` covers what is mechanically decidable. You still have to assess:

- Font choice and pairing, beyond flagging system fonts
- Whether the heading hierarchy is doing real work
- Page margins and whitespace
- Tables, lists and captions
- Whether the page reads as though it was set with care

Do this from the screenshots, and say plainly when a call is a matter of taste.

## Reporting

Rank findings by impact using the grading order above. Each one gets:

- The measured value and the target range, not an adjective. "Line length 118
  characters, target 45–90" beats "lines feel long."
- The file and line, for source findings.
- The citation URL from `references/rules.md`.

Butterick states when to break his own rules, and the thresholds are ranges
rather than limits. Where a target deliberately sits outside a range, say so and
move on instead of filing it. Mark low-confidence findings as such.

Report only by default. If asked to fix, limit automatic changes to the text
substitutions in `mechanics.mjs` — quotes, dashes, ellipses, symbols. Never
change a font stack, type scale or spacing without confirmation.
