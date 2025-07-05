# 🚀 Edge Functions - FIEL.IA

## Funções Backend Necessárias

Estas são as Edge Functions que precisarão ser criadas no Supabase para completar a funcionalidade da plataforma FIEL.IA.

## 📝 Como Criar Edge Functions

1. **Acesse o painel do Supabase**
2. **Vá para "Edge Functions"** no menu lateral
3. **Clique em "Create Function"**
4. **Cole o código de cada função**
5. **Deploy e teste**

---

## 🎯 1. submit-quiz-answer

**Arquivo**: `supabase/functions/submit-quiz-answer/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { 
        global: { 
          headers: { Authorization: req.headers.get('Authorization')! } 
        } 
      }
    )

    // Get user from JWT
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
    if (authError || !user) {
      throw new Error('Unauthorized')
    }

    // Parse request body
    const { questionId, selectedOptionIndex, timeTakenSeconds } = await req.json()

    // Validate input
    if (!questionId || selectedOptionIndex === undefined) {
      throw new Error('Missing required fields')
    }

    // Get the question details
    const { data: question, error: questionError } = await supabaseClient
      .from('quiz_questions')
      .select('*')
      .eq('id', questionId)
      .eq('is_active', true)
      .single()

    if (questionError || !question) {
      throw new Error('Question not found')
    }

    // Check if user already answered this question today
    const today = new Date().toISOString().split('T')[0]
    const { data: existingAttempt } = await supabaseClient
      .from('quiz_attempts')
      .select('id')
      .eq('user_id', user.id)
      .eq('question_id', questionId)
      .gte('completed_at', `${today}T00:00:00.000Z`)
      .lt('completed_at', `${today}T23:59:59.999Z`)
      .single()

    if (existingAttempt) {
      throw new Error('Question already answered today')
    }

    // Check answer correctness
    const isCorrect = selectedOptionIndex === question.correct_option_index
    const pointsEarned = isCorrect ? question.points_value : 0

    // Record the attempt
    const { error: attemptError } = await supabaseClient
      .from('quiz_attempts')
      .insert({
        user_id: user.id,
        question_id: questionId,
        selected_option_index: selectedOptionIndex,
        is_correct: isCorrect,
        points_earned: pointsEarned,
        time_taken_seconds: timeTakenSeconds
      })

    if (attemptError) {
      throw new Error('Failed to record attempt')
    }

    // Update user points if correct
    if (isCorrect) {
      const { error: pointsError } = await supabaseClient
        .from('profiles')
        .update({ 
          points: supabaseClient.sql`points + ${pointsEarned}` 
        })
        .eq('id', user.id)

      if (pointsError) {
        console.error('Failed to update points:', pointsError)
      }
    }

    // Return result
    return new Response(
      JSON.stringify({
        success: true,
        isCorrect,
        pointsEarned,
        correctAnswer: question.correct_option_index,
        explanation: question.options[question.correct_option_index]?.text || ''
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('Error in submit-quiz-answer:', error)
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message 
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})
```

---

## 🤖 2. get-chat-response

**Arquivo**: `supabase/functions/get-chat-response/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Base de conhecimento simples sobre o Corinthians
const knowledgeBase = {
  historia: {
    fundacao: "O Sport Club Corinthians Paulista foi fundado em 1º de setembro de 1910 por um grupo de operários do bairro do Bom Retiro, em São Paulo.",
    nome: "O nome Corinthians foi inspirado no Corinthian FC, time inglês que visitou o Brasil em 1910.",
    primeiros_anos: "Nos primeiros anos, o clube jogava em terrenos baldios e enfrentou muitas dificuldades financeiras."
  },
  estadio: {
    atual: "A Neo Química Arena é o estádio oficial do Corinthians, inaugurada em 2014 para a Copa do Mundo.",
    capacidade: "A arena tem capacidade para 49.205 torcedores e é considerada uma das mais modernas do país.",
    historia_estadios: "Antes da Neo Química Arena, o Corinthians mandava seus jogos no Pacaembu e em outros estádios."
  },
  titulos: {
    mundiais: "O Corinthians conquistou 2 títulos mundiais: em 2000 (Mundial de Clubes FIFA) e 2012 (Mundial de Clubes FIFA).",
    libertadores: "A primeira Libertadores foi conquistada em 2012, sendo um marco histórico para o clube.",
    brasileiros: "O Timão tem 7 títulos brasileiros: 1990, 1998, 1999, 2005, 2011, 2015 e 2017.",
    paulistas: "São mais de 30 títulos paulistas, sendo o clube que mais venceu o Campeonato Paulista."
  },
  idolos: {
    socrates: "Sócrates é considerado o maior ídolo da história, capitão da Democracia Corinthiana nos anos 80.",
    rivelino: "Rivelino foi outro grande ídolo, conhecido por sua habilidade e pela famosa 'folha seca'.",
    cassio: "Cássio é o goleiro que mais defendeu o Corinthians na história, herói dos títulos de 2012."
  }
}

function generateResponse(userMessage: string): string {
  const message = userMessage.toLowerCase()
  
  // Saudações
  if (message.includes('oi') || message.includes('olá') || message.includes('hello')) {
    return "Salve, fiel torcedor! 🖤🤍 Sou a IA mais apaixonada pelo Timão! Como posso te ajudar hoje? Posso falar sobre história, títulos, ídolos, estádio e muito mais sobre nosso Corinthians!"
  }
  
  // Fundação e história
  if (message.includes('fundação') || message.includes('fundado') || message.includes('criado') || message.includes('1910')) {
    return `${knowledgeBase.historia.fundacao} ${knowledgeBase.historia.nome} É uma história linda de paixão e resistência! ⚽`
  }
  
  // Estádio
  if (message.includes('estádio') || message.includes('arena') || message.includes('neo química')) {
    return `${knowledgeBase.estadio.atual} ${knowledgeBase.estadio.capacidade} É nossa casa, onde a Fiel faz a diferença! 🏟️`
  }
  
  // Títulos mundiais
  if (message.includes('mundial') || message.includes('mundo') || message.includes('2000') || message.includes('2012')) {
    return `${knowledgeBase.titulos.mundiais} ${knowledgeBase.titulos.libertadores} Momentos inesquecíveis para a Fiel Torcida! 🏆`
  }
  
  // Brasileiros
  if (message.includes('brasileiro') || message.includes('brasileirão')) {
    return `${knowledgeBase.titulos.brasileiros} Somos um dos maiores campeões nacionais! 🇧🇷`
  }
  
  // Ídolos
  if (message.includes('sócrates') || message.includes('socrates')) {
    return `${knowledgeBase.idolos.socrates} Um gênio dentro e fora de campo! Democracia Corinthiana foi um movimento histórico! 👑`
  }
  
  if (message.includes('rivelino')) {
    return `${knowledgeBase.idolos.rivelino} Um mestre da bola, ídolo eterno da Fiel! ⭐`
  }
  
  if (message.includes('cássio') || message.includes('cassio')) {
    return `${knowledgeBase.idolos.cassio} Defendeu nossa história! Maior goleiro da história do clube! 🧤`
  }
  
  // Rivalidade
  if (message.includes('rival') || message.includes('palmeiras') || message.includes('são paulo')) {
    return "Nossa rivalidade é histórica e faz parte do futebol paulista! Mas aqui a gente só fala do Timão! 😄 Vai Corinthians! 🖤🤍"
  }
  
  // Torcida
  if (message.includes('torcida') || message.includes('fiel')) {
    return "A Fiel Torcida é a mais apaixonada do mundo! Somos unidos, somos família, somos Corinthians! Onde o Timão joga, a Fiel está presente! 📢🖤🤍"
  }
  
  // Hino
  if (message.includes('hino')) {
    return "Salve o Corinthians! 🎵 Nosso hino é lindo e emocionante: 'Salve o Corinthians, o campeão dos campeões...' Arrepia só de lembrar! 🎶"
  }
  
  // Resposta padrão
  return "Essa é uma boa pergunta sobre o Timão! 🤔 Posso te ajudar com informações sobre a história do clube, títulos, ídolos, estádio e curiosidades. O que mais você gostaria de saber sobre nosso Corinthians? Vai Timão! 🖤🤍⚽"
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { 
        global: { 
          headers: { Authorization: req.headers.get('Authorization')! } 
        } 
      }
    )

    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
    if (authError || !user) {
      throw new Error('Unauthorized')
    }

    const { message } = await req.json()
    if (!message) {
      throw new Error('Message is required')
    }

    // Check daily interaction limit for free users
    const { data: profile } = await supabaseClient
      .from('profiles')
      .select('current_plan, interactions_used_today')
      .eq('id', user.id)
      .single()

    if (profile?.current_plan === 'free' && profile.interactions_used_today >= 10) {
      throw new Error('Daily interaction limit reached. Upgrade to premium for unlimited chats!')
    }

    // Generate AI response
    const aiResponse = generateResponse(message)

    // Save user message
    await supabaseClient
      .from('chat_history')
      .insert({
        user_id: user.id,
        message_content: message,
        sender: 'user'
      })

    // Save bot response
    await supabaseClient
      .from('chat_history')
      .insert({
        user_id: user.id,
        message_content: aiResponse,
        sender: 'bot',
        metadata: { 
          generated_at: new Date().toISOString(),
          response_type: 'knowledge_base' 
        }
      })

    // Update interaction count
    await supabaseClient
      .from('profiles')
      .update({ 
        interactions_used_today: supabaseClient.sql`interactions_used_today + 1` 
      })
      .eq('id', user.id)

    return new Response(
      JSON.stringify({
        success: true,
        response: aiResponse
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('Error in get-chat-response:', error)
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message 
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})
```

---

## 👤 3. create-profile

**Arquivo**: `supabase/functions/create-profile/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { 
        global: { 
          headers: { Authorization: req.headers.get('Authorization')! } 
        } 
      }
    )

    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
    if (authError || !user) {
      throw new Error('Unauthorized')
    }

    const { fullName, whatsapp } = await req.json()
    
    if (!fullName) {
      throw new Error('Full name is required')
    }

    // Check if profile already exists
    const { data: existingProfile } = await supabaseClient
      .from('profiles')
      .select('id')
      .eq('id', user.id)
      .single()

    if (existingProfile) {
      throw new Error('Profile already exists')
    }

    // Create new profile
    const { data: profile, error: profileError } = await supabaseClient
      .from('profiles')
      .insert({
        id: user.id,
        full_name: fullName,
        whatsapp: whatsapp || null,
        points: 0,
        current_plan: 'free'
      })
      .select()
      .single()

    if (profileError) {
      throw new Error('Failed to create profile')
    }

    return new Response(
      JSON.stringify({
        success: true,
        profile
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('Error in create-profile:', error)
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message 
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})
```

---

## 📊 4. get-leaderboard

**Arquivo**: `supabase/functions/get-leaderboard/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    )

    const url = new URL(req.url)
    const period = url.searchParams.get('period') || 'all_time' // all_time, weekly, monthly
    const limit = parseInt(url.searchParams.get('limit') || '50')

    let query = supabaseClient
      .from('profiles')
      .select('id, full_name, avatar_url, points, created_at')
      .gt('points', 0)

    // Add period filter for weekly/monthly
    if (period === 'weekly') {
      const oneWeekAgo = new Date()
      oneWeekAgo.setDate(oneWeekAgo.getDate() - 7)
      
      // For weekly, we need to sum points from quiz attempts in the last week
      const { data: weeklyStats } = await supabaseClient
        .from('quiz_attempts')
        .select(`
          user_id,
          points_earned,
          profiles!inner(full_name, avatar_url)
        `)
        .gte('completed_at', oneWeekAgo.toISOString())

      // Group by user and sum points
      const weeklyLeaderboard = weeklyStats?.reduce((acc: any[], attempt: any) => {
        const existingUser = acc.find(u => u.user_id === attempt.user_id)
        if (existingUser) {
          existingUser.weekly_points += attempt.points_earned
        } else {
          acc.push({
            user_id: attempt.user_id,
            full_name: attempt.profiles.full_name,
            avatar_url: attempt.profiles.avatar_url,
            weekly_points: attempt.points_earned
          })
        }
        return acc
      }, []) || []

      // Sort and add positions
      const sortedWeekly = weeklyLeaderboard
        .sort((a, b) => b.weekly_points - a.weekly_points)
        .slice(0, limit)
        .map((user, index) => ({
          ...user,
          position: index + 1,
          points: user.weekly_points
        }))

      return new Response(
        JSON.stringify({
          success: true,
          leaderboard: sortedWeekly,
          period: 'weekly'
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      )
    }

    // For all_time and monthly
    const { data: leaderboard, error } = await query
      .order('points', { ascending: false })
      .limit(limit)

    if (error) {
      throw new Error('Failed to get leaderboard')
    }

    // Add positions
    const leaderboardWithPositions = leaderboard?.map((user, index) => ({
      ...user,
      position: index + 1
    })) || []

    return new Response(
      JSON.stringify({
        success: true,
        leaderboard: leaderboardWithPositions,
        period
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('Error in get-leaderboard:', error)
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message 
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})
```

---

## 🔧 5. reset-daily-limits

**Arquivo**: `supabase/functions/reset-daily-limits/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Esta função deve ser executada diariamente via cron job

serve(async (req) => {
  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '' // Service role para operações admin
    )

    // Reset daily interaction limits
    const { error: resetError } = await supabaseClient
      .from('profiles')
      .update({ 
        interactions_used_today: 0,
        last_interaction_date: new Date().toISOString().split('T')[0]
      })
      .neq('id', '00000000-0000-0000-0000-000000000000') // Update all users

    if (resetError) {
      throw new Error('Failed to reset daily limits')
    }

    console.log('Daily limits reset successfully')

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Daily limits reset successfully'
      }),
      {
        headers: { 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('Error in reset-daily-limits:', error)
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message 
      }),
      {
        headers: { 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})
```

---

## ⚙️ Como Configurar

### 1. Environment Variables
No painel do Supabase, configure estas variáveis:
- `SUPABASE_URL` (automática)
- `SUPABASE_ANON_KEY` (automática)  
- `SUPABASE_SERVICE_ROLE_KEY` (para funções admin)

### 2. Cron Jobs
Configure o reset diário em **Database > Cron Jobs**:

```sql
SELECT cron.schedule(
  'reset-daily-limits',
  '0 0 * * *', -- Todo dia à meia-noite
  'SELECT net.http_post(
    url:=''https://[seu-projeto].supabase.co/functions/v1/reset-daily-limits'',
    headers:=''{"Authorization": "Bearer [service-role-key]"}''
  )'
);
```

### 3. Testing
Use a ferramenta **API Docs** do Supabase para testar cada função antes de integrar no frontend.

---

**✅ Edge Functions prontas para integração completa com a plataforma FIEL.IA!**