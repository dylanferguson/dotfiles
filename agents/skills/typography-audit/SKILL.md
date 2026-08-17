---
name: typography-audit
description: |
  Apply the principles from Butterick's Practical Typography to set or audit type — body text size, line spacing, measure, font choice, then punctuation and emphasis — citing the page behind each call.
  Use only when explicitly asked to audit, review or check the typography of a specific page, site or document, or to set type for one. Do not use for general design, layout or CSS work.
---

# Typography

## Cite, never reproduce

The book is free to read and reader-supported. This file holds the rules and the
page names, not Butterick's prose, and neither should any report it produces.
Cite the page behind each call so the reader can go read the argument.

Pages are `https://practicaltypography.com/<name>.html`. If you have not paid for
the book, see `how-to-pay-for-this-book.html`.

## The four decisions that matter

Body text is most of typography. These come first, in this order, and a report
that raises em dashes while the measure runs to 120 characters is a failed
report.

**Point size** — 15–25px on the web, 10–12pt in print. Set once, explicitly.
(`point-size`)

**Line spacing** — 120–145% of point size. Set it unitless, `line-height: 1.45`,
so the ratio is the value you read and it inherits down correctly.
(`line-spacing`)

**Line length** — 45–90 characters. Set it in `ch`, `max-width: 66ch`, so the
measure is stated rather than emerging from a pixel width and a font metric.
(`line-length`)

**Font** — a professional text face over a system stack. Question novelty faces,
monospace as body text, and free fonts. (`font-recommendations`, `goofy-fonts`,
`monospaced-fonts`, `free-fonts`, `system-fonts`)

State each rule in the units of the rule itself and the source answers the audit
directly — no measuring, no glyph arithmetic. Where a value hides inside a
`clamp()` or a type scale, resolve it at the breakpoints that matter. If you
cannot tell what it resolves to, that is itself the finding: a rule you cannot
read is a rule nobody is checking.

The common failure is a page that passes on desktop and fails narrow, because
the wide case was the only one ever looked at. Check both.

## Paragraphs and layout

- First-line indent **or** space between paragraphs, never both. Indent 1–4× the
  point size, or leave 4–10pt. (`first-line-indents`, `space-between-paragraphs`)
- Hyphenate justified text; leave ragged text unhyphenated. (`hyphenation`,
  `justified-text`)
- Centre sparingly. (`centered-text`)
- Letterspace caps and small caps 5–12%. Leave lowercase alone. (`letterspacing`)
- Kerning on. (`kerning`)

## Emphasis

- Bold and italic sparingly — emphasis that is everywhere is nowhere.
  (`bold-or-italic`)
- No underlining, except as a link affordance. (`underlining`)
- All caps under one line. (`all-caps`)
- Real small caps, never faux. (`small-caps`)

## Punctuation and symbols

- Curly quotation marks and apostrophes; apostrophes always point downward.
  Straight marks are for feet and inches and nothing else.
  (`straight-and-curly-quotes`, `apostrophes`, `foot-and-inch-marks`)
- One space between sentences, and never more than one between words.
  (`one-space-between-sentences`, `word-spaces`)
- Hyphen, en dash and em dash are three different characters doing three
  different jobs. (`hyphens-and-dashes`)
- One ellipsis character, not three periods. (`ellipses`)
- About one exclamation point per three pages. (`question-marks-and-exclamation-points`)
- Ampersands sparingly. (`ampersands`)
- ™ © ®, never (tm) (c) (r). (`trademark-and-copyright-symbols`)

For an exhaustive sweep, grep the content files — straight quotes and stray `--`
hide well in a long passage. Read the hits before filing them: code, URLs and
quoted matter legitimately contain all of these.

## Web habits Butterick names

Body text set too small, headings set too large, system fonts, overbuilt
navigation, large blocks of colour. (`websites`, `typewriter-habits`,
`body-text`, `headings`, `color`)

## Judgment

The rules above are readable from the source. These are not, and want a
screenshot at both a wide and a narrow width:

- Whether the heading hierarchy is doing real work or just changing sizes
- Page margins and whitespace
- Tables, lists and captions
- Whether the page reads as though it was set with care

Say plainly when a call is a matter of taste.

## Reporting

Rank by the order above. Give the value and the target — "measure is 118
characters, target 45–90" — with the file, the line and the citation. Never
"lines feel long."

These are ranges, and Butterick states when to break his own rules. Where a
target sits outside one deliberately, say so and move on instead of filing it.
Quoted passages are not the author's punctuation; don't charge them for it.

Report only by default. If asked to fix, limit automatic changes to text
substitutions — quotes, dashes, ellipses, symbols. Never change a font stack,
type scale or spacing without confirmation.
