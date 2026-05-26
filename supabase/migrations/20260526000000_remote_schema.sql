-- Remote schema pulled from ltodsegzbbdcaublkgtp (2026-05-26)
-- Generated via Supabase Management API (Docker not available)

CREATE TABLE public.users (
  id uuid NOT NULL,
  email text NOT NULL,
  nombre text,
  apellido text,
  cedula text,
  cedula_tipo text DEFAULT 'V'::text,
  telefono text,
  username text,
  ciudad text,
  role text NOT NULL DEFAULT 'particular'::text,
  avatar_url text,
  activo boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE public.concesionarios (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  nombre text NOT NULL,
  tag text,
  ciudad text,
  telefono text,
  instagram text,
  whatsapp text,
  logo_url text,
  banner_url text,
  color text DEFAULT '135deg,#1a1a2e,#16213e'::text,
  initial text,
  activo boolean DEFAULT false,
  expiry timestamptz,
  created_at timestamptz DEFAULT now(),
  plan_expiry timestamptz
);

CREATE TABLE public.listings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  concesionario_id uuid,
  titulo text NOT NULL,
  marca text,
  modelo text,
  year integer,
  km integer,
  color text,
  motor text,
  traccion text,
  transmision text,
  combustible text,
  tipo_vehiculo text,
  ciudad text,
  descripcion text,
  precio_usd numeric,
  condicion text,
  whatsapp text,
  estado text DEFAULT 'revision'::text,
  es_chocado boolean DEFAULT false,
  tipo_dano text,
  estado_chocado text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE public.listing_photos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  listing_id uuid,
  url text NOT NULL,
  orden integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.auctions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  concesionario_id uuid,
  tipo text NOT NULL,
  estado text NOT NULL DEFAULT 'revision'::text,
  titulo text NOT NULL,
  marca text,
  modelo text,
  year integer,
  km integer,
  color text,
  transmision text,
  combustible text,
  motor text,
  traccion text,
  tipo_vehiculo text,
  clasificacion text,
  condicion text,
  duenos integer DEFAULT 1,
  ciudad text,
  descripcion text,
  precio_usd numeric,
  precio_reserva numeric,
  current_bid numeric DEFAULT 0,
  sin_reserva boolean DEFAULT false,
  duracion_dias integer DEFAULT 5,
  end_time timestamptz,
  es_chocado boolean DEFAULT false,
  tipo_dano text,
  estado_chocado text,
  whatsapp text,
  razon_rechazo text,
  moderado_por uuid,
  moderado_at timestamptz,
  bid_count integer DEFAULT 0,
  view_count integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE public.auction_photos (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  auction_id uuid,
  url text NOT NULL,
  orden integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.bids (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  auction_id uuid,
  user_id uuid,
  amount numeric NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.comments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  auction_id uuid,
  user_id uuid,
  parent_id uuid,
  body text NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.favorites (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  auction_id uuid,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.notifications (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  tipo text,
  titulo text,
  body text,
  icon text DEFAULT 'default'::text,
  read boolean DEFAULT false,
  auction_id uuid,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.bcv_rates (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  rate numeric NOT NULL,
  fecha date DEFAULT CURRENT_DATE,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.payment_refs (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  ref_num text NOT NULL,
  metodo text,
  amount_usd numeric,
  monto_bs text,
  fecha_pago text,
  celular text,
  status text DEFAULT 'pendiente'::text,
  tipo_pago text,
  auction_id uuid,
  confirmado_por uuid,
  confirmado_at timestamptz,
  razon_rechazo text,
  raw_sms text,
  created_at timestamptz DEFAULT now(),
  listing_id uuid,
  tipo text DEFAULT 'publicacion'::text
);

CREATE TABLE public.password_resets (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  token text NOT NULL,
  used boolean DEFAULT false,
  expires_at timestamptz DEFAULT (now() + '01:00:00'::interval),
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.invitation_codes (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  code text NOT NULL,
  tipos text[] NOT NULL DEFAULT '{}'::text[],
  usos_maximos integer NOT NULL DEFAULT 1,
  usos_actuales integer NOT NULL DEFAULT 0,
  dias integer NOT NULL DEFAULT 30,
  expires_at timestamptz,
  activo boolean NOT NULL DEFAULT true,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.invite_codes (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  code text NOT NULL,
  tipo text,
  usos_max integer DEFAULT 1,
  usos_count integer DEFAULT 0,
  descuento_pct integer DEFAULT 100,
  expiry timestamptz,
  creado_por uuid,
  activo boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.fotografos (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  nombre text NOT NULL,
  ciudad text,
  instagram text,
  whatsapp text,
  precio_usd numeric,
  rating numeric DEFAULT 5.0,
  fotos_url text[],
  activo boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE public.unresolved_sms (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  raw_body text NOT NULL,
  source text,
  created_at timestamptz DEFAULT now()
);
