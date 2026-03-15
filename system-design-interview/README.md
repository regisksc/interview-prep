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

> **Priority: CRITICAL.** Structure is how the interviewer judges seniority before you've said a technical word.

A system design interview is not a trivia test. The interviewer wants to see _how you think_ under ambiguity, not whether you memorized the correct answer. There is no single correct answer.

### 1.1 The 45-Minute Structure

```
┌─────────────────────────────────────────────────────────┐
│ 0–5 min   │ Clarify requirements — ask, don't assume    │
│ 5–10 min  │ Estimate scale — DAU, QPS, storage          │
│ 10–20 min │ High-level design — boxes and arrows        │
│ 20–40 min │ Deep dive — pick 2–3 hardest components     │
│ 40–45 min │ Trade-offs, bottlenecks, what you'd change  │
└─────────────────────────────────────────────────────────┘
```

The most common mistake: jumping straight to a solution at minute 1. That signals junior behavior. Senior engineers gather requirements first.

---

### 1.2 Functional vs Non-Functional Requirements

**Functional requirements** = what the system _does_. These are features.

```
Example (design a ride-sharing app):
- Riders can request a ride
- Drivers can accept or reject rides
- Riders can track driver location in real-time
- Payment is processed after ride completion
```

**Non-functional requirements** = how well the system performs those features. These are quality attributes.

```
- 99.99% uptime (4 nines = ~52 minutes of downtime/year)
- < 100ms response for location updates
- Support 1 million concurrent users
- Data must not be lost (durability)
- Location data must never show wrong driver to wrong rider (consistency)
```

**What interviewers ask:**
> "What are your non-functional requirements?"

Model answer:
> "I'd want to clarify a few things — what's the expected DAU? Is this global or regional? For availability, I'd target 99.9% for core flows. Latency-wise, the location update needs to feel real-time so < 200ms. I'd also want to confirm whether we prioritize consistency or availability in case of network partition — for payments I'd say consistency, for location I'd accept slightly stale data in exchange for availability."

> **Senior signal:** Surfacing the CAP theorem trade-off in requirements (covered in Module 6) without being asked shows you understand the constraints _before_ designing.

---

### 1.3 Clarifying Questions That Actually Matter

Don't ask generic questions. Ask questions whose answers change the design.

| Question | Why it changes the design |
|----------|--------------------------|
| "How many daily active users?" | Determines if a single DB is enough or if you need sharding |
| "Read-heavy or write-heavy?" | Changes indexing, caching, and replication strategy |
| "Is eventual consistency acceptable?" | Determines if you can use NoSQL and async replication |
| "Do we need offline support?" | Completely changes the mobile client architecture |
| "What's the media type? User-generated video?" | Changes storage costs by orders of magnitude |
| "Do we need full-text search?" | Adds Elasticsearch or Algolia to the design |

---

### 1.4 Module 1 — Quick Fire

| Question | Answer |
|----------|--------|
| Functional vs non-functional? | Functional = what it does. Non-functional = how well it does it. |
| Why gather requirements before designing? | Different scale, consistency, and latency requirements change the entire architecture |
| What are "4 nines"? | 99.99% uptime = ~52 minutes of downtime per year |
| What's the first thing you say when the interview starts? | "Before I start designing, can I ask a few questions to clarify scope?" |

---

## Module 2: Back-of-Envelope Estimation

> **Priority: HIGH.** Interviewers explicitly ask "estimate the scale." Numbers anchor every decision.

You don't need precision. You need order of magnitude — is this a megabyte problem or a petabyte problem? Is this 100 QPS or 100,000 QPS? Those answers determine whether a single server works or you need a distributed system.

### 2.1 The Numbers You Must Know

```
Latency reference (know these cold):
  L1 cache: ~1 ns
  L2 cache: ~4 ns
  RAM:      ~100 ns
  SSD:      ~100 µs
  Network (same datacenter): ~500 µs
  Network (cross-continent): ~150 ms
  HDD seek: ~10 ms

Storage reference:
  1 KB  = 1,000 bytes    (a tweet)
  1 MB  = 1,000,000 bytes (a photo thumbnail)
  1 GB  = 10^9 bytes     (a movie)
  1 TB  = 10^12 bytes    (a large database)
  1 PB  = 10^15 bytes    (a data warehouse)

Time reference:
  1 day  = 86,400 seconds ≈ 10^5 seconds
  1 year = 31,536,000 seconds ≈ 3 × 10^7 seconds
```

### 2.2 The Estimation Framework

Work top-down: Users → Actions → QPS → Storage

**Step 1: DAU (Daily Active Users)**
```
"Instagram has ~500M DAU"
"A mid-sized app has ~10M DAU"
```

**Step 2: Actions per user per day**
```
"Each user sends 10 messages/day on average"
"Each user views 20 photos/day"
```

**Step 3: QPS (Queries Per Second)**
```
QPS = (DAU × actions per day) / seconds per day
    = (10M × 10) / 100,000
    = 1,000 QPS (read)

Write QPS is usually 10–100x lower than read QPS
```

**Step 4: Storage**
```
Storage per day = QPS × message size × seconds per day
               = 1,000 × 1KB × 86,400
               = 86.4 GB/day

Storage per year = 86.4 × 365 ≈ 31 TB/year
```

### 2.3 Worked Example: Design Instagram Stories

```
Assumptions:
  DAU: 500M
  Stories viewed per user per day: 20
  Stories created per user per day: 0.1 (1 in 10 users posts daily)
  Story size (video, 15 sec): 5 MB

Read QPS:
  500M × 20 / 100,000 = 100,000 QPS (reads)

Write QPS:
  500M × 0.1 / 100,000 = 500 QPS (writes)
  → Clearly read-heavy → caching will be critical

Storage:
  500 QPS × 5 MB × 86,400 sec = 216 TB/day
  → Object storage (S3-like), not a regular database
  → CDN is mandatory — you can't serve 216 TB/day from a single origin
```

> **Senior signal:** Deriving "this is read-heavy" from your own estimation and immediately connecting it to "so caching is critical" shows you understand the implication of numbers, not just the math.

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

### 3.5 Indexes — What They Are Physically

An **index** is a separate data structure that the database maintains alongside your table, designed to make specific queries fast.

The most common index type is a **B-tree** (balanced tree). Think of it like a book's index in the back: instead of reading every page to find "Redis," you look up R in the index and get the page number.

```
B-Tree index on users.email:
                    [M]
                   /   \
              [D–L]     [N–Z]
             /     \        \
          [D–G]  [H–L]    [N–R]
           ...     ...      ...
                    │
              [hash@b.com, row_ptr]
              [hello@x.com, row_ptr]
              [hi@y.com, row_ptr]
```

Each leaf node holds the indexed value and a pointer to the actual row on disk. To find `email = 'hash@b.com'`, the database traverses the tree in O(log n) instead of scanning all rows in O(n).

#### Creating an Index

```sql
-- Single-column index
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Composite index (column order matters!)
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
```

#### Composite Index Column Order — Why It Matters

A composite index `(user_id, status)` is efficient for:
- Queries filtering on `user_id` alone
- Queries filtering on `user_id` AND `status`

But **not** efficient for:
- Queries filtering on `status` alone (index can't be used from the middle)

Think of a phone book sorted by (last name, first name). You can quickly find "Smith, John." You can find all Smiths. But you cannot quickly find all "Johns" — because "John" is the second sort key.

```sql
-- Uses the index (prefix match):
SELECT * FROM orders WHERE user_id = '...' AND status = 'pending';
SELECT * FROM orders WHERE user_id = '...';

-- Does NOT use the index (starts from second column):
SELECT * FROM orders WHERE status = 'pending';
```

#### Index Trade-offs

| | Fast reads | Slow writes | Extra storage |
|--|-----|-------|-------|
| No index | ✗ (full scan) | ✓ (no overhead) | ✓ (minimal) |
| Index | ✓ | ✗ (must update index too) | ✗ (significant) |

For every INSERT, UPDATE, or DELETE, the database must also update every index on that table. A table with 10 indexes has 10x the write overhead compared to a table with no indexes.

> **What interviewers ask:** "How would you optimize a slow query?"
> Model answer: "First I'd look at the query plan (`EXPLAIN ANALYZE` in PostgreSQL) to see if it's doing a full table scan. If so, I'd add an index on the filter columns, paying attention to column order for composites. I'd also check if the query could be rewritten to use an existing index."

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

> **Priority: HIGH.** Appears in every system design. The question is not "should I cache" but "what, where, and for how long."

### 4.1 Why Caching Exists

A database query on a cold disk takes ~10ms. The same data from Redis (in-memory) takes ~0.1ms. Caching exploits the fact that most systems read the same data repeatedly, but write it rarely.

The fundamental trade-off: **freshness vs speed**. A cache serves stale data. How stale is acceptable depends on the use case.

```
User profile photo:     stale for minutes is fine
Stock ticker price:     stale for seconds is unacceptable
Live sports score:      stale for 1 second is acceptable
Bank balance:           never stale
```

---

### 4.2 Cache-Aside (Lazy Loading)

The most common pattern. The application code manages the cache.

```
Read flow:
  1. App checks cache for key
  2a. Cache HIT  → return cached value
  2b. Cache MISS → query database → store result in cache → return value

Write flow:
  1. Write to database
  2. Invalidate (delete) the cache entry
     (don't write to cache — write the DB first, let next read repopulate)
```

```
Client ──► Cache? ──HIT──► return
              │
             MISS
              │
              ▼
           Database ──► set cache ──► return
```

**Pros:** Cache only contains data that's actually been requested. Database is the source of truth.
**Cons:** First request after cache expiry is slow (cache miss penalty). If cache is flushed, thundering herd (see 4.5).

---

### 4.3 Write-Through

Every write to the database is also written to the cache simultaneously.

```
Write:
  1. Write to database
  2. Write same data to cache

Read:
  1. Always hits cache (data was already put there on write)
```

**Pros:** Cache is always fresh. No cold-start problem.
**Cons:** Write latency is higher (two writes per operation). Cache fills up with data that may never be read.

---

### 4.4 Write-Back (Write-Behind)

Write to the cache first, acknowledge success to the client, then asynchronously flush to the database.

```
Write:
  1. Write to cache
  2. Return success to client immediately
  3. [async] Flush cache → database every N seconds

Risk: If cache server dies before flush, data is lost
```

**Pros:** Extremely fast writes.
**Cons:** Risk of data loss. Rarely used outside of write-heavy, loss-tolerant systems (analytics, logs).

---

### 4.5 Eviction Policies

When the cache is full and a new item needs to be cached, something must be evicted.

**LRU (Least Recently Used):** Evict the item that was accessed least recently. Good general-purpose choice — assumes recently used data will be used again.

**LFU (Least Frequently Used):** Evict the item that was accessed fewest times overall. Better for data with wildly different popularity (e.g., a viral post vs. a 5-year-old post). More complex to implement.

**FIFO:** Evict the oldest item, regardless of access pattern. Simple but poor hit rate.

Redis uses an approximation of LRU by default and supports LFU as a policy option.

---

### 4.6 Cache Stampede (Thundering Herd)

Imagine a cached item with a 10-minute TTL that 10,000 users request per minute. When it expires, 10,000 requests arrive simultaneously, all get a cache miss, all query the database at once, and the DB is crushed.

**Solutions:**

1. **Mutex/lock:** When a cache miss happens, acquire a lock. One request fetches from DB and repopulates the cache. Others wait. The lock prevents concurrent DB queries.

2. **Probabilistic early expiration:** Before the TTL expires, randomly decide to refresh it — so the cache is refreshed in the background before it becomes stale. No stampede.

3. **Cache warming:** Pre-populate cache before TTL expires using a background job.

---

### 4.7 CDN — Content Delivery Network

A CDN is a geographically distributed network of cache servers. When a user in Brazil requests a video stored on a server in Virginia, without a CDN they wait for the full round-trip (~150ms). With a CDN, the video is cached on a server in São Paulo and served from there (~20ms).

```
Without CDN:
  User (Brazil) ──150ms──► Origin Server (Virginia) ──150ms──► User

With CDN:
  User (Brazil) ──20ms──► CDN Edge (São Paulo) ──► User
                               (cached from origin on first request)
```

CDNs are primarily for **static assets**: images, videos, JS bundles, CSS, fonts. For dynamic API responses, CDN is less useful (though some CDNs support it with short TTLs).

For mobile apps specifically: every image you show should go through a CDN. Direct origin serving at scale is a cost and latency disaster.

---

### 4.8 Module 4 — Quick Fire

| Question | Answer |
|----------|--------|
| Cache-aside vs write-through? | Cache-aside: app manages cache on read. Write-through: every write populates cache |
| What is cache stampede? | Multiple requests hitting DB simultaneously when a cached item expires |
| LRU vs LFU? | LRU evicts least recently accessed. LFU evicts least frequently accessed |
| What is TTL? | Time-To-Live — how long a cache entry lives before expiring |
| When is write-back dangerous? | Data loss risk if cache dies before async flush to DB |
| What is a CDN? | Geographically distributed cache servers for static assets |

---

## Module 5: APIs & Communication Patterns

> **Priority: HIGH.** You use REST daily — this module covers what you likely don't know.

### 5.1 REST — What Makes a Good API

**Idempotency** is the most important REST concept for interviews. An operation is **idempotent** if calling it multiple times has the same effect as calling it once.

```
GET /users/123          → Idempotent (reading doesn't change state)
PUT /users/123 {name:"Bob"} → Idempotent (setting to same value)
DELETE /users/123       → Idempotent (deleting twice = same result)
POST /orders            → NOT idempotent (creates new order each time)
```

Why it matters: On mobile, a network request might time out without you knowing if the server processed it. Retrying a `POST /orders` could create duplicate orders. Solution: **idempotency keys**.

```http
POST /orders
Idempotency-Key: uuid-4c2f-abc1-...

{ "product_id": "...", "quantity": 1 }
```

The server stores the key and response. If the same key comes again, it returns the cached response without creating a duplicate order.

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
