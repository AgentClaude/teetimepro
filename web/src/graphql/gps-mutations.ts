import { gql } from "@apollo/client";

export const CREATE_COURSE_GPS_FEATURE = gql`
  mutation CreateCourseGpsFeature(
    $courseHoleId: ID!
    $featureType: GpsFeatureTypeEnum!
    $name: String!
    $latitude: Float!
    $longitude: Float!
    $elevationFeet: Float
    $distanceFromTeeYards: Int
    $metadata: JSON
  ) {
    createCourseGpsFeature(
      courseHoleId: $courseHoleId
      featureType: $featureType
      name: $name
      latitude: $latitude
      longitude: $longitude
      elevationFeet: $elevationFeet
      distanceFromTeeYards: $distanceFromTeeYards
      metadata: $metadata
    ) {
      gpsFeature {
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
      }
      errors
    }
  }
`;

export const REGISTER_RANGEFINDER_DEVICE = gql`
  mutation RegisterRangefinderDevice(
    $deviceId: String!
    $name: String!
    $deviceType: RangefinderDeviceTypeEnum!
    $firmwareVersion: String
    $metadata: JSON
  ) {
    registerRangefinderDevice(
      deviceId: $deviceId
      name: $name
      deviceType: $deviceType
      firmwareVersion: $firmwareVersion
      metadata: $metadata
    ) {
      device {
        id
        deviceId
        name
        deviceType
        status
        firmwareVersion
        batteryLevel
        online
        lastSeenAt
      }
      newlyRegistered
      errors
    }
  }
`;

export const UPDATE_PLAYER_LOCATION = gql`
  mutation UpdatePlayerLocation(
    $bookingId: ID!
    $latitude: Float!
    $longitude: Float!
    $accuracyMeters: Float
    $currentHole: Int
    $rangefinderDeviceId: ID
  ) {
    updatePlayerLocation(
      bookingId: $bookingId
      latitude: $latitude
      longitude: $longitude
      accuracyMeters: $accuracyMeters
      currentHole: $currentHole
      rangefinderDeviceId: $rangefinderDeviceId
    ) {
      playerLocation {
        id
        latitude
        longitude
        currentHole
        recordedAt
      }
      distances {
        featureId
        featureName
        featureType
        distanceYards
      }
      errors
    }
  }
`;
