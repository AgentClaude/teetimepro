interface TurnOrderBadgeProps {
  deliveryHole: number | null;
  totalCents: number;
  status: string;
}

export function TurnOrderBadge({ deliveryHole, totalCents, status }: TurnOrderBadgeProps) {
  const isOpen = status === 'open';
  const total = `$${(totalCents / 100).toFixed(2)}`;

  return (
    <span
      className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-medium ${
        isOpen
          ? 'bg-orange-100 text-orange-700'
          : 'bg-gray-100 text-gray-600'
      }`}
    >
      🍔 {total}
      {deliveryHole && (
        <span className="text-[10px] opacity-75">→ H{deliveryHole}</span>
      )}
    </span>
  );
}
