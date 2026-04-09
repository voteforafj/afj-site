-- =============================================
-- AFJ for America 2028 — Supabase Schema
-- Run this in: Supabase Dashboard > SQL Editor
-- =============================================

-- SUPPORTERS
CREATE TABLE IF NOT EXISTS supporters (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at  timestamptz DEFAULT now(),
  first_name  text,
  last_name   text,
  email       text NOT NULL,
  phone       text,
  state       text,
  age_range   text,
  why         text
);

-- OPINIONS
CREATE TABLE IF NOT EXISTS opinions (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at  timestamptz DEFAULT now(),
  message     text NOT NULL,
  topic_tags  text
);

-- RANTS
CREATE TABLE IF NOT EXISTS rants (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at  timestamptz DEFAULT now(),
  message     text NOT NULL
);

-- DIRECT MESSAGES
CREATE TABLE IF NOT EXISTS direct_messages (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at  timestamptz DEFAULT now(),
  message     text,
  media_path  text,
  media_url   text,
  media_name  text
);

-- POLLS
CREATE TABLE IF NOT EXISTS polls (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at  timestamptz DEFAULT now(),
  question    text NOT NULL,
  options     text[] NOT NULL,
  active      boolean DEFAULT true
);

-- POLL VOTES
CREATE TABLE IF NOT EXISTS poll_votes (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at    timestamptz DEFAULT now(),
  poll_id       uuid REFERENCES polls(id) ON DELETE CASCADE,
  option_index  integer NOT NULL
);

-- =============================================
-- ENABLE ROW LEVEL SECURITY
-- =============================================
ALTER TABLE supporters     ENABLE ROW LEVEL SECURITY;
ALTER TABLE opinions       ENABLE ROW LEVEL SECURITY;
ALTER TABLE rants           ENABLE ROW LEVEL SECURITY;
ALTER TABLE direct_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE polls           ENABLE ROW LEVEL SECURITY;
ALTER TABLE poll_votes      ENABLE ROW LEVEL SECURITY;

-- =============================================
-- RLS POLICIES — PUBLIC (anon) ACCESS
-- =============================================

-- Supporters: anyone can insert, only authenticated can read
CREATE POLICY "Public can register as supporter"
  ON supporters FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "Authenticated can read supporters"
  ON supporters FOR SELECT TO authenticated USING (true);

-- Opinions: anyone can insert and read (public feed)
CREATE POLICY "Public can submit opinion"
  ON opinions FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "Public can read opinions"
  ON opinions FOR SELECT TO anon USING (true);

-- Rants: anyone can insert and read (public feed)
CREATE POLICY "Public can drop a rant"
  ON rants FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "Public can read rants"
  ON rants FOR SELECT TO anon USING (true);

-- Direct messages: anyone can insert, only authenticated can read
CREATE POLICY "Public can send direct message"
  ON direct_messages FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "Authenticated can read direct messages"
  ON direct_messages FOR SELECT TO authenticated USING (true);

-- Polls: anyone can read, only authenticated can insert/update
CREATE POLICY "Public can read polls"
  ON polls FOR SELECT TO anon USING (true);

CREATE POLICY "Authenticated can manage polls"
  ON polls FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Poll votes: anyone can insert, anyone can read (for live results)
CREATE POLICY "Public can vote"
  ON poll_votes FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "Public can read poll votes"
  ON poll_votes FOR SELECT TO anon USING (true);

-- =============================================
-- ENABLE REALTIME
-- =============================================
ALTER PUBLICATION supabase_realtime ADD TABLE supporters;
ALTER PUBLICATION supabase_realtime ADD TABLE rants;
ALTER PUBLICATION supabase_realtime ADD TABLE opinions;
ALTER PUBLICATION supabase_realtime ADD TABLE polls;
ALTER PUBLICATION supabase_realtime ADD TABLE poll_votes;

-- =============================================
-- STORAGE BUCKET for campaign-media (file uploads)
-- Run this separately in Supabase Dashboard >
-- Storage > New Bucket: name it "campaign-media"
-- and set it to PUBLIC.
-- =============================================
