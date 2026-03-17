# Mock Interview 5: Real-time Chat System

**Difficulty:** Hard (Real-time Systems Focus)
**Duration:** 75-90 minutes
**Focus Areas:** WebSockets, message delivery guarantees, presence system, ordering, scaling stateful connections

---

## Problem Statement

> **Interviewer:** "Design a real-time chat system like WhatsApp or Slack. Users should be able to send messages to individuals and groups, see when others are typing, and know when messages are delivered and read. Let's design this to support 50 million daily active users."

---

## Phase 1: Requirements & Scale Estimation (10 minutes)

### Clarifying Questions

**Candidate:** "Let me clarify the requirements before diving in:

1. **Functional requirements:**
   - One-on-one messaging
   - Group messaging — how large can groups be?
   - Message types: text only, or media (images, files, voice)?
   - Presence indicators: online/offline/typing/read receipts?
   - Message history — how far back do we need to store?

2. **Delivery guarantees:**
   - Do messages need to be delivered in order?
   - What happens if a message fails to deliver — retry or fail?
   - Is at-least-once delivery required, or is at-most-once acceptable?

3. **Scale:**
   - 50M DAU — what's the message volume per user per day?
   - What's the peak concurrency — how many users online simultaneously?

4. **Platforms:**
   - Mobile apps, web, or both?
   - Do we need to support multiple devices per user?"

**Interviewer:** "Good questions. Here's the scope:

- **Functional:** One-on-one and group chats (up to 1000 members for groups). Text + images. Full presence system — online status, typing indicators, delivery and read receipts.
- **History:** Store messages indefinitely, but only show last 1000 messages in UI.
- **Delivery:** Messages must be delivered in order. At-least-once delivery — better to duplicate than lose.
- **Scale:** 50M DAU, each sends 20 messages/day. Peak concurrency is 10% of DAU = 5M concurrent connections.
- **Platforms:** Mobile and web. Users can have multiple devices — phone + laptop both receive messages."

---

### Back-of-Envelope Calculations

**Candidate:** "Let me estimate the scale.

**Daily Active Users:** 50 million

**Message volume:**
- 50M DAU × 20 messages/user/day = **1B messages/day**
- QPS: 1B ÷ 100,000 = **10,000 messages/second**
- Peak might be 3x average = **30,000 messages/second**

**Concurrent connections:**
- 10% of 50M = **5M concurrent WebSocket connections**
- This is the real scaling challenge — maintaining 5M persistent connections

**Storage:**
- Text: 1B messages/day × 500 bytes = 500 GB/day
- Monthly: 500 GB × 30 = **15 TB/month** of text
- Images: Assume 50% of messages have images × 100KB = 50 TB/day
- Monthly: **1.5 PB/month** of media — this dominates storage

**Read-to-write ratio:**
- For every message sent, multiple people read it
- One-on-one: 1 writer, 1 reader = 2 reads
- Groups (avg 50 members): 1 writer, 49 readers = 49 reads
- Assume avg 10 reads per write → **10:1 read ratio**

**Key insights:**

1. **Connection scale is the bottleneck** — 5M concurrent WebSocket connections requires careful architecture
2. **Ordering matters** — messages must appear in order per conversation
3. **Multi-device adds complexity** — same user on phone + laptop = duplicate deliveries
4. **Image storage dominates** — need object storage + CDN"

---

## Phase 2: High-Level Architecture (15 minutes)

### Core Components

**Candidate:** *[Drawing on whiteboard]*

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              Client Layer                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
│  │   Mobile    │  │   Mobile    │  │    Web      │  │    Web      │   │
│  │   (Alice)   │  │   (Bob)     │  │  (Alice)    │  │  (Bob)      │   │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘   │
└─────────┼────────────────┼────────────────┼────────────────┼──────────┘
          │                │                │                │
          └────────────────┴────────────────┴────────────────┘
                                   │
                          ┌────────▼────────┐
                          │  Load Balancer  │
                          │  (WebSocket-    │
                          │   aware, e.g.,  │
                          │   NLB/HAProxy)  │
                          └────────┬────────┘
                                   │
          ┌────────────────────────┼────────────────────────┐
          │                        │                        │
   ┌──────▼──────┐          ┌──────▼──────┐          ┌──────▼──────┐
   │  WebSocket  │          │  WebSocket  │          │  WebSocket  │
   │   Server    │          │   Server    │          │   Server    │
   │   (Pool A)  │          │   (Pool B)  │          │   (Pool C)  │
   │  10K conns  │          │  10K conns  │          │  10K conns  │
   └──────┬──────┘          └──────┬──────┘          └──────┬──────┘
          │                        │                        │
          └────────────────────────┼────────────────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
       ┌──────▼──────┐     ┌──────▼──────┐     ┌──────▼──────┐
       │   Message   │     │   Presence  │     │   Session   │
       │   Service   │     │   Service   │     │   Store     │
       │             │     │             │     │   (Redis)   │
       └──────┬──────┘     └──────┬──────┘     └─────────────┘
              │                   │
       ┌──────┴──────┐     ┌──────┴──────┐
       │             │     │             │
┌──────▼──────┐ ┌───▼──────▼─┐ ┌──▼───────▼──┐
│  PostgreSQL │ │   Kafka    │ │   Redis     │
│  (Messages) │ │   (Queue)  │ │   (Cache)   │
└─────────────┘ └────────────┘ └─────────────┘
       │
┌──────▼──────┐
│ Object      │
│ Storage +   │
│ CDN         │
│ (Images)    │
└─────────────┘
```

**Narrating the architecture:**

"The key insight here is that **WebSocket connections are stateful** — unlike HTTP where each request is independent, a WebSocket connection persists. This changes everything about scaling.

**Connection Layer:**

- Load balancer must be WebSocket-aware (NLB, HAProxy, or AWS ALB with WebSocket support)
- Health checks based on connection health, not just HTTP 200
- Sticky sessions — once a client connects to a WebSocket server, stay there

**WebSocket Server Pool:**

- Each server maintains persistent connections to clients
- A single server can handle ~10K-50K concurrent connections (memory-bound)
- For 5M connections: 5M ÷ 10K = **500 WebSocket servers minimum**
- I'd run 1000+ for headroom and failover

**Session Store (Redis):**

- Tracks which user is connected to which WebSocket server
- Key for handling multi-device: one user can have multiple sessions
- Critical for routing messages to the right server

**Message Service:**

- Handles message persistence, ordering, delivery
- Uses Kafka for async processing — decouples sending from delivery
- At-least-once delivery via Kafka consumer retries

**Presence Service:**

- Manages online/offline status, typing indicators
- Heartbeat-based liveness detection
- Separate from message path to avoid coupling

This is a **stateful architecture** — the WebSocket servers have in-memory connection state. That's different from the stateless API servers we've designed before."

---

## Phase 3: Deep Dive — WebSocket Connection Management (25 minutes)

### Connection Lifecycle

**Interviewer:** "Walk me through what happens when a user opens the app and connects."

**Candidate:** "Let me trace the full connection flow:

```
┌──────────┐                                              ┌─────────────┐
│  Client  │                                              │WebSocket Svr│
│  (Alice) │                                              │   (Pool A)  │
└────┬─────┘                                              └──────┬──────┘
     │                                                           │
     │  1. HTTP Upgrade: WebSocket Upgrade                       │
     │     headers: Sec-WebSocket-Key, Origin                    │
     │  ───────────────────────────────────────────────────────► │
     │                                                           │
     │  2. HTTP 101 Switching Protocols                          │
     │     Sec-WebSocket-Accept: <computed>                      │
     │  ◄─────────────────────────────────────────────────────────│
     │                                                           │
     │  [WebSocket connection established]                       │
     │                                                           │
     │  3. Auth message (over WebSocket)                         │
     │     {"type": "auth", "token": "jwt_token_here"}           │
     │  ───────────────────────────────────────────────────────► │
     │                                                           │
     │  4. Auth confirmed + session registration                 │
     │     {"type": "auth_ok", "session_id": "sess_abc123"}      │
     │  ◄─────────────────────────────────────────────────────────│
     │                                                           │
     │  5. Heartbeat (ping/pong every 30s)                       │
     │     ◄──────────────────────────────────────────────────►  │
     │                                                           │
```

**Step-by-step:**

**1. WebSocket Handshake (HTTP Upgrade):**

```javascript
// Client initiates
GET wss://chat.example.com/socket HTTP/1.1
Host: chat.example.com
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
Sec-WebSocket-Version: 13
Origin: https://app.example.com

// Server responds
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=
```

The `Sec-WebSocket-Accept` is computed from the key — this prevents caching proxies from interfering.

**2. Authentication:**

Important: **Don't authenticate in the HTTP handshake.** Why?

- The handshake happens before you can read custom headers in many frameworks
- Tokens in URLs leak in logs
- Better to authenticate after connection is established

```javascript
// Client sends auth message over WebSocket
{
  "type": "auth",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "device_id": "iphone_14_pro_max",
  "client_version": "3.2.1"
}

// Server validates JWT, extracts user_id
// If valid:
{
  "type": "auth_ok",
  "session_id": "sess_abc123",
  "server_id": "ws_server_42"
}

// If invalid:
{
  "type": "auth_error",
  "reason": "token_expired"
}
// Then server closes connection
```

**3. Session Registration:**

After auth succeeds, the WebSocket server registers the session:

```python
async def on_auth_success(user_id, device_id, session_id):
    # Register in session store
    await redis.hset(
        f"user_sessions:{user_id}",
        mapping={
            device_id: json.dumps({
                "session_id": session_id,
                "server_id": CURRENT_SERVER_ID,
                "connected_at": time.time(),
                "device_type": detect_device_type()
            })
        }
    )

    # Track server → users mapping (for fanout later)
    await redis.sadd(f"server_users:{CURRENT_SERVER_ID}", user_id)

    # Update presence
    await redis.setex(f"online:{user_id}", 300, "true")  # 5 min TTL
```

---

### Heartbeat & Connection Health

**Interviewer:** "How do you detect if a connection is dead?"

**Candidate:** "Great question. There are two levels of heartbeats:

**Level 1: WebSocket Protocol Ping/Pong**

```javascript
// WebSocket protocol has built-in ping/pong frames
// These are handled by the WebSocket library

// Server sends ping frame (binary, not visible to application)
// Client's WebSocket stack automatically responds with pong

// If no pong after N pings → connection is dead, clean up
```

**Level 2: Application-Level Heartbeat**

```python
# Client sends heartbeat every 30 seconds
{
  "type": "heartbeat",
  "timestamp": 1234567890,
  "connection_quality": "good"  // Client-reported
}

# Server tracks last heartbeat
async def on_message(user_id, message):
    if message["type"] == "heartbeat":
        await redis.setex(f"heartbeat:{user_id}", 60, str(time.time()))
        return

# Monitor for stale connections
async def health_checker():
    while True:
        await asyncio.sleep(30)
        now = time.time()

        # Find servers with stale heartbeats
        all_servers = await redis.keys("server_users:*")

        for server_key in all_servers:
            server_id = server_key.split(":")[1]
            users = await redis.smembers(server_key)

            for user_id in users:
                last_heartbeat = await redis.get(f"heartbeat:{user_id}")
                if last_heartbeat and (now - float(last_heartbeat)) > 90:
                    # Connection is stale — clean up
                    await cleanup_stale_connection(user_id, server_id)
```

**Why both?**

- Protocol ping/pong detects TCP-level failures (network disconnected)
- Application heartbeat detects client-level failures (app crashed, battery died)

---

## Phase 4: Message Flow & Delivery Guarantees (25 minutes)

### Sending a Message

**Interviewer:** "Walk me through what happens when Alice sends a message to Bob."

**Candidate:** "Let me trace the full message flow:

```
┌──────────┐         ┌─────────────┐         ┌─────────────┐         ┌──────────┐
│  Alice   │         │ WebSocket   │         │   Message   │         │   Bob    │
│(Sender)  │         │   Server    │         │   Service   │         │(Receiver)│
└────┬─────┘         └──────┬──────┘         └──────┬──────┘         └────┬─────┘
     │                      │                       │                      │
     │ 1. Send message      │                       │                      │
     │─────────────────────►│                       │                      │
     │                      │                       │                      │
     │                      │ 2. Publish to Kafka   │                      │
     │                      │──────────────────────►│                      │
     │                      │                       │                      │
     │ 3. Ack received      │                       │                      │
     │◄─────────────────────│                       │                      │
     │                      │                       │                      │
     │                      │                       │ 4. Persist to DB     │
     │                      │                       │──────────┐           │
     │                      │                       │          │           │
     │                      │                       │◄─────────┘           │
     │                      │                       │                      │
     │                      │                       │ 5. Route to Bob's    │
     │                      │                       │    WebSocket server  │
     │                      │                       │─────────────────────►│
     │                      │                       │                      │
     │                      │                       │                      │ 6. Deliver over WebSocket
     │                      │                       │                      │──────────────────────►
     │                      │                       │                      │
     │                      │                       │                      │ 7. Delivery receipt
     │                      │                       │                      │◄───────────────────────
     │                      │                       │                      │
     │ 8. Delivery status   │                       │                      │
     │◄─────────────────────────────────────────────────────────────────────│
     │                      │                       │                      │
```

**Step 1: Client sends message**

```javascript
// Alice's client sends:
{
  "type": "message",
  "conversation_id": "conv_alice_bob",
  "content": "Hey Bob!",
  "local_id": "local_123",  // Client-generated ID for dedup
  "timestamp": 1234567890
}
```

**Step 2: WebSocket server publishes to Kafka**

```python
async def on_message(user_id, message):
    # Validate message
    if not validate_message(message):
        send_error(user_id, "Invalid message")
        return

    # Assign sequence number for ordering
    seq_num = await get_next_sequence(message["conversation_id"])
    message["seq_num"] = seq_num
    message["sender_id"] = user_id

    # Publish to Kafka
    kafka.produce(
        topic="chat_messages",
        key=message["conversation_id"],  # Same conv_id → same partition
        value=json.dumps(message)
    )

    # Ack to sender (message received, not yet delivered)
    send_to_client(user_id, {
        "type": "message_ack",
        "local_id": message["local_id"],
        "server_id": message["id"],
        "seq_num": seq_num,
        "status": "sent"  // sent → delivered → read
    })
```

**Why Kafka?**

- **Durability:** Messages persist even if Message Service crashes
- **Ordering:** Same conversation_id → same partition → FIFO order
- **Backpressure:** If delivery is slow, Kafka buffers
- **Replay:** Can re-process messages if there's a bug

**Step 3-4: Persist to database**

```python
# Kafka consumer in Message Service
async def consume_messages():
    consumer = kafka_consumer("chat_messages")

    async for message in consumer:
        # Insert into database
        await db.execute("""
            INSERT INTO messages
            (id, conversation_id, sender_id, content, seq_num, created_at)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (
            message["id"],
            message["conversation_id"],
            message["sender_id"],
            message["content"],
            message["seq_num"],
            message["timestamp"]
        ))

        # Route to recipient(s)
        await route_message(message)
```

---

### Message Ordering Guarantee

**Interviewer:** "How do you guarantee messages arrive in order?"

**Candidate:** "Message ordering is per-conversation, not global. Here's how I ensure it:

**Problem: Naive approach fails**

```
Alice sends: "Hello" → seq_num=1
             "How are you?" → seq_num=2

Network routing:
  "How are you?" takes faster path → Bob receives first
  "Hello" arrives later → Bob sees messages out of order!
```

**Solution 1: Kafka partitioning by conversation_id**

```python
# When publishing to Kafka:
kafka.produce(
    topic="chat_messages",
    key=message["conversation_id"],  # Key determines partition
    value=message
)

# All messages for conv_alice_bob go to partition 3
# Within a partition, Kafka guarantees FIFO order
# Consumers read from partition in order
```

**Solution 2: Sequence numbers**

```python
# Each conversation has its own sequence counter
async def get_next_sequence(conversation_id):
    seq = await redis.incr(f"seq:{conversation_id}")
    return seq

# Messages for conv_alice_bob:
# seq_num=1: "Hello"
# seq_num=2: "How are you?"
# seq_num=3: "Did you get my last message?"

# Recipient's client buffers and reorders:
async def on_message_received(message):
    expected_seq = last_seq + 1

    if message["seq_num"] == expected_seq:
        # In order — display immediately
        display_message(message)
        last_seq = message["seq_num"]
    else:
        # Out of order — buffer and wait
        pending_buffer[message["seq_num"]] = message

        # Check if we can fill gaps
        while expected_seq + 1 in pending_buffer:
            expected_seq += 1
            display_message(pending_buffer.pop(expected_seq))
```

**Solution 3: Idempotency on client**

```python
# Client tracks received message IDs
received_ids = set()

async def on_message_received(message):
    if message["id"] in received_ids:
        # Duplicate — ignore (at-least-once delivery)
        return

    received_ids.add(message["id"])
    display_message(message)
```

---

### Handling Offline Users

**Interviewer:** "What if Bob is offline when Alice sends a message?"

**Candidate:** "Good question. Let me trace the offline flow:

```
Step 1: Route message, discover Bob is offline
  → Session lookup returns: no active sessions for user_bob
  → Mark message as "pending delivery"

Step 2: Store in database (already happens)
  → messages table has "delivered" flag

Step 3: When Bob reconnects:
  → Fetch undelivered messages from database
  → Push to Bob's client
```

**Database schema:**

```sql
CREATE TABLE messages (
    id              UUID PRIMARY KEY,
    conversation_id UUID NOT NULL,
    sender_id       UUID NOT NULL,
    content         TEXT,
    seq_num         INTEGER NOT NULL,
    status          VARCHAR(20) DEFAULT 'sent',  -- sent, delivered, read
    created_at      TIMESTAMP DEFAULT NOW(),
    delivered_at    TIMESTAMP,
    read_at         TIMESTAMP,
    UNIQUE (conversation_id, seq_num)
);

-- Index for fetching undelivered messages
CREATE INDEX idx_messages_pending
    ON messages (conversation_id, status)
    WHERE status = 'sent';
```

**Reconnection flow:**

```python
async def on_user_connect(user_id):
    # Fetch undelivered messages
    undelivered = await db.query("""
        SELECT * FROM messages
        WHERE conversation_id IN (
            SELECT conversation_id FROM conversation_members
            WHERE user_id = ?
        )
        AND status = 'sent'
        ORDER BY created_at ASC
        LIMIT 100
    """, user_id)

    # Push to client
    for message in undelivered:
        send_to_client(user_id, {
            "type": "message",
            **message,
            "is_historical": True  # Flag for client
        })

    # Mark as delivered
    await db.execute("""
        UPDATE messages
        SET status = 'delivered', delivered_at = NOW()
        WHERE id IN (?)
    """, [m["id"] for m in undelivered])
```

---

## Phase 5: Group Chat Scaling (15 minutes)

### The Fan-Out Problem

**Interviewer:** "How does group chat differ from one-on-one?"

**Candidate:** "Group chat introduces **fan-out** — one sender, many recipients. The scaling depends on group size.

**Small groups (< 50 members): Simple fan-out**

```python
async def send_group_message(message, group_id):
    # Get all members
    members = await get_group_members(group_id)  # Returns 50 user_ids

    # Deliver to each member
    for member_id in members:
        if member_id == message["sender_id"]:
            continue  # Don't send to self

        # Find member's WebSocket server
        session = await redis.hgetall(f"user_sessions:{member_id}")

        for device_id, session_info in session.items():
            server_id = session_info["server_id"]

            # Route to that server
            await route_to_server(server_id, member_id, message)
```

**Large groups (100-1000 members): Optimized fan-out**

```python
async def send_large_group_message(message, group_id):
    # For large groups, fan-out at the database layer
    # Each recipient fetches messages when they reconnect or poll

    # 1. Store message once
    await db.insert("messages", message)

    # 2. Notify online members (don't wait for delivery)
    online_members = await get_online_group_members(group_id)

    for member_id in online_members:
        session = await get_session(member_id)
        if session:
            # Fire-and-forget — no retry if fails
            fire_and_forget_delivery(session["server_id"], member_id, message)

    # 3. Offline members will fetch on reconnect (see previous section)
```

**The broadcast optimization:**

```python
# Instead of N individual deliveries, use pub/sub

async def broadcast_to_group(group_id, message):
    # Publish to group channel
    await redis.publish(f"group:{group_id}", message)

# Each WebSocket server subscribes to groups its users are in
async def subscribe_to_groups():
    pubsub = redis.pubsub()

    # Subscribe to all groups (or use sharding)
    await pubsub.psubscribe("group:*")

    async for event in pubsub.listen():
        channel = event["channel"]
        message = event["data"]

        # Check if any local users are in this group
        local_users = get_local_users_in_group(channel)

        for user_id in local_users:
            send_to_client(user_id, message)
```

---

### Group Membership Caching

**Interviewer:** "Looking up group members for every message seems slow."

**Candidate:** "Absolutely — that's why we cache group membership:

```python
# Cache group members in Redis
# Key: group_members:{group_id}
# Type: Set

async def get_group_members(group_id):
    # Try cache first
    members = await redis.smembers(f"group_members:{group_id}")
    if members:
        return members

    # Cache miss — load from database
    members = await db.query("""
        SELECT user_id FROM group_members
        WHERE group_id = ? AND status = 'active'
    """, group_id)

    # Populate cache with TTL
    if members:
        await redis.sadd(f"group_members:{group_id}", *members)
        await redis.expire(f"group_members:{group_id}", 3600)  # 1 hour

    return members

# Invalidate cache on membership change
async def add_member_to_group(group_id, user_id):
    await db.insert("group_members", {"group_id": group_id, "user_id": user_id})
    await redis.sadd(f"group_members:{group_id}", user_id)
    # Don't invalidate entire cache — just add
```

**Memory estimation for caching:**

- 1M groups × 100 members avg × 8 bytes per user_id = 800 MB
- Well within Redis capacity
- TTL ensures stale data self-corrects"

---

## Phase 6: Presence System (15 minutes)

### Online/Offline Status

**Interviewer:** "Design the presence system — online status, typing indicators."

**Candidate:** "Presence is a separate concern from messaging. Let me design it:

**Data model:**

```python
# Online status
# Key: online:{user_id}
# Type: String (JSON)
# TTL: 5 minutes (refreshed by heartbeat)

online:user_123 = {
    "status": "online",
    "devices": ["iphone", "chrome_mac"],
    "last_seen": 1234567890
}

# Typing indicator
# Key: typing:{conversation_id}:{user_id}
# Type: String
# TTL: 5 seconds (auto-expires when user stops typing)

typing:conv_alice_bob:user_alice = "typing..."
```

**Setting online status:**

```python
async def on_user_connect(user_id, device_id):
    # Add device to online set
    await redis.hset(
        f"online:{user_id}",
        device_id,
        json.dumps({
            "connected_at": time.time(),
            "device_type": detect_device(device_id)
        })
    )

    # Set overall online status
    await redis.setex(f"user_online:{user_id}", 300, "true")

    # Publish presence update to subscribers
    await redis.publish(f"presence:{user_id}", json.dumps({
        "user_id": user_id,
        "status": "online",
        "timestamp": time.time()
    }))

async def on_user_disconnect(user_id, device_id):
    # Remove device
    await redis.hdel(f"online:{user_id}", device_id)

    # Check if any devices remain online
    remaining = await redis.hlen(f"online:{user_id}")
    if remaining == 0:
        await redis.delete(f"user_online:{user_id}")

        # Publish offline status
        await redis.publish(f"presence:{user_id}", json.dumps({
            "user_id": user_id,
            "status": "offline",
            "timestamp": time.time()
        }))
```

**Subscribing to presence:**

```python
# When Alice opens chat with Bob, subscribe to his presence
async def open_chat_with(user_id, other_user_id):
    # Subscribe to presence updates
    await redis.psubscribe(f"presence:{other_user_id}")

    # Get current status
    is_online = await redis.exists(f"user_online:{other_user_id}")

    return {
        "user_id": other_user_id,
        "status": "online" if is_online else "offline",
        "last_seen": await get_last_seen(other_user_id)
    }

# Listen for updates
async def presence_listener(user_id):
    pubsub = redis.pubsub()
    await pubsub.psubscribe("presence:*")

    async for event in pubsub.listen():
        channel = event["channel"]
        data = json.loads(event["data"])

        # Push to connected clients
        await push_to_subscribers(channel, data)
```

---

### Typing Indicators

**Candidate:** "Typing indicators are ephemeral — they auto-expire:

```python
# Client sends typing event
{
  "type": "typing",
  "conversation_id": "conv_alice_bob"
}

# Server sets short-lived key
async def on_typing(user_id, conversation_id):
    key = f"typing:{conversation_id}:{user_id}"

    # Set with 5 second TTL
    await redis.setex(key, 5, "typing")

    # Publish to subscribers (people in the conversation)
    await redis.publish(f"typing:{conversation_id}", json.dumps({
        "user_id": user_id,
        "status": "typing"
    }))

# Client subscribes to typing events
async def subscribe_to_typing(conversation_id):
    await redis.psubscribe(f"typing:{conversation_id}:*")

    async for event in pubsub.listen():
        # Show "User is typing..." indicator
        # When key expires (no more typing events), hide indicator
        pass
```

**Race condition handling:**

```
Alice types → sets typing:conv:user with 5s TTL
Alice stops typing → key expires after 5s
Alice types again within 5s → TTL refreshes

Client logic:
  On "typing" event → Show indicator, reset 5s timer
  If no event for 5s → Hide indicator (key expired)
```

---

## Phase 7: Scaling & Failure Handling (10 minutes)

### Scaling WebSocket Servers

**Interviewer:** "You have 5M concurrent connections. How do you scale WebSocket servers?"

**Candidate:** "The key insight is that WebSocket servers are **stateful** — they hold active connections in memory. This affects scaling:

**Horizontal scaling:**

```
┌─────────────────────────────────────────────────────────────┐
│                    Load Balancer (NLB)                       │
│   Distributes connections across WebSocket server pool      │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
   ┌────▼────┐          ┌────▼────┐          ┌────▼────┐
   │ WS Svr  │          │ WS Svr  │          │ WS Svr  │
   │ Pool A  │          │ Pool B  │          │ Pool C  │
   │ 500     │          │ 500     │          │ 500     │
   │ servers │          │ servers │          │ servers │
   │ 10K     │          │ 10K     │          │ 10K     │
   │ conns   │          │ conns   │          │ conns   │
   └─────────┘          └─────────┘          └─────────┘

Total: 1500 servers × 10K connections = 15M connection capacity
For 5M connections: 500 servers (with headroom)
```

**Connection draining for deploys:**

```python
# Don't just kill servers — gracefully migrate connections

async def graceful_shutdown(server_id):
    # 1. Stop accepting new connections
    mark_server_draining(server_id)

    # 2. Notify connected clients to reconnect
    for user_id in connected_users:
        send_to_client(user_id, {
            "type": "reconnect",
            "reason": "server_maintenance"
        })

    # 3. Wait for clients to reconnect to other servers
    await asyncio.sleep(30)  # Give time to reconnect

    # 4. Force close remaining connections
    for conn in active_connections:
        conn.close()

    # 5. Clean up session store
    await redis.delete(f"server_users:{server_id}")
```

---

### Handling Server Failures

**Interviewer:** "A WebSocket server crashes. What happens?"

**Candidate:** "Let me trace the failure and recovery:

**Detection:**

```python
# Health checker detects dead server
async def health_checker():
    while True:
        await asyncio.sleep(10)

        servers = await get_all_servers()
        for server in servers:
            if not await is_healthy(server):
                await handle_server_failure(server)

async def handle_server_failure(server_id):
    # 1. Get all users on that server
    user_ids = await redis.smembers(f"server_users:{server_id}")

    # 2. Clean up session store
    await redis.delete(f"server_users:{server_id}")

    # 3. For each user, check if they have other sessions
    for user_id in user_ids:
        sessions = await redis.hgetall(f"user_sessions:{user_id}")

        if len(sessions) <= 1:
            # This was their only session — mark offline
            await redis.delete(f"online:{user_id}")

            # Notify contacts
            await redis.publish(f"presence:{user_id}", json.dumps({
                "user_id": user_id,
                "status": "offline"
            }))
        else:
            # Remove this session, user still online via other device
            await redis.hdel(f"user_sessions:{user_id}", failed_device)
```

**Client reconnection:**

```javascript
// Client handles reconnection
ws.onclose = async (event) => {
  if (event.code === 1006) {
    // Abnormal closure — server probably died
    console.log("Connection lost, reconnecting...");

    // Exponential backoff
    let delay = 1000;
    while (!connected) {
      await sleep(delay);
      try {
        await connect();
        connected = true;
      } catch {
        delay *= 2;  // Double delay each retry
        delay = Math.min(delay, 30000);  // Max 30s
      }
    }

    // Fetch missed messages
    await fetch_missed_messages();
  }
};
```

**Missed message recovery:**

```python
async def fetch_missed_messages(user_id):
    # Get last received sequence per conversation
    last_seq = await db.query("""
        SELECT conversation_id, MAX(seq_num) as max_seq
        FROM messages
        WHERE recipient_id = ? AND status = 'delivered'
        GROUP BY conversation_id
    """, user_id)

    # Fetch messages after last_seq
    for conv_id, max_seq in last_seq:
        missed = await db.query("""
            SELECT * FROM messages
            WHERE conversation_id = ? AND seq_num > ?
            ORDER BY seq_num ASC
        """, conv_id, max_seq)

        for message in missed:
            send_to_client(user_id, message)
```

---

## Phase 8: Wrap-Up (5 minutes)

### Summary

**Candidate:** "Let me summarize the key design decisions:

**1. Connection Management:**
- WebSocket servers maintain stateful connections
- 500-1000 servers for 5M concurrent connections
- Session store (Redis) tracks user → server mapping

**2. Message Delivery:**
- Kafka for durability and ordering (partitioned by conversation_id)
- Sequence numbers for in-order delivery
- At-least-once with idempotency on client

**3. Group Chat:**
- Fan-out for small groups (< 50)
- Optimized delivery for large groups (100-1000)
- Cached group membership

**4. Presence System:**
- Separate from message path
- Heartbeat-based liveness
- Pub/sub for real-time updates

**5. Failure Handling:**
- Graceful degradation on server failure
- Client reconnection with exponential backoff
- Missed message recovery on reconnect"

---

### If I Had More Time

**Candidate:** "The biggest gap is **end-to-end encryption**. I haven't addressed:

- Key exchange (Signal protocol, double ratchet)
- Per-message encryption keys
- Group key management

Also, **moderation** at scale:
- Spam detection
- Abuse reporting
- Content filtering for images

And **search** — searching message history efficiently:
- Full-text search across conversations
- Indexing strategy
- Privacy considerations"

---

### Follow-Up Questions

| Question | What They're Testing |
|----------|---------------------|
| "How would you handle 10M person group chat (like a broadcast channel)?" | Extreme fan-out, push vs pull |
| "How does end-to-end encryption change the architecture?" | Security, key management |
| "What if users need to edit/delete sent messages?" | Idempotency, mutation handling |
| "How do you prevent spam/abuse?" | Rate limiting, moderation |
| "Design message reactions (emoji responses)" | Metadata, aggregation |

---

## Interviewer Scorecard

### What Strong Candidates Do

| Criterion | Strong Candidate | Weak Candidate |
|-----------|-----------------|----------------|
| **WebSocket understanding** | Explains stateful connections, heartbeat, graceful shutdown | Treats like HTTP, no connection management |
| **Ordering guarantee** | Kafka partitioning + sequence numbers + client reordering | "Database order" without details |
| **Multi-device** | Session store with device_id, fan-out to all devices | Single session per user |
| **Offline handling** | Store-and-forward, fetch on reconnect | "User must be online" |
| **Group scaling** | Different strategy for small vs large groups | Same fan-out for 2 and 1000 members |
| **Presence** | TTL-based, pub/sub, separate from messages | Polling-based, coupled with messages |

### Red Flags

❌ **No ordering guarantee:** "Messages arrive in order" — but no mechanism explained

❌ **HTTP polling:** "Clients poll every 5 seconds for new messages" — wrong for real-time

❌ **Ignoring multi-device:** One session per user, doesn't work for phone + laptop

❌ **No idempotency:** At-least-once delivery will cause duplicates

❌ **Coupled presence:** "Check if user is online by querying database" — too slow

---

## Full Mock Dialogue: Key Moments

### Moment 1: Connection Management

```
Interviewer: "How do you maintain 5M concurrent connections?"

Candidate: "The key is that WebSocket servers are stateful — each holds
active TCP connections in memory. A single server can handle about 10K
connections before running into memory limits. So for 5M connections, I
need about 500 servers.

The load balancer needs to be WebSocket-aware — it can't just do HTTP
round-robin. It needs to understand WebSocket upgrades and maintain
sticky sessions.

Each server registers connected users in Redis — that's how we know which
server to route messages to. When a message comes in for Bob, we look up
Bob's session in Redis, find his WebSocket server, and route there."
```

### Moment 2: Ordering Guarantee

```
Interviewer: "How do you guarantee messages arrive in order?"

Candidate: "Message ordering is per-conversation. I use Kafka with
conversation_id as the partition key. This ensures all messages for a
conversation go to the same partition, and Kafka guarantees FIFO order
within a partition.

But network delivery can still reorder messages. So I also add sequence
numbers — each conversation has its own counter. The client buffers
out-of-order messages and reorders by sequence number before displaying.

The client also tracks received message IDs for deduplication, since we're
doing at-least-once delivery."
```

### Moment 3: Failure Handling

```
Interviewer: "A WebSocket server dies. What happens to the 10K users
connected to it?"

Candidate: "Their TCP connections break. The clients detect this and
initiate reconnection with exponential backoff.

On the server side, the health checker detects the dead server and cleans
up the session store. For each affected user, we check if they have other
active sessions — they might still be online on their laptop.

When clients reconnect, they fetch missed messages from the database. The
Message Service tracks which messages have been delivered, so we can
recover any gaps.

The key is graceful degradation — the system keeps working, users just
need to reconnect."
```

---

## Key Takeaways

### Memorable Anchors

1. **Stateful connections:** WebSocket servers hold connections in memory — different from stateless HTTP

2. **Kafka for ordering:** Partition by conversation_id → FIFO within partition

3. **Sequence numbers:** Client-side reordering buffer for out-of-order delivery

4. **Session store:** Redis tracks user → server mapping for routing

5. **TTL-based presence:** Online status expires automatically if heartbeat stops

### Phrases That Show Experience

- "WebSocket servers are stateful — each holds ~10K concurrent connections..."
- "Kafka partitioning by conversation_id ensures FIFO ordering..."
- "At-least-once delivery requires idempotency on the client..."
- "Session store enables routing to the correct WebSocket server..."
- "Presence uses TTL and pub/sub — separate from the message path..."

---

## Practice Questions

Try answering these out loud:

1. "How would you add voice/video calls to this system?"
2. "Design end-to-end encryption using the Signal protocol"
3. "How do you handle message reactions (emoji) at scale?"
4. "What's your strategy for preventing spam in group chats?"
5. "How would you add message search across a user's history?"

---

**End of Mock Interview 5**

---

## Complete Exercise Index

You now have all 5 mock interviews:

| # | Exercise | Difficulty | Focus Areas |
|---|----------|------------|-------------|
| 1 | URL Shortener | Easy | Back-of-envelope, basic caching |
| 2 | Rate Limiter | Intermediate | Algorithms, distributed systems |
| 3 | Booking System | Intermediate/Hard | Concurrency, Redis locks |
| 4 | News Feed | Hard | Fan-out, scaling reads, hot keys |
| 5 | Chat System | Hard | WebSockets, real-time, ordering |

These 5 exercises cover ~80% of common system design interview patterns.
