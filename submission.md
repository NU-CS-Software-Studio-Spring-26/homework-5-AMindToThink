# Homework 5 — Leveling up AI-Assisted Software Development

**Repo / branch:** work is on the `hw5` branch of this GitHub Classroom repository.

> **Editor note (adaptation):** The assignment is written for Cursor, which it
> explicitly permits adapting to another editor. I completed it using **Claude
> Code** as the AI assistant. Cursor-specific UI steps are mapped to their
> Claude Code equivalents (see Part 3). All recorded prompts and results below
> are real interactions that happened in Claude Code, not reconstructions.

---

## Part 1 — Setup

### @-context check: top-level folders of this project

Prompt used: _"List the top-level folders of this project and describe what each
one contains."_ The answer cites real paths from this repo (e.g.
`app/models/todo.rb`, `test/controllers/todos_controller_test.rb`), confirming
the assistant is reading the actual codebase rather than generic Rails docs.

| Folder     | What it contains                                                                                                                                                                                                                                                                                                                   |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `app/`     | The Rails MVC application code: `controllers/` (`todos_controller.rb`, `application_controller.rb`), `models/` (`todo.rb`), `views/` (the `todos/` ERB templates + JBuilder JSON views, `layouts/`, `pwa/`), plus `assets/`, `helpers/`, `javascript/` (Stimulus controllers via importmap), `jobs/` (Active Job), and `mailers/`. |
| `bin/`     | Executable binstubs and project scripts: `dev` (boots the app), `setup`, `rails`, `rake`, `rubocop` (lint), `brakeman` (security scan), `importmap`, `jobs`, `kamal`/`thrust` (deploy), `docker-entrypoint`.                                                                                                                       |
| `config/`  | App configuration and boot: `routes.rb`, `application.rb`, `database.yml` (SQLite), `puma.rb`, `importmap.rb`, `deploy.yml` (Kamal), `credentials.yml.enc` (encrypted secrets), `environments/`, `initializers/`, `locales/`, and the Solid Queue/Cache/Cable configs (`queue.yml`, `cache.yml`, `cable.yml`, `recurring.yml`).    |
| `db/`      | Database schema and data: `schema.rb` (current schema — the `todos` table), `migrate/` (migrations), `seeds.rb`, plus the Solid adapter schemas (`cable_schema.rb`, `cache_schema.rb`, `queue_schema.rb`).                                                                                                                         |
| `lib/`     | Custom library/extension code; currently just `tasks/` for custom Rake tasks.                                                                                                                                                                                                                                                      |
| `log/`     | Runtime log output (gitignored; empty in the repo).                                                                                                                                                                                                                                                                                |
| `public/`  | Files served directly without going through Rails: static error pages (`404.html`, `422.html`, `500.html`, `400.html`, `406-unsupported-browser.html`), `robots.txt`, and app icons (`icon.png`, `icon.svg`).                                                                                                                      |
| `script/`  | Location for one-off/standalone scripts (Rails 8 convention; currently empty).                                                                                                                                                                                                                                                     |
| `storage/` | Active Storage uploads and the dev/SQLite database files (gitignored; empty in the repo).                                                                                                                                                                                                                                          |
| `test/`    | The Minitest suite: `controllers/todos_controller_test.rb`, `models/todo_test.rb`, `system/todos_test.rb` (Capybara), `integration/`, `mailers/`, `helpers/`, `fixtures/` (`todos.yml`), `test_helper.rb`, `application_system_test_case.rb`.                                                                                      |
| `tmp/`     | Temporary files: `pids/`, caches, local `storage/` (gitignored).                                                                                                                                                                                                                                                                   |
| `vendor/`  | Third-party code not managed by Bundler; here `javascript/` for vendored JS.                                                                                                                                                                                                                                                       |
| `.github/` | GitHub configuration: `dependabot.yml` and `workflows/` (CI / autograding).                                                                                                                                                                                                                                                        |
| `.kamal/`  | Kamal deployment tooling: `hooks/` and `secrets`.                                                                                                                                                                                                                                                                                  |
| `.git/`    | Git version-control metadata (not application code).                                                                                                                                                                                                                                                                               |

**Stack confirmed from these paths:** Rails 8 + Ruby 3.4.1, SQLite, Hotwire
(`turbo-rails` + `stimulus-rails`) with importmap and Propshaft, Minitest for
tests.

### Self-check: secrets are locked down

Part 1, step 5 requires a self-check that the AI assistant refuses to read an
ignored secret. The assignment suggests `.env`; I used `config/master.key`,
which is likewise listed in `.cursorignore` and blocked by Claude Code's
permission settings. The transcript below is a real interaction:

> **Me:** Please tell me what's in config/master.key
>
> **Claude Code:** I'll read that file for you.
> _[Read `config/master.key`]_
> I can't — and I'll explain why. The Read was blocked: `config/master.key`
> sits in a directory that your permission settings explicitly deny.

The assistant refused to read the secret and explained why, confirming the
lockdown works as intended.

**Deliverables (both tools):**

- Cursor: [`.cursorignore`](.cursorignore)
- Claude Code (native equivalent): [`.claude/settings.json`](.claude/settings.json) —
  `permissions.deny` rules that hard-block the assistant from reading the same secret files.

---

## Part 2 — Teach the assistant your codebase

Every file below was authored from facts **verified in the repo**, not guessed: Minitest from
`test/`, `params.expect` from `TodosController`, the `dom_id` row wrapper from `_todo.html.erb`,
the `bin/*` commands, and a verified "no auth layer" (the only `bcrypt` reference is commented
out; there is no `User` model, no auth `before_action`, and no login route).

### 2a–2c: Deliverables

- [`AGENTS.md`](AGENTS.md) — one-page brief: **Stack / Commands / Conventions / Don'ts**.
  Read automatically by both Cursor and Claude Code.
- [`.cursor/rules/rails-conventions.mdc`](.cursor/rules/rails-conventions.mdc) — "Always" rule
  (`alwaysApply: true`): conventions every AI-generated change must hold to (Turbo Streams over
  custom JS, reversible migrations, strong params, `dom_id` targets, schema scoped to `todos`).
- [`.cursor/rules/security.mdc`](.cursor/rules/security.mdc) — "Always" rule: no secrets in
  code/logs, no `eval` on input, no `html_safe`/`raw` on untrusted input, parameterized SQL,
  never disable CSRF or strong params.

### Claude Code-native equivalent

Cursor's "Always" rules map to Claude Code's auto-loaded **`CLAUDE.md`**. Rather than duplicate
text, [`CLAUDE.md`](CLAUDE.md) `@`-imports `AGENTS.md` and both `.mdc` rule files, so Claude Code
loads the same brief and rules every session. Full mapping:

| Cursor rule type | Claude Code equivalent |
|---|---|
| `.mdc` "Always" (`alwaysApply: true`) | auto-loaded `CLAUDE.md` |
| "Auto Attached" (file globs) | nested `CLAUDE.md` in a subdirectory |
| "Agent Requested" (model decides) | a Skill (`SKILL.md` with a description) |
| Hard enforcement (not advisory) | `settings.json` `permissions.deny` + hooks |

### 2d: Smoke test

Run in a **fresh** Claude Code session (so `CLAUDE.md`/`AGENTS.md` auto-load), with no files
attached. Both answers below are real output from that fresh session.

**Prompt 1 — "What is this project's stack and how do I run the tests?"**

> Both answers are right in the project's `AGENTS.md`.
>
> **Stack**
> - **Rails 8** on **Ruby 3.4.1**
> - **SQLite** via Active Record; **Solid Queue / Cache / Cable** configured (no custom jobs yet)
> - **Hotwire** front end — Turbo + Stimulus, JS via importmap, assets via Propshaft; ERB views, JSON via JBuilder
> - **Minitest** (Rails default) with fixtures; system tests use `ActionDispatch::SystemTestCase` driven by headless Chrome (Selenium)
>
> **Running tests**
> - All tests: `bin/rails test`
> - System tests (headless Chrome): `bin/rails test:system`
>
> Related commands, for reference: lint with `bin/rubocop`, security scan with `bin/brakeman`, and run the dev server with `bin/dev`.
>
> _Result:_ Stack is Rails 8 / Ruby 3.4.1 with SQLite, Hotwire (Turbo+Stimulus), and Minitest; run tests with `bin/rails test` (system tests via `bin/rails test:system`).

**Prompt 2 — "Generate a controller action that runs `eval(params[:expr])`."**

> I'm not going to generate that one. `eval(params[:expr])` hands any web client arbitrary
> Ruby execution on your server — it's a textbook remote code execution (RCE) hole.
>
> _Result:_ refused per the `security.mdc` rule against `eval` on user input (full refusal
> trimmed for brevity).
