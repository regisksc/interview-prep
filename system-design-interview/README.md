# System Design Interview - Beginner's Guide

## What is a System Design Interview?

Unlike coding interviews that test your ability to write algorithms, **system design interviews** test your ability to:

1. **Design a complete system** - How do all the pieces fit together?
2. **Make trade-off decisions** - Why choose A over B?
3. **Scale systems** - What happens when 1 million users show up?
4. **Communicate clearly** - Can you explain your thinking?

### Typical Format (45-60 minutes)

```
┌─────────────────────────────────────────────────┐
│ 1. Understand the Problem (5 min)               │
│ 2. Define Requirements (5 min)                  │
│ 3. High-Level Design (10 min)                   │
│ 4. Deep Dive Components (20 min)                │
│ 5. Identify Bottlenecks (10 min)                │
└─────────────────────────────────────────────────┘
```

---

## Part 1: Fundamental Concepts (Start Here)

### 1.1 Client-Server Architecture

```
┌──────────┐         ┌──────────┐         ┌──────────┐
│  Client  │  ───►   │  Server  │  ───►   │ Database │
│ (Browser)│  ◄───   │  (API)   │  ◄───   │          │
└──────────┘         └──────────┘         └──────────┘
```

**Client**: The user's device (phone, browser)
**Server**: Processes requests, contains business logic
**Database**: Stores data permanently

**Example**: When you log into Instagram:
- Client sends: `POST /login {username, password}`
- Server validates credentials
- Database stores user data
- Server returns: `{success: true, token: "abc123"}`

---

### 1.2 API Endpoints

An **API** is how the client talks to the server. An **endpoint** is a specific URL for a specific action.

| Endpoint | Method | Purpose | Example Request | Example Response |
|----------|--------|---------|-----------------|------------------|
| `/users` | GET | Get all users | - | `[{id: 1, name: "John"}]` |
| `/users/1` | GET | Get user by ID | - | `{id: 1, name: "John"}` |
| `/users` | POST | Create user | `{name: "Jane"}` | `{id: 2, name: "Jane"}` |
| `/users/1` | DELETE | Delete user | - | `{success: true}` |

**Key terms:**
- **Request**: What client sends to server
- **Response**: What server sends back
- **HTTP Methods**: GET (read), POST (create), PUT (update), DELETE (remove)

---

### 1.3 Databases

A **database** stores your data. Two main types:

#### Relational (SQL) - Tables with relationships

```
┌─────────────────┐      ┌─────────────────┐
│     Users       │      │    Appointments │
├────────┬────────┤      ├────────┬────────┤
│ id     │ name   │      │ id     │ user_id│
├────────┼────────┤      ├────────┼────────┤
│ 1      │ John   │──────► 1      │ 1      │
│ 2      │ Jane   │      │ 2      │ 1      │
└────────┴────────┘      └────────┴────────┘
```

**Use when**: Data has clear relationships, needs consistency
**Examples**: PostgreSQL, MySQL

#### Non-Relational (NoSQL) - Flexible documents

```
{
  id: 1,
  name: "John",
  appointments: [
    {date: "2026-03-15", time: "10:00"},
    {date: "2026-03-16", time: "14:00"}
  ]
}
```

**Use when**: Flexible schema, fast reads/writes
**Examples**: MongoDB, DynamoDB

---

### 1.4 Caching

A **cache** is fast, temporary storage. Think of it like your browser remembering a webpage.

```
┌──────────┐      ┌──────────┐      ┌──────────┐
│  Client  │ ──►  │  Cache   │ ──►  │ Database │
│          │ ◄──  │ (Redis)  │ ◄──  │          │
└──────────┘      └──────────┘      └──────────┘
                       ▲
                       │
                  Fast! (ms)
```

**When to use cache:**
- Data is read often but rarely changes
- Expensive computations (don't recalculate every time)
- Session data (user login state)

**TTL (Time-To-Live)**: How long data lives in cache before expiring

```
Example: Booking hold for 5 minutes

Cache: {slot_id: "123", held_by: user_456, expires_at: 10:35}
                              │
                              ▼
                    At 10:35 → automatically expires
```

---

### 1.5 Concurrency

**Concurrency** = Multiple things happening at the same time.

**Problem**: Two users try to book the same appointment slot.

```
User A                          Server                        User B
  │                               │                              │
  │───"Is slot 123 available?"───►│                              │
  │                               │───"Yes, available"───────────│
  │                               │                              │
  │───"Book slot 123"────────────►│                              │
  │                               │◄──"Book slot 123"────────────│
  │                               │                              │
  │                               │ ⚠️ PROBLEM: Both booked!
```

**Solutions:**

1. **Database Locks**: Only one request can modify at a time
2. **Optimistic Locking**: Check version before saving
3. **Atomic Operations**: Database handles it in one step

---

### 1.6 Load Balancer

A **load balancer** distributes traffic across multiple servers.

```
                    ┌───────────────┐
                    │   10,000      │
                    │   Requests    │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │    Load       │
                    │   Balancer    │
                    └───────┬───────┘
                            │
            ┌───────────────┼───────────────┐
            ▼               ▼               ▼
    ┌───────────────┐ ┌───────────────┐ ┌───────────────┐
    │   Server 1    │ │   Server 2    │ │   Server 3    │
    └───────────────┘ └───────────────┘ └───────────────┘
```

**Why**: No single server can handle all traffic.

---

### 1.7 WebSockets vs HTTP

| HTTP | WebSockets |
|------|------------|
| Request → Response (one-way) | Persistent two-way connection |
| Client must ask for updates | Server can push updates anytime |
| Good for: fetching data | Good for: chat, live updates |

**HTTP Example** (Polling):
```
Client: "Any new messages?" → Server: "No"
Client: "Any new messages?" → Server: "No"
Client: "Any new messages?" → Server: "Yes, 1 message!"
```

**WebSocket Example**:
```
[Connection established]
Server: "New message!" → Client receives instantly
Server: "User is typing..." → Client receives instantly
```

---

## Part 2: Practice Scenarios (Progressive Difficulty)

### Scenario 1: URL Shortener (Beginner)

**Goal**: Build a service like bit.ly

**Requirements**:
- Given a long URL, generate a short URL (e.g., `bit.ly/abc123`)
- When someone visits short URL, redirect to original
- Track click count

**Questions to think about**:
1. How do you generate the short code?
2. Where do you store the mapping?
3. How do you handle two people shortening the same URL?

<details>
<summary>Click for Solution Approach</summary>

```
1. Generate short code:
   - Hash the URL (MD5, SHA) → take first 6 chars
   - Or: Auto-increment ID → base62 encode (0-9, a-z, A-Z)

2. Storage:
   Database table:
   ┌─────────┬──────────────────────────┬─────────┐
   │ code    │ original_url             │ clicks  │
   ├─────────┼──────────────────────────┼─────────┤
   │ abc123  │ https://very-long.com/...│ 42      │
   └─────────┴──────────────────────────┴─────────┘

3. Same URL handling:
   - Check if URL exists → return existing short code
   - Or: Always create new (different use case)
```

</details>

---

### Scenario 2: Appointment Booking System (Intermediate)

This is the scenario from your requirements. Let's break it down.

**Goal**: Book appointments with doctors/providers

**Requirements**:
- Users can see available time slots
- Users can book a slot (hold it for 5 minutes)
- Payment confirms the booking
- Handle multiple users trying to book same slot

**Key Concepts Applied**:
| Concept | How it applies |
|---------|---------------|
| **Caching** | Hold slot in Redis with 5-min TTL |
| **Concurrency** | Two users can't book same slot |
| **Database** | Store confirmed bookings |
| **Real-time** | Notify when slot becomes available |

**System Design**:

```
┌─────────────────────────────────────────────────────────┐
│                     Client App                          │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                  Load Balancer                          │
└─────────────────────────────────────────────────────────┘
                            │
            ┌───────────────┴───────────────┐
            ▼                               ▼
┌───────────────────────┐       ┌───────────────────────┐
│    API Server 1       │       │    API Server 2       │
└───────────────────────┘       └───────────────────────┘
            │                               │
            └───────────────┬───────────────┘
                            │
            ┌───────────────┴───────────────┐
            ▼                               ▼
┌───────────────────────┐       ┌───────────────────────┐
│    Redis Cache        │       │    PostgreSQL         │
│    (Holds & Slots)    │       │    (Confirmed Books)  │
└───────────────────────┘       └───────────────────────┘
```

**API Endpoints**:

```
GET  /providers?specialty=cardiology&location=NYC
→ Returns list of doctors matching criteria

GET  /providers/{id}/availability?date=2026-03-15
→ Returns available slots for that doctor on that date

POST /slots/{id}/hold
→ Puts 5-minute hold on slot (returns hold_id)

POST /bookings
→ Converts hold to confirmed booking (requires payment)

DELETE /holds/{id}
→ Releases hold early (user cancelled)
```

**Flow: Booking an Appointment**

```
User App                          Server                      Redis         Database
   │                                │                           │              │
   │──1. Search doctors────────────►│                           │              │
   │                                │──────────────────────────►│              │
   │◄───────────────────────────────│                           │              │
   │                                │                           │              │
   │──2. Get availability──────────►│                           │              │
   │    (date: 2026-03-15)          │                           │              │
   │                                │─────────┐                 │              │
   │                                │         │ Read available  │              │
   │                                │◄────────┤ slots from DB   │              │
   │                                │         │ (exclude booked)│              │
   │◄───────────────────────────────│                           │              │
   │    [9:00, 9:30, 10:00]         │                           │              │
   │                                │                           │              │
   │──3. Hold slot (10:00)─────────►│                           │              │
   │                                │──SET slot:10:00 {hold:true, user:123, TTL:300}──►│
   │◄───────────────────────────────│◄─────────────────────────────────────────────────│
   │    {hold_id: "abc"}            │                           │              │
   │                                │                           │              │
   │──4. Payment ──────────────────►│                           │              │
   │                                │                           │              │
   │                                │──────────────────────────►│ DELETE hold  │
   │                                │                           │              │
   │                                │─────────────────────────────────────────►│
   │                                │                           │   INSERT booking │
   │◄───────────────────────────────│                           │              │
   │    {booking_id: "xyz"}         │                           │              │
   │                                │                           │              │
   │                                │                           │              │
   │                                │                           │              │
   │                                │     [5 minutes pass - TTL expires]        │
   │                                │                           │              │
   │                                │                           │ Auto-delete  │
   │                                │                           │ (slot freed) │
```

**Handling Race Conditions**:

```
Problem: User A and User B both try to hold slot at 10:00

Solution 1: Redis SETNX (SET if Not eXists)
  - Only one succeeds, other gets error

Solution 2: Database unique constraint
  - (provider_id, slot_time) must be unique
  - Second insert fails → return "slot taken"

Solution 3: Optimistic locking
  - Add version number to slot
  - Only update if version matches
```

---

### Scenario 3: Real-Time Chat (Advanced)

**Goal**: Build WhatsApp-like messaging

**Requirements**:
- Send/receive messages instantly
- Online/offline status
- Message history
- Deliver even if recipient offline

**Key Concepts**:
| Concept | Application |
|---------|-------------|
| **WebSockets** | Persistent connection for instant delivery |
| **Database** | Store message history |
| **Cache** | Online status, recent messages |
| **Queue** | Deliver offline messages later |

**Architecture**:

```
┌─────────────┐                          ┌─────────────┐
│   User A    │                          │   User B    │
└──────┬──────┘                          └──────┬──────┘
       │                                        │
       │ WebSocket                              │ WebSocket
       │                                        │
       ▼                                        ▼
┌─────────────────────────────────────────────────────────┐
│              WebSocket Server (Connection Manager)      │
│  - Maintains active connections                         │
│  - Routes messages between users                        │
│  - Tracks online status                                 │
└─────────────────────────────────────────────────────────┘
       │                    │                    │
       ▼                    ▼                    ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Redis     │    │   Message   │    │   Queue     │
│   (Status)  │    │   Database  │    │   (Offline) │
└─────────────┘    └─────────────┘    └─────────────┘
```

---

## Part 3: How to Approach Any System Design Question

### Step-by-Step Framework

**1. Clarify Requirements (5 min)**

Ask questions:
- "How many users are we expecting?"
- "What are the core features vs nice-to-have?"
- "Any latency requirements?"

**2. Define Scope (5 min)**

Write down:
- **Functional Requirements**: What the system does
  - Users can book appointments
  - Users can cancel bookings
- **Non-Functional Requirements**: Quality attributes
  - 99.9% uptime
  - < 200ms response time

**3. High-Level Design (10 min)**

Draw boxes and arrows:
- Client → Load Balancer → Servers → Database
- Identify major components

**4. Deep Dive (20 min)**

Pick 2-3 areas to go deep:
- Data model (database schema)
- API design (endpoints)
- Specific challenge (concurrency, caching)

**5. Bottlenecks (10 min)**

Identify and solve:
- "Single point of failure" → Add redundancy
- "Database overload" → Add caching
- "Slow queries" → Add indexes

---

## Part 4: Practice Exercises

### Exercise 1: Design a Counter

**Task**: Design an API endpoint that returns an incrementing number.

**Requirements**:
- `GET /counter` returns `{count: 1}`, then `{count: 2}`, etc.
- Must work across multiple server instances

**Think about**:
- Where do you store the count?
- What if two requests come at the same time?

<details>
<summary>Solution</summary>

```
Problem: In-memory counter won't work with multiple servers

Solution 1: Redis INCR (atomic operation)
  - Redis handles concurrency
  - Fast (~1ms)

Solution 2: Database with transactions
  - BEGIN; SELECT count; UPDATE count+1; COMMIT;
  - Slower but durable

API:
  GET /counter
  → {count: 42}
```

</details>

---

### Exercise 2: Rate Limiter

**Task**: Limit users to 100 requests per minute.

**Think about**:
- How do you track request count?
- When does the count reset?
- Where do you enforce the limit?

<details>
<summary>Solution</summary>

```
Redis-based approach:

Key: rate_limit:{user_id}
Value: count
TTL: 60 seconds

Algorithm (sliding window):
  count = Redis.get(key)
  if count >= 100:
    return 429 Too Many Requests
  else:
    Redis.incr(key)
    Redis.expire(key, 60)  // Set TTL if first request
```

</details>

---

### Exercise 3: News Feed Design

**Task**: Design Twitter's home timeline.

**Requirements**:
- Users see tweets from people they follow
- Feed updates in real-time
- Must be fast (< 100ms)

**Think about**:
- How do you store tweets?
- How do you generate the feed?
- What about users with millions of followers?

<details>
<summary>Solution</summary>

```
Approach 1: Pull-based (read heavy)
  - On feed request: fetch tweets from all followed users
  - Problem: Slow if following many people

Approach 2: Push-based (write heavy)
  - When user tweets: push to all followers' feeds
  - Problem: Expensive for celebrity tweets

Approach 3: Hybrid
  - Regular users: push-based
  - Celebrities: pull-based (merge on read)
```

</details>

---

## Part 5: Common Interview Questions

### Q: "How would you scale this?"

**Good answer structure**:
1. Identify the bottleneck (database? CPU?)
2. Propose solution (cache? more servers?)
3. Discuss trade-offs

### Q: "What if the cache is wrong?"

**Topics to cover**:
- Cache invalidation strategies
- Cache-aside vs write-through
- Handling stale data

### Q: "How do you ensure data consistency?"

**Discuss**:
- ACID transactions (for SQL)
- Eventual consistency (for distributed systems)
- When each is appropriate

---

## Part 6: Resources for Further Learning

### Books
- **"System Design Interview" by Alex Xu** - Visual, beginner-friendly
- **"Designing Data-Intensive Applications" by Martin Kleppmann** - Deep dive

### Practice
- **bytebytego.com** - Newsletter with system design breakdowns
- **github.com/donnemartin/system-design-primer** - Free GitHub resource

---

## Quick Reference: Component Cheat Sheet

| Component | Purpose | When to Use |
|-----------|---------|-------------|
| **Load Balancer** | Distribute traffic | Always (production) |
| **Cache (Redis)** | Fast reads, sessions | Read-heavy data |
| **Database (SQL)** | Structured, consistent data | Financial, bookings |
| **Database (NoSQL)** | Flexible, scalable | Logs, content |
| **Queue (Kafka)** | Async processing | Email, notifications |
| **CDN** | Static assets globally | Images, videos, JS |
| **WebSocket** | Real-time bidirectional | Chat, live updates |

---

## Next Steps

1. **Start with URL Shortener** - Practice explaining the design out loud
2. **Move to Booking System** - Apply caching + concurrency concepts
3. **Study one component per day** - Redis, then databases, then load balancers
4. **Mock interviews** - Practice with timer (45 min per question)

Remember: There's no single "correct" answer. Interviewers want to see **how you think**, not memorization.
