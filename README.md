# Structurizr diagrams as code, AI edition

Companion code for the blog post on [codingwithtaz.blog](https://codingwithtaz.blog/). It is the 2026 update of [Git to Structurizr Cloud](https://codingwithtaz.blog/2022/08/21/git-to-structurizr-cloud/) and its repo, [gitToStructurizr](https://github.com/Tazmainiandevil/gitToStructurizr).

Same idea as before: several [C4](https://c4model.com/) diagrams as code in one Git repo, one folder per workspace, built by a pipeline. What changed:

| 2022 | Now |
|---|---|
| Push to Structurizr Cloud | Nothing is pushed. The cloud service is retired, so the pipeline produces the diagrams itself. |
| `structurizr/cli` image, `structurizr-cli push` | `structurizr/structurizr` image with `validate`, `inspect` and `export` |
| Structurizr Lite for preview | Structurizr Local |
| Graphviz and Puppeteer for SVG and PNG | `export -format png\|svg\|mermaid`, with the `-playwright` image |
| `publish.ps1` and per-workspace secrets | `scripts/workspaces.sh` and no secrets |
| Nothing checked the diagram | `validate` and `inspect` fail the build |
| Hand-written DSL | Claude drafts the DSL and loops on the checks (see below) |

## Layout

```text
MyProject/workspace.dsl           one folder per workspace, same as the 2022 post
OtherProject/workspace.dsl
docs/before/                      the 2022 DSL files, kept to show what inspect catches
scripts/workspaces.sh             lists workspace folders, or only the changed ones
.github/workflows/ci.yml          validate and inspect on pull requests, export on main
.claude/skills/c4-diagram/        the Claude skill: draft, check, review
.mcp.json                         connects Claude Code to the Structurizr MCP server
```

Folder names must not contain spaces. They are used as matrix values and artifact names.

## Run the checks locally

You only need Docker. These are the same commands the pipeline runs.

```bash
IMAGE=structurizr/structurizr:2026.09.19-playwright

docker run --rm -v "$PWD":/usr/local/structurizr $IMAGE validate -workspace MyProject/workspace.dsl
docker run --rm -v "$PWD":/usr/local/structurizr $IMAGE inspect  -workspace MyProject/workspace.dsl -severity error,warning
docker run --rm -v "$PWD":/usr/local/structurizr $IMAGE export   -workspace MyProject/workspace.dsl -format png -output diagrams/MyProject
```

`validate` checks the DSL parses. `inspect` checks the model against rules such as "every container has a description and a technology". The `inspect` exit code is the number of violations shown, so `0` means clean.

Every export writes a title on the diagram and a separate `<view>-key` image for the legend.

### Before and after

`docs/before/MyProject.workspace.dsl` is the 2022 file. It is valid DSL and `validate` passes, but `inspect` reports 14 errors: no descriptions, no technologies, no scope, and containers that are on no view.

```bash
docker run --rm -v "$PWD":/usr/local/structurizr $IMAGE inspect -workspace docs/before/MyProject.workspace.dsl -severity error
```

`MyProject/workspace.dsl` fixes all of them, and adds a container view.

### Tuning inspect

Every rule defaults to `error`. A workspace `properties` block changes that. These two are set to `ignore` in the examples because the examples have no documentation or decision records:

```
properties {
    "structurizr.inspection.model.softwaresystem.documentation" "ignore"
    "structurizr.inspection.model.softwaresystem.decisions" "ignore"
}
```

Only suppress a rule when the rule is wrong for the workspace. Do not suppress it to get a green build. The rule IDs are in the [Structurizr inspections docs](https://docs.structurizr.com/workspaces/inspections).

## The pipeline

[`.github/workflows/ci.yml`](.github/workflows/ci.yml) has three jobs:

1. **discover** runs `scripts/workspaces.sh`. On a pull request it returns every workspace. On a push to `main` it returns only the workspaces whose files changed. It returns every workspace if the pipeline or the script changed, or if the previous commit is unknown (a new branch).
2. **check** runs `validate` and `inspect` for each workspace. Any violation fails the job.
3. **export** runs on pushes to `main` after the checks pass. It writes PNG, SVG and Mermaid files and uploads them as one artifact per workspace.

The old pipeline skipped pull requests. This one runs the checks on them, so a bad diagram is caught before it merges.

## Claude in the loop

Two pieces, both optional:

**A skill.** [`.claude/skills/c4-diagram/SKILL.md`](.claude/skills/c4-diagram/SKILL.md) tells Claude Code how to work on a workspace: read the real code first, write the DSL, run `validate` and `inspect` until they are clean, then check the parts the tools cannot judge (one abstraction per thing, labels that match the arrow direction, people versus software).

**The Structurizr MCP server.** It gives Claude `validate`, `inspect`, `parse` and the `export-*` tools directly. Start it, then open the repo in Claude Code, which reads [`.mcp.json`](.mcp.json):

```bash
docker run -d --rm --name structurizr-mcp -p 3000:3000 -e PORT=3000 structurizr/mcp -dsl -mermaid -plantuml
```

Things worth knowing, all seen while writing the post:

- Every tool takes the DSL as text. The server cannot read your repo, so Claude reads the file and passes it in.
- The `validate` tool returns `isError: false` even when the DSL is broken. The error is in the text. Anything other than `OK` is a failure.
- The `inspect` tool also lists `IGNORE` entries. Those are the rules you suppressed, not failures.
- Run the server locally. The hosted `mcp.structurizr.com` instance would send your model to a third party, which matters for anything internal.

## Not covered

- Pushing to a Structurizr server. The `push` and `pull` commands exist, and `server` needs a licence for the prebuilt binaries. This repo does not use them.
- Hosting the exported diagrams. The pipeline uploads artifacts. Publishing them to Pages or a wiki is a further step.

## Licence

[MIT](LICENSE)
