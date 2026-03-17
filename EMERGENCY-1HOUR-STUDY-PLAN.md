# Emergency 1-Hour System Design Study Plan

> **Interview in 1 hour.** You've studied Modules 3, 4, 5 (databases, caching, APIs). This plan focuses on the **20% that appears in 80% of interviews**.

---

## Time Allocation

| Time | Topic | Priority |
|------|-------|----------|
| 0-10 min | Back-of-Envelope Estimation | HIGH |
| 10-25 min | Caching Patterns (you studied this) | CRITICAL |
| 25-35 min | Database Concurrency & Locking | CRITICAL |
| 35-45 min | Pick 1 Practice Problem & Walk Through | HIGH |
| 45-55 min | Final Review & Mental Checklist | MEDIUM |
| 55-60 min | The Interview Framework | CRITICAL |

---

## 0-10 min: Back-of-Envelope Estimation (MUST KNOW)

### Numbers to Memorize

```
1 day = 86,400 seconds ≈ 100,000 seconds (for estimation)

1 KB  = a text message
1 MB  = a photo
1 GB  = a movie

RAM read:      ~0.1 ms  (very fast)
Database read: ~10 ms   (100x slower than RAM - THIS IS WHY CACHING EXISTS)
```

### The Four-Step Formula

```
Step 1: DAU (Daily Active Users)
Step 2: Actions per user per day
Step 3: QPS = (DAU × actions per user) / 100,000
Step 4: Storage = writes per day × size per item
```

### What QPS Tells You

```
< 100 QPS:      Single server is fine
100–1,000 QPS:  Need multiple servers
1,000–10,000 QPS: Need caching, load balancing
> 10,000 QPS:   Serious distributed architecture
```

### Example: Appointment Booking

```
50,000 bookings/day ÷ 100,000 seconds ≈ 0.5 writes/second (LOW)

But availability checks (reads) might be 20x bookings → ~10 reads/second

→ Low volume, but caching still matters because:
  - Multiple users read the same therapist calendar simultaneously
  - Cache the SCHEDULE, not the booking
```

---

## 10-25 min: Caching Patterns (CRITICAL)

### The 3 Cache Strategies

Memorize these names and when to use each:

| Strategy | How It Works | When to Use |
|----------|--------------|-------------|
| **Cache-Aside** | Read: check cache → miss → read DB → populate cache. Write: invalidate cache. | Most common. Simple, resilient. |
| **Write-Through** | Write to both cache and DB atomically. | When you need always-fresh data. |
| **Time-Based (TTL)** | Set expiry on all cache entries. Auto-refresh. | Simple, eventually consistent. |

### Redis Key Design Pattern

```
# Slot availability for provider on date
Key: slots:{provider_id}:{date}
Value: JSON array of slot statuses
TTL: 1 hour (refreshed on changes)

# Active hold (with auto-expiry)
Key: hold:{hold_id}
Value: {"slot_id": "s1", "user_id": "u123"}
TTL: 300 seconds (5 min) → AUTO-DELETES

# What this solves:
# - TTL handles expiration automatically (no cron job needed)
# - When hold expires, slot becomes available again
```

### Cache Invalidation = The Hard Part

```
On Booking Confirm:
  1. INSERT booking to DB (transaction)
  2. DEL hold:{hold_id}
  3. DEL slot_hold:{slot_id}
  4. UPDATE slots:{provider_id}:{date} status to "booked"
  5. PUBLISH slot_booked:{slot_id} event (notify WebSocket clients)
```

### Why Caching Appears Everywhere

> "A database read is ~100x slower than an in-memory read."

When you say "we should cache this," you're saying:
- Reads are 100x faster
- Database load is reduced
- But: you accept eventual consistency (stale data for X seconds)

---

## 25-35 min: Concurrency & Locking (CRITICAL)

### The Race Condition Problem

```
Time    User A                          User B
 │       ┌─ Check slot: "available"
 │       │
 │       │                              ┌─ Check slot: "available" ⚠️
 │       │                              │
 │       ▼                              ▼
 │       ┌─ Try to hold                 ┌─ Try to hold
 │       │  SUCCESS                     │  SUCCESS  ⚠️ DOUBLE BOOKING!
```

Both succeeded because both checked BEFORE either wrote.

### Solution 1: Redis SETNX (Recommended)

```
SETNX = SET if Not eXists (atomic operation)

Hold Logic:
  result = SETNX slot_hold:slot_001 "hold_abc123"

  if result == 1:
    # We got the lock! Set hold details with TTL
    SET hold:hold_abc123 '{"slot_id":"slot_001"}' EX 300
    EXPIRE slot_hold:slot_001 300
    return SUCCESS
  else:
    # Someone else got it first
    return FAIL (slot already held)
```

**Why it works:** SETNX is atomic. Only one request can succeed even at the exact same millisecond.

### Solution 2: Database Unique Constraint

```sql
-- Add unique constraint
ALTER TABLE appointment_slots
ADD CONSTRAINT unique_provider_start UNIQUE (provider_id, start_time);

-- Or separate locking table
CREATE TABLE slot_locks (
    slot_id     UUID PRIMARY KEY,  -- Primary key = unique
    held_by     UUID NOT NULL,
    held_until  TIMESTAMP NOT NULL
);

-- Hold attempt:
INSERT INTO slot_locks (slot_id, held_by, held_until)
VALUES ('slot_001', 'user_456', NOW() + INTERVAL '5 minutes')
ON CONFLICT (slot_id) DO NOTHING;

-- Check rows affected: > 0 means we got it
```

### The Hold Flow (End-to-End)

```
1. User clicks "Hold" → POST /slots/slot_001/hold
2. Server: SETNX slot_hold:slot_001 "hold_abc"
   → If fails: return 409 (already held)
   → If succeeds: continue
3. Server: SET hold:hold_abc '{"slot_id":"s1"}' EX 300
4. Return hold_id to client
5. Client completes payment within 5 min → booking confirmed
6. Server: DEL hold:hold_abc, UPDATE slot status to "booked"

OR (if user doesn't complete):
5. 5 minutes pass → Redis auto-deletes hold_abc (TTL)
6. Slot becomes available again automatically
```

---

## 35-45 min: Practice Problem Walkthrough

Pick ONE of these and walk through it out loud:

### Option A: URL Shortener (TinyURL)

**Requirements (1 min):**
- Shorten long URLs → short code (bit.ly/abc123)
- Redirect on visit
- Track click count

**Estimation (2 min):**
- 100M URLs created per month
- 10B redirects per month
- 100:1 read:write ratio

**High-Level Design (3 min):**
```
┌─────────────┐    ┌──────────────┐    ┌────────────────┐
│   Browser   │───►│  API Server  │───►│    Database    │
└─────────────┘    └──────┬───────┘    └────────────────┘
                          │
                   ┌──────┴────────┐
                   │               │
            ┌──────▼──────┐  ┌─────▼─────┐
            │    Redis    │  │  Analytics│
            │  (cache)    │  │  (async)  │
            └─────────────┘  └───────────┘
```

**Deep Dive (3 min):**
- Short code generation: auto-increment ID + base62 encode
- Database schema: `urls(id, short_code, long_url, click_count, created_at)`
- Redirect: 301 HTTP redirect + async click increment

### Option B: Rate Limiter

**Requirements (1 min):**
- Limit users to 100 requests/minute
- Return 429 when exceeded
- Work across multiple servers

**Deep Dive (5 min):**
```
Algorithm: Sliding Window with Redis

Key: rate_limit:{user_id}
Value: request_count
TTL: 60 seconds

Logic:
  count = Redis.get(key)
  if count == null:
    Redis.set(key, 1, EX=60)  # First request
    return OK
  elif count < 100:
    Redis.incr(key)
    return OK
  else:
    ttl = Redis.ttl(key)
    return 429 {retry_after: ttl}
```

### Option C: Booking System (You Already Know This)

Walk through the booking flow from your exercises. Focus on:
1. The hold mechanism with Redis TTL
2. SETNX for concurrency
3. Cache invalidation on booking

---

## 45-55 min: Final Mental Checklist

### Before You Say Anything

- [ ] Pause. Breathe.
- [ ] Repeat the prompt back
- [ ] Ask to clarify requirements first

### Requirements Gathering Checklist

- [ ] Scale (DAU, writes/day)
- [ ] Concurrency concerns (can two users conflict?)
- [ ] Consistency (eventual vs immediate)
- [ ] Special features (search, media, notifications)

### High-Level Design Checklist

- [ ] Client → API → Database spine
- [ ] Cache layer (Redis)
- [ ] Async components (queues, notifications)
- [ ] CDN/object storage if media involved

### Deep Dive Checklist

- [ ] State the problem clearly
- [ ] Propose a solution
- [ ] Acknowledge the trade-off

### Wrap-Up Checklist

- [ ] Critique your own design
- [ ] Name one thing you'd improve with more time
- [ ] Mention a trade-off you made

---

## Quick Reference: Component Cheat Sheet

| Component | When to Use | Example |
|-----------|-------------|---------|
| **Redis** | Caching, locks, rate limiting, sessions | Slot availability, hold expiration |
| **PostgreSQL** | Strong consistency, transactions | Bookings, payments, user data |
| **MongoDB/DynamoDB** | Flexible schema, high write scale | Activity logs, analytics |
| **Kafka/SQS** | Async processing, decoupling | Notifications, analytics pipelines |
| **CDN** | Static assets, global users | Images, videos, JS/CSS |
| **S3/GCS** | File storage | Uploaded documents, photos |
| **Elasticsearch** | Full-text search | Search providers, products |

---

## Common Interview Questions & How to Answer

### Q: "What if Redis goes down?"

**Good answer structure:**
1. Acknowledge: "If Redis goes down, we can't create holds or check cache."
2. Immediate mitigation: "Fall back to database reads and DB-level locking."
3. Long-term: "Redis Cluster with replication, automatic failover."
4. Trade-off: "We accept slower performance during outage, but system remains functional."

### Q: "How do you prevent abuse (users holding slots without booking)?"

- Max 3 active holds per user
- Track expired holds → temporary block for abusers
- Shorter hold time during peak (2 min vs 5 min)
- Require payment info upfront for high-no-show users

### Q: "How would you scale to 100x traffic (flash sale)?"

- Add cache layers (CDN + Redis cluster)
- Read replicas for database
- Queue booking requests (async processing)
- Rate limiting per user/IP
- Virtual waiting room for extreme spikes

---

## 55-60 min: The Interview Framework (CRITICAL)

### The 45-Minute Interview Map

Memorize this structure. It signals seniority more than knowing specific technologies.

```
┌─────────────────────────────────────────────────────────────────────┐
│  0–1 min   │ Receive prompt. Pause. Repeat it back.                 │
│  1–5 min   │ Ask clarifying questions. Write requirements.          │
│  5–10 min  │ Estimate scale out loud. Derive key conclusions.       │
│ 10–20 min  │ Draw the high-level design (shallow, all components).  │
│ 20–38 min  │ Deep dive into 2–3 hard components.                    │
│ 38–45 min  │ Acknowledge trade-offs. Say what you'd do next.        │
└─────────────────────────────────────────────────────────────────────┘
```

### First Sentence Out of Your Mouth

> "Before I start designing, I'd like to ask a few clarifying questions to make sure I'm solving the right problem — is that okay?"

### Questions That Change the Design

| Question | Why It Matters |
|----------|----------------|
| "How many daily active users?" | Single server → need load balancer |
| "How many writes per second?" | No cache → caching becomes critical |
| "Can two users conflict on the same resource?" | Need locks, optimistic locking |
| "Eventual consistency or immediate?" | NoSQL viable vs SQL with transactions |
| "Do we need full-text search?" | Adds Elasticsearch |
| "Global or regional?" | Multi-region, CDN, data laws |

### Requirements Template (Write These Down)

```
FUNCTIONAL (what it does):
- Users can search X by Y
- Users can view Z
- Users can book/create W (exclusive - no double-booking)
- Notifications on confirmation

NON-FUNCTIONAL (how well):
- X users, Y scale
- Strong consistency on critical step
- 99.9% uptime
- Sub-second response time
```

---

## Final Reminders

1. **Structure beats knowledge.** A candidate who follows the framework scores higher than one who knows more tech but jumps around.

2. **Narrate while you draw.** The interviewer can't read your mind. Say what you're drawing and why.

3. **Trade-offs signal seniority.** Every design choice has a downside. Acknowledge it.

4. **It's okay to not know.** Say "I'm not familiar with X specifically, but I'd approach it by..." and reason from first principles.

5. **You've studied the hard parts.** Caching, concurrency, database design — you know these. Trust your preparation.

---

**Good luck. You've got this.**
