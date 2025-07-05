import { FielButton } from "@/components/ui/fiel-button"
import { ArrowRight } from "lucide-react"

export function HeroSection() {
  return (
    <section className="relative overflow-hidden bg-gradient-to-br from-background via-background to-content py-20 sm:py-32">
      {/* Background decoration */}
      <div className="absolute inset-0 -z-10">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-accent/5 rounded-full blur-3xl"></div>
      </div>
      
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="text-center">
          <h1 className="text-4xl font-bold tracking-tight text-neutral-text-primary sm:text-6xl lg:text-7xl">
            O Assistente IA de 
            <span className="block text-accent">todo Corinthiano</span>
          </h1>
          
          <h2 className="mx-auto mt-6 max-w-2xl text-lg leading-8 text-neutral-text-secondary sm:text-xl">
            Converse com a IA mais apaixonada pelo Timão, teste seus conhecimentos 
            e se conecte com a Fiel Torcida como nunca antes.
          </h2>
          
          <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
            <FielButton size="lg" asChild>
              <a href="/cadastro" className="group">
                Criar Conta Grátis
                <ArrowRight className="ml-2 h-4 w-4 transition-transform group-hover:translate-x-1" />
              </a>
            </FielButton>
            
            <FielButton variant="outline" size="lg" asChild>
              <a href="#recursos">
                Ver Recursos
              </a>
            </FielButton>
          </div>
          
          <div className="mt-16 flex justify-center">
            <div className="relative rounded-fiel-xl overflow-hidden shadow-medium border border-neutral-border">
              <div className="bg-content p-8 text-center">
                <div className="text-6xl mb-4">⚽</div>
                <p className="text-neutral-text-secondary">
                  Preview da plataforma em breve
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}