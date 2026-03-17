# Mock Interview 2: Design a Rate Limiter

**Difficulty:** Intermediate
**Time:** 60-75 minutes
**Focus:** Distributed systems, concurrency, algorithms, Redis patterns

---

## Problem Statement

> **Interviewer:** "Today I'd like you to design a rate limiter — a service that limits how many requests a user can make to an API. For example, we might want to limit each user to 100 requests per minute. If they exceed that limit, we return a 429 Too Many Requests error."

---

## Phase 1: Requirements Gathering (0-7 minutes)

### Mock Dialogue

**Interviewer:** "Today I'd like you to design a rate limiter..."

**Candidate:** "Got it. So the core function is: we track how many requests each user makes within a time window, and if they exceed their limit, we reject the request with a 429 error. Before I dive in, let me ask some questions to understand the requirements better.

First, what's the scale we're designing for? How many requests per second are we expecting?"

**Interviewer:** "Good question. Let's say we're protecting APIs that handle about 100,000 requests per second at peak."

**Candidate:** "Okay, 100K QPS is serious scale — that tells me we need a distributed solution, not something that runs in a single process. And how many unique users are making these requests?"

**Interviewer:** "About 10 million daily active users."

**Candidate:** "Got it. A few more questions:
- Is the rate limit the same for all users, or do we have tiers (like free vs premium)?
- What time windows do we need? Just per-minute, or also per-hour, per-day?"

**Interviewer:** "Good questions. Let's say we have three tiers:
- Free: 100 requests/minute
- Pro: 1,000 requests/minute
- Enterprise: 10,000 requests/minute

And we need multiple windows: per-minute and per-hour."

**Candidate:** "Okay, so a free user could make 100/minute OR 1,000/hour — whichever they hit first triggers the limit?"

**Interviewer:** "Exactly. What else do you need to know?"

**Candidate:** "A few more things:
- Do we need to tell users how many requests they have left? (Like X-RateLimit headers)
- Should the rate limiter work across multiple servers? (Can a user spread requests across servers to bypass limits?)
- What happens to legitimate traffic that gets rate limited — do we queue it, or just reject?"

**Interviewer:** "Good thinking. Yes, we need X-RateLimit headers. Yes, it must work across multiple servers — that's critical. And no queuing, just reject with 429."

**Candidate:** "Perfect. Let me also note some non-functional requirements:
- **Low latency:** Rate checking should add minimal overhead — ideally sub-millisecond
- **High availability:** If the rate limiter fails, do we fail open (allow all) or fail closed (block all)?
- **Accuracy:** We shouldn't allow significantly more than the limit, even under attack

For fail-open vs fail-closed — what's the preference?"

**Interviewer:** "Great question. For our use case, fail-open is acceptable — if the rate limiter is down, we'd rather allow extra traffic than block legitimate users."

**Candidate:** "Understood. Let me summarize the requirements before I move to design."

---

### Requirements Summary

```
┌─────────────────────────────────────────────────────────────────┐
│  FUNCTIONAL REQUIREMENTS                                        │
├─────────────────────────────────────────────────────────────────┤
│  1. Track request count per user within time window             │
│  2. Support multiple tiers (Free/Pro/Enterprise)                │
│  3. Support multiple windows (per-minute AND per-hour)          │
│  4. Return 429 when limit exceeded                              │
│  5. Include X-RateLimit headers in responses                    │
│  6. Work correctly across multiple servers (distributed)        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  NON-FUNCTIONAL REQUIREMENTS                                    │
├─────────────────────────────────────────────────────────────────┤
│  1. Scale: 100,000 QPS, 10M DAU                                 │
│  2. Latency: < 1ms overhead for rate check                      │
│  3. Availability: Fail-open if rate limiter is down             │
│  4. Accuracy: No bypassing limits via multiple servers          │
│  5. Consistency: Accurate counting across distributed nodes     │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 2: Back-of-Envelope Estimation (7-12 minutes)

### Mock Dialogue

**Candidate:** "Let me estimate the scale. 100,000 QPS with 10M DAU means each user makes about 10 requests per second on average... but that's not quite right. Let me recalculate.

10M users / day, and if each user makes requests throughout the day... actually, I should think about this differently. The 100K QPS is the total incoming traffic, and we need to rate limit each user individually.

For storage, if we track each user's request count:
- 10M users × 2 windows (minute + hour) × 2 tiers of data (count + timestamp)
- Each entry is maybe 50 bytes in Redis
- But not all 10M users are active at once — let's say 10% are active daily = 1M active users
- 1M × 2 × 50 bytes = 100 MB

That's very manageable in Redis."

**Interviewer:** "And what does that tell you about the architecture?"

**Candidate:** "Three things:

1. **Redis is the right choice:** 100 MB fits easily in memory, and Redis can handle millions of operations per second with sub-millisecond latency.

2. **We need sharding or clustering:** 100K QPS hitting a single Redis node is cutting it close. A single Redis node can do ~100-200K ops/sec, but we want headroom. Redis Cluster with 3-5 nodes would be safer.

3. **Local cache for tier lookup:** We need to know each user's tier (Free/Pro/Enterprise) to apply the right limit. Instead of querying a database for every request, we can cache tier info locally with a TTL."

---

### Estimation Summary

```
┌─────────────────────────────────────────────────────────────────┐
│  SCALE ESTIMATION                                               │
├─────────────────────────────────────────────────────────────────┤
│  Traffic: 100,000 QPS                                           │
│  Users: 10M DAU, ~1M active at any time                         │
│                                                                 │
│  Storage per user:                                              │
│  - 2 windows (minute + hour)                                    │
│  - ~50 bytes per window                                         │
│  - Total: ~100 MB for all active users                          │
│                                                                 │
│  ARCHITECTURE IMPLICATIONS:                                     │
│  • Redis Cluster (3-5 nodes) for capacity and HA               │
│  • Local cache for user tier (avoids DB lookup per request)     │
│  • Rate limiter as sidecar or library (not separate service)    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Phase 3: High-Level Design (12-22 minutes)

### Mock Dialogue

**Candidate:** "Let me start with the high-level architecture."

*(Draws while narrating)*

"The rate limiter isn't a separate service — it's a library or sidecar that runs alongside each API server. Every incoming request goes through the rate limiter before hitting the business logic."

```
┌─────────────┐     ┌──────────────────────────────────┐
│   Client    │────►│         API Server               │
│  (Browser)  │     │  ┌────────────────────────────┐  │
│             │     │  │   Rate Limiter (Library)   │  │
│             │     │  │                            │  │
│             │     │  │   1. Check local tier cache│  │
│             │     │  │   2. Check Redis counter   │  │
│             │     │  │   3. Allow or Reject       │  │
│             │     │  └────────────────────────────┘  │
│             │     └──────────────────────────────────┘
└─────────────┘                    │
                                   │
                          ┌────────▼────────┐
                          │   Redis Cluster │
                          │                 │
                          │ ┌─────┐ ┌─────┐ │
                          │ │Node1│ │Node2│ │
                          │ └─────┘ └─────┘ │
                          └─────────────────┘
```

**Interviewer:** "Walk me through what happens when a request comes in."

**Candidate:** "Sure. Here's the flow:

1. **Request arrives:** GET /api/users arrives at API server
2. **Extract user identity:** Get user_id from auth token, API key, or IP (for anonymous)
3. **Lookup tier:** Check local cache for user's tier (Free/Pro/Enterprise)
   - If cached: use cached value
   - If not cached: query database, cache for 5 minutes
4. **Check rate limit:** Query Redis for current request count
5. **Decision:**
   - If under limit: increment counter, allow request
   - If over limit: return 429 with Retry-After header
6. **Add headers:** Include X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset"

**Interviewer:** "Why is the rate limiter a library and not a separate service?"

**Candidate:** "Great question. There are two patterns:

**Pattern A: Rate limiter as a service**
```
Request → API Server → Rate Limiter Service → (if allowed) → Business Logic
```
- **Pro:** Centralized, easier to update limits dynamically
- **Con:** Adds network hop (latency), single point of failure

**Pattern B: Rate limiter as library (my choice)**
```
Request → API Server (with embedded rate limiter) → Business Logic
                      ↓
                  Redis (shared state)
```
- **Pro:** No network hop for the check itself (only to Redis), lower latency
- **Pro:** No single point of failure — each API server can rate limit independently
- **Con:** Need to keep library version in sync across servers

For 100K QPS with <1ms overhead requirement, the library pattern is the right choice. The only shared state is in Redis, which we need anyway for distributed counting."

---

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│              RATE LIMITER ARCHITECTURE                          │
└─────────────────────────────────────────────────────────────────┘

                              ┌─────────────┐
                              │   Clients   │
                              └──────┬──────┘
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
    │   + Rate      │        │   + Rate      │        │   + Rate      │
    │   Limiter     │        │   Limiter     │        │   Limiter     │
    │   Library     │        │   Library     │        │   Library     │
    │               │        │               │        │               │
    │ ┌───────────┐ │        │ ┌───────────┐ │        │ ┌───────────┐ │
    │ │  Local    │ │        │ │  Local    │ │        │ │  Local    │ │
    │ │  Cache    │ │        │ │  Cache    │ │        │ │  Cache    │ │
    │ │  (Tiers)  │ │        │ │  (Tiers)  │ │        │ │  (Tiers)  │ │
    │ └───────────┘ │        │ └───────────┘ │        │ └───────────┘ │
    └───────┬───────┘        └───────┬───────┘        └───────┬───────┘
            │                        │                        │
            └────────────────────────┼────────────────────────┘
                                     │
                    ┌────────────────┴────────────────┐
                    │                                 │
             ┌──────▼──────┐                  ┌───────▼───────┐
             │    Redis    │                  │    User DB    │
             │   Cluster   │                  │  (PostgreSQL) │
             │  (Counters) │                  │   (Tiers)     │
             └─────────────┘                  └───────────────┘
```

---

## Phase 4: Deep Dive — Rate Limiting Algorithms (22-40 minutes)

### Mock Dialogue

**Interviewer:** "Let's go deep on the rate limiting algorithm itself. What algorithm would you use?"

**Candidate:** "There are four main algorithms, each with different properties:

| Algorithm | How It Works | Pros | Cons |
|-----------|--------------|------|------|
| **Fixed Window** | Count requests in fixed time buckets (e.g., 12:00-12:01, 12:01-12:02) | Simple, efficient | Boundary burst problem |
| **Sliding Window** | Count requests in rolling window (last 60 seconds from now) | Accurate, no boundary issues | More complex, more memory |
| **Token Bucket** | Bucket fills with tokens at fixed rate, each request consumes a token | Allows bursting, smooth limiting | More state to track |
| **Leaky Bucket** | Requests queue in bucket, processed at fixed rate | Smooths out bursts | Adds latency, needs queue |

For our requirements — accurate limiting across per-minute AND per-hour windows — I'd recommend **Sliding Window Log** or **Sliding Window Counter**."

**Interviewer:** "What's the difference between those two?"

**Candidate:** "Good question. Let me explain both:

---

### Algorithm 1: Sliding Window Log (Most Accurate)

```
How it works:
- Store a timestamp for EVERY request
- To check limit: count timestamps within the window

Example (100 requests/minute limit):

User makes requests at:
12:00:05, 12:00:15, 12:00:30, 12:00:45, 12:00:50...

At 12:01:00, checking if 101st request is allowed:
- Count requests where timestamp > 12:00:00 (last 60 seconds)
- If count < 100: allow
- If count >= 100: reject

Redis implementation:
Key: rate_limit:{user_id}:minute
Value: Sorted set of timestamps

ZREMRANGEBYSCORE rate_limit:user123:minute 0 (now - 60000)  # Remove old
ZCARD rate_limit:user123:minute                               # Count current
If count < limit:
    ZADD rate_limit:user123:minute now now                   # Add new
    return ALLOW
else:
    return REJECT
```

**Pros:**
- Perfectly accurate — exact count within sliding window
- No boundary burst problem

**Cons:**
- Memory intensive — one entry per request
- For 100K QPS, if average user makes 10 requests/min, that's 1M entries in Redis at any time
- Each check requires multiple Redis commands (can be pipelined)"

---

### Algorithm 2: Sliding Window Counter (Approximate but Efficient)

```
How it works:
- Divide time into small slots (e.g., 1-second slots)
- Track count per slot
- Estimate current window count by interpolating

Example (100 requests/minute limit, 1-second slots):

Second:     0   1   2   3   4   5   ...  58  59  60
Count:     10   5   8  12   3   7   ...   2   4   6

At second 60, wanting to check if request is allowed:
- Full window would be seconds 1-60
- Current second (60) is only partially complete
- Estimated count = (count of seconds 1-59) + (partial count of second 60)
- If estimated < 100: allow

Redis implementation:
Key: rate_limit:{user_id}:minute:{second}
Value: Counter (integer)

Current second = floor(now / 1000)  # in seconds
Window start = current_second - 59

total = 0
for i from window_start to current_second:
    count = GET rate_limit:user123:minute:i
    total += count or 0

if total < limit:
    INCR rate_limit:user123:minute:current_second
    return ALLOW
else:
    return REJECT
```

**Pros:**
- Much less memory — one counter per second, not per request
- 60 counters per user per minute vs potentially 100+ timestamps

**Cons:**
- Approximate — can be off by up to 1 slot's worth of requests
- More complex to implement"

---

### Algorithm 3: Token Bucket (My Recommendation)

**Interviewer:** "You mentioned Token Bucket. Why might that be a good fit?"

**Candidate:** "Token Bucket is great for our use case because:

```
How it works:
- Each user has a 'bucket' that holds tokens
- Bucket has a max capacity (e.g., 100 tokens)
- Tokens are added at a fixed rate (e.g., 100 tokens per minute = 1.67 tokens/second)
- Each request consumes 1 token
- If bucket is empty: reject
- If bucket has tokens: consume 1, allow

Key insight: Allows bursting up to bucket capacity, but rate-limits over time.

Example:
- Bucket capacity: 100 tokens
- Refill rate: 100 tokens/minute

User makes 50 requests instantly:
- Bucket goes from 100 → 50 tokens
- All 50 requests allowed (burst!)

User makes 60 more requests:
- Bucket goes from 50 → 0 tokens
- Remaining 10 requests REJECTED

User waits 30 seconds:
- Bucket refills: 0 + (30 × 1.67) = 50 tokens
- User can now make 50 more requests
```

**Redis implementation:**
```
Key: rate_limit:{user_id}
Value: {tokens: float, last_update: timestamp}

Function check_rate_limit(user_id, bucket_capacity, refill_rate):
    now = current_timestamp()
    data = REDIS.hgetall(rate_limit:{user_id})

    if data is empty:
        # First request - full bucket
        tokens = bucket_capacity
        last_update = now
    else:
        tokens = data.tokens
        last_update = data.last_update

        # Calculate tokens to add based on elapsed time
        elapsed = now - last_update
        tokens_to_add = elapsed × refill_rate
        tokens = min(bucket_capacity, tokens + tokens_to_add)

    if tokens >= 1:
        # Allow request
        tokens = tokens - 1
        REDIS.hmset(rate_limit:{user_id}, {tokens, last_update: now})
        REDIS.expire(rate_limit:{user_id}, 3600)  # Cleanup after 1 hour
        return ALLOW, tokens
    else:
        # Reject request
        REDIS.hmset(rate_limit:{user_id}, {tokens, last_update: now})
        return REJECT, tokens
```

**Why Token Bucket for our use case:**

1. **Allows controlled bursting:** Users can make up to `bucket_capacity` requests instantly, which is good UX. A free user can make 100 requests in one second if they haven't used their quota recently.

2. **Smooth rate limiting over time:** Even if a user bursts, they'll be limited to the refill rate afterward.

3. **Memory efficient:** One key per user per window, not one entry per request.

4. **Easy to implement in Redis:** Just hash operations, no sorted sets needed."

---

**Interviewer:** "You said one key per user per window. So for per-minute AND per-hour limits, we'd have two keys?"

**Candidate:** "Exactly. Each window is independent:

```
rate_limit:{user_id}:minute → {tokens: 50, last_update: 1234567890}
rate_limit:{user_id}:hour   → {tokens: 500, last_update: 1234567890}

For each request:
    minute_result = check_rate_limit(user_id, capacity=100, refill_rate=100/60)
    hour_result = check_rate_limit(user_id, capacity=1000, refill_rate=1000/3600)

    if minute_result == REJECT or hour_result == REJECT:
        return REJECT (whichever limit is hit first)
    else:
        return ALLOW
```

The user is limited by whichever window they hit first. A free user could:
- Make 100 requests in 1 second (burst), but then wait a minute for more
- OR make 1-2 requests per second continuously (under the minute limit)
- But can't exceed 1,000 requests in any hour window"

---

**Interviewer:** "There's a problem with your implementation. What if two requests from the same user arrive at the exact same time?"

**Candidate:** "Ah, excellent catch. That's a race condition. Let me think...

```
Time    Request A                        Request B
 │       Read: tokens=50                 │
 │       Calculate: tokens=49            │
 │       Write: tokens=49                │
 │                                       │
 │                                       │ Read: tokens=50 (stale!)
 │                                       │ Calculate: tokens=49
 │                                       │ Write: tokens=49
 │                                       │
 │       Result: 2 tokens consumed       │
 │       But we only decremented once!   │
```

Both requests saw `tokens=50`, both calculated `tokens=49`, both wrote 49. We only consumed 1 token instead of 2. This allows users to bypass the rate limit by making parallel requests."

**Interviewer:** "How do you fix this?"

**Candidate:** "Two approaches:

---

**Solution 1: Redis Lua Script (Atomic)**

```lua
-- This entire script runs atomically in Redis
local key = KEYS[1]
local capacity = tonumber(ARGV[1])
local refill_rate = tonumber(ARGV[2])
local now = tonumber(ARGV[3])

local data = redis.call('HMGET', key, 'tokens', 'last_update')
local tokens = tonumber(data[1]) or capacity
local last_update = tonumber(data[2]) or now

-- Calculate tokens to add
local elapsed = now - last_update
local tokens_to_add = elapsed * refill_rate
tokens = math.min(capacity, tokens + tokens_to_add)

if tokens >= 1 then
    tokens = tokens - 1
    redis.call('HMSET', key, 'tokens', tokens, 'last_update', now)
    redis.call('EXPIRE', key, 3600)
    return {1, tokens}  -- Allowed
else
    redis.call('HMSET', key, 'tokens', tokens, 'last_update', now)
    return {0, tokens}  -- Rejected
end
```

**Why this works:** Redis Lua scripts run atomically — no other command can interleave. The read-calculate-write happens as one atomic operation.

**Trade-off:** Lua scripts block Redis while running. For simple scripts like this, it's negligible (~0.1ms), but complex scripts can cause latency."

---

**Solution 2: Redis INCR with Fixed Window (Simpler but Less Accurate)**

```
Alternative: Use fixed window with atomic INCR

Key: rate_limit:{user_id}:{window_start}
Window start = floor(now / window_size)

For per-minute (60 seconds):
    window = floor(now / 60)
    key = rate_limit:user123:12345678  # where 12345678 is the window number

    count = INCR(key)
    if count == 1:
        EXPIRE key, 60  # Set TTL on first request

    if count <= limit:
        return ALLOW
    else:
        return REJECT
```

**Why this works:** INCR is atomic in Redis. No Lua script needed.

**Trade-off:** Fixed window has the boundary burst problem:
- User can make 100 requests at 12:00:59
- And 100 requests at 12:01:01
- That's 200 requests in 2 seconds!

For our use case, I'd still recommend the Lua script approach for accuracy."

---

### Algorithm Comparison Table

```
┌──────────────────┬────────────┬──────────────┬──────────────┬─────────────┐
│   Algorithm      │  Accuracy  │  Memory      │  Complexity  │  Burst      │
├──────────────────┼────────────┼──────────────┼──────────────┼─────────────┤
│ Fixed Window     │ Low        │ O(1) per user│ Simple       │ Yes (bad)   │
│ Sliding Window   │            │              │              │             │
│   - Log          │ Perfect    │ O(requests)  │ Medium       │ No          │
│   - Counter      │ ~95%       │ O(seconds)   │ Medium       │ No          │
│ Token Bucket     │ High       │ O(1) per user│ Medium       │ Controlled  │
│ Leaky Bucket     │ High       │ O(queue)     │ Complex      │ Smoothed    │
└──────────────────┴────────────┴──────────────┴──────────────┴─────────────┘

RECOMMENDATION: Token Bucket with Lua script for atomic operations
```

---

## Phase 5: Handling Edge Cases (40-55 minutes)

### Mock Dialogue

**Interviewer:** "Let's talk about edge cases. What happens when Redis goes down?"

**Candidate:** "Good question. We said fail-open is acceptable for this use case. Here's how I'd handle it:

```python
def check_rate_limit(user_id, tier):
    try:
        # Try to check Redis
        result = redis_lua_script(user_id, tier.capacity, tier.refill_rate)
        return result

    except RedisConnectionError:
        # Redis is down - fail open
        metrics.increment('rate_limiter.redis_down')

        # Log the failure
        logger.warning(f'Rate limiter Redis unavailable for user {user_id}')

        # Fail open: allow the request
        return ALLOW

    except Exception as e:
        # Unexpected error - also fail open, but alert
        metrics.increment('rate_limiter.error')
        alert(f'Rate limiter error: {e}')
        return ALLOW
```

**Trade-off:** During a Redis outage, we allow all traffic through. For a 10-minute outage, a malicious user could make unlimited requests. But that's acceptable compared to blocking all legitimate users."

**Interviewer:** "What if you wanted fail-closed instead?"

**Candidate:** "For fail-closed, we'd add a local cache fallback:

```python
def check_rate_limit(user_id, tier):
    try:
        result = redis_lua_script(user_id, tier.capacity, tier.refill_rate)
        # Update local cache with latest values
        local_cache.set(user_id, result)
        return result

    except RedisConnectionError:
        # Redis is down - check local cache
        cached = local_cache.get(user_id)

        if cached is not None and not stale(cached):
            # Use cached value (conservative: assume no tokens refilled)
            return cached
        else:
            # No valid cache - fail closed
            return REJECT
```

The local cache would have the last known token count. Since we can't know if tokens have refilled (Redis is down), we'd be conservative and not refill. This is fail-closed but degrades gracefully."

---

**Interviewer:** "What about hot keys? What if a celebrity tweets their link and suddenly one user gets 10x normal traffic?"

**Candidate:** "Good scenario. A few considerations:

1. **Token Bucket handles this naturally:** If the bucket has capacity, the burst is allowed. If not, requests are rejected. That's the intended behavior.

2. **Redis hot key problem:** If one user is making 10,000 requests/second, all hitting the same Redis key, that single key becomes a bottleneck. Redis is single-threaded per shard.

**Solutions:**

**Option A: Redis Cluster with key sharding**
- Redis Cluster automatically shards keys across nodes
- Hot keys get isolated to one node
- Other users' rate limiting is unaffected

**Option B: Local rate limiting as backstop**
```python
# Per-server local limit
local_counter = Counter per user_id per server

if local_counter[user_id] > local_limit:  # e.g., 1000/second
    return REJECT  # Reject before even checking Redis

# Then check Redis for global limit
return check_redis_rate_limit(user_id)
```

This prevents any single user from overwhelming Redis with requests. If they hit 1000/second on one API server, they're blocked locally before hitting Redis."

---

**Interviewer:** "How do you handle the X-RateLimit headers?"

**Candidate:** "Right, we need to include:
- `X-RateLimit-Limit`: The maximum requests allowed
- `X-RateLimit-Remaining`: How many requests are left
- `X-RateLimit-Reset`: When the limit resets (Unix timestamp)

With Token Bucket:
```python
result = check_rate_limit(user_id, tier)

response.headers['X-RateLimit-Limit'] = tier.bucket_capacity
response.headers['X-RateLimit-Remaining'] = int(result.remaining_tokens)
response.headers['X-RateLimit-Reset'] = int(time.time() + (result.remaining_tokens / tier.refill_rate))

if result.allowed:
    return response
else:
    response.headers['Retry-After'] = int(1 / tier.refill_rate)  # Seconds until 1 token
    return 429 response
```

The `Reset` header tells the client when they'll have a full bucket again. The `Retry-After` tells them how long to wait before trying again."

---

**Interviewer:** "What if a user's tier changes? Like they upgrade from Free to Pro mid-minute?"

**Candidate:** "Good edge case. The tier lookup is cached locally with a TTL:

```python
def get_user_tier(user_id):
    cached = local_cache.get(f'tier:{user_id}')
    if cached and not stale(cached):
        return cached

    # Query database
    tier = db.query('SELECT tier FROM users WHERE id = ?', user_id)
    local_cache.set(f'tier:{user_id}', tier, ttl=300)  # 5 minute cache
    return tier
```

If a user upgrades:
1. The API server will pick up the new tier within 5 minutes (cache TTL)
2. We could also invalidate the cache on upgrade:
   - When user upgrades, publish event: `user_tier_changed:{user_id}`
   - All API servers subscribe, invalidate local cache on event
   - New tier is effective immediately

For rate limiting itself, the new limits apply immediately on the next request. We don't need to retroactively adjust — if they were rate limited as Free, and now they're Pro, their next request will use Pro limits."

---

**Interviewer:** "One more — how would you handle rate limiting for anonymous users (no user ID)?"

**Candidate:** "For anonymous users, we typically rate limit by IP address:

```python
def get_user_identifier(request):
    if request.user:
        return f'user:{request.user.id}'
    else:
        # Anonymous - use IP address
        ip = request.headers.get('X-Forwarded-For', request.remote_addr)
        return f'ip:{ip}'
```

**Challenges:**
1. **NAT issues:** All users behind a corporate NAT share one IP — one aggressive user could exhaust the limit for everyone
2. **IP spoofing:** Attackers can spoof IPs (though harder with TCP)
3. **Mobile networks:** Mobile users share IPs and change frequently

**Mitigations:**
1. **Higher limits for IP-based rate limiting:** IP limits are usually higher (1000/min) than user limits (100/min)
2. **Combine with fingerprinting:** Use browser fingerprint, API key, or other identifiers
3. **Progressive challenges:** After N requests, require CAPTCHA or API key
4. **Separate limits:** Track IP and user separately, apply whichever is more restrictive"

---

## Phase 6: Wrap-Up (55-65 minutes)

### Mock Dialogue

**Interviewer:** "Great. To wrap up, what's the one thing you'd most want to improve if you had more time?"

**Candidate:** "I'd add **adaptive rate limiting** — dynamically adjusting limits based on system load.

```
Current: Static limits (100/min for Free, 1000/min for Pro)

Improved: Dynamic limits based on system health

if system_load > 80%:
    effective_limit = configured_limit × 0.5  # Reduce by 50%
elif system_load > 60%:
    effective_limit = configured_limit × 0.75
else:
    effective_limit = configured_limit

# Could even be per-user based on behavior
if user.has_history_of_abuse:
    effective_limit = effective_limit × 0.5
```

This protects the system during traffic spikes and allows us to be more lenient during quiet periods. It's commonly used in production but adds complexity."

---

**Interviewer:** "Any trade-offs you want to call out?"

**Candidate:** "Yes, several:

1. **Token Bucket vs Sliding Window:**
   - Chose Token Bucket for controlled bursting and memory efficiency
   - Trade-off: Allows bursts up to bucket capacity (may not be desired for all use cases)

2. **Fail-open vs Fail-closed:**
   - Chose fail-open for availability
   - Trade-off: During Redis outage, no rate limiting

3. **Lua script vs INCR:**
   - Chose Lua script for accuracy
   - Trade-off: Slightly higher latency, Redis blocking during script execution

4. **Library vs Service:**
   - Chose library for latency
   - Trade-off: Harder to update limits dynamically (need to redeploy library)

5. **Local cache for tiers:**
   - Reduces database load
   - Trade-off: Tier changes take up to 5 minutes to propagate"

---

## Interviewer Scorecard

### Strong Candidate Signals

| Area | What to Look For |
|------|------------------|
| **Algorithm knowledge** | Can explain 3+ algorithms with trade-offs |
| **Distributed systems** | Understands race conditions, atomicity, Redis patterns |
| **Edge cases** | Handles Redis failures, hot keys, anonymous users |
| **Trade-offs** | Names specific trade-offs for each decision |
| **Production thinking** | Mentions metrics, alerting, graceful degradation |

### Red Flags

- ❌ Only knows one algorithm (usually fixed window)
- ❌ Doesn't consider race conditions
- ❌ No failure handling (Redis goes down?)
- ❌ Can't explain why they chose an algorithm
- ❌ No consideration for anonymous users

---

## Follow-Up Questions

### Q1: "How would you implement a rate limiter that limits based on request cost? (e.g., search costs 10 points, read costs 1 point)"

**Expected Answer:**
```
Modify Token Bucket to consume variable tokens:

def check_rate_limit(user_id, cost):
    if tokens >= cost:
        tokens = tokens - cost
        return ALLOW
    else:
        return REJECT

Usage:
check_rate_limit(user_id, cost=10)  # Search
check_rate_limit(user_id, cost=1)   # Read
```

### Q2: "Design a rate limiter for a global API (multi-region)."

**Expected Answer:**
```
Challenges:
- Cross-region latency for Redis checks
- Users hitting different regions

Solutions:
1. Per-region rate limiting with sync (eventual consistency)
2. Local region Redis with async replication
3. Trade-off: Users could bypass by hitting multiple regions
4. Mitigation: Central 'budget' service that allocates quotas to regions
```

### Q3: "How would you add rate limiting to an existing API without breaking clients?"

**Expected Answer:**
```
1. Start with high limits (no impact on existing clients)
2. Add metrics to understand actual usage patterns
3. Gradually lower limits to target
4. Communicate with high-volume users before limiting
5. Add headers before enforcing (X-RateLimit-* without 429s)
6. Finally, enforce limits with 429 responses
```

---

## Summary Checklist

- [ ] Can explain 4 rate limiting algorithms
- [ ] Understands race conditions and atomicity
- [ ] Can implement Token Bucket in Redis with Lua
- [ ] Handles Redis failure gracefully
- [ ] Knows X-RateLimit header format
- [ ] Can discuss anonymous user rate limiting
- [ ] Understands hot key problem and solutions

---

**Next:** Mock Interview 3 (Booking System — Concurrency Deep Dive)
