# System Design Interview — Complete Exercise Set

**5 Mock Interviews covering 80% of common system design patterns**

---

## How to Use These Exercises

### Option 1: Full Mock Simulation (Recommended)

1. **Pick an exercise** (start with #1 if new to system design)
2. **Set a timer** for the stated duration (45-90 min depending on difficulty)
3. **Read only the Problem Statement** at the top
4. **Design out loud** — talk through your thinking, draw diagrams, make decisions
5. **Compare your design** to the solution after you finish
6. **Note gaps** — what did you miss? What would you do differently?

### Option 2: Pattern Study

1. **Pick a pattern** you want to learn (caching, fan-out, concurrency, etc.)
2. **Find exercises** that focus on that pattern (see index below)
3. **Read the solution** and understand the trade-offs
4. **Practice explaining** the pattern out loud

### Option 3: Interview Cram (Day Before)

1. **Read the "Key Takeaways"** from each exercise
2. **Memorize the phrases** in "Phrases That Show Experience"
3. **Review the scorecards** — know what strong candidates do
4. **Skim the mock dialogues** — get a feel for the conversation flow

---

## Exercise Index

| # | Exercise | Difficulty | Duration | Core Patterns |
|---|----------|------------|----------|---------------|
| [1](./01-url-shortener-mock-interview.md) | URL Shortener | Easy | 45-60 min | Back-of-envelope, cache-aside, ID generation |
| [2](./02-rate-limiter-mock-interview.md) | Rate Limiter | Intermediate | 60-75 min | Token bucket, sliding window, Lua scripts |
| [3](./03-booking-system-mock-interview.md) | Booking System | Intermediate/Hard | 75-90 min | Concurrency control, Redis SETNX, hold patterns |
| [4](./04-news-feed-mock-interview.md) | News Feed | Hard | 75-90 min | Fan-out (push/pull/hybrid), hot keys, sharding |
| [5](./05-chat-system-mock-interview.md) | Chat System | Hard | 75-90 min | WebSockets, message ordering, presence, delivery guarantees |

---

## Pattern Cross-Reference

### Caching Patterns

| Pattern | Where It Appears | Key Insight |
|---------|-----------------|-------------|
| **Cache-Aside** | Exercises 1, 2, 3, 4 | Default choice — check cache, miss → DB → populate cache |
| **Write-Through** | Exercise 3 | Strong consistency — cache and DB update atomically |
| **TTL Expiry** | All exercises | Safety net — even if you forget to invalidate, data self-corrects |
| **Multi-Level Cache** | Exercises 4, 5 | L1 (memory) → L2 (Redis) → L3 (DB) for hot-key mitigation |

### Concurrency & Locking

| Pattern | Where It Appears | Key Insight |
|---------|-----------------|-------------|
| **Redis SETNX** | Exercises 2, 3 | Atomic lock acquisition — only one client succeeds |
| **Database Row Locking** | Exercise 3 | `SELECT FOR UPDATE` — hold lock until transaction completes |
| **Unique Constraints** | Exercises 1, 3 | Database-level guarantee — prevents duplicates at schema level |
| **Optimistic Locking** | Exercise 3 | Version numbers — detect conflicts, retry on failure |

### Fan-Out Strategies

| Pattern | Where It Appears | Key Insight |
|---------|-----------------|-------------|
| **Push (Write-Time)** | Exercises 3, 4, 5 | Pre-compute at write time — fast reads, slow writes for popular items |
| **Pull (Read-Time)** | Exercises 4, 5 | Compute on demand — slow reads, simple writes |
| **Hybrid** | Exercises 4, 5 | Threshold-based — push for normal, pull for celebrities/hot items |

### Scaling Strategies

| Pattern | Where It Appears | Key Insight |
|---------|-----------------|-------------|
| **Database Sharding** | Exercises 4, 5 | Partition by access pattern — author_id for posts, conversation_id for messages |
| **Redis Cluster** | All exercises | Shard by key hash — `hash(key) % NUM_SHARDS` |
| **Read Replicas** | Exercises 4, 5 | For hot keys — replicate popular data across multiple nodes |
| **CDN for Media** | Exercises 4, 5 | Offload static assets — images, videos, files go to edge |

### Message Delivery

| Pattern | Where It Appears | Key Insight |
|---------|-----------------|-------------|
| **At-Least-Once** | Exercise 5 | Better to duplicate than lose — client handles deduplication |
| **Sequence Numbers** | Exercise 5 | Per-conversation counters — enables client-side reordering |
| **Kafka Partitioning** | Exercise 5 | Key by conversation_id — FIFO order within partition |
| **Idempotency** | Exercise 5 | Client tracks received IDs — ignore duplicates |

---

## Interview Framework (Quick Reference)

Use this structure for **any** system design interview:

### Minute 0-1: Receive and Repeat

> "Got it. So the core requirement is: [repeat in your own words]. Before I start designing, I'd like to ask a few clarifying questions — is that okay?"

### Minute 1-5: Requirements Gathering

Ask these 6 questions:

1. "What's the scale — how many daily active users?"
2. "What's the main action users take, and how often?"
3. "Can two users conflict on the same resource?"
4. "Does data need to be immediately consistent, or eventually consistent?"
5. "Are there media files involved — images, video, documents?"
6. "Is this regional or global?"

Write on canvas:

```
┌─────────────────────────────────────────┐
│  REQUIREMENTS                           │
├─────────────────────────────────────────┤
│  FUNCTIONAL:                            │
│  • [what it does]                       │
│                                         │
│  NON-FUNCTIONAL:                        │
│  • [scale, consistency, uptime, latency]│
└─────────────────────────────────────────┘
```

### Minute 5-10: Estimation

**Formula:**

```
QPS = (Daily Users × Actions Per User) ÷ 100,000
```

**Say this:**

> "Let me estimate the scale. With [X] users, if [Y]% are active daily and each does [Z] actions, that's [QPS] requests per second. This tells me [single server / caching needed / sharding required]."

### Minute 10-20: High-Level Design

Draw the spine:

```
┌─────────────┐    ┌──────────────┐    ┌──────────────┐
│   Client    │───►│  Load        │───►│   Service    │
│             │◄───│  Balancer    │◄───│   Layer      │
└─────────────┘    └──────────────┘    └──────────────┘
                                              │
                                      ┌───────┴────────┐
                                      │                │
                               ┌──────▼─────┐  ┌──────▼─────┐
                               │  Database  │  │   Cache    │
                               └────────────┘  └────────────┘
```

### Minute 20-38: Deep Dive

Pick the hardest problem:

> "The most interesting part of this design is [concurrency / fan-out / consistency / scaling]. Can I go deep there?"

Walk through:
1. The problem (draw the race condition, bottleneck, etc.)
2. The solution (pattern choice, why it works)
3. The trade-off (what you're accepting, fallback plan)

### Minute 38-45: Wrap-Up

> "If I had more time, the thing I'd most want to improve is [specific enhancement]. The trade-off is [complexity/cost], but it would give us [benefit]."

---

## Memorize These Anchors

### The Three Numbers

| Number | Meaning |
|--------|---------|
| **100,000** | Seconds per day (rounded) — use for QPS estimation |
| **100x** | Cache vs DB latency (0.1ms vs 10ms) |
| **10:1** | Typical read-to-write ratio for content systems |

### Caching Patterns (When to Use Each)

| Pattern | Use When... | Trade-off |
|---------|-------------|-----------|
| **Cache-Aside** | Default choice (80% of cases) | Brief window of staleness |
| **Write-Through** | Need cache + DB to always match | Slower writes |
| **TTL** | Want simplicity, can tolerate staleness | Data may be stale up to TTL duration |

### Concurrency Solutions

| Problem | Solution | Key Operation |
|---------|----------|---------------|
| Two users booking same slot | Redis SETNX | `SETNX slot:hold user_id` |
| Double-spend / double-book | Database unique constraint | `INSERT ... ON CONFLICT DO NOTHING` |
| Read-modify-write race | `SELECT FOR UPDATE` | Lock row until transaction completes |

### Fan-Out Decision Tree

```
Is the write fan-out > 10,000?
  │
  ├─ No → Push model (pre-compute at write time)
  │
  └─ Yes → Is the item "celebrity" content?
            │
            ├─ Yes → Pull model (fetch at read time)
            │
            └─ Yes for some, No for others → Hybrid (threshold-based)
```

### Failure Handling (What to Say)

| Failure | Response |
|---------|----------|
| "What if Redis goes down?" | "Fall back to database reads. Slower but functional." |
| "What if the database goes down?" | "Reads served from cache (stale). Writes queued in Kafka for replay." |
| "What if a server crashes?" | "Clients reconnect with exponential backoff. Session store routes to new server." |
| "How do you handle overload?" | "Circuit breaker + rate limiting. Better to reject 10% than crash 100%." |

---

## What Interviewers Score

### Strong Signals ✅

- **Estimates first:** "Let me calculate the scale..." before designing
- **Names trade-offs:** "I'm choosing X because Y, accepting Z as the downside"
- **Handles pushbacks:** "Good question — here's how I'd handle that edge case"
- **Graceful degradation:** "If X fails, we fall back to Y — slower but works"
- **Clear narration:** Talks while drawing, explains decisions as they make them

### Red Flags ❌

- **No estimation:** Jumps into design without understanding scale
- **No trade-offs:** "This is the best solution" — without acknowledging downsides
- **Brittle design:** "If Redis is down, the feature doesn't work"
- **Over-engineering:** Adds Kafka/Kubernetes before proving the need
- **Vague answers:** "We'd shard the database" — without explaining how or why

---

## Practice Plan (1 Week Before Interview)

| Day | Focus |
|-----|-------|
| **Day 1** | Exercise 1 (URL Shortener) — warm-up, get comfortable with framework |
| **Day 2** | Exercise 2 (Rate Limiter) — practice algorithms + distributed systems |
| **Day 3** | Exercise 3 (Booking System) — deep dive on concurrency control |
| **Day 4** | Exercise 4 (News Feed) — practice fan-out + scaling reads |
| **Day 5** | Exercise 5 (Chat System) — practice WebSockets + real-time patterns |
| **Day 6** | Re-do weakest exercise — full mock, timed, out loud |
| **Day 7** | Review key takeaways + memorize interview scripts |

---

## Practice Plan (Day Before Interview)

| Time | Activity |
|------|----------|
| **Morning** | Read "Key Takeaways" from all 5 exercises |
| **Afternoon** | Review "Phrases That Show Experience" — memorize 2-3 per pattern |
| **Evening** | Skim the mock dialogues — get a feel for conversation flow |
| **Night Before** | Rest — don't cram. Trust your preparation. |

---

## Final Checklist (Before Interview)

- [ ] **First sentence memorized:** "Before I start designing, I'd like to ask a few clarifying questions..."
- [ ] **QPS formula:** (DAU × actions) ÷ 100,000
- [ ] **Cache patterns named:** Cache-aside, Write-through, TTL
- [ ] **Concurrency solutions:** SETNX, SELECT FOR UPDATE, unique constraints
- [ ] **Fan-out strategies:** Push, Pull, Hybrid — know when to use each
- [ ] **Failure language ready:** "We'd fall back to...", "Graceful degradation means..."
- [ ] **Wrap-up script ready:** "If I had more time, I'd improve..."

---

**Good luck. You've got this.**
