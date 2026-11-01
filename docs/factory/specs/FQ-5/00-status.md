item: FQ-5 (ClaimKit alpha, umbrella spec for milestones M1-M6) - https://github.com/LexaurinTheDog/claimkit/issues/5
gate_1_product: approved 2026-11-01
gate_2_architecture: approved 2026-11-01
gate_3_design: pending
gate_4_slices: not-started
slices_completed: 0 / ?
decisions:
  - 2026-11-01: evidence in the alpha is listed by file name only; no photo or receipt attachments (human owner, gate 1)
  - 2026-11-01: dependencies approved: zod, pdf-lib, @pdf-lib/fontkit, idb-keyval, Noto Sans Regular and Bold (OFL); dev: @playwright/test, fake-indexeddb, jsdom, @testing-library/react (human owner, gate 2)
  - 2026-11-01: audit: upgrade Next to a release with a fixed postcss, else a pnpm override for postcss; first slice (human owner, gate 2)
  - 2026-11-01: the Playwright smoke test runs as a separate CI job, not a gates.sh gate (human owner, gate 2)
open_questions: []
