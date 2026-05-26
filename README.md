# ruedda-backend

Backend infrastructure for **Ruedda** — a Venezuelan automotive marketplace featuring fixed-price listings, live auctions, dealership profiles, and Bolivar payment processing.

## Stack

- **Database**: Supabase (PostgreSQL 17) — project ref `ltodsegzbbdcaublkgtp`
- **Auth**: Supabase Auth
- **Migrations**: Supabase CLI (`supabase/migrations/`)
- **Seeds**: `supabase/seeds/`

## Setup

1. Copy `.env.example` to `.env` and fill in your Supabase credentials.
2. Install Supabase CLI: `brew install supabase/tap/supabase`
3. Link project: `supabase link --project-ref ltodsegzbbdcaublkgtp`

## Project structure

```
ruedda-backend/
├── supabase/
│   ├── config.toml
│   ├── migrations/   # Schema migrations
│   └── seeds/        # Manual seed scripts
├── .env.example
└── .gitignore
```
