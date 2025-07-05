import * as React from "react"
import { cn } from "@/lib/utils"

const FielCard = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn(
      "bg-content border border-neutral-border rounded-fiel-xl shadow-subtle p-6 transition-all duration-300 hover:shadow-medium",
      className
    )}
    {...props}
  />
))
FielCard.displayName = "FielCard"

const FielCardHeader = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("flex flex-col space-y-1.5 pb-4", className)}
    {...props}
  />
))
FielCardHeader.displayName = "FielCardHeader"

const FielCardTitle = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLHeadingElement>
>(({ className, ...props }, ref) => (
  <h3
    ref={ref}
    className={cn("text-xl font-semibold leading-none tracking-tight text-neutral-text-primary", className)}
    {...props}
  />
))
FielCardTitle.displayName = "FielCardTitle"

const FielCardDescription = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLParagraphElement>
>(({ className, ...props }, ref) => (
  <p
    ref={ref}
    className={cn("text-sm text-neutral-text-secondary", className)}
    {...props}
  />
))
FielCardDescription.displayName = "FielCardDescription"

const FielCardContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn("pt-0", className)} {...props} />
))
FielCardContent.displayName = "FielCardContent"

const FielCardFooter = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("flex items-center pt-4", className)}
    {...props}
  />
))
FielCardFooter.displayName = "FielCardFooter"

export { FielCard, FielCardHeader, FielCardFooter, FielCardTitle, FielCardDescription, FielCardContent }