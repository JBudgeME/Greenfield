import Link from "next/link";

import { ThemeToggle } from "@/components/theme-toggle";

const links = [
  { href: "/", label: "Home" },
  { href: "/about", label: "About" },
] as const;

export function SiteNav() {
  return (
    <header className="border-border/40 border-b">
      <div className="mx-auto flex w-full max-w-2xl items-center justify-between gap-4 p-4">
        <nav className="flex items-center gap-4 text-sm">
          <Link href="/" className="font-semibold tracking-tight">
            Greenfield
          </Link>
          <ul className="text-muted-foreground flex items-center gap-3">
            {links.map((link) => (
              <li key={link.href}>
                <Link
                  href={link.href}
                  className="hover:text-foreground transition-colors"
                >
                  {link.label}
                </Link>
              </li>
            ))}
          </ul>
        </nav>
        <ThemeToggle />
      </div>
    </header>
  );
}
