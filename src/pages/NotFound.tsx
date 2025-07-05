import { useLocation } from "react-router-dom";
import { useEffect } from "react";
import { FielButton } from "@/components/ui/fiel-button";
import { FielCard, FielCardContent, FielCardDescription, FielCardHeader, FielCardTitle } from "@/components/ui/fiel-card";
import { ArrowLeft, Home } from "lucide-react";

const NotFound = () => {
  const location = useLocation();

  useEffect(() => {
    console.error(
      "404 Error: User attempted to access non-existent route:",
      location.pathname
    );
  }, [location.pathname]);

  return (
    <div className="min-h-screen bg-background flex items-center justify-center px-4 sm:px-6 lg:px-8">
      <div className="text-center max-w-md w-full">
        <FielCard>
          <FielCardHeader className="text-center">
            <div className="text-6xl mb-4">⚽</div>
            <FielCardTitle className="text-4xl mb-2">404</FielCardTitle>
            <FielCardDescription className="text-lg">
              Ops! Esta página não foi encontrada na arquibancada.
            </FielCardDescription>
          </FielCardHeader>
          
          <FielCardContent>
            <p className="text-neutral-text-secondary mb-6">
              Parece que você se perdeu no caminho para a Arena. 
              Que tal voltar para a página inicial?
            </p>
            
            <div className="flex flex-col sm:flex-row gap-3">
              <FielButton asChild className="flex-1">
                <a href="/">
                  <Home className="mr-2 h-4 w-4" />
                  Voltar ao Início
                </a>
              </FielButton>
              
              <FielButton variant="outline" onClick={() => window.history.back()} className="flex-1">
                <ArrowLeft className="mr-2 h-4 w-4" />
                Página Anterior
              </FielButton>
            </div>
          </FielCardContent>
        </FielCard>
      </div>
    </div>
  );
};

export default NotFound;
