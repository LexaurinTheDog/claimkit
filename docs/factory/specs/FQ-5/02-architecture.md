# FQ-5 · Gate 2 · Architecture: ClaimKit alpha

Gate 1 was approved on 2026-11-01. The alpha lists evidence by file name only.

## Constraints that shape everything

- **Static export, no server.** `next.config.ts` keeps `output: "export"`. That rules out
  server code, middleware, API routes and dynamic routes built at request time.
- **No network from `src`.** Interpretation proposed for approval:
  - code in `src/` calls no network API: `fetch`, `XMLHttpRequest`, `WebSocket`,
    `EventSource`, `navigator.sendBeacon`
  - it loads nothing from another origin
  - the browser loading the app's own bundled JS chunks from the origin that served the app
    is allowed; the PDF font is one of those chunks (a module, see below), never a fetch
  - a test scans `src/` for those APIs and for absolute `http(s)://` URLs outside an
    allowlist of documentation links shown to the user
- **`next.config.ts` stays exactly as it is.** Every choice below was picked so it needs no
  config change.
- **Claim data stays on the device.** Claim data lives in IndexedDB, in memory, or in a
  file the user downloads. Nothing else.
- **Legal content is data.** Legal content lives in jurisdiction packs, never in components
  or core logic, and it is always `verified: false` until a lawyer signs it off.

## Modules

| Module | Role | Load-bearing |
|---|---|---|
| `src/core/claim.*` | Claim model and its schema (Zod): id, claim type, pack id, `rulesetVersion`, answers, evidence list, timestamps | no |
| `src/core/wizard.*` | Pure step engine: given a claim-type definition and answers, it returns the current step, its validation and overall completeness | no |
| `src/core/deadlines.*` | Pure: incident date + pack deadline rules -> dated or informational deadline items | **yes** |
| `src/core/letter.*` | Pure: fills a pack's letter template with claim answers -> structured paragraphs (no PDF) | no |
| `src/core/pdf/*` | Paragraphs and lists -> PDF bytes (pdf-lib): hand-written line wrapping and page breaks (pdf-lib has neither), embedded static Noto Sans Regular and Bold | no, but treated as real work with its own tests |
| `src/core/i18n.*` | Hand-rolled message lookup (~50 lines): `t(locale, key, params)` over `src/messages/*.json`, with a test that cs and en have the same keys | no |
| `src/core/storage.*` | Drafts in IndexedDB: save, load, list, delete, delete all, export and import JSON validated by the claim schema, schema version | **yes** |
| `src/claim-types/*` | Data: `travel` (subtypes delay, baggage, medical), `motor`, `home`. Steps, fields with label keys, evidence checklist, letter sections | no |
| `src/jurisdictions/schema.*`, `cz/*`, `xx/*`, registry | Pack schema and the packs: locale, currency, legal references with `verified`, deadline rules, insurers (name, claims contact), letter templates per claim type | **yes** |
| `src/messages/{cs,en}.json` | UI strings and field labels | no |
| `src/app/[locale]/*` | Pages: start, claim (wizard), review, drafts, privacy | no |
| `e2e/*` | Playwright smoke test against the built `out/` folder | no |

## Data shapes (summary; exact types come at gate 3)

- **Claim**: `{ id, schemaVersion, rulesetVersion, packId, claimType, subtype?, answers: Record<fieldKey, value>, evidence: { name, note? }[], createdAt, updatedAt }`.
- **ClaimTypeDef**: `{ id, subtypes?, steps: { id, titleKey, fields: { key, kind, required, labelKey, hintKey? }[] }[], evidence: { id, labelKey }[], letterSections: sectionId[] }`.
- **JurisdictionPack**: `{ id, locales, currency, legalRefs: { id, citation, summary, verified, sourceUrl? }[], deadlineRules: { id, claimTypes, kind: "relative-days" | "informational", days?, from?, textKey, legalRefIds }[], insurers: { id, name, claimsContact }[], letterTemplates: per claim type, per section, text with {field} placeholders }`.
- **Export file**: `{ format: "claimkit-drafts", version, exportedAt, claims: Claim[] }`. On import it is validated with the same schema, and any invalid claim is rejected whole, with a message.

## Routing under static export

The URL does not carry the claim id; a draft id is unknown at build time. Locale routes are
generated at build time with `generateStaticParams` (`/cs/…`, `/en/…`). The wizard is one
client page that takes the id and step from the query string: `/cs/claim?id=…&step=2`.
There is no trailing slash, so no `trailingSlash` setting is needed. Pages that read the
query string wrap `useSearchParams` in a Suspense boundary, which a static export requires.
`/` redirects to `/cs` with a client redirect and a `<meta refresh>` fallback.

## Main flow, in order

1. Start page: the user picks a claim type (and a travel subtype). A new Claim gets an id
   from `crypto.randomUUID()`, the `cz` pack and the pack's `rulesetVersion`, and is saved to
   IndexedDB.
2. Wizard: the step renderer draws the fields of the current step from the ClaimTypeDef and
   validates them with the step schema. Every change autosaves, debounced. A reload restores
   the draft.
3. Evidence step: the user ticks checklist items and adds file names. Nothing is uploaded or
   read.
4. Review: shows the answers with edit links. Deadlines come from `deadlines(incidentDate,
   pack.deadlineRules)`. Informational and unverified items get a badge. The three documents
   are listed.
5. Confirmation: "I checked this, and I send it myself" must be ticked.
6. Generate: `letter(claim, pack)` produces paragraphs; the PDF builder produces three PDFs
   (letter, evidence index, deadline summary), offered as downloads from Blob URLs. Nothing
   is sent.
7. Drafts page: list, resume, delete one, export JSON, import JSON, delete all (with a
   confirmation step on the page, not a browser dialog).

## Dependencies: each needs your decision

| Package | Why | Required? |
|---|---|---|
| `zod` | Schemas for claims, packs, import files. A pack test that validates every pack is part of ALPHA_DONE's safety. | Yes |
| `pdf-lib` + `@pdf-lib/fontkit` | Client-side PDFs. The built-in PDF fonts cannot encode ř, ě, ů, so a custom font must be embedded, and that needs fontkit. | Yes. pdf-lib has had few releases since 2021. If we hit a font bug, switch to the maintained `@cantoo/pdf-lib` fork, which has the same API. |
| Noto Sans Regular + Bold (static TTFs, not the variable font; OFL-1.1) | Czech diacritics in PDFs. Bundled as base64 TS modules behind a dynamic `import()`, so they load only when PDFs are generated, with no fetch and no config change. The licence ships with the app. Embedded without subsetting (`subset: false`), because fontkit's subsetting has known glyph bugs; the cost is ~2 × 500 KB per PDF. | Yes |
| `idb-keyval` | A thin IndexedDB wrapper, ~600 bytes. Dexie is more than drafts need. | Yes, or raw IndexedDB at ~80 more lines. **Recommend idb-keyval.** |
| `@playwright/test` (dev) | The ALPHA_DONE smoke test. Browsers are installed once by you (`pnpm exec playwright install chromium`); the worker is offline. | Yes |
| `fake-indexeddb` (dev) | Storage tests in Vitest without a browser. | Yes |
| `jsdom` + `@testing-library/react` (dev) | Component tests for the step renderer and review gate. | Recommended, not required |

Deliberately left out:
- `next-intl`: its server features need a plugin wrapping `next.config.ts`, and every real
  page here is a client component anyway. A hand-rolled lookup replaces it.
- `react-hook-form`: the step renderer is schema-driven and small.
- shadcn/ui, rjsf and SurveyJS: too much for one question group per screen.
- Dexie, exifr: not needed now that evidence is listed by name only.
- A date library: native `Date` in UTC, date-only values.

Also required: replace `next/font/google` in `src/app/layout.tsx` with a local font or the
system font stack. It downloads at build time, which the offline worker cannot do.

## Load-bearing paths involved

- `src/jurisdictions/**`: the schema, the `cz` pack, the `xx` pack. Its legal text comes
  only from you, verbatim. The worker never writes legal wording itself.
- `src/core/deadlines*`, `src/core/storage*`.
- `package.json`, `pnpm-lock.yaml`: the new dependencies above. You run `pnpm add` because
  the worker is offline.
- Not touched: `next.config.ts`, `.github/workflows/**`, `.factory/**`, `.claude/**`.

Every slice touching these runs `deep` gates and needs your read.

## What could break elsewhere

1. **The deep gate is red today.** `audit` fails on postcss advisories pulled in through
   `next@15.5.28`. Every load-bearing slice needs `deep`, so that is most of M1, M3 and M5.
   This needs a decision before slice work starts:
   - (a) upgrade Next to a release with a fixed postcss
   - (b) a pnpm override for postcss
   - (c) record an accepted-risk exception
   **Recommend (a) or (b) as the first slice.**
2. **The smoke test is not a gate.** `gates.sh` does not run Playwright, and
   `.factory/gates.conf` is human-owned. ALPHA_DONE needs both the smoke test and green
   gates. Either you add an `e2e` gate to `gates.conf`, or the smoke test runs as a separate
   CI job. **Recommend a CI job** (`.github/workflows/**` is load-bearing, so you approve
   that slice).
3. **Private browsing.** IndexedDB can be unavailable or wiped. Storage then falls back to
   memory and shows a visible warning: "this draft will not survive closing the tab". It
   never fails silently.
4. **Schema drift.** A draft saved by an older build must still open. `schemaVersion` plus
   a migration function per version, tested against stored fixtures.
5. **Deadline rules change.** A pack keeps every rule set it has shipped, keyed by
   `rulesetVersion`. A claim computes its deadlines from the version it was started with. A
   test proves that an old draft still uses its own version's rules. The review screen
   names the version.
6. **Font size.** The two fonts add ~1 MB to the bundle as a separate chunk. They load only
   when PDFs are generated, not on first paint. A test extracts the text from a generated
   PDF and checks ř, ě, ů and Ů; looking at the PDF is not enough.
7. **Two tabs, one draft.** Autosave compares `updatedAt` before writing. If another tab
   wrote in between, the page shows "this draft changed in another tab, reload" instead of
   overwriting it.
8. **The `xx` pack must stay generic.** If core code ever checks `packId === "cz"`, the
   `xx` test pack catches it.

## Not in this architecture

- No EU261 compensation calculator. Flight delay in the alpha means the travel insurance
  delay benefit, not airline compensation.
- No holiday calendar. No alpha deadline rule counts business days. One is added if a rule
  needs it.
- No service worker or PWA.

## Critic pass (factory-critic, 2026-11-01)

The critic's position was **concerns**, with no opposition. All five concerns are folded
into this version:

1. The font is a bundled module, not a fetch, so the no-network rule holds.
2. next-intl is dropped for a hand-rolled lookup, because its plugin would wrap
   `next.config.ts`.
3. The URLs have no trailing slash, so `next.config.ts` is not changed for that either.
4. Packs keep old rule sets per `rulesetVersion`, with a test.
5. PDF wrapping and pagination are planned as real work: static Regular and Bold TTFs,
   `subset: false`, and a diacritics check done by extracting text from the PDF.

The critic also flagged the Suspense requirement around `useSearchParams` and the risk of
two tabs overwriting each other's autosave. Both are now covered above.
