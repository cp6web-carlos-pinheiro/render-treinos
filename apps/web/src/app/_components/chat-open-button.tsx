"use client";

import { Sparkles } from "lucide-react";
import { useQueryStates, parseAsBoolean, parseAsString } from "nuqs";

export function ChatOpenButton() {
  const [, setChatParams] = useQueryStates({
    chat_open: parseAsBoolean.withDefault(false),
    chat_initial_message: parseAsString,
    chat_event_id: parseAsString,
  });

  return (
    <button
      onClick={() => setChatParams({ chat_open: true })}
      className="rounded-full bg-primary p-4 cursor-pointer"
    >
      <Sparkles className="size-6 text-primary-foreground" />
    </button>
  );
}
