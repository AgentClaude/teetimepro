import { Bars3Icon, BellIcon, UserCircleIcon } from '@heroicons/react/24/outline';
import { useAuth } from '../../hooks/useAuth';

interface TopNavProps {
  onMenuClick?: () => void;
}

export function TopNav({ onMenuClick }: TopNavProps) {
  const { user, logout } = useAuth();

  return (
    <header className="flex h-14 items-center justify-between border-b border-gray-200 bg-white px-4 sm:h-16 sm:px-6">
      <div className="flex items-center gap-3">
        {/* Hamburger menu — mobile only */}
        <button
          onClick={onMenuClick}
          className="rounded-md p-1.5 text-gray-500 hover:bg-gray-100 hover:text-gray-700 lg:hidden"
        >
          <Bars3Icon className="h-6 w-6" />
        </button>

        {/* Mobile logo */}
        <div className="flex items-center gap-1.5 lg:hidden">
          <span className="text-lg">⛳</span>
          <span className="text-sm font-bold text-gray-900">TeeTimes Pro</span>
        </div>
      </div>

      <div className="flex items-center gap-2 sm:gap-4">
        {/* Notifications */}
        <button className="relative rounded-full p-2 text-gray-500 hover:bg-gray-100 hover:text-gray-700">
          <BellIcon className="h-5 w-5" />
          <span className="absolute right-1 top-1 h-2 w-2 rounded-full bg-red-500" />
        </button>

        {/* User Menu */}
        <div className="flex items-center gap-2">
          <UserCircleIcon className="h-7 w-7 text-gray-400 sm:h-8 sm:w-8" />
          <div className="hidden text-sm sm:block">
            <p className="font-medium text-gray-900">{user?.firstName ?? 'User'}</p>
            <button
              onClick={logout}
              className="text-xs text-gray-500 hover:text-red-600"
            >
              Sign out
            </button>
          </div>
          {/* Mobile sign out */}
          <button
            onClick={logout}
            className="text-xs text-gray-500 hover:text-red-600 sm:hidden"
          >
            Sign out
          </button>
        </div>
      </div>
    </header>
  );
}
