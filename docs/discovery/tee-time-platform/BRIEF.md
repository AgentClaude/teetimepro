# TeeTimes Pro — Product Brief

> Date: 2026-03-06  
> Author: Product Research (AI-assisted)  
> Status: Draft

## One-Liner
A modern, API-first golf course management platform that replaces fragmented legacy systems with a unified tee sheet, booking engine, POS, and AI-powered voice booking — built for public courses and course groups who want to own their golfer relationships.

## The Problem
Golf course operators juggle 3-5 disconnected software systems (tee sheet, POS, F&B, marketing, accounting) while giving away their best inventory to GolfNow's marketplace. Their staff spends hours answering phones for bookings that should be self-service. Dynamic pricing — standard in hotels and airlines for decades — is still spreadsheet-based at most courses. The result: lost revenue, frustrated staff, and a golfer experience stuck in 2010.

## The Opportunity
- **$1.2-1.5B** golf management software market growing at 8-10% CAGR
- **~16,000 US courses**, ~60% on legacy or fragmented systems  
- Post-COVID golf boom: 41.1M Americans golfed in 2023 (record)
- Online booking grew 35%+ since 2019 — golfers expect modern experiences
- **No competitor** has voice-based phone booking (biggest whitespace)
- Courses are actively looking to reduce GolfNow dependency

## Target Customer
**Primary:** Public and semi-private courses (single and multi-course operators), 18-36 holes, $1.5-5M annual revenue, currently using ForeUP, legacy EZLinks, or fragmented systems.

**Beachhead:** Municipal golf operations (budget-conscious, procurement-friendly, multi-course portfolios, often 3-10 courses under one management entity).

## Differentiation

| Us | Them |
|----|------|
| Voice bot answers phones and books tee times 24/7 | Staff manually answers every call |
| Real-time collaborative tee sheet (WebSocket) | Page-refresh tee sheets |
| API-first (GraphQL + REST) — build your own integrations | Closed systems or clunky APIs |
| Transparent SaaS pricing | Opaque quotes and barter models |
| Built from scratch on modern stack (Rails 8, React, TypeScript) | Assembled from acquisitions or built on legacy codebases |
| Course-branded booking (with optional marketplace syndication) | Marketplace-first (courses lose brand identity) |

## Tech Stack
- **Backend:** Rails 8 API (Ruby 3.3+), PostgreSQL, Redis, Sidekiq
- **Frontend:** React 18+ with TypeScript, TailwindCSS
- **API:** GraphQL (graphql-ruby) + REST endpoints
- **Real-time:** ActionCable/WebSocket for live tee sheet
- **Payments:** Stripe Connect (marketplace model)
- **SMS:** Twilio
- **Voice:** Deepgram STT/TTS for phone booking bot
- **Deployment:** Docker, cloud-native

## Revenue Model
1. **SaaS subscription:** $199-599/mo per course (tiered by features)
2. **Payment processing:** Stripe Connect revenue share (~0.25-0.5% on top of Stripe fees)
3. **Per-booking fee:** $0.25-0.50 per online booking (optional, for lower-tier plans)
4. **Voice bot:** Premium add-on ($99-199/mo)
5. **Marketplace syndication:** Revenue share on bookings from syndicated channels

## MVP Scope (Phase 1: 8-12 weeks)
1. Tee sheet management (real-time, drag-and-drop)
2. Online booking engine (embeddable widget)
3. Dynamic pricing engine
4. Payment processing (Stripe Connect)
5. Multi-tenant auth with role-based access
6. Email/SMS notifications (confirmations, reminders)
7. Basic reporting dashboard

## Key Risks
- **Switching costs:** Courses resist change. Need white-glove migration.
- **GolfNow lock-in:** Some courses contractually tied to GolfNow.
- **Payment processing competition:** Lightspeed competing on rates.
- **Solo founder velocity:** Ambitious scope for one engineer. Prioritize ruthlessly.

## Success Metrics (Year 1)
- 10 courses on the platform
- $50K ARR
- 90%+ operator satisfaction (NPS > 50)
- < 2 second tee sheet load time
- Voice bot handling 50+ calls/day per course

## Next Steps
1. ✅ Competitive analysis complete
2. ✅ Full PRD written
3. 🔲 Technical architecture design
4. 🔲 Data model / ERD
5. 🔲 MVP wireframes
6. 🔲 Rails project scaffold
7. 🔲 First course partner (pilot)
