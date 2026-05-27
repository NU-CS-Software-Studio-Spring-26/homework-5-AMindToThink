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

| Cursor rule type                      | Claude Code equivalent                     |
| ------------------------------------- | ------------------------------------------ |
| `.mdc` "Always" (`alwaysApply: true`) | auto-loaded `CLAUDE.md`                    |
| "Auto Attached" (file globs)          | nested `CLAUDE.md` in a subdirectory       |
| "Agent Requested" (model decides)     | a Skill (`SKILL.md` with a description)    |
| Hard enforcement (not advisory)       | `settings.json` `permissions.deny` + hooks |

### 2d: Smoke test

Run in a **fresh** Claude Code session (so `CLAUDE.md`/`AGENTS.md` auto-load), with no files
attached. Both answers below are real output from that fresh session.

**Prompt 1 — "What is this project's stack and how do I run the tests?"**

> Both answers are right in the project's `AGENTS.md`.
>
> **Stack**
>
> - **Rails 8** on **Ruby 3.4.1**
> - **SQLite** via Active Record; **Solid Queue / Cache / Cable** configured (no custom jobs yet)
> - **Hotwire** front end — Turbo + Stimulus, JS via importmap, assets via Propshaft; ERB views, JSON via JBuilder
> - **Minitest** (Rails default) with fixtures; system tests use `ActionDispatch::SystemTestCase` driven by headless Chrome (Selenium)
>
> **Running tests**
>
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

## Part 3 Various-mode Prompting

## Ask mode

My prompt: "Where in this codebase is the todos index filter currently implemented? Cite the exact files and line numbers. Do not propose changes."
Response: "I've examined the controller, model, index view, helper, and grepped the whole app/config for filter logic. Here's what I found.

**There is no todos index filter currently implemented in this codebase.** The index action returns every todo unfiltered.

The relevant locations:

- **`app/controllers/todos_controller.rb:5-7`** — the `index` action is just `@todos = Todo.all`. No `where`, no scope, no reading of query/filter params.
- **`app/views/todos/index.html.erb:7-14`** — iterates `@todos.each` directly. No filter form, dropdown, or links.
- **`app/helpers/todos_helper.rb:1-2`** — empty module; no filter helpers.
- **`app/models/todo.rb:1-2`** — empty model; no scopes or class methods to filter by.

Supporting evidence that nothing else does it:

- A grep across `app/` and `config/` for `filter`, `where`, `scope`, and `params[:…]` turned up only `todo_params` (strong-params for `:description` at `todos_controller.rb:75`), a PWA manifest `"scope"`, and Rails' default `filter_parameter_logging.rb` — none of which filter the index.
- The schema has a `due_date` column (`db/migrate/20260519180933_add_due_date_to_todo.rb`) and a `description`, but neither is used for filtering anywhere.

result: No todos index filter exists yet — `TodosController#index` (`app/controllers/todos_controller.rb:5-7`) loads `Todo.all` unfiltered and `index.html.erb:7-14` renders all of them; the helper and model are empty stubs."

## Plan mode (design)

**Prompt used (Plan mode — design only, no code):**

> "I want to change how a todo gets marked done so that **only the user who created a todo can mark it done; other authenticated users can see it but cannot toggle it**. Propose a plan as a numbered list of changes, including files to edit, new tests to add, and any migration. Do not write code."

**Plan I got back.** It first established the gap: the app has *no authentication* (no `User`/`Session`, `bcrypt` commented out), *no done-state* (the `todos` table is just `description`/`due_date`/timestamps), and *no ownership* (no `user_id`, no `belongs_to :user`). So the rule can't be a one-line tweak — it has to stand up auth, ownership, and a done flag, then gate the toggle. Stated decisions: (a) Rails 8 built-in auth via `bin/rails generate authentication`; (b) only the done-toggle is owner-gated, everything else stays open to any logged-in user; (c) a dedicated `PATCH /todos/:id/toggle_done` action guarded by an owner `before_action`.

1. **Generate authentication** — run `bin/rails generate authentication` (User/Session/Current, sessions & passwords controllers, `Authentication` concern, login views), uncomment `bcrypt`, add `has_many :todos` to `User`, migrate.
2. **Add `root "todos#index"`** — the concern's `after_authentication_url` falls back to `root_url`, and the generated `SessionsControllerTest` asserts a redirect there.
3. **Migration `AddDoneAndUserToTodos`** — `done:boolean` (default false, `null: false`) and `user:references` (FK, `null: false`) on `todos`.
4. **Model** — `Todo belongs_to :user`; `done` needs no validation (the DB default covers it).
5. **Routes** — `resources :todos do member { patch :toggle_done } end`.
6. **Controller** (`todos_controller.rb`) — add `toggle_done`; extend `set_todo` to cover it; add `before_action :require_owner, only: :toggle_done`; in `create`, build through `Current.user.todos`; keep `todo_params` permitting only `:description` (never `done`/`user_id`).
7. **Views & serializers** — `_todo.html.erb` shows done status + creator and renders the toggle button only for the owner; `_todo.json.jbuilder` adds `done`/`user_id`; the layout gets a sign-out control; `db/seeds.rb` is rewritten to create users and owned todos.
8. **Tests** — `users.yml` + owners in `todos.yml`; controller tests for owner-can-toggle, non-owner-cannot, unauthenticated-redirected; model tests for the association + done default; a system test for the owner clicking the toggle and the button being absent for a non-owner.

Plus a verification section (`bin/rails test`, `bin/rails test:system`, a manual two-user walkthrough) and a "trickiest parts" note: global auth breaks every existing test until they sign in; there's no signup flow, so the first user comes from seeds/console; keep mass-assignment locked down.

**My edits to the plan** (where I tightened / removed / corrected):

1. **Removed the `current_user` waffle.** The plan offered an *optional* 4-line `current_user` helper "or just use `Current.user`" and then used both. I deleted the helper option and committed to `Current.user` everywhere — one convention, nothing to keep in sync.
2. **Tightened the toggle to HTML-only.** The returned `toggle_done` and `require_owner` each carried a `respond_to` block with an extra `format.json` branch (and the test plan said "test both HTML and JSON paths"). Since the toggle is a plain HTML `button_to`, I dropped the JSON branches and the doubled test matrix:
   - `toggle_done`: from `respond_to { html redirect_back…; json render :show }` down to a single `redirect_to @todo, notice: "Todo updated."`.
   - `require_owner`: from `respond_to { html redirect…; json head :forbidden }` down to a one-liner `redirect_to @todo, alert: "…" unless @todo.user_id == Current.user.id`.
3. **Corrected the redirect target.** The original used `redirect_back fallback_location: todos_path`, whose result depends on the `Referer` header. I changed it to `redirect_to @todo` to match the existing `update`/`create` style and keep the controller test deterministic.
4. **Added a correctness note** that `require_owner` must be declared *after* `set_todo`, so `@todo` is loaded before the owner check runs.

I deliberately **kept** two things a reviewer might have trimmed: explicit `done: false` in the fixtures (so the assertions are obvious), and a single inline `before_action` guard instead of pulling in Pundit/CanCanCan — one rule doesn't justify an authorization gem. I **declined** two further suggestions as out of scope for this slice: preloading `:user` in `index` to avoid an N+1, and exempting `/hello` from login.

## Agent Mode (smallest slice)

My prompt: "Please implement part 1 only, then commit, and put the link to the commit in the submission. Then wait for my go-ahead."

**Part 1 — authentication scaffolding.** The rule presupposes users, which this codebase had none of, so the smallest first slice is standing up Rails 8's built-in authentication (and nothing else — todo ownership and the done-state come in later slices):

- `bin/rails generate authentication` — `User`/`Session`/`Current` models, sessions & passwords controllers, the `Authentication` concern, login views, and the password-reset mailer; `bcrypt` uncommented.
- `include Authentication` makes login required app-wide; added `root "todos#index"` as the post-login landing (the generated `SessionsControllerTest` redirects there).
- Migrated the `users` and `sessions` tables.
- Signed in the existing todos controller/system tests in their `setup`, since app-wide auth would otherwise bounce every request to the login page (the system test logs in through the UI and waits for the post-login page to land).

Verified green before committing: `bin/rails test` → 19 runs, 59 assertions, 0 failures; `bin/rails test:system` → 4 runs, 8 assertions, 0 failures.

Commit: [`282fdff`](https://github.com/NU-CS-Software-Studio-Spring-26/homework-5-AMindToThink/commit/282fdff6f521a1df51d75d1b11e86c659699f7f9) on `hw5`. (The link resolves once the branch is pushed.)
