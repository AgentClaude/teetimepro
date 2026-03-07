/**
 * Format cents to a currency string.
 * @example formatCents(4500) => "$45.00"
 */
export function formatCents(cents: number | null | undefined): string {
  if (cents == null) return '--';
  return `$${(cents / 100).toFixed(2)}`;
}

/**
 * Format an ISO date string to a human-readable date.
 * @example formatDate('2026-03-15') => "Sun, Mar 15"
 */
export function formatDate(dateStr: string): string {
  const date = new Date(dateStr);
  return date.toLocaleDateString('en-US', {
    weekday: 'short',
    month: 'short',
    day: 'numeric',
  });
}

/**
 * Format an ISO datetime string to a human-readable date and time.
 * @example formatDateTime('2026-03-15T14:30:00Z') => "Sun, Mar 15 at 2:30 PM"
 */
export function formatDateTime(dateTimeStr: string): string {
  const date = new Date(dateTimeStr);
  return date.toLocaleDateString('en-US', {
    weekday: 'short',
    month: 'short',
    day: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  });
}

/**
 * Get today's date as ISO string (YYYY-MM-DD).
 */
export function todayISO(): string {
  return new Date().toISOString().split('T')[0]!;
}
