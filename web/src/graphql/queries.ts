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
  query GetBookings($date: ISO8601Date, $status: String) {
    bookings(date: $date, status: $status) {
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
