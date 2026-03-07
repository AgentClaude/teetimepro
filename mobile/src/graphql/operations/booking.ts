import { gql } from '@apollo/client';

export const PUBLIC_COURSE_QUERY = gql`
  query PublicCourse($slug: String!) {
    publicCourse(slug: $slug) {
      id
      name
      slug
      holes
      address
      phone
      weekdayRateCents
      weekendRateCents
      twilightRateCents
      intervalMinutes
      maxPlayersPerSlot
      firstTeeTime
      lastTeeTime
    }
  }
`;

export const PUBLIC_AVAILABLE_TEE_TIMES_QUERY = gql`
  query PublicAvailableTeeTimes(
    $courseSlug: String!
    $date: ISO8601Date!
    $players: Int
    $timePreference: String
  ) {
    publicAvailableTeeTimes(
      courseSlug: $courseSlug
      date: $date
      players: $players
      timePreference: $timePreference
    ) {
      id
      startsAt
      formattedTime
      status
      maxPlayers
      bookedPlayers
      availableSpots
      priceCents
      price
      dynamicPriceCents
      dynamicPrice
      hasDynamicPricing
    }
  }
`;

export const CREATE_PUBLIC_BOOKING_MUTATION = gql`
  mutation CreatePublicBooking(
    $courseSlug: String!
    $teeTimeId: ID!
    $playersCount: Int!
    $customerName: String!
    $customerEmail: String!
    $customerPhone: String!
  ) {
    createPublicBooking(
      input: {
        courseSlug: $courseSlug
        teeTimeId: $teeTimeId
        playersCount: $playersCount
        customerName: $customerName
        customerEmail: $customerEmail
        customerPhone: $customerPhone
      }
    ) {
      booking {
        id
        confirmationCode
        status
        playersCount
        totalCents
        notes
        createdAt
        teeTime {
          id
          startsAt
          formattedTime
        }
      }
      errors
    }
  }
`;

export const MY_BOOKINGS_QUERY = gql`
  query MyBookings($status: String) {
    bookings(status: $status) {
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
        teeSheetId
      }
    }
  }
`;

export const CANCEL_BOOKING_MUTATION = gql`
  mutation CancelBooking($id: ID!, $reason: String) {
    cancelBooking(input: { id: $id, reason: $reason }) {
      booking {
        id
        status
        cancelledAt
      }
      errors
    }
  }
`;
