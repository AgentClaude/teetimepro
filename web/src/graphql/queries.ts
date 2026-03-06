import { gql } from "@apollo/client";

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
  query GetCustomers($search: String, $role: String) {
    customers(search: $search, role: $role) {
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
      bookings {
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
        }
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
