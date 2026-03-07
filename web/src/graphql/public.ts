import { gql } from "@apollo/client";

// Public queries (no auth required)
export const GET_PUBLIC_COURSE = gql`
  query GetPublicCourse($slug: String!) {
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
    }
  }
`;

export const GET_PUBLIC_AVAILABLE_TEE_TIMES = gql`
  query GetPublicAvailableTeeTimes($courseSlug: String!, $date: Date!, $players: Int, $timePreference: String) {
    publicAvailableTeeTimes(
      courseSlug: $courseSlug
      date: $date
      players: $players
      timePreference: $timePreference
    ) {
      id
      startsAt
      formattedTime
      maxPlayers
      bookedPlayers
      availableSpots
      priceCents
    }
  }
`;

// Public mutations
export const CREATE_PUBLIC_BOOKING = gql`
  mutation CreatePublicBooking(
    $courseSlug: String!
    $teeTimeId: ID!
    $playersCount: Int!
    $customerName: String!
    $customerEmail: String!
    $customerPhone: String!
  ) {
    createPublicBooking(
      courseSlug: $courseSlug
      teeTimeId: $teeTimeId
      playersCount: $playersCount
      customerName: $customerName
      customerEmail: $customerEmail
      customerPhone: $customerPhone
    ) {
      booking {
        id
        confirmationCode
        status
        playersCount
        totalCents
        teeTime {
          formattedTime
          startsAt
        }
        user {
          firstName
          lastName
          email
        }
      }
      errors
    }
  }
`;