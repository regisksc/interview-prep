# System Design Exercises (50+ Scenarios)

Progressive difficulty exercises for system design interview preparation.

---

## Level 1 - Very Easy (10 exercises)

### Exercise 1: Design a Counter

**Time**: 10 min | **Difficulty**: 1

**Problem**: Design an API that returns incrementing numbers.

**Requirements**:
- `GET /counter` returns `{count: 1}`, then `{count: 2}`, etc.
- Must work correctly with multiple server instances

**Questions to Answer**:
1. Where do you store the count?
2. What happens if two requests arrive at the exact same time?
3. How do you ensure no numbers are skipped?

**Starter Template**:
```
API Endpoint:
  GET /counter
  → {count: ___}

Storage Options:
  □ In-memory variable
  □ Database table
  □ Redis
  □ Other: _____

Concurrency Handling:
  □ No handling needed
  □ Database transaction
  □ Redis atomic operation
  □ Distributed lock
```

<details>
<summary>Solution Approach</summary>

```
Problem with in-memory:
  Server 1: count = 5
  Server 2: count = 3
  → Different servers have different counts!

Solution: Redis INCR (atomic)
  Key: counter:global
  Operation: INCR counter:global
  → Returns: 1, 2, 3, 4, ...
  → Atomic: only one request processed at a time

API:
  GET /counter
  → Redis: INCR counter:global → 42
  → Return: {count: 42}

Alternative: Database with transaction
  BEGIN;
  SELECT count FROM counters WHERE name='global';
  UPDATE counters SET count = count + 1;
  COMMIT;
  → Slower but durable
```

</details>

---

### Exercise 2: Design a URL Shortener (TinyURL)

**Time**: 15 min | **Difficulty**: 1

**Problem**: Build a service like bit.ly that shortens long URLs.

**Requirements**:
- Given a long URL, generate a short code (e.g., `bit.ly/abc123`)
- Redirect to original URL when short URL is visited
- Track click count for each URL

**Questions to Answer**:
1. How do you generate the short code?
2. What's your database schema?
3. How do you handle two people shortening the same URL?

**Starter Template**:
```
API Endpoints:
  POST /shorten
  Request: {url: "https://very-long-url.com/..."}
  Response: {short_code: "___", short_url: "___"}

  GET /{short_code}
  → Redirect to original URL

Database Schema:
  Table: urls
  Columns: _____

Short Code Generation:
  □ Hash URL (MD5/SHA) → take first N chars
  □ Auto-increment ID → base62 encode
  □ Random string generation
  □ Other: _____
```

<details>
<summary>Solution Approach</summary>

```
Short Code Generation Options:

1. Hash-based (MD5 → first 6 chars)
   MD5("https://example.com") = "a1b2c3d4..."
   → Short code: "a1b2c3"
   Pros: Deterministic (same URL = same code)
   Cons: Collisions possible with short codes

2. Auto-increment + Base62
   ID: 1 → "a", ID: 62 → "10", ID: 1000 → "g8"
   Pros: Guaranteed unique, no collisions
   Cons: Predictable (can guess other IDs)

3. Random string with uniqueness check
   Generate: random_string(6)
   Check: EXISTS in DB?
   If exists: regenerate
   Pros: Unpredictable
   Cons: May need multiple attempts

Database Schema:
  CREATE TABLE urls (
    id          BIGINT PRIMARY KEY,
    short_code  VARCHAR(10) UNIQUE NOT NULL,
    long_url    TEXT NOT NULL,
    click_count BIGINT DEFAULT 0,
    created_at  TIMESTAMP DEFAULT NOW(),
    user_id     BIGINT,  -- if logged-in users
    INDEX idx_short_code (short_code)
  );

API Implementation:
  POST /shorten
  1. Check if URL already exists: SELECT short_code WHERE long_url = ?
  2. If exists: return existing short_code
  3. If not: generate new short_code, INSERT
  4. Return: {short_code, short_url}

  GET /{short_code}
  1. Lookup: SELECT long_url WHERE short_code = ?
  2. If found: INCREMENT click_count (async)
  3. Redirect: HTTP 301 → long_url
```

</details>

---

### Exercise 3: Design a Rate Limiter

**Time**: 15 min | **Difficulty**: 2

**Problem**: Limit users to 100 API requests per minute.

**Requirements**:
- Each user has a quota of 100 requests/minute
- Return 429 error when limit exceeded
- Must work across multiple servers

**Questions to Answer**:
1. Where do you track request counts?
2. How do you handle the "per minute" window?
3. What happens at exactly 100 requests?

**Starter Template**:
```
API Response (when limit exceeded):
  HTTP 429 Too Many Requests
  {
    error: "rate_limit_exceeded",
    retry_after: ___ seconds
  }

Storage Design:
  Key format: _____
  Value: _____
  TTL: _____

Algorithm Options:
  □ Fixed window counter
  □ Sliding window
  □ Token bucket
  □ Leaky bucket
```

<details>
<summary>Solution Approach</summary>

```
Algorithm: Sliding Window with Redis

Key Design:
  Key: rate_limit:{user_id}
  Value: request_count (integer)
  TTL: 60 seconds (1 minute)

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

Problem with fixed window:
  [Minute 1] [Minute 2]
     100 reqs   100 reqs
  → User could make 200 requests in 1 second!

Solution: Sliding window
  Track timestamps of recent requests
  Count requests in last 60 seconds
  More accurate but more storage

Alternative: Token Bucket
  Bucket holds 100 tokens
  Each request consumes 1 token
  Tokens refill at 100/minute rate
  Allows bursting but rate-limited overall

Redis + Lua Script (atomic):
  local key = "rate:" .. KEYS[1]
  local limit = tonumber(ARGV[1])
  local window = tonumber(ARGV[2])

  local current = redis.call('INCR', key)
  if current == 1 then
    redis.call('EXPIRE', key, window)
  end

  if current > limit then
    return 0  # Rate limited
  else
    return 1  # OK
  end
```

</details>

---

### Exercise 4: Design a Pastebin

**Time**: 20 min | **Difficulty**: 2

**Problem**: Build a service where users can paste text and get a shareable URL.

**Requirements**:
- Users paste text, get a unique URL
- Anyone with URL can view the paste
- Optional: expire after time, password protection
- Handle large pastes (up to 1MB)

**Questions to Answer**:
1. How do you store the paste content?
2. How do you generate unique IDs?
3. How do you handle expiry?

<details>
<summary>Solution Approach</summary>

```
Database Schema:
  CREATE TABLE pastes (
    id          VARCHAR(20) PRIMARY KEY,
    content     TEXT NOT NULL,  -- or store in S3 if large
    content_type VARCHAR(50) DEFAULT 'text/plain',
    created_at  TIMESTAMP DEFAULT NOW(),
    expires_at  TIMESTAMP,
    password_hash VARCHAR(255),  -- if password protected
    view_count  BIGINT DEFAULT 0,
    is_public   BOOLEAN DEFAULT true
  );

API Design:
  POST /pastes
  Request: {
    content: "text here...",
    expires_in: 3600,  // optional, seconds
    password: "secret123"  // optional
  }
  Response: {
    id: "abc123",
    url: "https://pastebin.com/abc123",
    expires_at: "2026-03-13T14:00:00Z"
  }

  GET /pastes/{id}
  → Returns content (or 404 if expired)

  POST /pastes/{id}/view  // optional, track views
  → Increments view_count

ID Generation:
  - NanoID or UUID (shortened)
  - Base62 encode of auto-increment
  - Random string with uniqueness check

Expiry Handling:
  Option 1: Lazy deletion
    - Check expires_at on read
    - Return 404 if expired
    - Background job deletes old pastes

  Option 2: Redis TTL
    - Store in Redis with TTL
    - Auto-deletes when expired
    - Periodic sync to DB for persistence

Storage for large pastes:
  - Store content in S3/GCS
  - Store metadata in DB
  - S3 key: pastes/{id}/content
```

</details>

---

### Exercise 5: Design a Key-Value Store API

**Time**: 15 min | **Difficulty**: 2

**Problem**: Build a simple key-value storage API.

**Requirements**:
- Store string values with string keys
- Support get, set, delete operations
- Optional: TTL for keys

**Starter Template**:
```
API Endpoints:
  PUT   /kv/{key}      → Set value
  GET   /kv/{key}      → Get value
  DELETE /kv/{key}     → Delete key
  GET   /kv/{key}/ttl  → Get remaining TTL
```

<details>
<summary>Solution Approach</summary>

```
Storage Options:

1. In-memory (single server)
   - HashMap<String, Value>
   - Fast but not persistent
   - Lost on restart

2. Redis
   - SET key value
   - GET key
   - DEL key
   - EXPIRE key seconds
   - Persistent (with AOF/RDB)
   - Handles TTL natively

3. Database
   - CREATE TABLE kv_store (key PRIMARY KEY, value, expires_at)
   - Slower but ACID guarantees

API Implementation:

  PUT /kv/{key}
  Request: {value: "hello", ttl: 3600}  // ttl optional
  Redis:
    SET key value
    If ttl: EXPIRE key ttl
  Response: {success: true}

  GET /kv/{key}
  Redis: GET key
  Response: {value: "hello", found: true}
  Or: {found: false}  // key doesn't exist

  DELETE /kv/{key}
  Redis: DEL key
  Response: {success: true}

Handling Concurrent Writes:
  - Last write wins (simple)
  - Version numbers (optimistic locking)
    SET key value VERSION 5
    → Only updates if current version is 4
```

</details>

---

### Exercise 6: Design a User Profile Service

**Time**: 20 min | **Difficulty**: 2

**Problem**: Design a service to store and retrieve user profiles.

**Requirements**:
- Store user info (name, email, avatar, bio, etc.)
- Fast profile reads
- Profile updates should be eventually consistent
- Cache frequently accessed profiles

**Starter Template**:
```
User Profile Data:
  - id: UUID
  - email: string
  - name: string
  - avatar_url: string
  - bio: string (max 500 chars)
  - created_at: timestamp
  - updated_at: timestamp

API:
  GET  /users/{id}/profile
  PUT  /users/{id}/profile
```

<details>
<summary>Solution Approach</summary>

```
Database Schema:
  CREATE TABLE user_profiles (
    id          UUID PRIMARY KEY,
    email       VARCHAR(255) UNIQUE NOT NULL,
    name        VARCHAR(100),
    avatar_url  VARCHAR(500),
    bio         VARCHAR(500),
    created_at  TIMESTAMP DEFAULT NOW(),
    updated_at  TIMESTAMP DEFAULT NOW()
  );

Cache Strategy (Cache-Aside):

  READ (GET /users/{id}/profile):
    1. Check Redis: GET profile:{id}
    2. If found: return cached data
    3. If not found:
       - Read from DB: SELECT * FROM user_profiles WHERE id = ?
       - Cache it: SET profile:{id} json_data EX 3600
       - Return data

  WRITE (PUT /users/{id}/profile):
    1. Update DB: UPDATE user_profiles SET ... WHERE id = ?
    2. Invalidate cache: DEL profile:{id}
    3. Next read will repopulate cache

Cache Invalidation Strategies:

  1. Delete on write (simple)
     - DEL profile:{id} after update
     - Next read repopulates

  2. Write-through
     - Update both DB and cache atomically
     - Risk: cache write fails

  3. TTL-based
     - Set 1-hour TTL on all profiles
     - Eventually consistent

Handling Avatar Uploads:
  1. Generate presigned S3 URL
  2. User uploads directly to S3
  3. Update avatar_url in profile
  4. Invalidate cache
```

</details>

---

### Exercise 7: Design a View Counter

**Time**: 15 min | **Difficulty**: 2

**Problem**: Track view counts for articles/products (like "1.2M views").

**Requirements**:
- Increment count on each view
- Display count (can be slightly stale)
- Handle high write volume (viral content)

**Questions to Answer**:
1. Why not update database on every view?
2. How do you persist counts?
3. How do you handle viral spikes?

<details>
<summary>Solution Approach</summary>

```
Problem with direct DB updates:
  10,000 views/second = 10,000 UPDATE queries/second
  → Database overload
  → Slow response times

Solution: Buffer writes in Redis

  INCR view_count:article_123
  → Fast, in-memory
  → Atomic operation

Periodic Persistence (every 30 seconds):
  Cron job:
    FOR each article:
      count = GET view_count:article_{id}
      UPDATE articles SET views = views + count WHERE id = {id}
      DEL view_count:article_{id}

Handling Viral Content:
  1. Shard by article ID
     Redis cluster: article_123 → shard based on hash
     Distributes load across nodes

  2. Batch updates
     Instead of per-article, batch 1000 articles at once

  3. Leaderboard for trending
     Use Redis ZSET for real-time trending:
     ZADD trending:articles score article_id

Display Format:
  if count < 1000: "999 views"
  elif count < 1000000: "{count/1000}K views"
  else: "{count/1000000}M views"
```

</details>

---

### Exercise 8: Design a Session Store

**Time**: 15 min | **Difficulty**: 2

**Problem**: Store user session data (login state, cart, preferences).

**Requirements**:
- Sessions expire after 30 days of inactivity
- Access session data on every request
- Support logout (delete session)

<details>
<summary>Solution Approach</summary>

```
Session Data:
  {
    user_id: "user_123",
    email: "user@example.com",
    roles: ["user"],
    cart_items: [1, 2, 3],
    last_activity: 1234567890
  }

Storage: Redis (fast + TTL support)

Key Design:
  Key: session:{session_token}
  Value: JSON session data
  TTL: 30 days (2592000 seconds)

Flow:

  Login:
    1. Validate credentials
    2. Generate session token: random_string(32)
    3. Store in Redis:
       SET session:{token} session_json EX 2592000
    4. Set cookie: Set-Cookie: session={token}; HttpOnly; Secure

  Every Request:
    1. Read cookie: session={token}
    2. Get session: GET session:{token}
    3. If exists: attach user to request
    4. Refresh TTL: EXPIRE session:{token} 2592000

  Logout:
    1. DEL session:{token}
    2. Clear cookie

Security Considerations:
  - Use cryptographically secure random tokens
  - Set HttpOnly flag (prevent XSS access)
  - Set Secure flag (HTTPS only)
  - Consider SameSite=Strict
```

</details>

---

### Exercise 9: Design a Feature Flag Service

**Time**: 20 min | **Difficulty**: 2

**Problem**: Build a system to toggle features without deploying code.

**Requirements**:
- Enable/disable features dynamically
- Target specific users or percentages
- Fast flag checks (on every request)

<details>
<summary>Solution Approach</summary>

```
Feature Flag Model:
  {
    flag_key: "new_checkout_flow",
    enabled: true,
    rules: [
      {type: "user_id", values: ["u1", "u2"]},  // Specific users
      {type: "percentage", value: 10}  // 10% of users
    ]
  }

API:
  GET /flags/{flag_key}
  → Returns flag state for current user

  PUT /flags/{flag_key}  // Admin only
  → Update flag configuration

Storage:
  - Database: source of truth
  - Redis: cached flag configurations
  - CDN: for client-side SDKs

Flag Evaluation Logic:

  def evaluate_flag(flag, user):
    if not flag.enabled:
      return False

    # Check user-specific rules
    for rule in flag.rules:
      if rule.type == "user_id":
        if user.id in rule.values:
          return True
      elif rule.type == "percentage":
        # Consistent hashing: same user always gets same result
        hash = md5(flag.key + user.id)
        if hash % 100 < rule.value:
          return True

    return False

Client SDK:
  - Fetch all flags on app start
  - Cache locally for 5 minutes
  - Fallback to default if service unavailable
```

</details>

---

### Exercise 10: Design a Health Check Endpoint

**Time**: 10 min | **Difficulty**: 1

**Problem**: Build a health check system to monitor service status.

**Requirements**:
- Return service status (healthy/unhealthy)
- Check database connectivity
- Check cache connectivity
- Include version info

<details>
<summary>Solution Approach</summary>

```
API Endpoint:
  GET /health

Response (healthy):
  {
    status: "healthy",
    version: "1.2.3",
    uptime_seconds: 86400,
    checks: {
      database: "ok",
      cache: "ok",
      external_api: "ok"
    }
  }

Response (unhealthy):
  {
    status: "unhealthy",
    version: "1.2.3",
    checks: {
      database: "error: connection refused",
      cache: "ok"
    }
  }

Implementation:

  async function healthCheck():
    checks = {}
    overall = "healthy"

    try:
      await db.query("SELECT 1")
      checks.database = "ok"
    except e:
      checks.database = "error: " + e.message
      overall = "unhealthy"

    try:
      await redis.ping()
      checks.cache = "ok"
    except e:
      checks.cache = "error: " + e.message
      overall = "unhealthy"

    return {
      status: overall,
      version: process.env.VERSION,
      uptime: process.uptime(),
      checks: checks
    }

Load Balancer Integration:
  - LB polls /health every 10 seconds
  - If unhealthy: stop sending traffic
  - If healthy again: resume traffic
```

</details>

---

## Level 2 - Easy (10 exercises)

### Exercise 11: Design a Notification Service

**Time**: 25 min | **Difficulty**: 2

**Problem**: Send notifications via email, SMS, and push.

**Requirements**:
- Queue notifications for delivery
- Retry failed deliveries
- Track delivery status

**Starter Template**:
```
API:
  POST /notifications
  Request: {
    user_id: "user_123",
    type: "email" | "sms" | "push",
    subject: string,
    body: string
  }

Database:
  Table: notifications
  Columns: _____
```

<details>
<summary>Solution Approach</summary>

```
Database Schema:
  CREATE TABLE notifications (
    id          UUID PRIMARY KEY,
    user_id     UUID NOT NULL,
    type        VARCHAR(20) NOT NULL,
    subject     VARCHAR(255),
    body        TEXT NOT NULL,
    status      VARCHAR(20) DEFAULT 'pending',
              -- pending, sent, failed, retrying
    retry_count INTEGER DEFAULT 0,
    created_at  TIMESTAMP DEFAULT NOW(),
    sent_at     TIMESTAMP,
    error       TEXT
  );

Architecture:
  ┌──────────┐     ┌──────────┐     ┌──────────┐
  │   API    │────►│  Queue   │────►│  Worker  │
  │  Server  │     │ (SQS/Kafka)    │          │
  └──────────┘     └──────────┘     └────┬─────┘
                                         │
                              ┌──────────┼──────────┐
                              ▼          ▼          ▼
                         ┌────────┐ ┌────────┐ ┌────────┐
                         │ Email  │ │  SMS   │ │  Push  │
                         │ (SES)  │ │ (Twilio)│ │(FCM/APN)│
                         └────────┘ └────────┘ └────────┘

Flow:
  1. API receives notification request
  2. Save to DB (status: pending)
  3. Publish to queue
  4. Worker picks up message
  5. Send via provider
  6. Update status (sent/failed)

Retry Logic:
  Max retries: 3
  Backoff: exponential (1min, 5min, 15min)

  if send_fails:
    if retry_count < 3:
      retry_count++
      delay = 60 * (2 ^ retry_count)
      schedule_retry(delay)
    else:
      status = 'failed'
```

</details>

---

### Exercise 12: Design an Image Thumbnail Service

**Time**: 25 min | **Difficulty**: 2

**Problem**: Generate and serve thumbnails for uploaded images.

**Requirements**:
- Accept image uploads
- Generate multiple sizes (thumb, medium, large)
- Serve from CDN

<details>
<summary>Solution Approach</summary>

```
Upload Flow:
  1. User uploads image to /upload
  2. Server generates presigned S3 URL
  3. User uploads directly to S3 (originals bucket)
  4. S3 event triggers Lambda
  5. Lambda generates thumbnails
  6. Thumbnails saved to S3 (thumbnails bucket)
  7. CDN caches thumbnails

S3 Structure:
  originals/
    user_123/
      photo_001.jpg
  thumbnails/
    user_123/
      photo_001_thumb.jpg   (100x100)
      photo_001_medium.jpg  (400x400)
      photo_001_large.jpg   (800x800)

CDN URLs:
  https://cdn.example.com/user_123/photo_001_thumb.jpg

Lazy Generation:
  - Generate on first request
  - Cache result
  - Return cached version subsequently
```

</details>

---

### Exercise 13: Design a File Upload Service

**Time**: 25 min | **Difficulty**: 2

**Problem**: Allow users to upload files (documents, images).

**Requirements**:
- Support files up to 100MB
- Validate file types
- Generate download URLs
- Optional: virus scan uploads

<details>
<summary>Solution Approach</summary>

```
API Flow:
  POST /uploads/initiate
  Request: {filename: "doc.pdf", size: 1048576, content_type: "application/pdf"}
  Response: {upload_url: "https://s3-presigned...", file_id: "file_123"}

  PUT {upload_url}  (direct to S3)
  → User uploads directly

  POST /uploads/{file_id}/complete
  → Server verifies upload, triggers virus scan

Database:
  CREATE TABLE files (
    id          UUID PRIMARY KEY,
    user_id     UUID NOT NULL,
    filename    VARCHAR(255),
    size        BIGINT,
    content_type VARCHAR(100),
    s3_key      VARCHAR(500),
    status      VARCHAR(20),  -- uploading, scanning, ready, infected
    created_at  TIMESTAMP
  );

Virus Scan:
  - Upload triggers Lambda
  - Lambda calls ClamAV or VirusTotal API
  - Update status based on result
  - If infected: delete file, notify user
```

</details>

---

### Exercise 14: Design a Like/Reaction System

**Time**: 20 min | **Difficulty**: 2

**Problem**: Users can like/react to posts (Facebook-style reactions).

**Requirements**:
- Support multiple reactions (like, love, haha, sad, angry)
- Show total count and breakdown
- Users can change their reaction

<details>
<summary>Solution Approach</summary>

```
Database Schema:
  CREATE TABLE reactions (
    id          UUID PRIMARY KEY,
    user_id     UUID NOT NULL,
    post_id     UUID NOT NULL,
    type        VARCHAR(20) NOT NULL,  -- like, love, haha, sad, angry
    created_at  TIMESTAMP DEFAULT NOW(),
    updated_at  TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, post_id)  -- One reaction per user per post
  );

API:
  PUT /posts/{post_id}/reactions
  Request: {type: "love"}
  → Creates or updates user's reaction

  DELETE /posts/{post_id}/reactions
  → Removes user's reaction

  GET /posts/{post_id}/reactions
  Response: {
    total: 142,
    breakdown: {
      like: 100,
      love: 30,
      haha: 10,
      sad: 1,
      angry: 1
    },
    user_reaction: "love"  // current user's reaction
  }

Optimization - Cache counts:
  Redis: post:123:reactions → {"like": 100, "love": 30, ...}

  On reaction:
    HINCRBY post:123:reactions love 1
    HINCRBY post:123:reactions like -1  // if changing
```

</details>

---

### Exercise 15: Design a Comment System

**Time**: 25 min | **Difficulty**: 3

**Problem**: Build a nested comment system (like Reddit).

**Requirements**:
- Users can reply to comments (nested threads)
- Support upvotes/downvotes
- Sort by best/top/newest

<details>
<summary>Solution Approach</summary>

```
Database Schema (Adjacency List):
  CREATE TABLE comments (
    id          UUID PRIMARY KEY,
    post_id     UUID NOT NULL,
    user_id     UUID NOT NULL,
    parent_id   UUID,  -- NULL for top-level comments
    content     TEXT NOT NULL,
    score       INTEGER DEFAULT 0,  -- upvotes - downvotes
    depth       INTEGER DEFAULT 0,
    path        VARCHAR(500),  -- for sorting: /root/child/grandchild
    created_at  TIMESTAMP DEFAULT NOW()
  );

API:
  GET /posts/{post_id}/comments?sort=best
  → Returns nested comments

  POST /posts/{post_id}/comments
  Request: {content: "...", parent_id: "optional"}

  POST /comments/{id}/vote
  Request: {direction: 1 | -1}

Frontend Rendering:
  - Flat list with depth indent
  - Or actual tree structure

Sorting:
  - best: score / log(age)  (Reddit algorithm)
  - top: score only
  - newest: created_at DESC
```

</details>

---

## Level 3 - Intermediate (10 exercises)

### Exercise 16: Design a Booking System (Full)

**Time**: 45 min | **Difficulty**: 3

**Problem**: Complete appointment booking system (extended from basics).

**Requirements**:
- Search providers by specialty, location, insurance
- View availability with real-time updates
- Book with 5-minute hold
- Handle cancellations and waitlist

See `01-booking-system/README.md` for the complete deep-dive.

---

### Exercise 17: Design a Food Delivery System

**Time**: 30 min | **Difficulty**: 3

**Problem**: Design UberEats/DoorDash clone.

**Requirements**:
- Browse restaurants and menus
- Add items to cart, place order
- Track delivery in real-time
- Driver assignment algorithm

<details>
<summary>Solution Approach</summary>

```
Core Entities:
  - User (customer)
  - Restaurant
  - MenuItem
  - Order
  - Driver
  - Delivery

Database Schema:
  CREATE TABLE orders (
    id              UUID PRIMARY KEY,
    user_id         UUID NOT NULL,
    restaurant_id   UUID NOT NULL,
    driver_id       UUID,
    status          VARCHAR(20),
                  -- pending, confirmed, preparing,
                  -- pickup, delivery, completed, cancelled
    total_amount    DECIMAL(10,2),
    delivery_address JSONB,
    created_at      TIMESTAMP,
    estimated_delivery TIMESTAMP
  );

Order Flow:
  1. User places order → status: pending
  2. Restaurant accepts → status: confirmed
  3. Restaurant marks ready → status: pickup
  4. Driver picks up → status: delivery
  5. Driver delivers → status: completed

Driver Matching:
  - Find drivers within 5km of restaurant
  - Rank by: distance, rating, current load
  - Assign best match
  - Timeout after 30 seconds, try next

Real-time Tracking:
  - Driver app sends location every 5 seconds
  - WebSocket to customer app
  - Show on map with ETA calculation
```

</details>

---

### Exercise 18: Design a Ride-Sharing System

**Time**: 30 min | **Difficulty**: 3

**Problem**: Design Uber/Lyft clone.

**Requirements**:
- Request ride with pickup/dropoff
- Price calculation (distance, time, surge)
- Driver matching
- Real-time tracking

<details>
<summary>Surge Pricing Logic</summary>

```
Base Price:
  base_fare + (rate_per_km × distance) + (rate_per_min × time)

Surge Multiplier:
  - Count ride requests in area (last 5 min)
  - Count available drivers in area
  - Ratio = requests / drivers

  if ratio > 2: surge = 1.5
  if ratio > 3: surge = 2.0
  if ratio > 5: surge = 2.5

Final Price:
  base_price × surge_multiplier
```

</details>

---

### Exercise 19: Design a Hotel Booking System

**Time**: 30 min | **Difficulty**: 3

**Problem**: Design Booking.com/Hotels.com clone.

**Requirements**:
- Search hotels by location, dates, guests
- Room availability with date ranges
- Booking with hold period
- Dynamic pricing

---

### Exercise 20: Design an E-commerce Cart

**Time**: 25 min | **Difficulty**: 3

**Problem**: Shopping cart for e-commerce site.

**Requirements**:
- Add/remove items
- Persist cart across sessions
- Handle inventory changes
- Apply discount codes

<details>
<summary>Solution Approach</summary>

```
Storage Strategy:
  - Logged-out users: localStorage or Redis (anonymous session)
  - Logged-in users: Database (persists across devices)

Database Schema:
  CREATE TABLE cart_items (
    id          UUID PRIMARY KEY,
    user_id     UUID,
    session_id  VARCHAR(100),  -- for anonymous users
    product_id  UUID NOT NULL,
    quantity    INTEGER NOT NULL,
    added_at    TIMESTAMP DEFAULT NOW()
  );

Inventory Check:
  - On add to cart: check availability
  - On checkout: reserve inventory (hold for 10 min)
  - TTL-based release if not purchased

Discount Codes:
  CREATE TABLE discount_codes (
    code        VARCHAR(50) PRIMARY KEY,
    type        VARCHAR(20),  -- percentage, fixed
    value       DECIMAL(10,2),
    min_order   DECIMAL(10,2),
    max_uses    INTEGER,
    current_uses INTEGER DEFAULT 0,
    expires_at  TIMESTAMP
  );
```

</details>

---

## Level 4 - Hard (10 exercises)

### Exercise 21: Design Twitter/X

**Time**: 45 min | **Difficulty**: 4

**Requirements**:
- Post short messages (tweets)
- Follow/unfollow users
- Home timeline (tweets from followed users)
- Hashtags, mentions
- Trends

---

### Exercise 22: Design Instagram

**Time**: 45 min | **Difficulty**: 4

**Requirements**:
- Photo/video posts
- Stories (expire after 24 hours)
- Feed algorithm
- Direct messaging

---

### Exercise 23: Design YouTube

**Time**: 45 min | **Difficulty**: 4

**Requirements**:
- Video upload and transcoding
- Streaming at multiple qualities
- Recommendations
- Comments and likes

---

### Exercise 24: Design WhatsApp

**Time**: 45 min | **Difficulty**: 4

**Requirements**:
- End-to-end encrypted messaging
- Group chats
- Read receipts
- Media sharing
- Voice/video calls

---

### Exercise 25: Design Netflix

**Time**: 45 min | **Difficulty**: 4

**Requirements**:
- Video streaming (CDN)
- Personalized recommendations
- Watch history sync across devices
- Offline downloads

---

## Level 5 - Expert (10 exercises)

### Exercise 26: Design Google Search

**Time**: 60 min | **Difficulty**: 5

**Requirements**:
- Web crawling
- Indexing
- PageRank algorithm
- Query processing
- Autocomplete

---

### Exercise 27: Design Google Drive

**Time**: 60 min | **Difficulty**: 5

**Requirements**:
- File sync across devices
- Version history
- Collaborative editing
- Sharing and permissions

---

### Exercise 28: Design Google Maps

**Time**: 60 min | **Difficulty**: 5

**Requirements**:
- Map tile serving
- Route calculation
- Real-time traffic
- Location search

---

### Exercise 29: Design a Stock Trading Platform

**Time**: 60 min | **Difficulty**: 5

**Requirements**:
- Real-time stock prices
- Order matching engine
- Portfolio tracking
- Circuit breakers (trading halts)

---

### Exercise 30: Design a Cryptocurrency Exchange

**Time**: 60 min | **Difficulty**: 5

**Requirements**:
- Order book management
- Trade matching
- Wallet management
- Security (2FA, cold storage)

---

## Quick Reference: Component Cheat Sheet

| Component | Purpose | Example Technologies |
|-----------|---------|---------------------|
| Load Balancer | Distribute traffic | NGINX, HAProxy, AWS ALB |
| Cache | Fast reads | Redis, Memcached |
| Database (SQL) | Structured data | PostgreSQL, MySQL |
| Database (NoSQL) | Flexible schema | MongoDB, DynamoDB |
| Queue | Async processing | SQS, Kafka, RabbitMQ |
| CDN | Static assets | CloudFront, Cloudflare |
| Object Storage | Files | S3, GCS |
| WebSocket | Real-time | Socket.io, WS |
| Search | Full-text search | Elasticsearch, Algolia |
| Monitoring | Observability | Prometheus, Datadog |

---

## How to Practice

1. **Pick one exercise per day**
2. **Set a timer** (45 min for interviews)
3. **Draw the architecture** (boxes and arrows)
4. **Explain out loud** (practice communication)
5. **Review the solution** (compare with your approach)
6. **Identify knowledge gaps** (study weak areas)
