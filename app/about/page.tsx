import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "About",
  description: "About this site.",
};

export default function AboutPage() {
  return (
    <main className="flex flex-1 flex-col items-center justify-center gap-8 p-8">
      <section className="flex w-full max-w-2xl flex-col gap-4">
        <h2 className="font-sans text-lg font-semibold tracking-tight">
          About
        </h2>
        <p className="text-muted-foreground text-sm">
          This page is a Server Component with no{" "}
          <code>&quot;use client&quot;</code> directive. Static by default —
          Next will prerender it at build time. To opt in to per-request
          rendering, export{" "}
          <code className="bg-muted rounded px-1 py-0.5 font-mono text-xs">
            const dynamic = &quot;force-dynamic&quot;
          </code>{" "}
          or call a dynamic API like <code>cookies()</code> or{" "}
          <code>headers()</code>.
        </p>
        <p className="text-muted-foreground text-sm">
          Adding more routes: create a folder under <code>app/</code> with a{" "}
          <code>page.tsx</code>. Folders in brackets like <code>[slug]</code>{" "}
          become dynamic segments.
        </p>
      </section>
    </main>
  );
}
