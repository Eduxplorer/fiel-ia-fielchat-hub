import { FielCard, FielCardContent, FielCardDescription, FielCardHeader, FielCardTitle } from "@/components/ui/fiel-card"
import { MessageCircle, Trophy, Newspaper, Users, Brain, Zap } from "lucide-react"

const features = [
  {
    icon: MessageCircle,
    title: "FielChat",
    description: "Converse com nossa IA especializada em Corinthians. Tire dúvidas sobre história, estatísticas e curiosidades do Timão."
  },
  {
    icon: Trophy,
    title: "Quiz Diário",
    description: "Teste seus conhecimentos sobre o Corinthians com perguntas desafiadoras e ganhe pontos para subir no ranking."
  },
  {
    icon: Newspaper,
    title: "Notícias",
    description: "Fique por dentro de todas as novidades do Corinthians com nossa curadoria inteligente de notícias."
  },
  {
    icon: Users,
    title: "Comunidade Fiel",
    description: "Conecte-se com outros torcedores, compartilhe opiniões e participe de discussões sobre o Sport Club Corinthians."
  },
  {
    icon: Brain,
    title: "IA Especializada",
    description: "Nossa inteligência artificial foi treinada especificamente sobre a história e dados do Corinthians."
  },
  {
    icon: Zap,
    title: "Tempo Real",
    description: "Informações e atualizações em tempo real sobre jogos, transferências e tudo sobre o Timão."
  }
]

export function FeaturesSection() {
  return (
    <section id="recursos" className="py-20 sm:py-32 bg-background">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="text-center">
          <h2 className="text-3xl font-bold tracking-tight text-neutral-text-primary sm:text-4xl">
            Recursos para a <span className="text-accent">Fiel Torcida</span>
          </h2>
          <p className="mt-4 text-lg text-neutral-text-secondary max-w-2xl mx-auto">
            Descubra todas as funcionalidades criadas especialmente para você, torcedor apaixonado pelo Corinthians.
          </p>
        </div>
        
        <div className="mt-16 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, index) => (
            <FielCard key={index} className="group hover:scale-105 transition-all duration-300">
              <FielCardHeader>
                <div className="flex items-center space-x-3">
                  <div className="p-2 bg-accent/10 rounded-fiel-md group-hover:bg-accent/20 transition-colors duration-300">
                    <feature.icon className="h-6 w-6 text-accent" />
                  </div>
                  <FielCardTitle>{feature.title}</FielCardTitle>
                </div>
              </FielCardHeader>
              <FielCardContent>
                <FielCardDescription className="text-base">
                  {feature.description}
                </FielCardDescription>
              </FielCardContent>
            </FielCard>
          ))}
        </div>
      </div>
    </section>
  )
}