# 🗄️ Database Schema - FIEL.IA

## Configuração do Supabase

### 1. Conectar o Projeto ao Supabase

⚠️ **IMPORTANTE**: Antes de executar este schema, você precisa conectar seu projeto Lovable ao Supabase:

1. Clique no botão **verde "Supabase"** no canto superior direito da interface Lovable
2. Siga as instruções para conectar ou criar um projeto Supabase
3. Aguarde a sincronização completa

### 2. Executar o Schema

Após conectar o Supabase:

1. Acesse o **SQL Editor** no painel do Supabase
2. Cole todo o conteúdo do arquivo `schema.sql`
3. Execute o script clicando em **"RUN"**

## 📊 Estrutura das Tabelas

### 🔐 Tabelas Principais

#### `profiles`
- **Descrição**: Perfis de usuários conectados ao Supabase Auth
- **Campos principais**: `full_name`, `whatsapp`, `avatar_url`, `points`, `current_plan`
- **Relacionamento**: 1:1 com `auth.users`

#### `quiz_questions` 
- **Descrição**: Banco de perguntas do quiz
- **Campos principais**: `question_text`, `options` (JSONB), `correct_option_index`
- **Categorias**: historia, jogadores, estadio, titulos, curiosidades, atual
- **Dificuldades**: easy, medium, hard

#### `quiz_attempts`
- **Descrição**: Tentativas individuais de resposta
- **Campos principais**: `user_id`, `question_id`, `is_correct`, `points_earned`
- **Relacionamentos**: profiles, quiz_questions

#### `quiz_sessions`
- **Descrição**: Sessões de quiz (múltiplas tentativas agrupadas)
- **Tipos**: daily, practice, challenge
- **Campos de controle**: `total_questions`, `correct_answers`, `total_points_earned`

#### `chat_history`
- **Descrição**: Histórico completo de conversas
- **Senders**: user, bot
- **Tipos de mensagem**: text, image, file
- **Metadata**: JSONB para contexto adicional

#### `chat_sessions`
- **Descrição**: Sessões de chat organizadas
- **Controle**: `message_count`, `is_active`, `last_message_at`

### 📰 Tabelas de Conteúdo (Futuro)

#### `news_articles`
- **Descrição**: Notícias sobre o Corinthians
- **Categorias**: geral, jogos, transferencias, bastidores, historia
- **Controle**: `is_featured`, `is_published`

#### `news_interactions`
- **Descrição**: Interações dos usuários com notícias
- **Tipos**: view, like, share, comment
- **Constraint**: Única interação por tipo/usuário/artigo

### 🏆 Tabelas de Gamificação

#### `leaderboards`
- **Descrição**: Rankings periódicos
- **Períodos**: daily, weekly, monthly, all_time
- **Campos**: `points`, `position`, `quiz_sessions`, `correct_answers`

## 🔒 Segurança (Row Level Security)

### Políticas Implementadas

**Profiles**:
- ✅ Usuários podem ver/editar apenas seu próprio perfil
- ✅ Visualização pública para rankings (sem dados sensíveis)

**Quiz**:
- ✅ Perguntas ativas são públicas
- ✅ Tentativas são privadas por usuário
- ✅ Sessões são privadas por usuário

**Chat**:
- ✅ Histórico privado por usuário
- ✅ Sessões privadas por usuário

**Notícias**:
- ✅ Artigos publicados são públicos
- ✅ Interações privadas por usuário

**Rankings**:
- ✅ Visualização pública de leaderboards

## 🚀 Views Úteis Criadas

### `v_user_rankings`
```sql
-- Ranking geral de usuários por pontos
SELECT * FROM v_user_rankings LIMIT 10;
```

### `v_user_quiz_stats`
```sql
-- Estatísticas detalhadas de quiz por usuário
SELECT * FROM v_user_quiz_stats WHERE user_id = 'uuid-do-usuario';
```

### `v_user_recent_activity`
```sql
-- Atividade recente do usuário (quiz + chat)
SELECT * FROM v_user_recent_activity 
WHERE user_id = 'uuid-do-usuario' 
ORDER BY created_at DESC LIMIT 20;
```

## 🎯 Dados de Exemplo

O schema inclui 5 perguntas de exemplo sobre o Corinthians:
- História da fundação (1910)
- Estádio oficial (Neo Química Arena)
- Títulos mundiais (2 vezes)
- Maior ídolo (Sócrates)
- Primeira Libertadores (2012)

## 🔧 Funções e Triggers

### Triggers Automáticos
- **updated_at**: Atualização automática de timestamps
- **reset_daily_interactions**: Reset diário do contador de interações

### Constraints de Validação
- **Pontos**: Sempre >= 0
- **Planos**: Apenas 'free', 'premium', 'vip'
- **Dificuldades**: easy, medium, hard
- **Categorias**: Pré-definidas por contexto

## 📱 Integração com Frontend

### Queries Essenciais

**Buscar perfil do usuário logado**:
```sql
SELECT * FROM profiles WHERE id = auth.uid();
```

**Pergunta aleatória para quiz**:
```sql
SELECT * FROM quiz_questions 
WHERE is_active = true 
AND id NOT IN (
  SELECT question_id FROM quiz_attempts 
  WHERE user_id = auth.uid() 
  AND DATE(completed_at) = CURRENT_DATE
)
ORDER BY RANDOM() LIMIT 1;
```

**Histórico de chat do usuário**:
```sql
SELECT * FROM chat_history 
WHERE user_id = auth.uid() 
ORDER BY created_at DESC LIMIT 50;
```

**Top 10 ranking geral**:
```sql
SELECT * FROM v_user_rankings LIMIT 10;
```

## 🔄 Manutenção e Atualizações

### Limpeza Periódica
- **Chat antigo**: Considerar arquivamento após 6 meses
- **Tentativas de quiz**: Manter histórico completo para estatísticas
- **Sessões inativas**: Marcar como concluídas após 24h

### Monitoramento
- **Performance**: Verificar uso dos índices criados
- **Crescimento**: Monitorar tamanho das tabelas principais
- **RLS**: Validar políticas de segurança regularmente

## 🐛 Troubleshooting

### Erros Comuns

**"permission denied for relation"**
- Verificar se RLS está configurado corretamente
- Confirmar que o usuário está autenticado

**"foreign key constraint fails"**
- Verificar se o perfil do usuário existe em `profiles`
- Confirmar IDs corretos nas referências

**"check constraint violation"**
- Validar valores de enum (planos, dificuldades, categorias)
- Verificar constraints de valores mínimos

---

**✅ Schema pronto para produção com a plataforma FIEL.IA!**