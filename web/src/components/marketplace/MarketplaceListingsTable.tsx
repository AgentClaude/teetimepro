import { Badge } from "../ui/Badge";
import { Card, CardHeader } from "../ui/Card";
import type { MarketplaceListing } from "../../types";

interface MarketplaceListingsTableProps {
  listings: MarketplaceListing[];
  loading?: boolean;
}

const statusVariants: Record<string, "success" | "warning" | "danger" | "default"> = {
  listed: "success",
  pending: "warning",
  booked: "success",
  expired: "default",
  error: "danger",
  cancelled: "default",
};

export function MarketplaceListingsTable({
  listings,
  loading = false,
}: MarketplaceListingsTableProps) {
  const formatCurrency = (cents: number | null): string => {
    if (cents === null) return "—";
    return `$${(cents / 100).toFixed(2)}`;
  };

  const formatDateTime = (dateStr: string | null): string => {
    if (!dateStr) return "—";
    return new Date(dateStr).toLocaleString(undefined, {
      month: "short",
      day: "numeric",
      hour: "numeric",
      minute: "2-digit",
    });
  };

  if (loading) {
    return (
      <Card>
        <CardHeader title="Marketplace Listings" />
        <div className="animate-pulse space-y-3 p-4">
          {[1, 2, 3].map((i) => (
            <div key={i} className="h-12 rounded bg-rough-200" />
          ))}
        </div>
      </Card>
    );
  }

  if (listings.length === 0) {
    return (
      <Card>
        <CardHeader title="Marketplace Listings" />
        <div className="p-8 text-center text-rough-500">
          No marketplace listings yet. Connect a marketplace and sync to get started.
        </div>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader
        title="Marketplace Listings"
        subtitle={`${listings.length} listing${listings.length !== 1 ? "s" : ""}`}
      />
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-rough-200">
          <thead className="bg-rough-50">
            <tr>
              <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-rough-500">
                Tee Time
              </th>
              <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-rough-500">
                Marketplace
              </th>
              <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-rough-500">
                Status
              </th>
              <th className="px-4 py-3 text-right text-xs font-medium uppercase tracking-wider text-rough-500">
                Listed Price
              </th>
              <th className="px-4 py-3 text-right text-xs font-medium uppercase tracking-wider text-rough-500">
                Commission
              </th>
              <th className="px-4 py-3 text-right text-xs font-medium uppercase tracking-wider text-rough-500">
                Net Revenue
              </th>
              <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-rough-500">
                Listed
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-rough-200 bg-white">
            {listings.map((listing) => (
              <tr key={listing.id} className="hover:bg-rough-50">
                <td className="whitespace-nowrap px-4 py-3">
                  <div className="text-sm font-medium text-rough-900">
                    {formatDateTime(listing.teeTime?.startsAt)}
                  </div>
                </td>
                <td className="whitespace-nowrap px-4 py-3 text-sm text-rough-700">
                  {listing.providerLabel}
                </td>
                <td className="whitespace-nowrap px-4 py-3">
                  <Badge variant={statusVariants[listing.status] || "default"}>
                    {listing.status.charAt(0).toUpperCase() + listing.status.slice(1)}
                  </Badge>
                </td>
                <td className="whitespace-nowrap px-4 py-3 text-right text-sm text-rough-900">
                  {formatCurrency(listing.listedPriceCents)}
                </td>
                <td className="whitespace-nowrap px-4 py-3 text-right text-sm text-rough-500">
                  {listing.commissionRatePercent}% ({formatCurrency(listing.estimatedCommissionCents)})
                </td>
                <td className="whitespace-nowrap px-4 py-3 text-right text-sm font-medium text-green-600">
                  {formatCurrency(listing.netRevenueCents)}
                </td>
                <td className="whitespace-nowrap px-4 py-3 text-sm text-rough-500">
                  {formatDateTime(listing.listedAt)}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Card>
  );
}
