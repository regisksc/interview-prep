# Exercise 1: Appointment Booking System

**Difficulty**: Intermediate
**Time**: 45-60 minutes (mock interview format)
**Core Concepts**: Concurrency, Caching, Database Design, Real-time Updates

---

## Problem Statement

Design an appointment booking system for a healthcare platform where patients can book appointments with doctors.

### Requirements

**Functional** (what it must do):
1. Search for doctors by specialty, location, availability
2. View available time slots for a specific doctor
3. Book a time slot (with 5-minute hold while entering payment)
4. Cancel a booking
5. Get notified if a slot becomes available (waitlist)

**Non-Functional** (quality requirements):
1. No double-booking allowed
2. Response time < 200ms for availability search
3. Handle 10,000 concurrent users during peak
4. 99.9% uptime

---

## Part 1: API Design (10 min)

Design the API endpoints. Write down:
- URL path
- HTTP method
- Request body (if any)
- Response format

### Your Turn

<details>
<summary>Example Solution</summary>

```
┌────────────────────────────────────────────────────────────────────┐
│ Endpoint 1: Search Providers                                        │
├────────────────────────────────────────────────────────────────────┤
│ GET /api/v1/providers                                               │
│                                                                     │
│ Query Params:                                                       │
│   - specialty: string (optional)                                    │
│   - location: string (optional)                                     │
│   - insurance: string (optional)                                    │
│   - page: number (default 1)                                        │
│   - limit: number (default 20)                                      │
│                                                                     │
│ Response 200 OK:                                                    │
│ {                                                                   │
│   "providers": [                                                    │
│     {                                                               │
│       "id": "prov_123",                                             │
│       "name": "Dr. Sarah Chen",                                     │
│       "specialty": "Cardiology",                                    │
│       "location": "New York, NY",                                   │
│       "rating": 4.8,                                                │
│       "next_available": "2026-03-15T09:00:00Z"                      │
│     }                                                               │
│   ],                                                                │
│   "total": 42,                                                      │
│   "page": 1,                                                        │
│   "has_more": true                                                  │
│ }                                                                   │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│ Endpoint 2: Get Provider Availability                               │
├────────────────────────────────────────────────────────────────────┤
│ GET /api/v1/providers/{provider_id}/availability                    │
│                                                                     │
│ Query Params:                                                       │
│   - date: string (required, format: YYYY-MM-DD)                     │
│                                                                     │
│ Response 200 OK:                                                    │
│ {                                                                   │
│   "date": "2026-03-15",                                             │
│   "provider_id": "prov_123",                                        │
│   "slots": [                                                        │
│     {                                                               │
│       "slot_id": "slot_001",                                        │
│       "start_time": "2026-03-15T09:00:00Z",                         │
│       "end_time": "2026-03-15T09:30:00Z",                           │
│       "status": "available" | "held" | "booked",                    │
│       "hold_expires_at": "2026-03-15T10:05:00Z"  // if held        │
│     }                                                               │
│   ]                                                                 │
│ }                                                                   │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│ Endpoint 3: Hold a Slot                                             │
├────────────────────────────────────────────────────────────────────┤
│ POST /api/v1/slots/{slot_id}/hold                                   │
│                                                                     │
│ Request Body:                                                       │
│ {                                                                   │
│   "user_id": "user_456",                                            │
│   "patient_id": "patient_789"  // booking for someone else         │
│ }                                                                   │
│                                                                     │
│ Response 200 OK:                                                    │
│ {                                                                   │
│   "hold_id": "hold_abc123",                                         │
│   "slot_id": "slot_001",                                            │
│   "expires_at": "2026-03-15T10:05:00Z",                             │
│   "hold_duration_seconds": 300                                      │
│ }                                                                   │
│                                                                     │
│ Response 409 Conflict (slot already held/booked):                   │
│ {                                                                   │
│   "error": "slot_unavailable",                                      │
│   "message": "This slot is no longer available"                     │
│ }                                                                   │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│ Endpoint 4: Confirm Booking                                         │
├────────────────────────────────────────────────────────────────────┤
│ POST /api/v1/bookings                                               │
│                                                                     │
│ Request Body:                                                       │
│ {                                                                   │
│   "hold_id": "hold_abc123",                                         │
│   "payment_method_id": "pm_xyz",                                    │
│   "reason": "Annual checkup"  // optional                          │
│ }                                                                   │
│                                                                     │
│ Response 201 Created:                                               │
│ {                                                                   │
│   "booking_id": "booking_999",                                      │
│   "status": "confirmed",                                            │
│   "provider": { ... },                                              │
│   "slot": { ... },                                                  │
│   "payment": { ... }                                                │
│ }                                                                   │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│ Endpoint 5: Cancel Booking                                          │
├────────────────────────────────────────────────────────────────────┤
│ DELETE /api/v1/bookings/{booking_id}                                │
│                                                                     │
│ Response 200 OK:                                                    │
│ {                                                                   │
│   "booking_id": "booking_999",                                      │
│   "status": "cancelled",                                            │
│   "refund": {                                                       │
│     "amount": 150.00,                                               │
│     "status": "processing",                                         │
│     "estimated_arrival": "3-5 business days"                        │
│   }                                                                 │
│ }                                                                   │
└────────────────────────────────────────────────────────────────────┘
```

</details>

---

## Part 2: Database Schema (10 min)

Design the database tables. Consider:
- What entities do we need?
- How do they relate?
- What indexes would help performance?

### Your Turn

<details>
<summary>Example Solution</summary>

```sql
-- Providers (doctors)
CREATE TABLE providers (
    id              UUID PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    specialty       VARCHAR(100) NOT NULL,
    email           VARCHAR(255) UNIQUE NOT NULL,
    phone           VARCHAR(20),
    bio             TEXT,
    rating_avg      DECIMAL(3,2) DEFAULT 0.00,
    review_count    INTEGER DEFAULT 0,
    is_active       BOOLEAN DEFAULT true,
    created_at      TIMESTAMP DEFAULT NOW(),
    updated_at      TIMESTAMP DEFAULT NOW()
);

-- Provider locations (one provider can have multiple offices)
CREATE TABLE provider_locations (
    id              UUID PRIMARY KEY,
    provider_id     UUID REFERENCES providers(id),
    address_line1   VARCHAR(255) NOT NULL,
    address_line2   VARCHAR(255),
    city            VARCHAR(100) NOT NULL,
    state           VARCHAR(50) NOT NULL,
    zip_code        VARCHAR(20) NOT NULL,
    latitude        DECIMAL(10, 8),
    longitude       DECIMAL(11, 8),
    is_primary      BOOLEAN DEFAULT false
);

-- Provider availability templates (recurring schedule)
CREATE TABLE provider_schedules (
    id              UUID PRIMARY KEY,
    provider_id     UUID REFERENCES providers(id),
    day_of_week     INTEGER NOT NULL,  -- 0=Sunday, 1=Monday, etc.
    start_time      TIME NOT NULL,
    end_time        TIME NOT NULL,
    slot_duration   INTEGER NOT NULL DEFAULT 30,  -- minutes
    is_active       BOOLEAN DEFAULT true
);

-- Specific slot instances (generated from schedule)
CREATE TABLE appointment_slots (
    id              UUID PRIMARY KEY,
    provider_id     UUID REFERENCES providers(id),
    location_id     UUID REFERENCES provider_locations(id),
    start_time      TIMESTAMP NOT NULL,
    end_time        TIMESTAMP NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'available',
                              -- 'available', 'held', 'booked', 'cancelled'
    held_by         UUID,           -- user_id who holds it
    held_until      TIMESTAMP,      -- when hold expires
    booked_by       UUID,           -- patient_id
    booked_at       TIMESTAMP,
    cancelled_at    TIMESTAMP,

    -- Prevent double-booking at database level
    UNIQUE(provider_id, start_time)
);

-- Bookings (confirmed appointments)
CREATE TABLE bookings (
    id              UUID PRIMARY KEY,
    slot_id         UUID REFERENCES appointment_slots(id),
    patient_id      UUID REFERENCES users(id),
    provider_id     UUID REFERENCES providers(id),
    status          VARCHAR(20) NOT NULL DEFAULT 'confirmed',
                              -- 'confirmed', 'completed', 'cancelled', 'no_show'
    reason          TEXT,
    notes           TEXT,
    payment_id      UUID,
    created_at      TIMESTAMP DEFAULT NOW(),
    updated_at      TIMESTAMP DEFAULT NOW()
);

-- Waitlist (notifications when slots open)
CREATE TABLE slot_waitlist (
    id              UUID PRIMARY KEY,
    provider_id     UUID REFERENCES providers(id),
    user_id         UUID REFERENCES users(id),
    preferred_date  DATE,
    preferred_time_start  TIME,
    preferred_time_end    TIME,
    notified        BOOLEAN DEFAULT false,
    created_at      TIMESTAMP DEFAULT NOW()
);

-- ====================
-- INDEXES for Performance
-- ====================

-- Fast provider search by specialty + location
CREATE INDEX idx_providers_specialty ON providers(specialty);
CREATE INDEX idx_providers_location ON provider_locations(city, state);

-- Fast availability lookup
CREATE INDEX idx_slots_provider_date ON appointment_slots(provider_id, start_time);
CREATE INDEX idx_slots_status ON appointment_slots(status);

-- Fast booking lookup by patient
CREATE INDEX idx_bookings_patient ON bookings(patient_id);
CREATE INDEX idx_bookings_provider ON bookings(provider_id);

-- Waitlist matching
CREATE INDEX idx_waitlist_provider_date ON slot_waitlist(provider_id, preferred_date);
```

</details>

---

## Part 3: Caching Strategy (15 min)

This is the **critical** part. How do you handle:
1. Multiple users viewing the same slots
2. 5-minute holds that auto-expire
3. Keeping cache in sync with database

### Your Turn: Design the Cache

**Questions to answer**:
1. What data goes in the cache vs database?
2. What's the cache key structure?
3. How do you handle hold expiration?
4. What's your cache invalidation strategy?

<details>
<summary>Example Solution</summary>

## Cache Data Structure

```
┌─────────────────────────────────────────────────────────────────────┐
│ What Goes in Redis (Cache)                                          │
├─────────────────────────────────────────────────────────────────────┤
│ ✓ Slot availability status (changes frequently)                     │
│ ✓ Active holds (need TTL auto-expiry)                               │
│ ✓ Search results (expensive to recompute)                           │
│ ✓ Provider ratings (read-heavy, updated periodically)               │
├─────────────────────────────────────────────────────────────────────┤
│ What Stays in Database Only                                         │
├─────────────────────────────────────────────────────────────────────┤
│ ✓ Confirmed bookings (must be durable)                              │
│ ✓ Payment records (ACID required)                                   │
│ ✓ User data (relational, not cache-friendly)                        │
└─────────────────────────────────────────────────────────────────────┘
```

## Redis Key Design

```
# Slot status for a provider on a date
Key: slots:{provider_id}:{date}
Value: JSON array of slot statuses
TTL: 1 hour (refreshed on changes)

Example:
slots:prov_123:2026-03-15 → [
  {"slot_id": "s1", "status": "available"},
  {"slot_id": "s2", "status": "held", "held_by": "u456", "expires": 1234567890},
  {"slot_id": "s3", "status": "booked"}
]

# Active hold (with auto-expiry via TTL)
Key: hold:{hold_id}
Value: JSON with hold details
TTL: 300 seconds (5 minutes)

Example:
hold:hold_abc123 → {"slot_id": "s2", "user_id": "u456", "provider_id": "prov_123"}
(TTL: 300 → auto-deletes after 5 minutes)

# Slot-to-hold mapping (for cleanup)
Key: slot_hold:{slot_id}
Value: hold_id
TTL: 300 seconds

# Search results cache
Key: search:providers:{specialty}:{location}:{page}
Value: JSON array of provider results
TTL: 5 minutes (providers don't change often)

# Provider ratings cache
Key: provider:{id}:rating
Value: {"avg": 4.8, "count": 142}
TTL: 1 hour (updated when new review arrives)
```

## Hold Flow with Cache

```
Step 1: User clicks "Hold" on slot

  Client → Server: POST /slots/slot_001/hold

  Server checks Redis:
    EXISTS slot_hold:slot_001?
    → If exists: return 409 (already held)
    → If not: proceed

  Server creates hold in Redis:
    MULTI
      SET hold:hold_abc123 '{"slot_id":"slot_001",...}' EX 300
      SET slot_hold:slot_001 "hold_abc123" EX 300
      HSET slots:prov_123:2026-03-15 slot_001 '{"status":"held",...}'
    EXEC

  Return hold_id to client

Step 2: User completes payment (within 5 min)

  Client → Server: POST /bookings {hold_id, payment}

  Server:
    1. Verify hold exists: GET hold:hold_abc123
       → If missing: return 409 (hold expired)

    2. Create booking in database (transaction):
       BEGIN
         INSERT INTO bookings (...)
         UPDATE appointment_slots SET status='booked', ...
       COMMIT

    3. Update cache:
       DELETE hold:hold_abc123
       DELETE slot_hold:slot_001
       PUBLISH slot_booked:slot_001 "booked"  (notify WebSocket clients)

    4. Return booking confirmation

Step 3: Hold expires (user didn't complete)

  Redis automatically deletes hold:hold_abc123 (TTL)

  But we need to free the slot! Use Redis Keyspace Notifications:

  Subscribe to: __keyevent@0__:expired

  When hold:hold_abc123 expires:
    → Event triggered
    → Worker receives event
    → Worker deletes slot_hold:slot_001
    → Worker updates slots:prov_123:2026-03-15 status to 'available'
    → Worker publishes slot_available:slot_001 event
    → WebSocket server notifies waitlisted users
```

## Cache Invalidation Strategies

```
Strategy 1: Time-based (TTL)
  - Set expiry on all cache entries
  - Pros: Simple, eventually consistent
  - Cons: Stale data until TTL expires

Strategy 2: Write-through (update cache on write)
  - When booking created → update cache immediately
  - Pros: Always fresh
  - Cons: More complex, cache write failures matter

Strategy 3: Cache-aside (lazy loading)
  - On read: check cache → if miss, read DB → populate cache
  - On write: invalidate cache key
  - Next read repopulates from DB
  - Pros: Simple, resilient
  - Cons: One slow read after invalidation

Our Choice: Hybrid
  - Slot availability: Cache-aside + short TTL (1 min)
  - Holds: Write-through with TTL
  - Search results: Time-based (5 min TTL acceptable)
```

</details>

---

## Part 4: Concurrency Handling (15 min)

### The Race Condition Problem

```
Time    User A                          User B
 │
 │       ┌─ Check slot availability
 │       │  → Returns "available"
 │       │
 │       │                              ┌─ Check slot availability
 │       │                              │  → Returns "available"  ⚠️
 │       │                              │
 │       ▼                              ▼
 │       ┌─ Try to hold                 ┌─ Try to hold
 │       │  POST /slots/s1/hold         │  POST /slots/s1/hold
 │       │                              │
 │       ▼                              ▼
         Server receives                 Server receives
         Request A                       Request B
              │                              │
              ▼                              ▼
         Check Redis:                    Check Redis:
         slot_hold:s1?                   slot_hold:s1?
         → Not found                     → Not found  ⚠️
              │                              │
              ▼                              ▼
         Create hold                   Create hold
         SUCCESS                       SUCCESS  ⚠️ DOUBLE BOOKING!
```

Both succeeded because both requests checked BEFORE either wrote.

### Solutions

<details>
<summary>Solution 1: Redis SETNX (Recommended)</summary>

```
SETNX = SET if Not eXists (atomic operation)

Hold Logic:
  result = SETNX slot_hold:slot_001 "hold_abc123"

  if result == 1:
    # We got the lock! Set hold details with TTL
    SET hold:hold_abc123 '{"slot_id":"slot_001",...}' EX 300
    EXPIRE slot_hold:slot_001 300
    return SUCCESS
  else:
    # Someone else got it first
    return FAIL (slot already held)
```

**Why it works**: SETNX is atomic - only one request can succeed even if they arrive at the exact same millisecond.

</details>

<details>
<summary>Solution 2: Database Unique Constraint</summary>

```sql
-- Add unique constraint at database level
ALTER TABLE appointment_slots
ADD CONSTRAINT unique_provider_start UNIQUE (provider_id, start_time);

-- Or add a separate locking table
CREATE TABLE slot_locks (
    slot_id     UUID PRIMARY KEY,  -- Primary key = unique
    held_by     UUID NOT NULL,
    held_until  TIMESTAMP NOT NULL
);

-- Hold attempt becomes:
INSERT INTO slot_locks (slot_id, held_by, held_until)
VALUES ('slot_001', 'user_456', NOW() + INTERVAL '5 minutes')
ON CONFLICT (slot_id) DO NOTHING;

-- Check if insert succeeded (rows affected > 0 means we got it)
```

**Why it works**: Database enforces uniqueness. Second insert fails.

</details>

<details>
<summary>Solution 3: Distributed Lock (Redis Lock)</summary>

```
Use Redis-based distributed lock (Redlock algorithm)

Hold Logic:
  lock_key = "lock:slot:slot_001"
  lock_id = generate_uuid()
  lock_acquired = SET lock_key lock_id NX EX 10  # 10 second lock

  if lock_acquired:
    try:
      # We have exclusive access
      # Check availability, create hold, etc.
      ...
    finally:
      # Release lock
      RELEASE_LOCK(lock_key, lock_id)  # Atomic release
  else:
    return FAIL (another request in progress)
```

**When to use**: For complex multi-step operations that need exclusive access.

</details>

---

## Part 5: Real-Time Notifications (10 min)

### Scenario: User is viewing available slots. A held slot expires. How do they see it?

### Approach 1: Polling (Simple but inefficient)

```
Client: "Any new slots?" → Server: "No"
Client: "Any new slots?" → Server: "No"
Client: "Any new slots?" → Server: "Yes, slot_001 available!"
     │              │              │
     ▼              ▼              ▼
   every 5s      every 5s       every 5s

Pros: Simple to implement
Cons:
  - Wasteful (99% of requests return "no change")
  - Delay up to poll interval
  - Server load: 10,000 users × 0.2 Hz = 2,000 requests/sec
```

### Approach 2: WebSockets (Recommended)

```
Client                          Server
  │                               │
  │──── WebSocket Connect ───────►│
  │                               │
  │◄──── Connection Accepted ────►│
  │                               │
  │     [Connection stays open]   │
  │                               │
  │                               │ Slot expires
  │                               │
  │◄──── {"type": "slot_available",
           "slot_id": "slot_001"}─│
  │                               │

Pros:
  - Instant delivery
  - Server can push to specific clients
  - Efficient (no wasteful polling)
Cons:
  - More complex infrastructure
  - Need connection management
```

### Approach 3: Server-Sent Events (SSE)

```
Client                          Server
  │                               │
  │──── GET /events (SSE) ───────►│
  │                               │
  │◄──── HTTP 200 (streaming) ───►│
  │                               │
  │     [HTTP connection stays open]
  │                               │
  │◄──── data: {"type": "slot_available"}
  │                               │
  │◄──── data: {"type": "slot_available"}

Pros: Simpler than WebSocket (HTTP only)
Cons: Server-to-client only (not bidirectional)
```

### Implementation: WebSocket Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                        WebSocket Flow                              │
└────────────────────────────────────────────────────────────────────┘

Client App                    WebSocket Server              Redis
   │                                │                         │
   │── Connect (user_456) ─────────►│                         │
   │                                │                         │
   │                                │── Store connection:      │
   │                                │── user_connections:      │
   │                                │──   user_456: [conn_1]   │
   │                                │                         │
   │◄───────────────────────────────│                         │
   │     Connected                   │                         │
   │                                │                         │
   │                                │                         │
   │                                │  Slot expires event     │
   │                                │  (from Redis pub/sub)   │
   │                                │                         │
   │                                │◄────────────────────────│
   │                                │  PUBLISH slot:001:free  │
   │                                │                         │
   │                                │── Lookup: who's watching?
   │                                │── GET user_connections:  │
   │                                │                         │
   │◄───────────────────────────────│                         │
   │   {"type": "slot_available",   │                         │
   │    "slot_id": "slot_001"}      │                         │
   │                                │                         │

Code Structure:

# WebSocket Server (pseudo-code)
class WebSocketHandler:
    connections = {}  # user_id → [connection_ids]

    def on_connect(self, websocket, user_id):
        self.connections[user_id].add(websocket)

    def on_slot_freed(self, slot_id, provider_id):
        # Find all users watching this provider
        watchers = redis.smembers(f"watching:provider:{provider_id}")
        for user_id in watchers:
            for conn in self.connections[user_id]:
                conn.send_json({
                    "type": "slot_available",
                    "slot_id": slot_id
                })
```

---

## Part 6: Complete Flow Diagram

```
┌────────────────────────────────────────────────────────────────────────────┐
│                    END-TO-END BOOKING FLOW                                 │
└────────────────────────────────────────────────────────────────────────────┘

User App                    Load Balancer          API Server           Redis           Database
   │                            │                      │                  │                │
   │── 1. Search doctors ──────►│                      │                  │                │
   │                            │                      │                  │                │
   │                            │─────────────────────►│                  │                │
   │                            │                      │  Check cache:    │                │
   │                            │                      │  GET search:...  │                │
   │                            │                      │◄─────────────────│                │
   │                            │                      │                  │                │
   │                            │                      │  Cache miss!     │                │
   │                            │                      │  Query DB:       │                │
   │                            │                      │  SELECT FROM...  │                │
   │                            │                      │─────────────────►│                │
   │                            │                      │◄─────────────────│                │
   │                            │                      │                  │                │
   │                            │                      │  Populate cache: │                │
   │                            │                      │  SET search:...  │                │
   │                            │                      │─────────────────►│                │
   │                            │                      │                  │                │
   │◄───────────────────────────│──────────────────────│                  │                │
   │   [List of doctors]        │                      │                  │                │
   │                            │                      │                  │                │
   │── 2. Select Dr. Smith ─────►│                      │                  │                │
   │                            │                      │                  │                │
   │                            │─────────────────────►│                  │                │
   │                            │                      │  Get availability│                │
   │                            │                      │  GET slots:...   │                │
   │                            │                      │◄─────────────────│                │
   │                            │                      │                  │                │
   │◄───────────────────────────│──────────────────────│                  │                │
   │   [9:00, 9:30, 10:00]      │                      │                  │                │
   │                            │                      │                  │                │
   │── 3. Click "Hold" 10:00 ──►│                      │                  │                │
   │                            │                      │                  │                │
   │                            │─────────────────────►│                  │                │
   │                            │                      │  SETNX slot_hold:│                │
   │                            │                      │─────────────────►│                │
   │                            │                      │◄─────────────────│                │
   │                            │                      │  SUCCESS!        │                │
   │                            │                      │                  │                │
   │                            │                      │  SET hold:... EX │                │
   │                            │                      │─────────────────►│                │
   │                            │                      │                  │                │
   │◄───────────────────────────│──────────────────────│                  │                │
   │   {hold_id: abc,           │                      │                  │                │
   │    expires: 5 min}         │                      │                  │                │
   │                            │                      │                  │                │
   │── 4. Enter payment ────────►│                      │                  │                │
   │     (within 5 min)         │                      │                  │                │
   │                            │                      │                  │                │
   │                            │─────────────────────►│                  │                │
   │                            │                      │  Verify hold:    │                │
   │                            │                      │  GET hold:abc    │                │
   │                            │                      │◄─────────────────│                │
   │                            │                      │                  │                │
   │                            │                      │  EXISTS!         │                │
   │                            │                      │  Process payment │                │
   │                            │                      │                  │                │
   │                            │                      │  Create booking: │                │
   │                            │                      │  INSERT INTO...  │                │
   │                            │                      │─────────────────►│                │
   │                            │                      │◄─────────────────│                │
   │                            │                      │                  │                │
   │                            │                      │  Delete hold:    │                │
   │                            │                      │  DEL hold:abc    │                │
   │                            │                      │─────────────────►│                │
   │                            │                      │                  │                │
   │                            │                      │  Update slot:    │                │
   │                            │                      │  SET slots:...   │                │
   │                            │                      │─────────────────►│                │
   │                            │                      │                  │                │
   │                            │                      │  PUBLISH event   │                │
   │                            │                      │─────────────────►│                │
   │                            │                      │                  │                │
   │◄───────────────────────────│──────────────────────│                  │                │
   │   {booking_id: xyz,        │                      │                  │                │
   │    status: confirmed}      │                      │                  │                │
   │                            │                      │                  │                │
   │                            │                      │                  │                │
   │                            │                      │                  │                │
   │                            │                      │                  │                │
   │                            │                      │     [5 min pass] │                │
   │                            │                      │                  │                │
   │                            │                      │  Hold expires    │                │
   │                            │                      │  (auto-delete)   │                │
   │                            │                      │                  │                │
   │                            │                      │◄─────────────────│  TTL expires   │
   │                            │                      │                  │                │
   │                            │                      │  Keyspace event: │                │
   │                            │                      │  on-expired      │                │
   │                            │                      │                  │                │
   │                            │                      │  Free up slot    │                │
   │                            │                      │  in cache        │                │
   │                            │                      │                  │                │
   │                            │                      │  Notify waiting  │                │
   │                            │                      │  users via WS    │                │
   │                            │                      │                  │                │
   │◄───────────────────────────│──────────────────────│                  │                │
   │   Push: "Slot available!"  │                      │                  │                │
```

---

## Part 7: Interview Questions to Expect

### Q1: "What if Redis goes down?"

<details>
<summary>Answer</summary>

**Good response structure**:

1. **Acknowledge the problem**: "If Redis goes down, we can't create holds or check availability from cache."

2. **Immediate mitigation**:
   - "Fall back to database reads for availability"
   - "Accept holds with database-based locking (slower but works)"

3. **Long-term solution**:
   - "Redis Cluster with replication (automatic failover)"
   - "Multi-region Redis (if global deployment)"
   - "Circuit breaker pattern to gracefully degrade"

4. **Trade-off**: "We accept slower performance during Redis outage, but system remains functional."

</details>

### Q2: "How would you handle last-minute cancellations?"

<details>
<summary>Answer</summary>

**Key points**:

1. **Cancellation policy**:
   - "Allow free cancellation up to 24 hours before"
   - "Charge fee for late cancellations"

2. **Slot becomes available**:
   - "Update slot status to 'available'"
   - "Notify waitlisted users immediately (WebSocket push)"

3. **Inventory management**:
   - "Track cancellation rate per provider"
   - "Overbook slightly to compensate (like airlines)"

4. **Database design**:
   - "Keep cancelled booking record (audit trail)"
   - "Add cancellation reason, timestamp"

</details>

### Q3: "How do you prevent people from holding slots without booking?"

<details>
<summary>Answer</summary>

**Solutions**:

1. **Hold limits**:
   - "Max 3 active holds per user"
   - "Track in Redis: SET holds:user_456 [slot1, slot2, slot3]"

2. **Penalty system**:
   - "Track expired holds count"
   - "Temporarily block users with high abuse rate"

3. **Shorter hold time**:
   - "5 minutes for regular users"
   - "2 minutes during peak hours"

4. **Require payment info upfront**:
   - "Store payment method on file"
   - "Charge no-show fee"

</details>

### Q4: "How would you scale this to handle flash sales (100x traffic)?"

<details>
<summary>Answer</summary>

**Scaling strategies**:

1. **Read-heavy scaling**:
   - "Add more cache layers (CDN for static, Redis for dynamic)"
   - "Read replicas for database"

2. **Write-heavy scaling**:
   - "Queue booking requests (process asynchronously)"
   - "Shard database by provider_id or geographic region"

3. **Traffic management**:
   - "Rate limiting per user/IP"
   - "Virtual waiting room (queue before hitting servers)"
   - "Graceful degradation (disable non-essential features)"

4. **Capacity planning**:
   - "Auto-scaling based on queue depth"
   - "Pre-warm cache before known high-traffic events"

</details>

---

## Part 8: Your Turn - Practice Questions

### Question 1: Design the waitlist feature

A user wants to be notified when a slot becomes available for their preferred date/time.

**Design**:
1. API endpoint to join waitlist
2. Data structure to store waitlist entries
3. Matching algorithm (when slot frees, who to notify?)
4. Notification delivery (push, email, SMS?)

### Question 2: Handle recurring appointments

A patient needs weekly physical therapy for 6 weeks.

**Design**:
1. How do you represent recurring bookings?
2. How do you handle one cancelled session?
3. How do you find available recurring slots?

### Question 3: Multi-provider booking

Some treatments require multiple providers (e.g., consultation + procedure).

**Design**:
1. How do you find overlapping availability?
2. How do you hold multiple slots atomically?
3. What if only one slot is available?

---

## Summary Checklist

After completing this exercise, you should be able to:

- [ ] Explain why caching is needed for slot availability
- [ ] Describe how Redis TTL handles hold expiration
- [ ] Identify the race condition in booking flows
- [ ] Explain at least 2 solutions to prevent double-booking
- [ ] Draw the complete system architecture
- [ ] Discuss trade-offs between polling vs WebSockets
- [ ] Design database schema with proper indexes
- [ ] Handle edge cases (Redis down, cancellations, no-shows)

---

## Further Reading

- **Redis Documentation**: https://redis.io/docs/
- **Martin Fowler on Caching**: https://martinfowler.com/bliki/Caching.html
- **System Design Primer**: https://github.com/donnemartin/system-design-primer
