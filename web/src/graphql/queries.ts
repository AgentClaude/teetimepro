import { gql } from "@apollo/client";

// Accounting queries
export const GET_ACCOUNTING_INTEGRATION = gql`
  query GetAccountingIntegration($provider: AccountingProviderEnum!) {
    accountingIntegration(provider: $provider) {
      id
      provider
      status
      companyName
      countryCode
      connectedAt
      lastSyncAt
      accountMapping
      settings
      lastErrorMessage
      lastErrorAt
      connected
      companyId
    }
  }
`;

export const GET_ACCOUNTING_SYNC_HISTORY = gql`
  query GetAccountingSyncHistory(
    $provider: AccountingProviderEnum
    $syncType: AccountingSyncTypeEnum
    $status: AccountingSyncStatusEnum
    $limit: Int
  ) {
    accountingSyncHistory(
      provider: $provider
      syncType: $syncType
      status: $status
      limit: $limit
    ) {
      id
      syncType
      status
      externalId
      retryCount
      errorMessage
      errorAt
      startedAt
      completedAt
      createdAt
      syncTypeHumanized
      provider
      duration
      retryable
      syncable {
        ... on Booking {
          id
          confirmationCode
          totalCents
          status
          user {
            fullName
            email
          }
        }
        ... on Payment {
          id
          amountCents
          stripePaymentIntentId
          status
          booking {
            confirmationCode
          }
        }
      }
    }
  }
`;

export const GET_ME = gql`
  query GetMe {
    me {
      id
      email
      firstName
      lastName
      fullName
      role
      organizationId
    }
  }
`;

export const GET_COURSES = gql`
  query GetCourses {
    courses {
      id
      name
      holes
      intervalMinutes
      maxPlayersPerSlot
      firstTeeTime
      lastTeeTime
      weekdayRateCents
      weekendRateCents
    }
  }
`;

export const GET_COURSE = gql`
  query GetCourse($id: ID!) {
    course(id: $id) {
      id
      name
      holes
      intervalMinutes
      maxPlayersPerSlot
      firstTeeTime
      lastTeeTime
      weekdayRateCents
      weekendRateCents
      twilightRateCents
      address
      phone
      voiceConfig
    }
  }
`;

export const GET_COURSES_WITH_VOICE_CONFIG = gql`
  query GetCoursesWithVoiceConfig {
    courses {
      id
      name
      voiceConfig
    }
  }
`;

export const GET_TEE_SHEET = gql`
  query GetTeeSheet($courseId: ID!, $date: ISO8601Date!) {
    teeSheet(courseId: $courseId, date: $date) {
      id
      date
      totalSlots
      availableSlots
      utilizationPercentage
      course {
        id
        name
      }
      teeTimes {
        id
        startsAt
        formattedTime
        status
        maxPlayers
        bookedPlayers
        availableSpots
        priceCents
        notes
        bookings {
          id
          confirmationCode
          status
          playersCount
          hasTurnOrder
          user {
            id
            fullName
          }
          bookingPlayers {
            id
            name
          }
        }
      }
    }
  }
`;

export const GET_BOOKINGS = gql`
  query GetBookings($courseId: ID, $date: ISO8601Date, $status: String) {
    bookings(courseId: $courseId, date: $date, status: $status) {
      id
      confirmationCode
      status
      playersCount
      totalCents
      cancellable
      createdAt
      teeTime {
        id
        startsAt
        formattedTime
      }
      user {
        id
        fullName
        email
      }
      bookingPlayers {
        id
        name
      }
    }
  }
`;

export const GET_BOOKING = gql`
  query GetBooking($id: ID!) {
    booking(id: $id) {
      id
      confirmationCode
      status
      playersCount
      totalCents
      notes
      cancellable
      cancelledAt
      cancellationReason
      createdAt
      updatedAt
      teeTime {
        id
        startsAt
        formattedTime
      }
      user {
        id
        fullName
        email
        phone
      }
      bookingPlayers {
        id
        name
      }
      auditLog {
        id
        event
        changedBy
        changes
        createdAt
      }
    }
  }
`;

export const GET_AVAILABLE_TEE_TIMES = gql`
  query GetAvailableTeeTimes(
    $courseId: ID!
    $date: ISO8601Date!
    $players: Int
  ) {
    availableTeeTimes(courseId: $courseId, date: $date, players: $players) {
      id
      startsAt
      formattedTime
      availableSpots
      priceCents
    }
  }
`;

export const GET_VOICE_CALL_LOGS = gql`
  query GetVoiceCallLogs($courseId: ID, $channel: String, $limit: Int) {
    voiceCallLogs(courseId: $courseId, channel: $channel, limit: $limit) {
      id
      courseId
      courseName
      callSid
      channel
      callerPhone
      callerName
      status
      durationSeconds
      summary
      startedAt
      endedAt
    }
  }
`;

export const GET_VOICE_CALL_LOG = gql`
  query GetVoiceCallLog($id: ID!) {
    voiceCallLog(id: $id) {
      id
      courseId
      courseName
      callSid
      channel
      callerPhone
      callerName
      status
      durationSeconds
      transcript
      summary
      startedAt
      endedAt
    }
  }
`;


export const GET_CUSTOMERS = gql`
  query GetCustomers(
    $search: String
    $role: String
    $membershipTier: String
    $loyaltyTier: String
    $minBookings: Int
    $maxBookings: Int
    $sortBy: String
    $sortDir: String
    $page: Int
    $perPage: Int
  ) {
    customers(
      search: $search
      role: $role
      membershipTier: $membershipTier
      loyaltyTier: $loyaltyTier
      minBookings: $minBookings
      maxBookings: $maxBookings
      sortBy: $sortBy
      sortDir: $sortDir
      page: $page
      perPage: $perPage
    ) {
      nodes {
        id
        email
        firstName
        lastName
        fullName
        phone
        role
        bookingsCount
        createdAt
      }
      totalCount
      page
      perPage
      totalPages
    }
  }
`;

export const GET_CUSTOMER = gql`
  query GetCustomer($id: ID!) {
    customer(id: $id) {
      id
      email
      firstName
      lastName
      fullName
      phone
      role
      bookingsCount
      createdAt
      updatedAt
      upcomingBookings {
        id
        confirmationCode
        status
        playersCount
        totalCents
        createdAt
        teeTime {
          id
          startsAt
          formattedTime
          teeSheet {
            date
            course {
              id
              name
            }
          }
        }
      }
      pastBookings {
        id
        confirmationCode
        status
        playersCount
        totalCents
        createdAt
        teeTime {
          id
          startsAt
          formattedTime
          teeSheet {
            date
            course {
              id
              name
            }
          }
        }
      }
      membership {
        id
        tier
        status
        startsAt
        endsAt
        daysRemaining
        accountBalanceCents
        creditLimitCents
        availableCreditCents
      }
      loyaltyAccount {
        id
        pointsBalance
        lifetimePoints
        tier
        tierName
        pointsNeededForNextTier
        recentTransactions {
          id
          transactionType
          points
          description
          balanceAfter
          createdAt
        }
      }
      golferProfile {
        id
        handicapIndex
        homeCourse
        preferredTee
      }
      auditLog {
        id
        event
        changedBy
        changes
        createdAt
      }
    }
  }
`;

export const GET_TOURNAMENTS = gql`
  query GetTournaments($courseId: ID, $status: TournamentStatusEnum, $upcomingOnly: Boolean) {
    tournaments(courseId: $courseId, status: $status, upcomingOnly: $upcomingOnly) {
      id
      name
      description
      format
      status
      startDate
      endDate
      holes
      teamSize
      maxParticipants
      minParticipants
      entriesCount
      registrationAvailable
      entryFeeCents
      entryFeeCurrency
      entryFeeDisplay
      handicapEnabled
      maxHandicap
      registrationOpensAt
      registrationClosesAt
      days
      course {
        id
        name
      }
      createdBy {
        id
        fullName
      }
    }
  }
`;

export const GET_TOURNAMENT = gql`
  query GetTournament($id: ID!) {
    tournament(id: $id) {
      id
      name
      description
      format
      status
      startDate
      endDate
      holes
      teamSize
      maxParticipants
      minParticipants
      entriesCount
      registrationAvailable
      entryFeeCents
      entryFeeCurrency
      entryFeeDisplay
      handicapEnabled
      maxHandicap
      rules
      prizeStructure
      registrationOpensAt
      registrationClosesAt
      days
      course {
        id
        name
      }
      createdBy {
        id
        fullName
      }
      tournamentEntries {
        id
        status
        teamName
        handicapIndex
        startingHole
        teeTime
        user {
          id
          fullName
          email
        }
      }
    }
  }
`;
export const GET_SMS_CAMPAIGNS = gql`
  query GetSmsCampaigns($status: String) {
    smsCampaigns(status: $status) {
      id
      name
      messageBody
      status
      recipientFilter
      totalRecipients
      sentCount
      deliveredCount
      failedCount
      progressPercentage
      scheduledAt
      sentAt
      completedAt
      createdAt
      createdBy {
        id
        fullName
      }
    }
  }
`;

export const GET_SMS_CAMPAIGN = gql`
  query GetSmsCampaign($id: ID!) {
    smsCampaign(id: $id) {
      id
      name
      messageBody
      status
      recipientFilter
      filterCriteria
      totalRecipients
      sentCount
      deliveredCount
      failedCount
      progressPercentage
      scheduledAt
      sentAt
      completedAt
      createdAt
      createdBy {
        id
        fullName
      }
      smsMessages {
        id
        toPhone
        status
        errorMessage
        sentAt
        deliveredAt
      }
    }
  }
`;

export const GET_DASHBOARD_STATS = gql`
  query GetDashboardStats($courseId: ID, $date: ISO8601Date) {
    dashboardStats(courseId: $courseId, date: $date) {
      todaysBookings
      todaysRevenueCents
      activeMembers
      utilizationPercentage
      upcomingBookings {
        id
        confirmationCode
        userName
        courseName
        teeTime
        playersCount
        totalCents
      }
      weeklyRevenue {
        date
        revenueCents
      }
    }
  }
`;

export const GET_REPORTS_SUMMARY = gql`
  query GetReportsSummary($courseId: ID, $days: Int) {
    reportsSummary(courseId: $courseId, days: $days)
  }
`;

// Golfer Segments
export const GET_GOLFER_SEGMENTS = gql`
  query GetGolferSegments {
    golferSegments {
      id
      name
      description
      filterCriteria
      isDynamic
      cachedCount
      lastEvaluatedAt
      createdAt
      createdBy {
        id
        fullName
      }
    }
  }
`;

export const GET_GOLFER_SEGMENT = gql`
  query GetGolferSegment($id: ID!) {
    golferSegment(id: $id) {
      id
      name
      description
      filterCriteria
      isDynamic
      cachedCount
      lastEvaluatedAt
      createdAt
      createdBy {
        id
        fullName
      }
      members {
        id
        fullName
        email
        phone
        role
        createdAt
      }
    }
  }
`;

export const PREVIEW_GOLFER_SEGMENT = gql`
  query PreviewGolferSegment($filterCriteria: JSON!) {
    golferSegmentPreview(filterCriteria: $filterCriteria)
  }
`;

export const GET_VOICE_ANALYTICS = gql`
  query GetVoiceAnalytics(
    $courseId: ID
    $startDate: ISO8601Date!
    $endDate: ISO8601Date!
  ) {
    voiceAnalytics(
      courseId: $courseId
      startDate: $startDate
      endDate: $endDate
    ) {
      totalCalls
      completedCalls
      errorRate
      averageDurationSeconds
      bookingConversionRate
      callsByChannel {
        channel
        count
      }
      callsByDay {
        date
        count
      }
      topCallers {
        phone
        name
        totalCalls
        averageDurationSeconds
      }
    }
  }
`;

export const GET_VOICE_CALL_LOGS_PAGINATED = gql`
  query GetVoiceCallLogsPaginated(
    $courseId: ID
    $channel: String
    $status: String
    $startDate: ISO8601Date
    $endDate: ISO8601Date
    $limit: Int
    $offset: Int
  ) {
    voiceCallLogs(
      courseId: $courseId
      channel: $channel
      status: $status
      startDate: $startDate
      endDate: $endDate
      limit: $limit
      offset: $offset
    ) {
      id
      courseId
      courseName
      callSid
      channel
      callerPhone
      callerName
      status
      durationSeconds
      startedAt
      endedAt
      createdAt
    }
  }
`;

// Pricing rules queries
export const GET_PRICING_RULES = gql`
  query GetPricingRules(
    $courseId: ID
    $ruleType: PricingRuleTypeEnum
    $active: Boolean
  ) {
    pricingRules(
      courseId: $courseId
      ruleType: $ruleType
      active: $active
    ) {
      id
      organizationId
      courseId
      course {
        id
        name
      }
      name
      ruleType
      conditions
      multiplier
      flatAdjustmentCents
      flatAdjustment
      priority
      active
      startDate
      endDate
      createdAt
      updatedAt
    }
  }
`;

export const GET_PRICING_RULE = gql`
  query GetPricingRule($id: ID!) {
    pricingRule(id: $id) {
      id
      organizationId
      courseId
      course {
        id
        name
      }
      name
      ruleType
      conditions
      multiplier
      flatAdjustmentCents
      flatAdjustment
      priority
      active
      startDate
      endDate
      createdAt
      updatedAt
    }
  }
`;

export const GET_EMAIL_CAMPAIGNS = gql`
  query GetEmailCampaigns($status: String) {
    emailCampaigns(status: $status) {
      id
      name
      subject
      bodyHtml
      bodyText
      status
      recipientFilter
      lapsedDays
      isAutomated
      recurrenceIntervalDays
      totalRecipients
      sentCount
      deliveredCount
      openedCount
      clickedCount
      failedCount
      progressPercentage
      openRatePercentage
      clickRatePercentage
      scheduledAt
      sentAt
      completedAt
      createdAt
      createdBy {
        id
        fullName
      }
    }
  }
`;

// Loyalty queries
export const GET_LOYALTY_PROGRAM = gql`
  query GetLoyaltyProgram {
    loyaltyProgram {
      id
      name
      description
      pointsPerDollar
      isActive
      tierThresholds
      createdAt
      updatedAt
    }
  }
`;

export const GET_LOYALTY_ACCOUNT = gql`
  query GetLoyaltyAccount {
    loyaltyAccount {
      id
      pointsBalance
      lifetimePoints
      tier
      tierName
      pointsNeededForNextTier
      createdAt
      updatedAt
      loyaltyProgram {
        id
        name
        description
        pointsPerDollar
      }
      recentTransactions {
        id
        transactionType
        points
        pointsDisplay
        description
        balanceAfter
        transactionIcon
        positive
        createdAt
      }
    }
  }
`;

export const GET_LOYALTY_REWARDS = gql`
  query GetLoyaltyRewards($rewardType: LoyaltyRewardTypeEnum, $affordableOnly: Boolean, $activeOnly: Boolean) {
    loyaltyRewards(rewardType: $rewardType, affordableOnly: $affordableOnly, activeOnly: $activeOnly) {
      id
      name
      description
      pointsCost
      rewardType
      discountValue
      discountDisplay
      isActive
      maxRedemptionsPerUser
      canBeRedeemed
      remainingRedemptions
      createdAt
      updatedAt
    }
  }
`;

export const GET_LOYALTY_TRANSACTIONS = gql`
  query GetLoyaltyTransactions($userId: ID, $transactionType: String, $limit: Int) {
    loyaltyTransactions(userId: $userId, transactionType: $transactionType, limit: $limit) {
      id
      transactionType
      points
      pointsDisplay
      description
      balanceAfter
      transactionIcon
      positive
      negative
      sourceType
      sourceId
      createdAt
    }
  }
`;

export const GET_LOYALTY_REDEMPTIONS = gql`
  query GetLoyaltyRedemptions($status: String, $rewardId: ID, $userId: ID, $limit: Int) {
    loyaltyRedemptions(status: $status, rewardId: $rewardId, userId: $userId, limit: $limit) {
      id
      status
      code
      expiresAt
      expired
      canBeApplied
      canBeCancelled
      createdAt
      updatedAt
      loyaltyAccount {
        id
        user {
          id
          fullName
          email
        }
      }
      loyaltyReward {
        id
        name
        pointsCost
        discountDisplay
      }
    }
  }
`;

export const GET_EMAIL_CAMPAIGN = gql`
  query GetEmailCampaign($id: ID!) {
    emailCampaign(id: $id) {
      id
      name
      subject
      bodyHtml
      bodyText
      status
      recipientFilter
      filterCriteria
      lapsedDays
      isAutomated
      recurrenceIntervalDays
      totalRecipients
      sentCount
      deliveredCount
      openedCount
      clickedCount
      failedCount
      progressPercentage
      openRatePercentage
      clickRatePercentage
      scheduledAt
      sentAt
      completedAt
      createdAt
      updatedAt
      createdBy {
        id
        fullName
        email
      }
      emailMessages {
        id
        toEmail
        status
        openedAt
        clickedAt
        sentAt
        deliveredAt
        errorMessage
        createdAt
        user {
          id
          fullName
          email
        }
      }
    }
  }
`;

// Email Providers
export const GET_EMAIL_PROVIDERS = gql`
  query GetEmailProviders {
    emailProviders {
      id
      providerType
      fromEmail
      fromName
      isActive
      isDefault
      verificationStatus
      lastVerifiedAt
      maskedApiKey
      settings
      createdAt
      updatedAt
    }
  }
`;

// Email Templates
export const GET_EMAIL_TEMPLATES = gql`
  query GetEmailTemplates($category: String) {
    emailTemplates(category: $category) {
      id
      name
      subject
      bodyHtml
      bodyText
      category
      isActive
      mergeFields
      usageCount
      createdAt
      updatedAt
      createdBy {
        id
        fullName
      }
    }
  }
`;

export const GET_EMAIL_TEMPLATE = gql`
  query GetEmailTemplate($id: ID!) {
    emailTemplate(id: $id) {
      id
      name
      subject
      bodyHtml
      bodyText
      category
      isActive
      mergeFields
      usageCount
      createdAt
      updatedAt
      createdBy {
        id
        fullName
      }
    }
  }
`;

// Booking Email Templates (transactional)
export const GET_BOOKING_EMAIL_TEMPLATES = gql`
  query GetBookingEmailTemplates {
    bookingEmailTemplates {
      id
      name
      subject
      bodyHtml
      bodyText
      category
      isActive
      mergeFields
      usageCount
      createdAt
      updatedAt
      createdBy {
        id
        fullName
      }
    }
  }
`;
