# Mock Interview 4: News Feed / Timeline System

**Difficulty:** Hard (Scaling Focus)
**Duration:** 75-90 minutes
**Focus Areas:** Fan-out patterns, read-heavy optimization, hot-key handling, sharding

---

## Problem Statement

> **Interviewer:** "Design a news feed system like Twitter or Facebook's timeline. When users open the app, they should see posts from people they follow, ordered by recency with some ranking. Let's design this to support 100 million daily active users."

---

## Phase 1: Requirements & Scale Estimation (10 minutes)

### Clarifying Questions

**Candidate:** "Before I start designing, let me clarify the requirements. When you say 'news feed,' I want to make sure I'm solving the right problem:

1. **Functional requirements:**
   - Users can post short updates (text + media?)
   - Users can follow other users
   - Followers see posts from people they follow in their timeline
   - Is there also ranking beyond pure recency?

2. **Scale:**
   - You mentioned 100M DAU — is that a good number to use for estimation?
   - What's the typical read-to-write ratio? I'd expect reads to vastly outnumber writes.

3. **Consistency:**
   - Does the feed need to be strongly consistent, or is eventual consistency acceptable?
   - If I post something, do I need to see it immediately in my own feed?

4. **Features:**
   - Do we need likes, comments, shares?
   - Are we handling media (images, video) or just text?"

**Interviewer:** "Good questions. Let's scope it:

- **Functional:** Users post text (280 chars), follow others, see a timeline of posts from people they follow. Posts can have images. For now, skip likes/comments/shares — focus on the feed itself.
- **Scale:** 100M DAU is correct. Assume 50% post daily, each posting 2 tweets. Average user follows 200 accounts. Average user checks feed 10 times per day.
- **Consistency:** Eventual consistency is fine for most users. But your own posts should appear immediately in your feed.
- **Ranking:** Yes, not purely chronological — some algorithmic ranking, but for this exercise, assume 'recent posts weighted by engagement.'

Start with estimation."

---

### Back-of-Envelope Calculations

**Candidate:** "Let me estimate the scale.

**DAU:** 100 million daily active users

**Write load (posts per day):**
- 50% of users post daily = 50M posting users
- Each posts 2 times per day
- Total posts per day = 50M × 2 = **100M writes/day**

**Read load (feed views per day):**
- 100M DAU × 10 feed checks per day = **1B reads/day**

**Read-to-write ratio:** 1B : 100M = **10:1**

**QPS calculations:**
- Posts: 100M ÷ 100,000 = **1,000 posts/second**
- Feed reads: 1B ÷ 100,000 = **10,000 feed reads/second**

**Storage:**
- 100M posts/day × 280 bytes ≈ 28 GB/day of text
- Add images: assume 100KB average × 100M = 10 TB/day
- Monthly: 10 TB × 30 = **300 TB/month** of media
- This is significant — we need object storage + CDN

**Follow graph:**
- 100M users × 200 follows average = **20B follow relationships**
- This is a large graph — needs efficient storage and traversal

**Key insight:** This is a **read-heavy** system (10:1 ratio), but the real complexity is the **fan-out** — each post needs to be delivered to potentially millions of followers."

---

## Phase 2: High-Level Architecture (15 minutes)

### Core Components

**Candidate:** *[Drawing on whiteboard]*

```
┌─────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│   Mobile App    │────►│    Load Balancer │────►│   API Gateway    │
│   (iOS/Android) │◄────│                  │◄────│  (Rate Limiting) │
└─────────────────┘     └──────────────────┘     └────────┬─────────┘
                                                           │
                          ┌────────────────────────────────┼────────────────────────────────┐
                          │                                │                                │
                   ┌──────▼──────┐              ┌──────────▼──────────┐          ┌──────────▼──────────┐
                   │   Post      │              │      Feed           │          │      User           │
                   │   Service   │              │     Service         │          │     Service         │
                   │             │              │                     │          │                     │
                   └──────┬──────┘              └──────────┬──────────┘          └──────────┬──────────┘
                          │                                │                                │
                ┌─────────┴─────────┐             ┌─────────┴─────────┐           ┌─────────┴─────────┐
                │                   │             │                   │           │                   │
         ┌──────▼──────┐   ┌───────▼──────┐ ┌────▼────┐   ┌────────▼───────┐ ┌────▼────┐  ┌────────▼────┐
         │   PostgreSQL│   │   Object     │ │  Redis  │   │    Feed        │ │PostgreSQL│  │    Graph    │
         │   (Posts)   │   │   Storage    │ │ (Cache) │   │    Cache       │ │ (Users) │  │   DB        │
         │             │   │   + CDN      │ │         │   │                │ │         │  │ (Follows)   │
         └─────────────┘   └──────────────┘ └─────────┘   └────────────────┘ └─────────┘  └─────────────┘
```

**Narrating the architecture:**

"I'm starting with the basic spine: mobile app → load balancer → API gateway → services. The API gateway handles rate limiting, auth, and routing.

I've decomposed into three core services:

1. **Post Service:** Handles creating, reading, updating posts. Writes to PostgreSQL for durability, uploads media to object storage (S3) with CDN for fast delivery.

2. **Feed Service:** The heart of the system — generates and caches timelines. Uses Redis for fast feed retrieval.

3. **User Service:** Manages user profiles and the follow graph. The follow graph is critical — it determines whose posts appear in your feed.

Now, the key design decision is **how to build the feed** — that's where the complexity is."

---

## Phase 3: Deep Dive — Fan-Out Strategies (30 minutes)

### The Core Problem

**Interviewer:** "Good start. Let's go deep on the feed service. How do you actually build a user's timeline?"

**Candidate:** "The fundamental challenge is **fan-out** — when someone posts, that post needs to appear in the feeds of all their followers. There are three main patterns:

---

### Pattern 1: Pull Model (Read-Time Fan-Out)

**Candidate:** "In a pull model, we generate the feed **on demand** when the user requests it.

**How it works:**

```
GET /feed/user_123

1. Look up who user_123 follows:
   → SELECT followee_id FROM follows WHERE follower_id = 'user_123'
   → Returns: [user_A, user_B, user_C, ...] (up to 200 users)

2. Fetch recent posts from all followed users:
   → SELECT * FROM posts
     WHERE author_id IN (user_A, user_B, user_C, ...)
     ORDER BY created_at DESC
     LIMIT 50

3. Apply ranking algorithm
4. Return feed
```

**Pros:**
- Simple to implement
- Always fresh — no stale data
- Storage efficient — only store posts once

**Cons:**
- **Slow reads** — every feed view requires a complex query joining followed users + their posts
- Hard to cache — feeds are unique per user
- At 10K feed QPS, each query scans potentially millions of posts

**When to use:** Small systems (< 1M users) or when followers are few."

---

### Pattern 2: Push Model (Write-Time Fan-Out)

**Candidate:** "In a push model, we **pre-compute** feeds at write time.

**How it works:**

```
POST /tweets (user_A posts)

1. Insert post into database:
   → INSERT INTO posts (author_id, content, ...) VALUES (...)

2. Look up user_A's followers:
   → SELECT follower_id FROM follows WHERE followee_id = 'user_A'
   → Returns: [user_X, user_Y, user_Z, ...] (could be millions!)

3. For each follower, prepend post to their cached feed:
   → For each follower_id in followers:
       LPUSH feed:follower_id post_json
       LTRIM feed:follower_id 0 200  (keep last 200 posts)
```

**Pros:**
- **Fast reads** — feed is pre-computed, just fetch from cache: `LRANGE feed:user_123 0 50`
- Scales reads beautifully — O(1) lookup regardless of follow count

**Cons:**
- **Slow writes for popular users** — if user_A has 10M followers, that's 10M cache writes for one post
- **Storage explosion** — same post stored millions of times
- **Wasted work** — most followers won't read their feed

**When to use:** When most users have modest follower counts."

---

### Pattern 3: Hybrid Model (Recommended)

**Candidate:** "The hybrid model combines both: **push for normal users, pull for celebrities.**

**The threshold approach:**

```
When user posts:
  follower_count = get_follower_count(user_id)

  if follower_count < CELEBRITY_THRESHOLD (e.g., 10,000):
    # Push model — pre-compute for all followers
    for each follower in followers:
      LPUSH feed:follower_id post_json
  else:
    # Celebrity post — don't fan out
    # Followers will pull this at read time
    mark_as_celebrity_post(post_id)
```

**When user requests feed:**

```
GET /feed/user_123

1. Get pre-computed feed from cache:
   → feed_posts = LRANGE feed:user_123 0 50

2. Get posts from celebrities user follows:
   → celebrity_ids = get_celebrity_follows(user_123)
   → celebrity_posts = SELECT * FROM posts
                        WHERE author_id IN celebrity_ids
                        ORDER BY created_at DESC
                        LIMIT 20

3. Merge and sort by timestamp/ranking:
   → merged_feed = merge_by_time(feed_posts, celebrity_posts)

4. Return merged feed
```

**Why this works:**

- **99% of users** have < 10K followers → push model works great
- **1% of users** (celebrities) have massive followings → their posts are pulled at read time
- Celebrity posts are typically the most engaging, so fetching them live is acceptable

**Real-world example:** Twitter uses this exact hybrid approach. When a celebrity tweets, they don't push to millions of followers immediately — those followers pull the post when they refresh."

---

### Interviewer Pushback

**Interviewer:** "What happens when a regular user suddenly goes viral and crosses the celebrity threshold? Their old posts were pushed, but new ones won't be."

**Candidate:** "Good catch. There are a few strategies:

**Option 1: Re-compute on threshold crossing**
- When user crosses 10K followers, re-process their recent posts
- Push those posts to all existing followers
- This is a one-time cost

**Option 2: Hybrid read for borderline users**
- For users between 5K-15K followers, use both strategies
- Push to existing followers, but also mark for pull
- This creates a buffer zone

**Option 3: Accept the inconsistency**
- Old posts remain in pushed feeds
- New posts are pulled at read time
- The feed merge handles both seamlessly
- Users won't notice — they just see a continuous feed

I'd go with Option 3 for simplicity. The hybrid read already handles mixing pushed and pulled posts, so the transition is invisible to users."

---

## Phase 4: Data Model & Storage (15 minutes)

### Database Schema

**Candidate:** "Let me design the core tables:

```sql
-- Users table
CREATE TABLE users (
    id              BIGSERIAL PRIMARY KEY,
    username        VARCHAR(50) UNIQUE NOT NULL,
    display_name    VARCHAR(100),
    bio             TEXT,
    follower_count  INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    created_at      TIMESTAMP DEFAULT NOW()
);

-- Follows graph (critical table)
CREATE TABLE follows (
    follower_id   BIGINT NOT NULL REFERENCES users(id),
    followee_id   BIGINT NOT NULL REFERENCES users(id),
    created_at    TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (follower_id, followee_id)
);

-- Indexes for fast lookups
CREATE INDEX idx_follows_follower ON follows(follower_id);      -- Who am I following?
CREATE INDEX idx_follows_followee ON follows(followee_id);      -- Who follows me?
CREATE INDEX idx_follows_created ON follows(followee_id, created_at DESC);

-- Posts table
CREATE TABLE posts (
    id              BIGSERIAL PRIMARY KEY,
    author_id       BIGINT NOT NULL REFERENCES users(id),
    content         TEXT NOT NULL,
    media_urls      TEXT[],  -- Array of S3 URLs
    reply_to_id     BIGINT REFERENCES posts(id),
    like_count      INTEGER DEFAULT 0,
    repost_count    INTEGER DEFAULT 0,
    created_at      TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_posts_author ON posts(author_id, created_at DESC);  -- User's tweets
CREATE INDEX idx_posts_time ON posts(created_at DESC);               -- Global timeline
```

**Key design decisions:**

1. **Follows table is denormalized:** We store `follower_count` and `following_count` on the user record to avoid COUNT(*) queries.

2. **Posts have `reply_to_id`:** Enables threading without a separate replies table.

3. **Composite indexes:** `(author_id, created_at DESC)` lets us fetch a user's posts in order efficiently."

---

### Redis Cache Structure

**Candidate:** "For the feed cache, I'm using Redis lists:

```
# Key pattern: feed:{user_id}
# Type: List (ordered by timestamp, newest first)

feed:user_123 = [
  {"post_id": "p_999", "author": "user_A", "content": "...", "timestamp": 1234567890},
  {"post_id": "p_998", "author": "user_B", "content": "...", "timestamp": 1234567880},
  ...
  (up to 200 posts)
]

# Operations:
# - Push new post: LPUSH feed:user_123 post_json
# - Trim to size: LTRIM feed:user_123 0 199
# - Get feed: LRANGE feed:user_123 0 49 (first 50 posts)
```

**Memory estimation:**

- 100M users × 200 posts × 500 bytes per post ≈ **10 TB of Redis data**
- This is too large for a single Redis instance
- We need **Redis Cluster** with sharding by user_id

```
# Sharding strategy
shard_id = hash(user_id) % NUM_SHARDS

feed:user_123 → shard_3
feed:user_456 → shard_7
```

**Handling celebrity reads:**

```
# Cache for celebrity posts (pulled at read time)
# Key pattern: celebrity_posts:{celebrity_id}
# TTL: 1 hour

celebrity_posts:user_celebrity = [
  {"post_id": "p_1000", "content": "...", "timestamp": ...},
  ...
]

# This cache is shared across all followers
# One copy, many readers
```

---

## Phase 5: Scaling to 100M Users (15 minutes)

### Database Sharding

**Interviewer:** "PostgreSQL will choke on 100M posts per day. How do you shard?"

**Candidate:** "Great question. Let me think about the access patterns:

**Query patterns:**
1. Fetch user's posts: `WHERE author_id = ?`
2. Fetch posts from followed users: `WHERE author_id IN (?, ?, ...)`
3. Fetch global timeline: `ORDER BY created_at DESC`

**Sharding by `author_id`:**

```
Shard 1: Users A-E → posts_1
Shard 2: Users F-J → posts_2
Shard 3: Users K-O → posts_3
...

Routing: shard_id = hash(author_id) % NUM_SHARDS
```

**Pros:**
- User's posts are co-located — great for their own timeline
- Easy to scale — add shards as user count grows

**Cons:**
- Query 2 (posts from followed users) may need to hit multiple shards
- If user follows 200 accounts spread across 10 shards, that's 10 database queries

**Mitigation: Application-side merge**

```python
def get_posts_from_followed_users(follower_id):
    # Get who they follow
    followed = db.query(
        "SELECT followee_id FROM follows WHERE follower_id = ?",
        follower_id
    )

    # Group followees by shard
    followees_by_shard = defaultdict(list)
    for followee in followed:
        shard = get_shard_for_user(followee.id)
        followees_by_shard[shard].append(followee.id)

    # Query each shard in parallel
    all_posts = []
    with ThreadPool() as pool:
        futures = []
        for shard, user_ids in followees_by_shard.items():
            futures.append(pool.submit(
                query_shard, shard, user_ids
            ))
        for future in futures:
            all_posts.extend(future.result())

    # Sort by timestamp
    all_posts.sort(key=lambda p: p.created_at, reverse=True)
    return all_posts[:50]
```

**Alternative: Use a read-optimized store**

For the `IN (...)` query pattern, consider:

- **Elasticsearch:** Great for querying across authors
- **Cassandra:** Wide-column store, efficient for time-series + multiple authors
- **Materialized views:** Pre-compute 'posts by followed users' in a separate table"

---

### Hot Key Problem

**Interviewer:** "What about hot keys? Say a celebrity posts and millions of users read that same post simultaneously."

**Candidate:** "This is the classic **hot key** problem. Let me trace through what happens:

**Scenario:** Taylor Swift posts → 50M followers need to see it

**Without mitigation:**

```
t=0: Taylor posts
t=1: Cache miss on celebrity_posts:taylor_swift
t=2: 10K requests/second all hit database for the same post
t=3: Database overloaded, latency spikes
```

**Solutions:**

**1. Multi-level caching:**

```
L1: Application memory cache (per-server)
L2: Redis cache (shared)
L3: Database

When celebrity post is requested:
  1. Check L1 — if found, return (fastest, no network)
  2. Check L2 — if found, return + populate L1
  3. Query database + populate L2 + populate L1
```

**2. Read replicas for hot keys:**

```
# Detect hot keys automatically
hot_keys = track_read_frequency(post_ids)

if post_id in hot_keys:
    # Replicate to multiple Redis nodes
    replicate_to_nodes(post_id, target_copies=10)

# Route reads across replicas
replica = consistent_hash(post_id + random()) % num_replicas
return redis[replica].GET(post_id)
```

**3. CDN for media:**

```
# Images/videos go to CDN, not database
POST /upload
  → Upload to S3
  → CDN edge caches the image
  → Post stores CDN URL: https://cdn.example.com/media/abc123.jpg

# Millions of image requests hit CDN edge, not origin
```

**4. Probabilistic early expiration:**

```
# For extremely hot posts, don't wait for TTL
# Randomly expire some cache entries early

def should_expire_early(post_id, read_count):
    # Hotter posts = higher probability of early expiry
    probability = min(0.9, read_count / 1_000_000)
    return random() < probability

if should_expire_early(post_id, read_count):
    cache.delete(post_id)  # Force refresh, spread load
```

---

## Phase 6: Failure Handling & Trade-offs (10 minutes)

### Graceful Degradation

**Interviewer:** "What happens if Redis goes down?"

**Candidate:** "The system should degrade gracefully:

**Fallback chain:**

```
def get_user_feed(user_id):
    try:
        # Try Redis cache first
        feed = redis.GET(f"feed:{user_id}")
        if feed:
            return feed
    except RedisConnectionError:
        # Redis is down — log and continue
        log.error("Redis unavailable, falling back to database")

    # Fallback: Generate feed from database
    feed = generate_feed_from_db(user_id)

    # Try to cache for next time (but don't fail if Redis still down)
    try:
        redis.SET(f"feed:{user_id}", feed, ex=300)
    except:
        pass

    return feed
```

**Impact:**

- Feed generation becomes slower (database queries instead of cache lookup)
- Database load increases significantly
- But **the system still works** — users can still see their feed

**Circuit breaker pattern:**

```python
class FeedService:
    def __init__(self):
        self.circuit_breaker = CircuitBreaker(
            failure_threshold=5,    # 5 failures in a row
            recovery_timeout=30     # Wait 30s before retrying
        )

    def get_feed(self, user_id):
        if self.circuit_breaker.is_open():
            # Redis is down — skip cache entirely
            return self.generate_from_db(user_id)

        try:
            feed = self.redis.get(f"feed:{user_id}")
            self.circuit_breaker.record_success()
            return feed
        except Exception as e:
            self.circuit_breaker.record_failure()
            raise
```

---

### Consistency vs Availability

**Interviewer:** "You mentioned eventual consistency. Walk me through a scenario where consistency matters."

**Candidate:** "Sure. Let's consider the **user's own posts**:

**Requirement:** When I post, I should see my post immediately in my feed.

**Problem with push model:**

```
t=0: Alice posts "Hello!"
t=1: Push to followers' feeds (async, takes time)
t=2: Alice refreshes her feed
t=3: Her feed was cached at t=-1, doesn't include her new post
t=4: Alice sees stale feed — her post is missing!
```

**Solution: Read-your-writes consistency**

```python
def get_user_feed(user_id, include_own_posts=True):
    # Get cached feed
    feed = redis.GET(f"feed:{user_id}")

    if include_own_posts:
        # Fetch user's own recent posts separately
        own_posts = db.query(
            "SELECT * FROM posts WHERE author_id = ? ORDER BY created_at DESC LIMIT 10",
            user_id
        )

        # Merge: own posts take precedence (they're freshest)
        feed = merge_by_time(feed, own_posts)

    return feed

def create_post(user_id, content):
    # Insert into database
    post = db.insert("posts", {"author_id": user_id, "content": content})

    # Invalidate user's own feed cache (forces regeneration)
    redis.DELETE(f"feed:{user_id}")

    # Push to followers (async)
    push_to_followers.delay(post)

    return post
```

**Trade-off:**

- We're accepting that **followers' feeds may be slightly stale** (seconds behind)
- But the **author's view is always consistent**
- This is the right trade-off for user experience — I care more about seeing my own posts immediately than seeing others' posts instantly"

---

## Phase 7: Wrap-Up (5 minutes)

### Summary

**Candidate:** "Let me summarize the key design decisions:

**1. Fan-out strategy:** Hybrid push/pull model
- Push for normal users (< 10K followers)
- Pull for celebrities (≥ 10K followers)
- Balances write amplification with read latency

**2. Storage:**
- PostgreSQL sharded by author_id for posts
- Redis Cluster for feed caches (sharded by user_id)
- S3 + CDN for media

**3. Scaling:**
- Read replicas for hot celebrity posts
- Multi-level caching (app memory → Redis → DB)
- Circuit breaker for graceful degradation

**4. Consistency:**
- Eventual consistency for followers' feeds
- Read-your-writes consistency for author's own posts
- Acceptable trade-off for this use case"

---

### If I Had More Time

**Candidate:** "The biggest gap is **ranking**. Right now, I've described a chronological feed. A real feed needs:

- Engagement signals (likes, shares, replies)
- User preferences (topics, accounts they interact with)
- Anti-spam filtering
- Diversity (not showing 50 posts from the same account)

I'd add a **ranking service** that scores posts:

```
ranking_score = (
    0.3 * recency_score +
    0.3 * engagement_score +
    0.2 * affinity_score +
    0.1 * diversity_bonus +
    0.1 * content_quality
)
```

But that's a machine learning problem on top of the infrastructure I've designed."

---

### Follow-Up Questions Interviewers Ask

| Question | What They're Testing |
|----------|---------------------|
| "How would you handle a user with 100M followers?" | Hot-key mitigation, celebrity handling |
| "What if the feed needs to be personalized beyond who you follow?" | Ranking algorithms, ML integration |
| "How do you detect and prevent spam?" | Content moderation, rate limiting |
| "What's your backup strategy if a shard dies?" | Data durability, replication |
| "How would you add 'trending topics'?" | Real-time aggregation, stream processing |

---

## Interviewer Scorecard

### What Strong Candidates Do

| Criterion | Strong Candidate | Weak Candidate |
|-----------|-----------------|----------------|
| **Estimation** | Calculates read/write ratio, identifies 10:1 as key constraint | Only calculates one metric |
| **Fan-out choice** | Explains all 3 patterns, justifies hybrid with threshold | Only knows one pattern |
| **Celebrity handling** | Pull model for hot users, explains trade-off | Tries to push to millions of followers |
| **Scaling** | Sharding strategy tied to query patterns | Says "use microservices" without detail |
| **Failure handling** | Graceful degradation with circuit breaker | "Redis doesn't go down" |
| **Consistency** | Read-your-writes for author, eventual for followers | Says "strong consistency" without justification |

### Red Flags

❌ **Pushing to millions:** "I'd iterate through all followers and insert the post" — no consideration for scale

❌ **Ignoring hot keys:** Designing a single cache key for celebrity posts

❌ **Over-engineering early:** Adding Kafka, Kubernetes, service mesh before proving the need

❌ **No fallback:** "If Redis is down, the feature doesn't work"

❌ **Vague sharding:** "Just shard the database" without explaining the key or query implications

---

## Full Mock Dialogue: Key Moments

### Moment 1: Fan-Out Discussion

```
Interviewer: "How do you build the feed?"

Candidate: "There are three main patterns I'd consider. Can I ask — what's
the typical follower distribution? Are most users following a few hundred
accounts, or are there many celebrities with millions of followers?"

Interviewer: "Good question. Let's say 99% of users have < 10K followers,
but the top 1% have up to 100M."

Candidate: "That's a classic power-law distribution. Given that, I'd use a
hybrid approach. For the 99% with modest followings, I'll push posts to
followers' feeds at write time. This makes reads O(1) — just fetch the
cached feed. But for celebrities, pushing to millions is wasteful. So I'll
pull their posts at read time and merge them in."

Interviewer: "What's the threshold?"

Candidate: "I'd start with 10K followers as the cutoff. Below that, push.
Above, pull. The exact number depends on write vs read costs — I'd monitor
and adjust. The key is the hybrid read handles both seamlessly."
```

### Moment 2: Hot Key Handling

```
Interviewer: "A celebrity tweets. 10 million requests hit your system in
one second for the same post. What happens?"

Candidate: "This is the hot key problem. Let me trace through my design.
First, the post itself — I'm storing it in PostgreSQL sharded by author_id,
so the write is isolated to one shard. The read is the problem.

I have three defenses:

First, caching. The first request misses cache, hits the database, and
populates Redis. But 10M requests in one second means even that first
database hit could be a thundering herd.

So second, I'd add application-level caching. Each API server keeps
recent hot posts in local memory. Requests distribute across servers,
so only a fraction hit Redis.

Third, I'd proactively replicate hot posts across multiple Redis nodes.
When I detect a post is getting > 1000 reads/second, I create copies on
different shards and route reads round-robin.

If that's not enough, I'd use probabilistic early expiration — randomly
expire some cache entries before their TTL to spread the refresh load."
```

### Moment 3: Failure Scenario

```
Interviewer: "Redis Cluster goes down completely. What happens?"

Candidate: "My system degrades gracefully. The feed service has a circuit
breaker — when it detects Redis is unreachable, it opens the circuit and
skips cache entirely. All reads go to the database.

The database is sized for this — it can handle the load for a few minutes.
I'd also have read replicas that can take over if the primary is
overwhelmed.

Meanwhile, alerts fire. On-call gets paged. The team investigates.

If Redis is down for more than a few minutes, I'd start rate-limiting feed
reads to protect the database. Better to show 50% of users a feed than to
crash entirely."

Interviewer: "What about writes?"

Candidate: "Writes still work — posts go to PostgreSQL, which is
independent of Redis. The only impact is followers won't see new posts
until Redis recovers and caches are repopulated. But the data isn't lost."
```

---

## Key Takeaways

### Memorable Anchors

1. **Fan-out is the core problem:** Push (write-time), Pull (read-time), or Hybrid (best of both)

2. **Celebrity threshold:** ~10K followers is where push becomes expensive

3. **Read-your-writes:** Your own posts must appear immediately, even if followers see them later

4. **Hot keys need defense:** Multi-level caching, replication, circuit breakers

5. **Graceful degradation:** When cache fails, fall back to database — don't just error out

### Phrases That Show Experience

- "The hybrid model handles the power-law distribution of followers..."
- "I'm accepting eventual consistency for followers but read-your-writes for the author..."
- "Circuit breaker pattern prevents cascading failures when Redis is down..."
- "We'd detect hot keys by tracking read frequency and proactively replicate..."
- "The right sharding strategy depends on query patterns — author_id gives us co-location..."

---

## Practice Questions

Try answering these out loud:

1. "How would you add 'trending topics' to this design?"
2. "What if we want to show ads in the feed?"
3. "How do you handle a user deleting a post that's already in millions of caches?"
4. "Design the 'likes' feature — how do you count and display likes at scale?"
5. "How would you modify this for a private network (corporate intranet) where everyone follows everyone?"

---

**End of Mock Interview 4**
