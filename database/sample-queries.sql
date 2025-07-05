-- ========================================
-- FIEL.IA - Queries de Exemplo
-- Consultas úteis para desenvolvimento e testes
-- ========================================

-- ========================================
-- QUERIES PARA AUTENTICAÇÃO E PERFIL
-- ========================================

-- Criar perfil após cadastro (será usado no hook de auth)
INSERT INTO profiles (id, full_name, whatsapp) 
VALUES (auth.uid(), 'João Corinthiano', '11999999999');

-- Buscar dados completos do usuário logado
SELECT 
  id,
  full_name,
  whatsapp,
  avatar_url,
  points,
  current_plan,
  interactions_used_today,
  created_at
FROM profiles 
WHERE id = auth.uid();

-- Atualizar perfil do usuário
UPDATE profiles 
SET 
  full_name = 'João da Silva Santos',
  whatsapp = '11988887777',
  avatar_url = 'https://example.com/avatar.jpg'
WHERE id = auth.uid();

-- ========================================
-- QUERIES PARA SISTEMA DE QUIZ
-- ========================================

-- Buscar pergunta aleatória que o usuário ainda não respondeu hoje
SELECT 
  id,
  question_text,
  options,
  correct_option_index,
  image_url,
  difficulty_level,
  category,
  points_value
FROM quiz_questions 
WHERE is_active = true 
AND id NOT IN (
  SELECT question_id 
  FROM quiz_attempts 
  WHERE user_id = auth.uid() 
  AND DATE(completed_at) = CURRENT_DATE
)
ORDER BY RANDOM() 
LIMIT 1;

-- Registrar tentativa de resposta (será usado em Edge Function)
INSERT INTO quiz_attempts (
  user_id, 
  question_id, 
  selected_option_index, 
  is_correct, 
  points_earned,
  time_taken_seconds
) VALUES (
  auth.uid(),
  'uuid-da-pergunta',
  2, -- índice da opção selecionada
  true, -- se está correto
  15, -- pontos ganhos
  30 -- tempo em segundos
);

-- Atualizar pontos do usuário após quiz correto
UPDATE profiles 
SET points = points + 15
WHERE id = auth.uid();

-- Buscar estatísticas de quiz do usuário
SELECT 
  COUNT(*) as total_attempts,
  COUNT(CASE WHEN is_correct THEN 1 END) as correct_answers,
  ROUND(
    (COUNT(CASE WHEN is_correct THEN 1 END)::float / COUNT(*)) * 100, 
    2
  ) as accuracy_percentage,
  SUM(points_earned) as total_points_earned
FROM quiz_attempts 
WHERE user_id = auth.uid();

-- Buscar tentativas de hoje do usuário
SELECT 
  qa.id,
  qq.question_text,
  qa.selected_option_index,
  qa.is_correct,
  qa.points_earned,
  qa.completed_at
FROM quiz_attempts qa
JOIN quiz_questions qq ON qa.question_id = qq.id
WHERE qa.user_id = auth.uid()
AND DATE(qa.completed_at) = CURRENT_DATE
ORDER BY qa.completed_at DESC;

-- ========================================
-- QUERIES PARA SISTEMA DE CHAT
-- ========================================

-- Iniciar nova sessão de chat
INSERT INTO chat_sessions (user_id, session_title) 
VALUES (auth.uid(), 'Conversa sobre história do Corinthians')
RETURNING id;

-- Salvar mensagem do usuário
INSERT INTO chat_history (user_id, message_content, sender) 
VALUES (auth.uid(), 'Qual foi o primeiro título mundial do Corinthians?', 'user');

-- Salvar resposta do bot
INSERT INTO chat_history (user_id, message_content, sender, metadata) 
VALUES (
  auth.uid(), 
  'O primeiro título mundial do Corinthians foi em 2000, quando venceu o Vasco por 4x3 no Maracanã!',
  'bot',
  '{"confidence": 0.95, "source": "knowledge_base"}'::jsonb
);

-- Buscar histórico de chat do usuário (últimas 50 mensagens)
SELECT 
  id,
  message_content,
  sender,
  metadata,
  created_at
FROM chat_history 
WHERE user_id = auth.uid()
ORDER BY created_at DESC 
LIMIT 50;

-- Buscar sessões de chat do usuário
SELECT 
  id,
  session_title,
  message_count,
  started_at,
  last_message_at,
  is_active
FROM chat_sessions 
WHERE user_id = auth.uid()
ORDER BY last_message_at DESC;

-- Incrementar contador de interações diárias
UPDATE profiles 
SET interactions_used_today = interactions_used_today + 1
WHERE id = auth.uid();

-- ========================================
-- QUERIES PARA RANKINGS E LEADERBOARDS
-- ========================================

-- Top 10 usuários por pontos (ranking geral)
SELECT 
  full_name,
  points,
  avatar_url,
  ROW_NUMBER() OVER (ORDER BY points DESC) as position
FROM profiles 
WHERE points > 0
ORDER BY points DESC 
LIMIT 10;

-- Posição do usuário atual no ranking
SELECT 
  position,
  total_users
FROM (
  SELECT 
    ROW_NUMBER() OVER (ORDER BY points DESC) as position,
    id,
    COUNT(*) OVER() as total_users
  FROM profiles 
  WHERE points > 0
) ranked 
WHERE id = auth.uid();

-- Top 10 desta semana (baseado em tentativas de quiz)
SELECT 
  p.full_name,
  p.avatar_url,
  COUNT(qa.id) as quiz_attempts_this_week,
  SUM(qa.points_earned) as points_this_week
FROM profiles p
JOIN quiz_attempts qa ON p.id = qa.user_id
WHERE qa.completed_at >= DATE_TRUNC('week', CURRENT_DATE)
GROUP BY p.id, p.full_name, p.avatar_url
ORDER BY points_this_week DESC, quiz_attempts_this_week DESC
LIMIT 10;

-- ========================================
-- QUERIES PARA ADMINISTRAÇÃO
-- ========================================

-- Estatísticas gerais da plataforma
SELECT 
  (SELECT COUNT(*) FROM profiles) as total_users,
  (SELECT COUNT(*) FROM quiz_questions WHERE is_active = true) as active_questions,
  (SELECT COUNT(*) FROM quiz_attempts WHERE DATE(completed_at) = CURRENT_DATE) as quiz_attempts_today,
  (SELECT AVG(points) FROM profiles WHERE points > 0) as avg_user_points;

-- Usuários mais ativos (mais tentativas de quiz)
SELECT 
  p.full_name,
  p.current_plan,
  COUNT(qa.id) as total_quiz_attempts,
  p.points,
  p.created_at as user_since
FROM profiles p
LEFT JOIN quiz_attempts qa ON p.id = qa.user_id
GROUP BY p.id, p.full_name, p.current_plan, p.points, p.created_at
ORDER BY total_quiz_attempts DESC, p.points DESC
LIMIT 20;

-- Perguntas mais difíceis (menor taxa de acerto)
SELECT 
  qq.id,
  qq.question_text,
  qq.difficulty_level,
  qq.category,
  COUNT(qa.id) as total_attempts,
  COUNT(CASE WHEN qa.is_correct THEN 1 END) as correct_attempts,
  ROUND(
    (COUNT(CASE WHEN qa.is_correct THEN 1 END)::float / COUNT(qa.id)) * 100, 
    2
  ) as success_rate
FROM quiz_questions qq
LEFT JOIN quiz_attempts qa ON qq.id = qa.question_id
WHERE qq.is_active = true
GROUP BY qq.id, qq.question_text, qq.difficulty_level, qq.category
HAVING COUNT(qa.id) >= 10 -- Apenas perguntas com pelo menos 10 tentativas
ORDER BY success_rate ASC;

-- ========================================
-- QUERIES PARA LIMPEZA E MANUTENÇÃO
-- ========================================

-- Limpar sessões de chat inativas há mais de 30 dias
UPDATE chat_sessions 
SET is_active = false 
WHERE last_message_at < (CURRENT_DATE - INTERVAL '30 days')
AND is_active = true;

-- Arquivar chat history muito antigo (mais de 1 ano)
-- NOTA: Em produção, considere mover para tabela de arquivo ao invés de deletar
DELETE FROM chat_history 
WHERE created_at < (CURRENT_DATE - INTERVAL '1 year');

-- Resetar contador de interações para todos os usuários (executar diariamente)
UPDATE profiles 
SET 
  interactions_used_today = 0,
  last_interaction_date = CURRENT_DATE
WHERE last_interaction_date < CURRENT_DATE;

-- ========================================
-- QUERIES PARA MÉTRICAS E ANALYTICS
-- ========================================

-- Usuários ativos por dia (últimos 30 dias)
SELECT 
  DATE(qa.completed_at) as date,
  COUNT(DISTINCT qa.user_id) as active_users,
  COUNT(qa.id) as total_quiz_attempts
FROM quiz_attempts qa
WHERE qa.completed_at >= (CURRENT_DATE - INTERVAL '30 days')
GROUP BY DATE(qa.completed_at)
ORDER BY date DESC;

-- Distribuição de usuários por plano
SELECT 
  current_plan,
  COUNT(*) as user_count,
  ROUND((COUNT(*)::float / (SELECT COUNT(*) FROM profiles)) * 100, 2) as percentage
FROM profiles
GROUP BY current_plan
ORDER BY user_count DESC;

-- Taxa de retenção semanal
WITH weekly_users AS (
  SELECT 
    DATE_TRUNC('week', created_at) as signup_week,
    id as user_id
  FROM profiles
),
weekly_activity AS (
  SELECT 
    DATE_TRUNC('week', completed_at) as activity_week,
    user_id,
    COUNT(*) as activities
  FROM quiz_attempts
  GROUP BY DATE_TRUNC('week', completed_at), user_id
)
SELECT 
  wu.signup_week,
  COUNT(wu.user_id) as signups,
  COUNT(wa.user_id) as active_in_week2,
  ROUND((COUNT(wa.user_id)::float / COUNT(wu.user_id)) * 100, 2) as retention_rate
FROM weekly_users wu
LEFT JOIN weekly_activity wa ON wu.user_id = wa.user_id 
  AND wa.activity_week = wu.signup_week + INTERVAL '1 week'
WHERE wu.signup_week >= (CURRENT_DATE - INTERVAL '12 weeks')
GROUP BY wu.signup_week
ORDER BY wu.signup_week DESC;

-- ========================================
-- QUERIES PARA DESENVOLVIMENTO/DEBUG
-- ========================================

-- Verificar configuração de RLS
SELECT 
  schemaname,
  tablename,
  rowsecurity,
  forcerlsforowners
FROM pg_tables 
WHERE schemaname = 'public'
AND tablename IN ('profiles', 'quiz_questions', 'quiz_attempts', 'chat_history');

-- Listar todas as políticas RLS
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE schemaname = 'public';

-- Verificar índices criados
SELECT 
  indexname,
  tablename,
  indexdef
FROM pg_indexes 
WHERE schemaname = 'public'
AND tablename IN ('profiles', 'quiz_questions', 'quiz_attempts', 'chat_history')
ORDER BY tablename, indexname;

-- ========================================
-- QUERIES PARA TESTES
-- ========================================

-- Criar usuário de teste (executar após criar auth user)
INSERT INTO profiles (id, full_name, whatsapp, points) 
VALUES (
  'user-test-uuid', 
  'Usuário Teste', 
  '11999999999', 
  500
);

-- Criar dados de teste para quiz
INSERT INTO quiz_attempts (user_id, question_id, selected_option_index, is_correct, points_earned)
SELECT 
  'user-test-uuid',
  id,
  1, -- sempre seleciona opção 1
  (1 = correct_option_index), -- correto se opção 1 for a correta
  CASE WHEN (1 = correct_option_index) THEN points_value ELSE 0 END
FROM quiz_questions 
WHERE is_active = true
LIMIT 5;

-- Limpar dados de teste
DELETE FROM quiz_attempts WHERE user_id = 'user-test-uuid';
DELETE FROM profiles WHERE id = 'user-test-uuid';