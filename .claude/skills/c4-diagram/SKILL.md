---
name: c4-diagram
description: Use when creating or changing a Structurizr DSL workspace, or when asked to review a C4 diagram. Drafts the DSL, loops on validate and inspect until clean, then checks the c4model.com review checklist.
---

# C4 diagrams as Structurizr DSL

One folder per workspace, each holding a `workspace.dsl`. The DSL is the source of truth. Never hand-edit exported PNG, SVG or Mermaid files.

## Loop

1. Read the code or docs the diagram describes. Every element and relationship must come from something you read. If you did not read it, leave it out, or follow "Facts you cannot verify" below.
2. If `<folder>/workspace.dsl` already exists, run `validate` and `inspect` on it exactly as it is, before you change anything. Quote what they report. Do not correct a mistake by eye and then check the corrected text: the tool's message is the evidence that the check works, and it shows what was wrong.
3. Write or edit `<folder>/workspace.dsl`.
4. Validate and inspect. Use the Structurizr MCP tools `validate` and `inspect` if the `structurizr` MCP server is connected, otherwise run the CLI:

   ```bash
   docker run --rm -v "$PWD":/usr/local/structurizr structurizr/structurizr:2026.09.19-playwright validate -workspace <folder>/workspace.dsl
   docker run --rm -v "$PWD":/usr/local/structurizr structurizr/structurizr:2026.09.19-playwright inspect  -workspace <folder>/workspace.dsl -severity error,warning
   ```

5. Repeat until `validate` prints nothing and `inspect` reports no `error` or `warning`.
6. Run the checklist below. These are judgement calls the tools cannot make.

## Reading the tool output

- The MCP `validate` tool returns `isError: false` even when the DSL is broken. Read the text. Anything other than `OK` is a failure.
- The MCP `inspect` tool does the opposite: it returns `isError: true` when the DSL does not parse, with the same message as `validate`.
- The CLI `inspect` exit code is the number of violations shown. `0` means clean.
- The MCP `inspect` tool also lists `IGNORE` entries. Those are suppressed on purpose and are not failures.

## Checklist (from c4model.com)

General
- Every view has a title and a description that state its type and scope.
- Each container or component view covers exactly one software system.
- A key is exported with each diagram (the export command writes `<view>-key.png`).

Elements
- Every element has a name, a description, and a technology where it applies (containers, components).
- One abstraction per thing. The same system must not be a container in one view and a software system in another.
- People are people. Software, agents and bots are software systems.

Relationships
- Every arrow is labelled with its intent, and the label reads correctly in the arrow's direction.
- Avoid generic labels such as "Uses". Say what the arrow does, for example "Views and updates data using".
- Inter-process arrows carry the protocol, for example `HTTPS` or `SQL/TCP`.

## Facts you cannot verify

`inspect` only checks that a description or technology is present, not that it is true. Any text satisfies it, so a green check says nothing about accuracy.

When you were not given a fact and cannot read it from the code, do not invent it. Put the exact text `TODO: confirm` in the field, for example a container technology of `"TODO: confirm"`. In your final report, list every `TODO: confirm` you left and say what is needed to resolve it. Never present a workspace with placeholders as finished.

## Suppressing a rule

Only suppress a rule when the rule is wrong for this workspace, never to get a green build. Put the reason next to it.

```
properties {
    "structurizr.inspection.model.softwaresystem.documentation" "ignore"
}
```
