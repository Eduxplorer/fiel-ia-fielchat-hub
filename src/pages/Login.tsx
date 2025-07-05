import { useState } from "react"
import { FielCard, FielCardContent, FielCardDescription, FielCardHeader, FielCardTitle } from "@/components/ui/fiel-card"
import { FielInput } from "@/components/ui/fiel-input"
import { FielButton } from "@/components/ui/fiel-button"
import { ArrowLeft } from "lucide-react"

export default function Login() {
  const [isLoading, setIsLoading] = useState(false)
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  })
  const [errors, setErrors] = useState<Record<string, string>>({})

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target
    setFormData(prev => ({ ...prev, [name]: value }))
    // Limpa o erro quando o usuário começa a digitar
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }))
    }
  }

  const validateForm = () => {
    const newErrors: Record<string, string> = {}

    if (!formData.email.trim()) {
      newErrors.email = 'E-mail é obrigatório'
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = 'E-mail inválido'
    }

    if (!formData.password) {
      newErrors.password = 'Senha é obrigatória'
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!validateForm()) return

    setIsLoading(true)
    
    // Aqui será integrado com Supabase
    try {
      // Simular login
      await new Promise(resolve => setTimeout(resolve, 1500))
      console.log('Login realizado:', formData)
      // Redirecionar para dashboard após sucesso
    } catch (error) {
      console.error('Erro no login:', error)
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-background flex items-center justify-center px-4 sm:px-6 lg:px-8">
      <div className="w-full max-w-md">
        <div className="mb-8">
          <FielButton variant="ghost" asChild>
            <a href="/" className="inline-flex items-center text-neutral-text-secondary hover:text-accent">
              <ArrowLeft className="mr-2 h-4 w-4" />
              Voltar
            </a>
          </FielButton>
        </div>

        <FielCard>
          <FielCardHeader className="text-center">
            <div className="text-2xl font-bold text-neutral-text-primary mb-2">
              <span className="text-accent">FIEL</span>
              <span className="text-secondary">.IA</span>
            </div>
            <FielCardTitle>Entrar na sua conta</FielCardTitle>
            <FielCardDescription>
              Bem-vindo de volta à comunidade corinthiana
            </FielCardDescription>
          </FielCardHeader>
          
          <FielCardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <FielInput
                label="E-mail"
                name="email"
                type="email"
                placeholder="joao@email.com"
                value={formData.email}
                onChange={handleInputChange}
                error={errors.email}
              />

              <FielInput
                label="Senha"
                name="password"
                type="password"
                placeholder="Digite sua senha"
                value={formData.password}
                onChange={handleInputChange}
                error={errors.password}
              />

              <div className="flex items-center justify-between">
                <label className="flex items-center">
                  <input
                    type="checkbox"
                    className="mr-2 rounded border-neutral-border text-accent focus:ring-accent"
                  />
                  <span className="text-sm text-neutral-text-secondary">Lembrar de mim</span>
                </label>
                <a href="#" className="text-sm text-accent hover:underline">
                  Esqueceu a senha?
                </a>
              </div>

              <FielButton
                type="submit"
                size="lg"
                className="w-full"
                isLoading={isLoading}
              >
                {isLoading ? 'Entrando...' : 'Entrar'}
              </FielButton>
            </form>

            <div className="mt-6 text-center">
              <p className="text-neutral-text-secondary">
                Ainda não tem uma conta?{' '}
                <a href="/cadastro" className="text-accent hover:underline">
                  Cadastre-se grátis
                </a>
              </p>
            </div>
          </FielCardContent>
        </FielCard>
      </div>
    </div>
  )
}