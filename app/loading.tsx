export default function Loading() {
  return (
    <main className="flex flex-1 items-center justify-center p-8">
      <div
        role="status"
        aria-label="Loading"
        className="size-6 animate-spin rounded-full border-2 border-muted border-t-foreground"
      />
    </main>
  );
}
