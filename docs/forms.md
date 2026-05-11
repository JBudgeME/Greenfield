# Forms

Forms use `react-hook-form` for state, `zod` for schema + inferred TS types, and `@hookform/resolvers/zod` to bridge them.

When adding the shadcn Form primitive, use `bunx shadcn@latest add form` rather than hand-rolling — it wires up `<Form>`, `<FormField>`, `<FormLabel>`, etc. correctly.

Define one `z.object({...})` schema, infer the type with `z.infer<typeof schema>`, and pass `zodResolver(schema)` to `useForm`.
