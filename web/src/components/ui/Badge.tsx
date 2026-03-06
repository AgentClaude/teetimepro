import { cn } from "../../lib/utils";

type BadgeVariant =
  | "default"
  | "success"
  | "warning"
  | "danger"
  | "info"
  | "neutral";

interface BadgeProps {
  children: React.ReactNode;
  variant?: BadgeVariant;
  className?: string;
}

const variantStyles: Record<BadgeVariant, string> = {
  default: "bg-fairway-100 text-fairway-800",
  success: "bg-green-100 text-green-800",
  warning: "bg-yellow-100 text-yellow-800",
  danger: "bg-red-100 text-red-800",
  info: "bg-blue-100 text-blue-800",
  neutral: "bg-rough-100 text-rough-800",
};

export function Badge({
  children,
  variant = "default",
  className,
}: BadgeProps) {
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
        variantStyles[variant],
        className
      )}
    >
      {children}
    </span>
  );
}

// eslint-disable-next-line react-refresh/only-export-components
export function statusBadgeVariant(
  status: string
): BadgeVariant {
  switch (status) {
    case "available":
      return "success";
    case "partially_booked":
      return "warning";
    case "fully_booked":
      return "danger";
    case "blocked":
    case "maintenance":
      return "neutral";
    case "confirmed":
      return "success";
    case "checked_in":
      return "info";
    case "cancelled":
      return "danger";
    case "no_show":
      return "warning";
    default:
      return "default";
  }
}
