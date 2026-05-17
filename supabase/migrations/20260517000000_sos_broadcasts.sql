-- SOS Broadcasts table: stores real-time emergency broadcasts for nearby
-- responders and facilities. Replaces the previous simulated "nearby services"
-- channel that returned fake success after a 3-second delay.
CREATE TABLE IF NOT EXISTS sos_broadcasts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  incident_id TEXT NOT NULL,
  user_id UUID REFERENCES auth.users(id),
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  severity INTEGER NOT NULL CHECK (severity BETWEEN 1 AND 5),
  services_needed TEXT NOT NULL DEFAULT 'ambulance',
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'resolved', 'expired')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  resolved_at TIMESTAMPTZ
);

CREATE INDEX idx_sos_broadcasts_active ON sos_broadcasts (status, created_at DESC)
  WHERE status = 'active';

CREATE INDEX idx_sos_broadcasts_location ON sos_broadcasts (latitude, longitude)
  WHERE status = 'active';

ALTER TABLE sos_broadcasts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert their own broadcasts"
  ON sos_broadcasts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Anyone can read active broadcasts"
  ON sos_broadcasts FOR SELECT
  USING (status = 'active');

CREATE POLICY "Users can update their own broadcasts"
  ON sos_broadcasts FOR UPDATE
  USING (auth.uid() = user_id);
