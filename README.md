# Loopline

A feedback-board and public-roadmap app — the "Canny in a box" pattern. Users post
ideas to a board, upvote what matters to them, and follow a public roadmap of what's
planned, in progress, and shipped.

Built as a modern, production-shaped **Rails 8** application: server-rendered with
Hotwire, real-time updates over Turbo Streams, database-backed jobs/cache/cable
(no Redis), and container deploys with Kamal.

## Stack

- **Ruby 3.4 · Rails 8.1**
- **PostgreSQL** (Active Record)
- **Hotwire** — Turbo (incl. Turbo Streams for live vote updates) + Stimulus
- **Authentication** — Rails 8 native session auth (`has_secure_password`), plus a
  registration flow and password reset
- **Solid Queue / Solid Cache / Solid Cable** — database-backed, no Redis dependency
- **Propshaft + import maps** — no Node build step
- **Kamal 2** — zero-downtime Docker deploys
- **Minitest** — model + integration tests
- **Brakeman** (static security analysis) and **RuboCop** (rails-omakase style) in CI

## What it does

| Feature | Notes |
|---|---|
| Feedback boards | Anyone can browse; signed-in users create boards (auto-slugged) |
| Ideas / posts | Signed-in users post feedback to a board |
| Upvotes | One vote per user per post (DB-enforced), live-updated via Turbo Streams, counter-cached |
| Public roadmap | Posts grouped into Planned / In progress / Done |
| Roadmap management | Board owners move posts across statuses; authors edit/delete their own posts |

## Data model

```
User ──< Board ──< Post ──< Vote
 └────────────────< Post (author)
```

- `Board` — owned by a user, has a unique slug, has many posts.
- `Post` — belongs to a board and an author; `status` enum
  (`open`/`planned`/`in_progress`/`done`/`closed`); `votes_count` counter cache.
- `Vote` — unique on `[post_id, user_id]` at the database and model level.

## Running locally

```bash
bin/setup            # installs gems, prepares the database
bin/rails db:seed    # optional sample data
bin/dev              # or: bin/rails server
```

Then open http://localhost:3000.

## Tests, security, style

```bash
bin/rails test       # model + integration tests
bin/brakeman         # static security scan
bin/rubocop          # style (rails-omakase)
```

## Deployment

Deployed as a Docker container with [Kamal](https://kamal-deploy.org). See
`config/deploy.yml`. The app exposes `/up` for health checks.

---

Built by [Khalid Benjelloun](https://github.com/kmbenjel).
