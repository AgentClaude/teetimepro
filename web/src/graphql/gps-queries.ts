import { gql } from "@apollo/client";

export const GET_COURSE_GPS_FEATURES = gql`
  query GetCourseGpsFeatures(
    $courseId: ID!
    $holeNumber: Int
    $featureType: GpsFeatureTypeEnum
  ) {
    courseGpsFeatures(
      courseId: $courseId
      holeNumber: $holeNumber
      featureType: $featureType
    ) {
      id
      name
      featureType
      latitude
      longitude
      elevationFeet
      distanceFromTeeYards
      metadata
      courseHole {
        id
        holeNumber
        par
      }
      createdAt
    }
  }
`;

export const GET_HOLE_GPS_OVERVIEW = gql`
  query GetHoleGpsOverview(
    $courseId: ID!
    $holeNumber: Int!
    $playerLatitude: Float
    $playerLongitude: Float
  ) {
    holeGpsOverview(
      courseId: $courseId
      holeNumber: $holeNumber
      playerLatitude: $playerLatitude
      playerLongitude: $playerLongitude
    )
  }
`;

export const GET_RANGEFINDER_DEVICES = gql`
  query GetRangefinderDevices(
    $status: RangefinderDeviceStatusEnum
    $deviceType: RangefinderDeviceTypeEnum
  ) {
    rangefinderDevices(status: $status, deviceType: $deviceType) {
      id
      deviceId
      name
      deviceType
      status
      firmwareVersion
      batteryLevel
      online
      lastSeenAt
      metadata
      createdAt
    }
  }
`;

export const GET_PLAYER_LOCATIONS = gql`
  query GetPlayerLocations($courseId: ID!, $holeNumber: Int) {
    playerLocations(courseId: $courseId, holeNumber: $holeNumber) {
      id
      latitude
      longitude
      accuracyMeters
      currentHole
      recordedAt
      booking {
        id
        confirmationCode
        user {
          fullName
        }
      }
      rangefinderDevice {
        id
        name
        deviceType
      }
    }
  }
`;
