# AGENTS.md — Sample Todo App

## Stack
- Rails 8, Ruby 3.4.1.
- SQLite via Active Record. Solid Queue / Cache / Cable are configured
  (`config/queue.yml`, `cache.yml`, `cable.yml`); no custom background jobs yet.
- View layer: Hotwire — Turbo (`turbo-rails`) + Stimulus (`stimulus-rails`),
  JS through importmap, assets through Propshaft. ERB views; JSON via JBuilder.
- Tests: Minitest (Rails default) with fixtures; system tests use
  `ActionDispatch::SystemTestCase` driven by headless Chrome (Selenium).
- Authentication: Rails 8 built-in (`bcrypt` / `has_secure_password`); `User`/`Session`/`Current`
  models, login required app-wide.

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
- Authentication & authorization live in controller `before_action`s. Rails 8 built-in auth
  (`include Authentication` in `ApplicationController`) runs `require_authentication` app-wide, so
  login is required unless an action opts out via `allow_unauthenticated_access`. The logged-in
  user is `Current.user` (there is **no** `current_user` helper); the login form is
  `new_session_path`. Per-resource authorization (e.g. owner-only actions) belongs in controller
  `before_action`s, not the views or models.
- Tests must authenticate: controller/integration tests call `sign_in_as(users(:one))` (helper in
  `test/test_helpers/session_test_helper.rb`); system tests log in through the UI
  (`visit new_session_path`, fill `email_address`/`password`, click "Sign in") then wait for the
  post-login page. User fixtures `one`/`two` use password `"password"`.

## Don'ts
- No new gems without approval — keep the Gemfile to Rails 8 defaults.
- No inline JavaScript in ERB; use Stimulus controllers in `app/javascript/controllers`.
- Never `skip_before_action :verify_authenticity_token`, and never disable CSRF or strong params.
- Don't hand-edit `db/schema.rb`; change the schema only through reversible migrations
  (`bin/rails generate migration`).
- Don't seed data outside `db/seeds.rb`, and keep the schema scoped to this app's tables
  (`todos` plus the auth `users`/`sessions`); don't import models/migrations from other projects.
