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
