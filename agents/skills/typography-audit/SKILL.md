---
name: typography-audit
description: |
  Audit a webpage or document against Butterick's Practical Typography, reporting measured values against his thresholds with a citation for each finding.
  Use only when explicitly asked to audit, review or check the typography of a specific page, site or document. Do not use for general design, layout or CSS work.
---

# Typography Audit

## Cite, never reproduce

The book is free to read and reader-supported. This file stores thresholds and
page names, not Butterick's prose, and neither should any report it produces.
Every finding carries the URL of the page it comes from, so the reader can go
read the argument for themselves.

Pages cited below are `https://practicaltypography.com/<name>.html`. If you have
not paid for the book, see `how-to-pay-for-this-book.html`.

## Grade in this order

Body text is most of typography. Audit and report it first, in this order:

| Rule | Target | Page |
| --- | --- | --- |
| Point size | 10–12 pt print, 15–25 px web | `point-size` |
| Line spacing | 120–145% of point size | `line-spacing` |
| Line length | 45–90 characters | `line-length` |
| Font choice | A professional font over a system font | `font-recommendations` |

A report that leads with em-dash corrections while the measure sits at 120
characters is a failed report.

## Measure the render, don't read the source

A type scale, a `clamp()` and a container query all resolve at render time.
Never infer these numbers from CSS — open the page and measure it. Characters
per line in particular cannot be eyeballed.

Run this through `javascript_tool` on the page under audit:

```js
(() => {
  const el = [...document.querySelectorAll('p')]
    .reduce((a, b) => (b.textContent.length > a.textContent.length ? b : a));
  const s = getComputedStyle(el);
  const size = parseFloat(s.fontSize);
  const text = el.textContent.replace(/\s+/g, ' ').trim();
  const ctx = document.createElement('canvas').getContext('2d');
  ctx.font = `${s.fontStyle} ${s.fontWeight} ${s.fontSize} ${s.fontFamily}`;
  const box = el.getBoundingClientRect().width
    - parseFloat(s.paddingLeft) - parseFloat(s.paddingRight);
  return {
    pointSize: s.fontSize,
    lineSpacing: Math.round((parseFloat(s.lineHeight) / size) * 100) + '%',
    lineLength: Math.round(box / (ctx.measureText(text).width / text.length)),
    font: s.fontFamily,
  };
})();
```

Then `resize_window` to mobile and run it again. Point size and line length
routinely pass on desktop and fail on mobile.

## Then the rest

**Fonts to question:** novelty (`goofy-fonts`), monospaced as body text
(`monospaced-fonts`), free (`free-fonts`), system stacks such as Arial, Georgia
and Verdana (`system-fonts`).

**Paragraphs and layout**

| Rule | Target | Page |
| --- | --- | --- |
| Indent **or** paragraph spacing, never both | Indent 1–4× point size, or 4–10 pt of space | `first-line-indents`, `space-between-paragraphs` |
| Hyphenation | On when justified, off when ragged | `hyphenation`, `justified-text` |
| Centred text | Sparingly | `centered-text` |
| Letterspacing | 5–12% on caps and small caps | `letterspacing` |
| Kerning | On | `kerning` |

**Emphasis**

| Rule | Target | Page |
| --- | --- | --- |
| Bold and italic | Sparingly | `bold-or-italic` |
| Underlining | Never, except as a link affordance | `underlining` |
| All caps | Under one line | `all-caps` |
| Small caps | Real, never faux | `small-caps` |

**Punctuation and symbols**

| Rule | Target | Page |
| --- | --- | --- |
| Quotation marks | Curly | `straight-and-curly-quotes` |
| Apostrophes | Curly, always downward | `apostrophes` |
| Foot and inch marks | Straight, and only here | `foot-and-inch-marks` |
| Sentence spacing | One space | `one-space-between-sentences` |
| Word spacing | Never more than one | `word-spaces` |
| Hyphens and dashes | Three distinct characters | `hyphens-and-dashes` |
| Ellipses | The single character | `ellipses` |
| Exclamation points | About one per three pages | `question-marks-and-exclamation-points` |
| Ampersands | Sparingly | `ampersands` |
| Trademark and copyright | ™ © ®, not (tm) (c) (r) | `trademark-and-copyright-symbols` |

For an exhaustive punctuation sweep, grep the content files rather than reading
for them — straight quotes and stray `--` hide well. Read the hits before
filing them: quotes, code and URLs legitimately contain all of these.

**Web habits Butterick names:** body text too small, headings too large, system
fonts, overbuilt navigation, large blocks of colour (`websites`,
`typewriter-habits`, `body-text`, `headings`, `color`).

## Reporting

Rank by the grading order. Each finding gets the measured value and the target
range — "line length 118 characters, target 45–90", never "lines feel long" —
plus the file and line for source findings, and the citation URL.

These are ranges, and Butterick states when to break his own rules. Where a
target deliberately sits outside one, say so and move on instead of filing it.
Quoted passages are not the author's punctuation; don't charge them for it.

Report only by default. If asked to fix, limit automatic changes to text
substitutions — quotes, dashes, ellipses, symbols. Never change a font stack,
type scale or spacing without confirmation.
