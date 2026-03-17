# System Design Interview — Emergency 1-Hour Cram Guide

> **For:** Senior Mobile Engineer who knows Modules 3, 4, 5 (databases, caching, APIs)
> **Goal:** Stick to your brain under pressure. Every concept explained with *why*, not just *what*.
> **Read time:** 20 minutes. Practice time: 40 minutes.

---

## Part 1: The 3 Numbers That Drive Every Decision (10 min)

### The Magic Number: 100,000

**Memorize this:** 1 day ≈ 100,000 seconds (actually 86,400, but we round for easy math)

**Why this matters:** Every interview question about scale boils down to: "How many requests per second?"

**The Formula (say this out loud in the interview):**

```
QPS = (Daily Users × Actions Per User) ÷ 100,000
```

**Real Example — Appointment Booking:**

> **Interviewer:** "How would you scale this?"
>
> **You:** "Let me estimate the scale first. You mentioned 500,000 patients. If 10% book per day, that's 50,000 bookings. Spread across 100,000 seconds, that's 0.5 bookings per second. But availability checks — those are reads — might be 20x higher, so ~10 QPS for reads."
>
> **What this tells you:** 10 QPS is NOTHING. A single server handles hundreds of QPS easily. So you're not designing for scale — you're designing for **concurrency** (two people booking the same slot) and **data integrity** (no double-bookings).

### The Three QPS Thresholds

| QPS Range | What It Means | Architecture Implication |
|-----------|---------------|--------------------------|
| **< 100** | Small problem | Single server, one database. Focus on correctness, not scale. |
| **100 – 10,000** | Medium problem | Multiple servers, caching layer, read replicas. |
| **> 10,000** | Large problem | Sharding, multiple data centers, serious distributed systems. |

**Key insight:** Most interview problems are in the 100-10,000 range. That means **caching** and **load balancing** are almost always part of the answer.

### Latency Numbers That Explain Why Caching Exists

**Memorize this comparison:**

```
Reading from RAM (cache):      0.1 milliseconds
Reading from database:        10 milliseconds

A cache hit is 100x faster than a database query.
```

**Say this in the interview:**

> "I'm adding a Redis cache layer because availability checks are read-heavy and latency-sensitive. A cache hit is 100x faster than a database query — 0.1ms vs 10ms. For a booking flow where users are actively selecting slots, that responsiveness matters."

**The trade-off you're accepting:**

> "The trade-off is eventual consistency. The cache might be 5 seconds stale. For appointment availability, that's acceptable — users expect some delay. For the actual booking step, I'll bypass cache and go direct to database with locking."

---

## Part 2: Caching — The Actual Patterns (20 min)

### Pattern 1: Cache-Aside (Lazy Loading)

**When to use:** Default choice. 80% of caching scenarios.

**How it works:**

```
READ OPERATION:
  1. Check cache: GET slots:prov_123:2026-03-15
  2. If found (cache hit): Return cached data
  3. If not found (cache miss):
     a. Query database: SELECT * FROM slots WHERE provider_id = ? AND date = ?
     b. Store in cache: SET slots:prov_123:2026-03-15 [result] EX 3600
     c. Return data

WRITE OPERATION:
  1. Write to database: UPDATE slots SET status = 'booked' WHERE id = ?
  2. Invalidate cache: DEL slots:prov_123:2026-03-15
  3. Next read will repopulate cache from database
```

**Say this in the interview:**

> "I'm using cache-aside pattern for slot availability. On reads, we check cache first, then fall back to database and populate cache on miss. On writes — like when a slot is booked — we invalidate the cache. The next read will repopulate it. This is simple and resilient: if cache fails, we gracefully degrade to database reads."

**The trade-off (say this!):**

> "The downside is there's a brief window where cache is stale — between the database write and the cache invalidation. For appointments, a few seconds of staleness is acceptable. If we needed stronger consistency, we'd use write-through instead."

---

### Pattern 2: Write-Through

**When to use:** When you need cache and database to always match.

**How it works:**

```
WRITE OPERATION:
  1. Application writes to cache: SET slots:prov_123:2026-03-15 [updated_data]
  2. Cache synchronously writes to database
  3. Both succeed or both fail (atomic)

READ OPERATION:
  1. Always hits cache first
  2. Cache is always consistent with database
```

**Say this in the interview:**

> "For the actual booking confirmation — not just availability checks, but the confirmed slot — I'd use write-through. When a booking is confirmed, we write to both cache and database atomically. This ensures the cache never shows a slot as available when it's actually booked. The trade-off is write latency increases, but for bookings, correctness matters more than speed."

---

### Pattern 3: Time-Based (TTL)

**When to use:** When you can tolerate staleness and want simplicity.

**How it works:**

```
Every cache entry has an expiration time:

SET slots:prov_123:2026-03-15 [data] EX 3600

After 3600 seconds (1 hour), Redis auto-deletes the key.
Next read repopulates from database.
```

**Say this in the interview:**

> "I'm setting a 1-hour TTL on availability cache. This is a safety net — even if we forget to invalidate cache somewhere, it'll self-correct within an hour. For a booking system, I'd use a shorter TTL during peak hours (5 minutes) and longer during off-peak (1 hour)."

---

### Redis Key Design — The Actual Structure

**Don't just say "Redis." Name the keys:**

```
# Pattern: resource:id:context
slots:{provider_id}:{date}           → Array of slot statuses for one day
hold:{hold_id}                       → Active hold with 5-min TTL
slot_hold:{slot_id}                  → Which hold owns this slot
search:providers:{specialty}:{city}  → Search results cache
provider:{id}:rating                 → Provider rating (changes rarely)
```

**Why this structure:**

> "I'm using colon-separated keys with the resource type first. This makes it easy to debug in Redis CLI — I can run `KEYS slots:*` to see all slot caches. The `{provider_id}:{date}` structure means I can invalidate all slots for a provider on a date with one pattern match."

---

## Part 3: Concurrency — Preventing Double-Bookings (20 min)

### The Problem (Draw This)

**Say this while drawing:**

> "Let me show you the race condition I need to handle. Two users, Alice and Bob, both view Dr. Smith's 3 PM slot at the same time..."

```
Time →

Alice                           Bob
  │                              │
  │  Check availability          │
  │  → "3 PM is available"       │
  │                              │
  │                              │  Check availability
  │                              │  → "3 PM is available"  ⚠️
  │                              │
  │  Click "Book"                │
  │  → Creates booking           │
  │                              │
  │                              │  Click "Book"
  │                              │  → Creates booking  ⚠️ DOUBLE-BOOKED!
```

**Explain why it happens:**

> "Both requests read 'available' before either wrote the booking. This is a classic read-modify-write race condition. The fix is to make the 'check and book' operation atomic — only one request can succeed."

---

### Solution 1: Redis SETNX (Recommended for Holds)

**What SETNX means:** "SET if Not eXists" — atomic operation that only succeeds if the key doesn't exist.

**The actual code (pseudo-code you can say out loud):**

```python
def hold_slot(slot_id, user_id, hold_id):
    # Try to claim the slot
    result = redis.setnx(f"slot_hold:{slot_id}", hold_id)

    if result == 1:
        # We got the lock! Set hold details with 5-minute TTL
        redis.set(f"hold:{hold_id}",
                  json.dumps({"slot_id": slot_id, "user_id": user_id}),
                  ex=300)  # 300 seconds = 5 minutes
        redis.expire(f"slot_hold:{slot_id}", 300)
        return {"success": True, "hold_id": hold_id}
    else:
        # Someone else got it first
        return {"success": False, "error": "Slot already held"}
```

**Say this in the interview:**

> "I'm using Redis SETNX for the hold operation. SETNX is atomic — it only succeeds if the key doesn't exist. So even if two requests arrive at the exact same millisecond, only one will succeed. The other gets a 'slot already held' error. I also set a 5-minute TTL, so if the user doesn't complete the booking, the hold auto-expires and the slot becomes available again."

**Why this is better than database locking:**

> "Database locking would work, but it's slower — we're holding a database transaction open for 5 minutes. With Redis, the hold is in-memory and auto-expires. We only touch the database when the booking is confirmed."

---

### Solution 2: Database Unique Constraint (Fallback)

**When to use:** If Redis is down, or for ultimate correctness.

**The SQL:**

```sql
-- Option A: Unique constraint on the slot itself
ALTER TABLE appointment_slots
ADD CONSTRAINT unique_provider_start UNIQUE (provider_id, start_time);

-- This prevents two rows with same provider+time from existing.
-- But it doesn't help with "holding" — only with final booking.

-- Option B: Separate locking table
CREATE TABLE slot_locks (
    slot_id     UUID PRIMARY KEY,  -- PRIMARY KEY = must be unique
    held_by     UUID NOT NULL,
    held_until  TIMESTAMP NOT NULL
);

-- Hold attempt:
INSERT INTO slot_locks (slot_id, held_by, held_until)
VALUES ('slot_001', 'user_456', NOW() + INTERVAL '5 minutes')
ON CONFLICT (slot_id) DO NOTHING;

-- Check if insert succeeded (rows_affected > 0 means we got it)
```

**Say this in the interview:**

> "As a fallback if Redis is unavailable, I'd use database-level locking with a unique constraint. The INSERT...ON CONFLICT pattern means only one hold can exist per slot. It's slower than Redis but guarantees correctness. I'd design the system to prefer Redis but degrade to database locking if needed."

---

### The Complete Hold Flow (Walk Through This Aloud)

**Practice saying this step-by-step:**

```
SCENARIO: User books an appointment with a 5-minute hold

Step 1: User clicks "Hold this slot"
  → Client: POST /api/slots/slot_001/hold
  → Server: Redis SETNX slot_hold:slot_001 "hold_abc123"
  → Result: Success (key didn't exist, we created it)

Step 2: Server creates hold record
  → Redis: SET hold:hold_abc123 {"slot": "slot_001", "user": "u456"} EX 300
  → Response: {"hold_id": "hold_abc123", "expires_at": "2026-03-17T13:35:00Z"}

Step 3: User enters payment details (within 5 minutes)
  → Client: POST /api/bookings {hold_id: "hold_abc123", payment: "..."}
  → Server: Verify hold exists (GET hold:hold_abc123)
  → Server: If missing → return 409 "Hold expired"
  → Server: If exists → continue

Step 4: Create booking in database
  → BEGIN TRANSACTION
  → INSERT INTO bookings (slot_id, user_id, status) VALUES (...)
  → UPDATE appointment_slots SET status='booked' WHERE id='slot_001'
  → COMMIT

Step 5: Update cache
  → Redis: DEL hold:hold_abc123
  → Redis: DEL slot_hold:slot_001
  → Redis: SET slots:prov_123:2026-03-15 [updated with slot_001=booked]
  → Redis: PUBLISH slot_booked:slot_001 "booked"  (WebSocket notification)

Step 6: Confirm to user
  → Response: {"booking_id": "bk_789", "status": "confirmed"}
```

**If user doesn't complete (timeout flow):**

```
Step 3 (alternative): User takes too long (> 5 minutes)
  → Redis auto-deletes hold:hold_abc123 (TTL expired)
  → Redis auto-deletes slot_hold:slot_001 (TTL expired)
  → Slot is now available again

Optional: Use Redis Keyspace Notifications
  → Subscribe to __keyevent@0__:expired
  → When hold_abc123 expires, receive event
  → Worker: Update slot status back to 'available'
  → Worker: PUBLISH slot_available:slot_001
  → WebSocket server notifies waiting users
```

---

## Part 4: The Interview Framework — Your Script (10 min)

### Minute 0-1: Receive and Repeat

**First thing you say (memorize this exact script):**

> "Got it. So the core requirement is: [repeat prompt in your own words]. Before I start designing, I'd like to ask a few clarifying questions to make sure I'm solving the right problem — is that okay?"

**Why this works:** Shows you listen, you think before acting, and you respect the interviewer's input.

---

### Minute 1-5: Requirements Gathering

**The 6 Questions That Matter (ask these in order):**

| # | Question | What You're Learning |
|---|----------|---------------------|
| 1 | "What's the scale — how many daily active users?" | Single server vs load balancer |
| 2 | "What's the main action users take, and how often?" | Read vs write ratio |
| 3 | "Can two users conflict on the same resource?" | Need concurrency control |
| 4 | "Does data need to be immediately consistent, or eventually consistent?" | SQL vs NoSQL, caching strategy |
| 5 | "Are there media files involved — images, video, documents?" | Object storage + CDN |
| 6 | "Is this regional or global?" | Multi-region, data residency |

**Write this on your canvas as you ask:**

```
┌─────────────────────────────────────────┐
│  REQUIREMENTS                           │
├─────────────────────────────────────────┤
│  FUNCTIONAL (what it does):             │
│  • Users can search X by Y              │
│  • Users can view Z                     │
│  • Users can book/create W (exclusive!) │
│  • Notifications on confirmation        │
│                                         │
│  NON-FUNCTIONAL (how well):             │
│  • 500K users, 50K actions/day          │
│  • Strong consistency on booking        │
│  • 99.9% uptime                         │
│  • < 200ms response for availability    │
└─────────────────────────────────────────┘
```

---

### Minute 5-10: Estimation

**Say this out loud (script):**

> "Let me estimate the scale. With 500,000 users, if 10% are active daily, that's 50,000 DAU. If each user checks availability 10 times but only books once, that's 500,000 reads and 50,000 writes per day. Divided by 100,000 seconds, that's 5 QPS for reads and 0.5 QPS for writes. This is low volume — a single server handles it easily. The complexity isn't scale, it's concurrency: two users trying to book the same slot."

---

### Minute 10-20: High-Level Design

**Draw this spine first (always starts the same):**

```
┌─────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│   Mobile App    │────►│    API Server    │────►│    Database      │
│  (Patient/Prov) │◄────│   (Node/Go/Py)   │◄────│   (PostgreSQL)   │
└─────────────────┘     └────────┬─────────┘     └──────────────────┘
                                 │
                        ┌────────┴────────┐
                        │                 │
                 ┌──────▼──────┐   ┌──────▼──────┐
                 │    Redis    │   │ Notification│
                 │  (cache +   │   │   Service   │
                 │    locks)   │   │             │
                 └─────────────┘   └─────────────┘
```

**Narrate while drawing (script):**

> "I'm starting with the basic spine: mobile app, API server, database. The app talks to the API, the API talks to PostgreSQL for persistence. Now, for slot availability — that's read-heavy and latency-sensitive — I'm adding Redis as a cache. Redis also handles the hold mechanism with atomic SETNX operations. Finally, notifications — confirmations, reminders — I'll put those on a separate service so they don't block the booking flow."

---

### Minute 20-38: Deep Dive

**Pick the hardest problem and go deep:**

> "The most interesting part of this design is the concurrency problem — preventing double-bookings. Can I go deep there?"

**Then walk through:**

1. **The problem:** "Two users viewing the same slot at the same time..."
2. **The solution:** "Redis SETNX for atomic hold acquisition..."
3. **The trade-off:** "If Redis goes down, we fall back to database locking — slower but correct."

---

### Minute 38-45: Wrap-Up

**Say this (script):**

> "If I had more time, the thing I'd most want to improve is notification reliability. Right now, if the notification service crashes mid-booking, the user might not get a confirmation even though the booking succeeded. I'd add a message queue — Kafka or SQS — between booking and notification. That way, notifications are guaranteed to eventually deliver even if the service is temporarily down. The trade-off is increased complexity: we'd need to handle duplicate notifications and build a dead-letter queue for failed deliveries."

---

## Part 5: Practice Problem — URL Shortener (10 min)

**Walk through this out loud, using the framework:**

### Requirements (1 min)

> "Functional: shorten URLs, redirect on visit, track clicks. Non-functional: high availability (redirects must work even if shortener is down), low latency (< 50ms for redirects), 100:1 read:write ratio."

### Estimation (2 min)

> "100M URLs created per month, 10B redirects per month. That's ~40 writes/sec and ~4,000 reads/sec. The reads need caching; the writes are low volume."

### High-Level Design (3 min)

```
┌─────────────┐    ┌──────────────┐    ┌────────────────┐
│   Browser   │───►│  API Server  │───►│    Database    │
└─────────────┘    └──────┬───────┘    └────────────────┘
                          │
                   ┌──────┴────────┐
                   │               │
            ┌──────▼──────┐  ┌─────▼─────┐
            │    Redis    │  │  Analytics│
            │  (redirect  │  │  (async   │
            │   cache)    │  │   clicks) │
            └─────────────┘  └───────────┘
```

### Deep Dive (4 min)

> "The interesting problem is short code generation. Three options:
>
> 1. **Hash the URL (MD5 → first 6 chars):** Deterministic — same URL = same code. But collisions possible.
> 2. **Auto-increment ID + base62:** ID=1 → 'a', ID=62 → '10', ID=1000 → 'g8'. Guaranteed unique, but predictable.
> 3. **Random string with uniqueness check:** Generate random 6-char string, check if exists, retry if collision. Unpredictable, but may need multiple attempts.
>
> I'd go with option 2 — auto-increment + base62. It's simple, guaranteed unique, and the predictability doesn't matter for this use case. The database schema is straightforward: `urls(id, short_code, long_url, click_count, created_at)`."

---

## Quick Reference: What to Say When

| When interviewer asks... | Say this... |
|--------------------------|-------------|
| "How would you scale this?" | "Let me estimate the QPS first..." |
| "What if Redis goes down?" | "We'd fall back to database reads and DB-level locking. Slower but functional." |
| "How do you prevent X?" | "I'd use [pattern] because [reason]. The trade-off is [downside]." |
| "Tell me about consistency." | "For reads, eventual consistency is fine — cache can be 5 seconds stale. For writes (bookings), I need strong consistency — direct to database with locking." |
| "What would you improve?" | "Notification reliability — I'd add a queue to guarantee delivery even if the service is temporarily down." |

---

## Final Checklist (Read Before Interview)

- [ ] **First sentence memorized:** "Before I start designing, I'd like to ask a few clarifying questions..."
- [ ] **QPS formula memorized:** (DAU × actions) ÷ 100,000
- [ ] **Cache patterns named:** Cache-aside (default), Write-through (strong consistency), TTL (safety net)
- [ ] **Concurrency solution ready:** Redis SETNX for holds, DB unique constraint as fallback
- [ ] **Trade-off language ready:** "The downside is...", "I'm accepting X for Y benefit..."
- [ ] **Wrap-up script ready:** "If I had more time, I'd improve..."

---

**You've studied the hard parts already. This is about organizing what you know so it comes out right under pressure.**

**Good luck. You've got this.**
