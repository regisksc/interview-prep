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

### 1.8 Common Mistakes and How to Recover

| Mistake | How to recover |
|---------|---------------|
| You jumped into architecture without asking questions | Pause, say "Actually, let me back up — I want to make sure I have the requirements right before I go further" |
| You went silent for 30+ seconds | Say out loud: "I'm thinking through the trade-offs of X vs Y — give me just a moment" |
| You proposed a solution and the interviewer pushes back | Say "Fair point — let me reconsider. If Y is the constraint, then maybe X is a better fit because..." |
| You don't know a specific technology | "I'm not deeply familiar with [X] specifically, but I know it's a [type]. I'd approach it by [reasoning]..." |
| You ran out of things to say at minute 15 | Ask the interviewer: "Is there a particular component you'd like me to go deeper on?" |
| You forgot to mention a requirement mid-design | "Actually, I want to add something to the requirements I noted — we haven't talked about what happens when a therapist cancels. That would change the notification design." |

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

---

### 3.8 NoSQL Types — When to Use Each

**Document stores (MongoDB, Firestore):** Store JSON-like documents. Great when data is naturally hierarchical and you often read the whole document at once (e.g., a user profile with nested settings).

**Key-value stores (Redis, DynamoDB):** Lookup by key → get value. Extremely fast (Redis runs in-memory). Great for caching, sessions, leaderboards.

**Wide-column stores (Cassandra, HBase):** Like a spreadsheet with billions of rows and thousands of columns, but each row can have different columns. Designed for massive write throughput and time-series data. Used by Instagram for DMs and Uber for trips.

**Graph databases (Neo4j):** Entities are nodes, relationships are edges. Great for social graphs, recommendation engines, fraud detection (finding connected accounts).

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

---

### 5.5 Module 5 — Quick Fire

| Question | Answer |
|----------|--------|
| What is idempotency? | An operation that produces the same result no matter how many times it's called |
| Which HTTP methods are idempotent? | GET, PUT, DELETE. POST is NOT |
| Cursor vs offset pagination — key difference? | Cursor is stable (new inserts don't shift pages). Offset is not. Cursor is also O(1) seek |
| WebSocket vs SSE? | WebSocket is bidirectional. SSE is server→client only but simpler |
| gRPC vs REST? | gRPC uses binary protobuf + HTTP/2, faster for internal services. REST is JSON + HTTP/1.1, better for public APIs |
| Token bucket vs leaky bucket? | Token bucket allows bursts (up to capacity). Leaky bucket smooths all traffic to a constant rate |

---

## Module 6: Scalability Patterns

> **Priority: HIGH.** Every "how would you scale this?" question lives here.

### 6.1 Load Balancing Strategies

A **load balancer** distributes incoming requests across multiple server instances.

**Round Robin:** Send request 1 to Server 1, request 2 to Server 2, request 3 to Server 3, then back to Server 1. Simple, works when servers are identical.

**Least Connections:** Send the next request to whichever server has the fewest active connections. Better when requests have variable processing time.

**Consistent Hashing:** Route requests for the same resource (e.g., same user_id) to the same server. Critical for stateful operations where server-local state (connection pools, caches) must be reused.

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

**Vertical scaling (scale up):** Buy a bigger server. 4 CPU → 32 CPU, 32 GB → 512 GB RAM. Simple but has a ceiling — the largest available machine — and creates a single point of failure.

**Horizontal scaling (scale out):** Add more servers. 1 server → 10 servers → 100 servers. Requires your service to be stateless. Much higher ceiling and no single point of failure.

In practice: vertical scaling is the first move (simple), horizontal scaling is the endgame (resilient).

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

---

### 6.5 Consistent Hashing (Revisited in Context)

Already covered in Module 3.6 for sharding. Consistent hashing also applies to load balancing (route same user to same cache node) and CDN edge selection. Knowing where it applies is the senior signal.

---

### 6.6 Module 6 — Quick Fire

| Question | Answer |
|----------|--------|
| Why must horizontal scaling require stateless services? | Any server must be able to handle any request, so state can't live on a single server |
| CAP theorem — what's the P? | Partition tolerance — the system continues operating when network partitions occur |
| Can you have CA without P? | In theory yes, but in real distributed systems, partitions happen — so you must choose CP or AP |
| Round Robin vs Least Connections? | Round Robin for uniform servers/requests. Least Connections when request processing time varies |
| What does BASE stand for? | Basically Available, Soft state, Eventually consistent |

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

---

### 12.4 Module 12 — Quick Fire

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
