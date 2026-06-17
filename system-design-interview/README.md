# System Design Interview — Senior Mobile Engineer Guide

> **Who this is for:** A Flutter/mobile developer who knows client-side deeply but has limited backend exposure. Every backend concept is explained from first principles, not assumed.
> **Difficulty target:** Senior IC. You're expected to drive the design, articulate trade-offs, and know _why_ each choice exists.

---

## Table of Contents

| # | Module | Why it matters |
|---|--------|---------------|
| 1 | [The Interview Framework](#module-1-the-interview-framework) | Structure that signals seniority |
| 2 | [Back-of-Envelope Estimation](#module-2-back-of-envelope-estimation) | Every interview needs numbers |
| 3 | [Database Fundamentals](#module-3-database-fundamentals) | The biggest gap for mobile devs |
| 4 | [Caching](#module-4-caching) | Appears in every design |
| 5 | [APIs & Communication Patterns](#module-5-apis--communication-patterns) | You know REST — go deeper |
| 6 | [Scalability Patterns](#module-6-scalability-patterns) | How systems survive real traffic |
| 7 | [Message Queues & Async Processing](#module-7-message-queues--async-processing) | Unfamiliar to most mobile devs |
| 8 | [Storage Systems](#module-8-storage-systems) | S3, CDN, data lakes |
| 9 | [Complete Design Walkthroughs](#module-9-complete-design-walkthroughs) | Apply everything end-to-end |
| 10 | [Mobile-Specific System Design](#module-10-mobile-specific-system-design) | Your competitive edge |
| 11 | [Distributed Systems Patterns](#module-11-distributed-systems-patterns) | The terms architects name-drop |
| 12 | [Observability & Reliability Engineering](#module-12-observability--reliability-engineering) | How senior engineers own production |
| 13 | [Sensitive Data & Compliance in System Design](#module-13-sensitive-data--compliance-in-system-design) | Non-negotiable in regulated domains |

---

## Module 1: The Interview Framework

> **Priority: CRITICAL.** Structure is how the interviewer judges seniority before you've said a single technical word. The candidate who stays calm, asks good questions, thinks out loud, and draws incrementally will always outscore the one who immediately dumps a "correct" architecture diagram in silence.

A system design interview is **not** a trivia test. There is no single correct answer. The interviewer is watching *how you think*, not whether you arrive at a specific design. Two candidates can propose completely different architectures and both score highly — if they both reason clearly, acknowledge trade-offs, and adapt when pushed.

---

### 1.0 The High-Level Anatomy of a Production App

> **Why this section is here:** Before you can design a system, you need a mental model of what a real production app looks like. The transcript opens with this — and it's the boxes you should be able to draw in 30 seconds if the interviewer asks "give me the standard architecture."

> **Senior signal — anchor in the system design problem space:** System design is the discipline of translating functional and non-functional requirements into a blueprint, then making tradeoffs on scalability, cost, security, and complexity. That framing is what makes the discipline senior-level work: the answer is never a single architecture, it's the architecture whose tradeoffs match *these* requirements. Senior candidates say it explicitly: "There is no single right answer — only the right answer for *this* problem at *this* scale."

When a senior engineer describes a "production-ready app," they mean a system that has more than just the app and database. Here's the full box diagram, with each box's job:

```
                      ┌────────────────────────────────────────┐
                      │         Logging & Monitoring           │
                      │  (Sentry, Datadog, ELK, CloudWatch)   │
                      │  Stores logs OFF the production box   │
                      └────────────────┬───────────────────────┘
                                       │ (triggers)
                                       ▼
            ┌──────────────────────────────────────────────┐
            │   CI/CD Pipeline                              │
            │   (GitHub Actions, Jenkins)                    │
            │   repo → tests → staging → canary → prod      │
            └──────────────────┬─────────────────────────────┘
                               │ deploys
                               ▼
   ┌──────────┐       ┌──────────────────┐       ┌──────────────────┐
   │  Users   │──────►│ Load Balancer /  │──────►│  App Servers     │
   │(web/mobile)│     │ Reverse Proxy    │       │  (auto-scaling   │
   └──────────┘       │  (NGINX, ALB)    │       │   group)         │
                      └──────────────────┘       └────────┬─────────┘
                                                          │
                              ┌───────────────────────────┤
                              │                           │
                              ▼                           ▼
                      ┌──────────────────┐      ┌──────────────────┐
                      │  Cache           │      │  External        │
                      │  (Redis)         │      │  Storage         │
                      └──────────────────┘      │  (S3, separate   │
                                                │   network)       │
                                                └──────────────────┘
                                                          │
                                                          ▼
                      ┌──────────────────────────────────────────────┐
                      │   Primary Database + Read Replicas            │
                      │   (PostgreSQL, MongoDB)                        │
                      └──────────────────────────────────────────────┘
```

#### What Each Box Does

```
CI/CD pipeline:
  Code in repo → automated tests → staging deploy → canary deploy → full prod.
  Tools: GitHub Actions, Jenkins, GitLab CI, CircleCI, Bitrise.
  No human clicks "deploy" in a healthy system.

Load balancer / reverse proxy:
  First thing requests hit. Distributes traffic across app servers,
  terminates TLS, may do gzip and WAF inspection.
  Could be a cloud LB (ALB, GCP LB) or self-hosted (NGINX, HAProxy).

App servers:
  Stateless. Auto-scaled based on CPU / request rate / queue depth.
  Multiple servers → any one dying is a non-event.

Cache (Redis, Memcached):
  Fronts the database for hot reads, holds sessions, holds rate-limit
  counters, sometimes pub/sub for coordination.

External storage (S3, GCS, Azure Blob):
  Files, images, videos, backups. Lives on a separate network from
  the app servers. Accessed via SDK or signed URLs.

Database + read replicas:
  Source of truth. Writes go to the primary. Reads scale out to replicas.
  (When this isn't enough, you shard. See Module 3.6.)

Logging & monitoring:
  Logs, metrics, traces flow out of every other box into a separate
  observability stack. Sentry for front-end errors, PM2/CloudWatch
  for back-end, ELK/Datadog for centralized search.

Alerting:
  When the monitoring stack detects an anomaly (error rate spike,
  latency cliff, queue depth growing), it pushes a notification
  → Slack channel, PagerDuty page, or status page update.
```

#### The Operational Loop (What Happens When Things Break)

```
1. ALERT FIRES       PagerDuty / Slack notification
                     "Error rate on /api/bookings > 5% for 5 min"
2. ON-CALL ACKS      Engineer opens the alert thread
3. INVESTIGATE       Check dashboards, tail logs, check recent deploys
                     (50% of incidents are "what changed?")
4. REPRODUCE         In staging — never debug in production directly
5. MITIGATE          Roll back, disable a feature flag, drain a node
                     (stop the bleeding before the root-cause fix)
6. HOTFIX / ROLLBACK Quick patch to restore service
7. ROOT-CAUSE FIX    Proper fix through the normal pipeline
8. POSTMORTEM        Blameless write-up: what happened, why,
                     what we'll do to prevent it
```

> **Senior signal:** When you start a design interview, you can say *"before I draw, let me make sure I'm thinking about this as a production system, not just an app — so the boxes I should always have in my head are CI/CD, the LB, the app tier, the cache, the database, external storage, and observability/alerting. For our design today, which of these do you most want to focus on?"* This is the senior opener. It signals you know the full landscape.

> **Why this is the right mental model:** It's the boxes you'd see on a whiteboard at any architecture review. It's the boxes the interviewer is mentally drawing too. Naming them up front shows you're playing the same game.

#### Mobile-Specific Add-On

Because this guide targets mobile engineers, two more boxes belong on the diagram:

```
Push notification service (APNs, FCM):
  Out-of-band channel for waking the app, delivering critical updates
  (appointment reminders, password resets). The app's only way to
  receive messages when it's not running.

CDN (Cloudflare, Fastly, CloudFront, Akamai):
  Serves your static assets (images, JS bundles, videos) from
  edge locations close to the user. Cuts first-paint time dramatically.
```

These were covered in detail in Module 4 (caching) and Module 10 (mobile), but they belong in your "default architecture" mental model.

#### 1.0.1 High-Level vs Low-Level System Design

> **Interview relevance: Differentiator.** A senior signal — naming the altitude early shows you've seen both modes. Unlikely to be asked directly, but if the interviewer pushes you in either direction, knowing this distinction lets you pivot smoothly.

The interview itself opens with a critical distinction: **what altitude are you designing at?** Interviewers test this by pushing you either up (toward infrastructure) or down (toward modules) at some point in the conversation.

```
HIGH-LEVEL (what an interview tests):
  Front-end ←→ API Gateway ←→ App Tier ←→ Data Tier (DB + Cache + Storage)
  Plus: load balancers, async queues, CDN, observability, CI/CD.

LOW-LEVEL (what an HLD/LLD split tests):
  Within a single service:
    Controllers → Services → Repositories → Data Sources
    OR: API layer → Domain layer → Infrastructure layer (Clean/Hexagonal)
    OR: handlers → use-cases → adapters
  Plus: in-process concurrency (threads, actors, async/await),
  module boundaries, in-process caching, internal interfaces.
```

| | High-level design | Low-level design |
|---|---|---|
| Granularity | Systems, services, queues, databases | Classes, modules, threads, methods |
| Drives | Service boundaries, data flow, infra choices | APIs, dependency direction, in-process concurrency |
| What it answers | "How do these boxes talk, and how do they fail?" | "How is this service built, and how is it testable?" |
| Typical interview | System design round (45 min) | Coding round, machine coding, OOD |
| In this course | Modules 1, 6, 7, 11 | Out of scope (see your Flutter/clean-architecture guide) |

> **Senior signal:** When the interviewer says "design a chat system," the first sentence out of your mouth should disambiguate the altitude. Try: *"I'll design this at the high level — the services, queues, and storage. If you'd like, I can zoom into a specific service and sketch the modules."* This single sentence signals you know the two modes and can move between them.

> **What this course covers:** This course is overwhelmingly high-level system design for system design interviews. When we mention things like "controller vs service" it is for *interview framing*, not implementation coaching.

#### 1.0.2 The Availability Ladder — How Much Uptime Do You Actually Need?

> **Interview relevance: Core.** A standard "how much do you really need" question. Pair with the SLO/SLA module. Candidates who default to "99.999% always" lose points; candidates who propose 99.9% for an MVP and explain why win.

There is a critical point about the cost of uptime. Your architecture should match the *smallest* availability number the business can live with. Choosing 5-nines when 3-nines would do is a senior mistake in the opposite direction — over-engineering for requirements that aren't there.

```
99%      (2 nines)   ≈ 3.65 days downtime/year
99.9%    (3 nines)   ≈ 8.7 hours downtime/year
99.99%   (4 nines)   ≈ 52 minutes downtime/year
99.999%  (5 nines)   ≈ 5 minutes downtime/year
```

**What each rung looks like architecturally:**

```
99%      (one machine, one region, no replication)
            → A single EC2 with a managed database. Tolerate ~3 days of
              downtime a year. Fine for internal tools, hobby projects,
              weekend hackathons.
            → Concrete: a status page for a college class project.

99.9%    (replication within a region, managed failover)
            → Multi-AZ deployment with RDS Multi-AZ, an ALB, two app
              servers. Tolerate ~8 hours of downtime a year. Most
              "normal" SaaS apps live here.
            → Concrete: a B2B SaaS billing tool, internal admin
              dashboards, MVPs in production.

99.99%   (active-active in one region, multi-AZ DB, RPO ≈ 0)
            → Multi-AZ with synchronous replicas, automated failover,
              load-balanced stateless app tier, health-checked deploys.
              ~52 minutes downtime a year.
            → Concrete: a payment authorization service, an e-commerce
              checkout, a B2C product used 24/7.

99.999%  (multi-region active-active, automated failover, chaos-tested)
            → Active-active in at least two regions, async replication,
              traffic re-routing on regional failure, regular game days
              and chaos drills. ~5 minutes downtime a year.
            → Concrete: HFT order-matching, real-time ad bidding,
              emergency services dispatch, 911-equivalent systems.
```

> **Senior signal — refuse the "always 99.999%" trap:** When the interviewer says "design a chat app," the wrong answer is to default to 5-nines architecture. The right answer is to *ask* — or propose a 3-nines target and explain the tradeoff. The cost of 99.999% is roughly 10x the cost of 99.9%. Senior engineers don't pay for capacity they don't need.

#### 1.0.3 Multi-Tier Architecture — The Classical Decomposition

> **Interview relevance: Differentiator.** The vocabulary is "present" in target's existing diagram; the explicit tier names (presentation / business / data) are an extra framing that helps you remember to draw all 8 boxes. Useful but unlikely to be asked as a discrete topic.

Almost every production system is described in **tiers**. Even in a microservices world, the tiers are the layers of the *request path* inside a single service.

```
Three-tier (the classical decomposition):
  PRESENTATION TIER    — UI, client app, API gateway (request shape)
  LOGIC / APPLICATION  — business rules, validation, orchestration
  DATA TIER            — database, cache, blob store, search index

N-tier (what production actually looks like):
  PRESENTATION    — browser, mobile app
  EDGE / GATEWAY  — CDN, WAF, API gateway, auth at the edge
  APPLICATION     — stateless app servers (often several services)
  CACHE           — Redis, Memcached, CDN edge
  DATA            — primary DB + read replicas, sometimes a search index
  STORAGE         — S3-like object storage for blobs
  ASYNC           — message queue + workers for background work
  OBSERVABILITY   — logs, metrics, traces — wraps all of the above
```

> **Why tiers matter for the interview:** A common interviewer question is "draw the boxes." If you draw only 2 boxes (client + database), you look junior. If you draw 6–8 boxes (presentation, gateway, app, cache, DB, queue, storage, observability), you look like someone who has actually built systems. The multi-tier framing is the cleanest way to remember to draw *all* of them.

#### 1.0.4 The "Server" Is a Process, Not a Machine

> **Interview relevance: Differentiator.** Almost never asked directly, but it shows up whenever the interviewer pushes on "what do you mean by 'add a server'?" or "container vs VM vs serverless?" Knowing the unit you're scaling is a senior-signal word choice.

There is a deceptively important clarification: **a "server" is a process, not a physical box**. In modern deployments, the same machine can run many "servers" (containers, serverless functions), and a single "server" can be auto-scaled across many machines.

```
"Same thing" — what people mean by "server" in different contexts:

  Bare-metal:   a physical machine in a rack.
  VM:           a virtual machine on a host (EC2, Compute Engine).
  Container:    an isolated process sharing an OS kernel (Docker, K8s).
  Serverless:   a function-as-a-service (Lambda, Cloud Functions).

  In all four cases, the "server" — the thing that handles requests —
  is a *process* (or a fleet of identical processes), not a machine.
```

Why this matters in the interview: when you say "I'll add a server," the interviewer is checking whether you mean "I'll add a process / instance behind the load balancer" (correct, scales horizontally) or "I'll add a machine" (an operational detail, not the architectural one). State the unit you're scaling. Say: "I'll scale the *number of instances of the app process* behind the load balancer" rather than "I'll add a server."

---

### 1.1 The Full 45-Minute Map — What Happens When

Before anything else, internalize this timeline. You will use it to pace yourself so you don't spend 35 minutes on requirements and have no time to draw anything, or rush into a full architecture at minute 2.

```
┌─────────────────────────────────────────────────────────────────────┐
│  0–1 min   │ Receive the prompt. Pause. Repeat it back.             │
│  1–5 min   │ Ask clarifying questions. Write requirements.          │
│  5–10 min  │ Estimate scale out loud. Derive key conclusions.       │
│ 10–20 min  │ Draw the high-level design. Narrate every box.         │
│ 20–38 min  │ Deep dive into 2–3 hard components.                    │
│ 38–45 min  │ Acknowledge trade-offs. Say what you'd do next.        │
└─────────────────────────────────────────────────────────────────────┘
```

Each phase has a different goal, a different thing the interviewer is watching for, and a different set of common mistakes. We'll walk through each one.

---

### 1.2 Phase 1: The First 60 Seconds — Receive the Prompt

**What happens:** The interviewer gives you a prompt. Something like:

> "Design a system for booking therapy appointments. Patients should be able to browse available providers, select a time slot, and book a session."

**What you should do immediately:**

Do NOT start drawing. Do NOT start naming technologies. Do NOT say "I'd use Postgres." Instead:

1. Take a breath.
2. Repeat the prompt back in your own words to confirm you understood it.
3. Announce that you're going to ask some questions before starting.

**What this looks like:**

> **Interviewer:** "Design a system for booking therapy appointments."
>
> **Strong candidate:** "Got it. So the core feature is: patients can find therapists and book sessions with them. Before I start designing, I'd like to ask a few questions to make sure I'm solving the right problem — is that okay?"

**What the interviewer is evaluating here:** Are you someone who rushes in, or someone who gathers context first? Senior engineers always clarify before building.

**What not to do:**
- ❌ Start drawing boxes immediately
- ❌ Say "I'll use microservices" before knowing the scale
- ❌ Ask questions that don't affect the design ("Do users have profile pictures?")
- ❌ Stay silent and stare at the screen

---

### 1.3 Phase 2: Minutes 1–5 — Gathering Requirements

This is the most important phase and the one most people underestimate. Your goal here is to understand the problem well enough to make real architectural decisions. Every question you ask should change something about the design if the answer is different.

#### What are requirements, exactly?

Requirements are the constraints and features your system must satisfy. There are two kinds.

**Functional requirements** are what the system *does* — the features, from the user's perspective.

Think of these as the user stories. If you were writing a product spec, these are the bullet points under "what users can do."

```
Example — appointment booking:
  ✓ Patients can search for therapists by specialty and availability
  ✓ Patients can view a therapist's open time slots
  ✓ Patients can book a slot (which then becomes unavailable to others)
  ✓ Patients can cancel or reschedule a booking
  ✓ Therapists can set their availability
  ✓ Both parties receive a confirmation notification
```

**Non-functional requirements** are *how well* the system does those things — performance, reliability, scale, security. These are quality constraints, not features.

```
Example — appointment booking:
  ✓ The system must handle 100,000 booking requests per day
  ✓ Slot availability must be accurate — two patients cannot book the same slot
  ✓ The booking confirmation must arrive within 5 seconds
  ✓ The system must be available 99.9% of the time
  ✓ Patient health data must be encrypted and access-logged
```

> **Why this distinction matters in the interview:** Functional requirements tell you *what to build*. Non-functional requirements tell you *how to build it* — they drive choices like databases, caching, replication, and consistency models. If you skip non-functional requirements, you'll propose a design that technically has the right features but is completely wrong for the scale or reliability needed.

---

#### How to gather requirements — the actual dialogue

Here is what a real requirements-gathering conversation looks like. Study this. Practice it out loud.

> **Interviewer:** "Design a system for booking therapy appointments."
>
> **Candidate:** "I'd love to ask a few questions first. Starting with scale — are we building this for a startup with a few hundred providers, or something at the scale of a major healthcare network with tens of thousands?"
>
> **Interviewer:** "Let's say mid-scale — about 5,000 providers, and we're targeting around 500,000 patients initially."
>
> **Candidate:** "Got it. And in terms of booking volume — roughly how many appointments are booked per day? I want to understand if this is a low-frequency scheduling system or something that gets thousands of bookings per hour."
>
> **Interviewer:** "Let's say 50,000 bookings per day."
>
> **Candidate:** "Okay. A few more — do we need real-time slot locking? Meaning: if two patients are looking at the same therapist's calendar at the same time, should only one of them be able to book a specific slot, even before they complete payment?"
>
> **Interviewer:** "Yes, we don't want double-bookings."
>
> **Candidate:** "Understood, that's a concurrency constraint I'll design for. Last one for now — is there a payment step as part of the booking flow, or is billing handled separately?"
>
> **Interviewer:** "Billing is handled externally. Focus on the booking and scheduling part."
>
> **Candidate:** "Perfect. Let me also note a few non-functional requirements I'd propose — correct me if these are wrong. I'd target 99.9% uptime, sub-second response for availability checks, and strong consistency for the booking step itself — meaning if a slot is taken, the system must reflect that immediately, not eventually. Does that sound right?"
>
> **Interviewer:** "Yes, that's fine."

**What the interviewer is evaluating here:**
- Are you asking questions that actually affect the design?
- Can you distinguish functional from non-functional requirements?
- Are you thinking about concurrency and edge cases (double-booking) proactively?
- Are you proposing constraints and checking them, rather than just asking for everything?

**What good looks like:** The candidate drives the conversation, proposes constraints, and confirms them. They don't wait for the interviewer to volunteer all the information.

**What bad looks like:** "Who are the users?" / "What country is this for?" / "Should we support dark mode?" — these don't change the architecture at all.

---

#### The questions that actually change the design

Every question below has a concrete architectural consequence. These are the ones worth asking.

| Question | What changes if the answer is large/yes |
|----------|----------------------------------------|
| "How many daily active users?" | Single DB → need sharding; single server → need load balancer |
| "How many writes per second?" | No cache needed → caching becomes critical |
| "Is this read-heavy or write-heavy?" | Affects indexing strategy, replication, and caching patterns |
| "Can two users conflict on the same resource?" | Need concurrency control (locks, optimistic locking) |
| "Is eventual consistency acceptable, or does it need to be immediate?" | Determines if NoSQL is viable or if you need SQL with transactions |
| "Do we need full-text search?" | Adds a search service (Elasticsearch) to the design |
| "Is this global or regional?" | Multi-region deployment, CDN, data residency laws |
| "Is there user-generated media (photos, video)?" | Object storage + CDN become necessary components |
| "Does this handle sensitive data (health, financial)?" | Adds encryption, audit logging, compliance requirements |
| "What's the acceptable downtime?" | Drives replication, failover, and deployment strategy |

Before asking any clarifying question, run it through this filter: *"If the answer is different from what I expect, will I draw a different diagram?"* If the answer is no — the question doesn't matter, skip it. If the answer is yes — it's worth asking.
>
> Examples of "waste" questions: "Do users have profile pictures?" (no design change), "Should we support dark mode?" (no design change), "What's the brand color?" (no design change). Examples of "good" questions: "How many DAU?" (changes whether you need sharding), "Are users ever offline?" (changes whether you need a sync protocol), "What's the consistency tolerance for the ledger?" (changes your entire persistence strategy).
>
> **Senior signal:** Stating the filter out loud once at the start of requirements — "I want to ask the questions that would actually change my design" — instantly signals you understand the difference between trivia and architecture.

---

#### What to write on your canvas during requirements

While you're asking questions, open draw.io and create a text box (or just a corner of the canvas). Write the requirements as bullet points as you gather them. This does two things:
1. Shows the interviewer you're organized
2. Gives you a reference card for the rest of the interview

```
In draw.io during requirements phase:

  FUNCTIONAL:
  - Patient searches therapist by specialty
  - Patient views available slots
  - Patient books slot (must be exclusive — no double-booking)
  - Cancellation supported
  - Notifications on confirmation

  NON-FUNCTIONAL:
  - 500K patients, 5K providers
  - 50K bookings/day
  - Strong consistency on booking
  - 99.9% uptime
  - HIPAA-relevant (health data)
```

You'll refer to this list when you make decisions later. When you say "I'm using a relational database because I need strong consistency for the booking step," you can point to that requirement.

---

### 1.4 Phase 3: Minutes 5–10 — Estimation

Before drawing your architecture, spend a few minutes doing quick math out loud. This is not about being precise — it's about arriving at the *order of magnitude* so you know what kind of system you're designing.

We cover estimation in full detail in Module 2. For now, understand the *goal*: your estimation should tell you whether your system is a "small problem" (a single server handles it fine) or a "large problem" (you need caching, multiple servers, sharding).

**What the interviewer is evaluating here:** Can you translate a vague scale description into concrete numbers? Can you then derive what those numbers *mean* for the architecture?

**Example (appointment booking):**
```
  50,000 bookings/day ÷ 86,400 seconds/day ≈ 0.6 writes/second (low)
  But availability checks (reads) might be 20x the bookings → ~12 reads/second

  → This is a low-volume system. A single well-configured server handles this easily.
  → So why might we still need caching? Because multiple users might read the
     same therapist's calendar simultaneously. Cache the schedule, not the booking.
  → Why might we still need concurrency control? Because even at low volume,
     two simultaneous booking requests for the same slot must be serialized.
```

Notice how estimation *informs decisions*, not just produces numbers. That's what makes it valuable.

---

### 1.5 Phase 4: Minutes 10–20 — The High-Level Design

This is where you draw your first architecture diagram. The goal of this phase is **a complete but shallow picture** — every major component present, none of them detailed yet.

Think of it like sketching a building's floor plan before drawing the plumbing. You need to know how many rooms, where the doors are, and how they connect. The plumbing details come later.

#### What to draw first

Start with the "spine" of the system: the client, the API layer, and the database. This is almost always the right starting point.

```
In draw.io, draw these three boxes first:

  ┌─────────────────┐     ┌──────────────────┐     ┌──────────────────┐
  │   Mobile App    │────►│    API Server    │────►│    Database      │
  │  (Patient/Prov) │◄────│                  │◄────│                  │
  └─────────────────┘     └──────────────────┘     └──────────────────┘
```

While you draw, narrate what you're drawing and *why*:

> "I'm starting with the basic client-server-database spine. Patients and providers both use the mobile app. The app talks to an API server, which handles business logic. The database persists appointments and availability. Let me think about what else we need..."

**Then add components one by one, narrating each:**

> "Since we have a concurrency requirement — two users can't book the same slot — I need to think about how the API server handles simultaneous booking requests. I'll add a Redis layer for slot locking, which I'll explain when we deep-dive. Let me also add a notification service since we send confirmations..."

```
After 5–8 minutes of high-level drawing:

  ┌─────────────┐    ┌──────────────┐    ┌────────────────┐
  │  Mobile App │───►│  API Server  │───►│  PostgreSQL    │
  └─────────────┘    └──────┬───────┘    └────────────────┘
                            │
                    ┌───────┴────────┐
                    │                │
             ┌──────▼──────┐  ┌──────▼──────┐
             │    Redis    │  │ Notification│
             │  (slot lock)│  │   Service   │
             └─────────────┘  └─────────────┘
```

#### What not to do during high-level design

- ❌ **Don't go deep on any one component.** Say "I'll explain how Redis handles this in a moment" and move on.
- ❌ **Don't draw every database table.** That's the deep-dive phase.
- ❌ **Don't go silent.** If you're thinking, say "Let me think about whether we need a queue here..." The interviewer needs to hear your reasoning, not just see the output.
- ❌ **Don't draw perfectly.** Rough boxes with labels are fine. This is a working document, not a presentation.

**What the interviewer is evaluating here:** Can you identify the major components? Do you know what each component is responsible for? Can you articulate how data flows through the system?

---

### 1.6 Phase 5: Minutes 20–38 — The Deep Dive

This is where the interview gets technical. The interviewer will either pick a component to go deep on, or ask you to pick the most interesting/complex one.

**What you should say:**

> "I think the most interesting part of this design is the slot-booking concurrency problem — preventing two patients from booking the same therapist slot simultaneously. Can I go deep there first?"

Or the interviewer might say:

> "Tell me more about how the database schema looks."
> "How would you handle a therapist changing their availability while a patient is mid-booking?"
> "What happens if the notification service is down when a booking completes?"

Each of these is an invitation to go one or two levels deeper on a specific component.

**What good looks like:** You zoom into the component, explain the problem precisely, propose a solution, and then acknowledge the trade-off it creates.

**What bad looks like:** Vague answers ("I'd just add more servers"), inability to go deeper ("the database handles that"), or answers without trade-offs ("this is always the right approach").

---

### 1.7 Phase 6: Minutes 38–45 — Trade-offs and Wrap-up

The interviewer is wrapping up. This is your chance to show intellectual honesty and range.

**What to say:**

> "If I had more time, the thing I'd most want to improve is the notification reliability. Right now if the notification service crashes mid-booking, the patient might not get a confirmation even though the booking went through. I'd add a message queue — Kafka or SQS — between the booking service and notification service so notifications are guaranteed to eventually deliver even if the notification service is temporarily down."

Or:

> "One trade-off I made is using Redis for slot locking instead of database-level locking. Redis is faster but it's a separate system that can fail. In a healthcare context, if Redis crashes mid-booking, I'd need a fallback strategy — probably falling back to optimistic locking at the database level. That's the reliability risk I accepted to get sub-millisecond locking performance."

**What the interviewer is evaluating here:** Are you aware of the limitations of your own design? Can you reason about trade-offs honestly? This is a massive senior signal — junior engineers defend their design; senior engineers critique it.

---

### 1.7.1 The Three Core Elements of Any System

Before you draw your first box in an interview, internalize this. *Every* system you will ever design is, at its heart, doing three things. Once you can place any component into one of these three buckets, the design becomes easier to reason about — and the interviewer's questions become easier to anticipate.

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│  1. MOVING DATA        2. STORING DATA        3. TRANSFORMING DATA │
│                                                                    │
│  How data flows.    Where data lives.    How raw input becomes    │
│  Networks, queues,  Databases, caches,   useful output.           │
│  load balancers,    object stores,       Business logic,         │
│  APIs, streams.     backups.             aggregation, ETL,        │
│                                          enrichment.              │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

#### 1. Moving Data

Everything about *how bytes get from A to B*.

```
In scope:
  - Networks (TCP/UDP, DNS, firewalls, CDNs)
  - Load balancers, reverse proxies, API gateways
  - Message queues (Kafka, RabbitMQ, SQS)
  - Pub/sub topics, event streams
  - WebSockets, gRPC, REST endpoints
  - File transfer (SFTP, presigned URLs to S3)

Design questions:
  - Synchronous or async?
  - Push or pull?
  - Guaranteed delivery or best-effort?
  - What's the bandwidth / latency budget?
```

> **Module mapping:** Networking (Module 5.5), APIs (Module 5.1), Load Balancing (Module 6.1), Proxies (Module 6.1.1), Message Queues (Module 7).

#### 2. Storing Data

Everything about *where bytes live and how they come back*.

```
In scope:
  - Relational databases (PostgreSQL, MySQL)
  - NoSQL: document (MongoDB), key-value (Redis), wide-column (Cassandra),
    graph (Neo4j)
  - Object storage (S3), block storage (EBS), file systems
  - Caches (Redis, Memcached, CDN)
  - Search indexes (Elasticsearch)
  - Data warehouses (Redshift, BigQuery), data lakes (S3 + Athena)
  - Backups, snapshots, replicas, archives

Design questions:
  - ACID or eventual consistency?
  - Structured or unstructured?
  - Read-heavy or write-heavy?
  - How long does it live? (retention policy)
  - What are the access patterns?
```

> **Module mapping:** Module 3 (Database Fundamentals), Module 4 (Caching), Module 8 (Storage Systems), Module 13 (Data minimization & retention).

#### 3. Transforming Data

Everything about *how raw input becomes useful output*. This is the "logic" of the system — what makes it more than a dumb pipe.

```
In scope:
  - Business logic (booking validation, payment processing)
  - API request/response shaping (BFF pattern)
  - Data aggregation (the "last 30 days" dashboard query)
  - ETL pipelines (raw logs → cleaned events → analytics)
  - Search ranking, recommendation algorithms
  - Image/video transcoding
  - Encryption, anonymization, PII redaction
  - AI/ML inference (image classification, recommendations)

Design questions:
  - Where does the transformation happen? (client, edge, server, batch)
  - Sync (user waits) or async (fire-and-forget)?
  - Stateless (just compute) or stateful (needs memory)?
  - What happens when the transformation fails? (retry? dead letter? alert?)
```

> **Module mapping:** Touches everything. Module 11 (Event Sourcing, CQRS, CDC) is largely about *where* and *when* transformation happens.

#### How to Use This Framing in the Interview

When the interviewer asks "design X," don't immediately think "what services do I need?" Think:

1. **What data is moving?** From where to where? How fast? How much?
2. **What data is stored?** What's the access pattern? How long does it live?
3. **What data is being transformed?** What business rules apply? What becomes meaningful from raw input?

Then draw your system: storage on the right, transformation in the middle, movement on the left, with the user at the top and ops tools wrapping it all.

> **Senior signal:** Naming these three elements in your opening ("Let's think about this as moving data, storing data, and transforming data — let me walk through each") shows a mental model that scales to any system, not just the one the interviewer happened to ask about. It signals seniority because it generalizes.

---

### 1.8 Common Mistakes and How to Recover

| Mistake | How to recover |
|---------|---------------|
| You jumped into architecture without asking questions | Pause, say "Actually, let me back up — I want to make sure I have the requirements right before I go further" |
| You went silent for 30+ seconds | Say out loud: "I'm thinking through the trade-offs of X vs Y — give me just a moment" |
| You proposed a solution and the interviewer pushes back | Say "Fair point — let me reconsider. If Y is the constraint, then maybe X is a better fit because..." |
| You don't know a specific technology | "I'm not deeply familiar with [X] specifically, but I know it's a [type]. I'd approach it by [reasoning]..." |
| You ran out of things to say at minute 15 | Ask the interviewer: "Is there a particular component you'd like me to go deeper on?" |
| You forgot to mention a requirement mid-design | "Actually, I want to add something to the requirements I noted — we haven't talked about what happens when a therapist cancels. That would change the notification design." |

#### 1.8.1 Design Anti-Patterns to Avoid in the Interview

> **Interview relevance: Differentiator.** You won't be asked "tell me the anti-patterns," but committing one of these live is the most common way to lose points. The "refusal of buzzword bingo" + "tradeoff acknowledged" rows are the ones to memorize cold.

These are the most common anti-patterns that signal junior thinking — internalize them so you don't accidentally commit any of them.

| Anti-pattern | What it looks like | Why it hurts | What to say instead |
|--------------|--------------------|--------------|---------------------|
| **Premature microservices** | "I'll split this into 12 services" for a 10-user MVP | Massive operational overhead for zero benefit; canary/observability cost is paid before scale arrives | "For the scale we discussed, I'd start with a modular monolith and split out a service only when there's a clear scaling or team-boundary reason." |
| **Buzzword bingo** | "I'll use Kubernetes, Istio, Kafka, Cassandra, ClickHouse, Redis, Elasticsearch, and Snowflake" | The interviewer stops listening. It signals you collected names without understanding fit. | Name *one* tool per problem, and only after you've explained the problem. |
| **"I'll add Redis"** (without saying why) | "Caching is good, so I'll add Redis" | Caching adds invalidation complexity, an extra failure mode, and cost. It only helps specific read patterns. | "Reads are 100x writes and the data is mostly read-only after creation — I'll add a cache-aside layer in front of the DB for the 5% of items that get 95% of reads." |
| **Ignoring failure modes** | Drawing boxes connected by happy-path arrows | Production is mostly failure paths. Interviewer wants to see you reason about what happens when each box dies. | For every box, name what happens if it goes down. "If the cache dies, the DB takes the load but my service stays up — read latency degrades." |
| **"I'll just add more servers"** | Defaulting to "scale horizontally" as the answer to every problem | Some problems are not capacity problems (correctness, consistency, contention). | "Before I scale, let me check if the bottleneck is throughput, latency, or correctness — they have different fixes." |
| **Drawing too much, talking too little** | Silent 5 minutes of drawing, then "here it is" | The interviewer can't see your reasoning. The 45 min is for thinking out loud, not for the artifact. | Narrate every box. "I'm adding a queue here *because* the user shouldn't wait for the thumbnail generation…" |
| **Premature optimization** | "I'll shard by hash of user_id + region + tenant + created_at" for a system that fits in one DB | Sharding is a 6-month project. Don't commit before you have data showing you need it. | "If single-DB QPS exceeds 5K or storage exceeds 1 TB, I'll shard. Until then, vertical + replicas." |
| **One-tier thinking** | "Client → API → DB" with nothing else | Real systems have cache, queue, storage, CDN, observability. The 3-box answer is the *starter*, not the system. | Use the multi-tier framing from §1.0.3: presentation → edge → app → cache → data → storage → async → observability. |
| **No tradeoff acknowledged** | "This is the right way to do it" | Senior engineers know every choice has a cost. The interviewer is watching for the cost. | Always pair a decision with "the cost is…" or "the tradeoff is…" |
| **Cargo-cult architecture** | "Uber uses Cassandra and Kafka so I should too" | You're not Uber. Their scale and constraints are not yours. | "I considered Cassandra, but for our QPS and access pattern Postgres with read replicas is sufficient. If our write QPS grew 100x, I'd revisit." |

The interview is not measuring whether you can list AWS services or whether you can clone Netflix. It is measuring (1) can you *reason* about a problem, (2) do you have a *repertoire* of solutions you can pick from, and (3) can you *collaborate* with the interviewer to refine the design. The anti-patterns above are all failures of one of those three.

---

### 1.9 Module 1 — Quick Fire (after the full explanation)

These are compressed reminders. Only use these after you've internalized the explanations above.

| Question | Answer |
|----------|--------|
| Functional vs non-functional? | Functional = what it does. Non-functional = how well (performance, reliability, security). |
| What is the first sentence out of your mouth? | "Before I start designing, I'd like to ask a few clarifying questions." |
| What makes a good clarifying question? | One whose answer changes the architecture |
| What are "4 nines"? | 99.99% uptime = ~52 minutes of downtime per year |
| What are you doing in the high-level design phase? | Drawing every component shallowly, narrating while drawing, not going deep on anything yet |
| What does good deep-dive look like? | Problem → solution → trade-off. Always the three together. |
| How do you show seniority in the wrap-up? | Critique your own design. Name the biggest risk you'd address next. |
| The boxes in a standard production architecture? | CI/CD → Load balancer → app servers → cache + external storage → DB. Plus observability + alerting wrapping it all |
| Why is "never debug in production" the rule? | A mistake there affects users. Always reproduce in a staging environment that mirrors production |

---

## Module 2: Back-of-Envelope Estimation

> **Priority: HIGH.** Interviewers explicitly ask "estimate the scale." Numbers anchor every decision. You don't need to be a math genius — you need to be comfortable doing rough calculations out loud and connecting the result to architectural decisions.

---

### 2.1 What Is "Back-of-Envelope" and Why Does It Exist?

The term comes from the idea of doing a quick calculation on the back of an envelope — no spreadsheet, no calculator, just a rough approximation done in 2–3 minutes.

The goal is not accuracy. The goal is to answer: **what class of problem is this?**

- Is this a system that handles 10 requests per second? Then a single API server is probably fine.
- Is this a system that handles 100,000 requests per second? Then you need multiple servers, caching, and load balancing.
- Is this a system that generates 1 GB of new data per day? Then a standard database on a normal server is fine for years.
- Is this a system that generates 100 TB of data per day? Then you need a data warehouse and object storage from day one.

These decisions are completely different, and the interviewer wants to see that you can figure out which category you're in *before* committing to a design.

---

### 2.2 The Numbers You Must Memorize

You will use these in every estimation. They don't need to be exact — they need to be in the right ballpark. Memorize them like a multiplication table.

**Time: how many seconds in a day?**
```
1 day = 24 hours × 60 min × 60 sec = 86,400 seconds

For estimation purposes: use 100,000 (10^5) — it's close enough and easier to work with.
So: 1 day ≈ 100,000 seconds
```

**Storage: the size of common things**
```
A short text message or tweet:   ~1 KB   (1,000 bytes)
A user profile record:           ~1 KB
A profile photo thumbnail:       ~100 KB
A full-resolution photo:         ~1–5 MB
A 1-minute audio clip:           ~1 MB
A 15-second compressed video:    ~5 MB
A 1-hour movie (compressed):     ~2 GB
```

**Storage units (how they scale up)**
```
1 KB  =                  1,000 bytes  (a text message)
1 MB  =              1,000,000 bytes  (a photo)
1 GB  =          1,000,000,000 bytes  (a movie)
1 TB  =      1,000,000,000,000 bytes  (a large database)
1 PB  =  1,000,000,000,000,000 bytes  (a data warehouse at tech-company scale)
```

**Latency: how fast different storage is**

This is important for reasoning about *why* caching helps. When you say "we should cache this," the numbers below explain the size of the benefit.

```
Reading from RAM (in-memory cache):      ~0.1 ms    (very fast)
Reading from SSD (local disk):           ~0.1 ms    (fast for random reads)
Reading from a database (disk + query):  ~10 ms     (100x slower than RAM)
A network round trip (same city):        ~1–5 ms
A network round trip (cross-continent):  ~150 ms    (very slow for real-time)
```

The punchline: **a database read is ~100x slower than an in-memory read**. That's why caching is so important.

---

### 2.3 The Four-Step Estimation Framework

You always follow the same four steps, in this order. Work top-down.

```
Step 1: How many users are active per day?  (DAU — Daily Active Users)
Step 2: What do those users do per day?     (Actions per user)
Step 3: How many requests per second?       (QPS — Queries Per Second)
Step 4: How much storage do we need?        (GB or TB per day/year)
```

Let's define each term, then do a full worked example.

#### 2.3.1 Little's Law — The Estimation Tool Most Candidates Miss

> **Interview relevance: Core.** "How many servers do I need?" and "how big should my queue be?" are the two questions this unlocks. Candidates who reach for L = λ × W out loud stand out; almost nobody else does.

Little's Law is a beautiful, simple formula that lets you reason about queues, capacity, and latency. Once you know it, estimation questions that seemed magical become mechanical.

**The formula:**

```
L = λ × W
where:
  L = average number of items in the system (in-flight, in-queue, in-service)
  λ = arrival rate (items per second)
  W = average time an item spends in the system (seconds)
```

**Why this matters in the interview:** Almost every "how many servers / how big a queue / what's the latency under load" question is Little's Law in disguise. If you can rearrange the formula and reason out loud, you look like someone who has actually run capacity planning — not just memorized numbers.

**Three useful rearrangements:**

```
Given λ and W:    L = λ × W   → "How many items are in-flight at any time?"
Given L and λ:    W = L / λ   → "How long does each item wait on average?"
Given L and W:    λ = L / W   → "What's the throughput ceiling?"
```

**Worked example 1 — Checkout system:**

```
Scenario: A checkout pipeline takes 3 seconds end-to-end.
          1000 users are concurrently checking out.

  L = 1000 (items in system)
  W = 3 sec
  λ = L / W = 1000 / 3 ≈ 333 checkouts/second

  → If you can do 333 checkouts/second, you need 333 concurrent
    checkouts in flight, which means you need ~333 worker threads
    (or 333 Lambda concurrent executions, or 333 serverful instances).
```

**Worked example 2 — Queue capacity:**

```
Scenario: Webhook events arrive at 1000/s.
          Each takes 50ms to process.
          How many events sit in the queue on average?

  λ = 1000/s
  W = 50ms = 0.05s
  L = λ × W = 1000 × 0.05 = 50 events in-flight

  → At 50ms per event with one consumer, the queue is essentially empty.
  → If W spikes to 5 sec (a slow consumer), L = 5000 events in queue
    — that means you need either more consumers or you start dropping.
```

**Worked example 3 — Throughput ceiling:**

```
Scenario: A single Kafka partition is processed by one consumer.
          Each message takes 20ms. What's the max throughput?

  Per-partition λ = 1 / W = 1 / 0.02s = 50 messages/second
  → If you need 10K messages/s, you need 10K/50 = 200 partitions.
```

> **Interview framing:** When the interviewer says "how big should my queue be?" or "how many consumers do I need?", don't guess. Say "let me apply Little's Law — if arrival rate is X and processing time is Y, then the system will have X×Y items in flight on average. To stay healthy, the consumer pool must process at least X items/second."

---

#### Step 1: DAU — Daily Active Users

"Daily Active Users" is simply: how many unique people use the system on a given day. Not total registered users — active users.

```
Rough benchmarks to anchor your estimates:
  Small startup / niche product:  10,000 – 100,000 DAU
  Successful mid-sized app:       1M – 10M DAU
  Large consumer app:             50M – 500M DAU
  Google/Facebook/WhatsApp scale: 1B+ DAU
```

In an interview, the interviewer will often give you this number or a proxy ("500,000 patients"). If they don't, ask, or propose one and confirm.

---

#### Step 2: Actions Per User Per Day

How many "things" does each active user do per day? This depends on the product.

```
A messaging app user:       sends ~40 messages/day, reads ~100 messages/day
A social media user:        views ~50 posts/day, creates ~1 post/day
A booking app user:         books ~1 appointment/month ≈ 0.03 bookings/day
A food delivery app user:   orders ~1 meal/day on active days
```

For reads and writes, estimate separately. Most systems have many more reads than writes — often 10x to 100x more.

---

#### Step 3: QPS — Queries Per Second

"Query" here means any request to the server — a database read, an API call, anything. QPS is how many of these happen every second on average.

The formula is:

```
QPS = (DAU × actions per user per day) / seconds per day

Using our shorthand: seconds per day ≈ 100,000

Example: 1M users each read 20 posts per day
  Read QPS = (1,000,000 × 20) / 100,000 = 200 QPS

Example: Same 1M users each write 1 post per day
  Write QPS = (1,000,000 × 1) / 100,000 = 10 QPS
```

**What QPS tells you:**

```
< 100 QPS:    A single well-configured server handles this easily
100–1,000 QPS: Starting to think about multiple servers
1,000–10,000 QPS: Need caching, load balancing, multiple servers
> 10,000 QPS: Need serious distributed architecture, multiple data centers
```

---

#### Step 4: Storage

How much disk space does new data require?

```
Storage per day = write QPS × size per item × seconds per day
Storage per year = storage per day × 365
```

Example:
```
Write QPS: 10 (10 new posts per second)
Size per post: 1 KB (text only)
Storage per day = 10 × 1KB × 100,000 = 1 GB/day
Storage per year = 1 GB × 365 = 365 GB/year → under 1 TB

→ This fits on a single database server. No exotic storage needed.
```

Bigger example:
```
Write QPS: 500 (500 new videos uploaded per second)
Size per video: 5 MB
Storage per day = 500 × 5MB × 100,000 = 250 TB/day

→ This does NOT fit in a database. You need object storage (like S3),
  a CDN, and a dedicated video processing pipeline.
```

The goal of the storage calculation is to discover when you need specialized storage solutions. If your answer is in the GB range, a normal database is fine. If it's TB per day, you need to think about object storage, data lakes, and CDNs.

---

### 2.4 Worked Example — Appointment Booking System

Let's go through a complete estimation, the way you'd actually do it in the interview, narrating out loud.

**Setup:** 500,000 active patients, 5,000 providers, 50,000 bookings per day.

> "Let me do a quick estimation to understand the scale. The interviewer told me 50,000 bookings per day. Let me figure out what that means in terms of requests per second and storage."

**Step 1: DAU**
```
500,000 patients — given
5,000 providers — given
```

**Step 2: Actions**
```
Bookings per day: 50,000 (given — this is the write operation)

But there are also reads: patients browsing available slots.
Assume each booking attempt involves ~10 slot-browsing requests before one succeeds.
Read requests per day ≈ 50,000 × 10 = 500,000
```

**Step 3: QPS**
```
Write QPS = 50,000 / 100,000 = 0.5 writes/second
Read QPS  = 500,000 / 100,000 = 5 reads/second
```

> "So this is a very low-volume system — under 10 requests per second total. A single server handles this with no problem. But I still need to think about concurrency: even at 5 reads/second, two patients could simultaneously try to book the same slot. The volume is low but the correctness requirement is high."

**Step 4: Storage**
```
Per booking record: ~1 KB (patient ID, provider ID, timestamp, status)
Storage per day = 50,000 × 1KB = 50 MB/day
Storage per year = 50 MB × 365 = ~18 GB/year

→ Trivially small. A basic PostgreSQL instance handles this for decades.
```

**What the estimation told us:**
- ✓ Single server is fine for traffic volume
- ✓ No caching needed for raw performance (volume is low)
- ✓ Standard relational database is more than enough for storage
- ✓ But concurrency control is still required (correctness, not volume)
- ✓ Compliance/security is the harder challenge, not scale

> "So this system is not a scale problem — it's a correctness and compliance problem. My architecture will focus on strong consistency for slot booking and proper data protection, not on horizontal scaling."

**What the interviewer is evaluating:** Did you draw conclusions from the numbers? Saying "write QPS is 0.5" means nothing in isolation. The point is: "this is low volume, so I'll focus on correctness rather than scale." That connection is the senior signal.

---

### 2.5 Worked Example — Instagram Stories (High Scale)

For contrast, here's a high-scale system.

```
DAU: 500M
Stories viewed per user per day: 20 (reads)
Stories created per user per day: 0.1 (1 in 10 users posts — writes)
Story size: 5 MB (15-second video)

Read QPS  = 500M × 20 / 100,000 = 100,000 reads/second
Write QPS = 500M × 0.1 / 100,000 = 500 writes/second

→ 200x more reads than writes → very read-heavy
→ Caching is critical (100,000 QPS from a database alone is impossible)
→ CDN is mandatory (users worldwide need low latency for video)

Storage per day = 500 writes/sec × 5MB × 100,000 sec = 250 TB/day
→ Object storage (S3-like), not a database
→ CDN layer between S3 and users — no one can watch video directly from S3 at this scale
```

> **Senior signal:** After computing these numbers, say: "The 100:1 read/write ratio tells me caching is the most important architectural choice here. And 250 TB/day of video means a relational database is completely wrong for media storage — I'd use object storage and a CDN."

#### 2.5.1 Worked Example — Uber-style Ride Dispatch (Write-Heavy, Geo, Real-Time)

> **Interview relevance: Differentiator.** Unlikely to be asked at this depth (QPS + storage + 5 derived architecture choices) in 45 min. But the *shape* — write-heavy + geo + real-time + async — is exactly what an interviewer is looking for when they say "design a ride-sharing app." The signal: "this person can decompose a system into its data shape and choose tools accordingly."

Ride-sharing is the canonical write-heavy, geo-aware, real-time problem. The same shape appears in food delivery, fleet management, on-demand services, IoT telemetry, and asset tracking.

```
DAU: 30M riders, 5M drivers
Rides per day: 20M
Trip lifecycle events per ride: 50 (location pings, status changes, payments)
  → 20M × 50 = 1B events/day
  → 1B / 100,000 sec = 10,000 events/second average
  → Peak: 3-5x average = 30K-50K events/second

Storage:
  Each event ~200 bytes
  1B events × 200 bytes = 200 GB/day of raw event data
  Replicated 3x in Kafka = 600 GB/day hot storage
  After 30 days in S3 (warm): 6 TB/month
  After 1 year in Glacier (cold): 72 TB/year

Read QPS:
  Active driver locations read by dispatch: 5M drivers × 1 update
    to dispatchers per 30s = 167K location reads/second
  Each rider checks app for nearby cars: 30M × 20 opens/day = 6M
    "find me a car" queries/day = 60 reads/second average
```

**What the estimation tells you architecturally:**

```
WRITE-HEAVY         — 10K+ writes/sec, all small structured events.
                       → Use a message queue (Kafka) as the primary
                         write path. DBs are for state, not events.
                       → Concrete: Uber, Lyft, DoorDash all use Kafka
                         as the trip-event backbone.

GEO-AWARE           — Every event has a lat/lon; every query is
                       "within X km of Y".
                       → Add a geo-index: H3 (Uber's open-source hex
                         grid), Redis GEORADIUS, or PostGIS. NOT a
                         naive SQL `WHERE lat BETWEEN ... AND ...`
                         scan, which is O(n) per query.

REAL-TIME DISPATCH  — Sub-second matching.
                       → A dedicated matching service in front of
                         a location cache (Redis with GEO commands,
                         or a hot-path service that keeps all
                         active drivers in memory).
                       → Concrete: Uber's Ringpop and H3 work
                         together; Lyft uses gRPC with extreme
                         connection pooling.

ASYNC BY DEFAULT    — A ride's "complete" event triggers payment,
                       ratings, receipt, analytics, ML training.
                       → All post-trip work happens via async
                         workers reading from Kafka, not in the
                         request path.

WRITE-PATH STATE    — Where IS the driver right now? This is
                       a state, not an event.
                       → Use a fast KV store (Redis) for the current
                         state, derived from the event stream
                         (Kafka → stream processor → Redis).
```

> **Senior signal:** "This is write-heavy, geo-aware, and real-time. I'll front it with a message queue, use a geo-index for spatial queries, and keep the hot path in memory. Async workers consume events for everything that doesn't need a synchronous response."

> **Common mistake:** Candidates try to write every location ping to a relational database. At 30K events/sec, a single Postgres primary will fall over in minutes. The event log (Kafka) is the source of truth; the database holds derived state.

#### 2.5.2 Worked Example — Ad Bidding (Read-Heavy, Latency-Critical, Money)

> **Interview relevance: Differentiator.** A great "I have done this at scale" example when asked about latency-critical or revenue-bound systems. Most candidates never connect "bid" → "100K QPS at <100ms" → "must be in-memory." Pair with the HFT/quant interview archetype.

The opposite of a write-heavy geo system is a read-heavy bidding system: 100K–500K bid requests per second, each must be answered in <100ms, and the answer directly affects revenue.

```
DAU (bidders): 1000
QPS (bid requests from ad exchanges): 100,000
Bid response time budget: 100ms (p99)
Bid price calculation: lookup user segment + look up ad campaign
                       + run a simple auction function
Per-bid DB lookup: 5 queries × 1ms each = 5ms
Per-bid cache lookup: 5 × 0.1ms = 0.5ms

  → At 100K QPS, you cannot hit a DB on every bid.
  → Cache user segment in Redis (sub-ms, can absorb 100K QPS).
  → Cache campaign in memory in the bidder process (fastest).
  → Pre-compute bid prices for common combinations in a lookup table.

Revenue calculation:
  100K QPS × 0.1% click-through × $1 CPM = $100/sec = $360K/hour.
  → Even a 1% drop in availability is $3600/hour lost.
  → Latency matters: ads served >200ms earn 50% less.
```

> **Senior signal:** "This is read-heavy and money-bound. I'll pre-compute bid prices and keep them in a multi-level cache (L1 in-process, L2 Redis). The bidder is stateless and horizontally scaled. The auction function is pure — no DB hits in the hot path. Failure mode I worry about: cache stampede on a campaign refresh."

---

### 2.6 How to Speak During Estimation in the Interview

Don't do the math silently. Say it out loud, and round aggressively.

> "Let me estimate the scale. They said 500,000 patients and 50,000 bookings per day. I'll use 100,000 as my seconds-per-day approximation. So write QPS is roughly 50,000 divided by 100,000, which is about 0.5 per second — so less than one write per second on average. That's very low. Reads will be higher — let me assume each booking involves maybe 10 slot-browsing requests, so 500,000 reads per day, which is 5 reads per second. Still very manageable on a single server."

Round to clean numbers. Say "about 0.5" not "0.4629." Interviewers know this is an estimate.

---

### 2.7 Module 2 — Quick Fire

| Term | What it means |
|------|--------------|
| DAU | Daily Active Users — unique users active in a day (not total registered) |
| QPS | Queries Per Second — total requests hitting your servers per second |
| Seconds per day (shorthand) | ≈ 100,000 (exact: 86,400) |
| Read-heavy | Many more reads than writes — suggests caching is valuable |
| Write-heavy | Many more writes — suggests careful DB write capacity planning |
| What does QPS < 100 mean? | Single server probably fine |
| What does QPS > 10,000 mean? | Need distributed architecture, caching, load balancing |
| Storage in GB range | Normal relational database is fine |
| Storage in TB/day range | Need object storage (S3), CDN, possibly a data warehouse |

---

## Module 3: Database Fundamentals

> **Priority: CRITICAL for mobile devs.** You know SQLite. This module covers everything you're missing about production databases.

### 3.1 What a Row Actually Is on Disk

Before understanding indexes, replication, or sharding, you need a mental model of what a database physically is.

A relational database stores data in **pages** (typically 8KB or 16KB) on disk. Each page holds multiple rows. When you run a query, the database reads pages from disk into memory, applies your query, and returns results.

```
Disk
┌──────────────────────────────────────────────────────────┐
│ Page 1 (8KB)                                             │
│  [row: id=1, name="Alice", email="a@a.com"]              │
│  [row: id=2, name="Bob",   email="b@b.com"]              │
│  [row: id=3, name="Carol", email="c@c.com"]              │
│  ... (more rows fill the page)                           │
├──────────────────────────────────────────────────────────┤
│ Page 2 (8KB)                                             │
│  [row: id=4, ...]                                        │
│  ...                                                     │
└──────────────────────────────────────────────────────────┘
```

A **full table scan** means reading every page, one by one, until you find what you want. For a table with 50 million rows across thousands of pages, this is slow. This is why indexes exist.

---

### 3.2 Relational vs Non-Relational

**Relational (SQL):** Data is stored in tables with defined columns and types. Relationships between tables are enforced by foreign keys. The schema is rigid — every row in a table has the same columns.

**Non-Relational (NoSQL):** Data can be stored in many forms (documents, key-value pairs, wide columns, graphs). Schema is flexible — two "documents" in the same collection can have different fields.

This is not a "which is better" question. It's a "which fits the problem" question.

| | SQL | NoSQL |
|--|-----|-------|
| Schema | Fixed, enforced | Flexible |
| Relationships | First-class (JOINs) | Application-level |
| Transactions | Full ACID | Varies by DB |
| Scale | Vertical first, horizontal is hard | Designed for horizontal |
| Best for | Financial data, bookings, anything with complex relations | Logs, user profiles, social graphs, time-series |
| Examples | PostgreSQL, MySQL | MongoDB, DynamoDB, Cassandra, Redis |

---

### 3.3 ACID Properties — What They Are and Why They Matter

ACID is a set of guarantees that relational databases make about transactions. A **transaction** is a group of operations that either all succeed or all fail together.

**Atomicity** — All or nothing.

```sql
-- Transfer $100 from Alice to Bob
BEGIN;
  UPDATE accounts SET balance = balance - 100 WHERE id = 'alice';
  UPDATE accounts SET balance = balance + 100 WHERE id = 'bob';
COMMIT;
```

If the server crashes after the first UPDATE but before the second, Atomicity guarantees the first is also rolled back. Alice doesn't lose $100 with Bob never receiving it.

**Consistency** — The database moves from one valid state to another. Constraints are always satisfied.

```sql
-- If there's a constraint: balance >= 0
-- This will fail atomically if Alice only has $50
BEGIN;
  UPDATE accounts SET balance = balance - 100 WHERE id = 'alice'; -- Would go to -50, violates constraint
COMMIT;
-- → Transaction is rolled back. Balance unchanged.
```

**Isolation** — Concurrent transactions don't interfere with each other. It's as if they run sequentially.

```
Without isolation:                     With isolation:
  Alice reads: balance = $100            Transaction 1 sees a snapshot
  Bob reads:   balance = $100            Transaction 2 sees a snapshot
  Alice deducts $100                     Only one commits first
  Bob deducts $100                       The other sees the updated value
  Result: balance = -$100 (wrong!)       Result: correct
```

**Durability** — Once a transaction commits, it's permanent. Even if the server crashes immediately after COMMIT, the data is not lost (it's been written to disk).

> **Senior signal:** When designing a financial system or a booking system, proactively saying "I need ACID guarantees here because partial writes would corrupt the data model" signals you understand _why_ you're choosing SQL, not just that "SQL is good."

#### 3.3.1 ACID vs CAP Consistency — The Most Common Interview Trap

> **Interview relevance: Core.** A classic "trap" question. Interviewers who ask about DynamoDB, Postgres, or distributed transactions often test exactly this. Knowing the two "consistencies" are different and naming when each applies is a top-of-band signal.

The word "consistency" appears in two completely different contexts in system design. Conflating them is a senior-engineer trap and a senior-interviewer trap.

```
ACID CONSISTENCY  (database-level):
  The database moves from one valid state to another.
  Means: integrity constraints are always satisfied.
  Scope: a single transaction in a single database.
  Example: a transfer can't make Alice's balance negative.

CAP CONSISTENCY   (distributed-systems-level):
  All replicas of a piece of data return the same value
  at the same time (linearizability).
  Means: every read sees the latest committed write.
  Scope: across multiple nodes in a distributed system.
  Example: a user in Tokyo and a user in São Paulo both see
  the same chat message at the same wall-clock moment.

THEY ARE NOT THE SAME.
A database can be ACID-compliant and CAP-inconsistent
(distributed transactions across regions use eventual consistency
for cross-region replication).
A database can be CAP-consistent (Raft quorum) and not
ACID (Cassandra is AP, sacrifices ACID atomicity).
```

**The interview trap questions:**

```
Q: "Is DynamoDB ACID?"
A: Sort of. DynamoDB Transactions API provides ACID for single-region
   multi-item transactions. But its default reads are eventually
   consistent (CAP-AP), not strongly consistent.

Q: "Is Postgres eventually consistent?"
A: No. A single Postgres instance is ACID and CAP-consistent (C in CAP
   because a single node doesn't have a partition to worry about).
   Once you add a read replica, you can choose to read from the replica
   — at which point you accept eventual consistency for those reads.

Q: "What does my application need?"
A: Depends on the operation. Banking ledger: ACID + CP.
   Social feed: BASE + AP.
   Cart in e-commerce: ACID at checkout, BASE while browsing.
```

> **Senior signal:** When the interviewer says "we need consistency," immediately ask "which kind — ACID consistency in our writes, or CAP consistency across replicas?" The fact that you know they are different is a top-of-band signal.

#### 3.3.2 BASE — The NoSQL Counterpart to ACID

> **Interview relevance: Differentiator.** The acronym is the value — the spelling "BASE" is memorable, and being able to name the three properties out loud when discussing NoSQL is a quick win. You will rarely be asked to define BASE explicitly, but it shows up whenever you discuss DynamoDB, Cassandra, or S3.

When NoSQL systems decided to give up full ACID to get horizontal scale, they articulated the alternative explicitly. The acronym is BASE.

```
BASE = Basically Available, Soft state, Eventual consistency

Basically Available:
  The system always responds — even if the response is stale
  or a degraded version of the truth. It does not return 500.
  → "I can always read your shopping cart; it might be 200ms stale."

Soft state:
  The system's state may change over time, even without input,
  because replicas are converging.
  → "A user's last-seen timestamp updates as replicas sync."

Eventual consistency:
  Given enough time and no new writes, all replicas will agree.
  → "If I update my profile picture, every region will show the
     new picture within a few seconds."
```

| | ACID | BASE |
|--|------|------|
| Common in | Postgres, MySQL, Oracle | DynamoDB, Cassandra, Riak, S3 |
| Trade-off | Strict correctness | Scale + availability |
| Use when | Money, inventory, bookings, anything where partial state is a bug | Social feeds, shopping carts, counters, analytics, anything where stale is acceptable |
| Real-world example | A bank transfer — can't have $100 vanish | A "view count" on a YouTube video — being off by a few is fine |

> **Common mistake:** "We don't need transactions" — usually wrong. Even in BASE systems, individual operations are atomic (single-item writes, single-row reads). What's eventually consistent is the *propagation* across replicas, not the operation itself.

---

### 3.4 Database Table Modeling — Schema Design

Mobile devs are used to thinking in objects (classes/structs). Backend schema design requires thinking in relations.

#### Primary Keys

A **primary key** is a column (or set of columns) that uniquely identifies each row. No two rows can have the same primary key value.

```sql
CREATE TABLE users (
  id         UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  email      VARCHAR(255) NOT NULL UNIQUE,
  name       VARCHAR(100) NOT NULL,
  created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
```

- `UUID` is better than auto-increment integer for distributed systems — you can generate IDs client-side without a round trip to the DB.
- `UNIQUE` on email means the database enforces no duplicate emails — you don't have to check in application code.

#### Foreign Keys

A **foreign key** is a column that references the primary key of another table. It enforces referential integrity — you can't have an order for a user that doesn't exist.

```sql
CREATE TABLE orders (
  id         UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  total      NUMERIC(10,2) NOT NULL,
  status     VARCHAR(20)  NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
```

`ON DELETE CASCADE` means: if the user is deleted, all their orders are automatically deleted too. The alternative is `ON DELETE RESTRICT` (reject deletion if orders exist) or `ON DELETE SET NULL`.

#### One-to-Many Relationships

The most common relationship. One user has many orders. The "many" side holds the foreign key.

```
users                     orders
┌────────────────────┐    ┌────────────────────────────┐
│ id (PK)            │    │ id (PK)                    │
│ email              │◄───┤ user_id (FK → users.id)    │
│ name               │    │ total                      │
└────────────────────┘    └────────────────────────────┘
           1                         N
```

#### Many-to-Many Relationships — The Junction Table

When two entities have a many-to-many relationship (a student can enroll in many courses; a course can have many students), you need a **junction table** (also called a pivot table or association table).

```sql
-- Without junction table you'd have to store arrays, which is messy and unqueryable
-- Instead:

CREATE TABLE students (
  id   UUID PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE courses (
  id    UUID PRIMARY KEY,
  title VARCHAR(200) NOT NULL
);

-- Junction table
CREATE TABLE enrollments (
  student_id UUID NOT NULL REFERENCES students(id),
  course_id  UUID NOT NULL REFERENCES courses(id),
  enrolled_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (student_id, course_id)  -- composite PK prevents duplicate enrollment
);
```

```
students ─── enrollments ─── courses
   1              N:N             1
```

This lets you query: "all courses a student is enrolled in" with a JOIN, and "all students in a course" with another JOIN.

#### Normalization

Normalization is the process of structuring a schema to reduce redundancy. It's organized into "normal forms."

**First Normal Form (1NF):** No repeating groups in a column. Each column holds one value.

```sql
-- BAD (violates 1NF):
CREATE TABLE orders (
  id       UUID,
  products VARCHAR -- "product_1,product_2,product_3"  ← array in a string
);

-- GOOD: extract products to a separate table
CREATE TABLE order_items (
  order_id   UUID REFERENCES orders(id),
  product_id UUID REFERENCES products(id),
  quantity   INT NOT NULL
);
```

**Second Normal Form (2NF):** Every non-key column must depend on the _entire_ primary key, not just part of it. (Only relevant when you have composite primary keys.)

```sql
-- BAD: composite PK is (order_id, product_id), but product_name depends only on product_id
CREATE TABLE order_items (
  order_id     UUID,
  product_id   UUID,
  product_name VARCHAR,  -- ← depends only on product_id, not the full PK
  quantity     INT,
  PRIMARY KEY (order_id, product_id)
);

-- GOOD: product_name belongs in the products table
CREATE TABLE products (
  id   UUID PRIMARY KEY,
  name VARCHAR NOT NULL
);
CREATE TABLE order_items (
  order_id   UUID,
  product_id UUID REFERENCES products(id),
  quantity   INT NOT NULL,
  PRIMARY KEY (order_id, product_id)
);
```

**Third Normal Form (3NF):** No non-key column depends on another non-key column (no transitive dependencies).

```sql
-- BAD: zip_code determines city and state, creating a transitive dependency
CREATE TABLE users (
  id       UUID PRIMARY KEY,
  zip_code VARCHAR,
  city     VARCHAR,  -- ← determined by zip_code, not by id
  state    VARCHAR   -- ← same
);

-- GOOD: extract to a zip_codes lookup table
CREATE TABLE zip_codes (
  zip   VARCHAR PRIMARY KEY,
  city  VARCHAR NOT NULL,
  state CHAR(2) NOT NULL
);
CREATE TABLE users (
  id       UUID PRIMARY KEY,
  zip_code VARCHAR REFERENCES zip_codes(zip)
);
```

**When to denormalize:** Normalization is about write-time correctness. At scale, you sometimes _intentionally_ break 3NF for read performance. For example, a social media post might store the author's username directly on the post row so you don't need a JOIN on every feed read. This is called **denormalization**, and it's a deliberate, reasoned trade-off, not a mistake.

> **Senior signal:** "I'd start normalized and denormalize only if query performance demands it, with a clear understanding of the consistency implications — now the username can be stale if the user changes it."

#### 3.4.6 Concurrency Control — Optimistic vs Pessimistic Locks

> **Interview relevance: Core.** Almost any system design with "two users touching the same resource" requires this. Booking, inventory, payments, leaderboards, voting, even document collaboration. Knowing the two patterns + the deadlock-avoidance rules is required, not extra.

When two transactions can edit the same row, the database needs a way to serialize them. There are two philosophical approaches: assume the worst and lock (pessimistic), or assume the best and check at commit time (optimistic).

```
PESSIMISTIC LOCKING ("lock first, then read"):
  - The transaction takes a lock on the row before reading it.
  - Any other transaction trying to read FOR UPDATE blocks until the first commits.
  - Use case: high-contention resources where conflicts are likely.
  - SQL:
      BEGIN;
        SELECT * FROM appointments WHERE id = '...' FOR UPDATE;
        -- now this row is locked; no other tx can update it
        UPDATE appointments SET ... WHERE id = '...';
      COMMIT;
  - Pros:  guaranteed serialization; no surprise conflicts at commit time.
  - Cons:  blocks other readers/writers; can deadlock if locks are taken
           in different orders; can hurt throughput.

OPTIMISTIC LOCKING ("read, then check at write time"):
  - Add a version column to the table.
  - On UPDATE, require the version to match the value you read.
  - If someone else updated the row, the version changed; your UPDATE
    affects 0 rows; the application knows the update lost a race.
  - Use case: low-contention resources; many reads, few writes.
  - SQL:
      CREATE TABLE appointments (
        id      UUID PRIMARY KEY,
        version INT NOT NULL DEFAULT 0,
        ...
      );

      -- Read
      SELECT * FROM appointments WHERE id = '...'   -- version = 3

      -- Update with version check
      UPDATE appointments
      SET ..., version = version + 1
      WHERE id = '...' AND version = 3;
      -- if 0 rows affected, retry (re-read, re-validate, re-write)
  - Pros:  no blocking; scales well under low contention.
  - Cons:  wasted work if conflicts are common; the retry loop is the
           application's responsibility.
```

**When to use which — the rule of thumb:**

```
High contention (booking a hot seat, flash sale, last ticket):
  → Pessimistic with timeout + retry.
  → "I want to serialize access and pay the lock cost."

Low contention (user updates their profile, post edits):
  → Optimistic with version column.
  → "Most updates won't conflict; if they do, the user retries."

Distributed lock (cross-service, across DBs):
  → Redis SET NX with expiry + auto-renewer.
  → "I need a lock that survives across services; a DB row lock
     only works within one transaction."
```

**Deadlock avoidance — concrete rules:**

```
Rule 1: Lock in the same order in every transaction.
  → "Always lock account A first, then account B" — not the reverse.

Rule 2: Set a lock timeout.
  → MySQL: innodb_lock_wait_timeout = 5s
  → Postgres: SET LOCAL lock_timeout = '5s'

Rule 3: Make transactions as short as possible.
  → "Don't do API calls inside a DB transaction."

Rule 4: Use the lowest granularity lock you can.
  → Row locks > table locks. WHERE id = '...'  not the whole table.
```

> **Interview signal:** "I'd use optimistic locking for user profile updates (rarely conflict) and pessimistic for booking a specific appointment slot (definitely conflicts). If two services need to coordinate, I'd use a Redis lock with a TTL so a crashed service doesn't deadlock the system."

---

### 3.5 Indexes — What They Are and How They Work

This section was confusing before. We're going to build the concept from zero — starting with the problem indexes solve, then what an index physically is, then how composite indexes work step-by-step, and finally how to reason about them in an interview.

---

#### Step 1: The Problem — Why Queries Without Indexes Are Slow

Imagine your `appointments` table has 10 million rows. You run this query:

```sql
SELECT * FROM appointments WHERE patient_id = 'abc-123';
```

Without an index, the database has no idea which rows belong to `patient_id = 'abc-123'`. It has to do what's called a **full table scan**: it reads every single row in the entire table, one by one, checks if `patient_id` matches, and keeps the ones that do.

Reading 10 million rows takes time — potentially several seconds. If 1,000 users run this query simultaneously, the database grinds to a halt.

**Analogy:** Imagine you want to find every mention of "anxiety" in a 1,000-page textbook. Without an index (the kind at the back of the book), you'd have to read every single page. With the index, you flip to "A," find "anxiety → pages 14, 67, 203," and go directly to those pages.

**An index solves this exact problem for databases.** It's a separate lookup structure that lets the database go directly to the relevant rows without reading everything.

---

#### Step 2: What an Index Physically Is

An **index** is a separate data structure — stored separately from your table data — that the database maintains automatically. Every time you insert, update, or delete a row, the database also updates all indexes on that table.

The most common type is called a **B-tree** (balanced tree). You don't need to understand the computer science deeply, but here's the intuition:

A B-tree is like a sorted, self-organizing lookup structure. Imagine you're looking for `patient_id = 'abc-123'` in a sorted list of patient IDs:

```
Index on appointments.patient_id (simplified as a sorted list):

  [aaa-001]  → points to row at disk position 4,203
  [aaa-456]  → points to row at disk position 17,891
  [abc-100]  → points to row at disk position 3,044
  [abc-123]  → points to row at disk position 9,117  ← found it!
  [abc-124]  → points to row at disk position 2,991
  ...
  [zzz-999]  → points to row at disk position 45,003
```

Each entry in the index says: "here is the value of the indexed column, and here is exactly where on disk to find the full row."

The database uses a tree structure (not a flat list) to make lookups even faster — it can jump to the right part of the index without reading from the beginning. But the key insight is: **an index maps a value → a pointer to the row on disk**.

Without an index: read all 10M rows → check each one → find matches. O(n).
With an index: jump directly to matching entries → follow pointers to rows. O(log n).

---

#### Step 3: Creating an Index

```sql
-- Create a single-column index:
CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);

-- Now this query is fast:
SELECT * FROM appointments WHERE patient_id = 'abc-123';
-- The database uses the index to jump directly to matching rows.
```

You can also index multiple columns at once — this is called a **composite index**.

```sql
-- Composite index on two columns:
CREATE INDEX idx_appointments_patient_status ON appointments(patient_id, status);
```

This is where it gets more complex, and this is what caused confusion before. Let's build it up carefully.

---

#### Step 4: Composite Indexes — Building the Intuition

A composite index on `(patient_id, status)` is like creating a sorted list where you sort **first** by `patient_id`, and **within the same patient_id**, you sort by `status`.

Visualize it like this:

```
Composite index on (patient_id, status):

  patient_id = 'abc-123', status = 'cancelled'  → row pointer
  patient_id = 'abc-123', status = 'completed'  → row pointer
  patient_id = 'abc-123', status = 'pending'    → row pointer
  patient_id = 'abc-123', status = 'upcoming'   → row pointer
  patient_id = 'abc-456', status = 'completed'  → row pointer
  patient_id = 'abc-456', status = 'pending'    → row pointer
  patient_id = 'def-789', status = 'completed'  → row pointer
  ...
```

See the pattern? The index is sorted first by `patient_id`, then by `status` within each `patient_id`. This means:

**The index can only be used if you start from the left.** You can use the first column alone. You can use the first and second column together. But you cannot use only the second column to jump into the index — the index isn't sorted by `status` alone.

---

#### Step 5: The Phone Book Analogy — Why Left-to-Right Matters

This is the cleanest analogy. A phone book is sorted by last name first, then by first name.

```
Phone book sorted by (last_name, first_name):

  Chen, Alice
  Chen, Bob
  Chen, Carol
  Garcia, Ana
  Garcia, Bob
  Smith, Alice
  Smith, Bob
  Smith, Carol
  ...
```

**What you can look up quickly:**
- All people named "Smith" — ✓ (jump to the S section)
- "Smith, Bob" specifically — ✓ (jump to S, then to Bob within S)

**What you CANNOT look up quickly:**
- All people whose first name is "Alice" — ✗ (you'd have to read every page, because the book isn't sorted by first name globally)

The composite database index works exactly the same way. If your index is on `(patient_id, status)`:

```
✓  WHERE patient_id = 'abc-123'                    → uses the index (matches the first column)
✓  WHERE patient_id = 'abc-123' AND status = 'pending' → uses both columns of the index
✗  WHERE status = 'pending'                         → CANNOT use the index (skips the first column)
```

The query `WHERE status = 'pending'` must do a full table scan even though `status` is in the index, because the index isn't sorted by `status` alone — it's only sorted by `status` *within each patient_id*.

---

#### Step 6: Concrete Scenario — Appointment System

Let's make this real. You have this table:

```sql
CREATE TABLE appointments (
  id         UUID PRIMARY KEY,
  patient_id UUID NOT NULL,
  provider_id UUID NOT NULL,
  status     VARCHAR(20) NOT NULL,  -- 'pending', 'upcoming', 'completed', 'cancelled'
  scheduled_at TIMESTAMPTZ NOT NULL
);
```

And your app needs to run these queries:

**Query A:** "Show all appointments for patient abc-123"
```sql
SELECT * FROM appointments WHERE patient_id = 'abc-123';
```

**Query B:** "Show all upcoming appointments for patient abc-123"
```sql
SELECT * FROM appointments WHERE patient_id = 'abc-123' AND status = 'upcoming';
```

**Query C:** "Show all pending appointments across all patients" (admin dashboard)
```sql
SELECT * FROM appointments WHERE status = 'pending';
```

**What index(es) should you create?**

For Query A and Query B, a composite index on `(patient_id, status)` works perfectly:
```sql
CREATE INDEX idx_patient_status ON appointments(patient_id, status);
-- Query A: uses patient_id prefix → fast
-- Query B: uses patient_id + status → fast
```

For Query C, that same index does NOT help. You need a separate index:
```sql
CREATE INDEX idx_status ON appointments(status);
-- Query C: uses status → fast
```

So you'd end up with two indexes: one for patient-specific queries, one for admin queries. Each one serves different access patterns.

---

#### Step 7: The Write Cost Trade-off

Here's the part that matters for system design decisions:

**Every index makes reads faster but writes slower.**

When you insert a new appointment:
- Without indexes: write one row to the table. Done.
- With 2 indexes: write one row to the table + update index 1 + update index 2. Three writes.

For a write-heavy system (like a logging service writing thousands of events per second), having many indexes can slow down writes significantly. This is why you don't "just add an index to everything" — you choose indexes based on your most critical queries.

```
Rule of thumb:
  Read-heavy system (social feeds, dashboards) → more indexes are fine
  Write-heavy system (logging, event streams)  → be selective with indexes
```

---

#### Step 8: How This Shows Up in an Interview

**Interviewer:** "Your appointment booking service is getting slow. Users are complaining that loading their appointment history takes 5 seconds. How would you investigate and fix this?"

**Bad answer:**
> "I'd add more servers."

**Good answer:**
> "The first thing I'd check is whether the query is doing a full table scan. In PostgreSQL I'd run `EXPLAIN ANALYZE` on the slow query — that shows the query plan and tells me if it's scanning the whole table or using an index. If it's doing a full scan on `patient_id`, I'd add an index on that column. If we're also frequently filtering by status in the same query, I'd make it a composite index on `(patient_id, status)`, with `patient_id` first because it's the higher-selectivity column that narrows down the result set the most. I'd also check if adding this index has a meaningful impact on write performance — if appointment writes are high-volume, I'd benchmark the trade-off."

**What the interviewer is evaluating:** Do you understand why a query is slow? Do you know what an index physically does? Do you understand the ordering rule for composite indexes? Do you know about write overhead?

---

#### Step 9: Index Summary (the shorthand, after the full explanation)

```
A composite index (A, B) behaves like a phone book sorted by A, then B within A.

Use it for:          WHERE A = ?
                     WHERE A = ? AND B = ?

Don't use for:       WHERE B = ?  (no index — full table scan)

Write cost:          Every index adds overhead to INSERT/UPDATE/DELETE
                     More indexes = slower writes
                     Fewer indexes = faster writes, slower reads
```

> **Senior signal in an interview:** "I'd create a composite index on `(patient_id, status)` with `patient_id` first, because it's the higher-cardinality column — it narrows the result set more than `status` would. I'd also run `EXPLAIN ANALYZE` in staging before deploying to confirm the index is actually being used and to check the write impact."

---

### 3.6 Sharding and Partitioning

A single database server has limits — CPU, RAM, and disk. **Sharding** is splitting your data across multiple database servers (shards), each owning a subset.

**Horizontal scaling** = more servers, each with a subset of data. (Sharding)
**Vertical scaling** = bigger server (more CPU, RAM). Simpler but has a ceiling.

#### Sharding Strategies

**Range-based sharding:** Divide data by a range of the shard key.

```
Shard 1: user_id 1       – 10,000,000
Shard 2: user_id 10,000,001 – 20,000,000
Shard 3: user_id 20,000,001 – 30,000,000
```

Problem: **hot spots**. If most traffic is for new users (high IDs), Shard 3 gets all the load while Shard 1 sits idle.

**Hash-based sharding:** Apply a hash function to the shard key.

```
shard = hash(user_id) % number_of_shards

user_id = "abc123" → hash → 847291 % 4 = 3 → Shard 3
user_id = "def456" → hash → 193847 % 4 = 1 → Shard 1
```

Distributes traffic evenly. Problem: adding or removing a shard requires rehashing all data — expensive.

**Consistent hashing:** Solve the rehashing problem. Place shard servers and data keys on a ring. Each key goes to the nearest server clockwise on the ring. Adding a new server only moves a fraction of keys (1/N on average), not all of them.

```
Ring (0–360°):
  Server A at 60°
  Server B at 180°
  Server C at 300°

Key hashes to 150° → goes to Server B (nearest clockwise)
Key hashes to 250° → goes to Server C
Key hashes to 20°  → goes to Server A

Add Server D at 120°:
  Keys from 60°–120° now go to D instead of B
  Everything else unchanged
```

> **Senior signal:** Mentioning consistent hashing unprompted when discussing "how you'd add shards to a growing system" is a clear differentiator.

#### Two More Sharding Strategies the Transcript Covers

**Directory-based sharding:** A lookup service maps each key to its current shard.

```
shard_directory:
  user_id "abc123"  → Shard 3
  user_id "def456"  → Shard 1
  user_id "ghi789"  → Shard 2
  ... (millions of entries)
```

✓ Any key can live on any shard — fine-grained control.
✓ Re-sharding only requires updating the directory, not moving data.
✗ The directory is a single point of failure (or a complex distributed system).
✗ One extra lookup per query (mitigated by caching the directory in memory).

Used when the shard key has weird distribution (e.g., enterprise customers with much more data than free users) and you want to override hashing.

**Geographical sharding:** Split the data by geography.

```
Shard "us-east":     users with US east-coast addresses
Shard "us-west":     users with US west-coast addresses
Shard "eu-central":  users in the EU
Shard "apac":        users in Asia-Pacific
```

✓ Latency to the user is minimized — their data lives in a nearby region.
✓ Compliance with data-residency rules (EU user data stays in the EU).
✗ Cross-region queries are slow and expensive (joining data across shards).
✗ "User moved from Berlin to Tokyo" requires a shard migration.

> **Interview tip:** "For a multi-region app with residency requirements, I'd shard by region. For a single-region app with uniform user load, hash-based is simpler and faster. For an enterprise SaaS where some customers are huge, directory-based lets us put the whales on dedicated shards." Naming the choice with its reason is the senior answer.

> **Sharding and the CAP theorem:** Sharding is fundamentally an AP choice (you accept that cross-shard queries may be eventually consistent). Trying to make a heavily-sharded system strongly consistent is a months-long, error-prone project. Design for it from the start, or don't shard.

#### 3.6.1 Federation vs Sharding — Two Different Splits

> **Interview relevance: Core.** "When do you split into microservices vs shard the DB?" comes up any time the interviewer pushes on the data layer. Knowing the two are different dimensions (and that microservices naturally *are* federation) is a frequent differentiator.

The word "federation" gets used interchangeably with sharding, but they split data along different dimensions. Microservices and sharding are not the same pattern.

```
SHARDING (horizontal split, same schema):
  You have ONE big table (e.g., users). You split its ROWS
  across N database servers. Each server has the same schema;
  each server holds 1/N of the data.
  Goal: scale a single data type beyond one server can hold.

  users_shard_1:  user_id 1-1M
  users_shard_2:  user_id 1M-2M
  users_shard_3:  user_id 2M-3M
       (same users table, partitioned by user_id)

FEDERATION (functional split, different schemas):
  You split your data into different databases, each owned
  by a different SERVICE. Each database has a different
  schema. The "split" is by domain, not by row.
  Goal: service autonomy; different data lives in different places.

  users_service    → users_db    (users table)
  orders_service   → orders_db   (orders + order_items tables)
  products_service → products_db (products + inventory tables)
  payments_service → payments_db (transactions + payouts tables)

  Each service OWNS its data. Other services cannot write to
  it directly; they call the service's API. This is the
  microservices pattern.
```

| | Sharding | Federation |
|---|---|---|
| Splits | Rows of the same table | Different tables (different domains) |
| Schema | Identical across shards | Different per database |
| Owner | Usually a single service / app | Different services own different DBs |
| Cross-cutting joins | Possible but expensive (cross-shard query) | Not possible without API call (eventual consistency) |
| Used when | One table is too big for one server | The product is naturally split into bounded contexts |
| Concrete example | Instagram splitting the `users` table by user_id across 1000 MySQL shards | An e-commerce platform with users, orders, products, payments as 4 services with 4 DBs |

> **The natural connection:** When you adopt microservices, you *naturally* get federation. Each microservice gets its own database; that's the rule. If the same database is shared between two services, they are not really microservices — they are a distributed monolith.

> **When federation is the wrong call:** When the data is naturally cross-cutting and the services constantly need to JOIN. In that case, the "microservices" have become a distributed monolith with all the cost and none of the benefit.

#### 3.6.2 Logical Partitioning (Same Server, Different Buckets)

> **Interview relevance: Differentiator.** Almost never asked directly, but if you mention "I'd partition the events table by month in Postgres" while discussing an event-heavy system, that's a senior moment. Most candidates skip past partitioning and go straight to sharding.

Logical partitioning is NOT sharding. The data lives on the same database server, but is split into "partitions" the database manages internally. It's the cheapest form of data pruning and is the canonical tool for time-series data.

```
A single appointments table with range partitioning by month:

  appointments_2024_q1  →  rows where created_at in 2024-Q1
  appointments_2024_q2  →  rows where created_at in 2024-Q2
  appointments_2024_q3  →  rows where created_at in 2024-Q3
  appointments_2024_q4  →  rows where created_at in 2024-Q4

Query: "all appointments in Q3 2024"
  → The DB scans ONLY the 2024_q3 partition.
  → Other partitions are skipped (pruned).
```

**Why partition rather than shard:**

```
✓ Cheaper than sharding — single server, no network hops, no cross-partition transactions.
✓ Index per partition is smaller → queries on hot partitions are faster.
✓ Easy retention: DROP PARTITION for old months = O(1) data deletion.
✓ Supported by every major RDBMS: Postgres (declarative partitioning), MySQL, Oracle.

✗ Whole dataset still on one server — no horizontal scaling of write QPS.
✗ One slow query on a large partition can still hurt.
✗ Cross-partition queries still expensive.
```

**When to use logical partitioning:**

```
Time-series data (events, logs, telemetry, audit trails):
  Partition by day/month. Hot data is current; cold data is old.
  Old partitions can be detached and archived to S3 cheaply.

Multi-tenant data (SaaS with one big customers table):
  Partition by tenant_id. Each tenant's data is in one partition.
  Helps with noisy-neighbor problems (one huge tenant can't
  dominate all queries).

Reference data with skewed access:
  Partition by category. Hot categories get their own partitions.
```

> **Interview tip:** "For a 10-billion-row events table, I'd partition by day in Postgres (declarative partitioning). Queries on recent data hit only the latest partition. Old partitions are dropped or archived to S3. This buys 90% of the benefit of sharding at 5% of the complexity — until you outgrow it, then you shard."

---

### 3.7 Replication

**Replication** = keeping a copy of your data on multiple servers. Reasons:
1. **High availability** — if one server dies, another has the data
2. **Read scaling** — spread read queries across replicas

**Primary-replica (master-slave) replication:**

```
Writes → Primary ────► Replica 1 (read-only)
                  └──► Replica 2 (read-only)
                  └──► Replica 3 (read-only)

Reads ──────────────► any replica
```

**Synchronous replication:** The primary waits for at least one replica to confirm the write before acknowledging success to the client. **Zero data loss**, but higher write latency.

**Asynchronous replication:** The primary acknowledges the write immediately and replicates in the background. **Lower latency**, but if the primary crashes before replication, you lose recent writes.

**Replication lag:** The delay between a write landing on the primary and being visible on replicas. In async replication, this can be milliseconds to seconds. This causes the classic bug:

```
User updates profile photo
→ Write goes to primary
→ App immediately reads from replica to show updated profile
→ Replica hasn't caught up yet → user sees old photo
→ User refreshes → now it works (replica caught up)
```

Fix: read-your-own-writes (route reads immediately after a write to the primary, or route to replica only after a delay).

**Primary-primary (master-master) replication:**

```
Node A ◄──► Node B
writes     writes
   │           │
   └─────┬─────┘
         │
   both nodes accept writes and replicate to each other
```

**Why it's appealing:** Two regions can both accept writes — US users write to US, EU users write to EU, with low latency on both sides. No single write bottleneck.

**Why it's almost never used:**

```
✗ Conflict resolution is hard:
  Two users edit the same record on different nodes simultaneously.
  Which one wins? Last-write-wins (LWW) loses data; vector clocks are
  complex; CRDTs only work for some data types.
✗ Replication lag becomes bidirectional:
  Both nodes are behind each other; "is this write visible?" is ambiguous.
✗ Failure modes multiply:
  Split-brain: network partition → each node thinks it's the only survivor
  → both accept writes → unrecoverable divergence.
✗ Most apps can use a single-writer pattern:
  Pick the home region for writes; the other region is read-only with
  async replication. Avoids 90% of the conflict complexity.
```

> **Interview tip:** "I'd use primary-replica with a single primary in one region. If we need multi-region writes, I'd consider either (a) routing writes to the home region with the user knowing about the latency, or (b) per-tenant partitioning — different tenants in different regions, no cross-region write conflict. I'd avoid multi-master unless we had a specific, well-understood conflict-resolution strategy."

---

### 3.8 NoSQL Types — When to Use Each

**Document stores (MongoDB, Firestore):** Store JSON-like documents. Great when data is naturally hierarchical and you often read the whole document at once (e.g., a user profile with nested settings).

**Key-value stores (Redis, DynamoDB):** Lookup by key → get value. Extremely fast (Redis runs in-memory). Great for caching, sessions, leaderboards.

**Wide-column stores (Cassandra, HBase):** Like a spreadsheet with billions of rows and thousands of columns, but each row can have different columns. Designed for massive write throughput and time-series data. Used by Instagram for DMs and Uber for trips.

**Graph databases (Neo4j):** Entities are nodes, relationships are edges. Great for social graphs, recommendation engines, fraud detection (finding connected accounts).

#### In-Memory Databases — When Speed Beats Durability

**In-memory databases** (Redis, Memcached) keep all data in RAM. The "what is RAM" mental model from the transcript: RAM is ~100× faster than SSD and ~1000× faster than spinning disk, but it's volatile (loses data on power off) and expensive per GB.

```
Disk (HDD):     ~100-200 MB/s sequential read
SSD:            ~500-3500 MB/s sequential read
RAM:            ~5,000-50,000 MB/s
                and access times in nanoseconds (vs milliseconds for disk)
```

**Why in-memory:**

```
✓ Sub-millisecond reads
✓ Perfect for: caching, session storage, real-time leaderboards,
  rate limiting counters, pub/sub
✗ Volatile (data lost on restart, unless persistence is configured)
✗ Expensive (RAM costs more per GB than disk)
✗ Whole dataset must fit in RAM (cluster of 256 GB machines, not petabytes)
```

**Redis vs Memcached:**

| | Redis | Memcached |
|--|-------|-----------|
| Data structures | Strings, lists, sets, hashes, sorted sets, streams, geospatial | Strings only |
| Persistence | Optional (RDB snapshots, AOF log) | None |
| Replication | Built-in (primary-replica) | Client-side (the app writes to multiple nodes) |
| Pub/Sub | Yes | No |
| When to use | Default. Need rich data types or durability | Pure caching of simple key-value blobs at extreme scale |

> **Interview tip:** "I'd reach for Redis first. If we discovered we needed a million-cached-items-per-second throughput at minimum memory cost, and our values are simple strings, I'd evaluate Memcached for its lower memory overhead."

#### When to Reach for What — A Decision Tree

```
Q1: Does it need to survive a restart?
    No  → In-memory (Redis, Memcached)
    Yes → Continue

Q2: Is the data relational (joins, transactions, complex queries)?
    Yes → SQL (PostgreSQL, MySQL)
    No  → Continue

Q3: What's the access pattern?
    Key → key-value (Redis, DynamoDB)
    Document → document store (MongoDB, Firestore)
    Time-series / write-heavy → wide-column (Cassandra, HBase)
    Graph traversals → graph (Neo4j)
    Search / full-text → search engine (Elasticsearch)
    Analytics / aggregations → warehouse (Redshift, BigQuery)
```

> **Senior signal:** Being able to say *"for this requirement, I'd reach for X because of Y, and the alternative is Z with this trade-off"* is what separates the senior answer from "use Postgres." The tree above is the senior answer.

#### 3.8.1 NoSQL Family Use Cases — Real-World Examples

> **Interview relevance: Core.** Almost every system design asks "which database?" The wrong answer is "Postgres" by reflex. The right answer is "Postgres for the system of record, Redis for hot reads, Elasticsearch for search, S3 for blobs, Kafka for events" — naming the *family* per problem.

Don't pick a NoSQL family in the abstract. Pick the *problem*, then the family that fits.

```
KEY-VALUE (Redis, DynamoDB, Memcached, etcd):
  Pattern: "give me the value for this key, fast"
  Real-world:
    - Session store ("who is this user, what's their cart?")
    - Cache layer (the read-through front for the DB)
    - Rate-limit counters (INCR + EXPIRE)
    - Leaderboards (Redis sorted sets: O(log N) update + range query)
    - Distributed locks (Redis SET NX with expiry)
    - Pub/Sub (chat fan-out, presence)
    - Service discovery (etcd, Consul — same key-value shape)
    - Feature flags (DynamoDB single-row read)
  Tradeoff: limited query patterns (no JOINs, no range queries except
    on the key, no full-text).

DOCUMENT (MongoDB, Firestore, Couchbase, DocumentDB):
  Pattern: "give me this self-contained record with all its nested data"
  Real-world:
    - User profile (a profile + nested preferences + nested addresses)
    - Content management (a blog post + comments + tags as nested fields)
    - Product catalog (a product + variants + reviews + specs as nested)
    - Mobile app sync (Firestore is built on this exact pattern —
      the document IS the sync unit)
    - IoT device shadow (current state of a device + history)
  Tradeoff: flexibility is great until you need cross-document
    transactions; many document stores added them later (MongoDB 4.0+).

WIDE-COLUMN (Cassandra, ScyllaDB, HBase, Bigtable):
  Pattern: "give me the rows for this partition key, ordered by row key"
  Real-world:
    - Uber trip events (one row per event, partition by trip_id)
    - Instagram DMs (partition by conversation_id, row by timestamp)
    - IoT telemetry (partition by device_id, row by timestamp)
    - Time-series metrics (partition by metric + minute, row by sub-second)
    - Write-heavy product catalogs (Cassandra can absorb millions of writes/sec)
  Tradeoff: queries outside the partition key are expensive (full scan).
    You have to design the schema for the query, not the other way around.

GRAPH (Neo4j, Neptune, JanusGraph):
  Pattern: "find the relationships between these entities"
  Real-world:
    - Social network ("friend of friend of friend" queries)
    - Fraud detection (find connected accounts through shared devices/IPs/cards)
    - Recommendation engine (users who liked X also liked Y, traversing)
    - Knowledge graph (Google's Knowledge Graph is exactly this)
    - Access control (role → permission → resource traversal)
  Tradeoff: terrible for non-graph queries; don't use as your primary store.

SEARCH (Elasticsearch, OpenSearch, Solr, Meilisearch, Typesense):
  Pattern: "find documents matching this text, ranked by relevance"
  Real-world:
    - E-commerce product search
    - Log search (Datadog, Splunk, ELK)
    - Code search (GitHub)
    - Slack message search
    - Autocomplete / typeahead
  Tradeoff: not a system of record; always paired with a primary DB.
    Eventual consistency between primary and search index is the norm.

COLUMNAR / WAREHOUSE (Redshift, BigQuery, Snowflake, ClickHouse):
  Pattern: "scan billions of rows to compute an aggregate"
  Real-world:
    - Analytics dashboards
    - Ad-hoc analyst queries
    - ML training data preparation
    - Business intelligence reports
  Tradeoff: write throughput is poor compared to OLTP; this is the read side
    of a Lambda/Kappa architecture.
```

> **The "use Postgres for everything" trap:** Senior candidates sometimes say "I just use Postgres" to dodge the question. The senior *real* answer is "Postgres for the system of record; Redis for hot reads; Kafka for event flow; Elasticsearch for search; S3 for blobs; a columnar warehouse for analytics. Each tool does one thing well."

> **Common mistake:** Picking a NoSQL database because it's "modern" or "scales better" without naming the access pattern that requires it. A relational DB can scale to billions of rows with proper indexing. NoSQL is for *access patterns* relational doesn't serve well.

---

### 3.9 Module 3 — Quick Fire

| Question | Answer |
|----------|--------|
| What is a full table scan? | Reading every row in a table — happens when no usable index exists |
| What is an index, physically? | A sorted B-tree data structure separate from the table, mapping column values to row pointers |
| What is a foreign key? | A column that references another table's primary key, enforcing referential integrity |
| What does ACID stand for? | Atomicity, Consistency, Isolation, Durability |
| Sharding vs replication? | Sharding splits data across servers. Replication copies the same data to multiple servers |
| When does replication lag cause bugs? | When a user writes then immediately reads from a replica that hasn't synced yet |
| When to use NoSQL? | Flexible schema, massive write throughput, or data that's naturally hierarchical and not relational |
| Redis vs Memcached? | Redis has rich data types and optional persistence. Memcached is pure key-value strings, lower memory overhead, higher throughput ceiling |
| Why are in-memory databases fast? | RAM access is ~100× faster than SSD and ~1000× faster than HDD; but volatile and expensive per GB |
| Master-master vs master-slave replication? | Master-slave: one writer, many readers. Master-master: multiple writers, more conflict resolution, more failure modes |

---

## Module 4: Caching

> **Priority: HIGH.** Caching comes up in almost every system design interview. You need to be able to explain not just *that* you'd cache something, but *what* you'd cache, *where* the cache sits, *how* you'd fill it, *when* it expires, and *what happens* when it's wrong. This module covers all of it.

---

### 4.1 Why Caching Exists — The Core Problem

Let's start with the problem before the solution.

Imagine your app shows a therapist's profile page — their name, photo, specialties, years of experience, bio, and available hours. This data is read thousands of times a day by patients browsing profiles. But it almost never changes — maybe once when the therapist updates their bio.

Without caching:
- Every time a patient views the profile → the app queries the database
- Database reads the data from disk → sends it back → app renders it
- Each read takes ~10ms
- 10,000 profile views per day → 10,000 database queries → all unnecessary for data that never changes

With caching:
- The first time anyone reads the profile → the app queries the database, gets the data, and **stores a copy in the cache** (an in-memory store like Redis)
- Every subsequent read → the app asks the cache first → gets the data in ~0.1ms, without touching the database
- The cache stores the data for, say, 10 minutes. If the therapist updates their bio, the cache is cleared and the next read re-fetches fresh data.

**The core insight:** A cache is a fast, temporary copy of data that would otherwise require an expensive operation to retrieve. It trades **freshness** for **speed**. Cached data may be slightly out of date — that trade-off is acceptable for some data and completely unacceptable for others.

---

### 4.2 What Can (and Cannot) Be Cached

Before designing a cache, you must ask: **is this data safe to serve stale?**

```
Data that is fine to cache (stale for minutes or more):
  ✓ Therapist profile (name, photo, bio)
  ✓ Provider search results for a given specialty
  ✓ Static configuration (appointment types, session lengths)
  ✓ User preferences (notification settings, display name)

Data that must be fresh (never serve stale):
  ✗ Available appointment slots (a slot cached as "available" might already be booked)
  ✗ Payment status (you cannot show a patient the wrong charge amount)
  ✗ Session authentication tokens (security-critical)
  ✗ Any count that directly drives a business decision (remaining appointment credits)
```

This is the first thing you say in an interview when you introduce caching:

> "I'd cache therapist profiles and search results since they're read-heavy and change rarely. I would NOT cache slot availability — that needs to be read directly from the source of truth since two users might be looking at the same slot simultaneously."

---

### 4.3 What Redis Is (Before We Call It "the Cache")

In every system design, when people say "cache," they almost always mean **Redis**. Let's understand what it actually is.

Redis is an in-memory data store. "In-memory" means all its data lives in RAM, not on disk. RAM is ~100x faster to read than disk. This is why Redis queries take 0.1ms while database queries take 10ms.

Redis stores data as key-value pairs. A key is a string identifier; a value can be a string, number, list, set, hash (dictionary), etc.

```
Redis examples:

Key: "therapist:profile:dr-smith-123"
Value: '{"name": "Dr. Smith", "specialty": "anxiety", "photo_url": "..."}'

Key: "user:session:abc-token-xyz"
Value: '{"user_id": "patient-456", "expires_at": "2026-03-16T10:00:00Z"}'

Key: "search:specialty:anxiety:nyc"
Value: '[list of provider IDs matching this search]'
```

When your app needs therapist profile data, instead of querying PostgreSQL, it asks Redis: "give me the value for key `therapist:profile:dr-smith-123`." If the key exists, Redis returns it instantly from RAM. If it doesn't, the app queries PostgreSQL and stores the result in Redis for next time.

Redis is also where you'd store:
- User sessions (who is logged in, when their session expires)
- Slot hold locks (prevent double-booking)
- Rate limiting counters (how many requests has this user made this minute)
- Leaderboard scores (sorted sets)

---

### 4.4 TTL — Time-To-Live

A **TTL** (Time-To-Live) is the maximum age of a cached item. When a cache entry's TTL expires, it is automatically deleted. The next request for that data will be a cache miss, which triggers a fresh database read.

```
Redis with TTL:

  SET "therapist:profile:dr-smith-123" <value> EX 600
                                                  ↑
                                             expires in 600 seconds (10 minutes)

  After 10 minutes, Redis automatically deletes this key.
  The next request for this data will hit the database again.
```

**How to choose a TTL:**

```
Data that changes rarely (therapist profile):     600 seconds (10 min) or longer
Data that changes occasionally (search results):  60–300 seconds
Data that changes frequently (feed):              10–30 seconds
Session tokens:                                   hours (until logout or expiry)
Slot hold (prevent double-booking):               300 seconds (5 min — exactly long enough for the payment flow)
Rate limiting window:                             60 seconds
```

There is no universal answer. The TTL is a deliberate choice based on how stale you're willing the data to be.

---

### 4.5 Cache-Aside — The Most Common Pattern

"Cache-aside" is the pattern you'll use in most systems and the one you should default to in interviews. Let's build it step by step.

**The key idea:** The application code is in charge of the cache. The database is always the source of truth. The cache is just a shortcut.

**How it works on a read:**

```
Step 1: App receives request for therapist profile
Step 2: App asks Redis: "do you have key therapist:profile:dr-smith?"
Step 3a (cache HIT):  Redis says "yes" → app returns Redis data → done
Step 3b (cache MISS): Redis says "no"
Step 4:  App queries PostgreSQL → gets the profile data
Step 5:  App stores result in Redis with TTL 600
Step 6:  App returns the data to the client
```

Visually:

```
Request
  │
  ▼
App ──► Redis ──► KEY EXISTS? ──YES──► Return cached data
           │
           NO
           │
           ▼
        PostgreSQL ──► App stores in Redis ──► Return data to client
```

**How it works on a write (when the profile is updated):**

```
Step 1: Therapist updates their bio
Step 2: App writes new profile to PostgreSQL
Step 3: App DELETES the Redis key "therapist:profile:dr-smith"
  (do NOT write new data to Redis here — let the next read repopulate it)
Step 4: Next read will be a cache miss → fetches fresh data from PostgreSQL → stores in Redis
```

**Why delete, not update?** If you tried to write to both PostgreSQL and Redis simultaneously and one failed, they'd be out of sync. Deleting the cache key is safer — it forces the next read to get fresh data from the single source of truth.

**Pros:** Simple. Cache only contains data that's been read at least once (no wasted storage). Database is always authoritative.

**Cons:** The very first request after a cache miss (or TTL expiry) is always slow — it has to hit the database. This is called the **cold start problem**.

---

### 4.5.1 The Three Places a Cache Can Live

> **Why this section is here:** "Where does the cache go?" has three different answers depending on the use case. The transcript covers all three and you'll be expected to know which to reach for.

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Browser cache  →  on the user's local device                 │
│ 2. Server cache   →  on the API server (or a separate cache box) │
│ 3. Database cache →  inside the DB or in front of the DB        │
└─────────────────────────────────────────────────────────────────┘
```

#### 1. Browser Cache (Client-Side)

The browser stores copies of HTML, CSS, JS, images on the user's disk. On a revisit, the browser can load from local disk instead of asking the server.

```
First visit to https://app.com:
  Browser: GET /index.html
  Server:  200 OK + Cache-Control: max-age=7200
  Browser stores the file; for the next 2 hours, the browser
  uses the local copy without asking the server.

Cache-Control: max-age=7200  → cache for 7200 seconds (2 hours)
ETag: "abc123"               → revalidate when max-age expires
```

**How to check cache hit/miss in your browser:**

```
Open DevTools → Network tab → click a request
  → look at the size column: "(disk cache)" or "(memory cache)" = hit
  → look at response headers: "x-cache: HIT" or "x-cache: MISS"

Developers can disable cache from DevTools:
  Chrome: DevTools → Network tab → ☑ "Disable cache" checkbox
  Firefox: DevTools → Network tab → ⚙ "Disable cache" (when DevTools open)
```

**What's stored:** HTML, CSS, JS bundles, images, fonts. Not user-specific API responses (one user's data would be served to another).

**When NOT to rely on browser cache:** Any data that must be fresh (booking availability, payment status, auth state).

#### 2. Server Cache (Application / Distributed Cache)

This is the "Redis in front of PostgreSQL" pattern. The cache lives in the application tier — either in-process (in-memory in the app server), in a local cache (Caffeine, Guava), or in a distributed cache (Redis, Memcached).

**In-process vs distributed:**

```
In-process cache (e.g., Caffeine in Java, lru_cache in Python):
  ✓ Zero network hop, sub-microsecond
  ✗ Each app server has its own copy → inconsistent across servers
  ✗ Lost on app server restart
  ✗ Wastes memory on every server

Distributed cache (Redis, Memcached):
  ✓ Single source of truth across all app servers
  ✓ Survives app server restarts
  ✗ Network hop (~0.5-2ms in same datacenter)
  ✗ Needs its own cluster to manage
```

> **Interview tip:** "For sub-millisecond reads on truly hot data (e.g., a feature flag), I'd use a small in-process LRU cache *in addition to* Redis. For everything else, Redis is the default." This is the layered-cache pattern.

#### 3. Database Cache (Inside or In Front of the DB)

The database has its own caches you don't have to manage:

```
Buffer pool / page cache:
  - The DB holds recently-read disk pages in RAM
  - First read of a row: page goes from disk → buffer pool → query
  - Second read: page is already in the buffer pool, no disk I/O
  - Configured automatically; you just give the DB enough RAM

Query result cache (some DBs):
  - Caches the result of a SELECT, keyed by the query text
  - Invalidation is tricky (any write to the underlying table)
  - Most modern apps prefer an external cache (Redis) for clarity

Materialized views:
  - Pre-computed result of an expensive query, stored on disk
  - Refreshed periodically (every 5 min, every hour)
  - Great for "last 24 hours of bookings" dashboards
```

> **Interview tip:** "Tuning Postgres, I'd first check `shared_buffers` and `effective_cache_size` to make sure the buffer pool is large enough — the cheapest win in DB performance is letting Postgres keep hot pages in RAM." Knowing to look at DB internals is a senior signal.

#### The Cache Hit Ratio — The Single Number to Watch

```
Hit ratio = cache hits / (cache hits + cache misses)

90% hit ratio = 9 of 10 requests served from cache
99% hit ratio = 99 of 100 requests served from cache

A 99% hit ratio on a 10,000 RPS service:
  - 9,900 requests served from cache (fast, cheap)
  - 100 requests hit the database (slow, expensive)
  - 100x reduction in database load just from caching
```

> **Senior signal:** "I'd track cache hit ratio as an SLI. If it drops below 95% on the therapist profile cache, that signals something is wrong — either TTL is too short, the cache size is too small (evictions!), or upstream traffic patterns changed." Knowing which number to watch and what to do when it's wrong is the senior move.

---

### 4.6 Write-Through — Keeping Cache Always Warm

Write-through solves the cold start problem by populating the cache on every write, not just on reads.

**How it works:**

```
Write path:
  Step 1: Therapist updates their bio
  Step 2: App writes to PostgreSQL AND Redis simultaneously
  Step 3: Both succeed → return success to client
```

```
Read path:
  Step 1: App asks Redis for therapist profile
  Step 2: Almost always a cache HIT (because every write populated it)
  Step 3: Return data without touching PostgreSQL
```

**Pros:** The cache is almost always warm. No cold start.

**Cons:**
1. Every write is now two writes (PostgreSQL + Redis). Slightly higher write latency.
2. Cache may fill up with data that's never read again (you wrote it on update, but nobody read it).

**When to use:** When your system is very read-heavy and the cold start latency (from cache-aside) is unacceptable. Search index warming is a common use case.

---

### 4.6.1 Write-Around — Skip the Cache on Writes

The third write policy the transcript covers. Useful when writes happen to data that *isn't read often* — you don't want the cache polluted with cold entries.

```
Write path:
  Step 1: Therapist updates a rarely-read field (e.g., a "last_login" timestamp)
  Step 2: App writes directly to PostgreSQL ONLY
  Step 3: Cache is untouched
  Step 4: Next read will be a cache miss → fetches from DB → populates cache

Read path:
  Same as cache-aside.
```

**Pros:** Doesn't pollute the cache with data that may never be read again. Cheaper writes.

**Cons:** The first read after a write is always a cache miss → cold start. Same downside as cache-aside for write-then-immediate-read patterns.

**When to use:** When writes are mostly to data that won't be re-read soon (analytics ingest, audit logs, telemetry). You'd pair write-around with cache-aside reads.

> **Interview framing:** "If I have a user_last_seen field that gets updated on every API call but is read once a day by an admin dashboard, I'd use write-around. Putting it in the cache would evict more useful data and never get re-read."

---

### 4.7 Write-Back — Speed at the Cost of Safety

Write-back (also called write-behind) is the most aggressive caching strategy. You write to the cache only, immediately tell the client "success," and then asynchronously write to the database in the background.

```
Write path:
  Step 1: App receives write request
  Step 2: App writes to Redis only
  Step 3: App immediately returns "success" to client (before DB write!)
  Step 4: Background job flushes Redis → PostgreSQL every few seconds

Risk:
  If Redis crashes between step 3 and step 4, the data is LOST.
  The client was told "success" but the database never received it.
```

**When to use:** Only for data where losing a small amount of recent writes is acceptable. Examples: analytics counters, view counts, like counts on social media. You wouldn't use this for appointment bookings or patient records.

**In an interview:** Mentioning write-back and immediately saying "but I wouldn't use this for health records because of the data loss risk" shows you understand the trade-off, not just the pattern.

---

### 4.8 Eviction — What Happens When the Cache Is Full

Redis has a limited amount of memory (you configure it, e.g., 8 GB). When it's full and you add a new item, something old must be removed. This is called **eviction**.

Different eviction policies choose different items to remove:

**LRU — Least Recently Used**

Remove the item that hasn't been read for the longest time. The assumption is: if nobody has asked for this data recently, nobody will soon.

```
Cache after 10 items:
  [A] last read 9 min ago
  [B] last read 1 min ago
  [C] last read 8 min ago  ← LRU would evict this (wait, A was 9 min)
  [A] last read 9 min ago  ← LRU evicts this first

New item added → LRU removes [A] (oldest last access)
```

This is the default in Redis and the right choice for most systems. Data that was recently popular tends to stay popular.

**LFU — Least Frequently Used**

Remove the item that has been accessed the fewest total times, regardless of when.

```
Cache:
  [A] accessed 3 times
  [B] accessed 1,000 times
  [C] accessed 2 times  ← LFU evicts this first

New item added → LFU removes [C] (fewest total accesses)
```

Better when some items are structurally more popular than others (a celebrity's profile vs. an inactive user's profile). LFU retains the consistently popular items even if they weren't accessed in the last few minutes.

**For an interview:** Say "I'd use LRU as the eviction policy since it's the sensible default. If we found that a small number of profiles (popular therapists) were disproportionately popular, I'd consider LFU to protect those from eviction."

**FIFO — First In, First Out**

Remove the *oldest* item by insertion time, regardless of how often it's been accessed.

```
Cache:   [A inserted 9 min ago] [B inserted 5 min ago] [C inserted 1 min ago]
New item arrives → FIFO evicts A (oldest insertion)
```

Trivially simple to implement (a queue). Works for caches where the access pattern is "recent insertions are most likely to be read again soon" — which is the *opposite* of LRU's assumption. Almost always worse than LRU in practice, which is why it shows up mainly as a baseline in benchmarks.

> **Interview framing:** "I'd use LRU. FIFO is simpler but evicts based on age, not usefulness — an item that was just inserted but is being read heavily could be evicted before a stale item that hasn't been touched in an hour." Knowing *why* you'd pick LRU over FIFO is the senior signal.

---

### 4.9 Cache Stampede — When the Cache Makes Things Worse

Here's a failure mode that's not obvious: the cache itself can cause a crisis.

**Scenario:**

A popular therapist's profile is cached. 10,000 patients have it loaded. The TTL expires at 3:00pm. At 3:00pm:
- All 10,000 patients who had it cached now have a cache miss simultaneously
- All 10,000 send a database query at exactly the same moment
- The database, which was handling maybe 10 queries/second, suddenly gets 10,000 queries in one second
- It collapses

This is called a **cache stampede** or **thundering herd problem**.

**Solutions:**

**1. Mutex (lock):** When a cache miss happens, only one request fetches from the database. The others wait for that one request to finish and repopulate the cache.

```
Cache miss happens:
  Thread 1: acquires lock, fetches from DB, writes to cache, releases lock
  Thread 2: waits for lock
  Thread 3: waits for lock
  ...
  After Thread 1 finishes, others get the cached value → no DB stampede
```

**2. Jitter (random TTL variation):** Instead of all similar items expiring at the same time, add a small random offset to the TTL.

```
Without jitter: all therapist profiles expire at the top of every hour
  → stampede every hour

With jitter:
  Profile A: expires in 3600 + rand(0, 300) seconds = 3712 seconds
  Profile B: expires in 3600 + rand(0, 300) seconds = 3843 seconds
  Profile C: expires in 3600 + rand(0, 300) seconds = 3601 seconds
  → expirations spread out → no stampede
```

**3. Background refresh:** Before TTL expires, a background job proactively refreshes popular cache keys. The cache never actually goes empty for hot items.

#### 4.9.1 Negative Caching and Other TTL Tricks

> **Interview relevance: Differentiator.** Most candidates never think to cache a 404 or a "user not found." If the interviewer pushes on "what about scanner traffic?" or "what about a hot missing key?", naming negative caching with a TTL is a top-of-band moment.

> **Interview relevance: Differentiator.** Most candidates never think to cache a 404 or a "user not found." If the interviewer pushes on "what about scanner traffic?" or "what about a hot missing key?", naming negative caching with a TTL is a top-of-band moment.

Caches aren't just for hits. The most senior trick is caching *negatives*.

```
NEGATIVE CACHING:
  Store "this key is intentionally empty" with a short TTL.
  Used for: a 404 from the DB, a "user does not exist" lookup,
  a "no results" search response.

  → If a scanner hits the same missing URL 1000 times/sec,
    the cache absorbs 999 of them. The DB sees 1 lookup.

  Concrete example: a parking meter scanner pokes a payment API
  100x/sec for one car's plate. The first call returns 404. The
  next 99 calls in the next 30 seconds hit the cache.

SOFT TTL + HARD TTL:
  Soft TTL: the data is "stale" but still served (return fast).
  Hard TTL: the data is evicted, must be refetched.
  → Caffeine (Java), rdb (Python), BigCache (Go) implement this.

  Concrete: a product price cached for 5 minutes soft, 30 minutes hard.
    0-5 min:   serve from cache
    5-30 min:  serve stale + async refresh
    30+ min:   cache miss → DB lookup
```

#### 4.9.2 The Hit Rate → DB QPS Math

> **Interview relevance: Core.** When the interviewer asks "is a 90% hit rate good?" you need the answer: 10× reduction in DB load. 99% is 100×. This is the math that justifies the cache in the first place.

This is the most important caching math. Memorize it.

```
ORIGINAL DB QPS WITHOUT CACHE:
  read_qps = (DAU × reads_per_user_per_day) / 100,000

WITH CACHE:
  db_qps  = read_qps × (1 - hit_rate)
  cache_qps = read_qps × hit_rate

EXAMPLES (1M DAU, 20 reads/user/day = 200 read QPS):

  0%  hit rate →  200 QPS to DB
  50% hit rate →  100 QPS to DB
  90% hit rate →   20 QPS to DB
  95% hit rate →   10 QPS to DB
  99% hit rate →    2 QPS to DB   ← 100x reduction

  → 99% hit rate is the difference between a system that needs
    one DB and one that needs 50 DBs. It's a 100x cost difference.
```

> **Interview signal:** "With 99% hit rate, the DB sees 100x less load than without cache. That's the difference between needing one $100/mo DB and fifty. Cache hit rate is the single most important cache metric."

#### 4.9.3 Cache Sharding

> **Interview relevance: Differentiator.** Rarely asked, but if the cache itself is the bottleneck (e.g., 1M RPS to a hot key on one Redis shard), knowing you can shard the cache the same way you shard the DB is a top-of-band signal.

> When one Redis cluster is no longer big enough, you shard the cache the same way you shard the DB.

```
CACHE SHARDING:
  The cache key has a hash; the hash picks the shard.
  Standard pattern:  shard = hash(key) % N_shards

  Each shard is a Redis cluster (or a single Redis instance).

  Real-world:
    - Discord shards its session cache across many Redis nodes.
    - Twitter shards its timeline cache by user_id.
    - Pinterest uses memcached with consistent hashing across
      hundreds of nodes.

  Tradeoff:
    + horizontally scales read capacity
    - "scan all keys" becomes multi-shard (expensive)
    - "delete by tag" requires a tag index
```

#### 4.9.4 Multi-Level Cache

> **Interview relevance: Differentiator.** "Where does the cache live?" is sometimes asked. The L1/L2/L3/L4 pyramid is the right mental model — and saying "in-process (L1) + Redis (L2) + CDN (L4)" is a top-of-band answer vs "Redis."

The cache pyramid is a standard mental model.

```
L1  In-process (Java/Go/Node in-memory map, ~100ns)
    Use: a single hot value, a feature flag, a configuration value
    Size: KB to a few MB
    Risk: per-process; not shared; stale across instances

L2  In-memory distributed cache (Redis/Memcached, ~1ms)
    Use: shared session, hot product, popular post
    Size: GB
    Risk: network round trip; can be a bottleneck

L3  In-database cache / buffer pool (~1-10ms)
    Use: the DB's own internal cache of recently read pages
    Size: tens of GB
    Risk: not user-controllable; evicts based on DB heuristics

L4  Object storage / CDN (~10-100ms)
    Use: full-page HTML cache, large blobs, static assets
    Size: TB+
    Risk: high latency on cold reads
```

> **Why the pyramid matters in the interview:** When you say "I'll cache it," the interviewer asks "where?" Each level has a different latency, cost, and consistency story. Naming the *level* is senior; "I'll add a cache" is junior.

---

### 4.10 Where the Cache Sits in Your Architecture

There are actually multiple places you can add a cache layer. They serve different purposes.

**Level 1 — In the mobile app itself:**
```
Flutter app stores the last-fetched therapist list in memory (or local SQLite).
Next time the user opens the search screen, show the last result instantly
while the fresh data loads in the background.
→ This is client-side caching. It improves perceived performance on mobile.
```

**Level 2 — API server in-process cache:**
```
The Node.js or Go API server keeps a small in-memory dictionary.
Very hot data (like configuration, feature flags) can be cached here.
→ Zero network round trip. But lost when the server restarts.
→ Risk: different servers have different cache states.
```

**Level 3 — Shared distributed cache (Redis):**
```
All API servers share one Redis cluster.
Any server can read/write the same cache.
→ The main caching layer for most systems.
```

**Level 4 — CDN (for static content):**
```
Images, videos, and static files are cached at CDN edge servers worldwide.
→ The cache closest to the user's physical location.
→ Not appropriate for dynamic API responses.
```

In an interview diagram:

```
Mobile App → (local SQLite cache)
    ↓
CDN edge (for images/static assets)
    ↓
API Server → Redis (for profile data, sessions, locks)
    ↓
PostgreSQL (source of truth)
```

---

### 4.11 CDN — What It Is and Why Mobile Apps Need It

A **Content Delivery Network (CDN)** is a geographically distributed network of cache servers. The idea is simple: instead of every user in the world fetching a video from one server in Virginia, you cache that video on servers in São Paulo, London, Tokyo, and dozens of other cities. Users get the video from the nearest server.

```
Without CDN:
  Patient in São Paulo loads a therapist's profile photo
  Photo is stored on a server in Virginia
  Round trip: Brazil → Virginia → Brazil ≈ 150ms just for the network

With CDN:
  First request from Brazil: CDN edge in São Paulo fetches from Virginia, caches it
  Every subsequent request from Brazil: served directly from São Paulo ≈ 20ms
```

**What goes through a CDN:**
- Profile photos
- Video content (recorded therapy sessions, educational content)
- JavaScript and CSS bundles for web apps
- Fonts

**What does NOT go through a CDN:**
- API responses with user-specific data (the CDN would cache one user's data and return it to another)
- Real-time data (appointment availability, chat messages)

**For mobile engineers:** Every image your app displays should have a CDN URL, not a direct server URL. On a mobile connection, loading a 2 MB profile photo from a server on a different continent instead of a nearby CDN edge is the difference between 3 seconds and 200ms.

#### 4.11.1 CDN Cache Key Composition

> **Interview relevance: Differentiator.** Rarely asked at the cache-key level. Useful when the interviewer probes on "how do you handle per-user URLs" or "how do you cache different language versions." Names an actual production gotcha.

Most candidates say "the CDN caches URLs" and stop. The senior answer is that the CDN cache key is a *function* of the request — and you have to design that function.

```
DEFAULT CDN CACHE KEY:
  METHOD + URL + a few headers (varies by provider)

  Example: GET /hero.jpg
  Key:    "GET:/hero.jpg"
  → Every request to the same URL hits the same cached object.

CACHE KEY WITH QUERY STRING:
  Example: GET /hero.jpg?lang=en&v=2
  Key:    "GET:/hero.jpg?lang=en&v=2"
  → Different query strings = different cache entries.
  → CACHE BUSTING: append ?v=N when content changes.

CACHE KEY WITH VARIANT HEADERS:
  Example: GET /hero.jpg with Accept-Language: pt-BR
  Key:    "GET:/hero.jpg:Accept-Language:pt-BR"
  → Different language versions of the same image are cached separately.
  → This is how Cloudflare/Akamai serve globalized assets.
```

**The long-tail content problem and the "uncacheable URL" trap:**

```
A CDN loves 80/20 distributions:
  80% of traffic hits 1% of files (the "head").
  20% of traffic hits the remaining 99% (the "long tail").

  → The head is a perfect CDN use case.
  → The long tail evicts constantly; cache hit rate on the long tail
    is poor; you may serve most requests from origin anyway.

A CDN does NOT love:
  ✗ Per-user URLs: /u/12345/avatar.jpg — every URL is unique, no reuse.
  ✗ Signed URLs with short expiry: the cache evicts before the next request.
  ✗ Personalized responses: the cache returns User A's data to User B.
```

**Workaround for the per-user problem (signed URLs):**

```
The pattern:
  1. App asks the API for an avatar URL.
  2. API returns:
       "https://cdn.example.com/u/12345/avatar.jpg?Expires=...&Signature=..."
  3. The CDN sees a NEW URL → fetches from origin → caches it.
  4. Subsequent requests with the same signature hit the cache.
  5. When the signature expires, the URL changes → a new cache entry.

  → The CDN can still cache, but the "key" effectively includes
    a time window. Tune the expiry to match your traffic.
```

**CDN for dynamic content — the modern use case:**

```
A traditional CDN is a cache. A modern edge platform is a compute
layer that runs JavaScript/WASM at the edge, close to the user.

  Cloudflare Workers    →  JS at 200+ edge locations
  Lambda@Edge (AWS)     →  Node.js on CloudFront
  Fastly Compute@Edge   →  WASM at the edge

USE CASES:
  - Auth at the edge (verify JWT, reject bad requests, never hit origin)
  - A/B testing at the edge (route 10% to variant B without origin)
  - Geo-based content rewrite (return different HTML for EU users)
  - HTML caching with stale-while-revalidate (cache the page; refresh
    in the background; serve the cached version immediately)
```

#### 4.11.2 CDN for Video Streaming

> **Interview relevance: Differentiator.** Only relevant for video-streaming designs (YouTube, Netflix, Twitch). If asked to design one, this is a top-of-band section; otherwise, skim.

Video is its own CDN problem because the "file" is too big to download once. Streaming protocols let the user fetch small chunks as they watch.

```
HLS (HTTP Live Streaming) — Apple's protocol, industry standard:
  1. The source video is encoded at multiple bitrates (e.g., 480p, 720p, 1080p, 4K).
  2. Each bitrate is split into 2-10 second chunks (.ts files).
  3. A manifest file (.m3u8) lists the chunks and their bitrates.
  4. The client downloads the manifest, then requests chunks one at a time.
  5. The client can switch bitrates mid-stream based on bandwidth
     (adaptive bitrate streaming).

  → The CDN caches the .ts chunks. The manifest is updated as the
    stream progresses (live) or static (VOD).

DASH (Dynamic Adaptive Streaming over HTTP) — the MPEG standard:
  Same idea as HLS, but XML-based manifest (.mpd).
  Used by YouTube, Netflix, and most non-Apple platforms.

WHY THE CDN IS MANDATORY FOR VIDEO:
  A 1-hour 1080p video ≈ 2 GB.
  A 4K video ≈ 14 GB.
  Origin server can serve a few concurrent viewers. CDN can serve millions.
  Without a CDN, you cannot do video at scale.
```

---

### 4.12 Putting It All Together — Interview Dialogue

**Interviewer:** "Your appointment booking system is getting slow. Specifically, the therapist search results are taking 3 seconds to load. How do you fix this?"

**Strong candidate:**

> "First, let me understand the access pattern. Therapist search results — filtering by specialty, location, and availability — are read-only data that many patients query simultaneously. Availability changes occasionally, but profile data (name, specialty, bio) changes rarely. So there's a good caching opportunity here.
>
> I'd add Redis between the API server and the database. On a search request, the app first checks Redis for a cached result using the search parameters as the key — something like `search:specialty:anxiety:nyc`. If it's a hit, return it immediately. If it's a miss, query the database, store the result in Redis with a TTL of, say, 60 seconds, and return it.
>
> 60 seconds of stale search results is acceptable — if a new therapist joins, patients might see them with up to a 60-second delay, which is fine.
>
> One thing I'd NOT cache in this way: the actual slot availability. That needs to be real-time — a therapist's open slots shown to one patient must reflect bookings made by another patient a second ago. I'd keep availability reads going directly to the database, possibly with a read replica to spread the load."

**What the interviewer is evaluating:** Do you know what to cache and what not to? Do you know how to key a cache entry? Do you know about TTL? Do you call out the trade-off (stale data)?

---

### 4.13 Module 4 — Quick Fire

| Question | Answer |
|----------|--------|
| What is a cache? | A fast, temporary copy of data that would otherwise require an expensive operation |
| What is the fundamental caching trade-off? | Speed vs freshness — cached data may be stale |
| What is Redis? | An in-memory key-value store; the most common cache implementation |
| Cache-aside vs write-through? | Cache-aside: populated on reads. Write-through: populated on every write |
| What is TTL? | Time-To-Live — how long a cache entry lives before being automatically deleted |
| What is a cache miss? | The data isn't in the cache — must fetch from the database |
| What is a cache hit? | The data is in the cache — returned immediately |
| LRU vs LFU? | LRU removes least recently accessed. LFU removes least frequently accessed |
| What is a cache stampede? | When many requests simultaneously get a cache miss and all hit the database at once |
| What is a CDN? | A geographically distributed cache for static content — serves users from nearby servers |
| What should NEVER be cached? | Data that must be absolutely current — slot availability, payment state, auth tokens |
| Three places a cache can live? | Browser (on user's device), server (Redis in front of DB), inside the DB (buffer pool) |
| Cache-aside vs write-around? | Cache-aside: misses repopulate the cache on read. Write-around: writes skip the cache entirely |
| When would you use write-around? | For data that's written but rarely re-read (analytics, audit fields) — avoids polluting the cache |
| What's a good cache hit ratio target? | 95%+ for hot data. Below that, you have an eviction or TTL problem to investigate |

---

## Module 5: APIs & Communication Patterns

> **Priority: HIGH.** You use REST daily — this module covers what you likely don't know.

### 5.1 REST — What Makes a Good API

#### Idempotency — Explained From First Principles

This word trips people up constantly. Let's build the concept from zero.

---

**Step 1: What does "idempotent" mean in plain English?**

An operation is **idempotent** if doing it once produces exactly the same result as doing it two, three, or a hundred times.

In other words: **running it again doesn't cause extra side effects.**

The word comes from mathematics (idem = "same," potent = "power"), but the practical meaning is simple: you can safely repeat the operation without causing problems.

---

**Step 2: A non-technical analogy first**

Imagine two light switches:

**Switch A (idempotent):** You press it once — the light turns on. You press it again — the light stays on. Press it a third time — still on. Every press after the first has no additional effect. You could press it 100 times and the result is the same as pressing it once.

**Switch B (not idempotent):** You press it once — the light turns on. You press it again — the light turns off. Press again — on. Every press changes the state.

Idempotent operations are like Switch A. Pressing once or pressing many times — same result.

---

**Step 3: Examples from everyday life**

Before we get to APIs, here are three concrete examples of idempotent vs. non-idempotent operations:

**Example 1 (idempotent): Setting a value**
> "Set the thermostat to 22°C."
>
> Say it once — thermostat is at 22°C. Say it again — still 22°C. Say it 10 times — still 22°C. No matter how many times you repeat this instruction, the result is the same.

**Example 2 (not idempotent): Incrementing a value**
> "Turn up the thermostat by 1 degree."
>
> Say it once — 23°C. Say it again — 24°C. Say it 10 times — 32°C. Each repetition changes the state further. This is NOT idempotent.

**Example 3 (idempotent): Deletion**
> "Delete the appointment with ID abc-123."
>
> Run it once — appointment deleted. Run it again — appointment is still gone. The result of "appointment abc-123 does not exist" is the same regardless of whether you ran this once or ten times.

---

**Step 4: Idempotency in HTTP APIs**

Now apply this to API calls. HTTP methods have conventional idempotency properties:

**GET — idempotent:**
```
GET /therapists/dr-smith
→ Returns Dr. Smith's profile.

Call it 5 times → returns the same profile 5 times.
Nothing changes on the server. Safe to retry.
```

**PUT — idempotent:**
```
PUT /users/patient-123 {"name": "Alice Jones"}
→ Sets the user's name to "Alice Jones."

Call it 5 times → name is still "Alice Jones" after each call.
Repeating it doesn't create 5 users or change the name 5 times. Safe to retry.
```

**DELETE — idempotent:**
```
DELETE /appointments/appt-456
→ Deletes appointment appt-456.

First call: appointment deleted.
Second call: appointment is already gone — server responds "not found."
The *result* (appointment no longer exists) is the same. Safe to retry.
```

**POST — NOT idempotent:**
```
POST /appointments {"provider_id": "dr-smith", "time": "10:00am"}
→ Creates a new appointment.

First call: appointment #1 created.
Second call: appointment #2 created (a duplicate!).
Third call: appointment #3 created.

Repeating POST creates MORE resources. NOT safe to retry without a safeguard.
```

---

**Step 5: Why this matters so much on mobile**

This is where idempotency stops being academic and becomes critical to your daily work as a mobile developer.

**The real problem:** Network requests on mobile can fail silently.

Here's the scenario:

```
Patient books an appointment:

1. App sends POST /appointments to the server
2. Server processes the request → creates the appointment → writes to DB
3. Server tries to send the response back
4. [network drops here — the response never arrives]
5. App waits... times out
6. App shows: "Something went wrong. Please try again."
7. Patient taps "Try again"
8. App sends POST /appointments again
9. Server creates ANOTHER appointment (duplicate!)
10. Patient now has two appointments for the same slot
```

The app had no way of knowing whether step 2 succeeded. The server did the work but the confirmation was lost. When the user retried, the server couldn't tell this apart from a brand new booking.

**This is the core problem idempotency solves.**

---

**Step 6: Idempotency Keys — The Solution**

An **idempotency key** is a unique identifier the client generates before making the request, and sends along with it. The server uses this key to detect duplicates.

```http
POST /appointments
Idempotency-Key: 7f3c2a1b-4d5e-6f7a-8b9c-0d1e2f3a4b5c

{
  "provider_id": "dr-smith",
  "patient_id": "patient-123",
  "scheduled_at": "2026-03-20T10:00:00Z"
}
```

**How the server handles it:**

```
First time server sees key 7f3c2a1b...:
  → Process the request normally
  → Create the appointment
  → Store the result mapped to this key: {key → appointment_id, response_body}
  → Return the response

Second time (user retried after timeout):
  → Server sees key 7f3c2a1b... again
  → Look up stored result for this key
  → Return the SAME stored response — no new appointment created
  → Patient gets their confirmation; no duplicate
```

The client generates this key (typically a UUID) once, before the first attempt. It retries the same request with the same key. The server guarantees that no matter how many times the request arrives with the same key, the operation happens only once.

**Where the key comes from:** On mobile, generate a UUID when the user taps "Book." Store it in local state. Use it for all retry attempts for this booking.

---

**Step 7: Idempotency in Distributed Systems**

This concept also appears at the backend service level — not just in client-server APIs.

When services communicate with each other via message queues (Kafka, SQS, etc.), messages can be delivered more than once (this is called "at-least-once delivery" — covered in Module 7). A consumer service might receive the same "appointment booked" event twice.

If the consumer's job is to "send a confirmation email," receiving the event twice would send two emails to the patient. That's a bad user experience.

**Making the consumer idempotent:**

```
Consumer receives event: {appointment_id: "appt-789", event_type: "AppointmentBooked"}

Before processing:
  → Check database: "have I already sent an email for appointment appt-789?"
  → If yes: skip, acknowledge the message, do nothing else
  → If no: send the email, record "email sent for appt-789" in database, acknowledge

Result: Even if the event is delivered twice, only one email is sent.
```

The key is always the same: **check for the previous result before doing the work again.**

---

**Step 8: Bad vs. Good Explanation of Idempotency**

Here's what distinguishes a weak answer from a strong one in an interview.

**Weak answer:**
> "Idempotent means you can call it multiple times and it's safe."

This is not wrong, but it tells the interviewer nothing about your understanding. It's a definition without intuition.

**Strong answer:**
> "Idempotency means an operation produces the same outcome whether you run it once or a hundred times. On mobile, this is critical because network requests can time out after the server already processed them. If the client retries a non-idempotent operation like creating an appointment, it'll create duplicates. The solution is idempotency keys — the client generates a UUID before the request, sends it as a header, and the server maps that key to the result. On retry, the server detects the same key and returns the previous result instead of creating a new record. I'd also make any downstream consumers in a message queue idempotent for the same reason — at-least-once delivery means they might process the same event twice."

The difference: the strong answer includes the *why* (mobile network failures), the *mechanism* (idempotency keys), and the *broader application* (distributed message consumers).

---

**Step 9: How the interviewer might test this**

> **Interviewer:** "A patient tries to book an appointment. The request goes through, but the response never reaches the app. The patient taps 'Try again.' How do you prevent a duplicate booking?"

**Strong candidate:**
> "This is the idempotency problem. The client needs to generate an idempotency key — a UUID — before the first booking attempt and include it in the request header. On every retry, the same key is sent. The server, on receiving the first request, processes the booking and stores the result indexed by that key. On the second request with the same key, it checks its stored results, finds the key already exists, and returns the original response without creating a new booking. I'd store these idempotency records in Redis with a TTL of maybe 24 hours — long enough to cover any retry window, but not forever."

---

**HTTP Status Codes to know:**

```
200 OK              – Success (GET, PUT, PATCH)
201 Created         – Resource created (POST)
204 No Content      – Success, no body (DELETE)
400 Bad Request     – Client sent invalid data
401 Unauthorized    – Not authenticated
403 Forbidden       – Authenticated but not allowed
404 Not Found       – Resource doesn't exist
409 Conflict        – Conflicting state (duplicate, version mismatch)
422 Unprocessable   – Valid syntax but failed validation
429 Too Many Reqs   – Rate limited
500 Internal Error  – Server bug
503 Service Unavail – Server overloaded or down
```

**Pagination:** Cursor-based pagination is almost always better than offset for mobile.

```
# Offset pagination:
GET /posts?page=5&limit=20
Problem: if new posts are inserted while paginating, you get duplicates or skip items.
Also: to get page 5000, DB must scan and discard 100,000 rows.

# Cursor-based pagination:
GET /posts?after=cursor_abc&limit=20
Response: { posts: [...], next_cursor: "cursor_xyz" }
Stable — inserting new items doesn't affect other pages. O(1) to seek.
```

**HTTP Status Codes to know:**

```
200 OK              – Success (GET, PUT, PATCH)
201 Created         – Resource created (POST)
204 No Content      – Success, no body (DELETE)
400 Bad Request     – Client sent invalid data
401 Unauthorized    – Not authenticated
403 Forbidden       – Authenticated but not allowed
404 Not Found       – Resource doesn't exist
409 Conflict        – Conflicting state (duplicate, version mismatch)
422 Unprocessable   – Valid syntax but failed validation
429 Too Many Reqs   – Rate limited
500 Internal Error  – Server bug
503 Service Unavail – Server overloaded or down
```

**Pagination:** Cursor-based pagination is almost always better than offset for mobile.

```
# Offset pagination:
GET /posts?page=5&limit=20
Problem: if new posts are inserted while paginating, you get duplicates or skip items.
Also: to get page 5000, DB must scan and discard 100,000 rows.

# Cursor-based pagination:
GET /posts?after=cursor_abc&limit=20
Response: { posts: [...], next_cursor: "cursor_xyz" }
Stable — inserting new items doesn't affect other pages. O(1) to seek.
```

---

#### API Paradigms — REST vs GraphQL vs gRPC

> **Why this matters:** "What API style would you use?" is a very common design follow-up. The right answer isn't "REST" — it's "REST, *because* ..." with the trade-offs named.

| | REST | GraphQL | gRPC |
|--|------|---------|------|
| Wire format | JSON (usually) | JSON | Protocol Buffers (binary) |
| Transport | HTTP/1.1 (or HTTP/2) | HTTP/POST | HTTP/2 |
| Schema | Implicit, documented in OpenAPI | Strongly typed, single schema | Strongly typed, defined in `.proto` |
| Endpoint shape | Many URLs, one resource each | One URL, client specifies fields | One service, many methods |
| Caching | Easy (HTTP semantics) | Hard (everything is POST) | Hard (everything is POST over HTTP/2) |
| Browser support | Trivial | Trivial | Needs a proxy (grpc-web) |
| Best for | Public APIs, simple CRUD | Aggregating data from many sources, mobile clients with varying needs | Internal microservice-to-microservice |

**REST trade-offs:**

```
✓ Pros:
  - Easy to understand, easy to debug (curl + browser)
  - HTTP semantics: caching, status codes, idempotency, all free
  - Plays well with web, mobile, third parties
✗ Cons:
  - Over-fetching: GET /users/123 returns the full user object even
    when the client only needs the name
  - Under-fetching: to get a user + their last 5 orders, you make
    2+ requests (N+1 problem)
  - Adding new fields is easy; reshaping the response is hard
```

**GraphQL trade-offs:**

```
✓ Pros:
  - Client specifies exactly which fields it needs (no over/under-fetch)
  - One round-trip to fetch data spread across many resources
  - Strongly typed schema; auto-generates docs and client SDKs
✗ Cons:
  - Complex queries can hammer the database (no automatic N+1 protection)
  - All requests are POST; HTTP caching layers don't help
  - GraphQL errors return HTTP 200 with errors in the body —
    monitoring tools that key on 4xx/5xx miss them
  - Caching is per-query, not per-resource
```

**gRPC trade-offs:**

```
✓ Pros:
  - 3-10x smaller payloads than JSON (binary protobuf)
  - HTTP/2 multiplexing: many requests over one connection
  - Streaming (client, server, bidirectional) is built in
  - Strongly typed contracts enforced by .proto files
✗ Cons:
  - Not human-readable — debugging requires grpcurl or similar
  - Browsers can't natively speak gRPC; you need grpc-web + a proxy
  - Tooling is less ubiquitous than REST
```

> **Senior interview framing:** "For our public mobile API, I'd use REST — third parties consume it, browsers can hit it, and HTTP caching is valuable. For internal service-to-service calls between our Go booking service and Python payment service, I'd use gRPC — strongly typed, fast, and the team owns both ends so the learning curve is fine. I would *not* use GraphQL unless we had a clear aggregation problem (e.g., a screen that pulls from 6 services) — for a standard CRUD app, it adds complexity without payoff."

#### API Versioning — Don't Break Clients in Production

You will change your API. Old clients in production won't get the memo. You need a strategy.

```
URL versioning (REST):
  /api/v1/users/123     ← old clients
  /api/v2/users/123     ← new clients
  Both run side-by-side until v1 is deprecated (give 6-12 months notice)
  Easiest to reason about. Easy to route at the load balancer.

Header versioning:
  GET /api/users/123
  Accept: application/vnd.myapi.v2+json
  Cleaner URLs. Harder to test in a browser.

GraphQL: deprecate fields, don't break the schema
  type User {
    name: String @deprecated(reason: "Use fullName")
    fullName: String
  }
  Clients keep working; new ones use fullName.
```

> **Interview tip:** "If we change the user object in a way that breaks old clients, we'd ship v2 alongside v1. The mobile app would force-upgrade users on a deadline (the app store policy gives us 90 days). For the partners using our public API, we'd give 12 months notice and run both versions in parallel."

#### CORS — Why the Browser Blocks Your API

**Cross-Origin Resource Sharing (CORS)** is a browser security mechanism. By default, a web page on `https://app.com` *cannot* call an API on `https://api.app.com` — the browser blocks it as a same-origin policy violation.

```
Browser: "I'm on https://app.com trying to call https://api.app.com.
          Different origin. Unless the API says it's OK, I block this."

Server's response: "Access-Control-Allow-Origin: https://app.com"
Browser: "OK, the API explicitly allows this origin. Letting the request through."
```

> **Interview tip:** "For our public API, we'd set CORS to allow only our known front-end origins (https://app.com, https://admin.app.com), not `*` (everything). For server-to-server or mobile clients, CORS doesn't apply — it's a browser-only check." Mobile engineers often forget that CORS is a *browser* thing, not a security boundary.

#### Idempotency in GET Requests — Safe, Not Idempotent

A subtle but important distinction. The transcript makes a clean point that interviewers sometimes probe:

```
GET requests should be:
  - SAFE: calling them changes no server state. (No "this is the
          3rd time you pinged this endpoint" side effect.)
  - IDEMPOTENT: calling them many times returns the same result
                (within an acceptable staleness window).

A GET /api/therapists/123 is both safe and idempotent.
A GET /track-click?user=alice&ad=42 is NOT safe — every call
  logs a click event. Even though the *response* might be the same,
  the server's state changed.
```

> **Interview framing:** "If we need to track 'user clicked this,' that endpoint should be a POST (mutates state), not a GET. GETs are for reads that don't change anything."

#### Common Pagination / Filtering Patterns

```
Offset pagination (simple, painful at scale):
  GET /products?limit=20&offset=40
  Issue: if new products are added, results shift. Also O(offset) to seek.

Cursor pagination (recommended):
  GET /products?limit=20&after=cursor_xyz
  Stable, fast. Downside: can't jump to "page 5" directly.

Filtering:
  GET /orders?status=shipped&start_date=2026-01-01&end_date=2026-01-31
  GET /products?category=electronics&min_price=50&max_price=500
  Always set max bounds on filters to prevent abuse
  (e.g., limit=20 default, limit=100 max).
```

---

### 5.1.1 CRUD and Resource Modeling — The Basic Shapes

> **Why this section is here:** Every interview design includes some CRUD. The transcript walks through the canonical patterns; this is the version you can say out loud under pressure.

The heart of API design is mapping four operations onto URLs and HTTP methods. These four operations — Create, Read, Update, Delete — are the building blocks of any data-driven API.

| Operation | HTTP method | URL pattern | What happens |
|-----------|-------------|-------------|--------------|
| **Create** | `POST` | `/api/products` | Send new product details in the request body. Server creates, returns the new resource (with its generated ID). |
| **Read one** | `GET` | `/api/products/{id}` | Return a single product by ID. |
| **Read many** | `GET` | `/api/products` | Return a list. Usually with pagination and filtering. |
| **Update (full)** | `PUT` | `/api/products/{id}` | Replace the entire resource with the new representation. |
| **Update (partial)** | `PATCH` | `/api/products/{id}` | Send only the fields you want to change. |
| **Delete** | `DELETE` | `/api/products/{id}` | Remove the resource. Returns 204 No Content (typically). |

**Resource naming conventions:**

```
✓ Nouns, plural:    /api/products, /api/users, /api/orders
✗ Verbs:             /api/getProducts, /api/createUser

✓ Hierarchical for relationships:
  /api/users/{user_id}/orders
  → "the orders for this user"
  This implies a parent-child relationship. Don't go deeper than
  2 levels — deeper URLs get awkward and slow.

✗ Mixed concerns:
  /api/users/123/profile/avatar/upload
  → should be /api/users/123/avatar with POST (a single resource operation)
```

**Designing for relationships:**

```
One user has many orders:    /api/users/{user_id}/orders
One order has many items:    /api/orders/{order_id}/items
One product has reviews:     /api/products/{product_id}/reviews

Alternative: flat with query params
  /api/orders?user_id=123
  → useful when you want to filter across the relationship
  → less RESTful, but more flexible for complex queries
```

> **Interview tip:** "For our e-commerce API, the URL structure mirrors the resource hierarchy. A user's orders live at `/api/users/{user_id}/orders`. To get a single order, it's `/api/orders/{order_id}`. The flat-with-filter alternative (`/api/orders?user_id=...`) is fine for admin queries but doesn't reflect the user-facing mental model." This is the kind of clear design rationale that scores senior.

#### 5.1.2 BFF — Backend for Frontend

> **Interview relevance: Core.** When the prompt involves multiple client types (mobile + web + partner), BFF is a frequent follow-up. Naming the pattern and the use case (mobile BFF = lean payload, web BFF = rich, partner BFF = scoped auth) scores you points.

When mobile, web, and partner clients all hit the same API, the API becomes the lowest common denominator. The fix is a Backend for Frontend — a custom API tier per client.

```
THE PROBLEM:
  The mobile app wants a small JSON payload (low battery, slow network).
  The web dashboard wants a large JSON payload with related entities.
  The partner integration wants OAuth + rate limiting per partner.

  A single API endpoint can't serve all three well.
  You end up with: bloated mobile payload, missing web data, partner
  security baked into the main app.

THE BFF SOLUTION:
  One BFF per client type. Each BFF is a thin API layer that:
    - calls the underlying microservices
    - aggregates responses (e.g., 3 service calls → 1 mobile response)
    - shapes the data to the client's needs
    - enforces client-specific auth, rate limit, and observability

ARCHITECTURE:

  mobile_app   → mobile_bff   ─┐
                                ├──→ user_service
  web_app      → web_bff      ─┤    → order_service
                                ├──→ product_service
  partner_app  → partner_bff  ─┘    → payment_service

WHY IT MATTERS:
  - Mobile BFF returns 1KB of carefully shaped JSON instead of a
    generic 50KB response with 47 fields the app ignores.
  - Web BFF can pre-compute aggregations the web needs (e.g., "30-day order total").
  - Partner BFF can enforce partner-specific quotas without
    leaking partner logic into the main app.
  - The BFF is also a natural place for client-specific features:
    push notification token registration on mobile, OAuth flows
    on web, signed-request generation for partners.
```

> **The BFF vs API gateway distinction:** The API gateway is a *cross-cutting* layer (auth, rate limit, routing for ALL clients). The BFF is a *client-specific* layer (custom shapes, aggregations, behaviors). You usually have both: gateway in front, BFFs behind the gateway.

> **Interview signal:** "For a system with mobile, web, and partner clients, I'd put a BFF per client in front of the microservices. The mobile BFF returns lean payloads with binary compression; the web BFF returns rich aggregations; the partner BFF enforces partner-specific auth and quotas. The microservices behind them stay simple — they don't have to know who's calling."

#### 5.1.3 API Gateway vs Reverse Proxy vs Load Balancer

> **Interview relevance: Core.** Three boxes get conflated. Naming what each is and which layer it sits at is a frequent interview trap. The combination diagram (CDN → Gateway → Reverse proxy → LB → app) is a strong opener.

These three boxes get conflated. They have different jobs.

```
REVERSE PROXY (NGINX, HAProxy, Envoy):
  Job: terminate TLS, forward HTTP requests to backend servers.
  Knows: HTTP. Doesn't know: who the user is, what the API does.
  Where: directly in front of app servers.

API GATEWAY (Kong, AWS API Gateway, Apigee):
  Job: ALL of reverse proxy + per-route auth, rate limiting,
       transformation, aggregation, observability.
  Knows: HTTP, the API surface, the user, the rate limit, the contract.
  Where: at the public edge, in front of all services.

LOAD BALANCER (AWS ALB, GCP LB, F5):
  Job: distribute traffic across N servers based on a strategy
       (round-robin, least-conn, IP-hash).
  Knows: TCP/HTTP, server health. Doesn't know: the API surface.
  Where: anywhere traffic forks to N backends.
```

**How they combine in a production stack:**

```
  Internet
     │
  ┌──▼──────────┐   Layer 7 LB (or CDN edge) — terminates TLS, applies WAF,
  │  CDN/WAF    │   rate limits per IP, blocks junk.
  └────┬────────┘
       │
  ┌────▼─────────┐   API Gateway — per-route auth, per-user rate limit,
  │  API Gateway │   per-tenant quota, request transformation.
  └────┬─────────┘
       │
  ┌────▼─────────┐   Reverse Proxy / Service Mesh sidecar — TLS termination
  │  Reverse     │   inside the cluster, retries, circuit breaking.
  │  Proxy       │
  └────┬─────────┘
       │
  ┌────▼─────────┐   Load Balancer — distribute across N instances of
  │  Load        │   the app service within a region.
  │  Balancer    │
  └────┬─────────┘
       │
  ┌────▼─────────┐
  │ App Service  │   The actual business logic.
  │ (N instances)│
  └──────────────┘
```

> **The interview trap:** "I'll put a load balancer in front." Senior candidates clarify the *type* and *layer*. Saying "a reverse proxy with WAF rules" or "an API gateway with rate limits" is more specific and more senior than "a load balancer."

---

**State codes for CRUD:**

```
201 Created    – POST that created a new resource (include Location header)
200 OK         – GET, PUT, PATCH, or DELETE that returned data
204 No Content – DELETE (or any operation with no body to return)
400 Bad Request – Malformed request (bad JSON, missing field)
404 Not Found   – ID doesn't exist
409 Conflict    – Trying to create something that already exists, or version mismatch
422 Unprocessable – Valid JSON, but failed business rules (e.g., negative price)
```

#### What Goes in the URL vs the Body vs the Headers

```
URL path:        the resource identity    /api/products/123
URL query:       filtering, sorting, paging  ?category=books&limit=20
Headers:         metadata about the request  Authorization, Content-Type,
                                              Accept, If-Match (for optimistic locking)
Request body:    the resource itself         { "name": "...", "price": ... }
```

> **Interview tip:** "The path identifies *what*, the query string filters and shapes, the headers carry auth and conditional logic, and the body carries the data. Mixing these up (e.g., putting auth in the body, or filtering data in the path) is a common API design mistake."

---

### 5.2 WebSockets vs Server-Sent Events vs Long Polling

| | Long Polling | Server-Sent Events (SSE) | WebSockets |
|--|---|---|---|
| Direction | Client asks, server holds | Server → Client only | Bidirectional |
| Connection | New HTTP per poll | Persistent HTTP | Persistent TCP |
| Overhead | High (reconnect each time) | Low | Lowest |
| Use case | Notifications (simple) | Live feeds, dashboards | Chat, real-time collab |
| Mobile battery | Poor | Good | Good (fewer keepalives needed) |
| Firewall-friendly | ✓ | ✓ (HTTP) | Sometimes blocked |

**Long Polling** (how you might explain it):
```
Client: "Any updates?" → Server holds the connection open for 30 sec
  → If update: Server responds immediately
  → If no update: Server responds "nothing" after 30 sec timeout
  → Client immediately asks again
```

**WebSockets** are a full-duplex protocol. After an HTTP handshake, the connection is upgraded to TCP-level communication where both sides can send at any time. Used by WhatsApp, Slack, Google Docs.

> **Mobile battery note:** A persistent WebSocket connection prevents the mobile radio from going to sleep (consumes battery). For apps where real-time is critical, this is acceptable. For background sync, prefer push notifications over persistent sockets.

#### 5.2.1 MQTT for IoT and WebSocket at Scale

> **Interview relevance: Differentiator.** MQTT only matters for IoT prompts; the WS-at-scale section (connection table, sticky session by user_id) is the senior detail for chat/live-tracking prompts. Pick what's relevant to the question.

The choice between WebSocket, SSE, and MQTT depends on the *device*, not just the architecture.

```
MQTT (Message Queuing Telemetry Transport):
  Lightweight pub/sub protocol designed for constrained devices.
  ✓ Tiny packet overhead (~2 bytes header).
  ✓ Battery-friendly (sleeps most of the time, wakes for messages).
  ✓ Runs over TCP. Quality of Service levels (0/1/2).
  ✗ Not for browser-to-server (browsers don't speak it natively).
  Use: IoT sensors, smart home devices, fleet telemetry, industrial sensors.
  Concrete: AWS IoT Core, Azure IoT Hub, HiveMQ, Mosquitto.

WHEN TO USE EACH REAL-TIME PROTOCOL:

  WEB BROWSER CHAT/LIVE FEED:
    → WebSocket (the only persistent bidirectional option in browsers).

  MOBILE CHAT (foreground):
    → WebSocket over TLS. Battery impact is acceptable while in use.

  MOBILE BACKGROUND NOTIFICATIONS:
    → APNs/FCM (push). Don't try to keep a WebSocket alive in the
      background — the OS will kill it.

  LIVE DASHBOARD (server pushes updates):
    → SSE is simpler than WebSocket. One-way, low-overhead, browser-native.

  IOT DEVICE TELEMETRY:
    → MQTT (battery-friendly, tiny overhead, broker handles backpressure).

  HFT / GAMING (lowest latency):
    → UDP multicast or WebRTC data channels.
```

**WebSocket at scale — the connection problem:**

```
THE PROBLEM:
  10M concurrent WebSocket connections.
  A single server can hold 100K connections (Linux ulimit, file descriptors,
  memory per connection, ephemeral port exhaustion).
  → Need 100+ WebSocket servers.

  Now: how do you route a message to a specific user?
  - User Bob is connected to server #37.
  - The chat service wants to send Bob a message.
  - The chat service needs to look up "which server has Bob?"
  - Solution: a connection table in Redis.
    key: user_id → value: server_id
    - Set on connection open.
    - Read on every message send.
    - TTL on the key (heartbeat-driven).
```

> **Senior signal:** "At 10M concurrent connections, we'd shard the WebSocket gateway by user_id. The connection table in Redis maps user → server. The chat service looks up the server before sending. The gateway auto-scales on connection count, not CPU. Idle connections (no message in 60s) are evicted to free memory."

#### 5.2.2 SSE vs WebSocket — When SSE Wins

> **Interview relevance: Differentiator.** Candidates default to WebSocket. Knowing SSE is simpler for one-way push (live ticker, build status, location feed) is the senior moment. Rarely asked as a topic, but the right answer when the data is one-way.

```
SSE (Server-Sent Events):
  Server → Client only. One-way.
  ✓ Simpler than WebSocket (one HTTP connection, no upgrade).
  ✓ Auto-reconnect built-in.
  ✓ Works through HTTP proxies (no upgrade).
  ✓ Browser-native EventSource API.
  ✗ One-way (client can't easily send back).
  ✗ Max 6 connections per browser (HTTP/1.1 limit; HTTP/2 lifts this).

USE SSE WHEN:
  - The data flows server → client only.
  - Examples: live stock ticker, news feed, build status, location
    updates from a fleet, live sports score, log tail in browser.
  - Senior move: "I'd use SSE for our build pipeline's live status.
    No need for the full WebSocket overhead; the data is one-way."

USE WEBSOCKET WHEN:
  - The client also sends data frequently.
  - Examples: chat, collaborative editing, multiplayer games, trading.
```

---

### 5.3 gRPC

**gRPC** is a high-performance RPC (Remote Procedure Call) framework by Google. Instead of JSON over HTTP/1.1, it uses:
- **Protocol Buffers (protobuf):** Binary serialization format — 3–10x smaller payload than JSON
- **HTTP/2:** Multiplexed requests over one connection, header compression, bidirectional streaming

```protobuf
// Define the service in .proto file:
service UserService {
  rpc GetUser(GetUserRequest) returns (User);
  rpc StreamEvents(EventFilter) returns (stream Event);  // Server streaming
}

message GetUserRequest { string id = 1; }
message User { string id = 1; string name = 2; string email = 3; }
```

**When to use gRPC:**
- Internal microservice-to-microservice communication (not public APIs)
- High-throughput, low-latency requirements
- Streaming use cases (real-time events, sensor data)

**When NOT to use gRPC:**
- Public APIs (browser support requires grpc-web proxy, complex)
- When you need human-readable payloads for debugging

---

### 5.4 Rate Limiting

**Rate limiting** = restricting how many requests a client can make in a time window, to prevent abuse and protect the backend.

**Token Bucket Algorithm:**

Imagine a bucket that holds N tokens. Tokens are added at a constant rate (e.g., 10/second). Each request consumes one token. If the bucket is empty, the request is rejected (429).

```
Bucket capacity: 100 tokens
Refill rate: 10 tokens/second

Normal user: consumes ~2 tokens/sec → bucket stays full → always allowed
Burst-y user: consumes 50 tokens instantly → allowed (burst absorbed)
Abusive user: consumes 100 tokens/sec → bucket empties quickly → rejected
```

**Leaky Bucket:** Requests enter a queue (the "bucket"). Requests are processed at a fixed rate, regardless of burst. Excess overflows (rejected). Smooths out bursts — used for traffic shaping, not burst-friendly.

**Implementation in Redis:**

```
Key: rate_limit:{user_id}
Algorithm (sliding window log):
  1. Remove timestamps older than 1 minute from sorted set
  2. Count remaining
  3. If count >= limit → reject (429)
  4. Else → add current timestamp, allow request
```

**On the mobile client (handling 429):**
- Read `Retry-After` header from 429 response
- Implement exponential backoff with jitter:

```dart
Future<void> retryWithBackoff(Future<void> Function() request) async {
  int attempt = 0;
  while (attempt < 5) {
    try {
      await request();
      return;
    } catch (e) {
      if (e is RateLimitException) {
        final delay = Duration(seconds: (1 << attempt) + Random().nextInt(1000));
        await Future.delayed(delay);
        attempt++;
      } else rethrow;
    }
  }
}
```

#### 5.4.1 Rate Limiting Algorithms — The Full Comparison

> **Interview relevance: Core.** "How would you rate limit?" is a near-guaranteed follow-up. Naming the algorithm (token bucket, sliding window, etc.) and the tradeoff matrix is required. The "where to enforce" subsection is a senior add-on.

The four canonical algorithms each have a different shape. Naming the algorithm is a senior move; "I'll rate limit" is a junior move.

```
FIXED WINDOW:
  Limit: 100 requests per 60 seconds. Reset at the top of the minute.
  Easy to implement (one counter per key per window).
  ✗ Boundary problem: 100 requests at 12:00:59 + 100 at 12:01:00
    = 200 requests in 2 seconds.
  Use when: simplicity matters more than precision.

SLIDING WINDOW LOG:
  Store every request timestamp in a sorted set.
  Count requests in the last 60 seconds.
  ✓ Smooth — no boundary problem.
  ✗ Memory grows with request count (high traffic = big sorted set).
  Use when: precision matters AND traffic is moderate.

SLIDING WINDOW COUNTER (interpolation):
  Combine the previous window's count with the current one's,
  weighted by how much of the previous window overlaps the sliding 60s.
  ✓ Smooth-ish. ✓ Cheap memory.
  ✗ Approximate.
  Use when: you need sliding-window precision at fixed-window cost.

TOKEN BUCKET:
  Bucket holds N tokens, refilled at R/second.
  Each request consumes 1 token. Bucket empty → reject.
  ✓ Burst-friendly (a full bucket absorbs a spike).
  ✓ Cheap (one counter + one timestamp per key).
  Use when: real APIs (AWS, GCP, Stripe all use this).
  Concrete: bucket=100 tokens, refill 10/sec → 100 burst + 10/s sustained.

LEAKY BUCKET:
  Requests enter a queue; processed at fixed rate; overflow rejected.
  ✗ NOT burst-friendly (queue overflows).
  ✓ Output rate is constant (good for traffic shaping).
  Use when: you need a constant egress rate, not a burst-tolerant one.
  Concrete: process webhook deliveries at exactly 100/s regardless of input.
```

| | Burst | Smooth | Memory | Used by |
|---|---|---|---|---|
| Fixed window | High | No | Cheap | Most basic systems |
| Sliding log | Low | Yes | High | Strict fairness |
| Sliding counter | Low | Approx | Cheap | Most production systems |
| Token bucket | High | Yes | Cheap | AWS, GCP, Stripe APIs |
| Leaky bucket | None | Yes | Cheap | Traffic shapers, webhook senders |

> **Interview signal:** "I'd use a token bucket in Redis: 100 token capacity, 10 tokens/sec refill, 1 token per request. This gives a 100-request burst tolerance with a 10-rps steady-state ceiling, which matches our normal-vs-abusive user pattern."

#### 5.4.2 Where to Enforce Rate Limiting

> **Interview relevance: Differentiator.** Names the layered rule (edge / gateway / application). Useful when the interviewer pushes on "where does rate limiting actually happen?" Top-of-band: saying "per-user in the gateway, per-business-rule in the app."

> The key insight: enforcement point matters as much as algorithm.

```
EDGE (CDN / WAF):
  Block the obvious junk before it touches your infra.
  Use: Cloudflare rate-limit rules, AWS WAF rate-based rules.
  Blocks: scanner traffic, layer-7 DDoS, geographic blocks.
  ✓ Free tier covers most abuse; zero infra cost.
  ✗ Coarse (per-IP, not per-user).

API GATEWAY:
  Per-user, per-tenant, per-API-key rate limits.
  Use: Kong, AWS API Gateway, Apigee, Cloudflare Gateway.
  ✓ Centralized, easy to update rules, observability.
  ✗ Single point of failure (mitigated by being a managed service).

APPLICATION:
  Per-business-logic rate limit (e.g., "10 booking attempts per user per minute").
  ✓ Most flexible, knows the business semantics.
  ✗ Costs app-tier resources to enforce.
```

> **The layered rule of thumb:** Edge for junk, gateway for per-user, application for business logic. Don't try to do business-logic rate limiting at the edge — the edge doesn't know what's a "booking attempt."

---

### 5.5 Networking Fundamentals — The Vocabulary You Need

> **Why this section is here:** System design interviewers drop terms like "TCP handshake," "DNS resolution," "firewall," and "private IP" casually. If you don't have crisp mental models for these, you freeze when a follow-up question lands on the network. This section is the cheat sheet.

#### IP Addressing — How Two Computers Find Each Other

An **IP address** is a unique identifier for a device on a network. Two main versions exist:

| | IPv4 | IPv6 |
|--|------|------|
| Bits | 32 | 128 |
| Example | `192.168.1.42` | `2001:0db8:85a3::8a2e:0370:7334` |
| Total addresses | ~4.3 billion | ~3.4 × 10³⁸ |
| Status | Still dominant, exhausting | The future, gradually rolling out |

**Public vs Private IPs:**

```
Public IP:  unique across the entire internet
            (your router has one; your phone carrier assigns one)
            Can be reached from anywhere in the world.

Private IP: unique only within your local network
            (your phone on home Wi-Fi is 192.168.1.42;
             your laptop might be 192.168.1.43;
             another home has the same 192.168.1.42 — no conflict)
            Routable only inside the LAN, not on the open internet.
```

**Static vs Dynamic IPs:** Static = permanently assigned to a device (servers usually have these). Dynamic = assigned by DHCP and can change over time (your laptop on coffee-shop Wi-Fi). Interviewers assume servers are static.

#### Packets — How Data Actually Travels

When two computers communicate, they don't send one big blob. They break the data into **packets**, each containing:

```
┌──────────────────────────────────────────────────┐
│ IP Header                                         │
│  - Source IP:      192.168.1.10                   │
│  - Destination IP: 93.184.216.34                  │
│  - Protocol:       TCP (6) / UDP (17)             │
├──────────────────────────────────────────────────┤
│ TCP/UDP Header                                    │
│  - Source port:    54321                          │
│  - Dest port:      443                            │
│  - Sequence / ACK numbers (TCP only)              │
├──────────────────────────────────────────────────┤
│ Application Data (HTTP, SMTP, SSH, etc.)          │
│  - "GET /api/therapists HTTP/1.1\r\n..."         │
└──────────────────────────────────────────────────┘
```

Packets can take different routes, arrive out of order, or get dropped. That's why we need a transport protocol on top of IP.

#### TCP vs UDP — The Two Transport Choices

| | TCP | UDP |
|--|-----|-----|
| Connection | **Connection-oriented** (handshake first) | **Connectionless** (just send) |
| Reliability | Guaranteed delivery, in-order, no duplicates | Best-effort, may lose or reorder |
| Speed | Slower (handshake + acknowledgments) | Faster (no overhead) |
| Header size | 20 bytes | 8 bytes |
| Use cases | HTTP, HTTPS, SSH, email, file transfer | Video calls, live streaming, DNS, gaming |

**The TCP three-way handshake** (worth knowing — interviewers ask):

```
Client                              Server
  │  ──── SYN (seq=x) ───────────►   │   "I want to connect, my seq is x"
  │  ◄─── SYN-ACK (seq=y, ack=x+1) ─ │   "OK, my seq is y, I expect x+1 next"
  │  ──── ACK (seq=x+1, ack=y+1) ─►  │   "Got it. Connection established."
  │                                   │
  │     Now data can flow, with ACK   │
  │     + sequence numbers keeping    │
  │     everything in order.          │
```

**TCP sequence numbers** are how TCP reassembles packets in the correct order. If packet 5 arrives before packet 4, the receiver buffers 5 and waits for 4. If 4 never arrives, it requests a retransmit. This is why a flaky network feels "sticky" rather than corrupted.

> **Interview framing:** "I'd use TCP for the booking API because correctness matters more than microseconds. I'd use UDP only for the live video stream of a therapy session — a dropped frame is fine, but reordering or delay would be jarring."

#### 5.5.1 Protocol vs API — The Distinction

> **Interview relevance: Differentiator.** Candidates conflate them. Knowing the envelope vs contract distinction is a quick differentiator; rarely asked but cleanly senior.

"Use HTTP" and "use REST" mean different things. The protocol is the transport; the API is the contract. Confusing them in an interview is a senior-engineer trap.

```
PROTOCOL (the envelope):
  The wire format and the rules for sending and receiving data.
  Examples: HTTP, HTTP/2, HTTP/3 (QUIC), TCP, UDP, gRPC, WebSocket, SMTP, MQTT.
  → How data gets from A to B.

API STYLE (the contract):
  The shape of the requests and responses; the semantics.
  Examples: REST, GraphQL, gRPC, SOAP, WebSocket message format.
  → What the data means and how it's organized.

PAIRS:
  HTTP (protocol) + REST (API style)  — the most common.
  HTTP (protocol) + GraphQL (API style).
  HTTP (protocol) + gRPC (API style) — gRPC is actually a framework, not a protocol.
  TCP (protocol) + custom binary protocol (API style) — high-performance systems.
  WebSocket (protocol) + STOMP or custom JSON (API style) — real-time apps.
```

> **Senior signal:** "The protocol is HTTP/2 over TLS; the API is REST with JSON payloads." Naming the protocol AND the API is more senior than just "use HTTP."

#### 5.5.2 HTTP/1, HTTP/2, HTTP/3

> **Interview relevance: Differentiator.** Naming the version (HTTP/2 from CDN, HTTP/3 for mobile) is a senior moment. Not required, but cheap to know.

Most candidates say "HTTP" and stop. The senior answer names the version.

```
HTTP/1.1 (1997):
  ✓ Text-based. Universal. Simple.
  ✗ One request per TCP connection (or queue them).
  ✗ Head-of-line blocking: slow request blocks the next one.
  ✗ Large headers repeated on every request.

HTTP/2 (2015):
  ✓ Binary framing.
  ✓ Multiplexed: many requests on ONE TCP connection, interleaved.
  ✓ Header compression (HPACK).
  ✓ Server push (server can send resources before client asks).
  ✗ Still uses TCP — head-of-line blocking at the TCP level remains.
  → Today: this is the default. Most CDNs terminate HTTP/1.1 from
    the client and speak HTTP/2 to the origin.

HTTP/3 (2022, in deployment):
  ✓ Replaces TCP with QUIC (UDP-based reliable transport).
  ✓ No head-of-line blocking per stream.
  ✓ Faster handshake (0-RTT possible).
  ✓ Better on lossy networks (mobile, satellite).
  → Use when: serving mobile users, real-time apps.
  → Status: Cloudflare, Google, Facebook all serve HTTP/3 today.
```

> **Interview signal:** "Our public API is served over HTTP/2 from the CDN to clients. The CDN terminates HTTP/1.1 from older clients and speaks HTTP/2 to the origin. For our mobile clients, we can opt into HTTP/3 for faster cold-start on cellular networks."

#### 5.5.3 Private Subnet Topology

> **Interview relevance: Differentiator.** The ALB-in-public-subnet / app-in-private / DB-in-isolated layout is the standard production answer. Not asked as a topic, but it shows up implicitly when you say "the database has no public IP."

```
THE STANDARD AWS / GCP SUBNET LAYOUT:

  ┌────────────────────────────────────────────────────────┐
  │  VPC: 10.0.0.0/16                                      │
  │                                                         │
  │  ┌──────────────────────────────────────┐               │
  │  │  Public subnet: 10.0.1.0/24          │               │
  │  │  Hosts:                              │               │
  │  │    - ALB (Application Load Balancer)  │               │
  │  │    - NAT Gateway (for outbound)       │               │
  │  │    - Bastion host (SSH in)           │               │
  │  │  Internet-facing, has public IPs.    │               │
  │  └──────────────────────────────────────┘               │
  │                                                         │
  │  ┌──────────────────────────────────────┐               │
  │  │  Private subnet: 10.0.10.0/24        │               │
  │  │  Hosts:                              │               │
  │  │    - App servers (ECS, EKS, EC2)     │               │
  │  │    - Internal services               │               │
  │  │  No public IP. Outbound via NAT GW.  │               │
  │  │  Inbound only from ALB.              │               │
  │  └──────────────────────────────────────┘               │
  │                                                         │
  │  ┌──────────────────────────────────────┐               │
  │  │  Isolated subnet: 10.0.20.0/24       │               │
  │  │  Hosts:                              │               │
  │  │    - RDS database                    │               │
  │  │    - ElastiCache (Redis)              │               │
  │  │  No public IP. No outbound.          │               │
  │  │  Inbound only from app servers.      │               │
  │  └──────────────────────────────────────┘               │
  │                                                         │
  └────────────────────────────────────────────────────────┘
```

**Why this matters in the interview:**

```
- "The DB is in an isolated subnet" → answers "what if someone tries
  to connect to the DB from the internet?" (They can't.)
- "App servers are in a private subnet" → answers "how does an
  attacker reach them?" (Only through the ALB, which has WAF rules.)
- "The ALB is the only public-facing component" → answers
  "what's the minimum attack surface?" (One component to harden.)
```

> **Senior signal:** "The database lives in an isolated subnet — no public IP, no outbound internet. The app servers are in a private subnet; they reach the internet for outbound (npm, GitHub) via the NAT gateway. The ALB is the only public-facing component, fronted by a WAF."

#### 5.5.4 TCP/UDP/RPC Cheat Sheet

> **Interview relevance: Differentiator.** TCP vs UDP comes up occasionally. QUIC and gRPC are nice-to-know senior moments.

```
TCP — Transmission Control Protocol:
  ✓ Reliable, ordered, error-checked.
  ✓ Connection-oriented (3-way handshake).
  ✗ Overhead (3-way handshake, ACKs, retransmits).
  Use: HTTP, HTTPS, SSH, file transfer, email, database protocols.
  Concrete: AWS NLB, gRPC, all major databases.

UDP — User Datagram Protocol:
  ✓ No handshake. Send and forget.
  ✓ Low latency. No retransmission overhead.
  ✗ No delivery guarantee. No ordering.
  Use: live video (WebRTC, Zoom), voice (VoIP), live gaming,
       DNS (yes, even DNS uses UDP), IoT telemetry, HFT multicast.
  Concrete: WebRTC uses UDP; HFT uses UDP multicast; DNS uses UDP.

QUIC (Quick UDP Internet Connections):
  ✓ UDP-based, but adds reliability and multiplexing.
  ✓ 0-RTT handshake (faster than TCP's 1-RTT).
  ✓ No head-of-line blocking per stream.
  ✓ Built-in TLS 1.3.
  → Use as: the transport under HTTP/3.

RPC (Remote Procedure Call):
  ✓ Function call over the network. The wire format is language-neutral.
  ✓ Schema-first (Protobuf, Thrift, Avro).
  ✓ Type-safe, fast, code-generated stubs.
  ✗ Tighter coupling than message-based systems.
  Use: service-to-service in microservices.
  Concrete: gRPC (the dominant one), Apache Thrift, Cap'n Proto, Avro.
```

> **The interview answer:** "For our service-to-service calls, I'd use gRPC over HTTP/2. Schema is defined in Protobuf; code-generated stubs in each language. For our public API, I'd use REST/JSON over HTTP/2 for compatibility with browsers and mobile clients. For our live presence feed, I'd use WebSocket over TLS."

#### 5.5.5 DNS — Record Types and TTL

> **Interview relevance: Differentiator.** Record types: skip. TTL tradeoff: useful when the interviewer asks "how fast can you fail over?" — answer is bounded by DNS TTL.

The "DNS" question can go from "what is it" to "what's a TTL tradeoff" in two questions. Be ready.

```
THE COMMON DNS RECORD TYPES:

  A:     maps a hostname to an IPv4 address.
         api.example.com → 203.0.113.42

  AAAA:  same, but IPv6.
         api.example.com → 2001:db8::1

  CNAME: maps a hostname to ANOTHER hostname (alias).
         www.example.com → example.com

  MX:    mail server for a domain.
         example.com → mail.example.com (priority 10)

  TXT:   free-form text. Used for SPF (email), domain verification,
         DKIM, site ownership, ACME challenges (Let's Encrypt).

  NS:    authoritative name servers for the domain.
         example.com → ns1.awsdns.com

  SRV:   service location (host + port).
         _sip._tcp.example.com → sip.example.com:5060
```

**TTL — the DNS tradeoff:**

```
SHORT TTL (60s - 300s):
  ✓ Fast failover (DNS change propagates in ~1 minute).
  ✗ More DNS queries (more load on resolvers, more cost).
  ✗ "Stale DNS" risk: some resolvers ignore TTL and cache longer.
  → Use for: production services, regions that fail over often.

LONG TTL (1 day - 1 week):
  ✓ Cheap (fewer queries).
  ✓ Consistent routing.
  ✗ Slow failover (the change takes hours to propagate).
  → Use for: static infrastructure that doesn't change.

THE GOLDEN RULE:
  Set TTL to be SHORTER than your worst acceptable failover time.
  If you need to fail over in 5 min, TTL must be <5 min.
```

> **Senior signal:** "For our primary region, I'd set DNS TTL to 60 seconds. That lets us fail over to the secondary region in ~2 minutes (TTL + propagation). For our static marketing site, TTL can be 24 hours — it's a CloudFront URL, it doesn't change."

---

### 5.6 Application-Layer Protocols — What Else Travels on the Wire

> **Why this matters:** In a design, you might say "we send a push notification" or "users get a video call" or "background jobs process uploaded files." Each of these has a specific protocol, and interviewers may ask why you picked it. This section maps the common ones.

| Protocol | Full name | Layer | Purpose | When to use in a design |
|----------|-----------|-------|---------|--------------------------|
| **HTTP/HTTPS** | Hypertext Transfer Protocol | App | Web requests, REST APIs | Default for client↔server communication |
| **WebSocket** | — | App (over TCP) | Bidirectional, persistent | Chat, live tracking, collaborative editing |
| **DNS** | Domain Name System | App | Name → IP resolution | Always (handled by the OS, but design around its latency) |
| **SMTP** | Simple Mail Transfer Protocol | App | Sending email | Outgoing email from your app to recipients |
| **IMAP** | Internet Message Access Protocol | App | Reading email (server-side sync) | When users need to read mail from multiple devices |
| **POP3** | Post Office Protocol v3 | App | Downloading email to one device | When mail is managed from a single device only (legacy) |
| **FTP** | File Transfer Protocol | App | Bulk file upload/download | Legacy file transfers; mostly replaced by SFTP / HTTPS |
| **SFTP / SSH** | Secure File Transfer / Secure Shell | App | Secure remote access, file transfer | Ops access to servers, secure file movement |
| **WebRTC** | Web Real-Time Communication | App (over UDP) | Browser/mobile peer-to-peer media | Video calls, voice calls, low-latency P2P |
| **MQTT** | Message Queuing Telemetry Transport | App | Lightweight pub/sub for IoT | Battery-constrained devices, sensors, telemetry |
| **AMQP** | Advanced Message Queuing Protocol | App | Robust enterprise messaging | RabbitMQ, enterprise service buses |
| **RPC** | Remote Procedure Call | App | "Call a function on another machine" | gRPC (HTTP/2 + protobuf), internal microservice calls |

**Email — the three-protocol combo:**

```
Sending:     your app ──SMTP──► mail server ──SMTP──► recipient's mail server
Reading:     recipient's mail client ──IMAP or POP3──► recipient's mail server

IMAP:  mail stays on the server; multiple devices stay in sync
POP3:  mail is downloaded and (usually) deleted from the server; single-device world
SMTP:  used only for sending, never reading
```

**WebRTC vs WebSocket — pick the right one for real-time media:**

```
WebSocket:  client ⇄ server only, good for chat/events
            (text + small payloads, low rate)

WebRTC:     client ⇄ client (peer-to-peer), good for media
            (audio + video, needs UDP, handles NAT traversal,
            built-in encryption, lower latency than a server relay)
```

A video-calling app usually combines both: WebRTC for the media stream, WebSocket for signaling (the "call Bob" handshake).

**MQTT vs AMQP vs Kafka — message protocols at a glance:**

```
MQTT:   tiny pub/sub protocol for IoT (a sensor publishing temperature
        over a 3G connection that goes to sleep between sends)
        → headers ~2 bytes, designed for unreliable networks.

AMQP:   feature-rich message-oriented middleware (RabbitMQ, etc.)
        → routing, queues, exchanges, acknowledgments. Enterprise-grade.

Kafka:  not really a wire protocol — a *distributed log* with its own
        protocol. High-throughput event streaming. (See Module 7.)
```

**RPC — the umbrella idea:**

```
RPC = "make a function call on another machine as if it were local."

gRPC:     Google's modern RPC framework (HTTP/2 + protobuf). The default
          for microservice-to-microservice communication inside Google,
          Netflix, Square, etc.

JSON-RPC, XML-RPC: older variants using JSON or XML over HTTP. Still seen
                   in legacy systems.

Inside any larger protocol (HTTP, SMTP, gRPC) you'll often find RPC-style
calls being made to backend services to do the actual work.
```

> **Interview tip:** "Why gRPC for internal services and REST for public APIs?" is a favorite question. gRPC is faster (binary, HTTP/2 multiplexed, strongly typed contracts via .proto) but hard to debug from a browser, so it stays inside your service mesh. Public APIs prioritize human-readable JSON, browser compatibility, and easy curl debugging.

---

### 5.7 Module 5 — Quick Fire

| Question | Answer |
|----------|--------|
| What is idempotency? | An operation that produces the same result no matter how many times it's called |
| Which HTTP methods are idempotent? | GET, PUT, DELETE. POST is NOT |
| Cursor vs offset pagination — key difference? | Cursor is stable (new inserts don't shift pages). Offset is not. Cursor is also O(1) seek |
| WebSocket vs SSE? | WebSocket is bidirectional. SSE is server→client only but simpler |
| gRPC vs REST? | gRPC uses binary protobuf + HTTP/2, faster for internal services. REST is JSON + HTTP/1.1, better for public APIs |
| Token bucket vs leaky bucket? | Token bucket allows bursts (up to capacity). Leaky bucket smooths all traffic to a constant rate |
| TCP vs UDP — when to use which? | TCP for correctness (HTTP, file transfer, email). UDP for speed and loss tolerance (video, live streaming, DNS) |
| What does the TCP three-way handshake do? | SYN → SYN-ACK → ACK establishes a reliable, ordered connection before any data flows |
| Public vs private IP? | Public is unique across the internet; private is unique only inside your LAN (e.g., 192.168.x.x) |
| What does a firewall protect? | Filters inbound/outbound traffic by IP/port rules; sits at network boundaries |
| DNS A record vs CNAME? | A maps domain → IPv4 address. CNAME maps domain → another domain (alias) |
| SMTP vs IMAP? | SMTP sends email. IMAP reads email while keeping it on the server (multi-device sync) |
| MQTT vs AMQP? | MQTT is tiny pub/sub for IoT/unreliable networks. AMQP is enterprise-grade message middleware (RabbitMQ) |
| WebRTC vs WebSocket? | WebRTC is peer-to-peer media (video/voice). WebSocket is client-server messages (chat/events) |
| CRUD → HTTP method? | Create=POST, Read=GET, Update=PUT (full) or PATCH (partial), Delete=DELETE |
| REST URL convention for listing items? | Nouns, plural: GET /api/products. Verbs in the URL are an anti-pattern |
| PUT vs PATCH? | PUT replaces the entire resource. PATCH sends only the fields to change |
| GraphQL vs REST for a public API? | REST is usually simpler. GraphQL wins when clients need to aggregate data from many sources with varying field selections |

---

## Module 6: Scalability Patterns

> **Priority: HIGH.** Every "how would you scale this?" question lives here.

### 6.0 The Three Pillars of System Design

> **Why this section is here:** Before you scale a system, you have to know what "good" means. The transcript names three pillars that define a good design — interviewers will judge your work against all three, often without saying so.

```
┌────────────────────────────────────────────────────────────────────┐
│                  Three pillars of a good design                    │
│                                                                    │
│  1. SCALABILITY      2. MAINTAINABILITY      3. EFFICIENCY         │
│                                                                    │
│  The system grows   The system can be        The system uses       │
│  with its user      understood and           resources well —      │
│  base.              improved by future       CPU, RAM, network,    │
│                     developers.              money, energy.        │
└────────────────────────────────────────────────────────────────────┘
```

#### 1. Scalability

The system handles 10×, 100×, 1000× the load without falling over. Already the topic of this whole module — caching, sharding, replication, load balancing all serve scalability.

**Two flavors:**

```
Vertical scalability (scale up):
  Make one server bigger. 4 CPU → 32 CPU, 32 GB → 512 GB.
  Simple. Hard ceiling (largest machine available). Single point of failure.

Horizontal scalability (scale out):
  Add more servers. 1 → 10 → 100.
  Requires stateless services. No real ceiling. No SPOF.

In practice: scale up first (it's easier), then scale out (it's stronger).
```

#### 2. Maintainability

The system can be **understood, changed, and debugged** by humans who didn't build it. The interviewer's mental check: *"If a new engineer joined the team tomorrow, could they ship a feature in this system in their first sprint?"*

**What improves maintainability:**

```
✓ Clear, documented APIs (OpenAPI / protobuf / GraphQL schema)
✓ Structured logs and good error messages
✓ Consistent naming and folder structure
✓ Tests (unit, integration, contract, load)
✓ Feature flags so you can change behavior without redeploying
✓ Health check endpoints and runbooks
✓ Modular services (small, focused, replaceable)
```

> **Senior signal:** When asked "how would you design X?" mention maintainability unprompted: *"I'd split the booking service from the notification service so they can be deployed and scaled independently — and so when a new engineer joins, they can own one service at a time."*

**What hurts maintainability:**

```
✗ Hidden side effects (mutation through a "getter")
✗ Distributed monolith (microservices that all deploy together)
✗ Magic numbers / magic strings / global state
✗ Logs that say "something went wrong"
✗ No tests, no docs, no runbook for the on-call engineer
```

#### 3. Efficiency

The system does its work with the **least amount of resources needed** — money, CPU, RAM, network, energy. This is the "make it cheap to run" pillar.

**Interview-relevant examples:**

```
"Caching the therapist profile in Redis reduces our database load from
 10,000 QPS to 1,000 QPS — that's a 10x cost reduction on the database
 tier, which is our most expensive line item."

"We use protobuf for internal service-to-service calls instead of JSON.
 At 5 billion requests/day, that's several TB less network egress per
 month — meaningful cost and latency win."

"Geohashing rider location queries reduces a 100ms PostGIS scan to a
 5ms index lookup. 20× faster AND the database handles 20× the load
 on the same hardware."
```

#### The Fourth Pillar the Interview Looks For: Resilience

The transcript also calls out a dimension that the three pillars don't fully cover — **planning for failure**.

```
A scalable, maintainable, efficient system that crashes when one
server dies is not a good system.

A good system:
  - Expects things to fail (servers, networks, deployments, third-party APIs)
  - Continues to function in degraded mode (core features stay up)
  - Recovers automatically when the failure resolves
  - Surfaces failures to humans who can fix them (alerts, dashboards)

This is the topic of Module 12 (Observability & Reliability).
```

#### How to Use This in the Interview

When you propose a design, name the trade-off against these three pillars explicitly. The strongest candidates are the ones who *self-critique*:

> *"I'm proposing horizontal scaling with a Redis cache, which is highly scalable and efficient. The maintainability cost is that we now have two more systems to operate — Redis needs monitoring, backups, and a failover plan. The alternative — pure read replicas on the database — is less efficient but more maintainable. For a 5-person team, I'd probably start with the replicas; for a 50-person team, the cache is the right call."*

> **Senior signal:** Naming a trade-off against a *named* pillar (scalability, maintainability, efficiency) is dramatically more senior than "it's a trade-off." It shows you have a framework, not just an opinion.

#### 6.0.1 Architecture Styles — Monolith, Modular Monolith, Microservices, Serverless

> **Interview relevance: Core.** A favorite interview opener. Knowing the four styles + when each fits (team size, scale, domain clarity) is one of the most-tested topics in senior rounds.

"Microservices" is the most over-used word in system design. Knowing when NOT to use them is the senior move. The right answer depends on team size, domain clarity, and scale.

```
MONOLITH:
  One single deployable. All features live in one codebase, one process.
  ✓ Simple to develop, test, deploy.
  ✓ One DB, one repo, one CI pipeline.
  ✗ Any deploy requires the whole app to redeploy.
  ✗ One slow feature can starve the whole process.
  ✗ Scaling is vertical (bigger box) — you can't scale the chat
    service without scaling the entire app.
  → Use when: tiny team (<5 devs), unclear domain, MVP, single-tenant.

MODULAR MONOLITH (the senior default):
  One deployable, BUT the code is organized into modules with
  clear boundaries. Each module owns its data; cross-module calls
  go through internal APIs.
  ✓ One deploy, but modules can be extracted to services later.
  ✓ Vertical scaling is still simple.
  ✗ Still one process; one slow module affects all (though
    less than a true monolith because of isolation).
  → Use when: small-to-medium team (5-20 devs), domain is starting
    to clarify, you want to defer the microservices decision.

MICROSERVICES:
  Many small services. Each owns its data. Services communicate
  over the network.
  ✓ Independent deploy, independent scale per service.
  ✓ Teams own their service end-to-end.
  ✗ Operational cost is massive (deploy, monitor, debug N services).
  ✗ Distributed-system problems: partial failure, latency, consistency.
  ✗ Cross-service transactions are hard (saga, eventual consistency).
  → Use when: large team (20+ devs), clear bounded contexts, the
    cost of coordination > the cost of operation.

SERVERLESS (FaaS):
  Functions triggered by events. No server management.
  ✓ Zero ops for the function itself.
  ✓ Auto-scales to zero when idle (cost-efficient for spiky load).
  ✗ Cold start (the first request after idle pays a latency tax).
  ✗ Per-request pricing can be expensive for steady high traffic.
  ✗ Vendor lock-in.
  → Use when: spiky async work (image resize on upload, scheduled
    jobs, webhook receivers). NOT for steady-state request paths.
```

| | Monolith | Modular Monolith | Microservices | Serverless |
|---|---|---|---|---|
| Team size | <5 | 5-20 | 20+ | any |
| Deploy cadence | weekly | weekly | per service | per function |
| Operational cost | low | low | high | very low (managed) |
| Latency overhead | none | none | per-call network | cold start |
| Failure isolation | none | partial | full | per-function |
| Best for | MVP, internal tools | most production systems | large orgs, clear domains | spiky async, glue code |

> **Senior signal:** "For a 5-person team building a B2B SaaS, I'd start with a modular monolith. We can split out a service when there's a clear scaling or team-boundary reason — not before. Microservices are an answer to organizational problems first, technical problems second."

#### 6.0.2 Concurrency vs Parallelism

> **Interview relevance: Differentiator.** Two words candidates mix up. Knowing the distinction is a quick differentiator; rarely asked directly but shows up in "how do you scale the chat service?"

These are two different things. Confusing them in an interview is a senior mistake.

```
CONCURRENCY:
  Dealing with many things at once.
  A single Node.js process handles 10K WebSocket connections at
  once — but only runs one piece of JS at a time.
  ✓ Makes progress on multiple tasks.
  ✗ Doesn't necessarily make individual tasks faster.

PARALLELISM:
  Doing many things at once.
  10 worker processes each handling 1K connections — running on
  10 cores simultaneously.
  ✓ Makes individual tasks faster (when CPU-bound).
  ✗ Requires multiple cores/machines.

WHEN EACH MATTERS:
  I/O-bound work (API calls, DB queries, network):
    Concurrency is enough. You don't need 10 cores;
    you need 10K concurrent in-flight requests.
    → Node.js, Go, Elixir all shine here.

  CPU-bound work (image processing, ML inference, encryption):
    Parallelism is required. You need 10 cores actually working.
    → Python with multiprocessing, C++ with threads, Go with goroutines
      across N CPUs.
```

> **Senior signal:** "For our chat service, the work is I/O-bound (waiting for messages, network). I'll use Go with goroutines — concurrency handles 100K connections per process without parallelism. For the ML moderation service, the work is CPU-bound (model inference). I'll scale horizontally across machines, not just within one process."

#### 6.0.3 Service Mesh — When the Plumbing Becomes a Product

> **Interview relevance: Differentiator.** Only relevant once you have 10+ microservices. Senior candidates name Istio/Linkerd unprompted when discussing east-west traffic. Skip for small-system prompts.

When you have 20+ microservices, every service ends up reimplementing the same plumbing: retries, timeouts, circuit breaking, mTLS, observability. A service mesh moves that plumbing out of the app and into a sidecar.

```
THE PROBLEM:
  Service A calls Service B.
  A needs to: set a timeout, retry on failure, break the circuit
  if B is down, encrypt the call with mTLS, log the call,
  emit a metric, trace it across services.
  → This code is the same in every service. 50 services × 200 lines
    of plumbing = 10K lines of duplicated, brittle code.

THE SERVICE MESH SOLUTION:
  Every service runs with a sidecar proxy (Envoy, Linkerd-proxy).
  All traffic goes through the sidecar.
  The sidecar handles: retries, timeouts, mTLS, circuit breaking,
  metrics, tracing, header propagation.
  → The application code is clean: "call Service B."
  → The mesh handles everything else.

ARCHITECTURE:
  Service A ────► Sidecar A ────► Sidecar B ────► Service B
  (application)  (Envoy)         (Envoy)         (application)
                       │                              │
                  retry, mTLS,                   retry, mTLS,
                  timeout,                       timeout,
                  metrics                       metrics

EXAMPLES: Istio, Linkerd, Consul Connect.
```

> **When to reach for a service mesh:**

```
YOU HAVE:
  - 10+ microservices
  - mixed languages (Go, Python, Java, Node) — every team would
    reimplement retries/timeouts in their own language
  - compliance requires mTLS between services
  - on-call is hard because there's no consistent observability

YOU DON'T HAVE:
  - 3 services and a queue. Just use a client library.
  - 1 service. Definitely don't add a mesh.
```

---

### 6.1 Load Balancing Strategies

A **load balancer** distributes incoming requests across multiple server instances.

**Round Robin:** Send request 1 to Server 1, request 2 to Server 2, request 3 to Server 3, then back to Server 1. Simple, works when servers are identical.

**Least Connections:** Send the next request to whichever server has the fewest active connections. Better when requests have variable processing time.

**Consistent Hashing:** Route requests for the same resource (e.g., same `user_id`) to the same server. Critical for stateful operations where server-local state (connection pools, caches) must be reused.

#### More Algorithms You Should Know

The three above are the ones you use every day. The ones below are the ones that show up in design reviews and in senior interviews.

| Algorithm | What it does | When to use it | Trade-off |
|-----------|--------------|----------------|-----------|
| **Least Response Time** | Picks server with lowest response time AND fewest active connections | When latency matters more than throughput (e.g., user-facing API) | Needs a feedback loop from each server; slightly more complex |
| **IP Hash** | `hash(client_ip) % N` → fixed server per client | When you need session affinity (a user sticks to one server) | If a user moves networks (Wi-Fi → cellular), they may land on a different server |
| **Weighted Round Robin / Weighted Least Connections** | Like the base algorithm, but servers have weights (more capable = more traffic) | When the pool is heterogeneous (e.g., 1× big box + 3× small boxes during migration) | Static weights go stale; you need to re-tune when servers change |
| **Geographic / Geo-IP** | Route to the closest region or a specific region for compliance | Global services where latency reduction is priority, or data residency rules | Closest is not always fastest (a nearby region can be overloaded) |
| **Consistent Hashing (in a ring)** | Place nodes + keys on a hash ring; key goes to the next node clockwise | Distributed caches (Memcached, Redis Cluster), CDN edge selection | Trickier to reason about; needs virtual nodes to balance load |

> **Senior signal:** Don't just say "Round Robin." Say *"Round Robin works for our backend today because all app servers are identical and request time is roughly uniform. The day we mix instance sizes or run long-running requests, I'd switch to Weighted Least Connections. And if I needed a user to always land on the same server (e.g., for a sticky session on the chat service), I'd use IP Hash."*

#### Health Checks — The Other Half of Load Balancing

A load balancer is only useful if it stops sending traffic to broken servers. **Health checks** are periodic probes ("GET /healthz on port 8080 — does it return 200?") that mark servers as healthy or unhealthy.

```
Healthy:   LB sends traffic
Unhealthy: LB stops sending traffic; resumes only after N consecutive successes

Active probe:   LB pings every 5s; 3 fails in a row → unhealthy
Passive probe:  LB watches real responses; if 50% of last 100 requests 5xx'd → unhealthy

Failing fast (active) catches a dead server in seconds.
Failing on signal (passive) catches a degraded server that returns 200 but is super slow.
```

Most production setups use both. A dead server is caught by active probes; a slow or partially-broken server is caught by passive error rate.

#### Software vs Hardware vs Cloud Load Balancers

| Type | Examples | When to reach for it |
|------|----------|----------------------|
| **Hardware** | F5 BIG-IP, Citrix ADC (formerly NetScaler) | Carrier-grade performance, dedicated appliances, on-prem data centers. Very expensive, high throughput. |
| **Software** | HAProxy, Nginx, Envoy, Traefik | Self-hosted, flexible, runs on commodity servers. The default inside a service mesh or on VMs. |
| **Cloud-managed** | AWS ELB / ALB / NLB, GCP Load Balancer, Azure Load Balancer | When you're on a cloud — they're highly available by default, integrate with auto-scaling, certificates, WAFs. |
| **Virtual / Software-defined ADC** | F5 NGINX Plus, Citrix ADC VPX, VMware AVI | Deploy the "hardware" experience as software (on a VM or in the cloud). Used in hybrid setups. |

> **Interview tip:** If your design is on AWS, you don't even draw a load balancer box — you just say "an ALB terminates TLS and routes to an ASG of app servers." The interviewer will smile. If you're on-prem, "HAProxy doing TCP load balancing" is the safe answer.

#### 6.1.2 L4 vs L7 Load Balancers

> **Interview relevance: Core.** "What kind of load balancer?" is a common follow-up. Naming the layer + a concrete example (NLB vs ALB) is required.

"A load balancer" is too vague. The senior answer names the *layer* of the OSI model the LB operates at.

```
L4 LOAD BALANCER (transport layer, TCP/UDP):
  - Routes based on IP and port.
  - Doesn't look at the payload.
  - Very fast: just a hash of the connection's 4-tuple.
  - Examples: AWS NLB, HAProxy (in TCP mode), LVS, F5 LTM.
  - Use when: extreme throughput (millions of connections), non-HTTP
    traffic (gRPC over TCP, raw TCP services, game servers, video).

L7 LOAD BALANCER (application layer, HTTP):
  - Routes based on URL, headers, cookies, body.
  - Can do path-based routing: /api → API service; /static → CDN.
  - Can do host-based routing: api.app.com vs admin.app.com.
  - Examples: AWS ALB, NGINX, HAProxy (in HTTP mode), Envoy, Traefik.
  - Use when: HTTP/HTTPS traffic; you need header/URL-aware routing.
  - Slower than L4 (it parses the request), but infinitely more flexible.
```

**Choosing between L4 and L7:**

```
"The whole request is one TCP connection and we want maximum throughput"
  → L4 (NLB, or HAProxy in TCP mode).

"We want /api/* routed to the API service, /static/* to the CDN,
 and /admin/* to the admin service"
  → L7 (ALB, NGINX, Envoy).

"WebSocket connections that hold for hours"
  → Either, but L7 is more common (ALB has WebSocket support).

"gRPC with header-based routing (route by service name)"
  → L7 (Envoy, ALB with gRPC support).

"Game server traffic, custom binary protocol"
  → L4.
```

> **Senior signal:** "For the public-facing API I'd use an L7 LB (ALB or NGINX) to do path-based routing, header inspection, and WAF rules. For the internal east-west traffic between microservices, I'd use Envoy sidecars (service mesh) which act as L7 LBs at every hop."

#### 6.1.3 Sticky Sessions and Their Tradeoffs

> **Interview relevance: Differentiator.** Almost never asked directly. Useful when discussing WebSocket scaling or in-memory session design.

"Sticky session" is a way to make a stateless LB behave statefully. It has a cost; know when it's worth it.

```
STICKY SESSION (session affinity):
  The LB routes all requests from the same client to the same backend.
  Implementations: IP hash, cookie-based, TLS session ID.

  ✓ Server-local state survives across requests (in-memory session, cache).
  ✓ WebSocket connections stay on the same server (no re-handshake).
  ✗ Uneven load: one heavy user sticks to one server; if they're a
    power user, that server gets hammered.
  ✗ Server restart loses the session.
  ✗ Doesn't survive across regions.

ALTERNATIVE: externalize the session.
  - Session data lives in Redis, not in server memory.
  - Any server can serve any request; load is truly even.
  - This is the senior default.
```

> **Senior signal:** "I'd default to stateless app servers with sessions in Redis. Only use sticky sessions when the cost of externalizing state is higher than the cost of uneven load — for example, WebSocket-heavy chat where the connection state is large and per-connection."

#### 6.1.4 Active vs Passive Health Checks

> **Interview relevance: Differentiator.** Rare. Useful when the interviewer asks "how does the LB know a server is broken?" or "what if the server returns 200 but is slow?"

```
ACTIVE HEALTH CHECKS:
  The LB probes each server on a schedule ("GET /healthz every 5s").
  ✓ Catches dead servers (no response).
  ✗ Catches "the server responds but is degraded" only if the
    /healthz endpoint does a deep check.
  ✗ Adds load (every probe is a real request).
  ✗ Probe interval is a tradeoff: too long → slow detection;
    too short → wasted load.

PASSIVE HEALTH CHECKS:
  The LB watches real responses.
  If >50% of the last 100 requests to a server errored, mark unhealthy.
  ✓ Catches slow servers (they look "degraded" via response time).
  ✓ No extra load (uses real traffic).
  ✗ Requires bad traffic to detect bad servers (the canary in the coal mine).
  ✗ Slow at low traffic: 100 requests can take minutes for low-QPS services.

THE RIGHT ANSWER: BOTH.
  Active for fast failure detection; passive for slow / partial failure.
```

---

### 6.1.1 Proxy Servers — Forward, Reverse, and Friends

> **Why this section is here:** A load balancer is a *type* of proxy. A CDN is a *type* of proxy. If you can't articulate the difference between a forward and reverse proxy, you'll be lost in any architecture review where these terms come up.

A **proxy** is a server that sits between a client and the actual server, forwarding requests and responses. The two main flavors are mirror images of each other:

```
Forward proxy (in front of the CLIENT):
  Client ──► Forward Proxy ──► Internet (target server)
  The proxy hides the client. The server thinks it's talking to the proxy.
  Used to: control / monitor / anonymize outgoing traffic from a network.

Reverse proxy (in front of the SERVER):
  Client ──► Reverse Proxy ──► Backend server(s)
  The proxy hides the servers. The client thinks it's talking to the proxy.
  Used to: load balance, cache, terminate TLS, hide topology, WAF.
```

#### Forward Proxy — Use Cases

| Use case | What it does |
|----------|--------------|
| **Corporate egress control** | Block employees from visiting non-work sites. All outbound traffic must go through the proxy. |
| **Anonymity / privacy** | The destination sees the proxy's IP, not the client's. Journalists, researchers, privacy-conscious users. |
| **Caching at the network edge** | A school or ISP caches popular content at the proxy; the same 1000 students watching the same video only hit the origin once. |
| **Multi-account management** | Marketers managing many Instagram accounts route through different residential proxies to look like different users in different places. (This is the "Instagram proxy" use case — exists in a gray area.) |
| **Malware / virus scanning** | Inspect and sanitize traffic leaving the network. |

The defining feature: the proxy is chosen and configured by the **client side** (the corporate IT team, the user, the app).

#### Reverse Proxy — Use Cases

| Use case | What it does |
|----------|--------------|
| **Load balancing** | Distribute traffic across multiple backend servers. (This is what ALB / HAProxy do.) |
| **TLS termination** | Decrypt HTTPS at the edge so backend servers see plain HTTP. Saves CPU on the app servers. |
| **Caching** | Cache static or cacheable responses at the edge (CDNs are reverse proxies). |
| **Compression** | Gzip responses on the way out. |
| **WAF / security** | Inspect requests for SQLi, XSS, bot patterns before they reach the app. |
| **Hide topology** | The client only knows the proxy's IP — never learns how many backend servers exist or where they live. |
| **Canary / blue-green** | Route 1% of traffic to a new version, 99% to the old — both behind the same proxy. |

> **Interview tip:** "I'd put a reverse proxy (NGINX / ALB) in front of the app servers. It does TLS termination, gzip, and routes /api/* to the API service and /static/* to the CDN. For WAF, I'd put AWS WAF in front of the ALB." This is the kind of sentence that signals you've actually deployed something.

#### Other Proxy Variants You'll Hear About

| Type | What it is | When you'd mention it |
|------|------------|----------------------|
| **Open proxy** | Anyone on the internet can use it (often abused) | "We block known open proxies because they're a source of abuse" |
| **Transparent proxy** | Client doesn't know it's there; traffic is forced through it | Corporate networks / ISPs; you can't "opt out" |
| **Anonymous proxy** | Hides client IP but identifies itself as a proxy | Privacy browsing |
| **Distorting proxy** | Sends a *false* IP to the destination | SEO / ad-verification use cases |
| **High-anonymity (Elite) proxy** | Doesn't send `X-Forwarded-For` or any proxy-identifying header; destination can't tell a proxy is in use | Maximum anonymity; harder to fingerprint |

#### What Is a CDN, Really?

A **CDN** (Content Delivery Network) is just a **fleet of reverse proxies** distributed geographically. The CDN edge closest to the user fetches content from the origin, caches it, and serves the next request. (Module 4.11 covered the why; here is the *what*.)

**Two flavors of CDNs (matters for design):**

```
Pull-based CDN (most common):
  User requests /images/hero.jpg
  → CDN edge doesn't have it → fetches from origin, caches it, returns it
  → Next user gets it from cache
  You don't manage what gets cached; the CDN does, based on demand.
  Best for: websites with lots of static content updated regularly.

Push-based CDN:
  You upload /images/hero.jpg to the CDN yourself (or via an API)
  → CDN stores it on all edges eagerly
  You control exactly what's on each edge.
  Best for: large files, infrequent updates, content that must be
            on the edge before the first user request (e.g., a game patch).
```

> **Interview framing:** "I'd use a pull-based CDN for our public marketing site and blog images — content changes often and traffic is unpredictable. For the mobile app's video assets (a 500 MB therapy session recording), I'd use a push-based CDN during release windows so users worldwide can download the new build from the nearest edge."

#### Why the Load Balancer Is Itself a Single Point of Failure

The load balancer is in front of *every* server. If it dies, all servers are unreachable. The strategies to avoid that:

```
1. Redundant load balancers (active-active or active-passive pair)
   → AWS ALB is already two behind the scenes; you don't see it.
   → On-prem: two HAProxy instances + keepalived/VRRP for a virtual IP.

2. DNS-level failover
   → Health-check the LB IP; if it goes down, update DNS to point at a backup.
   → Slow (DNS caches); coarse. Last resort.

3. Anycast IP
   → The same IP is advertised from multiple physical locations;
     routing takes the user to the closest healthy one.
   → What big CDNs (Cloudflare, Fastly) and DNS root servers do.

4. Self-healing infra
   → Auto-scaling group detects a failed LB, terminates it, launches a new one.
   → Works best in cloud / Kubernetes environments.
```

> **Interview tip:** When you draw a load balancer, the interviewer may ask "what if this dies?" The strong answer names a specific mitigation (active-active HA pair, cloud-managed LB which is already HA, or anycast for global). "We just hope it doesn't" is not a senior answer.

---

### 6.2 Stateless Services — Why They're Required

A **stateless service** stores no user-specific state in memory between requests. Every request carries all necessary information (e.g., a JWT token), and any server instance can handle any request.

```
Stateful (bad for scaling):
  Server 1 stores Alice's session in memory
  → Alice's next request MUST go to Server 1
  → Load balancer is constrained; can't freely route

Stateless (good for scaling):
  Alice sends JWT on every request
  → Any server can validate the JWT and serve Alice
  → Load balancer can freely distribute
  → You can spin up / down servers without losing sessions
```

**Session storage:** For truly stateless services, sessions must live in an external store (Redis). The server reads session data from Redis on every request instead of local memory.

---

### 6.3 Horizontal vs Vertical Scaling

> **Why this section matters:** Every "how would you scale this?" answer has a vertical phase and a horizontal phase. The senior answer names which you're in, and why.

**Vertical scaling (scale up):** Buy a bigger server. 4 CPU → 32 CPU, 32 GB → 512 GB RAM. Simple but has a ceiling — the largest available machine — and creates a single point of failure.

**Horizontal scaling (scale out):** Add more servers. 1 server → 10 servers → 100 servers. Requires your service to be stateless. Much higher ceiling and no single point of failure.

In practice: vertical scaling is the first move (simple), horizontal scaling is the endgame (resilient).

#### Decision Framework

```
Start here:    Vertical (cheaper, faster, no code changes)
Hit a wall:    Add a single replica, read-split
               (the cheap horizontal step — read replicas)
Still growing: Full horizontal — stateless app servers
               behind a load balancer, with the DB either
               scaled vertically (with bigger machines)
               or sharded horizontally (the expensive step).

Why the order matters:
  + Vertical:        swap a bigger box. 30 min of downtime.
  + Read replicas:   add a follower. Hours, not weeks.
  + Sharding:        refactor the data model, migrate the data,
                     rewrite queries. Weeks to months.
  Each step is increasingly invasive. Don't skip to sharding
  if vertical + a single replica handles your load.
```

#### Databases Are Different From App Servers

This is where horizontal scaling gets complicated. App servers are *stateless* — easy to clone horizontally. Databases are *stateful* — every node has the data, and keeping it consistent across nodes is the whole problem.

```
Database horizontal scaling, in order of difficulty:
  1. Bigger machine           (vertical)             — minutes
  2. Read replicas            (scale reads)          — hours
  3. Primary + read replicas in another region  (geo reads) — days
  4. Sharding                 (split data)           — weeks
  5. Master-master            (split writes)         — avoid unless necessary
```

> **Interview tip:** "I'd scale our PostgreSQL primary vertically first — bump to a 64-CPU instance with 256 GB RAM. Once we hit 80% of that capacity, I'd add 2 read replicas for the read-heavy queries (the therapist list page, the analytics dashboard). If we outgrow that, I'd consider sharding by `user_id` — but only at that point, because sharding is a months-long project."

---

### 6.4 The CAP Theorem

In a distributed system (multiple servers), when a **network partition** occurs (servers can't communicate with each other), you must choose between:

- **Consistency (C):** Every read returns the most recent write, or an error. No stale data.
- **Availability (A):** Every request receives a (non-error) response. No timeout or refusal. May be stale.

You cannot have both when the partition exists. This is the **CAP theorem**.

```
Network Partition: Server A and Server B can't talk to each other.
User writes to Server A.

Consistent (CP) choice:
  Server B refuses reads until it can sync with Server A
  → User gets an error or waits
  → But data is never wrong

Available (AP) choice:
  Server B serves its last-known value (potentially stale)
  → User gets a response (possibly old)
  → But data might be wrong

Examples:
  CP systems: PostgreSQL, HBase, Zookeeper
  AP systems: DynamoDB, Cassandra, CouchDB
```

**What to say in an interview:**
> "For the payment flow, I'd choose CP — I'd rather return an error than charge the user the wrong amount. For the user's activity feed, I'd choose AP — showing a slightly stale feed is fine, but failing to load it at all is bad UX."

> **Senior signal:** Connecting CAP to specific features in your design unprompted is a strong signal. Most candidates know what CAP stands for but can't apply it.

**BASE** (the AP counterpart to ACID):
- **Basically Available:** System is available most of the time
- **Soft state:** State may change without input (as replicas sync)
- **Eventually consistent:** The system will _eventually_ converge to consistency

#### 6.4.1 P Always Happens — The Real Choice Is C vs A

> **Interview relevance: Core.** This is the most important CAP reframing. The senior answer is "P always happens; the real choice is C vs A." This comes up any time distributed systems are discussed.

Most candidates learn CAP as a 3-way tradeoff. The senior reframing is that P (partition) is not a choice — it always happens in any real distributed system. The actual choice is C vs A *given that P has occurred*.

```
THE TRUTH ABOUT CAP:
  In theory: choose any 2 of C, A, P.
  In practice: P always happens (networks fail, datacenters disconnect).
  → The real choice is between C and A when P occurs.
  → A "CA" system is one that doesn't distribute the data (single node).

EXAMPLES OF CP SYSTEMS (refuse reads or writes during partition):
  → Banking (Postgres, Oracle, HBase)
  → ZooKeeper, etcd (consensus-based)
  → Anything that has "is the leader alive?" semantics
  → Coordination services (must agree on state)

EXAMPLES OF AP SYSTEMS (serve possibly-stale data during partition):
  → Cassandra, DynamoDB, Riak
  → DNS (always serves; TTL is the "staleness" knob)
  → CDN (always serves from edge; revalidates on miss)
  → Most caches (Redis can be AP if not in cluster mode)
  → Social media feeds, shopping carts, counters
```

> **Interview signal:** "In our payment service, I'd choose CP — a network partition means we refuse to write the payment rather than risk double-charging. In the user's notification feed, I'd choose AP — better to show a slightly stale notification than fail to load the feed at all."

> **The "I chose AP because CAP" trap:** Choosing AP is not free. You must have an explicit strategy for handling stale data: read repair, anti-entropy, vector clocks, CRDTs, or last-write-wins. Naming the conflict-resolution strategy is senior.

---

### 6.5 Consistent Hashing (Revisited in Context)

Already covered in Module 3.6 for sharding. Consistent hashing also applies to load balancing (route same user to same cache node) and CDN edge selection. Knowing where it applies is the senior signal.

---

### 6.6 Throughput vs Latency — Two Numbers That Define Performance

Every performance question in an interview reduces to one of these two numbers. They're related, but they measure *different things*, and optimizing one often hurts the other.

**Throughput:** How much *work* the system does per unit of time. "How many requests can we handle?"

**Latency:** How long *one* piece of work takes. "How long until this single request returns?"

| | Throughput | Latency |
|--|------------|---------|
| Question | "How many per second?" | "How long does one take?" |
| Unit | RPS, QPS, MB/s, msgs/s | ms (or µs) |
| Goes up when | You batch, parallelize, add capacity | You make each operation faster |
| Tradeoff | Batching *one* request makes its latency worse, but increases throughput | Doing every request *immediately* (no batching) can starve the system |

#### Three Throughputs You Should Name in an Interview

| Metric | What it counts | When it matters |
|--------|----------------|-----------------|
| **Server throughput (RPS)** | Requests per second a single server (or fleet) handles | Capacity planning for the API tier |
| **Database throughput (QPS)** | Queries per second the database can serve | Whether you need read replicas, caching, or both |
| **Data throughput (bytes/s)** | Bandwidth consumed when moving data | Network costs, S3 egress, video streaming, replication |

> **Interview tip:** "We're at 5,000 RPS per app server. The bottleneck is the DB at 2,000 QPS. To get to 20,000 RPS, I'd (a) add 4 read replicas to triple QPS, and (b) cache hot reads in Redis to keep the DB at 1,200 QPS." This is what throughput-driven design looks like.

#### Latency — P50, P95, P99, and the Tail

"Latency" without a percentile is meaningless. Averages hide misery.

```
For 1,000 requests with these latencies in ms:
  990 requests: 50ms
  10 requests:  5000ms (cold cache, GC pause, network blip)

Average: 99.5ms    ← misleading
P50:     50ms      ← typical user
P99:     5000ms    ← 1 in 100 users is furious
P99.9:   5000ms    ← 1 in 1000 gave up and uninstalled the app
```

**The senior move:** always state the *tail* (P95 or P99) in your SLOs, not the average. The average is fine for capacity planning; the tail is what users actually feel.

> **Interview signal:** Saying "the API has 100ms latency" is junior. Saying "P50 is 30ms, P99 is 180ms, P99.9 is 1.2s and that last bucket is dominated by cold cache misses" is senior.

#### The Throughput / Latency Tradeoff

Batching is the cleanest example. Say you can process 1 request at a time, taking 100ms each, with 10 server threads.

```
Without batching: each request goes to a thread, returns in 100ms
  → Latency per request: 100ms
  → Throughput: 10 threads × 10 RPS = 100 RPS

With batching (wait up to 50ms, then process 10 at once):
  → Latency per request: 50ms (wait) + 100ms (process) = 150ms
  → Throughput: 20 batches/s × 10 = 200 RPS

Latency got 50% worse. Throughput doubled.
```

The right answer depends on what users feel. A search box accepts +50ms for 2× throughput. A "Buy now" button does not.

> **Interview framing:** "I'd avoid batching on the booking confirmation path — that user is staring at a spinner, latency dominates perceived quality. I'd happily batch the analytics ingestion pipeline — a 5-second lag there is invisible to the user, and we get 10× throughput."

---

### 6.7 Module 6 — Quick Fire

| Question | Answer |
|----------|--------|
| Why must horizontal scaling require stateless services? | Any server must be able to handle any request, so state can't live on a single server |
| CAP theorem — what's the P? | Partition tolerance — the system continues operating when network partitions occur |
| Can you have CA without P? | In theory yes, but in real distributed systems, partitions happen — so you must choose CP or AP |
| Round Robin vs Least Connections? | Round Robin for uniform servers/requests. Least Connections when request processing time varies |
| What does BASE stand for? | Basically Available, Soft state, Eventually consistent |
| When would you use IP Hash load balancing? | When you need session affinity — a user always lands on the same server |
| Why is a single load balancer a problem? | It's a single point of failure — every request flows through it, so its death takes down the whole service |
| Forward proxy vs reverse proxy — what's the difference? | Forward proxy sits in front of *clients* (controls/anonymizes outgoing traffic). Reverse proxy sits in front of *servers* (load balances, caches, terminates TLS) |
| Is a CDN a proxy? | Yes — a fleet of reverse proxies distributed geographically |
| Pull-based vs push-based CDN? | Pull: CDN fetches from origin on first request. Push: you upload to CDN explicitly. Pull for unpredictable demand, push for large predictable releases |
| Throughput vs latency — give an example of trading one for the other | Batching increases throughput but adds latency per request |
| Why do we report P99 latency instead of average? | The average hides tail latency; P99 reflects what 1 in 100 users actually experiences |
| Name the three throughputs you'd quote in a design | Server RPS, database QPS, and data bytes/sec |
| The three pillars of system design? | Scalability (handles growth), maintainability (humans can change it), efficiency (uses resources well) |
| What is N+1 vs N+2? | N+1 redundancy = survive 1 component failure. N+2 = survive 2. You negotiate this with the SLA |
| Vertical vs horizontal scaling — which is "first"? | Vertical first (easier), horizontal at scale (stronger). Production is almost always both |

---

## Module 7: Message Queues & Async Processing

> **Priority: HIGH.** Mobile devs rarely encounter this. Interviewers love asking about it because it's a genuine blind spot.

### 7.1 Why Async Processing Exists

When a user submits an order, several things need to happen:
1. Save the order to the database
2. Charge the payment method
3. Send a confirmation email
4. Notify the warehouse system
5. Update inventory
6. Trigger a loyalty points calculation

If all of this happens **synchronously** in the HTTP handler, the user waits 3–5 seconds for their "Order Placed" screen. Worse, if the email service is slow or down, the whole order fails.

**Solution:** Save the order, return 201 immediately, and push the rest to a queue for background workers.

```
User ──► API Server ──► Database (save order)
                  └──► Message Queue
                              └──► Worker 1: charge payment
                              └──► Worker 2: send email
                              └──► Worker 3: notify warehouse
                              └──► Worker 4: update inventory
```

The user gets their response in ~100ms. The workers process in parallel, asynchronously.

Benefits:
- **Decoupling:** Email service being down doesn't fail the order
- **Resilience:** Jobs survive server restarts (queue is durable)
- **Peak load handling:** Queue absorbs bursts; workers process at their own pace
- **Retry logic:** Failed jobs can be retried automatically

#### 7.1.1 Queues as a Shock Absorber — Stress-Test Cases

> **Interview relevance: Differentiator.** Not asked as a topic, but the canonical examples (ticket sale, image upload, payment webhook) are useful real-world anchors when justifying the queue in your design.

Every "why use a queue" answer is more convincing when paired with a real spike scenario. These are the canonical examples.

```
TICKET SALE (flash sale, concert drop):
  Without queue: 100K requests hit 10 servers → all servers crash.
  With queue: 100K requests land in the queue. Workers process
              at 1K/sec. Everyone who got in gets a ticket.
  → Concrete: Ticketmaster, StubHub, Eventbrite.

PAYMENT PROCESSING (webhook redelivery):
  Without queue: webhook handler calls Stripe API synchronously;
                 Stripe slows down; your handler queue builds up;
                 you start timing out.
  With queue: webhook lands in queue, worker processes with its
              own timeout, retries on failure.
  → Concrete: every payment integration (Stripe, PayPal, Adyen).

IMAGE UPLOAD (slow transcoding):
  Without queue: user uploads a 200MB video, server transcodes
                 to 3 resolutions, takes 90 seconds, user waits.
  With queue: upload returns "processing" in 200ms; worker
              transcodes async, user gets notification when ready.
  → Concrete: YouTube, Instagram, TikTok.

BLACK FRIDAY / CYBER MONDAY:
  Without queue: 10x normal traffic → site is down for hours.
  With queue: queue depth grows; auto-scaler spins up workers;
              queue drains after the peak.
  → Concrete: every retail site that survived Black Friday.

EMAIL/SMS DELIVERY:
  Without queue: send-time API call; provider outage = your users
                 don't get notified.
  With queue: queue absorbs; worker retries; eventual delivery.
  → Concrete: SendGrid, Mailgun, Twilio consumers.
```

> **Senior signal:** "I'd put a queue between the API and the worker for the slow or unreliable work. This gives the user a fast response, decouples the API from downstream failure, and lets me scale workers independently of API servers."

#### 7.1.2 Fan-Out from One Event to Many Workers

> **Interview relevance: Core.** Fan-out is a frequent topic — photo upload → thumbnails + moderation + search + notification is a canonical example. Naming the pattern and the consumer-group model scores well.

A single event can trigger many independent actions. The fan-out pattern is the canonical way to do this.

```
SCENARIO: A new photo is uploaded to a social app.

ONE EVENT: "photo.uploaded { user_id, photo_id, url }"

FAN-OUT TO MANY WORKERS (each does its own job):
  - Thumbnail worker: generate small/medium/large thumbnails → store in S3
  - Moderation worker:  send to ML model for NSFW detection
  - Search worker:      index in Elasticsearch
  - Notification worker: alert followers ("Alice posted a new photo")
  - Analytics worker:   increment "photos uploaded" counter

ARCHITECTURE:
  upload API → Kafka topic "photo.uploaded"
                     │
        ┌────────────┼────────────┬────────────┐
        ▼            ▼            ▼            ▼
  thumbnail_w  moderation_w  search_w   notification_w
  (own group)   (own group)  (own group)  (own group)

EACH WORKER GROUP:
  - reads the topic at its own pace
  - scales independently
  - can fail without affecting the others
  - can be added later without changing the producer
```

> **Senior signal:** "When one event triggers multiple side effects, I'd put it on a Kafka topic and have one consumer group per side effect. This lets each team own its own consumer, scale it independently, and deploy without coordinating with anyone else."

---

### 7.2 Message Queue vs Pub/Sub

**Message Queue:** One producer sends a message. One consumer processes it. The message is removed from the queue once processed.

```
Producer ──► [Queue] ──► Consumer A  (message deleted after processing)
```

Example: Order processing — each order should be processed exactly once.

**Pub/Sub (Publish/Subscribe):** One producer publishes a message to a topic. Multiple consumers (subscribers) each receive a copy.

```
Producer ──► [Topic] ──► Consumer A (gets copy)
                    └──► Consumer B (gets copy)
                    └──► Consumer C (gets copy)
```

Example: "User signed up" event → email service + analytics service + recommendation service all need it.

---

### 7.3 Kafka vs RabbitMQ vs SQS

**Apache Kafka:** Distributed, durable log. Messages are retained even after consumption (you can replay them). Designed for high-throughput streaming (millions of messages/second). Used for event sourcing, audit logs, analytics pipelines.

**RabbitMQ:** Traditional message broker. Messages are deleted after consumption. Supports complex routing (topic exchanges, fanout). Good for task queues, simpler use cases.

**Amazon SQS:** Managed queue (AWS). Simple to operate, auto-scales, no infrastructure. Used for decoupling AWS services. At-least-once delivery by default.

| | Kafka | RabbitMQ | SQS |
|--|-------|----------|-----|
| Retention | Configurable (days/forever) | Until consumed | 14 days max |
| Throughput | Very high | Moderate | Managed (auto-scales) |
| Replay | ✓ (can re-read old messages) | ✗ | ✗ |
| Routing | Topic/partition | Rich exchange routing | Simple queues |
| Best for | Event streaming, audit log | Task queues, pub/sub | AWS workloads |

---

### 7.4 Delivery Guarantees

When a worker is processing a message and crashes, what happens?

**At-most-once:** Message is delivered once, maybe not at all. No retry. Use when losing messages is acceptable (metrics, non-critical logs).

**At-least-once:** Message is delivered one or more times. If the worker crashes before acknowledging, the broker retries. Side effect: message may be processed **twice**. This is the default in most systems.

**Exactly-once:** Delivered exactly once, guaranteed. Technically complex and expensive. Kafka supports it with transactions + idempotent producers, but at a performance cost.

**The implication:** Most production systems use **at-least-once** and require consumers to be **idempotent** to handle duplicates safely.

---

### 7.5 Idempotency in Consumers

If your worker might receive the same message twice, processing it twice must be safe.

```
Non-idempotent (dangerous):
  Message: "charge user $99"
  Worker crashes after charge, before ack
  → Queue retries → user charged twice ❌

Idempotent (safe):
  Message: "charge user $99 for order_id=XYZ"
  Worker checks: "has order XYZ been charged already?"
  → If yes: skip and ack → ✓
  → If no: charge → record in DB → ack → ✓
```

Technique: Use a **deduplication key** (the order_id or a message UUID). Before processing, check if that key exists in a "processed" table. If yes, skip. This turns a non-idempotent operation into an idempotent one.

---

### 7.6 Dead Letter Queues (DLQ)

A **dead letter queue** receives messages that couldn't be processed after N retries. Instead of losing them, they land in the DLQ for investigation.

```
Main Queue → Worker fails 5 times → Message → DLQ
                                                 └──► Alert ops team
                                                 └──► Manual inspection
                                                 └──► Replay after fix
```

Always configure a DLQ. Otherwise, a poison pill message (one that always causes a crash) will cause your worker to retry forever, blocking the queue.

#### 7.6.1 Ordering Keys and the Partitioning Trick

> **Interview relevance: Core.** If you mention a queue, the interviewer will likely ask "how do you preserve order?" The right answer is "key the partition by the entity (orderId, chatRoomId, paymentId)." Required, not extra.

The biggest "I lost data" trap in queues is wrong partitioning. Same-key messages must land in the same partition to preserve order.

```
SCENARIO: Order events for one order must be processed in order
          (created → paid → shipped → delivered).

WRONG (no key):
  - All "order.created" and "order.paid" events for order 123
    and order 456 are mixed across partitions.
  - Consumer pool A reads partition 1: order 123 paid before created.
  - Wrong state.

RIGHT (key = order_id):
  - All events for order 123 always go to partition X.
  - All events for order 456 always go to partition Y.
  - One consumer (or one consumer group) reads each partition in order.
  - Ordering preserved PER ORDER, even when the system is massively parallel.
```

**The "noisy neighbor" problem and per-tenant partitioning:**

```
SCENARIO: One B2B customer emits 100K events/minute. The other
          1000 customers emit 1K events/minute total.

WRONG (single partition for "all events"):
  - That B2B customer's events saturate the single partition.
  - All other customers are stuck waiting.

RIGHT (key = tenant_id, or explicit tenant-aware partitioner):
  - The noisy tenant gets its own partition (or set of partitions).
  - Other tenants are unaffected.
```

#### 7.6.2 Queue Capacity by Little's Law

> **Interview relevance: Core.** The throughput math (per-partition λ = 1/W) is the right way to answer "how many consumers do I need?" Cheap to memorize, high signal.

A single queue partition is bounded by a single consumer's throughput. The system ceiling is the number of partitions × the per-partition ceiling.

```
GIVEN:
  - 1 consumer per partition
  - each message takes 100ms to process
  - 10 partitions, 10 consumers

PER-PARTITION THROUGHPUT:
  λ_partition = 1 / W = 1 / 0.1s = 10 msg/sec

SYSTEM THROUGHPUT:
  λ_system = partitions × λ_partition = 10 × 10 = 100 msg/sec

  → To get 10K msg/sec, you need 10K/10 = 1000 partitions.
  → Adding partitions = adding consumers = horizontal scale.
```

> **Interview signal:** "If our target throughput is 10K msg/sec and each consumer handles 100 msg/sec, we need 100 partitions and 100 consumers. Adding a 101st consumer does nothing until we add the 101st partition."

#### 7.6.3 DLQ Strategy with Concrete Examples

> **Interview relevance: Differentiator.** Not asked directly, but "what happens when a message keeps failing?" is a follow-up you'll get. Naming DLQ + max retries + replay is a top-of-band answer.

```
EXAMPLE 1 — Malformed partner webhook:
  The partner sends a webhook with a JSON field we've never seen.
  The schema validator throws. We retry 5 times (same error each time).
  After 5 retries → DLQ.
  → DLQ alert: "New schema detected from partner X; update parser."

EXAMPLE 2 — Fraud check that always times out:
  The fraud-detection API is degraded. Our retry times out.
  We retry 3 times with exponential backoff. Still timing out.
  → DLQ. The order is held for manual review (a human checks the queue).
  → Without DLQ: infinite retries, order never completes.

EXAMPLE 3 — Downstream service permanently broken:
  The thumbnail service has a bug. Every image fails.
  Retries won't help. → DLQ. The bug is fixed; the DLQ is replayed.

STRATEGY:
  - Always set a max retry count (5-10 is typical).
  - Use exponential backoff with jitter between retries.
  - Send to DLQ on max-retry-exceeded.
  - Alert ops when DLQ depth > 0 (this is an SLO violation).
  - Have a documented replay process (re-push DLQ to main queue after fix).
```

#### 7.6.4 Sequencer — Generating Monotonic IDs

> **Interview relevance: Core.** Snowflake IDs / monotonic IDs come up in any system that needs ordered events (chat, payments, ride events, leaderboards). Knowing Snowflake's 64-bit layout (41 timestamp + 10 machine + 12 sequence) is a top-of-band answer.

A sequencer is a service whose only job is to hand out monotonic IDs. Used to order events in a distributed system, even when producers are spread across machines.

```
THE PROBLEM:
  - User generates 10 events from their phone.
  - Server receives them out of order.
  - Without IDs, you can't tell which came first.
  - With timestamps, you have clock-skew issues across regions.

THE SEQUENCER:
  - A service (or part of the DB) hands out IDs that are:
    - unique across the entire system
    - monotonically increasing (later = larger)
  - Each event is tagged with the sequencer's ID.
  - Consumers sort by ID; the order is unambiguous.
```

**Common sequencer designs:**

```
DATABASE SEQUENCE:
  INSERT INTO events (id, ...) VALUES (nextval('events_seq'), ...)
  ✓ Simple. ✓ ACID.
  ✗ The DB is the bottleneck for ID generation.
  ✗ Doesn't scale across regions.

TWITTER SNOWFLAKE (the famous one):
  64-bit ID = timestamp_ms (41 bits) + machine_id (10 bits) + sequence (12 bits)
  ✓ 4096 IDs per millisecond per machine.
  ✓ 1024 machines per "datacenter ID".
  ✓ Roughly time-ordered (high bits are the timestamp).
  ✓ No central bottleneck — each machine generates its own.
  → Used by: Twitter, Discord (modified), many other systems at scale.

ULID / UUID v7:
  ✓ Sortable by time (lexicographic order matches creation order).
  ✓ Globally unique.
  → Use when: you want sortable IDs without a central service.

KAFKA OFFSET:
  Each message in a Kafka partition has a monotonic offset.
  ✓ Producer and consumer agree on order per partition.
  ✗ Only meaningful within a partition.
```

**When ordering matters in system design:**

```
PAYMENT LEDGER:
  Without ordering, the same $100 might appear to be debited twice
  (two debits, then a credit) — or the credit might arrive first.
  → Snowflake IDs on each transaction event. Sort by ID.

CHAT MESSAGES:
  Display order in a conversation must match send order.
  → Snowflake IDs on each message. Sort by ID, display by sort.

RIDE EVENTS:
  pickup → en-route → arrived → started → completed → rated
  → Each event has a Snowflake ID. Sort by ID. Anomalies are visible
    (e.g., "started" without "arrived" is suspicious).

LEADERBOARDS:
  Two players hit "submit score" at the same millisecond.
  Without an ordering, the order is non-deterministic.
  → The leaderboard uses the sequencer ID as the tiebreaker.
```

> **Interview signal:** "For events that must be ordered (chat messages, payment transactions, ride events, leaderboard scores), I'd tag each with a Snowflake-style ID. The high bits are the timestamp; low bits are machine + sequence. This gives global uniqueness, monotonic ordering, and no central bottleneck."

> **Common mistake:** Using UUID v4 for "ordered events" — UUID v4 is random; the order has no relation to creation time. The right tool is UUID v7, ULID, or Snowflake.

---

### 7.7 Module 7 — Quick Fire

| Question | Answer |
|----------|--------|
| Why use async processing? | Decoupling, resilience, peak load handling, faster user response |
| Queue vs pub/sub difference? | Queue: one consumer per message. Pub/sub: all subscribers get a copy |
| At-least-once vs exactly-once? | At-least-once may deliver duplicates. Exactly-once guarantees one delivery, at higher cost |
| What is a DLQ? | Dead Letter Queue — where failed messages land after max retries |
| Why must message consumers be idempotent? | At-least-once delivery means they may receive the same message twice |
| Kafka vs RabbitMQ key difference? | Kafka retains messages (replayable). RabbitMQ deletes after consumption |

---

## Module 8: Storage Systems

### 8.1 Object Storage (S3-like)

Object storage is a flat namespace of files (objects) stored by a key. There is no directory hierarchy — just buckets and keys.

```
Bucket: "my-app-user-photos"
  Key: "users/abc123/avatar.jpg"    → 200 KB
  Key: "users/def456/avatar.jpg"    → 350 KB
  Key: "posts/xyz789/image.jpg"     → 2 MB
```

Objects are immutable — you don't append or edit; you replace. Designed for durability (S3 has 11 nines: 99.999999999%) and unlimited scale. Not designed for low-latency random access within files.

**Presigned URLs — how mobile uploads work:**

Mobile apps should never upload files directly to your API server (inefficient, expensive bandwidth). Instead:

```
1. Mobile app → API: "I want to upload a photo"
2. API → S3: "Generate a presigned upload URL for this key" (expires in 5 min)
3. API → Mobile: { upload_url: "https://s3.aws/bucket/key?sig=..." }
4. Mobile → S3 directly: PUT the file using the presigned URL
5. Mobile → API: "Upload complete"
6. API: "Update user record with new photo key"
```

This offloads the file transfer entirely to S3, your API stays fast, and bandwidth costs stay with S3 (which is cheaper at scale).

---

### 8.2 Block vs File vs Object Storage

| | Block | File | Object |
|--|-------|------|--------|
| What is it | Raw disk (like SSD) | Directory hierarchy (NFS, EFS) | Flat key → object (S3) |
| Access pattern | Random byte-level read/write | File-level read/write | Whole-object read/write |
| Use case | Databases, VMs | Shared filesystems | Media, backups, static assets |
| Scale | Limited (attached to one server) | Moderate | Effectively unlimited |

---

### 8.3 Data Lake vs Data Warehouse

You already studied this. The model answers:

> A **data lake** (e.g., S3) stores raw, structured, semi-structured, or unstructured data without requiring a schema before ingestion. You store first, figure out the schema later.

> A **data warehouse** (e.g., Redshift, BigQuery) stores curated, modeled, and cleaned data optimized for analytical queries. Data is typically loaded via ETL pipelines. Designed for high-performance SQL analytics.

> **AWS Glue** is not "creating relations in the data lake." It's a metadata catalog + ETL service. Crawlers discover data in S3 and infer schemas stored in the Glue Data Catalog. Athena and other services read this catalog to know how to parse the S3 files.

> **Athena** is a serverless SQL query engine. It queries data directly in S3 (using the Glue catalog for schema), charged per data scanned. No infrastructure to manage.

> **Redshift** is a columnar data warehouse with its own managed storage. Unlike Athena, data lives _in_ Redshift's warehouse, not in S3 (though it can query S3 externally via Redshift Spectrum). Optimized for complex analytical queries at scale with consistent low latency.

**The mental model:**
```
S3          = where raw data lives (the lake)
Glue        = metadata catalog + ETL engine
Athena      = SQL on top of S3 (ad hoc, pay-per-scan)
Redshift    = warehouse for modeled analytical data (managed compute/storage)
```

---

## Module 9: Complete Design Walkthroughs

### 9.1 Design a Chat Application (WhatsApp-like)

**Requirements gathering:**
```
Functional:
  - One-to-one and group messaging
  - Message history
  - Online/offline status
  - Delivery receipts (sent, delivered, read)
  - Offline message delivery (via push notification)

Non-functional:
  - < 100ms message delivery for online users
  - 99.99% availability
  - Messages must not be lost
  - Scale to 1B users
```

**Estimation:**
```
DAU: 1B
Messages/user/day: 40
Total messages/day: 40B
Messages/second: 40B / 86,400 ≈ 460,000 messages/sec (writes)
Message size: ~1KB (text)
Storage/day: 460K × 1KB = 460 GB/day
Storage/year: 167 TB/year
→ Need distributed message storage
→ Need sharding (no single DB handles 460K writes/sec)
```

**High-level design:**

```
┌─────────────┐  WebSocket  ┌──────────────────────────┐
│ Mobile App  │◄──────────►│  Chat Service (stateful)  │
└─────────────┘             └──────────┬───────────────┘
                                       │
                    ┌──────────────────┼──────────────────┐
                    ▼                  ▼                  ▼
             ┌──────────┐    ┌──────────────┐    ┌──────────────┐
             │  Redis   │    │   Message    │    │    Push      │
             │ (online  │    │   Database   │    │ Notification │
             │  status) │    │  (Cassandra) │    │   Service    │
             └──────────┘    └──────────────┘    └──────────────┘
```

**Component deep dives:**

**Message delivery (online user):**
```
1. Alice sends "Hello" to Bob
2. Alice's chat server receives the message
3. Server checks Redis: is Bob online?
4a. Bob online → look up Bob's connection in the connection table → forward via WebSocket
4b. Bob offline → store message in DB → send push notification
5. Update message status: sent → delivered
6. When Bob opens the message: update status → read
7. Server sends read receipt back to Alice
```

**Why Cassandra for messages:**
Messages are write-heavy and append-only. Cassandra is designed for exactly this — massive write throughput, time-ordered storage (great for message history), no single point of failure. Schema:

```sql
-- Cassandra schema (not SQL, but conceptually similar)
CREATE TABLE messages (
  conversation_id UUID,
  created_at      TIMESTAMP,
  message_id      UUID,
  sender_id       UUID,
  content         TEXT,
  PRIMARY KEY (conversation_id, created_at, message_id)
) WITH CLUSTERING ORDER BY (created_at DESC);
-- → Fast retrieval of most recent messages in a conversation
```

**Fanout for group messages:**
When Alice sends to a group of 1,000 people, the server must deliver to 1,000 connections. For large groups, do this asynchronously via a message queue — don't block Alice's send operation.

#### 9.1.1 WhatsApp Architecture Deep Dive

> **Interview relevance: Differentiator.** You're unlikely to be asked to design WhatsApp. But the pieces (Signal Protocol E2E, presence in Redis, fan-out for group chat, S3 presigned URLs) are senior details that come up in any chat or real-time design.

The architecture above is the right shape but missing the production-grade pieces that distinguish WhatsApp from a toy chat app.

```
THE FULL PRODUCTION ARCHITECTURE:

  ┌──────────┐
  │ Mobile   │  E2E encryption (Signal Protocol)
  │ App      │  Stores: message DB, media cache, contact list
  └────┬─────┘
       │ TLS over WebSocket (port 443)
       │
  ┌────▼──────────┐   Multiple chat servers, load-balanced,
  │ WebSocket     │   sharded by user_id (sticky session).
  │ Gateway       │   Terminates TLS, forwards to chat service.
  └────┬──────────┘   Connection table: which user is on which server.
       │
  ┌────▼──────────┐
  │ Chat Service  │   Stateless business logic.
  │ (N instances) │   Receives messages, looks up recipient's server,
  └────┬──────────┘   forwards via WebSocket. Records delivery state.
       │
  ┌────▼──────────┐
  │ Message Store │   Append-only message log (Cassandra or HBase).
  │ (Cassandra)   │   Partitioned by (sender_id, recipient_id) for 1:1
  └───────────────┘   and by (group_id) for groups. Time-ordered.
       │
  ┌────────────────┐
  │ Presence       │   Redis: user_id → {server_id, last_heartbeat}.
  │ (Redis)        │   TTL on the key (90s). Subscribed pattern for
  └────────────────┘   real-time presence updates.
       │
  ┌────────────────┐
  │ Push           │   APNs (iOS), FCM (Android), Web Push (web).
  │ Notification   │   Triggered when recipient is offline.
  │ (APNs/FCM)     │   Wakes the device, delivers a "new message" alert.
  └────────────────┘
       │
  ┌────────────────┐
  │ Media Service  │   Upload: S3 presigned URL. Download: CDN.
  │ (S3 + CDN)     │   Thumbnails generated by a separate worker.
  └────────────────┘
```

**The pieces that go beyond "basic chat":**

```
1. END-TO-END ENCRYPTION (Signal Protocol):
   - Keys generated on the device. The server NEVER sees plaintext.
   - Each message has a one-time key derived from a key agreement.
   - The server can see "Alice sent Bob a message" but not its content.
   - Why: privacy + post-Snowden expectations. WhatsApp's differentiator.

2. CONNECTION TABLE:
   - Maps user_id → chat_server_id.
   - When a WebSocket connection opens, register it.
   - When a message arrives, look up the recipient's server.
   - Heartbeat every 30s; if missed, evict.
   - Stored in Redis with a 90s TTL.

3. PRESENCE (online/offline/last seen):
   - "Online" = WebSocket is open AND heartbeat is recent.
   - "Last seen" = timestamp of last heartbeat.
   - Subscribe pattern: friends want to know when you come online.
   - Privacy: "last seen" is configurable (everyone, contacts, nobody).

4. DELIVERY RECEIPTS (sent → delivered → read):
   - SENT: the message left Alice's device.
   - DELIVERED: the recipient's server received it.
   - READ: the recipient opened the chat with the message visible.
   - The app sends a receipt event back; the originating server
     forwards to Alice's app.

5. MEDIA HANDLING:
   - Upload: client requests a presigned S3 URL from the API,
     then PUTs the file directly to S3. S3 → CDN.
   - Download: CDN URL.
   - Thumbnails: client requests multiple sizes; server returns
     URLs to each. Image service generates on demand or async.

6. GROUP CHAT FAN-OUT:
   - Group of 1,000: don't synchronously push to 1,000 connections.
   - Sender → fan-out worker (via Kafka) → worker pushes to 1,000
     recipient servers in parallel.
   - Sender's app returns "sent" immediately; deliveries happen async.
```

> **The senior framing:** "For WhatsApp, I'd add (1) Signal Protocol E2E encryption so the server is just a router of encrypted blobs, (2) a connection table in Redis for fast recipient lookup, (3) presence with a TTL-based heartbeat, (4) a fan-out worker for group messages, and (5) media via S3 presigned URLs and CDN. The 1B-user scale is solved by sharding the chat service and the message store — no single DB holds all messages."

#### 9.1.2 WebSocket Fan-Out at Scale

> **Interview relevance: Differentiator.** Connection table + sticky session is the right answer to "how do you scale WebSockets to 10M connections." If the prompt is chat or live tracking, this is required; otherwise a strong bonus.

> A common senior lesson on WebSockets highlights a problem most candidates miss.

```
THE PROBLEM:
  10M users connected via WebSocket.
  One server can hold 100K connections.
  → Need 100 chat servers.
  Now: Bob's message arrives at server A, but Bob is on server C.
  → Server A must look up "where is Bob?" (connection table).
  → Forward to server C. Server C delivers via WebSocket.

THE LATENCY COST:
  Alice → server A (5ms) → lookup (1ms) → server C (5ms) → Bob.
  = 11ms of network for a "local" chat.
  For 50ms SLO, this is fine. For 10ms SLO, it's half the budget.

THE OPTIMIZATIONS:
  1. Co-locate the connection table with the WebSocket (sticky session by user_id).
     → Almost always: Alice's server has Bob too.
     → No cross-server hop.
  2. Use a fast in-memory table (Redis with hash structure) for the lookup.
  3. Use a binary protocol (protobuf) instead of JSON for chat messages.
  4. WebSocket compression (permessage-deflate) for text messages.
```

> **Senior signal:** "At 10M concurrent WebSocket connections, the chat service is sharded by user_id so each user sticks to one server. The connection table in Redis is the bridge — when Alice sends to Bob and Bob is on a different server, we forward via the table. The latency cost is ~10ms of network hop, which is fine for our 50ms SLO."

---

### 9.2 Design a Feed / Timeline (Instagram)

**Key question: fanout-on-write vs fanout-on-read**

When Alice (1M followers) posts a photo, how do those 1M followers see it in their feed?

**Fanout-on-write (push model):**
When Alice posts, immediately write the post to the feed of every follower.
```
Alice posts → Worker reads 1M follower IDs → Write post to 1M feed caches
Pros: Read is O(1) — just read your pre-built feed
Cons: 1M writes per post. "Celebrity problem" — if Alice has 100M followers, this is catastrophic
```

**Fanout-on-read (pull model):**
When Bob opens his feed, fetch the latest posts from everyone he follows.
```
Bob opens feed → Fetch following list → Fetch latest post from each → Merge + rank
Pros: No fan-out writes. Works for celebrities.
Cons: Read is expensive — O(following count). Slow for users following 2,000 accounts.
```

**Hybrid (what Instagram actually does):**
- Regular users (< 10K followers): fanout-on-write (push)
- Celebrities (> 10K followers): fanout-on-read (pull)
- When Bob opens his feed: merge his pre-built feed with live-fetched celebrity posts

> **Senior signal:** Knowing the celebrity problem and the hybrid solution unprompted is a strong differentiator.

**Architecture:**

```
┌────────────┐  POST /post  ┌────────────────┐
│ Alice's    │─────────────►│   Post Service │
│ App        │              └───────┬────────┘
└────────────┘                      │
                                    │ publish event
                                    ▼
                             ┌────────────┐
                             │   Kafka    │
                             └────┬───────┘
                                  │
                    ┌─────────────┴──────────────┐
                    ▼                            ▼
           ┌──────────────────┐        ┌─────────────────┐
           │  Fanout Worker   │        │  Media Service  │
           │  (push to feeds) │        │  (process video,│
           └────────┬─────────┘        │   CDN upload)   │
                    │                  └─────────────────┘
                    ▼
           ┌──────────────────┐
           │  Feed Cache      │
           │  (Redis per user)│
           └──────────────────┘
```

---

### 9.3 Design a Ride-Sharing App (Uber-like)

**The hard problem: matching riders to nearby drivers in real-time**

**Geospatial indexing with Geohash:**

Standard database indexes don't work for "find all drivers within 500m of this GPS coordinate." GPS is two-dimensional (lat, lng), but B-tree indexes are one-dimensional.

**Geohash** encodes a lat/lng pair as a short string, where strings with the same prefix are geographically nearby.

```
San Francisco downtown: 9q8yy
Uber HQ (nearby):       9q8yz
Los Angeles:            9q5c...

9q8yy and 9q8yz share prefix 9q8y → they are close
9q8y and 9q5c share only 9q → they are distant
```

```
Uber driver location update:
  1. Driver sends GPS every 4 seconds
  2. Server computes geohash (precision 6: ~1.2km × 0.6km cell)
  3. Store in Redis: GEOADD drivers:9q8yy {driver_id} {lng} {lat}
     (Redis has native geospatial support)

Rider requests ride:
  1. Compute geohash of rider's location
  2. Query Redis: GEORADIUS drivers:9q8yy 37.77 -122.42 500 m
  3. Get nearby driver IDs → sort by ETA → offer to closest available driver
```

**Architecture:**

```
Driver App                                      Rider App
    │ location updates (every 4s)                   │ request ride
    ▼                                               ▼
┌──────────────────────────────────────────────────────────┐
│                     API Gateway                           │
└────────────────────────┬─────────────────────────────────┘
                         │
        ┌────────────────┼─────────────────┐
        ▼                ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  Location    │  │  Matching    │  │   Trip       │
│  Service     │  │  Service     │  │   Service    │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                 │                 │
       ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  Redis       │  │  Redis       │  │  PostgreSQL  │
│  (live GPS)  │  │  (geosearch) │  │  (trips)     │
└──────────────┘  └──────────────┘  └──────────────┘
```

**Real-time tracking (after match):**
Once a rider is matched to a driver, the driver's location is pushed to the rider app via WebSocket every 4 seconds. The server fans out each driver's location update only to their current rider — not to all riders.

---

### 9.4 Design a Search Engine (Google Search)

Search is the canonical "inverted index at massive scale" problem. The architecture below is what Google's crawler → indexer → query pipeline looks like at the shape level.

**Requirements gathering:**

```
Functional:
  - Crawl the web and discover pages
  - Index pages (full-text, structure, links)
  - Serve queries in <500ms
  - Rank results by relevance
  - Autocomplete / suggest
  - Ads (separate auction system)

Non-functional:
  - 8.5B queries/day = ~100K QPS average, ~500K QPS peak
  - 99.99% availability
  - Index freshness: hours to days (web is huge; full re-crawl takes weeks)
  - Scale to billions of pages
```

**Estimation:**

```
Web pages: ~50 billion (Google's known index size)
Per page (HTML + text + metadata): ~100 KB on average
Index size: 50B × 100KB = 5 PB raw
After compression, dedup, and inverted-index structure: ~100-500 PB
Queries per day: 8.5B
QPS: 8.5B / 86400 ≈ 100K QPS average
Peak (3x): ~300K QPS
```

**High-level design:**

```
CRAWLER PIPELINE              INDEXING PIPELINE              QUERY PIPELINE
                                                      
URL frontier                  Document parser          ┌─────────────┐
   │                          (HTML → text)            │   User      │
   ▼                              │                    │   browser   │
HTTP fetchers                       ▼                    └──────┬──────┘
(spider the web)             Extracted features               │
   │                          (terms, links)                 ▼
   ▼                              │                    DNS → Load balancer
Document store                       ▼                       │
(S3, raw HTML)                Inverted indexer              ▼
   │                          (MapReduce)              Query server
   │                              │                    (per-shard)
   │                              ▼                       │
   │                       Sharded inverted              ▼
   │                       index (per-term)          Ranking service
   │                              │                       │
   │                              │                       ▼
   └──────────────────────────────┴─────────────►  Results page
                                                       (HTML)
```

**Component deep dives:**

**Crawler:**

```
The crawler must:
  - Discover new URLs (follow links from known pages)
  - Fetch pages at scale (millions/sec)
  - Respect robots.txt (don't crawl what owners forbid)
  - Politeness (don't hammer one site)
  - Detect duplicates (canonical URLs, content fingerprinting)

Architecture:
  URL frontier (priority queue of URLs to crawl)
       │
       ▼
  N crawler workers (distributed)
       │
       ▼
  HTTP fetcher (DNS → TCP → HTTP → body)
       │
       ▼
  Content extractor (link extraction, text extraction)
       │
       ▼
  Document store (S3, raw HTML)
       │
       ▼
  URL discovery: extract links, add new ones to the frontier
```

**Inverted Index — the heart of search:**

```
FORWARD INDEX (one row per document):
  doc_1: "the quick brown fox"
  doc_2: "the lazy brown dog"
  doc_3: "the brown brown fox"

INVERTED INDEX (one row per term):
  "the"   → [doc_1, doc_2, doc_3]
  "quick" → [doc_1]
  "brown" → [doc_1, doc_2, doc_3, doc_3]   ← "brown" appears 2x in doc_3
  "fox"   → [doc_1, doc_3]
  "lazy"  → [doc_2]
  "dog"   → [doc_2]

  → Look up "brown" → get the doc list → rank by relevance + authority.

SHARDING THE INDEX:
  - Shard by TERM (one shard holds the postings for some terms).
  - Query "quick brown fox" hits 3 term shards in parallel.
  - Merge the results, rank, return.

WHY TERM-SHARDED:
  ✓ Each term's posting list is large but bounded.
  ✓ Queries are parallelized across shards.
  ✗ "Find all docs containing X AND Y" requires a merge step.
```

**Ranking:**

```
THE PIPELINE (modern search):
  1. RETRIEVAL: get top N=1000 candidate documents from the index.
     Uses BM25 (term frequency / inverse document frequency) — fast.
  2. RE-RANKING: a deep neural model scores the 1000 candidates.
     Uses BERT-like models. More expensive; run on a small set.
  3. POLICY: apply business rules (boost news, demote spam, ads).

PAGE RANK (the original Google innovation):
  - A page is important if many important pages link to it.
  - Computed once across the whole web, offline.
  - The score is one of many signals used in ranking.
```

**The query path (what happens when you type "best coffee" and hit enter):**

```
1. Browser → DNS → google.com (200ms)
2. Load balancer → query server (5ms)
3. Query server parses "best coffee":
   - "best" → postings list (millions of docs)
   - "coffee" → postings list (10M docs)
   - Intersect: docs containing both
4. Retrieve top 1000 candidates
5. Re-rank with neural model (50ms)
6. Apply policy + ads
7. Render HTML page
8. Total: 300-500ms
```

> **Senior signal:** "The query path is: DNS → LB → query server → term-shard index lookups (parallel) → BM25 candidate generation → neural re-ranking → policy → render. The crawlers and indexers run asynchronously; the query path is real-time and serves from the index. Index freshness is a separate concern from query latency — a freshly-crawled page can take hours to appear in results."

#### 9.4.1 Elasticsearch in the Search Pipeline

> **Interview relevance: Core.** Almost any e-commerce / log-search / in-app-search design uses Elasticsearch. Knowing the inverted-index shape and the indexer-via-Kafka pattern is required.

Most teams don't build a Google. They use Elasticsearch (built on Apache Lucene) and call it a day. The architecture is similar in shape.

```
ELASTICSEARCH (Lucene underneath):
  - Distributed inverted index.
  - You write documents; ES tokenizes text and builds the index.
  - You query with a JSON DSL; ES retrieves and ranks.
  - You scale by adding nodes; ES auto-shards and rebalances.

USES IN PRODUCTION:
  - E-commerce search (Amazon, Shopify, ASOS)
  - Log search (Datadog, Splunk, ELK)
  - Slack message search
  - GitHub code search
  - App-internal "find that user by name"
  - In-app site search (Coveo, Algolia as managed alternatives)

SHAPE: same as a custom search engine, but pre-built.
  Ingestion: app → Kafka → ES indexer
  Storage:    sharded inverted index (ES handles sharding)
  Query:      app → ES query node → top K results
```

> **Senior signal:** "For our e-commerce search, I'd use Elasticsearch as the search index, fed by a Kafka consumer reading product-change events from the primary DB. The query goes to ES, which returns the top 50 products. The primary DB stays the source of truth; ES is the read-optimized search index. Refresh interval of 1s is fine for product search."

---

## Module 10: Mobile-Specific System Design

> This module is your competitive edge. Most system design guides skip mobile. Interviewers of mobile engineers often probe here.

### 10.1 Offline-First Architecture

Mobile devices lose connectivity. A well-designed mobile app works offline and syncs when reconnected.

**The hard problem: conflict resolution**

If Alice edits a note on her iPhone while offline, and also edits it on her iPad, which version wins when both sync?

**Last-Write-Wins (LWW):** The most recent timestamp wins. Simple. Problem: clocks on devices are not reliable — a device with the wrong system time will always win or always lose. Also, you permanently lose the other edit.

**Merge:** For text documents, merge the two edits (like Git). Works well for append-only structures. Fails for numeric fields (two "increment by 1" operations can't be merged without knowing the base value).

**CRDTs (Conflict-free Replicated Data Types):** Data structures that are mathematically guaranteed to merge without conflicts. Examples:
- **G-Counter:** A counter that only grows. Each device has its own sub-counter. The total is the sum of all sub-counters. Two devices can increment independently and merge correctly.
- **LWW-Register:** A key-value register where last-write wins, but with vector clocks instead of wall clocks to correctly determine "last."

> For an interview, knowing CRDTs exist and what problem they solve is enough. You don't need to implement them.

**Delta sync:** When reconnecting, don't send everything — send only what changed since the last sync.

```
Client → Server: "Give me everything changed since timestamp 2026-03-14T10:00:00Z"
Server → Client: { changes: [...], server_timestamp: "2026-03-15T09:00:00Z" }
Client: store the new server_timestamp, apply changes
```

The server needs a `updated_at` index on every synced table. Deleted records need a `deleted_at` column (soft delete) — you can't sync "this row was deleted" if you hard-delete it.

---

### 10.2 Push Notifications Architecture

**APNs (Apple Push Notification service)** — Apple's delivery infrastructure for iOS/macOS.
**FCM (Firebase Cloud Messaging)** — Google's delivery infrastructure for Android.

Neither is a queue you control. You send a message to APNs/FCM and they handle delivery to the device. They maintain persistent, encrypted connections to every registered device.

**Fan-out problem:**

When a user receives a message in a chat app, you need to push a notification to their phone. At scale (10M users), a single service sending notifications serially is too slow.

```
Naive approach (too slow):
  for each user in recipients:
    send_push_notification(user.device_token, message)
  → 10M sequential HTTP calls to APNs/FCM

Better: Push notification service with queue
  1. Publish "send notification to user_id=X" to Kafka
  2. Notification workers consume from queue in parallel
  3. Workers look up device tokens from DB
  4. Workers batch calls to APNs/FCM (APNs supports batching up to 1,000 per HTTP/2 stream)
```

**Device token management:**

Device tokens change:
- App reinstall
- User logs out and logs in on new device
- iOS rotates tokens after transfer

You must:
1. Update the token on every app launch
2. Handle APNs/FCM feedback: if delivery fails with "invalid token," delete that token from your DB

```sql
CREATE TABLE device_tokens (
  id         UUID PRIMARY KEY,
  user_id    UUID NOT NULL REFERENCES users(id),
  token      VARCHAR(255) NOT NULL UNIQUE,
  platform   VARCHAR(10) NOT NULL,  -- 'ios' or 'android'
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

### 10.3 Mobile API Design Best Practices

**Payload optimization:**
Mobile networks are slow and bandwidth costs money for users. Design APIs to send only what the client needs.

```
Problem: GET /user returns 150 fields, mobile only needs 8
Solution 1: GraphQL (client specifies fields)
Solution 2: Sparse fieldsets: GET /user?fields=id,name,avatar_url
Solution 3: Separate mobile API that returns a mobile-optimized payload
```

**Response compression:**
Enable gzip or brotli on your API. Mobile HTTP clients handle decompression automatically. Savings: 60–80% payload size reduction for JSON.

```
Response headers:
  Content-Encoding: gzip
  Vary: Accept-Encoding

Request headers (client signals support):
  Accept-Encoding: gzip, deflate, br
```

**Exponential backoff with jitter:**
When a server returns 503 or a network request fails, don't immediately retry — you'll contribute to the overload. Wait, then retry with increasing delays + random jitter to prevent all clients retrying simultaneously.

```
attempt 1: wait 1s + random(0–500ms)
attempt 2: wait 2s + random(0–1000ms)
attempt 3: wait 4s + random(0–2000ms)
attempt 4: wait 8s + random(0–4000ms)
...cap at 60s
```

---

### 10.4 App Telemetry Pipeline

Your app crashes in production. How do you find out what happened?

**Error tracking (Sentry-like):**

```
App crash
  → SDK captures: stack trace, device info, OS version, app version, user_id, breadcrumbs
  → Buffer locally (in case network is down)
  → Flush on next app open or when network recovers
  → POST to ingest endpoint (batched, compressed)
  → Server: deduplicate by stack trace fingerprint → group into "issues"
  → Alert if new issue or spike in existing issue
```

**Metrics pipeline:**
Don't log every event as it happens — buffer and batch.

```
Mobile SDK:
  1. Event occurs (button tap, page view, api_call_latency)
  2. Append to in-memory ring buffer
  3. Flush buffer when: timer fires (every 30s), buffer full, app backgrounds
  4. POST batch to ingest endpoint (compressed)

Backend ingest:
  → Kafka → Stream processors (Flink, Spark Streaming) → Data warehouse
```

**Privacy consideration:** Session recording and telemetry can capture PII. Scrub sensitive fields before logging. Never log passwords, tokens, payment info. In the EU, GDPR requires explicit consent for analytics.

---

### 10.5 Module 10 — Quick Fire

| Question | Answer |
|----------|--------|
| What is offline-first architecture? | Designing mobile apps to work without a network connection, syncing changes when connectivity returns |
| Last-write-wins problem? | Device clocks are unreliable, and concurrent edits lose data permanently |
| What is a CRDT? | A data structure that merges concurrent changes without conflicts, mathematically guaranteed |
| Why use presigned URLs for uploads? | Mobile uploads directly to S3, bypassing your API server, reducing bandwidth costs and latency |
| APNs vs FCM? | APNs is Apple's push notification infrastructure (iOS/macOS). FCM is Google's (Android) |
| What is delta sync? | Sending only data that changed since the last successful sync, not the full dataset |
| Why buffer telemetry events on mobile? | Batching reduces battery usage, network requests, and backend ingestion load |

---

## Module 11: Distributed Systems Patterns

> **Priority: HIGH.** These are the patterns architects name-drop in design reviews. Hearing "we need the outbox pattern here" or "this is a saga" without knowing what those mean leaves you unable to contribute. After this module, you will.

---

### 11.1 Event Sourcing

**The problem it solves:** In a traditional database, you store the *current state*. If a patient's appointment is cancelled, you update the `status` column to `cancelled`. You've lost the history — who cancelled it, when, what the previous state was, and why.

**Event sourcing** inverts this. Instead of storing current state, you store every **event** that ever happened. The current state is derived by replaying events.

```
Traditional:
  appointments table:
  | id  | status    | updated_at |
  | 123 | cancelled | 2026-03-15 |
  (history is gone)

Event sourcing:
  events table:
  | id | aggregate_id | type                  | payload                        | occurred_at        |
  |----|-------------|------------------------|--------------------------------|--------------------|
  | 1  | appt-123    | AppointmentCreated     | {provider: "Dr. Smith", ...}   | 2026-03-10 09:00   |
  | 2  | appt-123    | AppointmentRescheduled | {old_time: "...", new_time: ...}| 2026-03-12 14:00  |
  | 3  | appt-123    | AppointmentCancelled   | {reason: "patient_requested"}  | 2026-03-15 10:30   |
```

Current state of `appt-123` = start from zero + apply event 1 + apply event 2 + apply event 3 = "cancelled."

**Benefits:**
- Full audit trail — who did what, in what order, exactly when. Non-negotiable in regulated industries (healthcare, finance).
- Time travel — reconstruct the state of any entity at any point in the past.
- Event replay — reprocess past events with new business logic (e.g., recalculate all billing if tax rules change).
- Natural fit for event-driven architectures — events are already there to publish.

**Cost:**
- Reading current state requires replaying all events. Mitigated by **snapshots** (periodically save a materialized state so you only replay events since the last snapshot).
- Queries across many entities are complex (you can't easily `SELECT * WHERE status = 'active'`). Solved by CQRS (below).

> **Senior signal:** "I'd use event sourcing for the appointment and prescription models because of the regulatory audit requirements, but not for the user's notification preferences — that's overkill where simple CRUD is fine."

#### 11.1.1 Event Sourcing in the Wild

> **Interview relevance: Differentiator.** Bank ledger / Git / Kafka log are the canonical examples. Useful when the prompt involves audit trail, financial ledger, or "the source of truth is the event log." Not asked as a topic, but real-world anchors are powerful.

Event sourcing is a pattern older than microservices. Real systems that look like event sourcing:

```
BANK LEDGER (the canonical example):
  You don't UPDATE an account balance.
  You APPEND transactions: +$100, -$30, +$50.
  The balance is the sum of all transactions.
  ✓ Every cent is auditable.
  ✓ Time travel: "what was Alice's balance on Dec 31 last year?"
  → Used by: every bank's core system.

GIT:
  The repository IS the sequence of commits.
  Current state = HEAD + working directory.
  ✓ Every change is logged with author, message, parents.
  ✓ You can checkout any commit (time travel).
  ✓ You can replay a commit with a different tool (rebase).

KAFKA LOG:
  Each topic IS a sequence of events.
  Consumers track their own offset.
  ✓ Replay from any point.
  ✓ Durable by default.

LEADERBOARD:
  "Score updated" events stream in.
  The current score is the sum.
  ✓ You can reconstruct the leaderboard at any historical moment.

CHAT MESSAGE HISTORY:
  Each message is an event.
  "Message deleted" doesn't delete the event; it appends a "tombstone."
  ✓ The history is preserved (regulatory requirements, e.g., HIPAA).
```

**Snapshot strategy — the trick to keeping event sourcing fast:**

```
THE PROBLEM:
  An aggregate has 10,000 events. To compute the current state,
  you replay all 10,000. That's slow.

THE FIX: SNAPSHOTS.
  Every N events (say, 100), save a snapshot of the current state.
  To compute current state:
    1. Load the latest snapshot (event 9900's state).
    2. Replay only events 9901-10000.
  → 100x faster.

CONCRETE:
  A bank account with 10 years of transactions (1000 transactions).
  Without snapshot: replay 1000 events. 50ms.
  With snapshot every 100: replay 10 events. 0.5ms.
```

**Schema evolution — the event sourcing landmine:**

```
EVENT V1 (3 years ago): AppointmentCreated { provider, time }
EVENT V2 (1 year ago):  AppointmentCreated { provider, time, duration_minutes }
EVENT V3 (today):        AppointmentCreated { provider_id, time, duration_minutes, location_id }

The event store has events of all three versions. The consumer must
handle all three. Strategies:
  - Upcasting: a service reads V1, transforms to V3, returns.
  - Versioned handlers: switch on event version, apply appropriate logic.
  - Schema registry: enforce forward-compatibility at write time
    (Protobuf/Avro with a schema registry).
```

> **Senior signal:** "For the bank ledger, I'd use event sourcing with snapshots every 100 events. The current balance is the latest snapshot plus the sum of transactions since. For querying 'all transactions in date range X', I'd use a CQRS read model: a stream consumer projects events into a search-friendly table."

---

### 11.2 CQRS — Command Query Responsibility Segregation

**The problem:** In event sourcing, the write model (event log) is not queryable the way a normal table is. More broadly, the shape of data you need to *write* is often different from the shape you need to *read*.

**CQRS** separates the system into two models:
- **Command side** — handles writes (create, update, delete). Emits events. Owns the authoritative state.
- **Query side** — handles reads. Maintains one or more *read models* (materialized views, denormalized tables, search indexes) optimized for specific query patterns.

```
User request: "Show me all active appointments for provider Dr. Smith on 2026-03-15"

Without CQRS:
  → Query the appointments table with JOIN on providers
  → May require multiple JOINs, slow at scale

With CQRS:
  Command side: events flow into Kafka
  Query side: a consumer maintains a read model:

  provider_schedule_view table (pre-joined, denormalized):
  | provider_id | provider_name | date       | time  | patient_name | status |
  | dr-smith    | Dr. Smith     | 2026-03-15 | 09:00 | Alice Jones  | active |
  | dr-smith    | Dr. Smith     | 2026-03-15 | 10:00 | Bob Chen     | active |

  → Read is a single table scan with a filter. Milliseconds.
```

```
┌────────────┐  Command   ┌──────────────────┐
│  Client    │──────────► │  Command Handler │──► events ──► Kafka
└────────────┘            └──────────────────┘
                                                         │
┌────────────┐  Query     ┌──────────────────┐          │
│  Client    │──────────► │  Query Handler   │◄── read model ◄─ Consumer
└────────────┘            └──────────────────┘  (maintained by event consumer)
```

**The trade-off:** The read model is **eventually consistent** with the command side. There's a lag between writing an event and seeing it in the read model. For most UI use cases this is fine (< 1 second). For operations requiring immediate consistency (e.g., "can I book this slot right now?"), use the command side directly.

---

### 11.3 The Saga Pattern — Distributed Transactions

**The problem:** In a monolith, a transaction spanning multiple operations is easy — wrap them in a database `BEGIN`/`COMMIT`. In a microservices architecture, each service has its own database. There's no shared transaction coordinator.

**Example:** A patient books an appointment. This involves:
1. Booking Service: reserve the slot
2. Payment Service: charge the insurance/co-pay
3. Notification Service: send confirmation
4. EHR Service: create the encounter record

If step 3 fails, you need to refund the payment (step 2) and release the slot (step 1). You can't use a single database transaction across three services.

**Saga pattern:** A sequence of local transactions, each publishing an event that triggers the next. If a step fails, **compensating transactions** run in reverse to undo the completed steps.

```
Choreography-based saga (event-driven, no central coordinator):

  BookingService          PaymentService          NotificationService
       │                       │                        │
       │──AppointmentCreated──►│                        │
       │                       │──PaymentProcessed─────►│
       │                       │                        │──EmailSent──►
       │                       │                        │
       │ (if PaymentFailed):   │                        │
       │◄──PaymentFailed───────│                        │
       │ Run: ReleaseSlot      │                        │
```

```
Orchestration-based saga (central coordinator tells each service what to do):

  SagaOrchestrator
       │──1. "BookingService: reserve slot"──────────────►
       │◄──"OK, slot reserved"────────────────────────────
       │──2. "PaymentService: charge $20"───────────────►
       │◄──"FAILED: card declined"────────────────────────
       │──3. "BookingService: release slot" (compensate)──►
       │◄──"OK"────────────────────────────────────────────
       │ Saga complete (rolled back)
```

**Choreography** is simpler to implement but harder to debug (the "saga" is implicit in event flow). **Orchestration** is explicit and easier to monitor, but the orchestrator becomes a coordination bottleneck.

> In a meeting when someone says "we need a saga here," they mean: this operation spans multiple services and we need a way to handle partial failures with compensating actions.

#### 11.3.1 Saga in the Real World — Concrete Examples

> **Interview relevance: Core.** If you say "I'd use a saga for cross-service transactions," the interviewer will likely ask "for what?" Travel booking / ride-hailing / e-commerce / food delivery are the canonical examples. Required for any microservices design.

Sagas aren't theoretical. The classic example is travel booking, but there are many.

```
TRAVEL BOOKING (the canonical example):
  Step 1: Book flight      → success
  Step 2: Book hotel       → success
  Step 3: Book rental car  → FAILED
  Compensate 2: Cancel hotel
  Compensate 1: Cancel flight (refund as credit)

RIDE-HAILING (Uber):
  Step 1: Match rider to driver → success
  Step 2: Driver accepts        → success
  Step 3: Rider pays            → FAILED (card declined)
  Compensate 2: Release driver from trip
  Compensate 1: Mark match as failed
  → User sees "we couldn't process your payment, please try again."

E-COMMERCE ORDER:
  Step 1: Reserve inventory     → success
  Step 2: Charge payment        → success
  Step 3: Create shipment       → FAILED (warehouse overloaded)
  Compensate 2: Refund payment
  Compensate 1: Release inventory
  → User sees "we're temporarily out of stock."

FOOD DELIVERY:
  Step 1: Restaurant accepts    → success
  Step 2: Payment authorized    → success
  Step 3: Driver assigned       → FAILED (no driver available)
  Compensate 2: Void payment authorization
  Compensate 1: Cancel restaurant acceptance
  → User sees "we couldn't find a driver; try again later."
```

**Choreography vs Orchestration — when to pick which:**

```
CHOREOGRAPHY (event-driven, no central coordinator):
  Each service emits events; other services react.
  ✓ No single bottleneck.
  ✓ Each service stays simple (just listens for its events).
  ✗ The "saga" is implicit — hard to see the full flow in one place.
  ✗ Hard to debug ("which step failed?" requires tracing events).
  ✗ Cyclic dependencies (service A depends on B's events which depend
    on A's events).
  → Use when: 3-5 services, simple flows, decentralized teams.

ORCHESTRATION (central coordinator):
  A dedicated service tells each service what to do, in order.
  ✓ Full saga state is visible in one place (the orchestrator's DB).
  ✓ Easy to add a step (just update the orchestrator).
  ✓ Easy to monitor (saga completion time, failure rate per step).
  ✗ The orchestrator is a new service to build and operate.
  ✗ The orchestrator's DB becomes a write hotspot.
  → Use when: 5+ services, complex flows, regulated industry (need audit).
  → Tools: AWS Step Functions, Camunda, Temporal, Apache Airflow.
```

> **Senior signal:** "For a travel booking saga, I'd use orchestration. The flow is regulated (refund rules, audit requirements), the steps can change (add 'book airport transfer' tomorrow), and on-call needs to see the saga state in one place. AWS Step Functions or Temporal is the right tool."

#### 11.3.2 CQRS in the Real World — Concrete Examples

> **Interview relevance: Differentiator.** Useful when the prompt has fundamentally different read vs write shapes (social feed, e-commerce catalog, bank account). Not asked as a topic, but the e-commerce example is a strong anchor.

```
E-COMMERCE CATALOG:
  Write side: product team updates products via admin UI → events.
  Read side: Elasticsearch index, updated by event consumer, serves
             the public-facing search.
  ✓ Search is fast (single Elasticsearch query, no JOINs).
  ✓ Search can be richer than the source (synonyms, scoring, boosts).
  ✓ Write model can be normalized; read model can be denormalized.

SOCIAL FEED (Twitter):
  Write side: user posts a tweet → "TweetPosted" event in Kafka.
  Read side:  a fan-out worker pushes the tweet to followers' timelines
              (Redis cache or read-replica table).
  ✓ Heavy lift (fan-out) happens async.
  ✓ Timeline read is a single Redis lookup per user.

BANK ACCOUNT:
  Write side: transaction event in event log.
  Read side:  materialized "current balance" view, maintained by a
              stream consumer, queried by the UI.
  ✓ Real-time write (the event log never lies).
  ✓ Fast read (the view is pre-computed).
  ✓ Multiple read views: "balance", "monthly statement",
                         "spending-by-category" — all from the same log.

RIDE STATUS:
  Write side: trip events stream in (requested, matched, en-route,
              arrived, started, completed, rated).
  Read side:  a stream consumer maintains "current trip state" in
              a fast KV store (Redis). User app reads from there.
  ✓ The "current state" is always pre-computed and ready.
  ✓ Multiple views for different consumers: rider app, driver app,
                                              analytics, ops dashboard.
```

> **The senior rule of thumb:** "If the read shape is fundamentally different from the write shape, use CQRS. If they're the same (a simple CRUD app), don't."

---

### 11.4 The Outbox Pattern — Guaranteed Message Delivery

**The problem:** You write to your database AND publish an event to Kafka. What if the server crashes between the two?

```
Scenario A — crash after DB write, before Kafka publish:
  Database: order saved ✓
  Kafka: event never published ✗
  → Downstream services never know the order exists

Scenario B — crash after Kafka publish, before DB commit:
  Kafka: event published ✓
  Database: order not saved (rollback) ✗
  → Downstream services process an order that doesn't exist
```

Both are real failure modes. You cannot atomically write to a database and publish to a message broker in a single transaction — they're different systems.

**The outbox pattern** solves this by using the database itself as a staging area.

```
Write path:
  BEGIN transaction
    INSERT INTO orders (...)
    INSERT INTO outbox (event_type, payload, published=false)  ← same transaction
  COMMIT
  → Either both succeed or both fail. Atomicity guaranteed.

Background publisher (a separate process):
  1. Poll outbox table for unpublished rows
  2. Publish each to Kafka
  3. Mark as published=true (or delete)
```

```
outbox table:
| id | aggregate_id | event_type       | payload     | published | created_at |
|----|-------------|------------------|-------------|-----------|------------|
| 1  | order-123   | OrderCreated     | {...}       | false     | 2026-03-15 |
| 2  | order-124   | OrderCreated     | {...}       | true      | 2026-03-14 |
```

The outbox publisher may publish the same event more than once (if it crashes after publishing but before marking `published=true`). Consumers must be idempotent (covered in Module 7.5).

> **In architecture meetings:** When you hear "we need the outbox pattern," the problem is dual-write atomicity. The solution is making the database the single transactional boundary and polling it into the message broker.

---

### 11.5 Change Data Capture (CDC)

**What it is:** Instead of polling an outbox table, CDC reads the database's own **transaction log** (the internal log every database maintains for crash recovery) and turns each committed change into an event.

PostgreSQL has the WAL (Write-Ahead Log). MySQL has the binlog. **Debezium** is the most common CDC tool — it tails these logs and publishes changes to Kafka in real-time.

```
Application ──► PostgreSQL (writes to WAL) ──► Debezium (reads WAL) ──► Kafka
                              (transaction log)        (CDC tool)
```

**Why it's powerful:**
- Zero application-level changes — the database change is captured regardless of how it was made
- Sub-second latency (reading the WAL as it's written)
- Used for: keeping a search index (Elasticsearch) in sync with your DB, syncing data warehouses, feeding downstream services

**vs. Outbox:** Outbox is explicit (you write to an outbox table). CDC is transparent (reads the WAL automatically). CDC is operationally more complex to set up but requires no application changes.

---

### 11.6 Circuit Breaker

**The problem:** Service A calls Service B. Service B is slow or down. Without protection, Service A's threads pile up waiting for B's response, eventually exhausting A's thread pool and taking A down too. This is a **cascading failure**.

**Circuit breaker** is borrowed from electrical engineering. It monitors calls to a service and "trips" (opens the circuit) when the failure rate crosses a threshold. While open, calls fail immediately (fast fail) instead of waiting to time out.

```
States:

  CLOSED (normal):
    Requests pass through to Service B
    Failure rate monitored in a sliding window
    If failure rate > 50% in last 60 sec → OPEN

  OPEN (failing fast):
    Requests immediately return an error (no network call made)
    Wait for a recovery timeout (e.g., 30 sec)
    → HALF-OPEN

  HALF-OPEN (testing recovery):
    Allow one probe request through to Service B
    If it succeeds → CLOSED (circuit reset)
    If it fails   → OPEN again (wait longer)
```

```
Service A ──► [Circuit Breaker] ──► Service B

  Normal:  A → CB (closed) → B
  Tripped: A → CB (open)  → immediate error returned to A
                             B gets no traffic (time to recover)
```

**Why it matters for the user experience:** Fail fast + return a fallback (stale cached data, default response, graceful degradation) is much better than timing out after 30 seconds.

> When you hear "put a circuit breaker there" in a meeting, it means: if that downstream dependency degrades, we want to stop hammering it and return a fast fallback rather than letting the failure cascade upward.

---

### 11.7 Domain-Driven Design (DDD) Vocabulary

You'll hear these terms in architecture discussions. They're a vocabulary for thinking about how to carve up a large system.

**Domain:** The business problem space. For a healthcare platform: clinical scheduling, billing, clinical documentation, member management are domains.

**Bounded Context:** A linguistic and logical boundary within which a model (set of terms, rules, entities) is consistent and has a specific meaning. The word "patient" means different things in the billing context (a payer) and the clinical context (someone receiving care). Each bounded context has its own database, its own service, and its own definition of "patient."

```
┌──────────────────────────┐     ┌──────────────────────────┐
│   Scheduling Context      │     │   Billing Context         │
│   "patient" = person      │     │   "patient" = payer       │
│   with appointments       │     │   with insurance + co-pay │
│                          │     │                           │
│   Appointment             │     │   Claim                   │
│   Provider                │     │   Invoice                 │
│   Slot                    │     │   InsurancePlan           │
└──────────────────────────┘     └──────────────────────────┘
          │ events cross context boundaries via Kafka
```

**Aggregate:** A cluster of domain objects that must be kept consistent together, with one root entity (the **Aggregate Root**) through which all external access goes. The aggregate is also the unit of a transaction — all changes to the aggregate happen in one transaction.

```
Appointment (Aggregate Root)
  ├── AppointmentSlot
  ├── AttendanceRecord
  └── RescheduleHistory

Rule: You can only change AttendanceRecord through Appointment.
      You cannot update AttendanceRecord directly.
      This ensures the invariant "you can't mark attendance without an appointment" is always enforced.
```

**Repository:** An abstraction over the data store for a specific aggregate. From the domain code's perspective, the repository looks like an in-memory collection. It hides SQL, Cassandra, or whatever storage is behind it.

> **In meetings:** "That belongs in a different bounded context" means the feature/data is someone else's responsibility and crosses a service boundary. "What's the aggregate root here?" means: what is the main entity that owns and protects this cluster of data?

---

### 11.8 Module 11 — Quick Fire

| Term | One-line definition |
|------|---------------------|
| Event sourcing | Store events, not state. Current state = replay of all events |
| CQRS | Separate the write model (commands) from the read model (queries) |
| Saga | Sequence of local transactions with compensating actions for rollback |
| Outbox pattern | Write to DB + outbox in one transaction; poll outbox to publish events |
| CDC | Read the database transaction log (WAL/binlog) to stream changes as events |
| Circuit breaker | Trips on high failure rate; returns fast errors instead of waiting |
| Bounded context | Linguistic/service boundary within which a model is consistent |
| Aggregate root | The entry point of an aggregate; the unit of a transaction |
| Compensating transaction | The "undo" operation for a completed saga step |

---

## Module 12: Observability & Reliability Engineering

> **Priority: HIGH.** Senior engineers don't just build systems — they own them in production. This vocabulary comes up in every architecture review and incident debrief.

---

### 12.0 Resilience Vocabulary — The Terms Behind the Buzzword

> **Why this section is here:** "How resilient is this design?" is a question you'll get, and the words *reliability*, *fault tolerance*, and *redundancy* sound similar but mean different things. Get them tangled in an interview and you lose credibility fast. This section makes them crisp.

```
┌────────────────────────────────────────────────────────────────────┐
│  RELIABILITY   — Does the system work correctly when it works?     │
│  FAULT TOLERANCE — Does the system survive when something breaks?  │
│  REDUNDANCY    — Do we have backups ready to take over?            │
│  RESILIENCE    — The umbrella: does the system absorb and recover? │
└────────────────────────────────────────────────────────────────────┘
```

#### Reliability — Works Correctly and Consistently

A reliable system gives the right answer, the right way, every time. It's not just *up* — it's *correct*.

```
Reliable:
  Booking service: user clicks "Book 3pm Tuesday"
  → returns 200 with a confirmed appointment
  → the database has the new appointment
  → the user gets a confirmation email
  → if any of these fail, the system tells the user clearly (not a silent partial success)

Unreliable:
  Booking service: user clicks "Book 3pm Tuesday"
  → returns 200 (claimed success)
  → database write succeeded
  → email never sent
  → user thinks the appointment is confirmed; it shows in the app,
    but they got no notification, and the therapist's calendar
    shows it differently. Silent inconsistency.
```

**Reliability is about *correctness*, not just availability.** A system that's always available but sometimes lies to the user is not reliable.

#### Fault Tolerance — Survives When Things Break

A fault-tolerant system **keeps functioning** when components fail. The failure is contained; the service degrades gracefully instead of collapsing.

```
Server dies:         Load balancer stops sending traffic to it.
Network blips:        Retry with exponential backoff; circuit breaker
                      opens if the dependency is too sick to call.
Database is slow:     Read replica takes over; cache absorbs the load.
Third-party API down: Circuit breaker returns "service degraded";
                      users see a banner, not a stack trace.
Region goes down:     DNS failover routes traffic to another region.
```

> **Interview tip:** "My design is fault-tolerant to *N* server failures" is a concrete, measurable claim. Specify *N* and the interviewer knows you've actually thought about the failure modes.

#### Redundancy — Backups Ready to Take Over

Redundancy is the *mechanism* that makes fault tolerance possible: having **more than one** of the critical components.

```
Redundancy patterns:
  + Data redundancy:        Multiple copies of the data (replication, backups)
  + Compute redundancy:     Multiple app servers behind a load balancer
  + Network redundancy:     Multiple ISPs, multiple network paths
  + Geographic redundancy:  Multi-region deployment
  + Power redundancy:       UPS, generators, multiple power feeds

Rule of thumb: every component that can take the system down
should have at least one backup ready to take over automatically.
```

**Important:** "Redundant" doesn't mean "duplicated." A replica is redundant; a backup on tape that takes 4 hours to restore is not (for runtime redundancy).

> **Interview tip:** "We have N+2 redundancy" is a specific, senior claim. It means we can lose 2 servers out of N+2 and still serve traffic at full capacity. N+1 means losing 1 is fine; N+2 means losing 2. Pick the right number based on your SLA.

#### Resilience — The Umbrella

Resilience is the property of *absorbing failures and recovering from them*. Reliability + fault tolerance + redundancy are the ingredients.

```
A resilient system:
  1. Detects failures (monitoring, alerts)            ← observability
  2. Limits blast radius (isolation, bulkheads)        ← fault tolerance
  3. Continues core functionality (graceful degradation) ← fault tolerance
  4. Recovers automatically (auto-scaling, failover)   ← redundancy
  5. Recovers state correctly (replication, backups)   ← reliability
  6. Learns from incidents (postmortems, action items)  ← culture
```

> **Senior framing:** "I'd say the design is resilient to one full AZ failure and one slow third-party dependency simultaneously. Beyond that, the booking flow degrades to a 'try again later' message — which is acceptable per our SLO of 'core booking flow succeeds 99.9% of the time.'" Specific failure modes + specific recovery = the senior answer.

#### How to Apply This in an Interview

When you describe a design, ask yourself: **what's the worst single thing that can break, and what happens?**

| Failure | A weak answer | A strong answer |
|---------|---------------|-----------------|
| "What if the database dies?" | "We have backups." | "Primary fails → the replica is promoted in <30s via automated failover. Reads/writes resume. RPO = 0 (sync replication), RTO = 30s." |
| "What if a region goes down?" | "We have multi-region." | "DNS health check fails → traffic shifts to the secondary region in ~60s. The secondary runs warm (serving 10% of traffic normally) so it's not cold-starting. Database is asynchronously replicated; we may lose <1 minute of writes." |
| "What if the third-party payment API is down?" | "We retry." | "Circuit breaker opens after 5 failures in 10s. New payment requests get a 503 + 'payment temporarily unavailable' message. We persist the pending payment in our DB and retry asynchronously when the third party recovers. Users see the truth; the system stays internally consistent." |

> **The senior signal:** Naming **RPO** (Recovery Point Objective — how much data you can afford to lose) and **RTO** (Recovery Time Objective — how long recovery can take) is gold. These are the actual numbers you negotiate with the business.

#### 12.0.1 Defense in Depth

> **Interview relevance: Differentiator.** WAF + private subnet + RBAC + encryption at rest — the 7 layers. Not asked as a topic, but "how is this secure?" comes up implicitly. Naming the layers is a top-of-band answer.

"Defense in depth" means layering security so a breach at one layer doesn't compromise the system. Every production system is attacked at the edge first; you need layers beyond the edge.

```
LAYER 1 — EDGE:
  CDN + WAF + DDoS protection (Cloudflare, AWS Shield, CloudFront + WAF)
  Blocks: SQL injection, XSS, path traversal, volumetric DDoS,
          scanner traffic, geographic blocks.
  Why: filters 99% of junk before it touches your infra.

LAYER 2 — NETWORK:
  Security groups, private subnets, VPCs, mTLS between services.
  The database is in a private subnet — no public IP.
  Why: even if a request bypasses the WAF, it can't reach internal systems.

LAYER 3 — IDENTITY:
  OAuth2 / OIDC at the API gateway. Per-user authn.
  mTLS between services (each service has a certificate).
  Why: every request is authenticated, every caller is identified.

LAYER 4 — AUTHORIZATION:
  RBAC + ABAC in the service. The user can do only what their role allows.
  Why: a valid token doesn't grant access to everything.

LAYER 5 — APPLICATION:
  Input validation, output encoding, parameter binding, secrets in
  a vault (AWS Secrets Manager, HashiCorp Vault), no secrets in code.
  Why: prevent the most common code-level vulnerabilities (OWASP Top 10).

LAYER 6 — DATA:
  Encryption at rest (KMS-managed keys), encryption in transit (TLS),
  tokenization for PII, key rotation.
  Why: even if the database is breached, the data is unreadable.

LAYER 7 — DETECTION:
  SIEM, anomaly detection, audit logs reviewed by humans/ML.
  Why: when an attack succeeds (and one will), you know fast.
```

> **Senior signal:** "For our public API, I'd put a WAF at the edge (Cloudflare or AWS WAF) to block OWASP Top 10 attacks. The API gateway enforces per-user authn. The app services are in a private subnet, no public IPs. The DB is encrypted at rest with KMS, and we rotate keys annually. Audit logs flow to a SIEM. This is defense in depth — six layers, each independent."

#### 12.0.2 WAF — The Web Application Firewall

> **Interview relevance: Differentiator.** OWASP Top 10 + AWS WAF + Cloudflare. Mentioned unprompted when discussing public API security. A cheap differentiator.

```
WAF (Web Application Firewall):
  Sits in front of your web app. Inspects HTTP requests.
  Blocks based on rules: signature-based (known patterns),
  rate-based (too many requests), anomaly-based (unusual behavior).

WHAT IT BLOCKS:
  ✓ SQL injection:    ' OR 1=1 -- in a query parameter
  ✓ XSS:              <script>alert('xss')</script> in a form
  ✓ Path traversal:   ../../../../etc/passwd in a URL
  ✓ RCE attempts:     ; rm -rf / in a header
  ✓ Rate-based:       10K requests/sec from one IP
  ✓ Geographic:       all traffic from country X (sanctions)
  ✓ Bot detection:    headless browsers, known scanner user-agents

CONCRETE EXAMPLES:
  AWS WAF + CloudFront:
    Ruleset: AWS Managed Rules + OWASP Top 10
    Per-rule action: count, allow, block, challenge (CAPTCHA)
    Cost: $5/month + $1/million requests

  Cloudflare WAF:
    Free tier: basic rules.
    Pro:        full OWASP + custom rules + bot protection.
    Cost:       $20/month.

  ModSecurity:
    Open-source, run as NGINX module.
    ✓ Free, ✓ full control.
    ✗ You operate it.

IN THE INTERVIEW:
  "I'd put a WAF in front of the public API as the first line of defense.
   It blocks SQL injection, XSS, and volumetric abuse before the
   requests reach my app servers. The WAF is configured with the
   OWASP Top 10 ruleset plus a custom rule for our specific API."
```

#### 12.0.3 Resilience Patterns Cheat Sheet

> **Interview relevance: Differentiator.** Naming retry / timeout / circuit breaker / bulkhead / rate limit / graceful degradation in one breath is a top-of-band moment. Required for any "how do you handle dependency failure?" question.

"Resilience pattern" is the umbrella for the specific techniques you apply when a dependency is sick. The senior move is naming the *right* pattern for the *right* failure.

```
RETRY:
  Try the call again. Most useful for transient failures (network blip, 503).
  ✓ Easy. ✓ Works for idempotent operations.
  ✗ Useless for permanent failures (404, 400).
  ✗ Dangerous for non-idempotent operations (charging a credit card).
  Use with: exponential backoff + jitter. Cap at 3-5 attempts.

TIMEOUT:
  Set a deadline on every external call. Always.
  ✓ Prevents thread pile-up when a dependency is slow.
  ✓ Forces the caller to make a decision (retry, fail, fallback).
  ✗ Time too short: false positives. Too long: piles up.
  Use: 100-500ms for a database call, 1-5s for a third-party API.

CIRCUIT BREAKER:
  Stop calling a sick dependency. Fail fast.
  ✓ Prevents cascading failure.
  ✓ Gives the sick dependency time to recover.
  ✗ Requires tuning (what's the failure threshold?).
  Use: in front of every external service.

BULKHEAD:
  Isolate dependencies. A failure in one doesn't take down the others.
  ✓ Limits blast radius.
  ✗ More moving parts.
  Concrete: a separate thread pool for the payment API and another
            for the search API. Payment API slow → search API unaffected.

RATE LIMIT:
  Cap the rate of incoming requests. Protects the system from
  one client overwhelming the others.
  ✓ Protects backend.
  ✓ Fairness.
  ✗ Doesn't fix a slow downstream.
  Use: at the gateway, per-user.

GRACEFUL DEGRADATION:
  When a dependency is down, serve a degraded version of the feature.
  ✓ Users see something instead of an error.
  ✗ Hard to design well.
  Concrete: search is down → return "popular items" instead of "no results".
            map is down → return a static map image.

CHAOS ENGINEERING:
  Inject failures deliberately to test resilience.
  ✓ Finds problems before users do.
  ✗ Requires cultural buy-in (and Netflix-grade maturity).
  Tools: Chaos Monkey, Gremlin, AWS Fault Injection Service.
```

> **Interview signal:** "For our service that calls Stripe, I'd put a circuit breaker in front. On 5 failures in 10 seconds, the circuit opens and new requests fail fast with a 503. We'd persist the pending payment in our DB and retry asynchronously when Stripe recovers. The user sees a 'payment processing' message, not a generic 500."

---

---

### 12.1 SLI, SLO, SLA — The Reliability Hierarchy

These three acronyms are used constantly in reliability discussions and often confused.

**SLI (Service Level Indicator):** A specific, measurable metric that reflects how a service is performing.

```
Examples of SLIs:
  - "99.5% of appointment booking requests complete in < 200ms"
  - "Error rate of the login endpoint < 0.1%"
  - "95th percentile of API latency < 500ms"
```

**SLO (Service Level Objective):** The target value for an SLI. This is an internal goal.

```
SLI: 99th percentile latency of the booking API
SLO: That latency must be < 400ms, 99.9% of the time, over a 30-day rolling window
```

**SLA (Service Level Agreement):** A contract with external parties (customers, enterprise clients) that includes consequences if the SLO is breached (refunds, credits).

```
Hierarchy:
  SLA (legal contract, external)
    └── SLO (internal target, stricter than SLA to give buffer)
          └── SLI (the actual measurement)

A typical SLA says "99.9% uptime."
The internal SLO might target "99.95% uptime" to have a safety buffer.
The SLI measures actual uptime continuously.
```

**Error budget:** The amount of downtime/errors you're *allowed* by your SLO before breaching it.

```
SLO: 99.9% availability (30-day window)
Error budget: 0.1% of 30 days = 43.2 minutes of allowed downtime
              (if you exceed 43.2 minutes of downtime, you've burned your error budget)
```

Error budgets make reliability decisions concrete: "We've consumed 80% of our error budget this month. We should not deploy risky changes before the month resets."

> **Senior signal:** In a design interview, saying "I'd define SLOs upfront for the critical paths — the appointment booking API should target P99 < 300ms — and design the system's caching, replication strategy, and circuit breakers to protect that SLO" shows production ownership.

#### 12.1.1 The SLA-to-Downtime Table

> **Interview relevance: Differentiator.** Memorize 99.9% = 8.7h/year, 99.99% = 52min/year. The interviewer will accept a rough number; the senior answer cites it from memory.

The exact downtime numbers are something senior candidates cite from memory. The table is the source of truth.

```
SLA         Per year          Per month        Per week
99%         3.65 days         7.2 hours        1.68 hours
99.9%       8.77 hours        43.2 min         10.1 min
99.95%      4.38 hours        21.6 min         5.04 min
99.99%      52.6 min          4.32 min         1.01 min
99.999%     5.26 min          25.9 sec         6.05 sec
```

**How to use this in the interview:**

```
"For our chat service, I'd target 99.9% availability — that's
 8.7 hours of allowed downtime per year. I'd need 2-AZ
 deployment with automated failover. For our payment service,
 I'd target 99.99% — 52 minutes per year. That requires
 multi-region active-active."

"At 99.999%, I'm in 5-minutes-of-downtime-a-year territory.
 That means 3+ regions active-active, automated failover
 with chaos drills, and probably a dedicated SRE team.
 I would NOT propose this for a 10-person startup."
```

---

### 12.2 The Three Pillars of Observability

When something breaks in production, you need to answer: "What happened, when, to whom, and why?" The three pillars are the tools for that.

**Metrics:** Aggregated numerical measurements over time. They answer "is something wrong right now?"

```
Examples:
  - API request rate (requests/sec)
  - Error rate (% of requests that returned 5xx)
  - P50/P95/P99 latency
  - CPU utilization
  - Cache hit rate
  - Queue depth (how many messages are waiting)

Tools: Prometheus (collection), Grafana (visualization), Datadog
```

Metrics are cheap to store and query, but they're pre-aggregated — you lose individual request detail.

**Logs:** Structured, timestamped records of discrete events. They answer "what exactly happened in this specific request?"

```json
{
  "timestamp": "2026-03-15T10:23:45Z",
  "level": "ERROR",
  "service": "appointment-service",
  "trace_id": "abc123",
  "user_id": "user-456",
  "message": "Failed to reserve slot",
  "error": "slot already held by another user",
  "slot_id": "slot-789"
}
```

**Structured logs** (JSON, not plain text strings) are essential — you need to query logs by `user_id`, `trace_id`, etc. Plain text is unsearchable at scale.

**Traces (Distributed Tracing):** A trace follows a single request as it travels through multiple services. Each step is a **span**. Together, spans form a trace that shows the full call path and latency at each hop.

```
Trace: "User books appointment" (total: 312ms)
  │
  ├── Span: API Gateway (12ms)
  │
  ├── Span: Appointment Service - validate (8ms)
  │
  ├── Span: Appointment Service - check Redis for hold (3ms)
  │
  ├── Span: Appointment Service - write DB (45ms)
  │      ⚠ Unusually slow — this is where you look
  │
  ├── Span: Notification Service - send email (200ms)
  │      ⚠ Dominating the latency — fire-and-forget this
  │
  └── Span: API Gateway - return response (1ms)
```

Without distributed tracing, you see "the booking API is slow at P99" in your metrics, but you don't know if the slowness is in the database, the notification service, or a network hop. Tracing pinpoints it.

**Tools:** OpenTelemetry (standard SDK for instrumentation), Jaeger or Zipkin (trace storage and UI), Datadog APM.

> When you hear "we need to add tracing to this service" in a meeting, it means: we want to see end-to-end request flows across service boundaries so we can diagnose latency and errors.

---

### 12.3 Deployment Strategies — Blue/Green and Canary

**Blue/Green deployment:**
Run two identical production environments. "Blue" is the current live version. You deploy to "Green," test it, then switch the load balancer to route all traffic to Green. Rollback is instant — just flip back to Blue.

```
  Load Balancer
       │
       ├── Blue (v1.0) ← current production
       └── Green (v1.1) ← new version, being tested

After validation:
  Load Balancer
       │
       ├── Blue (v1.0) ← idle, ready for instant rollback
       └── Green (v1.1) ← now production
```

**Canary deployment:**
Release the new version to a small percentage of traffic first. Monitor for errors. Gradually increase the percentage. Roll back if errors spike.

```
Stage 1:  1% → new version, 99% → old
Stage 2: 10% → new version, 90% → old
Stage 3: 50% → new version, 50% → old
Stage 4: 100% → new version
```

Named after the "canary in a coal mine" — a small population is exposed to the risk first to detect danger before the whole system is affected.

**When to use which:**
- Blue/Green: large, risky migrations (database schema changes, infrastructure upgrades). Full traffic switch is clean.
- Canary: typical feature releases. Safer for catching bugs that only appear at scale.

#### 12.3.1 Rolling Deployment and Deployment by Service Type

> **Interview relevance: Core.** "How do you deploy?" is a frequent question. Knowing rolling / blue-green / canary and when each fits (stateless vs stateful vs ML model) is required.

Blue/green and canary are the two everyone knows. There's a third, often the default.

```
ROLLING DEPLOYMENT:
  Replace instances of the old version one at a time, with a health
  check between each. Continue while the cluster is healthy.
  ✓ No idle capacity (no Blue and Green running simultaneously).
  ✓ Incremental; can pause if something goes wrong.
  ✗ Old and new versions serve traffic simultaneously during the deploy.
    Schema/contract changes that aren't backward-compatible break.
  ✗ Rollback is slow (have to roll instances back one at a time).
  → Use for: stateless services with backward-compatible contracts.

  Stage 1: [v1, v1, v1, v1, v1]  (5 instances)
  Stage 2: [v2, v1, v1, v1, v1]  (one replaced)
  Stage 3: [v2, v2, v1, v1, v1]
  Stage 4: [v2, v2, v2, v1, v1]
  ...
  Stage N: [v2, v2, v2, v2, v2]
```

**Decision: which strategy for which service type:**

```
STATELESS MICROSERVICE (chat, search, recommendation):
  → Rolling deployment.
  → Old and new versions can coexist (no shared state).
  → Rollback is just "redeploy the old image."

STATEFUL SERVICE (Postgres, Kafka, Redis):
  → Blue/Green. Database schema changes are the riskiest part of any
    deploy. You want to be able to abort and roll back cleanly.
  → Tools: pt-online-schema-change, gh-ost, AWS DMS, logical replication.

ML MODEL (recommendation, ranking, fraud detection):
  → Canary with A/B measurement. The model needs traffic to evaluate;
    you can't tell if it's better from unit tests.
  → Compare business metrics (CTR, fraud caught, conversion) between
    canary and control.

INFRASTRUCTURE / KUBERNETES UPGRADES:
  → Blue/Green at the cluster level. Drain nodes from one cluster,
    bring up nodes in the new cluster, switch the load balancer.
  → Tools: cluster API, ArgoCD, Spinnaker.

FRONT-END (web bundle, mobile app):
  → No real "deploy" — apps are downloaded. For web bundles:
    blue/green at the CDN (CloudFront with two origins, weighted).
  → Mobile: phased rollout via app store (1% → 10% → 50% → 100%).
```

> **Senior signal:** "I'd use rolling deploys for our stateless services, blue/green for the database schema changes, and canary with A/B measurement for the ML model. Picking the right strategy per service type is the senior answer."

#### 12.3.2 Auto-Scaling Strategies

> **Interview relevance: Differentiator.** Not asked directly, but "how does your service scale?" comes up. Naming reactive + predictive + queue-depth is a top-of-band answer.

Auto-scaling isn't "scale on CPU." It's a portfolio of strategies.

```
REACTIVE (scale when a metric crosses a threshold):
  - CPU > 70% for 5 min  → add 2 instances
  - Memory > 80%         → add 2 instances
  - Queue depth > 1000   → add 2 consumers
  - Request latency P99 > 500ms → add 2 instances
  ✓ Reactive, predictable.
  ✗ Reacts AFTER the problem. By the time CPU is 70%, users are
    already feeling slowness.
  ✗ Scale-down is slow (you don't want to thrash).

PREDICTIVE / SCHEDULED (scale on a known schedule):
  - "Every weekday at 8am, ensure min 10 instances."
  - "Black Friday: pre-scale to 50 instances at 00:00."
  ✓ Scale-up is zero-latency (instances are warm before traffic arrives).
  ✗ Only works when the schedule is predictable.

COLD-START-FRIENDLY (serverless-style):
  - First request after idle pays a 1-3s cold-start tax.
  - The benefit: zero cost when idle, infinite scale under load.
  ✓ Cheapest for spiky async work.
  ✗ Bad for user-facing paths with strict latency SLOs.

QUEUE-DEPTH DRIVEN (the right pattern for async workers):
  - "When the queue has > 1000 messages, add 5 consumers."
  - "When queue depth drops below 100 for 5 min, remove consumers."
  ✓ Auto-scales with actual work to be done, not arbitrary metrics.
  ✓ Cheap (no scale-up until there's work).
  → Use for: image thumbnail workers, ML inference workers,
             webhook delivery workers.
```

> **Senior signal:** "For our API tier, I'd use reactive auto-scaling on CPU and request rate. For our async workers (image processing, email sending), I'd use queue-depth auto-scaling — workers scale with the work."

---

### 12.4 The Production Pipeline — CI/CD, Logs, Alerts, Debug

> **Why this matters:** "How does your code get to production, and what happens when it breaks there?" is the unspoken question behind every system design. Junior candidates draw a happy-path box diagram and stop. Senior candidates narrate the full lifecycle.

#### The CI/CD Pipeline

**Continuous Integration (CI):** Every commit triggers an automated build + test pipeline. No human clicks "run tests." Catches breakages in minutes, not days.

**Continuous Delivery (CD):** Every green build produces a deployable artifact (a Docker image, a binary, a versioned bundle). Deployment to production is the next step — possibly manual for high-risk, possibly automatic for low-risk.

**Continuous Deployment (CD, the strict version):** Every green build goes to production automatically. No human gate. Used by Netflix, Facebook, Amazon.

```
Developer pushes commit
       │
       ▼
GitHub / GitLab / Bitbucket
       │
       ▼
CI runner:  checkout → install deps → compile → unit tests
            → integration tests → static analysis → security scan
            → build Docker image → push to container registry
       │
       ▼  (on success)
Staging:   auto-deploy to a staging environment
           → run smoke tests → run contract tests
       │
       ▼  (on success)
Production: auto-deploy (canary → full) OR wait for human approval
       │
       ▼
Health checks + smoke tests on the new version
       │
       ▼
Keep monitoring: if error rate spikes, auto-rollback
```

**Common tools:** GitHub Actions, GitLab CI, Jenkins, CircleCI, Buildkite, Bitrise (mobile). The tool doesn't matter in the interview; saying "I'd set up GitHub Actions for CI, with a Docker image build and a staging deploy on every merge to main" is enough.

> **Senior signal:** "I want a staging environment that's production-shaped (same data shape, same infra) but isolated, plus a canary deploy to production where 5% of traffic hits the new version for 15 minutes before full rollout. If the canary's error rate exceeds baseline, auto-rollback." That's a real production pipeline.

#### Logging — What Goes Where, and How Much

Every system you design generates logs. The question is *what kind*, *where they go*, and *who can read them*.

```
Application logs:
  - "User 123 booked slot 456 at 14:32:01"
  - "Failed to send email: SMTP timeout"
  - Use structured (JSON) logging with trace_id, user_id, level, timestamp
  - Stdout in containers; a sidecar (Fluentd, Filebeat, Vector) ships them
    to a central store (Elasticsearch, Loki, CloudWatch Logs, Datadog)

Access logs:
  - "GET /api/therapists 200 in 87ms from 192.0.2.45"
  - Generated by the reverse proxy / load balancer
  - Essential for understanding traffic patterns, debugging user complaints
    ("why is this user's request slow?")

Error / exception logs:
  - Stack traces, error codes, context for failures
  - Often sent to a dedicated tool: Sentry, Rollbar, Bugsnag
  - These tools group, deduplicate, and alert on new error patterns

Audit logs (see Module 13):
  - Who did what, when, from where
  - Append-only, often stored separately from app logs
```

> **Interview tip:** "Logs from the app server live on the same server, but I ship them to an external log store (CloudWatch / Datadog / ELK) so when the server dies, the logs survive. The log store is in a separate AWS account from production, so an attacker who compromises production can't tamper with the audit trail." This kind of operational thinking is what separates senior from mid-level.

#### Monitoring vs Alerting — Different Jobs

**Monitoring** = continuously collecting and visualizing metrics so humans can see what's happening.

**Alerting** = automatically paging humans when something is wrong.

| | Monitoring | Alerting |
|--|------------|----------|
| Purpose | Visibility — "what is the system doing right now?" | Action — "wake someone up because something is broken" |
| Examples | Grafana dashboard, Datadog overview, CloudWatch metrics | PagerDuty alert, Slack notification, Opsgenie page |
| Latency | Real-time, human-paced | As fast as the on-call engineer can respond |
| Granularity | Everything, all the time | Only what you would wake someone up for |

> **The senior heuristic:** "If the page is not actionable, don't send it." A page that says "error rate is 0.5% above baseline" with no runbook is noise. A page that says "error rate > 5% for 5 min — likely cause: payments service 503ing — runbook: [link] — last incident: [link]" is a good page.

#### Alerting Channels — Where the Wake-Up Goes

```
Slack channel:   for non-urgent, team-visible issues
                 (deploy notifications, warning-level alerts)

Email:           for summaries, daily digests, non-time-sensitive

PagerDuty /     for urgent, on-call rotations
Opsgenie:        escalates through levels if not acknowledged

SMS / phone:     for true emergencies, after-hours pages
                 (SLO-breaching outage, security incident)
```

> **Interview tip:** Mention the integration chain: *"Metrics breach the SLO threshold → Alertmanager fires → PagerDuty page goes to the on-call → if no ack in 5 min, escalate to the secondary → Slack channel gets a thread for context."* This is what real production looks like.

#### The Debugging Workflow — When Something Breaks

This is the lifecycle of an incident, from "oh no" to "we shipped the fix." It comes up in design interviews because interviewers want to know you've actually lived through one.

```
1. DETECT     Alert fires (PagerDuty, Sentry, user report, status page)
2. TRIAGE     On-call acknowledges; opens #incident channel
              Classifies severity: SEV1 (outage) / SEV2 (degraded) / SEV3 (minor)
3. INVESTIGATE  Look at dashboards (metrics), tail logs, look at recent deploys
                Recent deploy? → check the diff. Spike? → check the dependency.
4. MITIGATE   First goal is to *stop the bleeding*, not to understand why
               - Roll back the deploy
               - Disable a feature flag
               - Drain traffic from a bad node
               - Failover to backup region
5. RESOLVE    Apply the real fix; verify metrics return to baseline
6. POSTMORTEM Blameless write-up: timeline, root cause, contributing factors,
              action items to prevent recurrence
```

> **Senior signal:** "We never debug in production directly — we replicate the issue in a staging environment that matches production. We use the same logs, the same data shape, the same dependencies. We don't poke at production with curl." This is the "golden rule" the video mentions and it's a real interview point.

#### The "Hotfix" Pattern

A **hotfix** is a small, targeted patch to stop a bleeding issue immediately. It's not the elegant, long-term fix — that's the *root cause* fix. The hotfix is a tourniquet.

```
1. Production is on fire
2. Engineer writes a 5-line patch (a feature flag, a config change, a one-line revert)
3. Patch goes through the *expedited* pipeline (skip the canary, get human approval, ship in <15 min)
4. Production stabilizes
5. A *proper* fix follows in the normal pipeline (canary, full rollout)
```

> **Interview tip:** "If my service is throwing exceptions on every request, I'd ship a hotfix that adds a try/catch returning a 503 and a feature flag to disable the broken path. The long-term fix (rewrite the function, fix the data corruption) goes through the normal pipeline." Knowing the difference between hotfix and proper fix is a senior signal.

---

### 12.5 Module 12 — Quick Fire

| Term | Definition |
|------|-----------|
| SLI | The actual measurement (e.g., P99 latency = 280ms) |
| SLO | The target for the SLI (e.g., P99 must be < 400ms) |
| SLA | External contract with penalties if SLO is breached |
| Error budget | Allowed amount of failure before breaching SLO |
| Metrics | Aggregated time-series numbers. Fast, cheap, low detail |
| Logs | Per-event structured records. High detail, expensive to query at scale |
| Traces | End-to-end request path across services with per-span latency |
| OpenTelemetry | Vendor-neutral SDK standard for emitting metrics, logs, traces |
| Canary deployment | Gradually shift traffic to new version; monitor before full rollout |
| Blue/Green | Two environments; instant switch + instant rollback |
| CI vs CD | CI: every commit auto-tested. CD: every green build is auto-deployable (or auto-deployed) |
| Monitoring vs alerting | Monitoring = human-paced visibility. Alerting = actionable page to on-call |
| Hotfix vs proper fix | Hotfix: small patch to stop the bleeding, ships fast. Proper fix: root-cause fix through normal pipeline |
| Why ship logs off the server? | So they survive server death and can't be tampered with if the server is compromised |
| Why are alerts in Slack *and* PagerDuty? | Slack for team-visible context (warnings, deploys). PagerDuty for urgent, on-call, escalatable pages |
| Reliability vs fault tolerance? | Reliability = works correctly when up. Fault tolerance = keeps working when something breaks |
| What is N+2 redundancy? | You can lose 2 of N+2 components and still serve at full capacity. N+1 = survive 1 failure |
| What are RPO and RTO? | RPO: how much data loss is acceptable. RTO: how long recovery can take. The two numbers you negotiate |
| Graceful degradation means what? | When a dependency fails, the system stays up but with reduced functionality (e.g., disable a feature, show a banner) instead of crashing |

---

## Module 13: Sensitive Data & Compliance in System Design

> **Priority: CRITICAL for regulated domains.** Any system dealing with health records, financial data, or personal data operates under legal constraints that directly shape the architecture. These constraints are non-negotiable and interviewers at companies in these spaces explicitly test for this awareness.

---

### 13.1 Why Sensitive Data Changes Your Architecture

In a standard consumer app, the worst case of a data breach is reputational damage. In healthcare or finance, it also means regulatory fines, loss of operating licenses, and personal liability. This forces specific architectural choices:

- **Audit logs** are not optional — you must be able to answer "who accessed this record, when, from where, and why"
- **Encryption at rest** is not optional
- **Data minimization** — only collect what you need; the less you store, the smaller the blast radius of a breach
- **Access control** must be fine-grained — a billing staff member should never see clinical notes
- **Data residency** — certain jurisdictions require data to stay within their borders (GDPR in EU, LGPD in Brazil, HIPAA in the US)

---

### 13.2 Encryption At Rest vs In Transit

**Encryption in transit:** Data is encrypted as it travels over the network. TLS (Transport Layer Security) handles this. Any modern API using HTTPS has encryption in transit.

What TLS does, simply:
```
1. Client and server agree on encryption keys (TLS handshake)
2. All subsequent data is encrypted — an eavesdropper sees gibberish
3. Certificate verifies the server is who it claims to be
```

For mobile apps handling sensitive data: **certificate pinning** — the app only trusts a specific certificate (or public key), not just any CA-issued cert. Prevents man-in-the-middle attacks using rogue certificates.

**Encryption at rest:** Data is encrypted on disk. If someone steals the hard drive, they get encrypted data.

Two approaches:
- **Transparent disk encryption** (e.g., AWS EBS encryption, database-level encryption): the database/cloud handles it automatically. Simplest. Protects against physical theft.
- **Application-level encryption:** The application encrypts specific fields before writing to the database. More complex, but protects against compromised database access (a DBA can't read encrypted fields without the key).

```sql
-- Application-level field encryption:
-- Store SSN encrypted, not as plain text
INSERT INTO patients (id, name, ssn_encrypted)
VALUES ('123', 'Alice Jones', encrypt('123-45-6789', key));

-- Only decrypt at access time, in the application layer
```

**Key management:** Where you store the encryption keys is as important as the encryption itself. Keys must not be in the same system as the encrypted data. Use a dedicated key management service (AWS KMS, GCP Cloud KMS, HashiCorp Vault).

---

### 13.3 Audit Logging

An audit log is an append-only, tamper-evident record of every access or modification to sensitive data. In healthcare this is called an **access log**; in finance it's called an **audit trail**.

**What to log:**
```
- WHO: user_id, role, service that made the request
- WHAT: resource type, resource ID, operation (read/write/delete)
- WHEN: timestamp with timezone
- WHERE: IP address, device, geographic region
- WHY: (if available) reason_code or session context
- RESULT: success or failure
```

**Minimal schema:**

```sql
CREATE TABLE audit_log (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id     UUID        NOT NULL,  -- who performed the action
  actor_role   VARCHAR(50) NOT NULL,  -- their role at the time
  action       VARCHAR(50) NOT NULL,  -- 'READ', 'UPDATE', 'DELETE', 'EXPORT'
  resource_type VARCHAR(50) NOT NULL, -- 'PatientRecord', 'Appointment', 'Prescription'
  resource_id  UUID        NOT NULL,
  ip_address   INET        NOT NULL,
  user_agent   TEXT,
  result       VARCHAR(10) NOT NULL,  -- 'SUCCESS', 'DENIED', 'ERROR'
  metadata     JSONB,                 -- additional context
  occurred_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for "show me all access to patient X's record":
CREATE INDEX idx_audit_resource ON audit_log(resource_type, resource_id, occurred_at DESC);

-- Index for "show me all actions by user Y":
CREATE INDEX idx_audit_actor ON audit_log(actor_id, occurred_at DESC);
```

**Critical properties:**
- **Append-only:** No UPDATE or DELETE on audit_log ever. Not even admins.
- **Separate storage:** Audit logs should be in a separate database from operational data, with stricter access controls. Ideally write-only for the application.
- **Tamper-evident:** For high-assurance scenarios, use cryptographic chaining (each log entry includes a hash of the previous entry — any modification breaks the chain). This is similar to how a blockchain works.

> **What interviewers ask:** "How would you ensure only authorized staff can access patient records, and how would you prove who accessed what?"
> Model answer: "RBAC at the API layer — no request touches patient data without going through an authorization check. Every access, including successful reads, is written to an append-only audit log in a separate database with its own write-only credentials. The log captures actor, resource, and timestamp. Audit logs are retained for at least 6 years and reviewed by compliance teams. Alerts fire if a user accesses an unusually high number of records in a short time."

---

### 13.4 Role-Based Access Control (RBAC) — Schema Design

**RBAC:** Permissions are assigned to roles, not directly to users. Users are assigned roles.

```
User → has many → Roles → have many → Permissions → on Resources
```

**Schema:**

```sql
CREATE TABLE roles (
  id   UUID PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE  -- 'clinician', 'care_coordinator', 'billing_staff', 'admin'
);

CREATE TABLE permissions (
  id             UUID PRIMARY KEY,
  resource_type  VARCHAR(100) NOT NULL,  -- 'PatientRecord', 'Appointment', 'BillingInfo'
  action         VARCHAR(50)  NOT NULL,  -- 'read', 'write', 'delete', 'export'
  UNIQUE (resource_type, action)
);

CREATE TABLE role_permissions (
  role_id       UUID REFERENCES roles(id),
  permission_id UUID REFERENCES permissions(id),
  PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE user_roles (
  user_id UUID REFERENCES users(id),
  role_id UUID REFERENCES roles(id),
  PRIMARY KEY (user_id, role_id)
);
```

**Authorization check (pseudocode):**

```
function canAccess(userId, resourceType, action):
  userRoles = query user_roles WHERE user_id = userId
  for each role in userRoles:
    permission = query role_permissions
                 JOIN permissions
                 WHERE role_id = role.id
                   AND resource_type = resourceType
                   AND action = action
    if permission exists: return ALLOW
  return DENY
```

**Fine-grained control — attribute-based access:** RBAC alone is sometimes insufficient. A clinician should be able to read *their own patients'* records, but not any patient's record. This is **ABAC (Attribute-Based Access Control)** — "allow read if `record.assigned_clinician_id == requesting_user.id`." ABAC is more expressive but harder to reason about. A common approach: use RBAC for coarse control, ABAC for the fine-grained row-level check.

#### 13.4.1 OAuth2 Grant Types and OIDC

> **Interview relevance: Differentiator.** When the prompt involves "log in with Google" or third-party auth, knowing the grant-type cheat sheet (auth code + PKCE for mobile, client credentials for service-to-service) is a senior moment.

When an interviewer says "use OAuth" without specifying, candidates freeze because OAuth2 has multiple grant types. Knowing which one is the senior move.

```
THE OAUTH2 GRANT TYPES — WHEN TO USE WHICH:

  AUTHORIZATION CODE:
    Used by: web apps, mobile apps (the standard for "log in with Google")
    Flow: user → login at provider (Google, Auth0) → provider returns
          a one-time code → app exchanges code for access token + refresh token
    ✓ Most secure. Tokens never touch the browser directly.
    ✓ Standard, supported by every major IdP.
    → Use for: any consumer-facing app with third-party login.

  AUTHORIZATION CODE + PKCE (Proof Key for Code Exchange):
    Same as above, but with an extra code-verifier challenge.
    ✓ Mandatory for mobile apps and SPAs since OAuth2.1.
    ✓ Prevents authorization code interception attacks.
    → Use for: mobile apps (always), single-page apps (always).

  CLIENT CREDENTIALS:
    Used by: service-to-service auth.
    Flow: a service authenticates with its own client_id + client_secret →
          gets an access token → calls another service.
    ✓ No human in the loop.
    → Use for: microservice A calling microservice B.

  REFRESH TOKEN:
    Used by: long-lived sessions.
    Flow: the access token (short-lived, 15-60 min) is paired with a
          refresh token (long-lived, days-weeks). When the access
          token expires, the app uses the refresh token to get a new
          one without the user logging in again.
    ✓ Better UX. ✓ Tokens can be revoked.
    → Use for: any app where the user shouldn't re-login frequently.

  IMPLICIT (DEPRECATED in OAuth 2.1):
    Used by: old SPAs that couldn't keep a client_secret.
    ✗ Tokens returned directly in the URL fragment.
    ✗ Vulnerable to token leakage. Removed from OAuth 2.1.
    → Don't use. Use authorization code + PKCE instead.

  PASSWORD (DEPRECATED):
    Used by: legacy first-party apps that had to ask for a username/password.
    ✗ App handles the user's password — never ideal.
    → Don't use for new systems.

OIDC (OPENID CONNECT):
  OAuth2 + identity.
  → The access token is for API authorization.
  → The id_token (a JWT) is for "who is the user".
  → Use when you need to know "who logged in", not just "is this
    request authorized".
```

> **Interview signal:** "For the mobile app, I'd use OAuth2 Authorization Code with PKCE. The user logs in at the IdP, the IdP returns a code, the app exchanges it for an access token (15 min) + refresh token (30 days). When the access token expires, the app uses the refresh token silently. Tokens are stored in the iOS Keychain or Android EncryptedSharedPreferences."

> **The Auth0/Keycloak/Cognito decision (cheat sheet):**

```
KEYCLOAK (self-hosted, open-source):
  ✓ Free. Full control. No per-user cost.
  ✓ Mature OIDC + SAML support.
  ✗ You run it. HA, patching, upgrades are your problem.
  → Use when: cost-sensitive, on-prem requirements, you have ops capacity.

COGNITO (AWS managed):
  ✓ Deep AWS integration (IAM, Lambda triggers, DynamoDB).
  ✓ Pay per MAU; cheap for small apps.
  ✗ AWS-only (vendor lock).
  ✗ Limited customization vs Auth0/Keycloak.
  → Use when: AWS-native stack, simple user pool, low ops appetite.

AUTH0 (SaaS):
  ✓ Best DX, best documentation, fastest to integrate.
  ✓ Strong social login + enterprise connections.
  ✗ Most expensive at scale (per-active-user pricing).
  → Use when: time-to-market matters, complex identity features needed.
```

#### 13.4.2 JWT vs Session — The Tradeoff

> **Interview relevance: Differentiator.** Not asked directly, but "how do you handle auth?" comes up often. Knowing the access/refresh split + revocation strategy is a top-of-band answer vs "use JWT."

JWTs are popular and over-used. Knowing when NOT to use them is senior.

```
SERVER-SIDE SESSION:
  - The server creates a session record (in Redis or DB).
  - The cookie holds only an opaque session ID.
  - Every request: look up the session by ID.
  - To "log out", delete the session record (or set an expiry).
  ✓ Instant revocation (delete the record).
  ✓ Server has full control (can change session data on the fly).
  ✓ The cookie is opaque — no info leak even if intercepted.
  ✗ One DB/Redis lookup per request.
  ✗ Sessions don't scale to stateless microservices without sticky LB.

JWT (JSON Web Token):
  - The token IS the user data, signed by the server.
  - The client stores the token (cookie or local storage).
  - Every request: verify the signature, read the user from the token.
  - To "log out", you can't easily invalidate (token is self-contained).
  ✓ Zero server-side lookup — scales perfectly across stateless services.
  ✓ Mobile-friendly (no cookie required; bearer token in Authorization header).
  ✗ Hard to revoke: until the token expires, anyone with it is "logged in".
  ✗ Can't change user data on the fly (would need to re-issue all tokens).
  ✗ Bigger payload (all the user data is in the token).
  ✗ Storage in localStorage is XSS-vulnerable.
```

**The hybrid pattern most production systems use:**

```
  Access token:  JWT, 15-minute expiry, sent in Authorization header.
  Refresh token: Opaque random string, 30-day expiry, stored in HttpOnly cookie.
  Revocation:    the server keeps a "revoked token" list (Redis) checked on every
                 request. Or: the refresh token is invalidated; the access token
                 expires within 15 minutes anyway.

  → Best of both: stateless verification, revocable refresh.
```

> **Interview trap:** "Use JWT" without specifying expiry, storage, and revocation is a junior answer. The senior answer names the access/refresh split, the storage location, and the revocation strategy.

---

### 13.5 Data Residency

**Data residency** means data about users in a specific country must be stored and processed within that country (or region) only.

**GDPR (EU):** Personal data of EU residents must not leave the EU without adequate protections. Most cloud providers offer EU-region deployments (AWS eu-west-1, GCP europe-west1).

**LGPD (Brazil):** Similar to GDPR, applies to data of Brazilian residents.

**HIPAA (US):** Governs Protected Health Information (PHI). Any system storing PHI must use HIPAA-compliant infrastructure (AWS, GCP, Azure all offer BAA — Business Associate Agreement — for HIPAA workloads).

**What this means architecturally:**

```
Multi-region deployment with data sovereignty:

  EU users → EU region (Frankfurt data center)
                ├── EU database (patient records stay in EU)
                ├── EU caches
                └── EU audit logs

  US users → US region (Virginia data center)
                ├── US database
                ├── US caches
                └── US audit logs

  Services that are region-agnostic (CDN, authentication):
    → can be global, but user data cannot be replicated cross-region without consent
```

This adds significant operational complexity — two separate database clusters, no simple global joins, cross-region queries require explicit data transfer agreements.

---

### 13.6 Data Minimization and Retention

**Data minimization:** Collect only what you need for the stated purpose. If your feature doesn't need someone's exact date of birth, store only birth year. Less data = smaller breach blast radius = simpler compliance.

**Data retention:** Data should not be kept indefinitely. Define retention policies:

```
Medical records:  7 years after last encounter (varies by jurisdiction)
Audit logs:       6 years minimum (HIPAA)
Session tokens:   24 hours
App crash reports: 90 days (after that, individual records have no value)
Payment info:     Do not store raw card numbers ever (PCI-DSS requirement)
                  Store tokenized reference from payment processor only
```

**Right to be forgotten (GDPR Article 17):** Users can request deletion of their data. In a system with event sourcing, this is particularly challenging — you can't delete events from the immutable log. Solutions:
- **Crypto-shredding:** Encrypt the user's events with a user-specific key stored in a key service. To "delete" the user, delete their key. The events remain in the log but are permanently unreadable.
- **Selective anonymization:** Replace PII fields in the log with `[DELETED]` tokens. The event structure remains, but the personal data is gone.

---

### 13.7 Protecting Sensitive Data at the Application Layer

**Never log sensitive data.** This is a common developer mistake.

```
// BAD — SSN and token in logs:
logger.info("User ${userId} requested with SSN ${ssn} and token ${authToken}")

// GOOD — log identifiers and types only:
logger.info("User ${userId} requested SSN verification")
```

**Tokenization:** Replace sensitive values with opaque tokens stored in a secure vault.

```
Real card number:  4111-1111-1111-1111
Token:             tok_abc123xyz

Application stores and uses only the token.
Payment processor maps token ↔ real card in their secure vault.
Even if your database is breached, attackers get tokens, not card numbers.
```

**PII (Personally Identifiable Information)** in analytics: When sending events to an analytics pipeline, strip or hash PII.

```
BAD analytics event:
{ "event": "appointment_booked", "user_email": "alice@example.com", "diagnosis": "anxiety" }

GOOD analytics event:
{ "event": "appointment_booked", "user_id_hash": "sha256(user_id + salt)", "specialty": "therapy" }
```

---

### 13.8 Module 13 — Quick Fire

| Question | Answer |
|----------|--------|
| Encryption in transit vs at rest? | In transit: TLS protects data moving over the network. At rest: disk encryption protects stored data |
| What is an audit log and why is it append-only? | Tamper-evident record of who accessed what when. Append-only prevents retroactive modification |
| RBAC vs ABAC? | RBAC: permissions tied to roles. ABAC: permissions depend on attributes (e.g., "only your own patients") |
| What is crypto-shredding? | Encrypt data with a per-user key; delete the key to make data permanently unreadable without deleting the records |
| What is data minimization? | Collect only the data necessary for the stated purpose |
| What is tokenization? | Replace sensitive values (card numbers, SSNs) with opaque tokens backed by a secure vault |
| What is a BAA? | Business Associate Agreement — contract required before a vendor can handle HIPAA-covered PHI |
| What does data residency mean? | Legal requirement that data about residents of a jurisdiction stays within that jurisdiction |

| Component | What it physically is | When to reach for it |
|-----------|----------------------|---------------------|
| Load Balancer | Proxy that distributes requests | Always, for any multi-server setup |
| Redis | In-memory key-value store | Caching, sessions, rate limiting, pub/sub, leaderboards |
| PostgreSQL | Relational DB with full ACID | Financial data, bookings, anything with complex relations |
| Cassandra | Wide-column distributed DB | Write-heavy, time-series, massive scale |
| Kafka | Durable distributed log | Event streaming, audit trail, decoupling services |
| S3 | Object storage with flat namespace | Media files, backups, static assets |
| CDN | Geographically distributed cache | Any static asset delivery |
| Elasticsearch | Inverted index search engine | Full-text search, log search |
| WebSocket | Persistent bidirectional TCP | Chat, real-time collaboration, live tracking |
| gRPC | Binary RPC over HTTP/2 | Internal service-to-service communication |
| Debezium | CDC connector that tails DB transaction log | Sync DB changes to Kafka without app changes |
| Prometheus + Grafana | Metrics collection + dashboarding | Monitoring SLIs in production |
| Jaeger / Zipkin | Distributed trace storage and UI | Diagnosing latency across service boundaries |
| AWS KMS / Vault | Encryption key management service | Storing encryption keys separate from encrypted data |
| OpenTelemetry | Vendor-neutral instrumentation SDK | Emitting metrics, logs, traces from any service |

---

## How to Practice

1. **Pick a system design from exercises.md.** Set a 45-minute timer.
2. **Say it out loud.** Don't write the answer — narrate the design as if explaining to an interviewer.
3. **Estimate first.** Before drawing anything, compute QPS and storage.
4. **Identify the hard problem.** Every system has one dominant challenge. Find it and go deep.
5. **End with trade-offs.** "If I had more time, I'd improve X because Y."

The interviewer is evaluating your thinking process, not your memorization. Saying "I'm not sure about the exact replication protocol Cassandra uses, but I know it supports tunable consistency — I'd set it to QUORUM for writes in this case" is better than silence.
