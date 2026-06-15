-- ════════════════════════════════════════════════════════════════════
-- Ruedda · RLS Policies Snapshot
-- Generado: junio 2026
-- ────────────────────────────────────────────────────────────────────
-- Este archivo documenta las políticas Row-Level Security activas en
-- producción. Es un snapshot de referencia para reproducibilidad y
-- auditoría. Refleja el estado real de la base de datos.
--
-- Modelo: lectura pública donde corresponde al producto (subastas/listings
-- activos, fotos, comentarios), escritura restringida por dueño
-- (auth.uid() = user_id), datos sensibles (KYC, pagos, mensajes) aislados
-- por dueño, y superadmin con acceso completo para moderación.
--
-- Las validaciones críticas (monto de puja, estado de subasta) se hacen
-- a nivel de base de datos, no solo en el cliente.
-- ════════════════════════════════════════════════════════════════════

-- ─── Habilitar RLS en todas las tablas ──────────────────────────────
ALTER TABLE public.users              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.auctions           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bids               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listings           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.concesionarios     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.private_messages   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_refs       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kyc_submissions    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.auction_access_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.auction_photos     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.listing_photos     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bcv_rates          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invitation_codes   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invite_codes       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.noticias           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ruedda_clips       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.carspotting        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fotografos         ENABLE ROW LEVEL SECURITY;

-- ════════════════════════════════════════════════════════════════════
-- BIDS — pujas con validación de monto y estado a nivel de DB
-- ════════════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "bids: insert validado" ON public.bids;
CREATE POLICY "bids: insert validado" ON public.bids
  FOR INSERT TO authenticated
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM public.auctions a
      WHERE a.id = bids.auction_id
        AND a.estado = 'activa'
        AND now() < a.end_time
        AND bids.amount > a.current_bid
    )
  );

DROP POLICY IF EXISTS "bids: leer todas (publico)" ON public.bids;
CREATE POLICY "bids: leer todas (publico)" ON public.bids
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "bids: superadmin full" ON public.bids;
CREATE POLICY "bids: superadmin full" ON public.bids
  FOR ALL USING (is_superadmin()) WITH CHECK (is_superadmin());

-- ════════════════════════════════════════════════════════════════════
-- AUCTIONS — lectura pública de activas, escritura por dueño,
-- update restringido a subastas activas y en tiempo
-- ════════════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "auctions: leer activas (publico)" ON public.auctions;
CREATE POLICY "auctions: leer activas (publico)" ON public.auctions
  FOR SELECT USING (estado = 'activa');

DROP POLICY IF EXISTS "auctions: leer propias" ON public.auctions;
CREATE POLICY "auctions: leer propias" ON public.auctions
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "auctions: insertar propias" ON public.auctions;
CREATE POLICY "auctions: insertar propias" ON public.auctions
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "auctions: editar propias" ON public.auctions;
CREATE POLICY "auctions: editar propias" ON public.auctions
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "auctions_delete_own" ON public.auctions;
CREATE POLICY "auctions_delete_own" ON public.auctions
  FOR DELETE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "auctions_bid_update" ON public.auctions;
CREATE POLICY "auctions_bid_update" ON public.auctions
  FOR UPDATE TO authenticated
  USING (estado = 'activa' AND now() < end_time)
  WITH CHECK (estado = 'activa' AND now() < end_time);

DROP POLICY IF EXISTS "auctions: superadmin full" ON public.auctions;
CREATE POLICY "auctions: superadmin full" ON public.auctions
  FOR ALL USING (is_superadmin()) WITH CHECK (is_superadmin());

-- ════════════════════════════════════════════════════════════════════
-- LISTINGS — marketplace: lectura pública de activas, escritura por dueño
-- ════════════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "listings: leer activas" ON public.listings;
CREATE POLICY "listings: leer activas" ON public.listings
  FOR SELECT USING (estado = 'activa');

DROP POLICY IF EXISTS "listings: leer propias" ON public.listings;
CREATE POLICY "listings: leer propias" ON public.listings
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "listings: insertar propias" ON public.listings;
CREATE POLICY "listings: insertar propias" ON public.listings
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "listings: editar propias" ON public.listings;
CREATE POLICY "listings: editar propias" ON public.listings
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "listings_delete_own" ON public.listings;
CREATE POLICY "listings_delete_own" ON public.listings
  FOR DELETE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "listings: superadmin full" ON public.listings;
CREATE POLICY "listings: superadmin full" ON public.listings
  FOR ALL USING (is_superadmin()) WITH CHECK (is_superadmin());

-- ════════════════════════════════════════════════════════════════════
-- COMMENTS — lectura pública, escritura autenticada por dueño
-- ════════════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "comments: leer (publico)" ON public.comments;
CREATE POLICY "comments: leer (publico)" ON public.comments
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "comments: crear (autenticado)" ON public.comments;
CREATE POLICY "comments: crear (autenticado)" ON public.comments
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL AND auth.uid() = user_id);

DROP POLICY IF EXISTS "comments: eliminar (propio o admin)" ON public.comments;
CREATE POLICY "comments: eliminar (propio o admin)" ON public.comments
  FOR DELETE USING (auth.uid() = user_id OR get_my_role() = 'superadmin');

-- ════════════════════════════════════════════════════════════════════
-- PAYMENT_REFS — pagos: solo el dueño lee/inserta, superadmin gestiona
-- ════════════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "payment_refs: insertar autenticado" ON public.payment_refs;
CREATE POLICY "payment_refs: insertar autenticado" ON public.payment_refs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "payment_refs: leer propias" ON public.payment_refs;
CREATE POLICY "payment_refs: leer propias" ON public.payment_refs
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "payment_refs: superadmin full" ON public.payment_refs;
CREATE POLICY "payment_refs: superadmin full" ON public.payment_refs
  FOR ALL USING (is_superadmin()) WITH CHECK (is_superadmin());

-- ════════════════════════════════════════════════════════════════════
-- PRIVATE_MESSAGES — solo emisor/receptor, marca de leído por receptor
-- ════════════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "pm_insert" ON public.private_messages;
CREATE POLICY "pm_insert" ON public.private_messages
  FOR INSERT WITH CHECK ((auth.uid())::text = (sender_id)::text);

DROP POLICY IF EXISTS "pm_select" ON public.private_messages;
CREATE POLICY "pm_select" ON public.private_messages
  FOR SELECT USING (
    (auth.uid())::text = (sender_id)::text
    OR (auth.uid())::text = (receiver_id)::text
  );

DROP POLICY IF EXISTS "pm_update_read" ON public.private_messages;
CREATE POLICY "pm_update_read" ON public.private_messages
  FOR UPDATE USING ((auth.uid())::text = (receiver_id)::text)
  WITH CHECK ((auth.uid())::text = (receiver_id)::text);

-- ════════════════════════════════════════════════════════════════════
-- KYC_SUBMISSIONS — solo el dueño lee/inserta, superadmin valida
-- ════════════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "kyc_insert_own" ON public.kyc_submissions;
CREATE POLICY "kyc_insert_own" ON public.kyc_submissions
  FOR INSERT WITH CHECK ((auth.uid())::text = (user_id)::text);

DROP POLICY IF EXISTS "kyc_select_own" ON public.kyc_submissions;
CREATE POLICY "kyc_select_own" ON public.kyc_submissions
  FOR SELECT USING ((auth.uid())::text = (user_id)::text);

DROP POLICY IF EXISTS "kyc_admin_all" ON public.kyc_submissions;
CREATE POLICY "kyc_admin_all" ON public.kyc_submissions
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.users u
            WHERE u.id = auth.uid() AND u.role = 'superadmin')
  );

-- ════════════════════════════════════════════════════════════════════
-- FAVORITES / NOTIFICATIONS — solo el dueño
-- ════════════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "favorites: leer propios" ON public.favorites;
CREATE POLICY "favorites: leer propios" ON public.favorites
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "favorites: insertar propio" ON public.favorites;
CREATE POLICY "favorites: insertar propio" ON public.favorites
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "favorites: eliminar propio" ON public.favorites;
CREATE POLICY "favorites: eliminar propio" ON public.favorites
  FOR DELETE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "notifs: leer propias" ON public.notifications;
CREATE POLICY "notifs: leer propias" ON public.notifications
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "notifs: marcar leida" ON public.notifications;
CREATE POLICY "notifs: marcar leida" ON public.notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- ════════════════════════════════════════════════════════════════════
-- LECTURA PÚBLICA — catálogos y contenido del producto
-- ════════════════════════════════════════════════════════════════════
DROP POLICY IF EXISTS "bcv_rates: leer (publico)" ON public.bcv_rates;
CREATE POLICY "bcv_rates: leer (publico)" ON public.bcv_rates
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "concesionarios: leer activos (publico)" ON public.concesionarios;
CREATE POLICY "concesionarios: leer activos (publico)" ON public.concesionarios
  FOR SELECT USING (activo = true);

-- ────────────────────────────────────────────────────────────────────
-- NOTA: snapshot documental. Algunas tablas tienen policies adicionales
-- redundantes (creadas en distintas iteraciones) que validan lo mismo.
-- No representan riesgo; su consolidación está en el roadmap de limpieza.
-- ════════════════════════════════════════════════════════════════════
