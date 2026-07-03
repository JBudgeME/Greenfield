#!/usr/bin/env bun
// Bucketed view of open GitHub issues. Spec: .claude/skills/open-work/SKILL.md
// Usage: bun scripts/open-work.ts [--from-json <path>] [--self-test]

type Issue = { number: number; title: string; labels: { name: string }[] };

const BUCKETS: Record<string, string[]> = {
  Actionable: [
    "ready-for-agent",
    "ready-for-human",
    "needs-triage",
    "needs-info",
  ],
  Queued: ["queued"],
  "Watch-only": ["watch-only"],
  Blocked: ["blocked"],
};
const SEVERITY_ORDER = ["severity:high", "severity:medium", "severity:low"];

export function classify(issue: Issue): string {
  const names = issue.labels.map((l) => l.name);
  for (const [bucket, labels] of Object.entries(BUCKETS)) {
    if (labels.some((l) => names.includes(l))) return bucket;
  }
  // ponytail: no recognized open-state triage label = drift; re-triage it.
  return "Unknown";
}

export function severityRank(issue: Issue): number {
  const names = issue.labels.map((l) => l.name);
  const i = SEVERITY_ORDER.findIndex((s) => names.includes(s));
  return i === -1 ? SEVERITY_ORDER.length : i;
}

function render(issues: Issue[]): string {
  const grouped = new Map<string, Issue[]>(
    [...Object.keys(BUCKETS), "Unknown"].map((b) => [b, []]),
  );
  for (const issue of issues) grouped.get(classify(issue))!.push(issue);

  const out: string[] = [];
  for (const [bucket, items] of grouped) {
    if (bucket === "Unknown" && items.length === 0) continue; // Unknown only when drift exists
    items.sort((a, b) => severityRank(a) - severityRank(b));
    out.push(`## ${bucket} (${items.length})`);
    for (const i of items) {
      const tags = i.labels
        .map((l) => l.name)
        .filter((n) => n.startsWith("kind:") || n.startsWith("severity:"))
        .join(", ");
      out.push(`- #${i.number} ${i.title}${tags ? ` [${tags}]` : ""}`);
    }
    out.push("");
  }
  return out.join("\n");
}

function selfTest() {
  const mk = (n: number, ...labels: string[]): Issue => ({
    number: n,
    title: `t${n}`,
    labels: labels.map((name) => ({ name })),
  });
  console.assert(
    classify(mk(1, "ready-for-agent", "kind:issue")) === "Actionable",
  );
  console.assert(classify(mk(2, "queued")) === "Queued");
  console.assert(classify(mk(3, "kind:prd")) === "Unknown");
  const sorted = [
    mk(4, "blocked", "severity:low"),
    mk(5, "blocked", "severity:high"),
  ].sort((a, b) => severityRank(a) - severityRank(b));
  console.assert(sorted[0].number === 5);
  console.assert(!render([mk(1, "ready-for-agent")]).includes("Unknown"));
  console.log("self-test ok");
}

if (import.meta.main) {
  const args = Bun.argv.slice(2);
  if (args[0] === "--self-test") {
    selfTest();
  } else {
    const fromJson = args.indexOf("--from-json");
    const issues: Issue[] =
      fromJson !== -1
        ? await Bun.file(args[fromJson + 1]).json()
        : await new Response(
            Bun.spawn([
              "gh",
              "issue",
              "list",
              "--state",
              "open",
              "--json",
              "number,title,labels",
            ]).stdout,
          ).json();
    console.log(render(issues));
  }
}
