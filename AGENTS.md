# AGENTS.md — Sample Todo App

## Stack
- Rails 8, Ruby 3.4.1.
- SQLite via Active Record. Solid Queue / Cache / Cable are configured
  (`config/queue.yml`, `cache.yml`, `cable.yml`); no custom background jobs yet.
- View layer: Hotwire — Turbo (`turbo-rails`) + Stimulus (`stimulus-rails`),
  JS through importmap, assets through Propshaft. ERB views; JSON via JBuilder.
- Tests: Minitest (Rails default) with fixtures; system tests use
  `ActionDispatch::SystemTestCase` driven by headless Chrome (Selenium).

## Commands
- Setup:         `bin/setup`
- Run (server):  `bin/dev`
- Test (all):    `bin/rails test`   (system tests: `bin/rails test:system`)
- Lint:          `bin/rubocop`
- Security scan: `bin/brakeman`

## Conventions
- RESTful controllers in `app/controllers` (e.g. `TodosController`); models in `app/models`.
- Controllers respond via `respond_to` with `format.html` and `format.json` (JBuilder
  `*.json.jbuilder`). For partial-page updates, add `format.turbo_stream` with a matching
  `app/views/todos/<action>.turbo_stream.erb`.
- Strong params use Rails 8 `params.expect(...)` (e.g. `params.expect(todo: [:description])`).
- Shared/row partials live in `app/views/todos/` (`_todo.html.erb`, `_form.html.erb`); each
  row is wrapped in `<div id="<%= dom_id todo %>">`, which is the Turbo Stream target.
- No authentication/authorization layer exists: no auth gems are active (the only `bcrypt`
  reference is commented out), no `User`/session model, no auth `before_action`s, no login
  routes. Treat all actions as open; don't assume a `current_user`.

## Don'ts
- No new gems without approval — keep the Gemfile to Rails 8 defaults.
- No inline JavaScript in ERB; use Stimulus controllers in `app/javascript/controllers`.
- Never `skip_before_action :verify_authenticity_token`, and never disable CSRF or strong params.
- Don't hand-edit `db/schema.rb`; change the schema only through reversible migrations
  (`bin/rails generate migration`).
- Don't seed data outside `db/seeds.rb`, and keep the schema scoped to the `todos` table
  (don't import models/migrations from other projects).
