-- Privacidad de users + funciones seguras (2026-09-29). Ver Ruedda_SQL_completo_2026-09-29.sql
-- ────────────────────────────────────────────────────────────────────────────
-- PARTE 2 · FUNCIONES SEGURAS
-- Corren con permisos del dueño (security definer) y cada una valida quién llama.
-- ────────────────────────────────────────────────────────────────────────────

-- 2.1 Mi perfil completo (incluye mis propios datos privados). Solo devuelve TU fila.
create or replace function public.get_my_profile()
returns setof public.users
language sql
stable
security definer
set search_path = public
as $$
  select * from public.users where id = auth.uid();
$$;
revoke all on function public.get_my_profile() from public;
grant execute on function public.get_my_profile() to authenticated;

-- 2.2 ¿Esta cédula ya está registrada? Solo responde sí/no (nunca devuelve datos).
--     La usa el registro, por eso también la puede llamar alguien sin sesión.
create or replace function public.cedula_en_uso(p_cedula text, p_tipo text default null, p_excluir uuid default null)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists(
    select 1 from public.users
    where cedula::text = p_cedula
      and (p_tipo is null or cedula_tipo::text = p_tipo)
      and (p_excluir is null or id <> p_excluir)
  );
$$;
revoke all on function public.cedula_en_uso(text, text, uuid) from public;
grant execute on function public.cedula_en_uso(text, text, uuid) to anon, authenticated;

-- 2.3 Datos privados de varios usuarios — SOLO superadmin (Ruedda Control, KYC, pagos)
create or replace function public.admin_users_private(p_ids uuid[])
returns table(id uuid, email text, cedula text, cedula_tipo text, telefono text, celular text)
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  if not is_superadmin() then
    raise exception 'acceso denegado' using errcode = '42501';
  end if;
  return query
    select u.id, u.email::text, u.cedula::text, u.cedula_tipo::text, u.telefono::text, u.celular::text
    from public.users u
    where u.id = any(p_ids);
end;
$$;
revoke all on function public.admin_users_private(uuid[]) from public;
grant execute on function public.admin_users_private(uuid[]) to authenticated;

-- 2.4 Buscar usuarios por correo, cédula o teléfono — SOLO superadmin
create or replace function public.admin_find_users(p_q text)
returns table(id uuid)
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  if not is_superadmin() then
    raise exception 'acceso denegado' using errcode = '42501';
  end if;
  return query
    select u.id from public.users u
    where u.email::text    ilike '%' || p_q || '%'
       or u.cedula::text   ilike '%' || p_q || '%'
       or u.telefono::text ilike '%' || p_q || '%'
       or u.celular::text  ilike '%' || p_q || '%'
    limit 500;
end;
$$;
revoke all on function public.admin_find_users(text) from public;
grant execute on function public.admin_find_users(text) to authenticated;


-- ────────────────────────────────────────────────────────────────────────────
-- PARTE 3 · PRIVACIDAD DE users
-- Hoy cualquiera con la clave pública de la app puede leer correo, cédula y teléfono
-- de todos los usuarios. Esto quita el permiso de lectura SOLO a esas 5 columnas.
-- Todo lo demás (nombre, @usuario, foto, ciudad, rol, verificado, etc.) sigue público
-- porque lo necesitan los perfiles, el market y la comunidad.
-- · El servidor (service_role: APIs de Vercel) no se ve afectado.
-- · Escribir en tu propia fila (editar perfil, registro) no se ve afectado.
-- · Columnas que se agreguen en el futuro quedan públicas automáticamente si se
--   vuelve a correr este bloque (se calcula la lista en el momento).
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare cols text;
begin
  select string_agg(quote_ident(column_name), ', ' order by ordinal_position)
    into cols
  from information_schema.columns
  where table_schema = 'public' and table_name = 'users'
    and column_name not in ('email','cedula','cedula_tipo','telefono','celular');

  execute 'revoke select on public.users from anon, authenticated';
  execute 'revoke select (email, cedula, cedula_tipo, telefono, celular) on public.users from anon, authenticated';
  execute format('grant select (%s) on public.users to anon, authenticated', cols);
end $$;

-- que la API de Supabase recargue permisos y funciones nuevas ya mismo
notify pgrst, 'reload schema';


