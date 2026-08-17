// Measure the rendered body text. Run the contents of this file through
// javascript_tool against the page under audit; it returns a JSON summary.
//
// Source files cannot answer these questions — a type scale, a clamp() and a
// container query all resolve at render time. Measure what the reader sees, and
// measure it again at mobile width.
//
// Thresholds cited in references/rules.md.

(() => {
  const cite = (page) => `https://practicaltypography.com/${page}`;

  /** The element holding the most text is the body text, whatever it is called. */
  function findBodyText() {
    const candidates = [...document.querySelectorAll('p')];
    if (candidates.length === 0) return document.body;
    return candidates.reduce((widest, el) =>
      el.textContent.trim().length > widest.textContent.trim().length ? el : widest,
    );
  }

  /**
   * Characters per line, measured rather than guessed: take the average glyph
   * width of the element's own text in its own font, then divide the content
   * box by it.
   */
  function charactersPerLine(el, style) {
    const text = el.textContent.replace(/\s+/g, ' ').trim();
    if (!text) return null;

    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    ctx.font = `${style.fontStyle} ${style.fontWeight} ${style.fontSize} / ${style.lineHeight} ${style.fontFamily}`;

    const avgGlyph = ctx.measureText(text).width / text.length;
    if (!avgGlyph) return null;

    const box = el.getBoundingClientRect().width
      - parseFloat(style.paddingLeft)
      - parseFloat(style.paddingRight);

    return Math.round(box / avgGlyph);
  }

  const el = findBodyText();
  const style = getComputedStyle(el);
  const fontSize = parseFloat(style.fontSize);
  const lineHeight = style.lineHeight === 'normal'
    ? fontSize * 1.2
    : parseFloat(style.lineHeight);
  const measure = charactersPerLine(el, style);
  const spacing = Math.round((lineHeight / fontSize) * 100);

  const check = (ok, value, target, page) => ({
    value,
    target,
    pass: ok,
    cite: cite(page),
  });

  // Underlining that is not a link, and faux small caps.
  const underlined = [...document.querySelectorAll('*')].filter((node) => {
    if (node.closest('a')) return false;
    if (!node.textContent.trim()) return false;
    const s = getComputedStyle(node);
    return s.textDecorationLine.includes('underline')
      && [...node.children].every((c) => !getComputedStyle(c).textDecorationLine.includes('underline'));
  });

  // All caps set by CSS rather than typed, and how long each run runs.
  const capsRuns = [...document.querySelectorAll('*')]
    .filter((node) => {
      const s = getComputedStyle(node);
      return s.textTransform === 'uppercase' && node.textContent.trim().length > 0;
    })
    .map((node) => {
      const s = getComputedStyle(node);
      return {
        text: node.textContent.trim().slice(0, 60),
        characters: node.textContent.trim().length,
        letterSpacingPercent: s.letterSpacing === 'normal'
          ? 0
          : Math.round((parseFloat(s.letterSpacing) / parseFloat(s.fontSize)) * 100),
      };
    });

  return {
    viewport: { width: innerWidth, height: innerHeight },
    sample: {
      selector: el.tagName.toLowerCase() + (el.className ? `.${String(el.className).split(' ')[0]}` : ''),
      excerpt: el.textContent.trim().slice(0, 80),
    },
    bodyText: {
      pointSize: check(fontSize >= 15 && fontSize <= 25, `${fontSize}px`, '15–25px', 'point-size.html'),
      lineSpacing: check(spacing >= 120 && spacing <= 145, `${spacing}%`, '120–145%', 'line-spacing.html'),
      lineLength: check(measure >= 45 && measure <= 90, measure === null ? 'unknown' : `${measure} characters`, '45–90 characters', 'line-length.html'),
      font: {
        value: style.fontFamily,
        cite: cite('font-recommendations.html'),
        note: 'System stack is a finding; judge the rest by eye.',
      },
    },
    paragraphs: {
      // Indent and space between paragraphs are alternatives, never both.
      textIndent: style.textIndent,
      marginBottom: style.marginBottom,
      bothSet: parseFloat(style.textIndent) > 0 && parseFloat(style.marginBottom) > 0,
      cite: cite('first-line-indents.html'),
    },
    underlinedNonLinks: {
      count: underlined.length,
      samples: underlined.slice(0, 5).map((n) => n.textContent.trim().slice(0, 60)),
      cite: cite('underlining.html'),
    },
    allCaps: {
      runs: capsRuns.slice(0, 10),
      cite: cite('all-caps.html'),
      note: 'Keep under one line; letterspace 5–12%.',
    },
  };
})();
