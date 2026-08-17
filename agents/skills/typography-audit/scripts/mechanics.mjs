#!/usr/bin/env node
// Deterministic typography checks over source prose.
//
// Only the mechanically decidable rules live here. Everything requiring a
// rendered page (point size, line spacing, line length) is measured by
// measure.js instead, and everything requiring judgment stays with the reader.
//
//   node mechanics.mjs [--json] [--quiet] <file...>
//
// Non-prose regions are masked out before the rules run, so code, markup,
// attributes and URLs cannot produce findings. Masking preserves byte offsets,
// which keeps line and column numbers exact.

import { readFileSync } from 'node:fs';
import { basename, extname } from 'node:path';

const CITE = 'https://practicaltypography.com';

// ---------------------------------------------------------------- masking

// Masked regions become NUL rather than space. Space would splice separate
// regions together — two string literals on one line would read as one run of
// prose with a gap in the middle, and the spacing rules would fire on the gap.
const NUL = '\0';

/** Replace a matched region with NUL, preserving newlines and offsets. */
function mask(text) {
  return text.replace(/[^\n]/g, NUL);
}

function maskAll(source, patterns) {
  let out = source;
  for (const pattern of patterns) {
    out = out.replace(pattern, mask);
  }
  return out;
}

const TAG = /<[^>]*>/g;
const FENCE = /```[\s\S]*?```|~~~[\s\S]*?~~~/g;
const INLINE_CODE = /`[^`\n]*`/g;
const FRONTMATTER = /^---\n[\s\S]*?\n---/;
const MD_LINK_TARGET = /\]\([^)]*\)/g;
const AUTOLINK = /<[^\s>]+>/g;
const BARE_URL = /\bhttps?:\/\/\S+/g;
const COMMENT = /\/\/[^\n]*|\/\*[\s\S]*?\*\//g;
const HTML_COMMENT = /<!--[\s\S]*?-->/g;
const ELEMENT = (name) => new RegExp(`<${name}[\\s>][\\s\\S]*?</${name}>`, 'gi');

/**
 * Mask JSX and Astro expression containers, braces balanced so nested objects
 * and ternaries go with them. `{" "}` and `{/* … *\/}` are code, not prose.
 * Run this after tags are masked, so attribute values cannot open a group.
 * An unbalanced brace is left alone rather than swallowing the rest of the file.
 */
function maskBraces(text) {
  const out = text.split('');
  for (let i = 0; i < out.length; i++) {
    if (out[i] !== '{') continue;

    let depth = 0;
    let end = -1;
    for (let j = i; j < out.length; j++) {
      if (out[j] === '{') depth++;
      else if (out[j] === '}' && --depth === 0) {
        end = j;
        break;
      }
    }
    if (end === -1) continue;

    for (let k = i; k <= end; k++) {
      if (out[k] !== '\n') out[k] = NUL;
    }
    i = end;
  }
  return out.join('');
}

/**
 * Reduce a source file to prose, masking everything else.
 * Returns a string the same length as the input.
 */
function extractProse(source, ext) {
  switch (ext) {
    case '.md':
    case '.mdx':
      return maskAll(source, [
        FRONTMATTER,
        FENCE,
        INLINE_CODE,
        MD_LINK_TARGET,
        AUTOLINK,
        BARE_URL,
        TAG,
      ]);

    case '.html':
    case '.astro':
    case '.jsx':
    case '.tsx':
    case '.svelte':
    case '.vue':
      return maskBraces(
        maskAll(source, [
          FRONTMATTER, // Astro component script
          HTML_COMMENT,
          ELEMENT('script'),
          ELEMENT('style'),
          ELEMENT('pre'),
          ELEMENT('code'),
          BARE_URL,
          TAG, // leaves text nodes, masks every attribute
        ]),
      );

    case '.json':
    case '.json5': {
      // Inverse of the others: mask everything, then restore the interiors of
      // string literals. Delimiters stay masked so the quote characters that
      // structure the file are never counted as straight quotes.
      //
      // Comments go first. A comment containing quotes would otherwise parse as
      // a string literal and reintroduce the code we are trying to exclude.
      const decommented = maskAll(source, [COMMENT]);
      const literal = /"(?:[^"\\\n]|\\.)*"|'(?:[^'\\\n]|\\.)*'/g;
      const masked = mask(source).split('');
      for (const match of decommented.matchAll(literal)) {
        const start = match.index + 1;
        const end = match.index + match[0].length - 1;
        for (let i = start; i < end; i++) masked[i] = source[i];
      }
      return maskAll(masked.join(''), [BARE_URL]);
    }

    default:
      return maskAll(source, [BARE_URL]);
  }
}

// ------------------------------------------------------------------ rules

// Each rule scans the masked prose and yields findings. `match` rules report
// every hit; `count` rules report once per file against a budget.
const RULES = [
  {
    id: 'straight-quotes',
    page: 'straight-and-curly-quotes.html',
    pattern: /"/g,
    message: 'Straight quotation mark. Use “ ” instead.',
  },
  {
    id: 'straight-apostrophe',
    page: 'apostrophes.html',
    pattern: /'/g,
    message: 'Straight apostrophe. Use ’ instead.',
  },
  {
    id: 'sentence-spacing',
    page: 'one-space-between-sentences.html',
    pattern: /[.!?][)”’"']?\x20{2,}(?=[A-Z“‘])/g,
    message: 'More than one space between sentences. Use one.',
  },
  {
    id: 'word-spacing',
    page: 'word-spaces.html',
    pattern: /(?<=[^\s\0])\x20{2,}(?=[^\s\0])/g,
    message: 'More than one space between words. Use one.',
    // Sentence spacing is reported by its own rule; skip the overlap.
    skip: (prose, index) => /[.!?][)”’"']?$/.test(prose.slice(0, index)),
  },
  {
    id: 'dash-as-hyphen',
    page: 'hyphens-and-dashes.html',
    pattern: /\x20-{1,2}\x20|(?<=\w)--(?=\w)/g,
    message: 'Hyphen used as a dash. Use an en dash (–) or em dash (—).',
  },
  {
    id: 'ellipsis',
    page: 'ellipses.html',
    pattern: /\.{3,}/g,
    message: 'Periods used as an ellipsis. Use … instead.',
  },
  {
    id: 'faux-symbol',
    page: 'trademark-and-copyright-symbols.html',
    pattern: /\((?:c|r|tm)\)/gi,
    message: 'Symbol typed in parentheses. Use © ® ™ instead.',
  },
  {
    id: 'all-caps-run',
    page: 'all-caps.html',
    // A run this long will exceed a line at any reasonable measure.
    pattern: /\b[A-Z][A-Z\x20,'’-]{59,}[A-Z]\b/g,
    message: 'All caps running longer than a line. Keep it under one line.',
  },
  {
    id: 'exclamation-points',
    page: 'question-marks-and-exclamation-points.html',
    // Budget: roughly one per three pages, at ~500 words a page.
    count: /!/g,
    budget: (words) => Math.max(1, Math.floor(words / 1500)),
    message: (found, allowed) =>
      `${found} exclamation points across ~${allowed * 1500} words. ` +
      `Budget is about ${allowed} (one per three pages). ` +
      'Counts quoted text too — discount quotations before filing this.',
  },
];

// ----------------------------------------------------------------- engine

function locate(source, index) {
  const upTo = source.slice(0, index);
  const line = upTo.split('\n').length;
  const column = index - (upTo.lastIndexOf('\n') + 1) + 1;
  return { line, column };
}

/** Context around the match, not the head of the line — findings deep in a long
 *  line are the ones that most need showing. */
function snippet(source, index, length) {
  const lineStart = source.lastIndexOf('\n', index) + 1;
  const lineEnd = source.indexOf('\n', index + length);
  const line = source.slice(lineStart, lineEnd === -1 ? source.length : lineEnd);
  const at = index - lineStart;

  if (line.length <= 90) return line.trim();

  const from = Math.max(0, at - 35);
  const to = Math.min(line.length, at + length + 35);
  return (from > 0 ? '…' : '')
    + line.slice(from, to).trim()
    + (to < line.length ? '…' : '');
}

function auditFile(path) {
  const source = readFileSync(path, 'utf8');
  const prose = extractProse(source, extname(path).toLowerCase());
  const words = prose.replace(/\0/g, ' ').split(/\s+/).filter(Boolean).length;
  const findings = [];

  for (const rule of RULES) {
    if (rule.count) {
      const found = [...prose.matchAll(rule.count)].length;
      const allowed = rule.budget(words);
      if (found > allowed) {
        findings.push({
          file: path,
          line: 0,
          column: 0,
          rule: rule.id,
          message: rule.message(found, allowed),
          cite: `${CITE}/${rule.page}`,
          text: '',
        });
      }
      continue;
    }

    for (const match of prose.matchAll(rule.pattern)) {
      if (rule.skip?.(prose, match.index)) continue;
      findings.push({
        file: path,
        ...locate(source, match.index),
        rule: rule.id,
        message: rule.message,
        cite: `${CITE}/${rule.page}`,
        text: snippet(source, match.index, match[0].length),
      });
    }
  }

  return findings.sort((a, b) => a.line - b.line || a.column - b.column);
}

// ------------------------------------------------------------------- main

const args = process.argv.slice(2);
const json = args.includes('--json');
const quiet = args.includes('--quiet');
const paths = args.filter((a) => !a.startsWith('--'));

if (paths.length === 0) {
  console.error('usage: mechanics.mjs [--json] [--quiet] <file...>');
  process.exit(2);
}

const findings = [];
for (const path of paths) {
  try {
    findings.push(...auditFile(path));
  } catch (error) {
    console.error(`skipped ${path}: ${error.message}`);
  }
}

if (json) {
  console.log(JSON.stringify(findings, null, 2));
} else if (findings.length === 0) {
  console.log(`No mechanical findings across ${paths.length} file(s).`);
} else {
  const byRule = new Map();
  for (const f of findings) {
    if (!byRule.has(f.rule)) byRule.set(f.rule, []);
    byRule.get(f.rule).push(f);
  }

  for (const [rule, group] of byRule) {
    console.log(`\n${rule} — ${group.length} finding(s)`);
    console.log(`  ${group[0].message}`);
    console.log(`  ${group[0].cite}`);
    if (quiet) continue;
    for (const f of group.slice(0, 20)) {
      const where = f.line ? `${f.file}:${f.line}:${f.column}` : f.file;
      console.log(`    ${where}${f.text ? `  ${f.text}` : ''}`);
    }
    if (group.length > 20) console.log(`    … ${group.length - 20} more`);
  }
  console.log(
    `\n${findings.length} finding(s) across ${paths.length} file(s). ` +
      'Mechanical rules only — measure the rendered page for body text.',
  );
}

process.exit(0);
