# Mock Interview 1: Design a URL Shortener (TinyURL)

**Difficulty:** Warm-up / Easy
**Time:** 45-60 minutes
**Focus:** Basic system design, estimation, database schema, caching

---

## Problem Statement

> **Interviewer:** "Today I'd like you to design a URL shortening service like bit.ly or TinyURL. Users should be able to submit a long URL and get back a short code. When someone visits the short URL, they should be redirected to the original long URL."

---

## Phase 1: Requirements Gathering (0-5 minutes)

### Expected Candidate Behavior

**What good looks like:**
- Asks clarifying questions before drawing anything
- Distinguishes functional vs non-functional requirements
- Questions change the design (not trivia)

**What bad looks like:**
- Jumps straight into "I'd use Redis" without understanding the problem
- Asks questions like "What color should the button be?" (doesn't affect design)

---

### Mock Dialogue

**Interviewer:** "Today I'd like you to design a URL shortening service like bit.ly or TinyURL..."

**Candidate:** "Got it. So the core functionality is: users submit a long URL, we generate a short code, and when someone visits that short URL they get redirected to the original. Before I start designing, I'd like to ask a few clarifying questions to make sure I'm solving the right problem — is that okay?"

**Interviewer:** "Yes, absolutely."

**Candidate:** "Great. Starting with scale — are we building this for a small startup doing a few thousand URLs per day, or something at the scale of bit.ly which handles billions?"

**Interviewer:** "Let's say we're a mid-sized service — about 100 million URLs created per month, and around 10 billion redirects per month."

**Candidate:** "Okay, so the read-to-write ratio is about 100:1, which is quite read-heavy. A few more questions:
- Do users need to customize their short codes, or are they all system-generated?
- Should we track analytics like click counts?
- Do we need to support link expiration or deletion?"

**Interviewer:** "Good questions. Let's say: no custom codes for now, all system-generated. Yes, we need basic click tracking. And yes, users should be able to delete their links. Anything else?"

**Candidate:** "One more — for redirects, do we need 301 (permanent) or 302 (temporary)? This affects browser caching behavior."

**Interviewer:** "Good catch. Let's go with 302 for now so we can update destinations if needed."

**Candidate:** "Perfect. Let me also note some non-functional requirements I'd propose:
- High availability — redirects must work even if the creation service is down
- Low latency — redirects should complete in under 100ms
- The short codes should be reasonably short — I'm thinking 6-8 characters

Does that sound right?"

**Interviewer:** "Yes, that's a good summary."

---

### Requirements Summary (What You Should Write Down)

```
┌─────────────────────────────────────────────────────────────────┐
│  FUNCTIONAL REQUIREMENTS                                        │
├─────────────────────────────────────────────────────────────────┤
│  1. Create short URL from long URL                              │
│  2. Redirect short URL → long URL (302 redirect)                │
│  3. Track click count per URL                                   │
│  4. Users can delete their URLs                                 │
│  5. All short codes are system-generated (no custom)            │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  NON-FUNCTIONAL REQUIREMENTS                                    │
├─────────────────────────────────────────────────────────────────┤
│  1. Scale: 100M URLs created/month, 10B redirects/month         │
│  2. Availability: Redirects must work 99.99% of time            │
│  3. Latency: < 100ms for redirects                              │
│  4. Short code length: 6-8 characters                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 2: Back-of-Envelope Estimation (5-10 minutes)

### Mock Dialogue

**Candidate:** "Now let me estimate the scale to understand what kind of architecture we need.

100 million URLs per month is about 100M ÷ (30 × 24 × 3600) ≈ 40 URLs created per second.

10 billion redirects per month is about 10B ÷ 2.5M seconds ≈ 4,000 redirects per second.

So we're looking at roughly 40 writes/sec and 4,000 reads/sec. That's a 100:1 read-to-write ratio."

**Interviewer:** "And what does that tell you about the architecture?"

**Candidate:** "Great question. 4,000 QPS for reads is significant — a single server can typically handle a few thousand QPS, but we'd be cutting it close. Combined with the 100:1 read ratio, this tells me:
1. We definitely need caching — redirects are perfect for cache-aside pattern
2. We need a load balancer to distribute traffic across multiple API servers
3. The database will be read-heavy, so we might want read replicas

For storage, if each URL record is about 500 bytes (short code, long URL, metadata), then:
100M URLs × 500 bytes = 50 GB per month
Over 5 years, that's about 3 TB — very manageable for a modern database."

**Interviewer:** "Good. So you're saying caching is critical here?"

**Candidate:** "Absolutely. A redirect is a perfect use case for caching — it's read-heavy, the data doesn't change frequently, and latency is critical. I'd expect a 99%+ cache hit rate for redirects, which means the database only sees the 1% of traffic that's cache misses or new URLs."

---

### Estimation Summary

```
┌─────────────────────────────────────────────────────────────────┐
│  SCALE ESTIMATION                                               │
├─────────────────────────────────────────────────────────────────┤
│  Writes: 100M / month ÷ 2.5M seconds ≈ 40 writes/sec            │
│  Reads:  10B / month ÷ 2.5M seconds ≈ 4,000 reads/sec           │
│  Ratio:  100:1 (read-heavy)                                     │
│                                                                 │
│  Storage: 100M URLs × 500 bytes = 50 GB/month                   │
│           5 years ≈ 3 TB                                        │
│                                                                 │
│  ARCHITECTURE IMPLICATIONS:                                     │
│  • Need caching (99%+ hit rate expected)                        │
│  • Need load balancer (4,000 QPS too much for single server)    │
│  • Read replicas for database                                   │
│  • Storage is very manageable                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 3: High-Level Design (10-20 minutes)

### What to Draw First

Always start with the spine: Client → API → Database

### Mock Dialogue

**Candidate:** "Let me start with the basic architecture."

*(Draws while narrating)*

"I'm drawing three boxes: the client (browser or app), an API server layer, and a database. The API server handles both URL creation and redirects. The database persists the URL mappings."

```
┌─────────────┐     ┌──────────────────┐     ┌────────────────┐
│   Client    │────►│    API Server    │────►│   Database     │
│  (Browser)  │     │                  │     │   (SQL/NoSQL)  │
└─────────────┘     └──────────────────┘     └────────────────┘
```

**Interviewer:** "Okay, walk me through what happens when a user creates a short URL."

**Candidate:** "Sure. The user submits a long URL via POST /shorten:

1. Client sends: POST /shorten with body `{url: 'https://very-long-url.com/...'}`
2. API server validates the URL (is it well-formed? is it a duplicate?)
3. API generates a short code
4. API stores the mapping in the database
5. API returns: `{short_code: 'abc123', short_url: 'https://short.ly/abc123'}`

For redirects, it's simpler:
1. Client requests GET /abc123
2. API looks up the short code
3. API returns HTTP 302 redirect to the long URL
4. Browser follows the redirect automatically"

**Interviewer:** "Where does caching fit in?"

**Candidate:** "Good question. Let me add that."

*(Adds Redis to the diagram)*

```
┌─────────────┐     ┌──────────────────┐     ┌────────────────┐
│   Client    │────►│    API Server    │────►│   Database     │
│  (Browser)  │     │        │         │     │                │
└─────────────┘     │        ▼         │     │                │
                    │    ┌───────┐     │     │                │
                    │    │ Redis │     │     │                │
                    │    │ Cache │     │     │                │
                    │    └───────┘     │     │                │
                    └──────────────────┘     └────────────────┘
```

"For redirects, the flow becomes:
1. GET /abc123 arrives
2. Check Redis: GET url:abc123
3. If found (cache hit, ~99% of requests): return redirect immediately
4. If not found (cache miss, ~1% of requests):
   - Query database: SELECT long_url FROM urls WHERE short_code = 'abc123'
   - Populate cache: SET url:abc123 long_url EX 3600
   - Return redirect"

**Interviewer:** "Why Redis specifically? Why not just cache in the API server's memory?"

**Candidate:** "Two reasons:
1. **Shared cache across servers:** We'll have multiple API servers behind a load balancer. If we cache in-memory, each server would have its own cache, leading to inconsistent hit rates and more database load. Redis gives us a single shared cache.
2. **Memory management:** Redis handles eviction, TTL, and memory limits automatically. In-memory caching would require us to build that ourselves.

The trade-off is we're adding another system to operate — Redis is generally reliable, but it's another failure mode to handle."

---

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    URL SHORTENER ARCHITECTURE                   │
└─────────────────────────────────────────────────────────────────┘

                           ┌─────────────┐
                           │   Clients   │
                           │  (Browsers) │
                           └──────┬──────┘
                                  │
                           ┌──────▼──────┐
                           │   CDN       │  ← Optional: cache redirects at edge
                           │ (Cloudflare)│
                           └──────┬──────┘
                                  │
                           ┌──────▼──────┐
                           │Load Balancer│
                           │   (NGINX)   │
                           └──────┬──────┘
                                  │
            ┌─────────────────────┼─────────────────────┐
            │                     │                     │
    ┌───────▼───────┐     ┌───────▼───────┐     ┌───────▼───────┐
    │   API Server  │     │   API Server  │     │   API Server  │
    │   (Node.js)   │     │   (Node.js)   │     │   (Node.js)   │
    │               │     │               │     │               │
    │   ┌─────────┐ │     │   ┌─────────┐ │     │   ┌─────────┐ │
    │   │  Local  │ │     │   │  Local  │ │     │   │  Local  │ │
    │   │  Cache  │ │     │   │  Cache  │ │     │   │  Cache  │ │
    │   └─────────┘ │     │   └─────────┘ │     │   └─────────┘ │
    └───────┬───────┘     └───────┬───────┘     └───────┬───────┘
            │                     │                     │
            └─────────────────────┼─────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
             ┌──────▼──────┐            ┌───────▼───────┐
             │    Redis    │            │  PostgreSQL   │
             │   Cluster   │            │   (Primary)   │
             │  (Cache +   │            │               │
             │   Locks)    │            │  ┌─────────┐  │
             └─────────────┘            │  │Read     │  │
                                        │  │Replicas │  │
                                        │  └─────────┘  │
                                        └───────────────┘
```

---

## Phase 4: Deep Dive — Short Code Generation (20-30 minutes)

### Mock Dialogue

**Interviewer:** "Let's go deeper on short code generation. How would you generate the short codes?"

**Candidate:** "Great, this is the interesting part. There are three main approaches:

**Option 1: Hash-based generation**
- Take the MD5 or SHA-256 hash of the long URL
- Use the first 6-8 characters as the short code
- Example: MD5('https://example.com') = 'a1b2c3d4...' → short code 'a1b2c3'

**Pros:** Deterministic — same URL always produces same short code
**Cons:** Collisions are possible, especially with shorter codes

**Option 2: Auto-increment ID + Base62 encoding**
- Use a database auto-increment primary key
- Convert the ID to base62 (0-9, a-z, A-Z)
- Example: ID=1 → 'a', ID=62 → '10', ID=1000 → 'g8'

**Pros:** Guaranteed unique, no collisions
**Cons:** Predictable — users can guess other IDs; also requires database round-trip

**Option 3: Random string generation**
- Generate a random 6-character string
- Check if it exists in the database
- If collision, retry

**Pros:** Unpredictable codes
**Cons:** May need multiple attempts; more complex"

**Interviewer:** "Which would you choose and why?"

**Candidate:** "For this use case, I'd choose **Option 2: Auto-increment + Base62**. Here's my reasoning:

1. **Simplicity:** It's guaranteed unique with no collision handling needed
2. **Efficiency:** One database insert, get the ID back, encode it
3. **Predictability isn't a concern:** Unlike session tokens, short codes being guessable isn't a security issue

The main downside is users could enumerate URLs by guessing IDs, but for a URL shortener, that's acceptable. If we needed unpredictability, we could combine approaches — use auto-increment for uniqueness, then apply a reversible transformation (like XOR with a secret key) before encoding."

**Interviewer:** "Wait, but you said we need a database round-trip for auto-increment. What if we want to generate the code without hitting the database first?"

**Candidate:** "Good pushback. There's a way to do that with a **keyspace service** or **range allocation**:

Instead of a central database, we have a service that allocates ranges of IDs to each API server:
- API Server 1 gets IDs 1-1,000,000
- API Server 2 gets IDs 1,000,001-2,000,000
- etc.

Each server can then generate codes locally without coordination. The trade-off is:
- **Pro:** No database round-trip for generation
- **Con:** If a server crashes, it 'wastes' its unused ID range (gaps in the sequence)
- **Con:** More complex — we need to manage the range allocation service

For 40 writes/sec, I don't think this complexity is warranted. A single database write is fine. But at 100,000 writes/sec, I'd absolutely use range allocation."

**Interviewer:** "Good. Now let's talk about the database schema. What does it look like?"

**Candidate:** "Let me write that out."

---

### Database Schema Design

```sql
-- Main URLs table
CREATE TABLE urls (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    short_code      VARCHAR(10) UNIQUE NOT NULL,
    long_url        TEXT NOT NULL,
    user_id         BIGINT,              -- NULL for anonymous URLs
    click_count     BIGINT DEFAULT 0,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    expires_at      TIMESTAMP NULL,      -- NULL = never expires

    -- Indexes for fast lookups
    INDEX idx_short_code (short_code),
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
);

-- Click analytics (if we want detailed tracking)
CREATE TABLE url_clicks (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    url_id          BIGINT NOT NULL,
    clicked_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address      VARCHAR(45),         -- IPv4 or IPv6
    user_agent      VARCHAR(500),
    referrer        VARCHAR(500),
    country         VARCHAR(2),          -- GeoIP lookup

    INDEX idx_url_id (url_id),
    INDEX idx_clicked_at (clicked_at)
);
```

**Candidate:** "The main `urls` table has:
- `short_code` with a unique index for O(1) lookups
- `click_count` denormalized for fast reads (updated asynchronously)
- `user_id` to support user-owned URLs and deletion
- `expires_at` for link expiration

The `url_clicks` table is optional — if we only need total click count, we can just increment the counter. But if we want analytics (clicks by country, referrer, etc.), we'd log each click here."

**Interviewer:** "You mentioned updating click_count asynchronously. How would that work?"

**Candidate:** "Good question. We have a few options:

**Option A: Synchronous increment**
```sql
UPDATE urls SET click_count = click_count + 1 WHERE short_code = 'abc123';
```
- **Pro:** Simple, accurate
- **Con:** Write on every redirect, adds latency

**Option B: Redis counter + async flush**
```
On redirect:
  1. INCR url:clicks:abc123 (Redis, ~0.1ms)
  2. Return redirect immediately

Background job (every 10 seconds):
  1. For each URL: GET url:clicks:abc123
  2. UPDATE urls SET click_count = click_count + redis_count
  3. DEL url:clicks:abc123
```
- **Pro:** Fast redirects, batched database writes
- **Con:** Click count is eventually consistent (up to 10 seconds behind)
- **Con:** More complex, need background job"

**Interviewer:** "Which would you choose?"

**Candidate:** "For this use case, I'd go with **Option A: Synchronous increment**. Here's why:
1. 4,000 QPS is manageable for simple increments
2. Click count doesn't need to be real-time accurate
3. It keeps the system simpler

However, if we were at 100,000+ QPS, I'd switch to Option B. The async pattern also lets us do more — like sampling (only log 1 in 100 clicks) or detailed analytics without impacting redirect performance."

---

## Phase 5: Handling Edge Cases (30-40 minutes)

### Mock Dialogue

**Interviewer:** "Let's talk about edge cases. What happens if someone tries to create a short URL for a URL that already exists in the system?"

**Candidate:** "Good question. We have two options:

**Option 1: Return the existing short URL**
- Check if the long URL already exists: SELECT short_code FROM urls WHERE long_url = ?
- If found, return the existing short code
- **Pro:** No duplicates, saves storage
- **Con:** Requires a hash or index on long_url, which is a TEXT field and expensive

**Option 2: Always create a new short URL**
- Don't check for duplicates
- **Pro:** Simpler, faster
- **Con:** Same URL can have multiple short codes

I'd choose **Option 2** for simplicity. If duplicate detection becomes important, we could add a hash of the long URL:
```sql
CREATE TABLE urls (
    ...
    long_url_hash CHAR(64),  -- SHA-256 of long_url
    INDEX idx_url_hash (long_url_hash)
);
```
Then we can quickly check for duplicates using the hash index."

---

**Interviewer:** "What about malicious URLs? How do you prevent abuse?"

**Candidate:** "Several layers of protection:

**1. Rate limiting per IP/user:**
```
- Anonymous users: 10 URLs per hour
- Authenticated users: 100 URLs per hour
- Use Redis sliding window: rate_limit:{user_id}
```

**2. URL validation:**
```python
def validate_url(url):
    # Must be valid HTTP/HTTPS URL
    if not url.startswith(('http://', 'https://')):
        return False

    # Block internal/private IP ranges
    parsed = urlparse(url)
    ip = socket.gethostbyname(parsed.hostname)
    if ip.startswith(('10.', '192.168.', '127.', '172.16.')):
        return False

    # Check against blocklist (malware, phishing, spam)
    if url in blocklist:
        return False

    return True
```

**3. Human review queue:**
- Flag URLs that get reported
- Temporarily disable URLs with suspicious click patterns

**4. Domain allowlist/blocklist:**
- For high-security deployments, only allow specific domains"

---

**Interviewer:** "Let's talk about deletions. What happens when a user deletes a URL?"

**Candidate:** "The flow would be:

```
DELETE /urls/{short_code}
1. Verify user owns this URL (check user_id matches)
2. Soft delete: UPDATE urls SET deleted_at = NOW() WHERE short_code = ?
3. Invalidate cache: DEL url:abc123
4. Return 204 No Content
```

For the redirect behavior after deletion:
- **Option A:** Return 404 Not Found immediately
- **Option B:** Keep redirecting for 24 hours (grace period), then 404

I'd choose **Option A** for simplicity, but **Option B** is more user-friendly — broken links are frustrating."

---

**Interviewer:** "What if the database goes down?"

**Candidate:** "Let me think through the failure modes:

**If the database is down:**
- URL creation fails (we can't persist new URLs)
- Redirects can still work if the URLs are cached!

So the architecture should handle this:
```python
def redirect(short_code):
    try:
        # Try cache first
        long_url = redis.get(f'url:{short_code}')
        if long_url:
            return redirect(long_url)

        # Cache miss, try database
        long_url = db.query('SELECT long_url FROM urls WHERE short_code = ?', short_code)
        redis.set(f'url:{short_code}', long_url, ex=3600)
        return redirect(long_url)

    except DatabaseError:
        # Database is down
        metrics.increment('db_down')

        # Check cache one more time
        long_url = redis.get(f'url:{short_code}')
        if long_url:
            return redirect(long_url)

        # Cache miss + DB down = 503
        return error(503, 'Service temporarily unavailable')
```

The key insight: **reads can degrade gracefully, writes cannot**. If the database is down, we can't create new URLs, but we can still serve cached redirects. This is why we separate the read path (redirects) from the write path (creation)."

---

**Interviewer:** "Good. One more — how would you scale this to 10x traffic?"

**Candidate:** "Let me think about the bottlenecks:

**Current bottlenecks at 4,000 QPS:**
1. Database read capacity (4,000 QPS with 99% cache hit = 40 DB queries/sec, which is fine)
2. Redis capacity (single Redis node can handle 100K+ QPS, so we're fine)
3. API server capacity (depends on implementation, but 4,000 QPS across 3 servers = ~1,300 QPS each, manageable)

**For 10x traffic (40,000 QPS):**

1. **Cache layer:**
   - Add Redis replication (1 master, multiple read replicas)
   - Or Redis Cluster for horizontal scaling

2. **Database:**
   - Add read replicas for redirect lookups
   - Keep writes on primary (40 writes/sec is still fine)
   - Consider read/write splitting in the application

3. **API layer:**
   - Add more API servers behind the load balancer
   - Auto-scale based on CPU or request queue depth

4. **Optional: CDN caching**
   - Cache redirects at the edge (Cloudflare, CloudFront)
   - For very popular URLs, the CDN can handle the redirect without hitting our servers at all
   - 302 redirects can be cached with a short TTL (1 minute)

The architecture scales horizontally at every layer, which is good design."

---

## Phase 6: Wrap-Up (40-45 minutes)

### Mock Dialogue

**Interviewer:** "Great. To wrap up, what's the one thing you'd most want to improve if you had more time?"

**Candidate:** "Good question. The thing I'd most want to improve is the **analytics pipeline**. Right now we're doing basic click counting, but a real URL shortener would want:

1. **Real-time analytics dashboard:**
   - Clicks per minute/hour/day
   - Geographic distribution
   - Referrer sources
   - Device/browser breakdown

2. **Architecture for this:**
   ```
   Redirect → Kafka → Stream Processor → Analytics DB
                                      ↓
                              Clickstream Table
   ```

3. **Why this matters:**
   - Separates analytics load from redirect path
   - Enables complex queries without impacting performance
   - Can add new metrics without schema changes

The trade-off is complexity — we're adding Kafka, a stream processor, and a separate analytics database (like ClickHouse or Druid). For a v1, the simple approach is fine. But for a production service, analytics is a key differentiator."

---

**Interviewer:** "Any trade-offs you want to call out from your design?"

**Candidate:** "Yes, a few:

1. **Auto-increment IDs vs random codes:**
   - Chose auto-increment for simplicity
   - Trade-off: predictable codes (acceptable for this use case)

2. **Synchronous click counting vs async:**
   - Chose synchronous for simplicity
   - Trade-off: slightly higher redirect latency, but accurate counts

3. **Cache-aside vs write-through:**
   - Chose cache-aside for simplicity
   - Trade-off: brief window of stale cache after updates

4. **SQL vs NoSQL:**
   - Chose SQL (PostgreSQL) for strong consistency and simplicity
   - Trade-off: less horizontally scalable than DynamoDB, but fine for our scale

All these choices are revisitable — if we hit limits, we can change them. But for 4,000 QPS, simplicity wins."

---

## Interviewer Scorecard (What They're Evaluating)

### Strong Candidate Signals

| Area | What to Look For |
|------|------------------|
| **Requirements** | Asked about scale, read/write ratio, custom codes, deletion |
| **Estimation** | Calculated QPS correctly, derived architecture from numbers |
| **High-level design** | Drew spine first, added cache with justification, narrated while drawing |
| **Deep dive** | Compared 3 approaches for short codes, chose with reasoning |
| **Trade-offs** | Named specific trade-offs for each decision |
| **Edge cases** | Handled duplicates, abuse, database failures gracefully |
| **Communication** | Thought out loud, asked for clarification, acknowledged uncertainties |

### Red Flags

- ❌ Started drawing without asking questions
- ❌ Couldn't calculate QPS from monthly numbers
- ❌ Proposed microservices for a 4,000 QPS system (over-engineering)
- ❌ No cache mentioned for a 100:1 read ratio
- ❌ Couldn't explain why they chose a technology
- ❌ No trade-offs mentioned (everything was "the best")

### Common Mistakes

| Mistake | Why It's Bad | Fix |
|---------|--------------|-----|
| "I'd use microservices" immediately | Over-engineering for scale | Start monolith, split when needed |
| No cache for redirects | Ignores 100:1 read ratio | Always cache read-heavy workloads |
| MD5 hash without collision handling | Will fail in production | Discuss collision strategy |
| No rate limiting | System gets abused | Always mention abuse prevention |
| "Database will handle it" | Unclear thinking | Explain which database and why |

---

## Follow-Up Questions (For More Practice)

### Q1: "How would you handle custom short codes (user-specified)?"

**Expected Answer:**
```
1. Add user_id validation (only allow custom codes for authenticated users)
2. Check if custom code already exists
3. Rate limit custom code creation (prevent squatting)
4. Consider reserving profanity/inappropriate words
5. Store in same table with a flag: is_custom BOOLEAN
```

### Q2: "What if we wanted to support QR codes for each short URL?"

**Expected Answer:**
```
1. Generate QR code on-demand or pre-generate and store
2. On-demand: Use a library like qrcode, cache the image
3. Pre-generate: Store in S3, serve from CDN
4. Trade-off: Storage vs compute
5. Add endpoint: GET /qr/{short_code}
```

### Q3: "How would you make this service global (low latency worldwide)?"

**Expected Answer:**
```
1. Multi-region deployment (US, EU, Asia)
2. GeoDNS for routing users to nearest region
3. Database replication with conflict resolution (or regional DBs)
4. Redis replication or regional Redis clusters
5. CDN for static assets and cached redirects
6. Trade-off: Data consistency across regions (eventual consistency)
```

### Q4: "Design a rate limiter for the URL creation API."

**Expected Answer:**
```
Algorithm: Sliding Window with Redis

Key: rate_limit:{user_id}
Value: Sorted set of request timestamps

Pseudo-code:
  now = current_timestamp()
  window_start = now - 3600  # 1 hour window

  # Remove old entries
  redis.zremrangebyscore(f'rate:{user_id}', 0, window_start)

  # Count current requests
  count = redis.zcard(f'rate:{user_id}')

  if count >= limit:
    return 429 Too Many Requests

  # Add current request
  redis.zadd(f'rate:{user_id}', {request_id: now})
  redis.expire(f'rate:{user_id}', 3600)

  return OK
```

---

## Self-Study Exercises

### Exercise 1: Implement the Short Code Generator

```python
# Implement base62 encoding
BASE62 = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

def encode_base62(num):
    """Convert integer to base62 string"""
    # Your implementation here
    pass

def decode_base62(code):
    """Convert base62 string back to integer"""
    # Your implementation here
    pass

# Test cases
assert encode_base62(0) == '0'
assert encode_base62(61) == 'Z'
assert encode_base62(62) == '10'
assert encode_base62(1000) == 'g8'
```

### Exercise 2: Design the API Contract

Write OpenAPI/Swagger spec for:
- POST /shorten
- GET /{short_code}
- DELETE /urls/{short_code}
- GET /urls/{short_code}/stats

Include request/response schemas, error codes, and rate limit headers.

### Exercise 3: Draw the Failure Scenarios

For each failure mode, draw what happens:
1. Redis goes down
2. Primary database goes down
3. One API server crashes
4. Load balancer fails
5. CDN has an outage

For each, answer: What fails? What degrades? How do users experience it?

---

## Summary Checklist

After this mock interview, you should be able to:

- [ ] Calculate QPS from monthly traffic numbers
- [ ] Explain why caching is critical for 100:1 read ratio
- [ ] Compare 3 approaches to short code generation
- [ ] Design a database schema with proper indexes
- [ ] Handle edge cases (duplicates, abuse, failures)
- [ ] Name trade-offs for each major decision
- [ ] Explain how to scale to 10x traffic
- [ ] Draw the complete architecture diagram from memory

---

**Next:** Move to Mock Interview 2 (Rate Limiter) for more practice with concurrency and distributed systems patterns.
