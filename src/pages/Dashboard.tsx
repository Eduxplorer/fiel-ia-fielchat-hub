import { FielCard, FielCardContent, FielCardDescription, FielCardHeader, FielCardTitle } from "@/components/ui/fiel-card"
import { FielButton } from "@/components/ui/fiel-button"
import { MessageCircle, Trophy, Users, Settings, LogOut } from "lucide-react"

export default function Dashboard() {
  // Dados simulados do usuário
  const user = {
    name: "João Corinthiano",
    points: 1250,
    plan: "free",
    interactionsLeft: 8
  }

  const metrics = [
    {
      title: "Interações Restantes",
      value: user.interactionsLeft,
      description: "Conversas com FielChat hoje",
      icon: MessageCircle
    },
    {
      title: "Pontos no Quiz",
      value: user.points,
      description: "Total acumulado",
      icon: Trophy
    },
    {
      title: "Ranking",
      value: "#47",
      description: "Posição geral",
      icon: Users
    }
  ]

  return (
    <div className="min-h-screen bg-background">
      {/* Header do Dashboard */}
      <header className="bg-content border-b border-neutral-border px-4 sm:px-6 lg:px-8 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div className="text-2xl font-bold">
              <span className="text-accent">FIEL</span>
              <span className="text-secondary">.IA</span>
            </div>
            <div className="h-8 w-px bg-neutral-border"></div>
            <div>
              <h1 className="text-lg font-semibold text-neutral-text-primary">
                Olá, {user.name}!
              </h1>
              <p className="text-sm text-neutral-text-secondary">
                Plano {user.plan === 'free' ? 'Gratuito' : 'Premium'}
              </p>
            </div>
          </div>
          
          <div className="flex items-center space-x-2">
            <FielButton variant="ghost" size="sm">
              <Settings className="h-4 w-4" />
            </FielButton>
            <FielButton variant="ghost" size="sm">
              <LogOut className="h-4 w-4" />
            </FielButton>
          </div>
        </div>
      </header>

      {/* Conteúdo Principal */}
      <main className="px-4 sm:px-6 lg:px-8 py-8">
        {/* Métricas */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          {metrics.map((metric, index) => (
            <FielCard key={index}>
              <FielCardHeader>
                <div className="flex items-center justify-between">
                  <FielCardTitle className="text-lg">{metric.title}</FielCardTitle>
                  <metric.icon className="h-5 w-5 text-accent" />
                </div>
              </FielCardHeader>
              <FielCardContent>
                <div className="text-3xl font-bold text-neutral-text-primary mb-2">
                  {metric.value}
                </div>
                <FielCardDescription>{metric.description}</FielCardDescription>
              </FielCardContent>
            </FielCard>
          ))}
        </div>

        {/* Ações Rápidas */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <FielCard className="group hover:scale-105 transition-all duration-300 cursor-pointer">
            <FielCardHeader>
              <div className="flex items-center space-x-3">
                <div className="p-3 bg-accent/10 rounded-fiel-lg group-hover:bg-accent/20 transition-colors duration-300">
                  <MessageCircle className="h-8 w-8 text-accent" />
                </div>
                <div>
                  <FielCardTitle>FielChat</FielCardTitle>
                  <FielCardDescription>
                    Converse com nossa IA especializada
                  </FielCardDescription>
                </div>
              </div>
            </FielCardHeader>
            <FielCardContent>
              <FielButton className="w-full" asChild>
                <a href="/chat">Iniciar Conversa</a>
              </FielButton>
            </FielCardContent>
          </FielCard>

          <FielCard className="group hover:scale-105 transition-all duration-300 cursor-pointer">
            <FielCardHeader>
              <div className="flex items-center space-x-3">
                <div className="p-3 bg-accent/10 rounded-fiel-lg group-hover:bg-accent/20 transition-colors duration-300">
                  <Trophy className="h-8 w-8 text-accent" />
                </div>
                <div>
                  <FielCardTitle>Quiz Diário</FielCardTitle>
                  <FielCardDescription>
                    Teste seus conhecimentos sobre o Timão
                  </FielCardDescription>
                </div>
              </div>
            </FielCardHeader>
            <FielCardContent>
              <FielButton className="w-full" asChild>
                <a href="/quiz">Jogar Agora</a>
              </FielButton>
            </FielCardContent>
          </FielCard>
        </div>

        {/* Estatísticas Adicionais */}
        <div className="mt-8">
          <FielCard>
            <FielCardHeader>
              <FielCardTitle>Atividade Recente</FielCardTitle>
              <FielCardDescription>
                Seu progresso na plataforma FIEL.IA
              </FielCardDescription>
            </FielCardHeader>
            <FielCardContent>
              <div className="space-y-4">
                <div className="flex items-center justify-between py-2 border-b border-neutral-border/50">
                  <div className="flex items-center space-x-3">
                    <div className="w-2 h-2 bg-accent rounded-full"></div>
                    <span className="text-neutral-text-primary">Quiz sobre história do clube</span>
                  </div>
                  <span className="text-sm text-neutral-text-secondary">+50 pontos</span>
                </div>
                <div className="flex items-center justify-between py-2 border-b border-neutral-border/50">
                  <div className="flex items-center space-x-3">
                    <div className="w-2 h-2 bg-accent rounded-full"></div>
                    <span className="text-neutral-text-primary">Conversa com FielChat</span>
                  </div>
                  <span className="text-sm text-neutral-text-secondary">há 2 horas</span>
                </div>
                <div className="flex items-center justify-between py-2">
                  <div className="flex items-center space-x-3">
                    <div className="w-2 h-2 bg-accent rounded-full"></div>
                    <span className="text-neutral-text-primary">Cadastro realizado</span>
                  </div>
                  <span className="text-sm text-neutral-text-secondary">ontem</span>
                </div>
              </div>
            </FielCardContent>
          </FielCard>
        </div>
      </main>
    </div>
  )
}