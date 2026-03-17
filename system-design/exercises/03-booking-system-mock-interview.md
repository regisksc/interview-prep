# Mock Interview 3: Design an Appointment Booking System

**Difficulty:** Intermediate/Hard
**Time:** 75-90 minutes
**Focus:** Concurrency control, distributed locks, cache invalidation, real-time updates

---

## Problem Statement

> **Interviewer:** "Today I'd like you to design an appointment booking system — think Zocdoc or a healthcare scheduling platform. Patients should be able to search for doctors, view their available time slots, and book appointments. The key challenge is that we can't allow double-bookings — two patients booking the same slot at the same time."

---

## Phase 1: Requirements Gathering (0-8 minutes)

### Mock Dialogue

**Interviewer:** "Today I'd like you to design an appointment booking system..."

**Candidate:** "Got it. So the core functionality is: patients search for doctors, view available slots, and book appointments — with the critical constraint that we can't have double-bookings. Let me ask some questions to understand the requirements better.

Starting with scale — how many providers (doctors) are we talking about, and what's the booking volume?"

**Interviewer:** "Let's say 5,000 providers, and about 50,000 bookings per day."

**Candidate:** "Okay, 50K bookings per day is about 0.6 bookings per second on average. But I imagine traffic isn't uniform — are there peak hours?"

**Interviewer:** "Good point. Let's say peak hours (9 AM - 12 PM) see 5x the average traffic."

**Candidate:** "So peak is about 3 bookings per second. And for availability searches — those are probably much more frequent than actual bookings?"

**Interviewer:** "Yes, I'd expect 20-50x more searches than bookings."

**Candidate:** "That gives us 60-150 searches per second at peak. A few more questions:
- Do we need real-time slot locking? Like, if I'm viewing a slot, should it be held for me while I enter my details?
- What's the hold duration — how long do we reserve a slot before the user completes booking?
- Do providers set their own availability, or is it managed by the system?"

**Interviewer:** "Good questions. Yes, we need a hold mechanism — let's say 5 minutes. And providers set their availability through a separate provider portal."

**Candidate:** "Perfect. And for concurrency — you mentioned no double-bookings. Is this just about the final booking step, or do we need to prevent two users from even holding the same slot simultaneously?"

**Interviewer:** "We should prevent two users from holding the same slot. Only one user should be able to have a slot on hold at any time."

**Candidate:** "Got it — so the hold itself is exclusive. A few more clarifying questions:
- Do we need to support recurring appointments? (e.g., weekly therapy sessions)
- What about cancellations and waitlists?
- Is payment part of the flow, or handled separately?"

**Interviewer:** "Let's keep it simple for now — no recurring appointments, yes to cancellations, and payment is handled externally. Anything else?"

**Candidate:** "Let me also confirm the non-functional requirements:
- **Consistency:** Strong consistency for bookings — no double-bookings even under concurrent requests
- **Latency:** Availability search should return in under 200ms
- **Availability:** 99.9% uptime for booking flow
- **Data sensitivity:** This is healthcare data, so we need HIPAA compliance (encryption, audit logs)

Does that sound right?"

**Interviewer:** "Yes, that's a good summary. HIPAA is important but focus on the system design aspects rather than security specifics."

---

### Requirements Summary

```
┌─────────────────────────────────────────────────────────────────┐
│  FUNCTIONAL REQUIREMENTS                                        │
├─────────────────────────────────────────────────────────────────┤
│  1. Search providers by specialty, location, availability       │
│  2. View provider's available time slots                        │
│  3. Hold a slot for 5 minutes (exclusive hold)                  │
│  4. Complete booking (convert hold to confirmed appointment)    │
│  5. Cancel booking (release slot back to available)             │
│  6. Providers can set/manage their availability                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  NON-FUNCTIONAL REQUIREMENTS                                    │
├─────────────────────────────────────────────────────────────────┤
│  1. Scale: 5,000 providers, 50K bookings/day                    │
│  2. Peak traffic: 3 bookings/sec, 150 searches/sec              │
│  3. Strong consistency: NO double-bookings                      │
│  4. Latency: < 200ms for availability search                    │
│  5. Availability: 99.9% uptime                                  │
│  6. HIPAA compliance: encryption, audit logging                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 2: Back-of-Envelope Estimation (8-15 minutes)

### Mock Dialogue

**Candidate:** "Let me estimate the scale. 50,000 bookings per day ÷ 86,400 seconds ≈ 0.6 bookings/second average. At peak (5x), that's about 3 bookings/second.

For availability searches, if we assume 50x more searches than bookings:
- Average: 30 searches/second
- Peak: 150 searches/second

This is a read-heavy workload with a 50:1 read-to-write ratio."

**Interviewer:** "And what does that tell you?"

**Candidate:** "Three things:

1. **Caching is critical:** Availability searches are read-heavy and latency-sensitive (< 200ms requirement). We should cache availability data.

2. **The hard problem is concurrency, not scale:** 3 bookings/second is trivial for a database. But preventing double-bookings when two users try to book the same slot at the exact same time — that's the real challenge.

3. **Storage is manageable:** If each provider has, say, 100 slots per week, and we store 52 weeks ahead:
   - 5,000 providers × 100 slots/week × 52 weeks = 26 million slots
   - Each slot record is ~100 bytes
   - Total: ~2.6 GB — very manageable

Let me also think about the hold mechanism. With 50K bookings/day and a 5-minute hold window:
- Average holds active at any time: 50,000 × (5 min / 1440 min per day) ≈ 173 holds
- Peak holds: ~500-1,000

That's a small number — Redis can easily handle this."

**Interviewer:** "Good analysis. So you're saying the complexity isn't about scale?"

**Candidate:** "Exactly. If this were 100,000 bookings/second, we'd need sharding, distributed databases, etc. But at 3 bookings/second, a single well-configured database handles it easily. The complexity is in:

1. **Concurrency control:** Preventing race conditions during booking
2. **Cache invalidation:** Keeping availability cache fresh when slots are booked
3. **Hold expiration:** Automatically releasing slots when holds expire

These are distributed systems problems, not scale problems."

---

### Estimation Summary

```
┌─────────────────────────────────────────────────────────────────┐
│  SCALE ESTIMATION                                               │
├─────────────────────────────────────────────────────────────────┤
│  Bookings: 50,000/day ÷ 86,400 sec ≈ 0.6/sec (avg)             │
│  Bookings (peak): ~3/sec                                        │
│  Searches: 50x bookings = 30/sec (avg), 150/sec (peak)          │
│  Ratio: 50:1 (read-heavy)                                       │
│                                                                 │
│  Active holds: 50K × (5/1440) ≈ 173 concurrent holds            │
│                                                                 │
│  Storage: 5K providers × 100 slots × 52 weeks × 100 bytes       │
│           ≈ 2.6 GB                                              │
│                                                                 │
│  ARCHITECTURE IMPLICATIONS:                                     │
│  • Caching essential for search latency                         │
│  • Concurrency control is the hard problem                      │
│  • Single database is sufficient for writes                     │
│  • Redis for holds (TTL auto-expiry)                            │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 3: High-Level Design (15-28 minutes)

### Mock Dialogue

**Candidate:** "Let me start with the high-level architecture."

*(Draws while narrating)*

"I'm drawing the basic spine first: mobile app, API server, and database. Then I'll add the components we need for caching and holds."

```
┌─────────────────┐     ┌──────────────────┐     ┌────────────────┐
│   Mobile App    │────►│    API Server    │────►│   PostgreSQL   │
│  (Patient/Prov) │◄────│                  │◄────│                │
└─────────────────┘     └────────┬─────────┘     └────────────────┘
                                 │
                        ┌────────┴────────┐
                        │                 │
                 ┌──────▼──────┐   ┌──────▼──────┐
                 │    Redis    │   │ Notification│
                 │  (holds +   │   │   Service   │
                 │   cache)    │   │             │
                 └─────────────┘   └─────────────┘
```

**Candidate:** "The key components are:

1. **PostgreSQL:** Stores providers, slots, and bookings. ACID compliance is important for preventing double-bookings.

2. **Redis:** Two use cases:
   - **Hold management:** Store active holds with TTL (auto-expires after 5 minutes)
   - **Availability cache:** Cache search results and slot availability

3. **Notification Service:** Sends confirmation emails/SMS asynchronously (doesn't block the booking flow).

**Interviewer:** "Walk me through what happens when a patient searches for providers."

**Candidate:** "Sure. The search flow:

```
1. Patient opens app, searches "Cardiologist in New York"
2. API Server receives: GET /providers?specialty=cardiology&location=NYC
3. Check cache: GET search:cardiology:nyc:page1
4. If cache hit: return cached results
5. If cache miss:
   a. Query database: SELECT providers WHERE specialty = 'cardiology' AND location = 'NYC'
   b. Cache results: SET search:cardiology:nyc:page1 [results] EX 300
   c. Return results
```

The cache TTL is 5 minutes — provider info doesn't change frequently, so slight staleness is acceptable."

**Interviewer:** "And what about viewing availability for a specific provider?"

**Candidate:** "Good question — this is more time-sensitive. Let me think...

```
1. Patient selects Dr. Smith, views March 15th
2. API Server: GET /providers/prov_123/availability?date=2026-03-15
3. Check cache: GET slots:prov_123:2026-03-15
4. If cache hit: return cached availability
5. If cache miss:
   a. Query database: SELECT * FROM slots WHERE provider_id = 'prov_123' AND date = '2026-03-15'
   b. Filter out held/booked slots
   c. Cache: SET slots:prov_123:2026-03-15 [slots] EX 60  (1 minute TTL)
   d. Return availability
```

Note the shorter TTL — 1 minute instead of 5 minutes. Availability changes more frequently than provider info, so we want fresher data."

**Interviewer:** "Why not real-time? Why cache at all for availability?"

**Candidate:** "Two reasons:

1. **Database load:** If 150 users/second are viewing Dr. Smith's calendar, we don't want 150 database queries. The underlying slot data doesn't change that frequently.

2. **User experience:** A patient viewing availability doesn't need millisecond-accurate data. If a slot was booked 30 seconds ago and they still see it as available, they'll find out when they try to hold it — and the hold request will fail gracefully.

The key insight: **availability display is eventually consistent, but the hold operation is strongly consistent.** We can show slightly stale data, but when the user tries to act on it, we check the real state."

---

### Detailed Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│           APPOINTMENT BOOKING SYSTEM ARCHITECTURE               │
└─────────────────────────────────────────────────────────────────┘

                              ┌─────────────┐
                         ┌────│   Patients  │────┐
                         │    └─────────────┘    │
                         │                       │
                   ┌─────▼─────┐           ┌─────▼─────┐
                   │  Patient  │           │ Provider  │
                   │    App    │           │   Portal  │
                   └─────┬─────┘           └─────┬─────┘
                         │                       │
                         └───────────┬───────────┘
                                     │
                              ┌──────▼──────┐
                              │Load Balancer│
                              │   (NGINX)   │
                              └──────┬──────┘
                                     │
            ┌────────────────────────┼────────────────────────┐
            │                        │                        │
    ┌───────▼───────┐        ┌───────▼───────┐        ┌───────▼───────┐
    │   API Server  │        │   API Server  │        │   API Server  │
    │    (Node)     │        │    (Node)     │        │    (Node)     │
    │               │        │               │        │               │
    │ ┌───────────┐ │        │ ┌───────────┐ │        │ ┌───────────┐ │
    │ │  Local    │ │        │ │  Local    │ │        │ │  Local    │ │
    │ │  Cache    │ │        │ │  Cache    │ │        │ │  Cache    │ │
    │ └───────────┘ │        │ └───────────┘ │        │ └───────────┘ │
    └───────┬───────┘        └───────┬───────┘        └───────┬───────┘
            │                        │                        │
            └────────────────────────┼────────────────────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
             ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐
             │    Redis    │  │ PostgreSQL  │  │    Kafka    │
             │   Cluster   │  │   Primary   │  │  (Events)   │
             │             │  │             │  │             │
             │ ┌─────────┐ │  │ ┌─────────┐ │  └──────┬──────┘
             │ │  Holds  │ │  │ │  Read   │ │         │
             │ │  Cache  │ │  │ │Replicas │ │  ┌──────▼──────┐
             │ └─────────┘ │  │ └─────────┘ │  │ Notification│
             └─────────────┘  └─────────────┘  │   Service   │
                                               └─────────────┘
```

---

## Phase 4: Deep Dive — Concurrency Control (28-50 minutes)

### Mock Dialogue

**Interviewer:** "Let's go deep on the hold and booking flow. This is where we prevent double-bookings. Walk me through exactly what happens."

**Candidate:** "This is the critical path. Let me break it down step by step.

**The Hold Flow:**

```
Step 1: User clicks "Hold" on a slot
  Client → Server: POST /slots/slot_001/hold
  Body: {user_id: "user_456"}

Step 2: Server attempts to create hold in Redis
  We use SETNX (SET if Not eXists) for atomicity:

  hold_key = "slot_hold:slot_001"
  result = REDIS.setnx(hold_key, "user_456")

  if result == 1:
    # We got the lock!
    REDIS.set("hold:hold_abc123",
              json.dumps({slot_id: "slot_001", user_id: "user_456"}),
              ex=300)  # 5 minute TTL
    REDIS.setex(hold_key, 300, "user_456")
    return {hold_id: "hold_abc123", expires_at: "..."}
  else:
    # Someone else holds this slot
    return 409 {error: "slot_already_held"}
```

**Key insight:** SETNX is atomic — even if two requests arrive at the exact same millisecond, only one succeeds."

**Interviewer:** "Why Redis and not the database for holds?"

**Candidate:** "Three reasons:

1. **TTL auto-expiry:** Redis automatically deletes keys when TTL expires. With a database, we'd need a background job to clean up expired holds — that's complex and error-prone.

2. **Performance:** Redis SETNX is sub-millisecond. Database locking with transactions is slower (milliseconds).

3. **Failure isolation:** If Redis goes down, we can fail over to database locking. But under normal operation, Redis gives us better performance.

The trade-off is we're adding another system to operate. But for this use case, the TTL feature alone justifies Redis."

---

**Interviewer:** "Okay, so the user has a hold. What happens when they try to book?"

**Candidate:** "Good question. The booking flow is where we need database-level guarantees:

```
Step 1: User completes booking form, clicks "Confirm"
  Client → Server: POST /bookings
  Body: {hold_id: "hold_abc123", payment_info: "..."}

Step 2: Server verifies hold exists
  hold_data = REDIS.get("hold:hold_abc123")

  if hold_data is null:
    return 409 {error: "hold_expired"}  # User took too long

  if hold_data.user_id != current_user:
    return 403 {error: "not_your_hold"}

Step 3: Create booking in database (transactional)
  BEGIN TRANSACTION;

  -- Lock the slot row to prevent concurrent modifications
  SELECT * FROM slots WHERE id = 'slot_001' FOR UPDATE;

  -- Verify slot is still available (defensive check)
  if slot.status != 'available':
    ROLLBACK;
    return 409 {error: "slot_no_longer_available"};

  -- Create the booking
  INSERT INTO bookings (slot_id, user_id, status)
  VALUES ('slot_001', 'user_456', 'confirmed');

  -- Update slot status
  UPDATE slots SET status = 'booked', booked_by = 'user_456'
  WHERE id = 'slot_001';

  COMMIT;

Step 4: Clean up holds
  REDIS.del("hold:hold_abc123")
  REDIS.del("slot_hold:slot_001")

Step 5: Update cache
  REDIS.del("slots:prov_123:2026-03-15")  # Invalidate availability cache

Step 6: Return confirmation
  return {booking_id: "bk_789", status: "confirmed"}

Step 7: Async notification (via Kafka)
  KAFKA.publish("booking.created", {booking_id: "bk_789", ...})
```

**Key insight:** The `SELECT ... FOR UPDATE` locks the slot row in the database. If another transaction tries to book the same slot simultaneously, it blocks until our transaction commits or rolls back."

---

**Interviewer:** "You mentioned SETNX for the hold. What if two requests arrive at exactly the same time? Walk me through the timing."

**Candidate:** "Let me draw out the race condition and how SETNX prevents it:

```
WITHOUT SETNX (race condition):

Time    Request A (Alice)                Request B (Bob)
 │       Check: slot_hold:slot_001        │
 │       → null (not held)                │
 │                                        │
 │       SET slot_hold:slot_001 = Alice   │
 │                                        │
 │                                       │ Check: slot_hold:slot_001
 │                                       │ → null (not held yet!)
 │                                       │
 │                                       │ SET slot_hold:slot_001 = Bob
 │                                       │
 │       Result: BOTH succeeded!          │
 │       Double hold created! ⚠️          │


WITH SETNX (atomic operation):

Time    Request A (Alice)                Request B (Bob)
 │       SETNX slot_hold:slot_001 = Alice │
 │       → Returns 1 (success)            │
 │                                        │
 │                                       │ SETNX slot_hold:slot_001 = Bob
 │                                       │ → Returns 0 (key exists!)
 │                                       │
 │       Alice gets hold ✓                │ Bob gets error ✓
 │                                        │
 │       NO RACE CONDITION!               │
```

SETNX is atomic — Redis processes commands sequentially. Even if both requests arrive at the same millisecond, Redis executes one first. The second SETNX sees the key already exists and returns 0."

---

**Interviewer:** "What if Redis goes down between creating the hold and the user completing the booking?"

**Candidate:** "Good edge case. Let me think through the failure modes:

**Scenario A: Redis down BEFORE hold is created**
```
User clicks "Hold" → Redis connection fails
→ Catch exception
→ Fail over to database locking:
   INSERT INTO slot_locks (slot_id, held_by, held_until)
   VALUES ('slot_001', 'user_456', NOW() + INTERVAL '5 minutes')
   ON CONFLICT (slot_id) DO NOTHING;

→ If insert succeeds, hold created via DB
→ If insert fails, slot already locked by another user
```

**Scenario B: Redis down AFTER hold is created but BEFORE booking**
```
User has hold_abc123 in hand
User clicks "Confirm" → Redis connection fails
→ We can't verify the hold in Redis
→ Check database: was a booking already created for this slot?
→ If no booking exists, allow the booking (user had valid hold)
→ Create booking in database
→ Log warning: couldn't clean up Redis hold
```

**Scenario C: Redis down DURING booking (after DB commit)**
```
Booking committed to database ✓
Try to delete Redis hold → Redis connection fails
→ Log warning: hold not cleaned up
→ Hold will expire naturally via TTL when Redis recovers
→ No data inconsistency (booking is persisted)
```

The key principle: **database is the source of truth**. Redis is an optimization. If Redis fails, we can still maintain correctness using database locks."

---

### Concurrency Control Comparison

```
┌─────────────────────────────────────────────────────────────────┐
│  CONCURRENCY CONTROL OPTIONS                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Option 1: Redis SETNX (Primary choice)                         │
│  ─────────────────────────────────────────                      │
│  Hold: SETNX slot_hold:{slot_id} {user_id}                      │
│  Pros: Sub-millisecond, TTL auto-expiry, simple                 │
│  Cons: Another system to operate, eventual failover needed      │
│                                                                 │
│  Option 2: Database Row Lock (Fallback)                         │
│  ─────────────────────────────────────                          │
│  Hold: SELECT ... FOR UPDATE then INSERT booking                │
│  Pros: ACID guarantees, no extra system                         │
│  Cons: Slower (milliseconds), need cleanup job for expired holds│
│                                                                 │
│  Option 3: Optimistic Locking (Alternative)                     │
│  ─────────────────────────────────────                          │
│  UPDATE slots SET status='booked', version=version+1            │
│  WHERE id='slot_001' AND version=5 AND status='available'       │
│  Pros: No locks, works well under low contention                │
│  Cons: Retry logic needed, fails under high contention          │
│                                                                 │
│  RECOMMENDATION: Redis SETNX with DB fallback                   │
└─────────────────────────────────────────────────────────────────┘
```

---

**Interviewer:** "You mentioned cache invalidation. Walk me through when and how you invalidate caches."

**Candidate:** "Cache invalidation is where most bugs happen. Let me be precise:

**When to invalidate:**

| Event | What to Invalidate | Why |
|-------|-------------------|-----|
| Slot held | `slots:{provider_id}:{date}` | Slot is now held, not available |
| Slot booked | `slots:{provider_id}:{date}` | Slot is now booked |
| Slot released (hold expired) | `slots:{provider_id}:{date}` | Slot is available again |
| Provider updates schedule | `slots:{provider_id}:{all dates}` | Schedule changed |
| Provider info changes | `search:{specialty}:{location}` | Search results changed |

**How to invalidate:**

```python
def on_slot_booked(slot_id, provider_id, date):
    # Pattern 1: Direct delete
    REDIS.delete(f"slots:{provider_id}:{date}")

    # Pattern 2: Publish event for cache refresh
    REDIS.publish(f"slot_updated:{slot_id}", "booked")

    # Pattern 3: Version key (for coordinated invalidation)
    REDIS.incr(f"cache_version:slots:{provider_id}:{date}")
```

**The hard case:** What if we invalidate the cache, but the database update fails?

```python
# WRONG order (can cause stale cache):
CACHE.delete("slots:prov_123:2026-03-15")
DB.update("UPDATE slots SET status='booked' WHERE id='slot_001'")  # Fails!
# Cache is now invalid, but DB wasn't updated
# Next read repopulates cache with OLD data (slot still shows available!)

# CORRECT order:
DB.update("UPDATE slots SET status='booked' WHERE id='slot_001'")  # First
CACHE.delete("slots:prov_123:2026-03-15")  # Then invalidate
# If DB fails, cache isn't invalidated (correct!)
# If cache invalidate fails, cache has TTL (will self-correct)
```

**Interviewer:** "What about when a hold expires? How do you know to update the cache?"

**Candidate:** "Great question. When Redis deletes a hold key (TTL expiry), we need to:
1. Mark the slot as available again
2. Update or invalidate the availability cache

There are two approaches:

**Approach A: Redis Keyspace Notifications**
```
# Enable keyspace notifications in Redis config:
notify-keyspace-events Ex  # Keyspace events for expired keys

# Subscribe to expired events:
SUBSCRIBE __keyevent@0__:expired

# When hold:hold_abc123 expires:
→ Event received: expired hold:hold_abc123
→ Worker extracts slot_id from hold data (before it's deleted)
→ Worker: UPDATE slots SET status='available' WHERE id='slot_001'
→ Worker: REDIS.delete("slots:prov_123:2026-03-15")
→ Worker: REDIS.publish("slot_available:slot_001", "available")
```

**Approach B: Lazy cleanup on next read**
```
# Don't proactively update when hold expires
# Instead, check for expired holds when reading availability:

def get_availability(provider_id, date):
    cached = REDIS.get(f"slots:{provider_id}:{date}")
    if cached:
        return cached

    # Cache miss - query DB
    slots = DB.query("SELECT * FROM slots WHERE provider_id = ? AND date = ?", provider_id, date)

    # Filter out slots that are held but expired
    valid_slots = []
    for slot in slots:
        if slot.status == 'held':
            # Check if hold is still valid
            hold_key = f"slot_hold:{slot.id}"
            if not REDIS.exists(hold_key):
                # Hold expired - mark as available
                DB.update("UPDATE slots SET status='available' WHERE id = ?", slot.id)
                slot.status = 'available'
        valid_slots.append(slot)

    REDIS.set(f"slots:{provider_id}:{date}", json.dumps(valid_slots), ex=60)
    return valid_slots
```

**My recommendation:** Approach B (lazy cleanup) for simplicity. Keyspace notifications add complexity and are a common source of bugs. The lazy approach means expired holds are cleaned up on the next availability read — which is usually within seconds."

---

## Phase 5: Handling Edge Cases (50-70 minutes)

### Mock Dialogue

**Interviewer:** "Let's talk about edge cases. What happens when a patient tries to book but their hold expired mid-booking?"

**Candidate:** "Good scenario. Let me trace through:

```
Time    Event
 │
 │  0:00  User clicks "Hold" → hold created, expires at 0:05
 │
 │  0:00  User sees hold form (payment, patient info)
 │
 │  ... user is typing ...
 │
 │  0:05  Hold expires (Redis auto-deletes)
 │
 │  0:06  User clicks "Confirm Booking"
 │
 ▼
Server receives: POST /bookings {hold_id: "hold_abc123"}

1. Verify hold: hold_data = REDIS.get("hold:hold_abc123")
   → Returns null (hold expired!)

2. Return 409 Conflict:
   {
     "error": "hold_expired",
     "message": "Your hold has expired. Please select a slot again.",
     "action": "redirect_to_slot_selection"
   }

3. Client shows user-friendly message:
   "Oops! Your reserved time slot was released. Please select a new time."
```

**User experience:** The user loses their slot and has to re-select. This is unfortunate but correct — we can't let them book an expired hold."

**Interviewer:** "Can we do better? Like warn them before the hold expires?"

**Candidate:** "Yes! We can add a client-side countdown with a warning:

```javascript
// Client-side code
const holdExpiresAt = new Date(response.expires_at);
const timeRemaining = holdExpiresAt - Date.now();

// Show countdown timer
setInterval(() => {
  const remaining = holdExpiresAt - Date.now();
  updateCountdownDisplay(remaining);

  if (remaining < 60000) {  // Less than 1 minute
    showWarning("Your slot will expire in 1 minute!");
  }

  if (remaining <= 0) {
    showExpiredMessage();
    disableBookingButton();
  }
}, 1000);
```

We could also add a **hold refresh** endpoint:

```
POST /holds/{hold_id}/refresh
→ Extends hold by another 2 minutes (one time only)
→ Gives user more time to complete
→ Prevents abuse (only one refresh per hold)
```

But for simplicity, I'd start with just a countdown timer and clear expiration message."

---

**Interviewer:** "What about no-shows? How do you handle patients who book but don't show up?"

**Candidate:** "This is more of a business logic question, but it affects the design. A few approaches:

**1. No-show tracking:**
```sql
ALTER TABLE bookings ADD COLUMN show_up_status VARCHAR(20);
-- Values: 'showed', 'no_show', 'cancelled'

-- Track no-show rate per patient
ALTER TABLE users ADD COLUMN no_show_count INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN total_bookings INTEGER DEFAULT 0;
```

**2. Consequences for no-shows:**
- After N no-shows, require prepayment for bookings
- Reduce no-show patients' priority for popular slots
- Send reminder notifications (reduces no-shows by 30-50%)

**3. Slot release after no-show:**
```
If patient doesn't show within 15 minutes of appointment time:
→ Mark slot as 'no_show' (not 'available')
→ Provider can still see this was a booked slot
→ Don't release to general availability (provider already blocked time)
```

For the system design, I'd add a **notification service** that sends:
- Booking confirmation (immediate)
- Reminder 24 hours before
- Reminder 2 hours before
- Follow-up after appointment (request review)

This reduces no-shows and improves the experience."

---

**Interviewer:** "How do you handle a provider canceling an appointment last minute?"

**Candidate:** "Provider cancellation is trickier than patient cancellation because:
1. It's more disruptive (patient was expecting care)
2. We need to proactively notify the patient
3. We might need to help rebook

```
Provider cancels appointment:

1. Provider clicks "Cancel" in provider portal
   → POST /bookings/bk_789/cancel {reason: "emergency"}

2. Server updates booking:
   BEGIN TRANSACTION;
   UPDATE bookings SET status = 'cancelled_by_provider',
                       cancelled_at = NOW(),
                       cancellation_reason = 'emergency'
   WHERE id = 'bk_789';

   -- Release the slot back to available
   UPDATE slots SET status = 'available', booked_by = NULL
   WHERE id = 'slot_001';
   COMMIT;

3. Invalidate cache:
   REDIS.delete("slots:prov_123:2026-03-15")

4. Notify patient (URGENT):
   KAFKA.publish("appointment.cancelled", {
     booking_id: "bk_789",
     patient_id: "user_456",
     reason: "emergency",
     slot: {...}
   })

   → Notification Service sends SMS + email + push notification
   → "Dr. Smith had to cancel your appointment. Click here to reschedule."

5. Offer priority rebooking:
   → Generate "priority rebook" token for patient
   → Allow patient to book next available slot before general public
```

The key difference from patient cancellation: provider cancellations trigger immediate proactive notification, not just a confirmation email."

---

**Interviewer:** "What about waitlists? If a patient wants a fully-booked day, how do they get notified when a slot opens?"

**Candidate:** "Good question — waitlists are a common feature. Let me design this:

**Data model:**
```sql
CREATE TABLE waitlist_entries (
    id              UUID PRIMARY KEY,
    provider_id     UUID NOT NULL,
    patient_id      UUID NOT NULL,
    preferred_date  DATE,
    preferred_time_start TIME,  -- Optional: "morning" or "afternoon"
    preferred_time_end   TIME,
    status          VARCHAR(20) DEFAULT 'active',
    notified_at     TIMESTAMP,
    created_at      TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_waitlist_provider_date ON waitlist_entries(provider_id, preferred_date);
```

**Joining the waitlist:**
```
POST /waitlist
Body: {provider_id: "prov_123", preferred_date: "2026-03-15"}

→ INSERT INTO waitlist_entries (provider_id, patient_id, preferred_date)
  VALUES ('prov_123', 'user_456', '2026-03-15')
```

**Notifying when slot opens:**

```python
def on_slot_released(provider_id, date, slot_time):
    # Find matching waitlist entries
    matches = DB.query("""
        SELECT patient_id FROM waitlist_entries
        WHERE provider_id = ? AND preferred_date = ?
        AND status = 'active'
        ORDER BY created_at ASC  # First-come-first-served
        LIMIT 5
    """, provider_id, date)

    for patient in matches:
        # Send notification
        KAFKA.publish("waitlist.slot_available", {
            patient_id: patient.patient_id,
            provider_id: provider_id,
            date: date,
            slot_time: slot_time
        })

        # Mark as notified (prevent duplicate notifications)
        DB.update("""
            UPDATE waitlist_entries
            SET notified_at = NOW(), status = 'notified'
            WHERE patient_id = ? AND provider_id = ?
        """, patient.patient_id, provider_id)
```

**User experience:**
```
→ Patient receives push notification:
  "Good news! A slot opened with Dr. Smith on March 15 at 2:00 PM.
   Click to book now!"

→ Patient clicks → goes directly to booking flow
→ Slot is NOT on hold — they need to complete booking
→ First patient to complete booking gets the slot
```

**Trade-off:** We notify 5 patients for one slot. Only one will book. The other 4 get a "slot taken" message. This is intentional — it maximizes the chance the slot gets filled quickly."

---

**Interviewer:** "Let's talk about scaling. What if we grow from 5,000 providers to 50,000? What breaks?"

**Candidate:** "Good question. Let me think about each component:

**Database:**
- 50K providers × 100 slots × 52 weeks = 260 million slot records
- Still manageable for PostgreSQL (billions of rows is fine with proper indexing)
- Read replicas can handle increased search load
- Write load is still low (maybe 30 bookings/sec at 10x scale)

**Redis:**
- More providers = more cache keys
- At 10x scale: ~10 GB of cache data (still fits in memory)
- Redis Cluster can shard across multiple nodes

**Potential bottlenecks:**

1. **Search queries:** As provider count grows, search becomes slower
   ```
   -- This query gets expensive at scale:
   SELECT * FROM providers WHERE specialty = 'cardiology' AND location = 'NYC'

   -- Solution: Use Elasticsearch for search
   → Index providers in Elasticsearch
   → Search: POST /providers/_search {query: {...}}
   → Returns provider IDs, then fetch details from DB
   ```

2. **Hot providers:** A very popular provider might have 1000 users viewing their calendar simultaneously
   ```
   -- Solution: Local cache + cache stampede prevention
   if cache_miss:
       if REDIS.setnx("refreshing:prov_123", "1", ex=5):
           # We're the one refreshing
           data = DB.query(...)
           REDIS.set("slots:prov_123:...", data)
           REDIS.delete("refreshing:prov_123")
       else:
           # Wait for other request to refresh
           sleep(100ms)
           data = REDIS.get("slots:prov_123:...")
   ```

3. **Booking concurrency:** If 100 users try to book the same slot at once
   ```
   -- Solution: Queue-based booking for high-demand slots
   → Users join a "booking queue" for popular slots
   → Process bookings sequentially
   → Fair (first-come-first-served) and prevents race conditions
   ```

At 100x scale (500K providers, 5M bookings/day), I'd also consider:
- Sharding database by geographic region
- Regional Redis clusters
- CDN for static provider info"

---

## Phase 6: Wrap-Up (70-85 minutes)

### Mock Dialogue

**Interviewer:** "Great. To wrap up, if you had more time, what's the one thing you'd most want to improve?"

**Candidate:** "I'd add **intelligent slot recommendation** — helping patients find the best available slot rather than just showing a calendar.

```
Current: Patient picks date → sees all available slots → manually selects

Improved: Patient enters preferences → system recommends best slots

Preferences:
- "As soon as possible"
- "Morning appointments only"
- "Within 5 miles of home"
- "Highest rated providers"

Algorithm:
1. Score each slot based on:
   - Recency (sooner = higher score)
   - Time of day preference
   - Provider rating
   - Distance from patient
   - Historical no-show rate (avoid risky slots)

2. Rank slots by score
3. Show top 5 recommendations + "view all" option

This improves conversion rates and patient satisfaction. But it requires:
- ML model for scoring
- More data (patient location, historical patterns)
- A/B testing infrastructure

So it's a v2 feature, not v1."
```

---

**Interviewer:** "Any trade-offs you want to call out?"

**Candidate:** "Yes, several key trade-offs:

1. **Redis vs Database for holds:**
   - Chose Redis for TTL auto-expiry and performance
   - Trade-off: Added system complexity, need failover strategy

2. **Cache-aside vs Write-through:**
   - Chose cache-aside for simplicity
   - Trade-off: Brief window of stale cache after invalidation

3. **SETNX vs Database locking:**
   - Chose SETNX for performance
   - Trade-off: Need to handle Redis failures gracefully

4. **Lazy hold cleanup vs Keyspace notifications:**
   - Chose lazy cleanup for simplicity
   - Trade-off: Expired holds aren't cleaned up immediately

5. **Eventual consistency for availability display:**
   - Accepting stale availability cache (1 min TTL)
   - Trade-off: Users might see a slot as available when it's already held
   - Mitigation: Hold operation is strongly consistent

All these choices favor simplicity for the initial implementation, with clear paths to improve if needed."

---

## Interviewer Scorecard

### Strong Candidate Signals

| Area | What to Look For |
|------|------------------|
| **Concurrency** | Understands race conditions, can explain SETNX atomicity |
| **Cache invalidation** | Knows when/how to invalidate, correct order (DB first, then cache) |
| **Hold mechanism** | TTL auto-expiry, Redis data structures |
| **Edge cases** | Handles expiration, cancellations, provider no-shows |
| **Trade-offs** | Names specific trade-offs, can discuss alternatives |
| **Production thinking** | Mentions metrics, graceful degradation, lazy cleanup |

### Red Flags

- ❌ No locking mechanism mentioned (allows double-booking)
- ❌ Cache invalidation in wrong order (cache before DB)
- ❌ No handling for hold expiration
- ❌ Can't explain why Redis over database for holds
- ❌ No consideration for provider cancellations
- ❌ Assumes single-server deployment

---

## Follow-Up Questions

### Q1: "How would you handle recurring appointments (weekly therapy for 6 weeks)?"

**Expected Answer:**
```
Data model:
CREATE TABLE recurring_appointments (
    id UUID PRIMARY KEY,
    booking_id UUID REFERENCES bookings(id),  -- First appointment
    recurrence_rule VARCHAR(50),  -- "WEEKLY;COUNT=6"
    series_id UUID  -- Groups all appointments in series
);

Booking flow:
1. Find 6 consecutive available slots (same day/time)
2. Hold ALL 6 slots atomically (or fail if any unavailable)
3. Create 6 bookings with same series_id
4. If user cancels one, offer to cancel entire series

Complexity:
- Need to hold multiple slots atomically
- If one slot is taken mid-booking, entire series fails
- Consider: book first, schedule rest later (flexible series)
```

### Q2: "How would you handle time zones for a multi-country platform?"

**Expected Answer:**
```
Key principle: Store everything in UTC, convert at display time

Database:
- slots.start_time: TIMESTAMP WITH TIME ZONE (stored as UTC)
- providers.timezone: VARCHAR(50)  -- "America/New_York"

API:
- Client sends timezone: GET /availability?timezone=America/Los_Angeles
- Server converts UTC times to requested timezone

Edge cases:
- Daylight Saving Time changes (some days have 23 or 25 hours)
- Providers moving locations (which timezone applies?)
- Cross-timezone bookings (patient in LA booking NYC doctor)

Solution:
- Store provider's canonical timezone
- Display times in patient's local timezone
- Show timezone explicitly: "3:00 PM ET"
```

### Q3: "Design a system to prevent booking fraud (fake appointments, scalping)."

**Expected Answer:**
```
Fraud patterns:
1. Bot booking all slots to resell
2. Fake accounts circumventing limits
3. Payment fraud (stolen cards)

Mitigations:
1. Rate limiting by IP + device fingerprint
2. Phone verification for bookings
3. Payment method verification (AVS, CVV)
4. Behavioral analysis (humans don't book at 3 AM every day)
5. Limit bookings per payment method
6. CAPTCHA for suspicious patterns

Detection:
- ML model for anomaly detection
- Graph analysis (accounts sharing payment methods)
- Velocity checks (too many bookings too fast)
```

---

## Summary Checklist

- [ ] Can explain SETNX and why it prevents race conditions
- [ ] Understands cache invalidation order (DB first, then cache)
- [ ] Knows Redis TTL pattern for auto-expiry
- [ ] Can handle hold expiration gracefully
- [ ] Understands provider vs patient cancellation flows
- [ ] Can discuss waitlist implementation
- [ ] Knows scaling strategies for 10x growth

---

**Next:** Mock Interview 4 (News Feed / Timeline — Scaling Focus)
