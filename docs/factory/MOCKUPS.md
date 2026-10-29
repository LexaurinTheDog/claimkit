# Spec mockups with OpenUI

Spec gate 1 (`factory-spec`) needs plain HTML mockups for every screen a change touches,
in `docs/factory/specs/FQ-<n>/mockups/`. The factory drafts them with
[OpenUI](https://github.com/wandb/openui), running locally on Ollama models.

OpenUI is a tool for this stage only. It is not an app dependency, and nothing it
produces is product code: the implementation builds the screen in Next.js from the
approved spec.

## Start it

```bash
./.factory/scripts/openui.sh up      # http://127.0.0.1:7878
./.factory/scripts/openui.sh down
```

The script runs a digest-pinned Docker image bound to loopback, with no provider API
keys and no wandb credentials. The only model backend is the local Ollama.

## Draft a mockup (planner)

```bash
./.factory/scripts/mockup.sh docs/factory/specs/FQ-12/mockups/02-baggage-details.html \
  "Step 2 of 5 of a lost-baggage claim wizard, in Czech: ..."
```

- Describe one screen: its purpose, the fields, the language, and "one question group
  per screen".
- Use invented names, dates and reference numbers. Never put real claimant data in a
  prompt or a mockup.
- `OPENUI_MODEL` picks the model, as `ollama/<name>` from `ollama list`. The default,
  `ollama/qwen3.5:latest` (7.6 GB), is less than half the size of the worker's model;
  a draft took about 4 minutes on this machine.
- The script refuses to overwrite an existing file. Name iterations `-v2`, `-v3`.

## Refine it (human)

Open http://127.0.0.1:7878, describe the screen or paste a draft's HTML into the editor,
and iterate in the browser. Export the HTML and save it under the spec's `mockups/`
folder.

## What a mockup is not

- **Not checked copy.** Local models make language mistakes, including in Czech; the
  wording on a mockup is a placeholder until a human approves gate 1.
- **Not legal content.** Field labels, deadlines and insurer names on a mockup are
  illustrative. Legal text still comes only from a human and stays `verified: false`
  until a lawyer signs it off.
- **Not offline.** A mockup loads Tailwind from its CDN when opened, so viewing one
  makes a request to `cdn.tailwindcss.com`. That is acceptable for sketches, which never
  contain claimant data, and is why mockups never ship in `src/`.
