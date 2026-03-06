import { gql } from "@apollo/client";

export const CREATE_BOOKING = gql`
  mutation CreateBooking(
    $teeTimeId: ID!
    $playersCount: Int!
    $paymentMethodId: String
    $playerNames: [String!]
  ) {
    createBooking(
      teeTimeId: $teeTimeId
      playersCount: $playersCount
      paymentMethodId: $paymentMethodId
      playerNames: $playerNames
    ) {
      booking {
        id
        confirmationCode
        status
        playersCount
        totalCents
        teeTime {
          id
          formattedTime
          availableSpots
          status
        }
        bookingPlayers {
          id
          name
        }
      }
      errors
    }
  }
`;

export const CANCEL_BOOKING = gql`
  mutation CancelBooking($bookingId: ID!, $reason: String, $refund: Boolean) {
    cancelBooking(bookingId: $bookingId, reason: $reason, refund: $refund) {
      booking {
        id
        status
        cancelledAt
        cancellationReason
      }
      errors
    }
  }
`;

export const CREATE_COURSE = gql`
  mutation CreateCourse(
    $name: String!
    $holes: Int!
    $intervalMinutes: Int!
    $maxPlayersPerSlot: Int
    $firstTeeTime: String!
    $lastTeeTime: String!
    $weekdayRateCents: Int
    $weekendRateCents: Int
    $address: String
    $phone: String
  ) {
    createCourse(
      name: $name
      holes: $holes
      intervalMinutes: $intervalMinutes
      maxPlayersPerSlot: $maxPlayersPerSlot
      firstTeeTime: $firstTeeTime
      lastTeeTime: $lastTeeTime
      weekdayRateCents: $weekdayRateCents
      weekendRateCents: $weekendRateCents
      address: $address
      phone: $phone
    ) {
      course {
        id
        name
        holes
      }
      errors
    }
  }
`;

export const UPDATE_COURSE_VOICE_CONFIG = gql`
  mutation UpdateCourseVoiceConfig(
    $courseId: ID!
    $systemPrompt: String
    $greeting: String
    $voiceModel: String
    $llmProvider: String
    $llmModel: String
  ) {
    updateCourseVoiceConfig(
      courseId: $courseId
      systemPrompt: $systemPrompt
      greeting: $greeting
      voiceModel: $voiceModel
      llmProvider: $llmProvider
      llmModel: $llmModel
    ) {
      course {
        id
        name
        voiceConfig
      }
      errors
    }
  }
`;

export const UPDATE_TEE_TIME = gql`
  mutation UpdateTeeTime(
    $teeTimeId: ID!
    $status: String
    $priceCents: Int
    $notes: String
    $maxPlayers: Int
  ) {
    updateTeeTime(
      teeTimeId: $teeTimeId
      status: $status
      priceCents: $priceCents
      notes: $notes
      maxPlayers: $maxPlayers
    ) {
      teeTime {
        id
        status
        priceCents
        notes
        maxPlayers
      }
      errors
    }
  }
`;

export const UPDATE_BOOKING = gql`
  mutation UpdateBooking(
    $id: ID!
    $status: String
    $playersCount: Int
    $notes: String
  ) {
    updateBooking(
      id: $id
      status: $status
      playersCount: $playersCount
      notes: $notes
    ) {
      booking {
        id
        status
        playersCount
        notes
        updatedAt
        auditLog {
          id
          event
          changedBy
          changes
          createdAt
        }
      }
      errors
    }
  }
`;

export const UPDATE_CUSTOMER = gql`
  mutation UpdateCustomer(
    $id: ID!
    $firstName: String
    $lastName: String
    $email: String
    $phone: String
  ) {
    updateCustomer(
      id: $id
      firstName: $firstName
      lastName: $lastName
      email: $email
      phone: $phone
    ) {
      customer {
        id
        email
        firstName
        lastName
        fullName
        phone
      }
      errors
    }
  }
`;

export const CREATE_TOURNAMENT = gql`
  mutation CreateTournament(
    $courseId: ID!
    $name: String!
    $format: TournamentFormatEnum!
    $startDate: ISO8601Date!
    $endDate: ISO8601Date!
    $description: String
    $maxParticipants: Int
    $minParticipants: Int
    $teamSize: Int
    $entryFeeCents: Int
    $holes: Int
    $handicapEnabled: Boolean
    $maxHandicap: Float
    $registrationOpensAt: ISO8601DateTime
    $registrationClosesAt: ISO8601DateTime
  ) {
    createTournament(
      courseId: $courseId
      name: $name
      format: $format
      startDate: $startDate
      endDate: $endDate
      description: $description
      maxParticipants: $maxParticipants
      minParticipants: $minParticipants
      teamSize: $teamSize
      entryFeeCents: $entryFeeCents
      holes: $holes
      handicapEnabled: $handicapEnabled
      maxHandicap: $maxHandicap
      registrationOpensAt: $registrationOpensAt
      registrationClosesAt: $registrationClosesAt
    ) {
      tournament {
        id
        name
        format
        status
        startDate
        endDate
      }
      errors
    }
  }
`;

export const UPDATE_TOURNAMENT = gql`
  mutation UpdateTournament(
    $id: ID!
    $name: String
    $status: TournamentStatusEnum
    $description: String
    $maxParticipants: Int
    $entryFeeCents: Int
    $registrationOpensAt: ISO8601DateTime
    $registrationClosesAt: ISO8601DateTime
  ) {
    updateTournament(
      id: $id
      name: $name
      status: $status
      description: $description
      maxParticipants: $maxParticipants
      entryFeeCents: $entryFeeCents
      registrationOpensAt: $registrationOpensAt
      registrationClosesAt: $registrationClosesAt
    ) {
      tournament {
        id
        name
        status
      }
      errors
    }
  }
`;

export const REGISTER_FOR_TOURNAMENT = gql`
  mutation RegisterForTournament(
    $tournamentId: ID!
    $handicapIndex: Float
    $teamName: String
    $paymentMethodId: String
  ) {
    registerForTournament(
      tournamentId: $tournamentId
      handicapIndex: $handicapIndex
      teamName: $teamName
      paymentMethodId: $paymentMethodId
    ) {
      tournamentEntry {
        id
        status
        handicapIndex
        teamName
      }
      errors
    }
  }
`;

export const WITHDRAW_FROM_TOURNAMENT = gql`
  mutation WithdrawFromTournament($tournamentId: ID!) {
    withdrawFromTournament(tournamentId: $tournamentId) {
      tournamentEntry {
        id
        status
      }
      errors
    }
  }
`;

export const CREATE_SMS_CAMPAIGN = gql`
  mutation CreateSmsCampaign(
    $name: String!
    $messageBody: String!
    $recipientFilter: String
    $filterCriteria: JSON
    $scheduledAt: ISO8601DateTime
  ) {
    createSmsCampaign(
      name: $name
      messageBody: $messageBody
      recipientFilter: $recipientFilter
      filterCriteria: $filterCriteria
      scheduledAt: $scheduledAt
    ) {
      smsCampaign {
        id
        name
        status
      }
      errors
    }
  }
`;

export const SEND_SMS_CAMPAIGN = gql`
  mutation SendSmsCampaign($id: ID!) {
    sendSmsCampaign(id: $id) {
      smsCampaign {
        id
        status
        totalRecipients
        sentCount
      }
      errors
    }
  }
`;

export const CANCEL_SMS_CAMPAIGN = gql`
  mutation CancelSmsCampaign($id: ID!) {
    cancelSmsCampaign(id: $id) {
      smsCampaign {
        id
        status
      }
      errors
    }
  }
`;
