import { useRef, useEffect, useCallback, useState } from 'react';

interface BarcodeInputProps {
  onScan: (code: string) => void;
  disabled?: boolean;
  placeholder?: string;
}

/**
 * Barcode scanner input component.
 * Supports USB/Bluetooth barcode scanners (which act as keyboard input)
 * and manual entry. Auto-focuses and listens for rapid keypresses
 * characteristic of scanner input.
 */
export function BarcodeInput({ onScan, disabled = false, placeholder }: BarcodeInputProps) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [value, setValue] = useState('');
  const bufferRef = useRef('');
  const timerRef = useRef<ReturnType<typeof setTimeout>>();

  // Auto-focus on mount and when enabled
  useEffect(() => {
    if (!disabled && inputRef.current) {
      inputRef.current.focus();
    }
  }, [disabled]);

  // Handle scanner input (rapid keypresses ending with Enter)
  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent<HTMLInputElement>) => {
      if (e.key === 'Enter') {
        e.preventDefault();
        const code = value.trim();
        if (code.length > 0) {
          onScan(code);
          setValue('');
          bufferRef.current = '';
        }
        return;
      }

      // Reset timer for scanner detection
      if (timerRef.current) {
        clearTimeout(timerRef.current);
      }

      // Scanner input is very fast — if idle for 100ms, it's manual entry
      timerRef.current = setTimeout(() => {
        bufferRef.current = '';
      }, 100);
    },
    [value, onScan]
  );

  return (
    <div className="relative">
      <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
        <svg
          className="h-5 w-5 text-gray-400"
          fill="none"
          viewBox="0 0 24 24"
          strokeWidth={1.5}
          stroke="currentColor"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            d="M3.75 4.5h1.5m0 0H7.5m-2.25 0v1.5M3.75 9h1.5m0 0h0m0 0v1.5m0-1.5h2.25M3.75 13.5h1.5m0 0h2.25m-2.25 0v1.5M3.75 18h1.5m0 0h2.25M7.5 4.5v1.5M7.5 9v1.5M7.5 13.5v1.5M7.5 18v1.5m3-16.5h1.5m0 0h2.25m-2.25 0v1.5m0-1.5V3m2.25 1.5h1.5m-1.5 0v1.5m0-1.5h-2.25M12 9h1.5m0 0h2.25m-2.25 0v1.5m0-1.5V7.5m2.25 1.5h1.5m-1.5 0v1.5m0-1.5h-2.25M12 13.5h1.5m0 0h2.25m-2.25 0v1.5m0-1.5V12m2.25 1.5h1.5m-1.5 0v1.5m0-1.5h-2.25M12 18h1.5m0 0h2.25m-2.25 0v1.5m0-1.5V16.5m2.25 1.5h1.5m-1.5 0v1.5M20.25 4.5h-1.5m1.5 0v1.5M20.25 9h-1.5m1.5 0v1.5M20.25 13.5h-1.5m1.5 0v1.5M20.25 18h-1.5m1.5 0v1.5"
          />
        </svg>
      </div>
      <input
        ref={inputRef}
        type="text"
        value={value}
        onChange={(e) => setValue(e.target.value)}
        onKeyDown={handleKeyDown}
        disabled={disabled}
        placeholder={placeholder ?? 'Scan barcode or enter SKU...'}
        className="block w-full rounded-lg border border-gray-300 bg-white py-3 pl-10 pr-4 text-lg shadow-sm transition-colors focus:border-green-500 focus:outline-none focus:ring-2 focus:ring-green-500/20 disabled:bg-gray-100 disabled:text-gray-500"
        autoComplete="off"
        autoCorrect="off"
        spellCheck={false}
      />
      <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3">
        <kbd className="rounded border border-gray-300 bg-gray-50 px-2 py-0.5 text-xs text-gray-500">
          Enter ↵
        </kbd>
      </div>
    </div>
  );
}
