# HeartOS Production Release Notes

## Concept

HeartOS is a privacy-first spiritual self-improvement app based on Islamic principles of soul purification (Tazkiyah). It tracks emotional states, guides spiritual growth through the concept of "Nafs" (soul states), and provides personalized Quranic interventions for soul healing.

## Key Features

### Core Functionality
- **Daily Check-In**: Log emotions with intensity (1-10) and notes, deriving affected spiritual attributes
- **Nafs Meter**: 15-day visual arc tracking spiritual progression through 4 Nafs levels (Ammarah → Lawwamah → Mulhamah → Mutmainnah)
- **Heart Graph**: Relational map linking 50 emotions to 200+ attributes showing growth paths
- **Spiritual Interventions**: Quran verses, Hadith, Dua, and Allah Names as personalized treatments

### Tracking & Analysis
- **Habit Tracking**: Prayer, Quran, Dhikr, Charity, Exercise with daily logging
- **Heart History**: Charts and pattern analysis of emotional/spiritual data
- **Domain Analysis**: 10 life domains for holistic perspective

### Technical
- **Privacy-First**: 100% offline with local SQLite + Hive storage
- **Optional Cloud Sync**: Supabase integration with Google Sign-In
- **Security**: Biometric/PIN lock via flutter_secure_storage + local_auth

## Version
**1.1.14+9**
