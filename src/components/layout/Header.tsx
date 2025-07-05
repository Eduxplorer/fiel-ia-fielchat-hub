import { FielButton } from "@/components/ui/fiel-button"
import { cn } from "@/lib/utils"

interface HeaderProps {
  className?: string
}

export function Header({ className }: HeaderProps) {
  return (
    <header className={cn(
      "flex items-center justify-between px-4 sm:px-6 lg:px-8 py-4 border-b border-neutral-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60",
      className
    )}>
      <div className="flex items-center">
        <div className="text-2xl font-bold text-neutral-text-primary">
          <span className="text-accent">FIEL</span>
          <span className="text-secondary">.IA</span>
        </div>
      </div>

      <nav className="hidden md:flex items-center space-x-8">
        <a href="#recursos" className="text-neutral-text-secondary hover:text-accent transition-colors duration-300">
          Recursos
        </a>
        <a href="#precos" className="text-neutral-text-secondary hover:text-accent transition-colors duration-300">
          Preços
        </a>
      </nav>

      <div className="flex items-center space-x-4">
        <FielButton variant="ghost" asChild><a href="/login">Entrar</a></FielButton>
        <FielButton asChild><a href="/cadastro">Começar Agora</a></FielButton>
      </div>
    </header>
  )
}