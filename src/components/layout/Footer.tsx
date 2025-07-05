export function Footer() {
  return (
    <footer className="bg-content border-t border-neutral-border">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div className="md:col-span-2">
            <div className="text-2xl font-bold text-neutral-text-primary mb-4">
              <span className="text-accent">FIEL</span>
              <span className="text-secondary">.IA</span>
            </div>
            <p className="text-neutral-text-secondary max-w-md">
              A plataforma definitiva para todos os apaixonados pelo Sport Club Corinthians Paulista. 
              Conectando a Fiel Torcida através da tecnologia.
            </p>
          </div>
          
          <div>
            <h3 className="text-neutral-text-primary font-semibold mb-4">Recursos</h3>
            <ul className="space-y-2">
              <li>
                <a href="#" className="text-neutral-text-secondary hover:text-accent transition-colors duration-300">
                  FielChat
                </a>
              </li>
              <li>
                <a href="#" className="text-neutral-text-secondary hover:text-accent transition-colors duration-300">
                  Quiz Diário
                </a>
              </li>
              <li>
                <a href="#" className="text-neutral-text-secondary hover:text-accent transition-colors duration-300">
                  Notícias
                </a>
              </li>
              <li>
                <a href="#" className="text-neutral-text-secondary hover:text-accent transition-colors duration-300">
                  Comunidade
                </a>
              </li>
            </ul>
          </div>
          
          <div>
            <h3 className="text-neutral-text-primary font-semibold mb-4">Suporte</h3>
            <ul className="space-y-2">
              <li>
                <a href="#" className="text-neutral-text-secondary hover:text-accent transition-colors duration-300">
                  Central de Ajuda
                </a>
              </li>
              <li>
                <a href="#" className="text-neutral-text-secondary hover:text-accent transition-colors duration-300">
                  Contato
                </a>
              </li>
              <li>
                <a href="#" className="text-neutral-text-secondary hover:text-accent transition-colors duration-300">
                  Política de Privacidade
                </a>
              </li>
              <li>
                <a href="#" className="text-neutral-text-secondary hover:text-accent transition-colors duration-300">
                  Termos de Uso
                </a>
              </li>
            </ul>
          </div>
        </div>
        
        <div className="mt-8 pt-8 border-t border-neutral-border text-center">
          <p className="text-neutral-text-secondary">
            © 2024 FIEL.IA. Todos os direitos reservados. Feito com ❤️ para a Fiel Torcida.
          </p>
        </div>
      </div>
    </footer>
  )
}