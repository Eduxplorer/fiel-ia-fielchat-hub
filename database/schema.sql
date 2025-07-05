-- ========================================
-- FIEL.IA - Schema do Banco de Dados
-- Plataforma SaaS para Torcedores do Corinthians
-- ========================================

-- Habilita extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ========================================
-- TABELA DE PERFIS DE USUÁRIOS
-- ========================================
-- Conectada ao sistema de autenticação do Supabase
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  whatsapp TEXT,
  avatar_url TEXT,
  points INT DEFAULT 0 CHECK (points >= 0),
  current_plan TEXT DEFAULT 'free' NOT NULL CHECK (current_plan IN ('free', 'premium', 'vip')),
  interactions_used_today INT DEFAULT 0 CHECK (interactions_used_today >= 0),
  last_interaction_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para otimização
CREATE INDEX idx_profiles_points ON profiles(points DESC);
CREATE INDEX idx_profiles_plan ON profiles(current_plan);
CREATE INDEX idx_profiles_interaction_date ON profiles(last_interaction_date);

-- ========================================
-- TABELA DE PERGUNTAS DO QUIZ
-- ========================================
CREATE TABLE quiz_questions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  question_text TEXT NOT NULL,
  options JSONB NOT NULL, -- Ex: [{"text": "Opção A"}, {"text": "Opção B"}, {"text": "Opção C"}, {"text": "Opção D"}]
  correct_option_index INT NOT NULL CHECK (correct_option_index >= 0 AND correct_option_index <= 3),
  image_url TEXT,
  difficulty_level TEXT DEFAULT 'medium' CHECK (difficulty_level IN ('easy', 'medium', 'hard')),
  category TEXT DEFAULT 'historia' CHECK (category IN ('historia', 'jogadores', 'estadio', 'titulos', 'curiosidades', 'atual')),
  points_value INT DEFAULT 10 CHECK (points_value > 0),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para otimização
CREATE INDEX idx_quiz_questions_active ON quiz_questions(is_active);
CREATE INDEX idx_quiz_questions_difficulty ON quiz_questions(difficulty_level);
CREATE INDEX idx_quiz_questions_category ON quiz_questions(category);

-- ========================================
-- TABELA DE TENTATIVAS DE QUIZ
-- ========================================
CREATE TABLE quiz_attempts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  question_id UUID REFERENCES quiz_questions(id) ON DELETE CASCADE,
  selected_option_index INT NOT NULL CHECK (selected_option_index >= 0 AND selected_option_index <= 3),
  is_correct BOOLEAN NOT NULL,
  points_earned INT DEFAULT 0 CHECK (points_earned >= 0),
  time_taken_seconds INT CHECK (time_taken_seconds > 0), -- Tempo para responder em segundos
  completed_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para otimização
CREATE INDEX idx_quiz_attempts_user ON quiz_attempts(user_id);
CREATE INDEX idx_quiz_attempts_date ON quiz_attempts(completed_at DESC);
CREATE INDEX idx_quiz_attempts_correct ON quiz_attempts(is_correct);

-- ========================================
-- TABELA DE SESSÕES DE QUIZ
-- ========================================
-- Para agrupar várias tentativas em uma sessão de quiz
CREATE TABLE quiz_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  total_questions INT DEFAULT 0,
  correct_answers INT DEFAULT 0,
  total_points_earned INT DEFAULT 0,
  session_type TEXT DEFAULT 'daily' CHECK (session_type IN ('daily', 'practice', 'challenge')),
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  is_completed BOOLEAN DEFAULT false
);

-- Índices para otimização
CREATE INDEX idx_quiz_sessions_user ON quiz_sessions(user_id);
CREATE INDEX idx_quiz_sessions_date ON quiz_sessions(completed_at DESC);
CREATE INDEX idx_quiz_sessions_type ON quiz_sessions(session_type);

-- ========================================
-- TABELA DE HISTÓRICO DE CHAT
-- ========================================
CREATE TABLE chat_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  message_content TEXT NOT NULL,
  sender TEXT NOT NULL CHECK (sender IN ('user', 'bot')),
  message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file')),
  metadata JSONB, -- Para informações adicionais como contexto da resposta
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para otimização
CREATE INDEX idx_chat_history_user ON chat_history(user_id);
CREATE INDEX idx_chat_history_date ON chat_history(created_at DESC);
CREATE INDEX idx_chat_history_sender ON chat_history(sender);

-- ========================================
-- TABELA DE SESSÕES DE CHAT
-- ========================================
-- Para agrupar conversas por sessão
CREATE TABLE chat_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  session_title TEXT,
  message_count INT DEFAULT 0,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  last_message_at TIMESTAMPTZ DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true
);

-- Índices para otimização
CREATE INDEX idx_chat_sessions_user ON chat_sessions(user_id);
CREATE INDEX idx_chat_sessions_active ON chat_sessions(is_active);
CREATE INDEX idx_chat_sessions_last_message ON chat_sessions(last_message_at DESC);

-- ========================================
-- TABELA DE NOTÍCIAS (FUTURO)
-- ========================================
CREATE TABLE news_articles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  summary TEXT,
  image_url TEXT,
  source_url TEXT,
  author TEXT,
  category TEXT DEFAULT 'geral' CHECK (category IN ('geral', 'jogos', 'transferencias', 'bastidores', 'historia')),
  is_featured BOOLEAN DEFAULT false,
  is_published BOOLEAN DEFAULT true,
  published_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para otimização
CREATE INDEX idx_news_published ON news_articles(is_published, published_at DESC);
CREATE INDEX idx_news_featured ON news_articles(is_featured);
CREATE INDEX idx_news_category ON news_articles(category);

-- ========================================
-- TABELA DE INTERAÇÕES DOS USUÁRIOS COM NOTÍCIAS
-- ========================================
CREATE TABLE news_interactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  article_id UUID REFERENCES news_articles(id) ON DELETE CASCADE,
  interaction_type TEXT NOT NULL CHECK (interaction_type IN ('view', 'like', 'share', 'comment')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Evita duplicatas de likes/shares por usuário por artigo
  UNIQUE(user_id, article_id, interaction_type)
);

-- Índices para otimização
CREATE INDEX idx_news_interactions_user ON news_interactions(user_id);
CREATE INDEX idx_news_interactions_article ON news_interactions(article_id);
CREATE INDEX idx_news_interactions_type ON news_interactions(interaction_type);

-- ========================================
-- TABELA DE RANKINGS/LEADERBOARDS
-- ========================================
CREATE TABLE leaderboards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  period_type TEXT NOT NULL CHECK (period_type IN ('daily', 'weekly', 'monthly', 'all_time')),
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  points INT NOT NULL DEFAULT 0,
  quiz_sessions INT NOT NULL DEFAULT 0,
  correct_answers INT NOT NULL DEFAULT 0,
  position INT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Evita duplicatas por usuário por período
  UNIQUE(user_id, period_type, period_start)
);

-- Índices para otimização
CREATE INDEX idx_leaderboards_period ON leaderboards(period_type, period_start);
CREATE INDEX idx_leaderboards_points ON leaderboards(points DESC);
CREATE INDEX idx_leaderboards_position ON leaderboards(position);

-- ========================================
-- FUNÇÕES TRIGGER PARA ATUALIZAÇÃO AUTOMÁTICA
-- ========================================

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_quiz_questions_updated_at BEFORE UPDATE ON quiz_questions FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_news_articles_updated_at BEFORE UPDATE ON news_articles FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- Função para resetar interações diárias
CREATE OR REPLACE FUNCTION reset_daily_interactions()
RETURNS TRIGGER AS $$
BEGIN
    -- Se a data mudou, resetar contador
    IF NEW.last_interaction_date != CURRENT_DATE THEN
        NEW.interactions_used_today = 0;
        NEW.last_interaction_date = CURRENT_DATE;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para resetar interações diárias
CREATE TRIGGER reset_daily_interactions_trigger 
    BEFORE UPDATE ON profiles 
    FOR EACH ROW 
    EXECUTE PROCEDURE reset_daily_interactions();

-- ========================================
-- ROW LEVEL SECURITY (RLS)
-- ========================================

-- Habilitar RLS em todas as tabelas
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE news_articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE news_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboards ENABLE ROW LEVEL SECURITY;

-- ========================================
-- POLÍTICAS DE RLS
-- ========================================

-- Políticas para PROFILES
CREATE POLICY "Users can view their own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Public profiles for leaderboard" ON profiles
    FOR SELECT USING (true); -- Permitir visualização pública para rankings

-- Políticas para QUIZ_QUESTIONS
CREATE POLICY "Anyone can view active quiz questions" ON quiz_questions
    FOR SELECT USING (is_active = true);

-- Políticas para QUIZ_ATTEMPTS
CREATE POLICY "Users can view their own quiz attempts" ON quiz_attempts
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own quiz attempts" ON quiz_attempts
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Políticas para QUIZ_SESSIONS
CREATE POLICY "Users can view their own quiz sessions" ON quiz_sessions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own quiz sessions" ON quiz_sessions
    FOR ALL USING (auth.uid() = user_id);

-- Políticas para CHAT_HISTORY
CREATE POLICY "Users can view their own chat history" ON chat_history
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own chat messages" ON chat_history
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Políticas para CHAT_SESSIONS
CREATE POLICY "Users can manage their own chat sessions" ON chat_sessions
    FOR ALL USING (auth.uid() = user_id);

-- Políticas para NEWS_ARTICLES
CREATE POLICY "Anyone can view published news" ON news_articles
    FOR SELECT USING (is_published = true);

-- Políticas para NEWS_INTERACTIONS
CREATE POLICY "Users can manage their own news interactions" ON news_interactions
    FOR ALL USING (auth.uid() = user_id);

-- Políticas para LEADERBOARDS
CREATE POLICY "Anyone can view leaderboards" ON leaderboards
    FOR SELECT USING (true);

-- ========================================
-- DADOS INICIAIS PARA DESENVOLVIMENTO
-- ========================================

-- Inserir algumas perguntas de quiz de exemplo
INSERT INTO quiz_questions (question_text, options, correct_option_index, difficulty_level, category, points_value) VALUES
(
  'Em que ano foi fundado o Sport Club Corinthians Paulista?',
  '[{"text": "1910"}, {"text": "1912"}, {"text": "1908"}, {"text": "1915"}]',
  0,
  'easy',
  'historia',
  10
),
(
  'Qual é o nome do estádio oficial do Corinthians?',
  '[{"text": "Morumbi"}, {"text": "Neo Química Arena"}, {"text": "Pacaembu"}, {"text": "Allianz Parque"}]',
  1,
  'easy',
  'estadio',
  10
),
(
  'Quantas vezes o Corinthians foi campeão mundial?',
  '[{"text": "1 vez"}, {"text": "3 vezes"}, {"text": "2 vezes"}, {"text": "4 vezes"}]',
  2,
  'medium',
  'titulos',
  15
),
(
  'Quem é considerado o maior ídolo da história do Corinthians?',
  '[{"text": "Rivelino"}, {"text": "Sócrates"}, {"text": "Ronaldo"}, {"text": "Cássio"}]',
  1,
  'medium',
  'jogadores',
  15
),
(
  'Em que ano o Corinthians conquistou sua primeira Libertadores?',
  '[{"text": "2012"}, {"text": "2010"}, {"text": "2011"}, {"text": "2013"}]',
  0,
  'hard',
  'titulos',
  20
);

-- ========================================
-- COMENTÁRIOS E DOCUMENTAÇÃO
-- ========================================

COMMENT ON TABLE profiles IS 'Perfis dos usuários conectados ao sistema de autenticação do Supabase';
COMMENT ON TABLE quiz_questions IS 'Banco de perguntas para o sistema de quiz gamificado';
COMMENT ON TABLE quiz_attempts IS 'Registro de todas as tentativas de resposta dos usuários';
COMMENT ON TABLE quiz_sessions IS 'Sessões de quiz agrupando múltiplas tentativas';
COMMENT ON TABLE chat_history IS 'Histórico completo de conversas com o FielChat';
COMMENT ON TABLE chat_sessions IS 'Sessões de chat para organização das conversas';
COMMENT ON TABLE news_articles IS 'Artigos de notícias sobre o Corinthians';
COMMENT ON TABLE news_interactions IS 'Interações dos usuários com as notícias';
COMMENT ON TABLE leaderboards IS 'Rankings periódicos dos usuários';

-- ========================================
-- VIEWS ÚTEIS PARA CONSULTAS FREQUENTES
-- ========================================

-- View para ranking geral de usuários
CREATE VIEW v_user_rankings AS
SELECT 
  p.id,
  p.full_name,
  p.avatar_url,
  p.points,
  p.current_plan,
  ROW_NUMBER() OVER (ORDER BY p.points DESC) as position
FROM profiles p
WHERE p.points > 0
ORDER BY p.points DESC;

-- View para estatísticas de quiz por usuário
CREATE VIEW v_user_quiz_stats AS
SELECT 
  p.id as user_id,
  p.full_name,
  COUNT(qa.id) as total_attempts,
  COUNT(CASE WHEN qa.is_correct THEN 1 END) as correct_answers,
  ROUND(
    (COUNT(CASE WHEN qa.is_correct THEN 1 END)::float / COUNT(qa.id)) * 100, 
    2
  ) as accuracy_percentage,
  SUM(qa.points_earned) as total_points_from_quiz
FROM profiles p
LEFT JOIN quiz_attempts qa ON p.id = qa.user_id
GROUP BY p.id, p.full_name;

-- View para atividade recente do usuário
CREATE VIEW v_user_recent_activity AS
SELECT 
  'quiz' as activity_type,
  qa.user_id,
  'Quiz respondido' as description,
  qa.points_earned as points,
  qa.completed_at as created_at
FROM quiz_attempts qa
UNION ALL
SELECT 
  'chat' as activity_type,
  ch.user_id,
  'Mensagem enviada' as description,
  0 as points,
  ch.created_at
FROM chat_history ch
WHERE ch.sender = 'user'
ORDER BY created_at DESC;

-- ========================================
-- ÍNDICES COMPOSTOS PARA PERFORMANCE
-- ========================================

-- Índice composto para consultas de ranking por período
CREATE INDEX idx_quiz_attempts_user_date ON quiz_attempts(user_id, completed_at);

-- Índice composto para histórico de chat por usuário e data
CREATE INDEX idx_chat_history_user_date ON chat_history(user_id, created_at);

-- Índice composto para consultas de leaderboard
CREATE INDEX idx_leaderboards_period_points ON leaderboards(period_type, period_start, points DESC);

-- ========================================
-- FIM DO SCHEMA FIEL.IA
-- ========================================