-- Reseñas en perfiles + reportes de usuarios (2026-09-29)
-- Idempotente: se puede correr más de una vez sin romper nada.

-- 1) Reseñas: comentario opcional junto a la calificación existente
alter table public.user_ratings
  add column if not exists comentario text;
do $$ begin
  alter table public.user_ratings
    add constraint user_ratings_comentario_len check (comentario is null or char_length(comentario) <= 500);
exception when duplicate_object then null; end $$;

-- 2) Reportes de usuarios (solo superadmin los puede leer/gestionar)
create table if not exists public.user_reports (
  id          uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.users(id) on delete cascade,
  reported_id uuid not null references public.users(id) on delete cascade,
  motivo      text not null check (motivo in ('estafa','suplantacion','publicacion_falsa','acoso','spam','contenido_inapropiado','otro')),
  detalle     text check (detalle is null or char_length(detalle) <= 1000),
  estado      text not null default 'pendiente' check (estado in ('pendiente','revisado','descartado')),
  created_at  timestamptz not null default now(),
  constraint user_reports_no_self check (reporter_id <> reported_id)
);
create index if not exists user_reports_estado_idx on public.user_reports (estado, created_at desc);
-- un mismo usuario no puede tener dos reportes PENDIENTES contra la misma persona (anti-spam)
create unique index if not exists user_reports_one_pending
  on public.user_reports (reporter_id, reported_id) where estado = 'pendiente';

alter table public.user_reports enable row level security;

drop policy if exists user_reports_insert_own on public.user_reports;
create policy user_reports_insert_own on public.user_reports
  for insert to authenticated
  with check (reporter_id = auth.uid());

drop policy if exists user_reports_superadmin_all on public.user_reports;
create policy user_reports_superadmin_all on public.user_reports
  for all using (is_superadmin()) with check (is_superadmin());
