import { useState, useEffect } from 'react';
import { clsx } from 'clsx';

interface SwitchProps {
  checked: boolean;
  onCheckedChange: (checked: boolean) => void;
  disabled?: boolean;
  size?: 'sm' | 'md';
  className?: string;
}

export function Switch({ 
  checked, 
  onCheckedChange, 
  disabled = false, 
  size = 'md',
  className 
}: SwitchProps) {
  const [internalChecked, setInternalChecked] = useState(checked);

  useEffect(() => {
    setInternalChecked(checked);
  }, [checked]);

  const handleClick = () => {
    if (disabled) return;
    
    const newValue = !internalChecked;
    setInternalChecked(newValue);
    onCheckedChange(newValue);
  };

  const sizeClasses = {
    sm: 'h-4 w-7',
    md: 'h-6 w-11'
  };

  const thumbSizeClasses = {
    sm: 'h-3 w-3',
    md: 'h-5 w-5'
  };

  const translateClasses = {
    sm: internalChecked ? 'translate-x-3' : 'translate-x-0',
    md: internalChecked ? 'translate-x-5' : 'translate-x-0'
  };

  return (
    <button
      type="button"
      className={clsx(
        'relative inline-flex flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-blue-600 focus:ring-offset-2',
        sizeClasses[size],
        {
          'bg-blue-600': internalChecked && !disabled,
          'bg-gray-200': !internalChecked && !disabled,
          'bg-gray-100 cursor-not-allowed': disabled,
          'opacity-50': disabled,
        },
        className
      )}
      disabled={disabled}
      onClick={handleClick}
      aria-checked={internalChecked}
      role="switch"
    >
      <span
        aria-hidden="true"
        className={clsx(
          'pointer-events-none inline-block rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out',
          thumbSizeClasses[size],
          translateClasses[size]
        )}
      />
    </button>
  );
}