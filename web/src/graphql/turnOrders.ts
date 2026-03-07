import { gql } from '@apollo/client';

export const CREATE_TURN_ORDER = gql`
  mutation CreateTurnOrder(
    $bookingId: ID!
    $items: [PosSaleItemInput!]!
    $deliveryHole: Int
    $deliveryNotes: String
  ) {
    createTurnOrder(
      bookingId: $bookingId
      items: $items
      deliveryHole: $deliveryHole
      deliveryNotes: $deliveryNotes
    ) {
      tab {
        id
        golferName
        totalCents
        status
        turnOrder
        deliveryHole
        deliveryNotes
        fnbTabItems {
          id
          name
          quantity
          unitPriceCents
          totalCents
        }
      }
      errors
    }
  }
`;

export const GET_TURN_ORDERS = gql`
  query GetTurnOrders($date: ISO8601Date, $status: String) {
    turnOrders(date: $date, status: $status) {
      id
      golferName
      totalCents
      status
      turnOrder
      deliveryHole
      deliveryNotes
      openedAt
      booking {
        id
        confirmationCode
        teeTime {
          formattedTime
        }
      }
      fnbTabItems {
        id
        name
        quantity
        unitPriceCents
        totalCents
        category
      }
    }
  }
`;

export const GET_BOOKING_TURN_ORDER = gql`
  query GetBookingTurnOrder($bookingId: ID!) {
    booking(id: $bookingId) {
      id
      hasTurnOrder
      turnOrder {
        id
        golferName
        totalCents
        status
        deliveryHole
        deliveryNotes
        fnbTabItems {
          id
          name
          quantity
          unitPriceCents
          totalCents
        }
      }
    }
  }
`;
