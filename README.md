# FIEL.IA - O Assistente IA de todo Corinthiano ⚽

## Sobre o Projeto

**FIEL.IA** é uma plataforma SaaS (Software as a Service) completa, desenvolvida como um assistente de inteligência artificial especializado no Sport Club Corinthians Paulista. A plataforma oferece funcionalidades de chat interativo, quiz gamificado, notícias e comunidade para conectar a Fiel Torcida através da tecnologia.

## ✨ Funcionalidades

### 🤖 FielChat
- Conversa com IA especializada em Corinthians
- Base de conhecimento sobre história, estatísticas e curiosidades
- Respostas contextualizadas e personalizadas

### 🏆 Quiz Diário
- Perguntas desafiadoras sobre o Timão
- Sistema de pontuação gamificado
- Ranking competitivo entre usuários
- Conquistas e recompensas

### 📰 Central de Notícias
- Curadoria inteligente de notícias
- Atualizações em tempo real
- Filtros personalizáveis por categoria

### 👥 Comunidade Fiel
- Conexão entre torcedores
- Discussões e debates
- Compartilhamento de conteúdo

## 🎨 Design System

### Paleta de Cores (Corinthians)
- **Primária**: Preto absoluto (#000000)
- **Secundária**: Branco (#FFFFFF)  
- **Accent**: Dourado (#FFD700)
- **Background**: #121212
- **Content**: #1C1C1C

### Princípios de Design
- **Mobile-First**: Otimizado para dispositivos móveis
- **Acessibilidade**: Seguindo diretrizes WCAG
- **Performance**: Core Web Vitals otimizados
- **Consistência**: Sistema de componentes reutilizáveis

## 🛠️ Stack Tecnológica

### Frontend
- **React.js 18+** com TypeScript
- **Tailwind CSS** para estilização
- **Radix UI** para componentes headless
- **Framer Motion** para animações
- **React Hook Form + Zod** para formulários

### Backend (Futuro - Supabase)
- **Supabase** como Backend as a Service
- **PostgreSQL** como banco de dados
- **Supabase Auth** para autenticação
- **Edge Functions** para lógica backend
- **Supabase Storage** para arquivos

### Outras Tecnologias
- **Lucide React** para ícones
- **Recharts** para gráficos
- **React Router DOM** para navegação

## 🚀 Como Executar

### Pré-requisitos
- Node.js 18+ e npm instalados
- Git para versionamento

### Instalação
```bash
# Clone o repositório
git clone <URL_DO_REPOSITORIO>

# Entre no diretório
cd fiel-ia

# Instale as dependências
npm install

# Execute o projeto
npm run dev
```

### Scripts Disponíveis
- `npm run dev` - Inicia o servidor de desenvolvimento
- `npm run build` - Gera build de produção
- `npm run preview` - Visualiza build de produção localmente

## 📱 Páginas Implementadas

### ✅ Fase 1 - MVP (Implementado)
- [x] **Landing Page** (`/`) - Página inicial com proposta de valor
- [x] **Cadastro** (`/cadastro`) - Registro de novos usuários
- [x] **Login** (`/login`) - Autenticação de usuários
- [x] **Dashboard** (`/dashboard`) - Painel principal do usuário
- [x] **404** (`*`) - Página de erro personalizada

### 🔄 Fase 2 - Engajamento (Planejado)
- [ ] **FielChat** (`/chat`) - Interface de conversação com IA
- [ ] **Quiz** (`/quiz`) - Sistema de perguntas e respostas
- [ ] **Ranking** (`/ranking`) - Leaderboard dos usuários
- [ ] **Perfil** (`/perfil`) - Configurações do usuário

### 🔮 Fase 3 - Monetização (Futuro)
- [ ] **Planos** (`/planos`) - Assinaturas e pagamentos
- [ ] **Admin** (`/admin`) - Painel administrativo
- [ ] **Comunidade** (`/comunidade`) - Fórum de discussões

## 🧩 Componentes Criados

### Sistema de UI Personalizado
- `FielButton` - Botões com variantes do design system
- `FielCard` - Cards para layout de conteúdo
- `FielInput` - Campos de entrada com validação visual
- `Header` - Cabeçalho principal da aplicação
- `Footer` - Rodapé com links e informações

### Seções Reutilizáveis
- `HeroSection` - Seção hero da landing page
- `FeaturesSection` - Showcase de funcionalidades

## 🎯 Próximos Passos

### Integração Backend
1. **Configurar Supabase**
   - Criar projeto no Supabase
   - Configurar variáveis de ambiente
   - Implementar autenticação

2. **Banco de Dados**
   - Criar tabelas conforme schema SQL definido
   - Configurar Row Level Security (RLS)
   - Implementar políticas de acesso

3. **Edge Functions**
   - `submit-quiz-answer` - Processamento de respostas
   - `get-chat-response` - Lógica do chatbot
   - `webhook-stripe` - Integração de pagamentos

### Novas Funcionalidades
1. **Sistema de Chat**
   - Interface de conversação
   - Histórico de mensagens
   - Simulação de IA respondendo

2. **Quiz Gamificado**
   - Banco de perguntas
   - Sistema de pontuação
   - Ranking global e semanal

## 📋 Arquitetura de Dados (Planejado)

### Tabelas Principais
```sql
-- Perfis de usuário
profiles (id, full_name, whatsapp, avatar_url, points, current_plan)

-- Perguntas do quiz
quiz_questions (id, question_text, options, correct_option_index, image_url)

-- Tentativas de quiz
quiz_attempts (id, user_id, score, completed_at)

-- Histórico de chat
chat_history (id, user_id, message_content, sender, created_at)
```

## 🤝 Contribuição

Este projeto foi desenvolvido seguindo as especificações técnicas rigorosas do documento de arquitetura FIEL.IA. 

### Padrões de Código
- TypeScript para type safety
- Componentes funcionais com hooks
- Design system consistente
- Acessibilidade como prioridade

### Estrutura de Pastas
```
src/
├── components/
│   ├── ui/           # Componentes base reutilizáveis
│   ├── layout/       # Componentes de layout
│   └── sections/     # Seções específicas
├── pages/            # Páginas da aplicação
├── lib/              # Utilitários e configurações
└── assets/           # Imagens e recursos estáticos
```

## 📞 Suporte

Para dúvidas técnicas ou sugestões sobre o projeto FIEL.IA, consulte a documentação ou entre em contato com a equipe de desenvolvimento.

---

**FIEL.IA** - Conectando a Fiel Torcida através da tecnologia ⚫⚪🟡