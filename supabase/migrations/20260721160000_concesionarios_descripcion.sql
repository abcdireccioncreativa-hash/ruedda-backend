-- Agrega el campo "descripción" que aparece debajo del nombre en la vitrina
-- de cada concesionario/marca oficial. Editable solo por el dueño desde
-- dealer-hub (dh-descripcion-input / saveDealerProfile en index.html).
ALTER TABLE public.concesionarios
  ADD COLUMN IF NOT EXISTS descripcion text;
