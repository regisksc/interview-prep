# Interview Preparation

This repository contains comprehensive interview preparation materials for Flutter/Dart development and system design roles.

## Contents

### 1. Flutter

**Location**: `flutter/`

Interview guide, live coding exercises, and runnable practice challenges.

| What | Location |
|------|----------|
| Interview guide (2 500 lines) | `flutter/FLUTTER_INTERVIEW_PREP.md` |
| Extensions (20, with solutions) | `flutter/practice/extensions/` |
| Multiple choice questions | `flutter/practice/multiple-choice/` |
| Bug-hunt challenges (5 topics) | `flutter/practice/challenges/` |
| Build-from-scratch challenges | `flutter/practice/challenges/` |
| Progress index | `flutter/practice/INDEX.md` |

**Getting Started**:
```bash
# Dart-only exercises
cd flutter/practice/extensions/001-movie-length && dart run

# Runnable Flutter challenges
cd flutter/practice/challenges/dart_fundamentals && flutter run
```

---

### 2. System Design Interview

**Location**: `system-design-interview/`

Beginner-friendly system design interview preparation.

| File | Content |
|------|---------|
| `README.md` | Fundamentals guide - concepts every beginner should know |
| `exercises.md` | 30+ practice exercises (Counter → Google Search) |
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
- 10 extension exercises daily (`flutter/practice/extensions/`)
- Focus on syntax and basic transformations

### Week 3-4: Flutter Internals
- Read `flutter/FLUTTER_INTERVIEW_PREP.md` modules 1–4
- Work through bug-hunt challenges (`flutter/practice/challenges/`)

### Week 5: State Management
- Build-from-scratch challenges: streams, RxDart, Riverpod
- Multiple choice warm-up (`flutter/practice/multiple-choice/`)

### Week 6: System Design Basics
- Read all of `system-design-interview/README.md`
- Understand each component (cache, DB, load balancer)

### Week 7: System Design Deep-Dive
- Complete 5 exercises from `exercises.md` (Level 1-2)
- Complete booking system exercise (`01-booking-system/`)

### Week 8: Mock Interviews
- Random Flutter challenges (timed, 15-30 min)
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
├── flutter/
│   ├── FLUTTER_INTERVIEW_PREP.md   # Full interview guide
│   └── practice/
│       ├── challenges/             # Bug-hunt + build-from-scratch apps
│       ├── extensions/             # Dart extension exercises (20)
│       ├── dart-files/             # Pure Dart challenges
│       ├── widgets/                # Flutter widget exercises
│       ├── multiple-choice/        # Theory questions
│       └── INDEX.md                # Progress tracking
├── system-design-interview/
│   ├── README.md                   # Beginner's guide (fundamentals)
│   ├── exercises.md                # 30+ practice exercises
│   └── 01-booking-system/          # Mock interview exercise
└── README.md                       # This file
```
