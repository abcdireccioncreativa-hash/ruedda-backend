# Ruedda — Backend (Supabase)

Capa de datos de Ruedda: esquema PostgreSQL, políticas de seguridad (RLS) y migraciones. La lógica serverless (endpoints) vive en el repo `ruedda-frontend` como Vercel Functions, por diseño de la plataforma.

## Qué hay aquí

```
ruedda-backend/
└── supabase/
    └── migrations/
        ├── 20260526000000_remote_schema.sql   Esquema inicial (tablas)
        └── 20260615000000_rls_policies.sql     Snapshot de RLS policies
```

## Stack de datos

- **PostgreSQL** gestionado por Supabase
- **Auth:** Supabase Auth (JWT, email/password + OAuth)
- **Realtime:** suscripciones para pujas en vivo
- **Storage:** buckets para fotos de vehículos, avatares, clips, logos de concesionarios

## Modelo de seguridad

Toda tabla con datos de usuario tiene **Row-Level Security (RLS) activo**. Principios:

- **Lectura pública** donde corresponde al producto: subastas activas, publicaciones activas, comentarios, fotos, concesionarios activos. (Como Cars & Bids — cualquiera ve las subastas en curso sin autenticarse.)
- **Escritura restringida por dueño:** un usuario solo puede insertar/editar sus propios registros (`auth.uid() = user_id`).
- **Datos sensibles aislados:** KYC, pagos (`payment_refs`), mensajes privados y favoritos solo son legibles por su dueño.
- **Superadmin:** rol con acceso completo para moderación, validado server-side vía `is_superadmin()` / `get_my_role()`.

### Validaciones críticas a nivel de base de datos

- **Pujas (`bids`):** una puja solo se acepta si el monto supera el `current_bid`, la subasta está `activa` y `now() < end_time`. Validado en la policy `bids: insert validado`, no solo en el cliente.
- **Actualización de subastas (`auctions`):** solo se permite actualizar una subasta `activa` y dentro de tiempo, protegiendo el cierre y el estado.

## Tablas principales

`users`, `auctions`, `bids`, `listings`, `concesionarios`, `comments`, `favorites`, `notifications`, `private_messages`, `payment_refs`, `kyc_submissions`, `auction_access_requests`, `bcv_rates`, `invitation_codes`, `noticias`, `ruedda_clips`, `carspotting`, `fotografos`.

## Reproducir el esquema

Con Supabase CLI vinculado al proyecto:

```bash
supabase db reset          # aplica todas las migraciones en orden
```

## Notas

- El archivo `20260615000000_rls_policies.sql` es un snapshot documental de las policies activas en producción. Refleja el estado real de la base de datos a junio 2026.
- Existen algunas policies redundantes (creadas en distintas iteraciones) que validan lo mismo. No representan riesgo de seguridad; su consolidación está en el roadmap de limpieza.
