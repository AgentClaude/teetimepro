import { gql } from '@apollo/client';

export const GET_POS_PRODUCTS = gql`
  query GetPosProducts($category: String, $search: String, $activeOnly: Boolean) {
    posProducts(category: $category, search: $search, activeOnly: $activeOnly) {
      id
      name
      sku
      barcode
      priceCents
      category
      description
      active
      trackInventory
      stockQuantity
      inStock
      formattedPrice
    }
  }
`;

export const LOOKUP_POS_PRODUCT = gql`
  mutation LookupPosProduct($code: String!) {
    lookupPosProduct(code: $code) {
      product {
        id
        name
        sku
        barcode
        priceCents
        category
        formattedPrice
        inStock
        trackInventory
        stockQuantity
      }
      errors
    }
  }
`;

export const CREATE_POS_PRODUCT = gql`
  mutation CreatePosProduct(
    $name: String!
    $sku: String!
    $barcode: String
    $priceCents: Int!
    $category: String
    $description: String
    $trackInventory: Boolean
    $stockQuantity: Int
  ) {
    createPosProduct(
      name: $name
      sku: $sku
      barcode: $barcode
      priceCents: $priceCents
      category: $category
      description: $description
      trackInventory: $trackInventory
      stockQuantity: $stockQuantity
    ) {
      product {
        id
        name
        sku
        barcode
        priceCents
        category
        formattedPrice
        active
      }
      errors
    }
  }
`;

export const UPDATE_POS_PRODUCT = gql`
  mutation UpdatePosProduct(
    $id: ID!
    $name: String
    $sku: String
    $barcode: String
    $priceCents: Int
    $category: String
    $description: String
    $active: Boolean
    $trackInventory: Boolean
    $stockQuantity: Int
  ) {
    updatePosProduct(
      id: $id
      name: $name
      sku: $sku
      barcode: $barcode
      priceCents: $priceCents
      category: $category
      description: $description
      active: $active
      trackInventory: $trackInventory
      stockQuantity: $stockQuantity
    ) {
      product {
        id
        name
        sku
        barcode
        priceCents
        category
        formattedPrice
        active
      }
      errors
    }
  }
`;

export const POS_QUICK_SALE = gql`
  mutation PosQuickSale($golferName: String!, $items: [PosSaleItemInput!]!) {
    posQuickSale(golferName: $golferName, items: $items) {
      tab {
        id
        golferName
        totalCents
        status
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
