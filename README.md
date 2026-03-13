# Interview Preparation

This repository contains comprehensive interview preparation materials for Flutter/Dart development and system design roles.

## Contents

### 1. Flutter Live Coding Challenges

**Location**: `flutter-live-coding-challenges/`

500+ coding exercises for Flutter/Dart technical interviews.

| Category | Exercises | Status |
|----------|-----------|--------|
| Extensions | 80 | 20 complete with solutions |
| Dart Fundamentals | 80 | README complete |
| Widgets | 80 | README complete |
| State Management | 80 | Planned |
| Async & Streams | 60 | Planned |
| Multiple Choice | 50 | Complete |

**Structure per exercise**:
```
extensions/001-movie-length/
├── README.md       # Challenge, requirements, hints
├── main.dart       # Starter code
└── ../solutions/   # Solution files
```

**Getting Started**:
```bash
cd flutter-live-coding-challenges/extensions/001-movie-length
dart run
```

---

### 2. System Design Interview

**Location**: `system-design-interview/`

Beginner-friendly system design interview preparation.

| File | Content |
|------|---------|
| `README.md` | Fundamentals guide - concepts every beginner should know |
| `01-booking-system/` | Deep-dive mock interview (appointment booking) |

**Topics Covered**:
- Client-server architecture
- API design (endpoints, requests, responses)
- Databases (SQL vs NoSQL, indexing)
- Caching (Redis, TTL, invalidation)
- Concurrency (race conditions, distributed locks)
- Real-time updates (WebSockets, polling, SSE)

**Getting Started**:
1. Start with `README.md` - read all fundamental concepts
2. Try `01-booking-system/README.md` - follow the mock interview format
3. Practice explaining your thinking out loud

---

## Study Plan

### Week 1-2: Dart Fundamentals
- 10 extension exercises daily
- Focus on syntax and basic transformations

### Week 3-4: Widgets
- 10 widget exercises daily
- Understand stateful vs stateless deeply

### Week 5: System Design Basics
- Read all of `system-design-interview/README.md`
- Understand each component (cache, DB, load balancer)

### Week 6: System Design Deep-Dive
- Complete booking system exercise
- Practice explaining architecture out loud

### Week 7-8: Mock Interviews
- Random exercise selection (timed)
- Full system design questions (45 min each)

---

## Resources

### Books
- "System Design Interview" by Alex Xu
- "Designing Data-Intensive Applications" by Martin Kleppmann

### Online
- [System Design Primer](https://github.com/donnemartin/system-design-primer)
- [bytebytego](https://bytebytego.com) - newsletter

---

## Repository Structure

```
interview-prep/
├── flutter-live-coding-challenges/
│   ├── extensions/           # Extension method exercises
│   ├── dart-files/           # Pure Dart challenges
│   ├── widgets/              # Flutter widget exercises
│   ├── multiple-choice/      # Theory questions
│   └── INDEX.md              # Progress tracking
├── system-design-interview/
│   ├── README.md             # Beginner's guide
│   └── 01-booking-system/    # Mock interview exercise
└── README.md                 # This file
```
