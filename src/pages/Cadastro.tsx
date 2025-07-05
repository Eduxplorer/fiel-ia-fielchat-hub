import { useState } from "react"
import { FielCard, FielCardContent, FielCardDescription, FielCardHeader, FielCardTitle } from "@/components/ui/fiel-card"
import { FielInput } from "@/components/ui/fiel-input"
import { FielButton } from "@/components/ui/fiel-button"
import { ArrowLeft } from "lucide-react"

export default function Cadastro() {
  const [isLoading, setIsLoading] = useState(false)
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    whatsapp: '',
    password: '',
    confirmPassword: ''
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

    if (!formData.fullName.trim()) {
      newErrors.fullName = 'Nome completo é obrigatório'
    }

    if (!formData.email.trim()) {
      newErrors.email = 'E-mail é obrigatório'
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = 'E-mail inválido'
    }

    if (!formData.password) {
      newErrors.password = 'Senha é obrigatória'
    } else if (formData.password.length < 6) {
      newErrors.password = 'Senha deve ter pelo menos 6 caracteres'
    }

    if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = 'Senhas não coincidem'
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
      // Simular cadastro
      await new Promise(resolve => setTimeout(resolve, 2000))
      console.log('Cadastro realizado:', formData)
      // Redirecionar para dashboard após sucesso
    } catch (error) {
      console.error('Erro no cadastro:', error)
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
            <FielCardTitle>Criar sua conta</FielCardTitle>
            <FielCardDescription>
              Junte-se à maior comunidade digital de corinthianos
            </FielCardDescription>
          </FielCardHeader>
          
          <FielCardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <FielInput
                label="Nome completo"
                name="fullName"
                type="text"
                placeholder="João da Silva"
                value={formData.fullName}
                onChange={handleInputChange}
                error={errors.fullName}
              />

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
                label="WhatsApp (opcional)"
                name="whatsapp"
                type="tel"
                placeholder="(11) 99999-9999"
                value={formData.whatsapp}
                onChange={handleInputChange}
                error={errors.whatsapp}
              />

              <FielInput
                label="Senha"
                name="password"
                type="password"
                placeholder="Mínimo 6 caracteres"
                value={formData.password}
                onChange={handleInputChange}
                error={errors.password}
              />

              <FielInput
                label="Confirmar senha"
                name="confirmPassword"
                type="password"
                placeholder="Digite a senha novamente"
                value={formData.confirmPassword}
                onChange={handleInputChange}
                error={errors.confirmPassword}
              />

              <FielButton
                type="submit"
                size="lg"
                className="w-full"
                isLoading={isLoading}
              >
                {isLoading ? 'Criando conta...' : 'Criar Conta Grátis'}
              </FielButton>
            </form>

            <div className="mt-6 text-center">
              <p className="text-neutral-text-secondary">
                Já tem uma conta?{' '}
                <a href="/login" className="text-accent hover:underline">
                  Faça login
                </a>
              </p>
            </div>
          </FielCardContent>
        </FielCard>
      </div>
    </div>
  )
}