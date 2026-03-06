import { useQuery } from "@apollo/client";
import { GET_TEE_SHEET } from "../graphql/queries";
import type { TeeSheet } from "../types";

interface UseTeeSheetOptions {
  courseId: string;
  date: string;
}

interface UseTeeSheetResult {
  teeSheet: TeeSheet | null;
  loading: boolean;
  error: Error | undefined;
  refetch: () => void;
}

export function useTeeSheet({
  courseId,
  date,
}: UseTeeSheetOptions): UseTeeSheetResult {
  const { data, loading, error, refetch } = useQuery(GET_TEE_SHEET, {
    variables: { courseId, date },
    skip: !courseId || !date,
    pollInterval: 30000, // Refresh every 30 seconds for real-time updates
  });

  return {
    teeSheet: data?.teeSheet ?? null,
    loading,
    error,
    refetch,
  };
}
