# mediforce-clinical-workspace

Clinical workspace for Mediforce AI agents. Agents clone this repo inside a **golden image** container (R + Python + Claude Code CLI), generate scripts and outputs, commit their work, and push to run-specific branches for human review.

## How it works

1. The Mediforce platform spins up a golden image container for each agent step
2. Input data (SDTM datasets, protocol PDFs) is mounted read-only at `/data`
3. This repo is cloned into `/workspace` at a pinned commit SHA
4. The agent generates code/outputs in `/workspace`
5. Changes are committed and pushed to a `run/{instanceId}` branch
6. A human reviewer sees the diff on GitHub and approves or requests revisions

## Structure

Organized by domain — agents work within their step's directory:

```
adam/       # ADaM dataset derivation scripts (R)
tlg/        # Tables, Listings, Figures generation
metadata/   # Trial metadata extraction outputs
```

## Branching

- `main` — approved, reviewed code
- `run/{instanceId}` — agent working branches, one per pipeline run
