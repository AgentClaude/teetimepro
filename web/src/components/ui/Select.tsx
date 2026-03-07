import { type SelectHTMLAttributes, forwardRef } from "react";
import { cn } from "../../lib/utils";

interface SelectOption {
  value: string;
  label: string;
}

interface SelectProps extends Omit<SelectHTMLAttributes<HTMLSelectElement>, "onChange"> {
  options: SelectOption[];
  placeholder?: string;
  error?: string;
  label?: string;
  onChange?: (value: string) => void;
}

export const Select = forwardRef<HTMLSelectElement, SelectProps>(
  ({ className, options, placeholder, error, label, id, value, onChange, ...props }, ref) => {
    const handleChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
      onChange?.(e.target.value);
    };
    return (
      <div>
        {label && (
          <label
            htmlFor={id}
            className="block text-sm font-medium text-rough-700 mb-1"
          >
            {label}
          </label>
        )}
        <select
          ref={ref}
          id={id}
          value={value}
          onChange={handleChange}
          className={cn(
            "block w-full rounded-lg border px-3 py-2",
            "focus:outline-none focus:ring-2 focus:ring-offset-0",
            "text-rough-900 bg-white",
            "transition-colors duration-150",
            error
              ? "border-red-300 focus:border-red-500 focus:ring-red-500"
              : "border-rough-300 focus:border-fairway-500 focus:ring-fairway-500",
            className
          )}
          {...props}
        >
          {placeholder && (
            <option value="" disabled>
              {placeholder}
            </option>
          )}
          {options.map((option) => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
        {error && <p className="mt-1 text-sm text-red-600">{error}</p>}
      </div>
    );
  }
);

Select.displayName = "Select";
