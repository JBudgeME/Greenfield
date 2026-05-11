"use client";

import { toast } from "sonner";

import { Button } from "@/components/ui/button";
import { ThemeToggle } from "@/components/theme-toggle";
import { cn } from "@/lib/utils";

export default function Home() {
  return (
    <main className="flex flex-1 flex-col items-center justify-center gap-8 p-8">
      <header className="flex w-full max-w-2xl items-center justify-between">
        <h1 className="font-sans text-2xl font-semibold tracking-tight">
          Hello, world
        </h1>
        <ThemeToggle />
      </header>

      <section className="flex w-full max-w-2xl flex-col gap-4">
        <p className="text-muted-foreground text-sm">
          Next.js 16 + React 19 + Tailwind v4 + shadcn/ui. Edit{" "}
          <code className="bg-muted rounded px-1 py-0.5 font-mono text-xs">
            app/page.tsx
          </code>{" "}
          to get started.
        </p>

        <div className={cn("flex flex-wrap gap-2")}>
          <Button onClick={() => toast.success("It works.")}>
            Show toast
          </Button>
          <Button
            variant="outline"
            onClick={() => toast.info("Theme toggles in the corner.")}
          >
            Info toast
          </Button>
          <Button
            variant="destructive"
            onClick={() => toast.error("Something went wrong.")}
          >
            Error toast
          </Button>
        </div>
      </section>
    </main>
  );
}
