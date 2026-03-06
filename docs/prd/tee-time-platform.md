# TeeTimes Pro — Product Requirements Document

> Version: 1.0  
> Date: 2026-03-06  
> Author: Product Research (AI-assisted)  
> Status: Draft — Ready for Engineering Review

---

## 1. Executive Summary

TeeTimes Pro is a modern, cloud-based golf course management platform designed to replace the fragmented, legacy software that most golf courses currently use. Built on Rails 8 with a React frontend and GraphQL API, it provides a unified system for tee sheet management, online booking, payment processing, customer management, and — uniquely — AI-powered voice booking via Deepgram integration.

The golf course management software market is worth $1.2-1.5B and growing at 8-10% CAGR. Despite this, the market is dominated by legacy players (GolfNow/EZLinks, Club Prophet) or conglomerate plays (Lightspeed). No competitor has built a truly modern, API-first, voice-enabled platform from scratch.

**Our thesis:** Golf courses want to own their golfer relationships, not rent them from a marketplace. They want modern software that their seasonal staff can learn in minutes, not hours. And they want their phones answered 24/7 without hiring more staff.

TeeTimes Pro addresses all three.

---

## 2. Problem Statement

Golf course operators face a compounding set of operational challenges:

**Fragmented Technology Stack**
The average course uses 3-5 disconnected systems: one for tee times, another for POS, a third for F&B, plus separate tools for email marketing, accounting, and reporting. Data doesn't flow between them. Staff must be trained on each. Errors from manual data entry are common.

**Marketplace Dependency**
GolfNow controls ~40-50% of online tee time bookings with 3.9M active users. To access this marketplace, courses must surrender their best tee times (barter model) or pay significant fees. Courses lose brand identity and direct golfer relationships. But they feel trapped because GolfNow brings eyeballs.

**Phone Booking Burden**
Despite digital booking growth, 40-60% of tee times at most courses are still booked by phone. Pro shop staff spend hours daily answering calls instead of serving golfers on-site. During peak hours, calls go unanswered — lost revenue. Hiring additional staff for phones is cost-prohibitive.

**Revenue Optimization Gap**
Hotels and airlines have used dynamic pricing for decades. Most golf courses still set seasonal rates in a spreadsheet and leave money on the table. When demand surges (perfect weather, weekend morning), they don't capture the premium. When demand drops (rainy Tuesday afternoon), they don't discount to fill the tee sheet.

**Legacy UX & Training Costs**
Golf courses have high staff turnover (seasonal workers, college students). Legacy systems require extensive training. Modern staff expect modern software. Poor UX leads to booking errors, slow check-in, and frustrated golfers.

---

## 3. Target Users & Personas

### 3.1 Golf Course Owner/Operator — "Dave"
- **Age:** 45-65
- **Context:** Owns or manages 1-3 courses. Focused on revenue, occupancy, and operational efficiency. Makes purchasing decisions. May not be tech-savvy but appreciates modern tools that "just work."
- **Goals:** Maximize revenue per tee time, reduce operational costs, get clear reporting, minimize dependency on GolfNow
- **Pain points:** Can't see real-time revenue data, juggling multiple systems, paying too much for software that does too little
- **Key metric:** Revenue per available tee time (RevPATT)

### 3.2 Pro Shop Manager — "Sarah"
- **Age:** 30-50
- **Context:** Day-to-day manager of golf operations. Handles scheduling, staffing, customer complaints, and the tee sheet. Power user of whatever system the course uses.
- **Goals:** Smooth daily operations, minimal booking errors, happy golfers, efficient staff
- **Pain points:** Phone ringing constantly, training new seasonal staff on old systems, managing walk-ons while handling reservations, juggling overbookings
- **Key metric:** Tee sheet utilization rate, customer satisfaction

### 3.3 Golf Course Staff — "Marcus" (starter, ranger, marshal)
- **Age:** 18-70 (wide range — college kids to retirees)
- **Context:** Uses the system for check-in, cart assignment, pace of play monitoring. Needs a mobile-friendly interface. May only work a few months per season.
- **Goals:** Quick check-in process, know who's coming next, communicate with pro shop
- **Pain points:** Complex systems with too many clicks, no mobile access, can't see updated tee sheet in real-time
- **Key metric:** Check-in time per golfer (< 30 seconds)

### 3.4 Golfer (End User) — "Alex"
- **Age:** 25-65
- **Context:** Books tee times online and by phone. Plays 10-40 rounds/year. Expects modern booking experience like OpenTable or Uber. May play at multiple courses.
- **Goals:** Book quickly, get good prices, play with friends, receive reminders
- **Pain points:** Clunky booking websites, can't see real-time availability, no easy way to invite friends, no price transparency
- **Key metric:** Booking conversion rate, repeat booking rate

### 3.5 Admin/Accountant — "Linda"
- **Age:** 35-60
- **Context:** Handles financial reporting, reconciliation, and accounting. Needs clean data export to QuickBooks/Xero.
- **Goals:** Accurate revenue reporting, easy reconciliation, clean data exports, audit trail
- **Pain points:** Manual data entry between systems, payment reconciliation nightmares, no standardized reporting
- **Key metric:** Time to close monthly books

---

## 4. Market Analysis

### 4.1 Market Size
- **Total Addressable Market (TAM):** ~$1.5B globally (golf course management software)
- **Serviceable Available Market (SAM):** ~$600M (US public/semi-private/municipal courses)
- **Serviceable Obtainable Market (SOM):** ~$12M (200 courses × $5K avg annual revenue per course, achievable in 3-5 years)

### 4.2 Growth Trends
- Golf participation at all-time highs post-COVID (41.1M Americans, NGF 2023)
- Online booking grew 35%+ from 2019-2023
- Dynamic pricing adoption accelerating (from <10% to ~25% of courses)
- AI/voice technology becoming mainstream in hospitality
- Multi-course management groups consolidating (buying up courses)
- Off-course golf (simulators, Topgolf) creating new management needs

### 4.3 Competitive Landscape

| Competitor | Founded | Courses | Primary Strength | Primary Weakness |
|---|---|---|---|---|
| GolfNow/EZLinks | 1995/2008 | 9,000 | Marketplace reach (3.9M golfers) | Barter model, legacy tech, operator resentment |
| Lightspeed Golf | 2013 | 2,000+ | Full platform + retail/restaurant POS | Conglomerate, complex pricing, not golf-first |
| ForeUP | 2013 | 1,500-2,000 | Modern UI, municipal focus | Limited features, no voice/AI, small scale |
| Club Prophet | ~1990 | ~1,000 | 30-year track record, deep POS | Dated UI, slow cloud transition |
| Teesnap | ~2015 | 400+ | Modern all-in-one, marketing services | Small, no AI/voice, limited API |
| Sagacity Golf | ~2010 | ~500+ | AI chatbot, dynamic pricing (24% uplift) | Not a full operations platform |
| Golf Genius | ~2008 | 11,000+ | Tournament management dominance | No tee sheet/booking/POS |

### 4.4 Differentiation Strategy

**"The modern, voice-enabled golf platform that puts courses first."**

1. **Voice-first booking:** AI phone bot (Deepgram) handles bookings 24/7. No competitor has this for phone calls.
2. **Real-time collaborative tee sheet:** WebSocket-powered, Google Docs-like multi-user experience.
3. **API-first architecture:** GraphQL + REST. Enable an ecosystem. Make integrations easy.
4. **Transparent pricing:** Published SaaS tiers. No barter. No opaque custom quotes.
5. **Course-branded, not marketplace-branded:** The booking experience is YOUR brand. Optional marketplace syndication.
6. **Built from scratch on modern stack:** No legacy baggage. Fast, responsive, mobile-first.
7. **Developer-friendly:** Open API means courses and third-party developers can build on our platform.

---

## 5. Product Vision & Goals

### 5.1 Short-Term — MVP (Months 1-3)
**Vision:** A functional tee sheet + booking + payment system that a course can use to replace their existing software.

**Goals:**
- Ship a tee sheet that staff love using
- Enable online booking that converts better than competitors
- Process payments via Stripe Connect
- Multi-tenant architecture supporting multiple courses
- Prove the concept with 1-3 pilot courses

### 5.2 Mid-Term — Growth (Months 4-9)
**Vision:** A complete operations platform with CRM, communications, analytics, and the voice bot.

**Goals:**
- Launch AI voice bot for phone bookings
- Build CRM with marketing automation
- Add comprehensive analytics/reporting
- Launch tournament management
- Scale to 25-50 courses
- Achieve product-market fit (NPS > 50)

### 5.3 Long-Term — Platform (Months 10-24)
**Vision:** The platform for golf — where courses, golfers, and third-party developers converge.

**Goals:**
- Public API marketplace (think Shopify App Store for golf)
- Mobile apps (golfer-facing)
- POS for pro shop and F&B
- Marketplace syndication (distribute tee times to GolfNow, Supreme Golf, etc.)
- 200+ courses, $1M+ ARR
- International expansion

---

## 6. Feature Requirements

### 6.1 Tee Sheet Management (P0)

**Description:** The visual, interactive tee sheet is the heart of the application. It must be real-time, collaborative, and intuitive enough that a seasonal worker can learn it in 5 minutes.

**User Stories:**

**US-6.1.1:** As a pro shop manager, I want to view today's tee sheet at a glance so I can see who's booked, what times are open, and where walk-ons can fit.
- **Acceptance Criteria:**
  - Tee sheet displays all tee times for selected date with color-coded status (booked, open, blocked, checked-in, no-show)
  - Each slot shows golfer count (e.g., "3/4"), player names on hover/click
  - Current time indicator shows "now" line
  - Loads in < 1 second for a full day's tee times
  - Updates in real-time when another user makes changes (WebSocket)

**US-6.1.2:** As a pro shop staff member, I want to drag and drop a booking to a different time slot so I can accommodate golfer requests without re-entering data.
- **Acceptance Criteria:**
  - Drag a booking to any open or partially-open slot
  - System prevents dropping onto incompatible slots (blocked, full, conflicting restrictions)
  - Confirmation dialog shows the change before saving
  - Original slot opens up, new slot updates — all in real-time
  - Undo available for 30 seconds after move

**US-6.1.3:** As a course manager, I want to configure tee time intervals (7, 8, 9, or 10 minutes) per course so the tee sheet matches our pace of play requirements.
- **Acceptance Criteria:**
  - Interval configurable per course (7/8/9/10 min)
  - Can set different intervals for different times of day (e.g., 10-min intervals during peak, 8-min during off-peak)
  - Changing interval reflows tee sheet for future dates without affecting existing bookings
  - Supports 1 and 10-tee starts

**US-6.1.4:** As a course manager, I want to block tee times for maintenance, tournaments, and shotgun starts so those times aren't available for regular booking.
- **Acceptance Criteria:**
  - Block individual times, ranges, or patterns (e.g., "every Tuesday 6-8 AM")
  - Block types: maintenance, tournament, event, private, other
  - Blocked times visually distinct on tee sheet (hatched/grayed)
  - Blocked times excluded from online booking automatically
  - Can unblock with confirmation

**US-6.1.5:** As a starter, I want to check in golfers with one tap so the check-in process takes under 30 seconds.
- **Acceptance Criteria:**
  - One-tap check-in from tee sheet or dedicated check-in view
  - Check-in updates tee sheet in real-time for all users
  - Can check in individual or entire group
  - Shows outstanding balance, prepaid status, cart assignment
  - Supports mobile (tablet at starter window)

**US-6.1.6:** As a pro shop manager, I want to manage walk-on golfers so I can fit them into available times without disruption.
- **Acceptance Criteria:**
  - "Quick Add" button opens streamlined walk-on form (name, # players, paid/unpaid)
  - System suggests best available times based on current availability
  - Walk-on bookings are visually distinguishable from reservations
  - Walk-on can be converted to a full booking/profile

**Technical Notes:**
- ActionCable/WebSocket for real-time updates across all connected clients
- Optimistic UI updates with conflict resolution
- Virtual scrolling for performance (100+ tee times per day)
- Keyboard shortcuts for power users (arrow keys to navigate, Enter to open, Esc to close)

---

### 6.2 Online Booking Engine (P0)

**Description:** An embeddable booking widget that courses can add to their website. Must be fast, mobile-first, and convert visitors to bookings. This is the public-facing revenue engine.

**User Stories:**

**US-6.2.1:** As a golfer, I want to see available tee times on the course website so I can book without calling.
- **Acceptance Criteria:**
  - Embeddable widget (iframe or web component) for any website
  - Shows available times for selected date with pricing
  - Responsive/mobile-first (60%+ of golfers book on mobile)
  - Loads in < 2 seconds
  - Shows real-time availability (no stale data)
  - Filterable by time of day, number of players, price range

**US-6.2.2:** As a golfer, I want to complete a booking in under 60 seconds so the process is fast and simple.
- **Acceptance Criteria:**
  - 3-step flow maximum: Select time → Enter details → Pay/Confirm
  - Guest checkout available (no account required)
  - Saved profiles for returning golfers (auto-fill)
  - Apple Pay / Google Pay support
  - Confirmation displayed immediately + email/SMS sent

**US-6.2.3:** As a course manager, I want dynamic pricing that automatically adjusts based on demand so I maximize revenue.
- **Acceptance Criteria:**
  - Rules engine: base price + modifiers (time of day, day of week, weather, occupancy, holidays, lead time)
  - Floor and ceiling prices per rate category
  - Visual pricing preview: manager can see projected prices for next 7 days
  - A/B testing support: compare pricing strategies
  - Historical data drives pricing recommendations
  - Override capability: manager can manually set price for any time slot

**US-6.2.4:** As a golfer, I want to join a waitlist when my preferred time is full so I get notified if a spot opens.
- **Acceptance Criteria:**
  - Waitlist option appears when a time slot is full
  - Golfer enters preferred time range and player count
  - Automatic notification (SMS + email) when matching slot opens
  - Golfer has configurable window (e.g., 15 min) to confirm before next in line
  - Manager can view and manage waitlist from admin

**US-6.2.5:** As a course manager, I want configurable booking policies so I can enforce rules appropriate for my course.
- **Acceptance Criteria:**
  - Advance booking window (e.g., 7 days for public, 14 days for members)
  - Cancellation policy (free until X hours before, then fee)
  - Minimum/maximum group size
  - Prepayment requirements (full, deposit, none) — configurable per rate category
  - Rain check / weather cancellation policy
  - Booking cutoff time (e.g., no online bookings within 1 hour of tee time)

**US-6.2.6:** As a golfer, I want to book for my group and invite friends so we can play together.
- **Acceptance Criteria:**
  - Book for 1-4 players
  - Invite others via email/SMS with a link to join the booking
  - Invited players can add their name and pay their share
  - Booking shows confirmed and pending players
  - Reminder sent to pending players

---

### 6.3 Account & Authentication System (P0)

**Description:** Multi-tenant architecture where each course (or course group) is a tenant, with role-based access control and golfer accounts.

**User Stories:**

**US-6.3.1:** As a course owner, I want my own isolated environment so my data is separate from other courses on the platform.
- **Acceptance Criteria:**
  - Tenant isolation at the data layer (all queries scoped to tenant)
  - Custom subdomain: `mycoursename.teetimespro.com`
  - Custom branding (logo, colors) on booking widget and admin
  - No data leakage between tenants

**US-6.3.2:** As a course owner, I want role-based access so I can control what each staff member can do.
- **Acceptance Criteria:**
  - Roles: Owner (full access), Manager (operational), Staff (limited — tee sheet, check-in), Accountant (reports, financials), Read-Only
  - Custom roles: owner can create roles with granular permissions
  - Audit log: who did what, when
  - Role assignment/revocation by Owner or Manager

**US-6.3.3:** As a multi-course operator, I want to manage all my courses from one login so I don't need separate accounts for each course.
- **Acceptance Criteria:**
  - Organization-level account that owns multiple courses
  - Switch between courses without re-logging in
  - Roll-up reporting across all courses
  - Staff can be assigned to one or multiple courses
  - Consistent branding across portfolio (optional)

**US-6.3.4:** As a golfer, I want to sign up with Google/Apple/email so I don't need yet another password.
- **Acceptance Criteria:**
  - Email + password registration
  - Google OAuth, Apple Sign-In
  - Single golfer account works across all courses on the platform
  - Profile: name, email, phone, handicap, home course, preferences
  - Golfer sees their booking history across all courses

**Technical Decisions:**
- **Multi-tenancy approach:** Shared database with tenant scoping (not schema-per-tenant). Reasons: simpler deployment, easier cross-tenant features (golfer profiles), lower ops overhead. Use `ActsAsTenant` gem or equivalent row-level security.
- **Auth:** Devise + OmniAuth for Rails. JWT tokens for API access. Separate auth flows for staff (email+password, 2FA) and golfers (social + email).
- **Tenant resolution:** Subdomain-based (`course.teetimespro.com`) or custom domain with DNS CNAME.

---

### 6.4 Payment Processing (P0)

**Description:** Stripe Connect as the payment backbone, enabling each course to have their own connected Stripe account while we handle the platform layer.

**User Stories:**

**US-6.4.1:** As a course owner, I want to accept credit card payments for online bookings so golfers can pay when they book.
- **Acceptance Criteria:**
  - Stripe Connect onboarding flow (Express accounts for simplicity)
  - Accept Visa, Mastercard, Amex, Discover
  - Apple Pay, Google Pay support
  - Funds deposited to course's bank account on standard Stripe schedule (2-day rolling)
  - Platform fee (our revenue) automatically deducted

**US-6.4.2:** As a course manager, I want to sell prepaid packages (10-pack, 20-pack, season pass) so golfers commit upfront.
- **Acceptance Criteria:**
  - Create package templates: name, included rounds, price, expiration date, valid days/times
  - Golfers purchase online or at POS
  - Package balance tracked on golfer profile
  - Auto-deduct when golfer books and checks in
  - Package transfer rules (transferable vs non-transferable)

**US-6.4.3:** As a course manager, I want to charge cancellation fees according to my policy so I reduce no-shows.
- **Acceptance Criteria:**
  - Configurable cancellation fee structure (tiered: free > 48h, 50% 24-48h, 100% < 24h)
  - Fee charged automatically when golfer cancels
  - Pre-authorized hold at booking time (capture on cancellation)
  - No-show fee: charge the card on file if golfer doesn't show
  - Override: staff can waive fees with manager approval

**US-6.4.4:** As a course owner, I want revenue reporting that shows me exactly what I earned, what the platform took, and what processing fees were.
- **Acceptance Criteria:**
  - Dashboard: gross revenue, platform fees, processing fees, net revenue
  - Breakdown by: day, week, month, booking type, rate category
  - Reconciliation report matching Stripe payouts
  - Exportable to CSV for accounting

**Technical Decisions:**
- **Stripe Connect Express:** Simplest integration. Courses don't need their own Stripe dashboard (though they can access it). We control the UX.
- **Platform fee model:** Take 2-3% of gross booking revenue OR fixed monthly subscription. Probably subscription + small per-transaction fee for the lower tier.
- **PCI compliance:** Stripe Elements/Checkout handles card data — we never touch raw card numbers. PCI SAQ-A.

---

### 6.5 Customer Management / CRM (P1)

**Description:** Golfer profiles with play history, segmentation, and marketing automation. The goal: help courses know their golfers and keep them coming back.

**User Stories:**

**US-6.5.1:** As a course manager, I want to see a golfer's complete profile (play history, spend, preferences) so I can provide personalized service.
- **Acceptance Criteria:**
  - Profile view: contact info, handicap, play frequency, total spend, favorite times, preferred playing partners
  - Booking history with details
  - Notes field for staff comments
  - Tags for segmentation (e.g., "league player", "VIP", "tournament regular")
  - Cross-course profile for multi-tenant golfers

**US-6.5.2:** As a course manager, I want to create golfer segments so I can target specific groups with promotions.
- **Acceptance Criteria:**
  - Segment builder: filter by play frequency, spend, handicap, last visit, booking channel, tags
  - Dynamic segments (auto-update as golfers match/unmatch criteria)
  - Example segments: "Lapsed golfers (no play in 60 days)", "Top 20% spenders", "Weekend warriors"
  - Segment count shown before sending campaign

**US-6.5.3:** As a course manager, I want to run email/SMS campaigns to my golfer segments so I can drive bookings.
- **Acceptance Criteria:**
  - Email composer with templates (drag-and-drop or rich text)
  - SMS campaigns via Twilio
  - Merge fields: {{first_name}}, {{last_play_date}}, {{booking_link}}
  - Schedule send for optimal timing
  - Campaign analytics: open rate, click rate, bookings attributed
  - Unsubscribe handling (CAN-SPAM, TCPA compliance)

**US-6.5.4:** As a course manager, I want loyalty program capabilities so I can reward repeat players.
- **Acceptance Criteria:**
  - Points-based system: earn points per round/dollar spent
  - Reward tiers (e.g., Silver, Gold, Platinum based on annual rounds)
  - Redeem points for discounts, free rounds, pro shop credit
  - Automatic tier progression/regression
  - Loyalty status visible on golfer profile and booking flow

---

### 6.6 Communication & Notifications (P0)

**Description:** Automated communications that keep golfers informed and reduce no-shows.

**User Stories:**

**US-6.6.1:** As a golfer, I want booking confirmation via email and SMS so I know my tee time is set.
- **Acceptance Criteria:**
  - Instant email confirmation with booking details, cancellation policy, weather forecast
  - SMS confirmation (if phone number provided)
  - Calendar invite attachment (.ics) in email
  - Include check-in instructions, directions, course policies

**US-6.6.2:** As a golfer, I want a reminder before my tee time so I don't forget.
- **Acceptance Criteria:**
  - SMS reminder at configurable interval (default: 24 hours before)
  - Email reminder at configurable interval (default: 48 hours before)
  - Reminder includes: tee time, course, weather forecast, cancel/modify link
  - Golfer can reply CANCEL to SMS to cancel (with policy enforcement)

**US-6.6.3:** As a course manager, I want weather-aware notifications so golfers and staff know about conditions.
- **Acceptance Criteria:**
  - Integrate weather API (Open-Meteo or WeatherAPI)
  - Auto-alert golfers if severe weather expected for their tee time
  - Course can post "course condition" updates visible on booking page
  - Lightning delay notifications via SMS to checked-in golfers

**US-6.6.4:** As a waitlisted golfer, I want instant notification when a spot opens so I can grab it.
- **Acceptance Criteria:**
  - SMS notification within 60 seconds of cancellation matching waitlist criteria
  - Push notification (future mobile app)
  - Claim link in notification — one tap to confirm and pay
  - If not claimed within configured window, notify next in queue

**Technical Notes:**
- Twilio for SMS (cost: ~$0.0079/segment outbound)
- SendGrid or Postmark for transactional email
- Sidekiq for async notification processing
- Rate limiting to prevent spam/abuse

---

### 6.7 Voice Bot Integration (P1)

**Description:** An AI-powered phone system that answers calls, searches tee times by natural language, and completes bookings — replacing the traditional IVR and reducing staff phone burden.

**User Stories:**

**US-6.7.1:** As a golfer calling the course, I want to book a tee time by speaking naturally ("I'd like a tee time for 4 this Saturday morning") so it's as easy as talking to a person.
- **Acceptance Criteria:**
  - Deepgram STT converts speech to text in real-time
  - NLU parses intent: date, time preference, party size, player names
  - Bot searches availability and presents options verbally
  - Golfer confirms verbally, bot completes booking
  - Confirmation SMS sent automatically
  - If golfer has an account (by phone number match), pull their profile

**US-6.7.2:** As a golfer, I want the voice bot to answer common questions (hours, pricing, directions, course conditions) so I get instant answers.
- **Acceptance Criteria:**
  - FAQ knowledge base configurable per course
  - Bot handles: hours of operation, green fees, cart fees, dress code, directions, current conditions
  - Natural conversational flow — not rigid IVR menu
  - Can handle multiple questions in one call

**US-6.7.3:** As a course manager, I want calls handed off to staff when the bot can't handle the request so we don't lose customers.
- **Acceptance Criteria:**
  - Handoff triggers: golfer requests human, bot confidence drops below threshold, complex request (tournament booking, complaint)
  - Warm transfer: bot summarizes conversation context to staff
  - If no staff available, take message and callback number
  - Configurable hours: bot-only after hours, bot + handoff during business hours

**US-6.7.4:** As a course manager, I want all calls recorded and transcribed so I can review them for quality and training.
- **Acceptance Criteria:**
  - All calls recorded (with required consent disclosure)
  - Automatic transcription via Deepgram
  - Searchable transcript archive
  - Analytics: calls per day, booking conversion rate, handoff rate, common questions
  - Flag calls that resulted in handoff for review

**Technical Architecture:**
- Deepgram STT (streaming) for real-time speech-to-text
- Deepgram TTS for natural voice responses (or ElevenLabs for higher quality)
- LLM (Claude/GPT) for natural language understanding and response generation
- Twilio Programmable Voice for telephony layer
- WebSocket pipeline: Twilio → Deepgram STT → LLM → Deepgram TTS → Twilio
- Average call latency target: < 500ms response time

---

### 6.8 Admin Dashboard & Analytics (P0)

**Description:** The command center for course operators. Real-time dashboards and historical reporting to drive decisions.

**User Stories:**

**US-6.8.1:** As a course owner, I want a real-time revenue dashboard so I always know how the course is performing.
- **Acceptance Criteria:**
  - Today's revenue (with comparison to same day last week/year)
  - Revenue by category: green fees, cart, packages, F&B, pro shop
  - Rolling 7-day, 30-day, 90-day trends
  - Revenue per available tee time (RevPATT) metric
  - Year-over-year comparison
  - Dashboard loads in < 2 seconds

**US-6.8.2:** As a course manager, I want utilization reports so I can see which times are consistently empty and price accordingly.
- **Acceptance Criteria:**
  - Heatmap view: utilization by day-of-week × time-of-day
  - Occupancy rate trend over time
  - Fill rate by booking channel (online, phone, walk-in, voice bot)
  - No-show rate by day/time/golfer segment
  - Forecasting: predicted utilization for next 7 days

**US-6.8.3:** As a course owner, I want a custom report builder so I can answer my own questions without waiting for IT.
- **Acceptance Criteria:**
  - Drag-and-drop report builder with dimensions and metrics
  - Common dimensions: date, time, day of week, rate category, booking channel, golfer segment
  - Common metrics: bookings, revenue, utilization, avg price, no-shows
  - Save and schedule reports (email delivery)
  - Export to CSV, PDF

**US-6.8.4:** As a course manager, I want pace of play analytics so I can identify slow groups and improve flow.
- **Acceptance Criteria:**
  - Track estimated vs actual round times
  - Identify bottleneck holes
  - Alert ranger when group falls > 15 min behind pace
  - Historical pace data by day/time/group size
  - Integration with tee sheet to show pace status

---

### 6.9 Course Operations (P1)

**Description:** Tools for managing the physical course — maintenance, carts, weather, and staff dispatch.

**User Stories:**

**US-6.9.1:** As a superintendent, I want to schedule and communicate maintenance windows so the tee sheet reflects course conditions.
- **Acceptance Criteria:**
  - Maintenance calendar integrated with tee sheet
  - Block tee times for specific holes or full course
  - Maintenance types: mowing, aeration, overseeding, cart path work
  - Notifications to golfers affected by maintenance
  - Historical maintenance log

**US-6.9.2:** As a course manager, I want cart management so I can track fleet status and assign carts efficiently.
- **Acceptance Criteria:**
  - Cart inventory: total fleet, available, in-use, charging, out-of-service
  - Auto-assign cart to booking at check-in
  - Cart return tracking
  - Fleet utilization reporting

**US-6.9.3:** As a course manager, I want weather integration so I can make informed decisions about operations.
- **Acceptance Criteria:**
  - Current conditions displayed on dashboard (temp, wind, precipitation)
  - Hourly forecast for today + 7-day outlook
  - Lightning alert system with SMS to staff
  - Automatic course closure workflow (rain/lightning)
  - Weather data correlated with booking patterns in analytics

**US-6.9.4:** As a pro shop manager, I want to dispatch rangers/marshals to specific holes so I can manage pace of play.
- **Acceptance Criteria:**
  - Real-time course map showing group positions (estimated from tee times)
  - Dispatch notification to ranger (SMS or in-app)
  - Ranger can update group status from mobile
  - Log interactions for review

---

### 6.10 Pro Shop & F&B POS (P2)

**Description:** Point-of-sale for pro shop retail and food & beverage operations. Deeply integrated with the tee sheet and golfer profiles.

**User Stories:**

**US-6.10.1:** As a pro shop worker, I want a POS that lets me ring up merchandise and charge it to a golfer's tab or booking.
- **Acceptance Criteria:**
  - Product catalog with categories, SKUs, barcodes
  - Barcode scanning support
  - Charge to golfer profile / booking
  - Cash, card, and account payment methods
  - Daily close-out and reconciliation
  - Inventory tracking (auto-deduct on sale)

**US-6.10.2:** As an F&B manager, I want mobile ordering so beverage cart staff can take orders on the course.
- **Acceptance Criteria:**
  - Mobile POS interface (tablet/phone)
  - Charge to golfer tab by name/tee time
  - Works with limited connectivity (offline-first with sync)
  - Kitchen/bar order display
  - Tab management (open, close, transfer)

---

### 6.11 Tournament Management (P1)

**Description:** Create and manage tournaments, leagues, and events with registration, scoring, and leaderboards.

**User Stories:**

**US-6.11.1:** As a course manager, I want to create a tournament with online registration so golfers can sign up and pay.
- **Acceptance Criteria:**
  - Tournament creation: name, date, format, max players, entry fee, included items
  - Online registration page (shareable link)
  - Payment collection at registration
  - Automatic tee sheet blocking for tournament times
  - Waitlist when full

**US-6.11.2:** As a tournament director, I want to support common formats (stroke play, match play, scramble, best ball, Stableford) so I can run any type of event.
- **Acceptance Criteria:**
  - Pre-built format templates
  - Handicap-based team balancing (for scrambles)
  - Flight creation based on handicap ranges
  - Scoring rules engine per format

**US-6.11.3:** As a golfer in a tournament, I want live scoring and leaderboards so I can see standings in real-time.
- **Acceptance Criteria:**
  - Mobile-friendly scoring input
  - Real-time leaderboard (WebSocket updates)
  - Leaderboard display page (shareable, embeddable)
  - Score verification workflow

---

### 6.12 Mobile App (P2)

**Description:** Native mobile app for golfers — booking, GPS, scorecard, and notifications.

**User Stories:**

**US-6.12.1:** As a golfer, I want a mobile app to book tee times, view my history, and get notifications.
- **Acceptance Criteria:**
  - React Native app (iOS + Android from one codebase)
  - Book tee times across any TeeTimes Pro course
  - View booking history and upcoming tee times
  - Push notifications for reminders, waitlist, promotions
  - Apple Pay / Google Pay for fast checkout

**US-6.12.2:** As a golfer, I want GPS yardage and a digital scorecard so I don't need a separate app.
- **Acceptance Criteria:**
  - GPS hole map with front/center/back yardages
  - Digital scorecard with stat tracking
  - Round history and statistics
  - Share round results

---

### 6.13 API & Integrations (P1)

**Description:** A public API and integration ecosystem that makes TeeTimes Pro the center of a course's tech stack.

**User Stories:**

**US-6.13.1:** As a course owner with a custom website, I want an API to build custom booking experiences.
- **Acceptance Criteria:**
  - Public GraphQL API with full tee sheet, booking, and golfer operations
  - REST endpoints for common operations (for simpler integrations)
  - API key management per tenant
  - Rate limiting (1000 requests/min default)
  - Comprehensive API documentation (auto-generated from schema)
  - SDKs: JavaScript, Ruby, Python

**US-6.13.2:** As a course manager, I want webhook notifications so my other systems stay in sync.
- **Acceptance Criteria:**
  - Webhooks for: booking.created, booking.cancelled, booking.checked_in, payment.completed, golfer.created
  - Webhook management UI (create, test, view delivery logs)
  - Retry logic with exponential backoff
  - Signature verification for security

**US-6.13.3:** As a course accountant, I want QuickBooks/Xero integration so revenue flows automatically into accounting.
- **Acceptance Criteria:**
  - OAuth connection to QuickBooks Online or Xero
  - Daily revenue sync (or real-time)
  - Map chart of accounts
  - Invoice generation for prepaid packages/memberships
  - Reconciliation report

**US-6.13.4:** As a course manager, I want to syndicate my tee times to GolfNow and other marketplaces so I get distribution without giving up control.
- **Acceptance Criteria:**
  - Configurable: which times to syndicate, at what price, to which marketplaces
  - One-way sync: our system is source of truth
  - Marketplace bookings flow back into our tee sheet
  - Commission/fee tracking per marketplace
  - Can pause/resume syndication

---

## 7. Technical Architecture

### 7.1 System Overview

```
┌─────────────────┐     ┌──────────────┐     ┌─────────────┐
│  React Frontend  │────▶│  GraphQL API  │────▶│  PostgreSQL  │
│  (TypeScript)    │     │  (Rails 8)    │     │  (Primary)   │
└─────────────────┘     └──────┬───────┘     └─────────────┘
                               │                      │
┌─────────────────┐     ┌──────┴───────┐     ┌─────────────┐
│ Booking Widget   │────▶│  Sidekiq     │────▶│    Redis     │
│ (Embeddable)     │     │  (Workers)   │     │  (Cache/PubSub)│
└─────────────────┘     └──────────────┘     └─────────────┘
                               │
┌─────────────────┐     ┌──────┴───────┐     ┌─────────────┐
│ Voice Bot        │────▶│ ActionCable  │     │   Stripe    │
│ (Deepgram+Twilio)│     │ (WebSocket)  │     │  Connect    │
└─────────────────┘     └──────────────┘     └─────────────┘
```

### 7.2 Backend — Rails 8 API

- **Ruby 3.3+** with YJIT enabled for performance
- **Rails 8** API-only mode (no server-side rendering)
- **graphql-ruby** gem for the GraphQL API layer
- **PostgreSQL 16** as primary database
- **Redis 7** for caching, Sidekiq queues, ActionCable pub/sub
- **Sidekiq** for background job processing (emails, SMS, webhooks, reporting)
- **ActionCable** over WebSocket for real-time tee sheet updates
- **Devise** + **OmniAuth** for authentication
- **Pundit** for authorization policies
- **ActsAsTenant** or custom `Current.tenant` scoping for multi-tenancy
- **StoreModel** or **jsonb** columns for flexible configuration storage
- **PgSearch** for full-text search on golfer profiles

### 7.3 Frontend — React 18+ with TypeScript

- **React 18+** with TypeScript (strict mode)
- **Vite** for build tooling
- **Apollo Client** for GraphQL state management
- **TailwindCSS** for styling (utility-first, responsive)
- **React DnD** or **dnd-kit** for drag-and-drop tee sheet
- **Recharts** or **Nivo** for analytics charts
- **React Hook Form** + **Zod** for form handling and validation
- **React Router** for navigation
- **Vitest** + **React Testing Library** for testing

### 7.4 Real-Time Architecture

The tee sheet must be collaborative in real-time:

1. User makes change (drag booking, add walk-on, check-in)
2. Optimistic update in React state
3. GraphQL mutation sent to Rails
4. Rails processes, broadcasts update via ActionCable to all connected clients
5. Other clients receive update, merge into their state
6. Conflict resolution: server wins, client reverts if conflict detected

**Scaling:** ActionCable backed by Redis Pub/Sub. For scale beyond single server, use AnyCable (Go-based ActionCable server) for 10K+ concurrent connections.

### 7.5 Multi-Tenancy Architecture

**Approach:** Shared database with row-level tenant scoping.

```ruby
# Every model includes tenant scoping
class Booking < ApplicationRecord
  acts_as_tenant :organization
  # All queries automatically scoped: WHERE organization_id = ?
end
```

**Why shared DB (not schema-per-tenant):**
- Simpler deployment and operations
- Easier cross-tenant features (golfer profiles, marketplace)
- Schema migrations apply once, not per-tenant
- Better resource utilization
- Suitable up to ~10,000 tenants

**Tenant resolution:** Subdomain → Organization lookup, cached in Redis.

### 7.6 Payment Architecture (Stripe Connect)

```
Golfer → Stripe Checkout → Platform Account → Connected Account (Course)
                                    ↓
                           Application Fee (our revenue)
```

- Each course onboards as a Stripe Connect Express account
- Bookings create Stripe PaymentIntents with `application_fee_amount`
- Platform collects fee automatically on each transaction
- Courses receive net amount on their Stripe payout schedule

### 7.7 Voice Bot Architecture

```
Phone Call (PSTN) → Twilio → WebSocket → Deepgram STT → LLM (intent + response)
                                                              ↓
              Twilio ← WebSocket ← Deepgram TTS ← Response text
                                                              ↓
                                          GraphQL API (search availability, create booking)
```

- Twilio Media Streams for real-time audio
- Deepgram Nova-2 for STT (streaming, low latency)
- Claude/GPT for NLU and conversational AI
- Deepgram Aura for TTS (natural voice)
- End-to-end latency target: < 800ms

### 7.8 Deployment

- **Docker** containers (Rails app, Sidekiq workers, AnyCable)
- **Docker Compose** for local dev
- **Cloud:** Render, Railway, or AWS ECS (start simple, migrate as needed)
- **Database:** Managed PostgreSQL (Render, AWS RDS, or Neon)
- **Redis:** Managed Redis (Upstash or AWS ElastiCache)
- **CDN:** CloudFlare for static assets and booking widget
- **CI/CD:** GitHub Actions → automated testing → deploy to staging → promote to production

---

## 8. Data Model (Key Entities)

### Core Entities

```
organizations (tenants)
├── courses
│   ├── holes
│   ├── tee_boxes
│   ├── tee_sheet_configs
│   ├── rate_categories
│   ├── pricing_rules (dynamic pricing)
│   └── blocked_times
├── users (staff)
│   ├── roles
│   └── permissions
├── tee_times
│   └── bookings
│       ├── booking_players
│       ├── payments
│       └── cancellations
├── golfer_profiles
│   ├── handicap_records
│   ├── loyalty_accounts
│   ├── packages (prepaid)
│   └── booking_history
├── tournaments
│   ├── tournament_rounds
│   ├── tournament_registrations
│   ├── scores
│   └── leaderboards
├── products (pro shop / F&B)
│   ├── inventory_items
│   └── orders
├── campaigns (email/SMS)
│   ├── segments
│   └── campaign_sends
├── notifications
│   ├── sms_messages
│   └── email_messages
├── voice_calls
│   ├── transcripts
│   └── call_recordings
└── webhook_subscriptions
    └── webhook_deliveries
```

### Key Table Details

**organizations**
- `id`, `name`, `slug`, `subdomain`, `custom_domain`, `stripe_connect_id`, `settings (jsonb)`, `plan`, `status`

**courses**
- `id`, `organization_id`, `name`, `holes_count`, `par`, `address`, `lat/lng`, `timezone`, `tee_time_interval_minutes`, `opening_time`, `closing_time`

**tee_times**
- `id`, `course_id`, `starts_at (timestamptz)`, `interval_minutes`, `max_players`, `status (open/booked/blocked/checked_in)`, `block_reason`, `price_cents`, `rate_category_id`

**bookings**
- `id`, `tee_time_id`, `golfer_profile_id`, `player_count`, `status (confirmed/cancelled/checked_in/no_show)`, `total_price_cents`, `payment_status`, `booked_via (online/phone/walk_in/voice_bot)`, `stripe_payment_intent_id`, `cancellation_reason`, `notes`

**golfer_profiles**
- `id`, `user_id (nullable)`, `email`, `phone`, `first_name`, `last_name`, `handicap_index`, `home_course_id`, `total_rounds`, `total_spend_cents`, `tags (array)`, `loyalty_tier`, `loyalty_points`

**pricing_rules**
- `id`, `course_id`, `rate_category_id`, `rule_type (time_of_day/day_of_week/occupancy/weather/lead_time)`, `conditions (jsonb)`, `modifier_type (percent/fixed)`, `modifier_value`, `floor_price_cents`, `ceiling_price_cents`, `priority`

---

## 9. Non-Functional Requirements

### 9.1 Performance
- Tee sheet page load: < 1 second
- Booking widget load: < 2 seconds
- API response time (p95): < 200ms
- WebSocket update propagation: < 100ms
- Search availability query: < 300ms
- Voice bot response latency: < 800ms
- Support 100+ concurrent staff users per course
- Support 1000+ concurrent booking sessions platform-wide

### 9.2 Security
- **PCI DSS compliance:** Level 4 (SAQ-A) — Stripe handles all card data
- **SOC 2 Type II:** Target for Year 2 (required by larger course groups)
- **Data encryption:** AES-256 at rest, TLS 1.3 in transit
- **Authentication:** Bcrypt password hashing, 2FA for staff accounts (TOTP)
- **Authorization:** Row-level tenant isolation, Pundit policies, principle of least privilege
- **Audit logging:** All data modifications logged with user, timestamp, old/new values
- **GDPR:** Data export, deletion, and consent management for international golfers
- **Rate limiting:** API and auth endpoints rate-limited to prevent abuse

### 9.3 Scalability
- **Database:** Read replicas for reporting queries, partitioning on tee_times by date
- **Caching:** Redis for hot data (today's tee sheet, pricing rules, config)
- **CDN:** Static assets and booking widget served from CDN
- **Horizontal scaling:** Stateless Rails app servers behind load balancer
- **Target:** Support 500 courses, 10K concurrent users without architectural changes

### 9.4 Accessibility
- **WCAG 2.1 AA** compliance for all public-facing pages
- Keyboard navigable tee sheet and booking flow
- Screen reader support for booking widget
- Color contrast ratios meeting AA standards
- Focus management for modal dialogs and dynamic content

### 9.5 Uptime & Reliability
- **SLA target:** 99.9% uptime (< 8.76 hours downtime/year)
- **Zero-downtime deployments** via rolling updates
- **Database backups:** Continuous WAL archiving + daily snapshots
- **Disaster recovery:** RTO < 1 hour, RPO < 5 minutes
- **Monitoring:** Application performance monitoring (Sentry for errors, Prometheus/Grafana for metrics)
- **Alerting:** PagerDuty for critical issues (payment processing, database, tee sheet)

---

## 10. Monetization Strategy

### 10.1 SaaS Subscription Tiers

| Plan | Price/mo | Target | Includes |
|------|----------|--------|----------|
| **Starter** | $199/mo | Single course, basic needs | Tee sheet, online booking, basic reporting, email notifications |
| **Professional** | $399/mo | Single course, full features | Everything in Starter + dynamic pricing, CRM, SMS, marketing campaigns, analytics dashboard |
| **Enterprise** | $599/mo per course | Multi-course operators | Everything in Professional + voice bot, tournament management, API access, priority support, custom integrations |

### 10.2 Transaction Fees
- **Payment processing:** Stripe base fees (2.9% + $0.30) pass through to course + 0.25% platform fee
- **Per-booking fee (Starter only):** $0.25 per online booking (waived on Professional+)
- **Marketplace syndication:** 10-15% commission on bookings from syndicated channels

### 10.3 Add-Ons
- **Voice bot:** $149/mo (included in Enterprise)
- **POS module:** $99/mo per terminal
- **Advanced analytics:** $49/mo (included in Professional+)
- **Custom domain + white-label:** $29/mo (included in Professional+)
- **SMS overages:** $0.01/SMS beyond included 1,000/mo (Starter), 5,000/mo (Professional), 15,000/mo (Enterprise)

### 10.4 Revenue Projections (Conservative)

| Metric | Year 1 | Year 2 | Year 3 |
|--------|--------|--------|--------|
| Courses | 15 | 75 | 200 |
| Avg Monthly Revenue per Course | $350 | $400 | $450 |
| MRR | $5,250 | $30,000 | $90,000 |
| ARR | $63,000 | $360,000 | $1,080,000 |

---

## 11. Development Roadmap

### Phase 1: MVP (Weeks 1-12)
**Goal:** A usable product that a course can run on.

| Week | Focus |
|------|-------|
| 1-2 | Project setup, data model, auth system, multi-tenancy |
| 3-4 | Tee sheet backend (GraphQL API, models, business logic) |
| 5-6 | Tee sheet frontend (React, real-time updates, drag-and-drop) |
| 7-8 | Online booking engine (widget, availability search, checkout) |
| 9-10 | Payment processing (Stripe Connect, checkout, reporting) |
| 11 | Notifications (email confirmations, SMS reminders) |
| 12 | Testing, polish, deploy, pilot with first course |

**Deliverable:** Tee sheet + booking + payments + auth + basic notifications.

### Phase 2: Intelligence (Weeks 13-18)
**Goal:** Dynamic pricing, CRM, and analytics make the product indispensable.

- Dynamic pricing engine with rules and recommendations
- CRM: golfer profiles, segmentation, play history
- Analytics dashboard: revenue, utilization, pace of play
- Email/SMS campaign builder
- Waitlist management
- Advanced booking policies

### Phase 3: Voice & Events (Weeks 19-24)
**Goal:** Voice bot differentiator and tournament management.

- Deepgram voice bot integration (phone booking)
- Tournament creation, registration, scoring, leaderboards
- League management
- Voice analytics and call recording
- API v1 (public, documented)

### Phase 4: POS & Mobile (Weeks 25-32)
**Goal:** Expand from booking to full operations platform.

- Pro shop POS (products, inventory, checkout)
- F&B POS (mobile ordering, tab management)
- Mobile app (React Native — golfer booking + GPS + scorecard)
- Cart management
- Advanced reporting and custom report builder

### Phase 5: Platform & Marketplace (Ongoing)
**Goal:** Become the platform for golf technology.

- GolfNow/marketplace syndication
- Public API marketplace (third-party integrations)
- Accounting integrations (QuickBooks, Xero)
- Webhook ecosystem
- International expansion (multi-currency, multi-language)
- Advanced AI features (demand forecasting, personalized pricing)

---

## 12. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| **Switching costs too high** — courses won't migrate from existing systems | High | Critical | White-glove migration service. Import tee times, golfer data, rate structures. Offer free parallel-run period. Target courses with expiring contracts. |
| **GolfNow contractual lock-in** — courses can't leave marketplace agreements | Medium | High | Position as complement, not replacement. "Use us as your system of record, keep GolfNow for distribution." Build syndication to make it seamless. |
| **Solo founder velocity** — too ambitious for one engineer | High | High | Ruthless MVP scope. Use AI coding tools aggressively. Consider technical co-founder or contract help for frontend. Ship faster by cutting scope, not quality. |
| **Payment processing competition** — Lightspeed and others competing on rates | Medium | Medium | Don't compete on rate alone. Compete on platform value. The voice bot and modern UX justify a small premium. Pass through Stripe's rates transparently. |
| **Voice bot quality** — AI not good enough for natural booking conversations | Medium | Medium | Start with limited scope (booking only, known intents). Expand gradually. Always offer handoff to human. Iterate on prompts and training data. |
| **Stripe Connect limitations** — complex for international or large course groups | Low | Medium | Start US-only. Stripe Connect handles most complexity. For enterprise accounts, consider custom Stripe integration later. |
| **Market downturn** — golf participation drops | Low | High | Golf has been resilient historically. Focus on revenue optimization (dynamic pricing) — courses need this more in downturns. Reduce costs, don't just grow revenue. |
| **Security breach** — golfer PII or payment data compromised | Low | Critical | Never store card data (Stripe handles it). Encrypt PII at rest. Regular penetration testing. SOC 2 path. Audit logging for all data access. |

---

## 13. Success Metrics / KPIs

### Product Metrics
| Metric | Target (6 months) | Target (12 months) |
|--------|-------------------|---------------------|
| Active courses | 5 | 15 |
| Monthly active golfers | 2,000 | 10,000 |
| Online bookings/month | 5,000 | 25,000 |
| Booking conversion rate (widget) | 8% | 12% |
| Tee sheet utilization improvement | 5% | 10% |
| Voice bot call resolution rate | 60% | 80% |

### Business Metrics
| Metric | Target (6 months) | Target (12 months) |
|--------|-------------------|---------------------|
| MRR | $2,000 | $5,250 |
| ARR | $24,000 | $63,000 |
| Customer churn (monthly) | < 3% | < 2% |
| NPS (operator) | > 40 | > 50 |
| CAC | < $2,000 | < $1,500 |
| LTV | > $12,000 | > $15,000 |

### Technical Metrics
| Metric | Target |
|--------|--------|
| Tee sheet load time (p95) | < 1s |
| API response time (p95) | < 200ms |
| Uptime | 99.9% |
| Error rate | < 0.1% |
| WebSocket reconnection time | < 2s |
| Voice bot latency (first response) | < 800ms |

---

## 14. Open Questions

1. **Naming:** "TeeTimes Pro" is a working name. Need to validate domain availability and trademark. Consider: TeeSheet.io, CourseOS, FairwayHQ, GreenSide.
2. **First pilot course:** Do we know a course owner willing to beta test? Municipal courses may be easier to approach (budget-conscious, procurement-friendly).
3. **Voice bot MVP:** Should we start with a basic IVR-style bot (menu-driven) or go straight to natural language? Natural language is the vision but more complex.
4. **Marketplace relationship:** Do we position as anti-GolfNow from day one, or cooperate (syndication) and differentiate on the operator experience?
5. **Mobile app timing:** Is a mobile app needed for MVP? Or is a responsive web app sufficient for Year 1?
6. **Pricing validation:** Need to interview 10+ course operators to validate willingness to pay $199-599/mo. Are we in the right range?
7. **Multi-tenancy at scale:** At what point (if ever) do we need to consider schema-per-tenant or database-per-tenant? Probably not until 1,000+ courses.
8. **Open source angle:** Would open-sourcing the tee sheet component or booking widget drive adoption? Could attract developer community.
9. **International from Day 1?** Multi-currency and multi-language add complexity. Recommendation: US-only for MVP, international in Year 2.
10. **PGA/USGA partnerships:** Should we pursue official partnerships for handicap data integration? GHIN API access?

---

*This PRD is a living document. It should be updated as we learn from customer conversations, pilot feedback, and market changes. The goal is to build something courses love using — software that makes their day better, not just different.*
