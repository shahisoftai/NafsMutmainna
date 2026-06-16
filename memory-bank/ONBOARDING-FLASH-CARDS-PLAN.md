# HeartOS Onboarding Flash Cards — Plan
**Date:** 2026-06-16
**Cards:** 7 swipable cards (recommended), expandable to 8

---

## Card 1 — Welcome to HeartOS
**Purpose:** Set expectations, explain the core value proposition

**Headline:** Your Spiritual Fitness Companion

**Body:**
- Privacy-first — all data stays on your device, always
- No account needed, no internet required
- Works quietly in the background of your day

**Visual suggestion:** HeartOS logo + lock icon, calming gradient

**Key message to convey:**
- HeartOS is a privacy-first Islamic self-improvement app
- Works completely offline — your spiritual data is yours alone
- No sign-up, no tracking, no ads

---

## Card 2 — Daily Check-in (3 Steps)
**Purpose:** Teach the core interaction — the daily check-in

**Headline:** Check In With Your Heart, Daily

**Body:**
- Step 1: Pick the emotion you're feeling right now
- Step 2: Adjust how strongly you feel it (1–10)
- Step 3: Add a note if you want (optional)
- Takes under 60 seconds

**Visual suggestion:** 3-step flow illustration — emotion picker → intensity slider → submit button

**Key message to convey:**
- Check-in is quick (under 1 minute)
- No right or wrong answers — just honest reflection
- Your first check-in unlocks everything

---

## Card 3 — Heart Analysis
**Purpose:** Show the personalized insight after check-in

**Headline:** See What Your Heart Reveals

**Body:**
- After each check-in, we analyze which heart attributes are active
- We detect 3–5 attributes from your emotion and intensity
- We show you your current growth path through the Nafs stations
- The more you check in, the more accurate it becomes

**Visual suggestion:** Heart icon with attribute cards radiating out, or a radar/spider chart

**Key message to convey:**
- The analysis is personalized to YOUR check-in right now
- It gets smarter the more you use it
- Shows your growth path in real-time

---

## Card 4 — Your Personal Prescription
**Purpose:** Explain the intervention/recommendation system

**Headline:** A Prescription Made Just for You

**Body:**
- Based on your detected attributes, we create a personal daily prescription
- Each prescription includes 1 of 6 types:
  - 📖 Quran verse
  - ✋ Hadith
  - 🤲 Dua (supplication)
  - 💎 Allah Names to reflect on
  - 🔁 Dhikr to recite
  - ✅ A small action to try today
- Mark each as Done or Skip — this refines future prescriptions

**Visual suggestion:** 6 intervention type icons in a grid, or a prescription card mockup

**Key message to convey:**
- Every prescription is unique to that day's check-in
- You don't have to do everything — even one action counts
- Done/Skip feedback makes future prescriptions more relevant

---

## Card 5 — Nafs Meter
**Purpose:** Explain the core spiritual health indicator

**Headline:** Your Nafs Meter — Your Spiritual Vital Sign

**Body:**
- Four stations of the soul (Nafs): Ammarah → Lawwamah → Mulhamah → Mutmainnah
- Your daily check-in updates your Nafs state
- The meter shows your trend — moving toward peace or drifting toward heedlessness
- Think of it like a fitness tracker, but for your heart

**Visual suggestion:** The Nafs meter widget (colored arc with needle), 4-station label strip

**Key message to convey:**
- Nafs is Islam's framework for spiritual self-awareness
- The meter is your daily spiritual health indicator
- Movement toward Mutmainnah is the goal — and it's a journey

---

## Card 6 — 15-Day Journey
**Purpose:** Show the progress tracking feature

**Headline:** Your 15-Day Journey

**Body:**
- Every check-in is saved to your personal journey
- See a trend of your last 15 days of Nafs movement
- Discover which Allah Names have been guiding you most
- Day-by-day breakdown with your emotions, intensity, and detected attributes
- Tap any day to dive into the details

**Visual suggestion:** Journey screen mockup — 15-day mini-cards, trend line, Allah Names list

**Key message to convey:**
- Your journey is tracked automatically — no extra work
- 15 days is the window the app uses to find patterns
- Each check-in adds to your story

---

## Card 7 — Heart Graph
**Purpose:** Introduce the big-picture spiritual map

**Headline:** The 8 Master Pathways of the Heart

**Body:**
- All spiritual struggles follow one of 8 master pathways
- HeartOS maps your current path and shows all 8
- Each pathway has a chain: from the challenging emotion to the soul at peace
- Example: Anger → Mercy: Ghadab → Sabr → Hilm → Rifq → Rahmah
- Your position on the graph shows where you are and where you're heading

**Visual suggestion:** Heart graph screen — 8 branching pathway lines from a center heart, user's dot highlighted

**Key message to convey:**
- You're not lost — every struggle has a mapped path
- HeartOS shows you the way forward, step by step
- The goal is Mutmainnah — and there are 8 different starting points

---

## Card 8 (Optional) — Habit Tracking
**Purpose:** Introduce the daily habit support feature

**Headline:** Build Daily Habits That Support Your Growth

**Body:**
- Add spiritual habits you want to track: Prayer, Quran, Dhikr, Charity, Exercise, or your own
- Today's habits appear on your Home screen each morning
- Simple Done/Skip tracking — no gamification, just honest reflection
- Your habit streaks build your positive pattern over time

**Visual suggestion:** Habits screen mockup — habit cards with check marks, streak counter

**Key message to convey:**
- Habits are optional but powerful
- Tracking them builds self-awareness
- HeartOS doesn't judge — it just helps you notice patterns

---

## Onboarding UX Notes

### Swipe Mechanics
- Horizontal swipe (left/right) to navigate between cards
- Dots indicator at bottom showing current position
- "Skip" button (top-right) to dismiss onboarding
- "Next" button (bottom-right) to advance
- On last card: "Get Started" button → navigates to Home

### When to Show Onboarding
- First launch only (after splash screen)
- Controlled by a `hasSeenOnboarding` flag in SharedPreferences
- If user is logged in or has checked in before, skip automatically

### Design Suggestions
- Full-screen cards with a clean, calming gradient background
- Each card: icon/illustration at top, headline in bold, body in regular weight
- Soft animations on swipe (fade + slide)
- Arabic decorative element (simple geometric pattern) in corner to reinforce Islamic aesthetic
- Colors: Use AppColors.primary, AppColors.primaryDark, AppColors.accent

### Card Progression Logic
```
Card 1 (Welcome)
    ↓ swipe right
Card 2 (Daily Check-in)
    ↓ swipe right
Card 3 (Heart Analysis)
    ↓ swipe right
Card 4 (Personal Prescription)
    ↓ swipe right
Card 5 (Nafs Meter)
    ↓ swipe right
Card 6 (15-Day Journey)
    ↓ swipe right
Card 7 (Heart Graph)
    ↓ swipe right
Card 8 (Habit Tracking) [optional — show last or skip]
    ↓ swipe right
"Get Started" → Home
```

### What NOT to Put on Onboarding Cards
- Too much text — max 3–4 lines per card
- Technical jargon (Nafs, Mulhamah, etc.) without context
- Screenshots that will go stale with UI updates
- Privacy or legal details (save for Settings/About)

---

## Feature Priority for Cards
| Priority | Card | Feature |
|----------|------|---------|
| 1 | Card 2 | Daily Check-in (core interaction) |
| 2 | Card 3 | Heart Analysis (immediate value after check-in) |
| 3 | Card 4 | Personal Prescription (the "why" of the app) |
| 4 | Card 5 | Nafs Meter (the key visual indicator) |
| 5 | Card 6 | 15-Day Journey (progress tracking) |
| 6 | Card 1 | Welcome/Privacy (trust building) |
| 7 | Card 7 | Heart Graph (advanced feature) |
| 8 | Card 8 | Habit Tracking (optional, secondary) |

**Recommendation:** Lead with Cards 2, 3, 4 — these are the core value loop. Card 1 builds trust, Cards 5, 6 show depth, Card 7 is for power users, Card 8 is optional.

---

## File Location for Implementation
Once implemented, the onboarding screens should live in:
```
lib/src/presentation/screens/onboarding/
  onboarding_screen.dart       # Main page with PageView
  widgets/
    onboarding_card.dart       # Reusable card widget
    page_indicator.dart       # Dot indicator
```
