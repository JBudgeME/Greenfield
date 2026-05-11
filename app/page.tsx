import { DemoButtons } from "@/components/demo-buttons";

export default function Home() {
  const renderedAt = new Date().toISOString();

  return (
    <main className="flex flex-1 flex-col items-center justify-center gap-8 p-8">
      <section className="flex w-full max-w-2xl flex-col gap-4">
        <h2 className="font-sans text-lg font-semibold tracking-tight">
          Hello, world
        </h2>
        <p className="text-muted-foreground text-sm">
          Next.js 16 + React 19 + Tailwind v4 + shadcn/ui. Edit{" "}
          <code className="bg-muted rounded px-1 py-0.5 font-mono text-xs">
            app/page.tsx
          </code>{" "}
          to get started.
        </p>
        <p className="text-muted-foreground text-xs">
          Server-rendered at{" "}
          <time dateTime={renderedAt} className="font-mono">
            {renderedAt}
          </time>
          . This page is a Server Component; the buttons below are a client
          island.
        </p>

        <DemoButtons />
      </section>
    </main>
  );
}
