# Tee Time Platform — Competitive Analysis

> Last updated: 2026-03-06

## Market Overview

The golf course management software market is valued at approximately **$1.2–1.5 billion globally** (2025) and growing at ~8-10% CAGR, driven by post-COVID golf participation surges, digital transformation of course operations, and demand for dynamic pricing and yield management tools.

**Key market facts:**
- ~16,000 golf courses in the US (~33,000 globally)
- US golf industry generates ~$84 billion annually (National Golf Foundation)
- 41.1 million Americans played golf/visited a golf facility in 2023 (NGF)
- Online tee time bookings grew 35%+ from 2019-2023
- ~60% of courses still use legacy or fragmented systems
- Average course revenue: $1.5-3M/year (public), $5-15M/year (private clubs)

---

## Competitor Deep Dive

### 1. ForeUP

| Attribute | Details |
|-----------|---------|
| **URL** | foreup.com |
| **Founded** | 2013 (Orem, Utah) |
| **Target Market** | Public courses, municipalities, daily-fee, semi-private |
| **Key Features** | Cloud-based tee sheet, POS, online booking, dynamic pricing, F&B, customer management, reporting, payment processing, marketing tools |
| **Pricing** | SaaS subscription; estimated $200-500/mo base + payment processing fees. Custom quotes. |
| **Tech** | Cloud-based, modern web UI, API available, integrates with various third parties |
| **Strengths** | Modern UI, strong in municipal/public market, good onboarding, responsive support, solid dynamic pricing |
| **Weaknesses** | Limited private club features, no tournament management, smaller scale vs GolfNow/Lightspeed, limited F&B depth |
| **Market Share** | ~1,500-2,000 courses (primarily US municipal and public) |
| **Notable Clients** | Many US municipal golf systems, city-operated courses |

**Why they matter:** ForeUP is the closest comparable to what we're building — modern, cloud-first, focused on public/muni courses. They proved the market wants modern alternatives to legacy systems. Their weakness is feature depth in private clubs and limited ecosystem.

---

### 2. Lightspeed Golf (formerly Chronogolf)

| Attribute | Details |
|-----------|---------|
| **URL** | lightspeedhq.com/golf |
| **Founded** | Chronogolf founded 2013 (Montreal); acquired by Lightspeed Commerce 2019 |
| **Target Market** | Public courses, semi-private, resorts, multi-course operators, private clubs (via Whoosh partnership) |
| **Key Features** | Tee sheet, retail POS (Lightspeed Retail), F&B POS (Lightspeed Restaurant), online booking, dynamic pricing, payments, SMS marketing, reporting/BI, custom websites & apps, Reserve with Google, AI booking concierge, waitlist technology, open API |
| **Pricing** | Custom quotes; "free software" with payment processing revenue model. No startup costs. Pay-as-you-go, no long-term contract. Processing rates are the primary revenue. Claims to save courses up to $9K/year on processing. |
| **Tech** | 100% cloud-based, runs on any device, open API, integrations ecosystem, AI features |
| **Strengths** | Backed by Lightspeed (NYSE: LSPD, ~$2B market cap), massive scale (2,000+ courses), unified retail+restaurant POS from parent company, 20 years of Chronogolf expertise, 24/7 support, AI features, Reserve with Google integration |
| **Weaknesses** | Part of larger conglomerate (golf not primary focus), complex pricing that obscures true cost, can feel enterprise-heavy for small courses, Whoosh partnership for private clubs = fragmented experience |
| **Market Share** | 2,000+ courses worldwide. Part of Lightspeed's ~165K business portfolio |
| **Notable Clients** | Major resort chains, multi-course operators |

**Why they matter:** The 800-pound gorilla. They have the deepest feature set and biggest parent company. But they're a conglomerate play — golf is one vertical among many. This creates opportunity for a focused competitor that's faster, more opinionated, and golf-first.

---

### 3. GolfNow / NBC Sports Next (EZLinks, G1, TeeSheet)

| Attribute | Details |
|-----------|---------|
| **URL** | golfnow.com, golfnowbusiness.com |
| **Founded** | EZLinks founded 1995; GolfNow launched 2008; acquired by NBC Sports Group/Comcast. EZLinks merged into GolfNow. |
| **Target Market** | All segments — public, private, resort, municipal. Consumer marketplace + B2B course management |
| **Key Features** | Tee time distribution/marketplace (3.9M golfers), G1 cloud-based course management, tee sheet (multiple products), POS, mobile check-in & pay, club management systems, payment processing, inventory & marketing tools, booking engine, business intelligence, customer service (GolfNow Answers) |
| **Pricing** | Barter model: courses give GolfNow "hot deal" tee times in exchange for marketplace listing + software. Also paid tiers. G1/EZLinks products are separately licensed. Complex, opaque pricing. |
| **Tech** | Mix of legacy (EZLinks is older) and modern (G1). Cloud and on-prem options depending on product line. |
| **Strengths** | Dominant marketplace (3.9M active bookers), 9,000 course partners, brand recognition, NBC/Comcast backing, GolfPass membership bundle with NBC Sports, widest distribution network |
| **Weaknesses** | The barter model is **deeply resented** by course operators (giving away inventory). Multiple legacy product lines create fragmented experience (EZLinks vs G1 vs TeeSheet vs Golf365). Slow innovation. Lock-in tactics. Poor operator satisfaction scores. |
| **Market Share** | ~9,000 courses (largest by distribution). ~40-50% of US online tee time bookings |
| **Notable Clients** | Broad penetration across all course types |

**Why they matter:** The marketplace is their moat. Courses hate the barter model but feel trapped because of golfer eyeballs. Our opportunity: offer courses a way to own their booking relationship while optionally syndicating to GolfNow. "Use us AND GolfNow, but we're your system of record."

---

### 4. Club Prophet

| Attribute | Details |
|-----------|---------|
| **URL** | clubprophet.com |
| **Founded** | ~1990 (30+ years in business) |
| **Target Market** | All segments — daily fee, semi-private, private clubs, resorts, MCOs, municipals, simulators |
| **Key Features** | POS (core strength), tee sheet (Starter Hut), F&B, member management, payment processing (ProphetPay, PCI compliant), marketing/reputation management, dynamic pricing via Priswing integration |
| **Pricing** | Custom quotes. Mid-range SaaS pricing. Platform fees on payment processing can offset costs. |
| **Tech** | Both local and cloud-based options. Transitioning to cloud but legacy roots show. |
| **Strengths** | 30+ year track record, deep POS functionality, broadest market coverage (even simulators), Priswing dynamic pricing integration, PCI compliance built-in |
| **Weaknesses** | UI feels dated compared to modern competitors, marketing feels old-school, slower cloud transition, less buzz/market momentum than newer entrants, website quality suggests smaller/older team |
| **Market Share** | Several hundred to low thousands of courses. Established but not growing rapidly. |

**Why they matter:** Proves the longevity of the market. 30 years means massive switching costs — their customers are loyal but potentially underserved on modern UX. Target their base with a migration path.

---

### 5. Teesnap

| Attribute | Details |
|-----------|---------|
| **URL** | teesnap.com |
| **Founded** | ~2015 |
| **Target Market** | Public, private, municipal, multi-course operations |
| **Key Features** | Cloud-based tee sheet, POS, F&B, online booking engine, reporting, marketing services (dedicated marketing advisor), profile-based pricing, CRM, mobile-friendly booking, social features (friend invites), pre-pay options |
| **Pricing** | Custom quotes. Likely $250-450/mo range. Flat-rate payment processing. |
| **Tech** | Cloud-based, modern web platform, mobile-friendly, integrated across modules |
| **Strengths** | Modern UI, all-in-one platform, 400+ facilities, strong marketing services offering (dedicated advisors), profile-based smart pricing, social booking features, good testimonials |
| **Weaknesses** | Smaller scale (400 facilities), limited API/integrations ecosystem, no tournament management, no AI/voice features, US-only |
| **Market Share** | 400+ facilities |

**Why they matter:** Direct competitor to what we're building. Modern, cloud-first, all-in-one. Their marketing services model (dedicated advisor per course) is interesting and generates stickiness. Their profile-based pricing and social booking features are innovative.

---

### 6. Sagacity Golf (formerly Quick18)

| Attribute | Details |
|-----------|---------|
| **URL** | sagacitygolf.com (quick18.com redirects here) |
| **Founded** | ~2010 (as Quick18, rebranded to Sagacity) |
| **Target Market** | Public courses, daily-fee, focused on revenue optimization |
| **Key Features** | Dynamic pricing (core), tee sheet, AI chatbot concierge (Sagacity AI), mobile apps (course app, multi-course app, Yards rangefinder, Sagacity 360), pricing tools (Group Quote, Power Hours, Price Check), benchmarking & competitive intelligence, marketing services, Toast integration for F&B |
| **Pricing** | Custom quotes. Revenue-share model likely tied to dynamic pricing uplift. Claims 24% revenue increase for customers. |
| **Tech** | Cloud-based, modern. AI-powered chatbot for 24/7 booking. Integrates with Toast POS for F&B. |
| **Strengths** | **AI-first approach** — their AI chatbot books tee times, answers questions 24/7. Dynamic pricing is market-leading (24% revenue uplift claim). Benchmarking tools. Mobile apps. Expert support model. |
| **Weaknesses** | Not a full operational platform (no deep POS, no member management for private clubs), focused primarily on revenue/pricing vertical, requires integration with other systems for full operations |
| **Market Share** | Growing but focused on pricing/revenue niche |

**Why they matter:** They're the most innovative competitor in AI/voice. Their AI concierge is **exactly** the direction we're going with Deepgram voice bot. Study them closely. Their weakness: they're a bolt-on, not a full platform. We can build this natively.

---

### 7. Golf Genius

| Attribute | Details |
|-----------|---------|
| **URL** | golfgenius.com |
| **Founded** | ~2008 |
| **Target Market** | Private clubs, country clubs, associations, resorts, tours |
| **Key Features** | Tournament management (core — 40M+ rounds/year, 11,000+ clubs), Golf Shop POS, CoachNow Academy, Operation 36 (player development), Golf Hub (event promotion), Twilight Golf Leagues, live scoring, leaderboards |
| **Pricing** | Subscription-based. Tournament module: ~$100-300/mo. Golf Shop: separate pricing. Enterprise for associations/tours. |
| **Tech** | Cloud-based, modern web + mobile apps |
| **Strengths** | Dominant in tournament management (no close competitor), trusted by PGA of America, massive scale (40M rounds), expanding into retail (Golf Shop POS), coaching platform, growing ecosystem |
| **Weaknesses** | Not a tee sheet/booking platform, no F&B, no dynamic pricing, focused primarily on events/tournaments not daily operations |
| **Market Share** | 11,000+ clubs for tournaments. Dominant in event management. |

**Why they matter:** Integration partner, not direct competitor. We should build tournament features but also integrate with Golf Genius since many clubs already use it. Their Golf Shop POS launch shows they want to expand.

---

### 8. Supreme Golf

| Attribute | Details |
|-----------|---------|
| **URL** | supremegolf.com |
| **Founded** | ~2015 |
| **Target Market** | Consumer marketplace (golfers booking tee times) |
| **Key Features** | Tee time aggregator/search engine, price comparison across GolfNow/TeeOff/course direct, booking, golfer accounts |
| **Pricing** | Free for golfers. Revenue from affiliate/booking fees with course partners. |
| **Tech** | Cloud-based consumer marketplace |
| **Strengths** | Price comparison shopping for golfers, aggregates multiple booking sources, growing consumer audience |
| **Weaknesses** | No B2B course management, pure consumer play, dependent on other platforms' inventory, thin margins |
| **Market Share** | Consumer niche. Not directly competitive. |

**Why they matter:** Potential distribution channel. We could syndicate inventory to Supreme Golf. Shows market demand for price transparency.

---

### 9. Other Notable Players

#### Tee-On (tee-on.com)
- Canadian company, strong in Canada/international
- Full suite: tee sheet, POS, membership, F&B, online booking
- Good private club features
- Smaller US presence

#### Jonas Club Software (jonasclub.com)
- Part of Jonas Software (Constellation Software)
- Targets private clubs, country clubs
- Full club management: membership, billing, F&B, golf, fitness
- Enterprise pricing, larger clubs

#### Northstar Club Management (northstarcms.com)
- Private club focused
- Membership management, billing, POS, reservations
- Competes with Jonas, Club Prophet in private segment

#### Vermont Systems (vermontsystems.com)
- RecTrac platform
- Targets municipal recreation departments (golf is one module)
- Strong in government/municipal market

#### CaddyMaster (part of NBC Sports Next)
- Legacy tee sheet software
- Being sunset in favor of G1 platform
- Still in use at many courses

#### Priswing (priswing.com)
- Dynamic pricing specialist
- Integrates with Club Prophet, others
- Not a full platform — pricing engine only

#### Whoosh (formerly IBS/Club Software)
- Private club tee sheet/scheduling
- Now partnered with Lightspeed for POS
- Drag-and-drop tee sheet for member clubs

---

## Competitive Landscape Matrix

| Competitor | Tee Sheet | POS | F&B | Booking | Dynamic Pricing | CRM | Marketing | Tournaments | Mobile App | AI/Voice | API | Price Range |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **ForeUP** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ❌ | ❌ | ❌ | ⚠️ | $$  |
| **Lightspeed Golf** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ (new) | ✅ | $$$ |
| **GolfNow/EZLinks** | ✅ | ✅ | ⚠️ | ✅ | ⚠️ | ⚠️ | ✅ | ❌ | ✅ | ❌ | ⚠️ | $$-$$$ |
| **Club Prophet** | ✅ | ✅ | ✅ | ✅ | ✅* | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | $$ |
| **Teesnap** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | $$ |
| **Sagacity** | ✅ | ❌ | ⚠️* | ✅ | ✅✅ | ⚠️ | ✅ | ❌ | ✅ | ✅ | ⚠️ | $$-$$$ |
| **Golf Genius** | ❌ | ✅ (new) | ❌ | ❌ | ❌ | ⚠️ | ✅ | ✅✅ | ✅ | ❌ | ⚠️ | $$ |
| **Supreme Golf** | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | Free |

✅ = Strong  ⚠️ = Basic/Limited  ❌ = None  * = Via integration

---

## Key Market Gaps & Opportunities

### 1. Voice/AI Booking is Wide Open
Only Sagacity has an AI chatbot. **No one** has voice-based phone booking (Deepgram STT). Courses still rely on staff answering phones. This is our biggest differentiator.

### 2. Modern Developer Experience / API-First
No competitor offers a true developer-friendly API (REST + GraphQL). Lightspeed has an "open API" but it's not developer-friendly. Building API-first enables an ecosystem.

### 3. Unified Platform Without Compromise
Lightspeed assembled their platform through acquisitions. GolfNow has 5+ legacy products. No one built a unified, modern platform from scratch recently. Being purpose-built is an advantage.

### 4. Transparent, Modern Pricing
GolfNow's barter model and opaque pricing across the industry creates frustration. Simple, transparent SaaS pricing (like Stripe's approach) would be differentiated.

### 5. Real-Time Collaborative Tee Sheet
No competitor offers a truly real-time collaborative tee sheet (think Google Docs for tee times). WebSocket-powered, multi-user, instant updates.

### 6. Multi-Tenant SaaS for Course Groups
Multi-course operators are underserved. A true multi-tenant platform with roll-up reporting, standardized ops, and portfolio management is needed.

### 7. No-Marketplace Option
Courses want direct relationships with golfers. Our booking engine should be course-branded, not marketplace-branded, while optionally syndicating to GolfNow/Supreme Golf.

---

## Operator Pain Points (from research)

1. **Fragmented systems** — POS from one vendor, tee sheet from another, F&B from a third
2. **GolfNow dependency** — giving away inventory for marketplace access
3. **Legacy UX** — training staff on clunky interfaces, high turnover in seasonal workers
4. **No dynamic pricing** — leaving money on the table or using spreadsheets
5. **Phone booking burden** — staff spending hours on phone instead of serving golfers
6. **Poor reporting** — can't easily see utilization, revenue trends, player demographics
7. **No mobile-first** — golfers expect to book on phones, many systems still desktop-only
8. **Switching costs** — data migration, retraining, contract lock-in
9. **Payment processing fees** — high rates with little negotiating power
10. **Limited marketing tools** — email campaigns are basic, no SMS, no automation
