import { gql } from '@apollo/client';

export const GET_GOLFER_PROFILE = gql`
  query GetGolferProfile($id: ID, $userId: ID) {
    golferProfile(id: $id, userId: $userId) {
      id
      handicapIndex
      homeCourse
      preferredTee
      totalRounds
      bestScore
      averageScore
      lastPlayedOn
      handicapUpdatedAt
      displayHandicap
      user {
        id
        fullName
        email
      }
      recentRounds {
        id
        courseName
        playedOn
        score
        holesPlayed
        differential
        teeColor
      }
      handicapRevisions(months: 12) {
        id
        handicapIndex
        previousIndex
        change
        effectiveDate
        source
        roundsUsed
      }
    }
  }
`;

export const GET_GOLFER_ROUNDS = gql`
  query GetGolferRounds($id: ID!, $limit: Int, $offset: Int) {
    golferProfile(id: $id) {
      id
      rounds(limit: $limit, offset: $offset) {
        id
        courseName
        playedOn
        score
        holesPlayed
        courseRating
        slopeRating
        differential
        teeColor
        notes
        putts
        fairwaysHit
        greensInRegulation
        course {
          id
          name
        }
        createdAt
      }
    }
  }
`;

export const RECORD_ROUND = gql`
  mutation RecordRound(
    $golferProfileId: ID!
    $courseName: String!
    $playedOn: ISO8601Date!
    $score: Int!
    $holesPlayed: Int
    $courseRating: Float
    $slopeRating: Int
    $courseId: ID
    $teeColor: String
    $notes: String
    $putts: Int
    $fairwaysHit: Int
    $greensInRegulation: Int
  ) {
    recordRound(
      golferProfileId: $golferProfileId
      courseName: $courseName
      playedOn: $playedOn
      score: $score
      holesPlayed: $holesPlayed
      courseRating: $courseRating
      slopeRating: $slopeRating
      courseId: $courseId
      teeColor: $teeColor
      notes: $notes
      putts: $putts
      fairwaysHit: $fairwaysHit
      greensInRegulation: $greensInRegulation
    ) {
      round {
        id
        courseName
        playedOn
        score
        differential
      }
      golferProfile {
        id
        handicapIndex
        totalRounds
        bestScore
        averageScore
        lastPlayedOn
        displayHandicap
      }
      errors
    }
  }
`;

export const UPDATE_HANDICAP = gql`
  mutation UpdateHandicap(
    $golferProfileId: ID!
    $handicapIndex: Float!
    $notes: String
  ) {
    updateHandicap(
      golferProfileId: $golferProfileId
      handicapIndex: $handicapIndex
      notes: $notes
    ) {
      golferProfile {
        id
        handicapIndex
        displayHandicap
        handicapUpdatedAt
      }
      errors
    }
  }
`;
