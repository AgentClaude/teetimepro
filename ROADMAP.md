# ROADMAP — TeeTimes Pro

> Full details in [PRD](docs/prd/tee-time-platform.md)

## Phase 1 — MVP (8 weeks)

### Sprint 1–2: Foundation
- Rails 8 API setup + Docker
- Auth (Devise + JWT) + multi-tenant Organization model
- Course, TeeSheet, TeeTime, Booking models + migrations
- Service object architecture (ApplicationService, ServiceResult)
- React scaffold + Tailwind + Apollo Client + Storybook

### Sprint 3–4: Core Booking
- Tee sheet generation service (intervals, blocked times)
- Booking creation flow (availability check → payment → confirmation)
- Cancellation + refund flow
- GraphQL API (queries + mutations)
- Tee sheet UI (grid view, drag & drop)

### Sprint 5–6: Payments & Notifications
- Stripe Connect integration (per-org accounts)
- Payment processing + refunds
- Twilio SMS confirmations + reminders
- Email notifications
- Booking management dashboard

### Sprint 7–8: Polish & Launch
- Public booking widget (embeddable)
- Admin settings (course config, pricing rules)
- Membership tiers + pricing
- Performance optimization
- Production deployment

## Phase 2 — Growth (Post-MVP)
- Yield management (dynamic pricing)
- Mobile app (React Native)
- Voice booking bot (Deepgram)
- League & tournament management
- Multi-course organizations
- Advanced reporting & analytics
- POS integration
- Weather-aware scheduling

## Phase 3 — Scale
- White-label solution
- API marketplace
- AI-powered demand forecasting
- Hardware integrations (GPS, kiosks)
