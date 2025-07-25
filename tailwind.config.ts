import type { Config } from "tailwindcss";

export default {
	darkMode: ["class"],
	content: [
		"./pages/**/*.{ts,tsx}",
		"./components/**/*.{ts,tsx}",
		"./app/**/*.{ts,tsx}",
		"./src/**/*.{ts,tsx}",
	],
	prefix: "",
	theme: {
		container: {
			center: true,
			padding: '2rem',
			screens: {
				'2xl': '1400px'
			}
		},
		extend: {
			colors: {
				// Paleta FIEL.IA (Corinthians)
				primary: 'hsl(var(--primary))',
				secondary: 'hsl(var(--secondary))',
				accent: 'hsl(var(--accent))',
				background: 'hsl(var(--background))',
				content: 'hsl(var(--content))',
				
				// Neutros
				'neutral-border': 'hsl(var(--neutral-border))',
				'neutral-text-primary': 'hsl(var(--neutral-text-primary))',
				'neutral-text-secondary': 'hsl(var(--neutral-text-secondary))',
				
				// Estados do Sistema
				success: 'hsl(var(--success))',
				warning: 'hsl(var(--warning))',
				danger: 'hsl(var(--danger))',
				
				// Compatibilidade shadcn
				border: 'hsl(var(--border))',
				input: 'hsl(var(--input))',
				ring: 'hsl(var(--ring))',
				foreground: 'hsl(var(--foreground))',
				muted: {
					DEFAULT: 'hsl(var(--muted))',
					foreground: 'hsl(var(--muted-foreground))'
				},
				destructive: {
					DEFAULT: 'hsl(var(--destructive))',
					foreground: 'hsl(var(--destructive-foreground))'
				},
				popover: {
					DEFAULT: 'hsl(var(--popover))',
					foreground: 'hsl(var(--popover-foreground))'
				},
				card: {
					DEFAULT: 'hsl(var(--card))',
					foreground: 'hsl(var(--card-foreground))'
				}
			},
			fontFamily: {
				sans: ['Inter', 'sans-serif']
			},
			borderRadius: {
				lg: 'var(--radius)',
				md: 'calc(var(--radius) - 2px)',
				sm: 'calc(var(--radius) - 4px)',
				// FIEL.IA specific
				'fiel-md': '8px',
				'fiel-lg': '12px', 
				'fiel-xl': '16px'
			},
			boxShadow: {
				'subtle': '0 2px 8px rgba(0,0,0,0.1)',
				'medium': '0 4px 12px rgba(0,0,0,0.15)'
			},
			transitionDuration: {
				'300': '300ms'
			},
			transitionTimingFunction: {
				'ease-in-out': 'ease-in-out'
			},
			keyframes: {
				'accordion-down': {
					from: {
						height: '0'
					},
					to: {
						height: 'var(--radix-accordion-content-height)'
					}
				},
				'accordion-up': {
					from: {
						height: 'var(--radix-accordion-content-height)'
					},
					to: {
						height: '0'
					}
				},
				'fade-in': {
					'0%': {
						opacity: '0',
						transform: 'translateY(10px)'
					},
					'100%': {
						opacity: '1',
						transform: 'translateY(0)'
					}
				},
				'scale-in': {
					'0%': {
						transform: 'scale(0.95)',
						opacity: '0'
					},
					'100%': {
						transform: 'scale(1)',
						opacity: '1'
					}
				}
			},
			animation: {
				'accordion-down': 'accordion-down 0.2s ease-out',
				'accordion-up': 'accordion-up 0.2s ease-out',
				'fade-in': 'fade-in 0.3s ease-out',
				'scale-in': 'scale-in 0.2s ease-out'
			}
		}
	},
	plugins: [require("tailwindcss-animate")],
} satisfies Config;