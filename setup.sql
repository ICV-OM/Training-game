-- جدول المنظمين
CREATE TABLE IF NOT EXISTS quiz_admins (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  display_name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- جدول الألعاب (كل لعبة لها إعدادات)
CREATE TABLE IF NOT EXISTS quiz_games (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  admin_id UUID REFERENCES quiz_admins(id),
  game_code TEXT NOT NULL,
  title TEXT DEFAULT 'لعبة اختبار',
  points_per_question INTEGER DEFAULT 10,
  time_per_question INTEGER DEFAULT 20,
  active_from TIMESTAMPTZ,
  active_to TIMESTAMPTZ,
  status TEXT DEFAULT 'draft',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- جدول الأسئلة (مرتبطة بلعبة)
CREATE TABLE IF NOT EXISTS quiz_questions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  game_id UUID REFERENCES quiz_games(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  option_a TEXT NOT NULL,
  option_b TEXT NOT NULL,
  option_c TEXT NOT NULL,
  option_d TEXT NOT NULL,
  correct_option INTEGER NOT NULL,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- تعديل جدول اللاعبين لربطه باللعبة
ALTER TABLE quiz_players ADD COLUMN IF NOT EXISTS game_id UUID;
ALTER TABLE quiz_players ADD COLUMN IF NOT EXISTS current_answer INTEGER DEFAULT -1;
ALTER TABLE quiz_players ADD COLUMN IF NOT EXISTS answer_time FLOAT DEFAULT 0;

-- صلاحيات
ALTER TABLE quiz_admins ENABLE ROW LEVEL SECURITY;
CREATE POLICY "admins_all" ON quiz_admins FOR ALL USING (true) WITH CHECK (true);
ALTER TABLE quiz_games ENABLE ROW LEVEL SECURITY;
CREATE POLICY "games_all" ON quiz_games FOR ALL USING (true) WITH CHECK (true);
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "questions_all" ON quiz_questions FOR ALL USING (true) WITH CHECK (true);

ALTER PUBLICATION supabase_realtime ADD TABLE quiz_games;
ALTER PUBLICATION supabase_realtime ADD TABLE quiz_questions;
