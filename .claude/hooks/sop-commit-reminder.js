// PreToolUse reminder: fires when a shell command contains `git commit`,
// injecting a non-blocking SOP routing check into the agent's context.
let raw = "";
process.stdin.on("data", (c) => (raw += c));
process.stdin.on("end", () => {
  let cmd = "";
  try {
    cmd = JSON.parse(raw)?.tool_input?.command ?? "";
  } catch {
    process.exit(0); // ponytail: unparseable input = no reminder, never block work
  }
  if (/\bgit\s+commit\b/.test(cmd)) {
    process.stdout.write(
      JSON.stringify({
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          additionalContext:
            "SOP check: was Tier/Type stated in the opening response and the matching sop-* route skill followed for this work? If not, stop and route per the CLAUDE.md router before committing.",
        },
      }),
    );
  }
  process.exit(0);
});
