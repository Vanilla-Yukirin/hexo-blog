# AGENTS.md

## Purpose
- This repository is a Hexo-based personal blog.
- Agent work here is mostly:
  - Content workflow support (draft/post/front-matter consistency)
  - Build/deploy script maintenance (PowerShell + Bash)
  - NexT theme customization via `source/_data/*`
  - GitHub Actions workflow updates

## Rule Sources
- Cursor rules:
  - `.cursor/rules/`: not found
  - `.cursorrules`: not found
- Copilot rules:
  - `.github/copilot-instructions.md`: not found
- If any of these files are added later, they override this document where applicable.

## Repository Layout (High Value Paths)
- `source/_drafts/`: draft posts
- `source/_posts/`: published posts
- `scaffolds/`: front-matter templates (`draft.md`, `post.md`)
- `_config.main.yml`: main Hexo config
- `_config.next.yml`: NexT theme config
- `source/_data/`: NexT custom injection templates/styles
- `build.ps1`, `service.ps1`, `publish.ps1`: Windows scripts
- `build.sh`, `service.sh`, `publish.sh`: Linux/macOS scripts
- `.github/workflows/deploy.yml`: CI/CD deployment workflow
- `README.md`: operational guidance and command examples

## Setup Commands
- Install deps (always locked):
  - `npm ci`
- Do not use `npm install` unless explicitly required and reviewed.

## Build / Run Commands
- NPM scripts:
  - `npm run clean` -> `hexo clean`
  - `npm run build` -> `hexo generate`
  - `npm run server` -> `hexo server`
- Preferred project scripts (recommended):
  - Windows:
    - `.\build.ps1`
    - `.\build.ps1 encrypt`
    - `.\build.ps1 draft encrypt`
    - `.\service.ps1`
    - `.\service.ps1 draft`
    - `.\service.ps1 encrypt`
    - `.\service.ps1 draft encrypt`
  - Linux/macOS:
    - `./build.sh`
    - `./build.sh encrypt`
    - `./build.sh draft encrypt`
    - `./service.sh`
    - `./service.sh draft`
    - `./service.sh encrypt`
    - `./service.sh draft encrypt`

## Publish Workflow Commands
- Create draft:
  - `hexo new draft "Chinese title allowed" --slug "english-slug"`
- Publish draft (recommended raw mode):
  - Windows: `.\publish.ps1`
  - Linux/macOS: `./publish.sh`
- Optional official Hexo publish mode:
  - Windows: `.\publish.ps1 hexo`
  - Linux/macOS: `./publish.sh hexo`

## Lint / Test Status
- There is no dedicated lint command configured.
- There is no dedicated unit/integration test framework configured.
- Validation is build-and-preview based.

## "Single Test" Equivalent (Important)
- Since no test framework exists, use targeted checks:
  - Single post validation:
    - Start server with matching config:
      - `.\service.ps1 draft encrypt` (Windows)
      - `./service.sh draft encrypt` (Linux/macOS)
    - Open the post URL directly and verify rendering.
  - Build-only verification:
    - `.\build.ps1 encrypt` or `./build.sh encrypt`
  - Route/feed spot-checks:
    - visit `/blog/atom.xml`
    - visit target post permalink in local server

## CI / Deployment Behavior
- Workflow: `.github/workflows/deploy.yml`
- Trigger:
  - `main` branch pushes
  - path-filtered; excludes `source/_drafts/**`
  - also supports manual `workflow_dispatch`
- Build command in CI:
  - `./build.sh encrypt`
- Deploy command:
  - rsync `public/` to `/var/www/blog/` via SSH

## Front-Matter Conventions
- Follow scaffold order in `scaffolds/post.md` and `scaffolds/draft.md`.
- Current keys:
  - `title`
  - `date`
  - `updated`
  - `permalink`
  - `tags`
  - `mathjax`
  - `categories`
  - `description`
  - `photo`
- Keep `description` as one clear sentence when possible.
- Prefer one primary category; use tags for additional facets.
- Use English slug (no spaces, kebab-case) for filenames/URLs.

## Content / Naming Conventions
- Filename/slug:
  - lowercase kebab-case preferred
  - avoid trailing hyphen
- Title:
  - Chinese titles are fine
- URL:
  - controlled by filename/slug and Hexo permalink settings
- Drafts should stay in `_drafts` until explicitly published.

## Code Style: PowerShell Scripts
- Use PascalCase for variable names (e.g., `$UseEncrypt`, `$ConfigArg`).
- Normalize flags to lowercase.
- Accept bare flags (`draft`, `encrypt`) and tolerate prefixed forms.
- Emit structured logs:
  - `[INFO]`, `[WARN]`, `[ERROR]`, `[REPRO]`, `[DONE]`
- Fail fast on missing required inputs (`deploy.env`, passwords).

## Code Style: Bash Scripts
- Keep `set -euo pipefail`.
- Use uppercase config/runtime vars (`USE_DRAFT`, `CONFIG_ARG`).
- Normalize input flags to lowercase.
- Quote variables consistently.
- Keep behavior aligned with PowerShell equivalents.

## Error Handling Guidelines
- Validate file existence before use.
- Validate required env vars before generation/deploy steps.
- Exit non-zero on hard failure.
- Keep user-facing messages explicit and actionable.
- For interactive publish:
  - support `q` quit path
  - confirm overwrite before destructive replacement

## Theme Customization Guidelines
- Do not modify `node_modules` theme files directly.
- Use NexT custom injection via:
  - `_config.next.yml -> custom_file_path`
  - `source/_data/*.njk`
  - `source/_data/styles.styl`
- Keep custom UI additions minimal and visually consistent with NexT.

## Runtime Config Artifacts
- `_config.runtime.yml` is generated at runtime by scripts.
- Do not commit runtime-generated config files.
- `.gitignore` should keep runtime files excluded.

## Security / Secrets
- Never commit `deploy.env`.
- Keep passwords/tokens in GitHub Secrets or local untracked env files.
- Treat encryption as display-layer only; source markdown remains public in repo.

## Git Hygiene for Agents
- Do not revert unrelated user changes.
- Avoid broad refactors when only workflow/content updates are needed.
- Keep commits scoped (scripts vs docs vs content).
- Mention behavior changes in commit message body.

## Preferred Verification Before Commit
- `git status`
- run relevant script (`build` or `service`) with expected flags
- check one representative post page
- check footer/build-stamp presence
- check feed endpoint if feed-related changes were made

## Quick "Do / Don't"
- Do:
  - use project scripts over raw commands when possible
  - preserve cross-platform parity between `.ps1` and `.sh`
  - keep docs updated when command behavior changes
- Don't:
  - introduce new tooling without need
  - commit generated runtime artifacts
  - rely on official `hexo publish` if front-matter order must be preserved
