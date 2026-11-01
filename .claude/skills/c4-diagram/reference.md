# C4 abstraction rules

Adapted from c4model.com by Simon Brown (github.com/simonbrowndotje/c4model), licensed [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Reworded and condensed. Further reading: *The C4 model for visualising software architecture*.

Read this before choosing what is a person, software system, container or component.

## Software system

Something one team builds, owns and can see inside. Often one repository, often deployed together. Other systems the team depends on or does not own are also software systems.

Not software systems: bounded contexts, business capabilities, product domains, feature teams, tribes, squads.

## Container

An application or data store that must be running for the system to work. A container is a runtime boundary. It is not Docker.

- Server-side web app, SPA in the browser, desktop app, mobile app, console app or batch process, serverless function, shell script.
- Database schema (two schemas are two containers, even on one server), blob store, file system.
- A server-rendered site that mostly returns HTML is one container. A server that delivers a significant SPA is two: the server and the browser app.
- JARs, assemblies, DLLs and modules are not containers. They organise code inside one.
- A cloud service you own the contents of (an S3 bucket, an RDS schema) is a container, even though someone else hosts it.
- Omit log files. Show a file system only when it holds business-critical data.

## Component

A group of related functionality behind a well-defined interface, inside one container. Not separately deployable: all components in a container run in one process.

- Packages, namespaces, folders, JARs and assemblies are usually not components.
- Frameworks, libraries and database drivers are technology choices of a component, never components.
- Components should be real things visible in the code. Do not invent logical components that exist only on the diagram.
- Calls between components are usually in-process, so they need no technology label.
- Shared helper and utility classes do not need their own component.

## Microservices and serverless

Ownership decides.

- One team owns the whole system: each service is a group of containers (an API plus its schema), all inside one software-system boundary. Colour or box the pair, do not make a "microservice" element.
- Services owned by other teams: each is a software system you cannot see inside.
- The same service seen from its own team's view is promoted to a software system with its own containers.

Serverless functions you build are containers.

## Queues, topics and message buses

- Do not model the message bus or broker as a container. The hub-and-spoke picture hides coupling between producers and consumers.
- Model each queue or topic as a container (a data store).
- Alternative for true point-to-point links: leave the queue out and put its name in the arrow label. Pick one style per workspace.
- Use arrow direction to match the story: "Sends messages to" for queues, "Publishes events to" and "Subscribes to" for topics.
- When services are separate software systems, ask who owns the queue. Ownership changes the diagram.

## Do not add abstraction levels

Subsystems, layers, modules, libraries and bounded contexts are organisational groupings, not abstractions. If the model seems to need another level, check that the existing terms were used correctly first.

## Keep views small

If a view has more than a handful of elements, split it into several views at the same level, each focused on one service, feature or area. A view per service showing its inbound and outbound neighbours is a good pattern. Do not widen the canvas.

## Component views from code

Component views go stale fastest. Derive them from the code, not from memory. Code (class) views are not worth creating: the IDE shows them on demand.
