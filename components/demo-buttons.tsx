"use client";

import { toast } from "sonner";

import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

export function DemoButtons() {
  return (
    <div className={cn("flex flex-wrap gap-2")}>
      <Button onClick={() => toast.success("It works.")}>Show toast</Button>
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
  );
}
