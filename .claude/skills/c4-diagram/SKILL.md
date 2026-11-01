---
name: c4-diagram
description: Use when creating, changing or reviewing a C4 model architecture diagram (system context, container, component, deployment) written as a Structurizr DSL workspace. Drafts the DSL, loops on validate and inspect until clean, then checks the c4model.com review checklist.
---

# C4 diagrams as Structurizr DSL

One folder per workspace, each holding a `workspace.dsl`. The DSL is the source of truth. Never hand-edit exported PNG, SVG or Mermaid files.

## Choose the views

Read [reference.md](reference.md) before modelling. It defines what is a software system, container and component, and how to model microservices and queues.

Create a system context view and a container view. Add others only when asked, or when they clearly pay for themselves:

- Component: one container at a time. Skip it for databases and simple services. Derive it from the code.
- Code: do not create.
- Dynamic: only for an interesting or complicated feature.
- Deployment: one per environment. Keep Docker, Kubernetes and cloud details out of container views.
- System landscape: when several systems are in scope.

Work from context down to containers, then deeper only if needed.

C4 suits bespoke software systems. It fits libraries, frameworks, SDKs, embedded firmware and heavily customised packages (SAP, Salesforce) poorly. If the target is one of those, say so, then stop at context and container views or diagram a usage example.

## Loop

1. Read the code or docs the diagram describes. Every element and relationship must come from something you read or were told. If you did neither, leave it out, or follow "Facts you cannot verify" below.
2. If `<folder>/workspace.dsl` already exists, run `validate` and `inspect` on it exactly as it is, before you change anything. Quote what they report. Do not correct a mistake by eye and then check the corrected text: the tool's message is the evidence that the check works, and it shows what was wrong.
3. Write or edit `<folder>/workspace.dsl`.
4. Validate and inspect. Use the Structurizr MCP tools `validate` and `inspect` if the `structurizr` MCP server is connected, otherwise run the CLI. Take `IMAGE` from `STRUCTURIZR_IMAGE` in `.github/workflows/ci.yml` so the local check matches CI:

   ```bash
   docker run --rm -v "$PWD":/usr/local/structurizr "$IMAGE" validate -workspace <folder>/workspace.dsl
   docker run --rm -v "$PWD":/usr/local/structurizr "$IMAGE" inspect  -workspace <folder>/workspace.dsl -severity error,warning
   ```

   If neither the MCP server nor Docker is available, say the DSL is unchecked. Never describe it as clean.

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
- A container view shows the same people and software systems as the context view, and draws the system boundary. Names and element placement match across views.
- The diagram makes sense without a narrative. If it needs one, fix the diagram.
- Large views are split into several focused views at the same level.

Elements
- Every element has a name, a description, and a technology where it applies (containers, components).
- Descriptions say what the element does. No generic text such as "business logic".
- One abstraction per thing. The same system must not be a container in one view and a software system in another.
- People are people. Software, agents and bots are software systems.
- Acronyms are avoided or explained. Technology acronyms such as HTTPS and SQL are fine.
- Colours, shapes, borders and sizes mean something the key explains. Colour only supplements meaning and must still work in black and white. Boxes are about the same size unless size is the point.

Relationships
- Every arrow is labelled with its intent, and the label reads correctly in the arrow's direction.
- Every arrow is one direction, and arrows point initiator to receiver throughout, or follow data flow throughout. Do not mix.
- End the label with a preposition ("reads from and writes to") and say the sentence aloud. "The web application reads from and writes to the database" works. "reads and writes" does not.
- Avoid generic labels such as "Uses". Say what the arrow does, for example "Views and updates data using".
- One summarised arrow per pair of elements. Show finer detail in a dynamic view.
- Inter-process arrows in container views carry the protocol, for example `HTTPS` or `SQL/TCP`. Context-view arrows and in-process component calls do not need one.
- Line styles and arrowheads are explained in the key.

## Facts you cannot verify

`inspect` only checks that a description or technology is present, not that it is true. Any text satisfies it, so a green check says nothing about accuracy.

Write descriptions and relationship verbs from the facts you were given and the names of the elements. "Exposes billing functionality as a REST API" follows from "a Go REST API for billing", so write it. Never fall back to "Uses": take the verb from the facts, for example "Works with billing data using". Reserve the placeholder for facts that are genuinely absent, such as a protocol, a version or a purpose nobody stated.

When you were not given a fact and cannot read it from the code, do not invent it. Put the exact text `TODO: confirm` in the field, for example a container technology of `"TODO: confirm"`. In your final report, list every `TODO: confirm` you left and say what is needed to resolve it. Never present a workspace with placeholders as finished.

## Suppressing a rule

Only suppress a rule when the rule is wrong for this workspace, never to get a green build. Put the reason next to it. Suppress a rule only after `inspect` has reported it. Never add suppressions in advance.

The `documentation` and `decisions` rules ask for `!docs` and `!adrs` on a software system that has containers. If the project has documentation or decision records, attach them with `!docs <folder>` and `!adrs <folder>` inside the `softwareSystem` block. The path is relative to the DSL file. If it has none, suppress the rule on that software system only, not for the whole workspace, and list it as a gap in your final report. Do not write documentation or decisions to satisfy the rule.

```
properties {
    "structurizr.inspection.model.softwaresystem.documentation" "ignore"
}
```
