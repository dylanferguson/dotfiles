---
name: tasteful-ui
description: Build web UIs with exceptional interaction design taste — fast responses, minimal chrome, smart defaults, and respectful UX patterns. Use this skill alongside frontend-design whenever building any interactive web application, dashboard, SaaS tool, or product UI. Trigger when the user mentions taste, polish, production-quality, professional UX, SaaS design, interaction design, or asks for something that feels "real" or "not like a demo." Also trigger when building any app with navigation, forms, state, or user flows — even if the user doesn't explicitly ask for taste.
---

# Tasteful UI

This skill encodes the craft principles that separate a polished product from a prototype. Use it alongside the `frontend-design` skill — that skill handles visual aesthetics and creative direction; this one handles interaction design, UX architecture, and the invisible details that make an interface feel *right*.

Read the frontend-design skill too when building UIs. These skills are complementary, not competing.

## Core Philosophy

Taste in UI is mostly about what you *remove*. Every tooltip, modal, loading spinner, and navigation layer is a small admission that the design didn't communicate on its own. The goal is an interface that feels inevitable — where users never wonder what to do next.

## The Principles

Apply every principle below unless it conflicts with explicit user requirements. These aren't suggestions — they're the baseline for quality.

### 1. Speed is a Feature

Every interaction must feel instant. This is non-negotiable.

- Use `transition-duration: 100ms` or less for UI feedback (hover, focus, active states)
- Use optimistic updates — reflect user actions immediately, reconcile with server after
- Debounce inputs at 150ms max; never block the UI thread
- Implement skeleton loading states (pulsing placeholder shapes that match content layout) instead of spinners or blank screens
- Lazy-load below-the-fold content but never let the user see it happening

```css
/* Fast, crisp interaction feedback */
.interactive {
  transition: all 80ms ease-out;
}

/* Skeleton loading pattern */
.skeleton {
  background: linear-gradient(90deg, var(--muted) 25%, var(--muted-bright) 50%, var(--muted) 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 4px;
}
@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
```

### 2. No Product Tours

The UI should be self-evident. If you need to explain it, redesign it.

- No onboarding modals, coach marks, or tooltip walkthroughs
- No "click here to get started" prompts
- Use smart defaults so the interface works immediately on first visit
- Progressive disclosure: show the simple path first, reveal advanced options contextually
- Empty states should be actionable, not instructional — show *what to do*, not *how the app works*

### 3. Clean URLs

URLs are UI. They should be readable, memorable, and shareable.

- Use short, lowercase, hyphenated slugs: `/settings`, `/projects/acme`, `/invoice/2024-001`
- Never expose UUIDs, database IDs, or query params in user-facing URLs
- If using React Router or similar, define clean route patterns upfront
- URLs should be bookmarkable and produce the same state when revisited

### 4. Persistent, Resumable State

Users should never lose work or context. The app remembers where they left off.

- Save form state, scroll position, and UI preferences to localStorage or the storage API
- Restore state on return — tabs, filters, sidebar collapse, draft content
- Use `beforeunload` warnings only when there's genuinely unsaved work
- Implement undo (Cmd+Z) for destructive actions where possible instead of confirmation dialogs

```javascript
// Save and restore UI state pattern
const saveState = (key, value) => {
  try { localStorage.setItem(`app:${key}`, JSON.stringify(value)); } catch {}
};
const loadState = (key, fallback) => {
  try { return JSON.parse(localStorage.getItem(`app:${key}`)) ?? fallback; } catch { return fallback; }
};
```

### 5. Disciplined Color

Not more than 3 colors. Constraint breeds coherence.

- One primary action color, one neutral base, one semantic/accent color
- Use opacity and lightness variations of these 3 — not new hues
- Reserve the primary color exclusively for the single most important action on screen
- Gray is not a color — use as many grays as needed for hierarchy

```css
:root {
  --primary: #2563eb;       /* Actions, links, primary buttons */
  --neutral: #111827;       /* Text, borders, structure */
  --accent: #f59e0b;        /* Alerts, badges, highlights */

  /* Derived through opacity, not new colors */
  --primary-soft: rgb(37 99 235 / 0.1);
  --neutral-muted: rgb(17 24 39 / 0.5);
}
```

### 6. No Visible Scrollbars

Scrollbars are visual noise. Hide them but keep scrolling functional.

```css
/* Apply to scrollable containers */
.scrollable {
  overflow-y: auto;
  scrollbar-width: none;           /* Firefox */
  -ms-overflow-style: none;        /* IE/Edge */
}
.scrollable::-webkit-scrollbar {
  display: none;                   /* Chrome/Safari */
}
```

Use subtle scroll indicators (fade gradients at edges, or a thin progress bar) if the user needs to know there's more content.

### 7. Three-Step Navigation Max

Every destination in the app should be reachable in 3 clicks or fewer from anywhere.

- Flat navigation hierarchy — avoid deep nesting
- Use a command palette (Cmd+K) as the universal escape hatch
- Breadcrumbs only if depth exceeds 2 levels
- Tab bars and sidebars should show all top-level sections without "More" menus

### 8. Command Palette (Cmd+K)

Every app with more than one view should have a command palette. It's the power user's front door.

- Trigger on `Cmd+K` (Mac) / `Ctrl+K` (Windows)
- Search across: navigation, actions, recent items, settings
- Fuzzy matching with highlighted matched characters
- Show keyboard shortcuts inline in results
- Recently used commands float to the top
- Dismiss on `Escape` or clicking outside

```javascript
// Keyboard listener pattern
useEffect(() => {
  const handler = (e) => {
    if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
      e.preventDefault();
      setCommandPaletteOpen(true);
    }
  };
  window.addEventListener('keydown', handler);
  return () => window.removeEventListener('keydown', handler);
}, []);
```

### 9. Larger Hit Targets

Small targets are hostile design. Be generous.

- Minimum touch target: 44×44px (per WCAG and Apple HIG)
- Clickable area should extend beyond the visible element with padding
- Form inputs: minimum height 40px, prefer 44px
- Icon buttons: wrap in a padded container, not just the icon itself
- Space interactive elements at least 8px apart

```css
button, a, input, select, textarea {
  min-height: 44px;
  padding: 10px 16px;
}
.icon-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 44px;
  min-height: 44px;
  padding: 10px;
}
```

### 10. Honest One-Click Cancel

If users can start a subscription or action in one click, they can cancel in one click. No dark patterns.

- Cancel/delete/unsubscribe actions are always visible, never buried
- No guilt-trip copy ("Are you sure you want to miss out?")
- Confirmation dialogs are plain and factual: state what will happen
- Destructive actions use red, but are not hidden or minimized
- Provide an undo window after deletion instead of a pre-deletion modal when possible

### 11. Clipboard Support

Copy and paste should work everywhere users expect it.

- Add "Copy" buttons next to codes, URLs, keys, IDs, and snippets
- Use the Clipboard API: `navigator.clipboard.writeText()`
- Show brief, non-modal confirmation ("Copied!") that auto-dismisses in 1.5s
- Support paste into inputs where users might paste from external sources

### 12. Minimal Tooltips

If you need a tooltip, the design might be unclear. Use them sparingly.

- Tooltips only for icon-only buttons that lack visible labels
- Max tooltip content: 5-7 words
- Show on hover after 300ms delay (not instant — that's jittery)
- Never put essential information in tooltips — it's invisible on mobile

### 13. Active Voice, Tight Copy

Every string in the UI is a micro-decision. Make it count.

- Active voice always: "Save changes" not "Changes will be saved"
- Max 7 words per UI label, button, or inline message
- No jargon, no "please", no "successfully" — just state what happened
- Error messages: say what went wrong and what to do. "Card declined. Try another." not "An error occurred while processing your payment method."
- Button labels describe the outcome: "Send invite" not "Submit" or "OK"

### 14. Optical Alignment

Geometric center ≠ visual center. Trust your eyes over the pixel grid.

- Vertically center text optically (shift up ~1-2px from mathematical center in large containers)
- Play icons inside circles need to shift right ~2px to look centered
- Left-align text to the visual edge, not the bounding box
- Icons next to text: align to the x-height, not the line-height
- Test alignment by squinting — if it looks off, it is off

### 15. Left-to-Right Reading Flow

Optimize layout for natural L-to-R, top-to-bottom scanning.

- Primary content and actions on the left; metadata and secondary actions on the right
- In tables: most important column first (leftmost)
- Navigation on the left side (sidebar) or top; never only on the right
- Form labels above inputs (not to the left) for faster scanning
- Reading order in code must match visual order — no CSS tricks that break tab order

### 16. Reassurance About Loss

Users fear losing their work. Proactively tell them they won't.

- Show "Saved" / "Draft saved" indicators near forms and editors — always visible, not just on save
- Auto-save with visible confirmation (subtle timestamp or checkmark)
- "Unsaved changes" warnings before navigation, only when actually needed
- Recovery: if a session expires, preserve draft content and restore it
- Show "You can undo this" on destructive actions instead of blocking with modals

```jsx
// Auto-save indicator pattern
const SaveIndicator = ({ lastSaved }) => (
  <span className="save-indicator">
    {lastSaved ? `Saved ${timeAgo(lastSaved)}` : 'Saving...'}
  </span>
);
```

## Implementation Checklist

When building any interactive UI, verify against this list before considering the work complete:

1. All hover/click feedback renders in ≤100ms
2. No onboarding modals or product tours exist
3. URLs are clean, short slugs with no UUIDs
4. User state persists across sessions (filters, position, drafts)
5. Color palette uses ≤3 hues (plus grays)
6. Scrollbars are hidden on all containers
7. Every destination is ≤3 clicks from any screen
8. Cmd+K command palette is functional (if multi-view app)
9. All buttons/inputs have ≥44px hit targets
10. Cancel/delete actions are one click, visible, and honest
11. Copy buttons exist on all copyable content
12. Skeleton loaders replace all loading states
13. No tooltip contains more than 7 words
14. All UI copy uses active voice, ≤7 words
15. Alignment is optically verified, not just geometrically
16. Layout follows L-to-R reading priority
17. Save state is visible and auto-save is active
