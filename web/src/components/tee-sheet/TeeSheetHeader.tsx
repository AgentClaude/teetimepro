import { format } from 'date-fns';

interface TeeSheetHeaderProps {
  date: Date;
  courseName: string;
  totalSlots: number;
  bookedSlots: number;
  revenue: number;
}

export function TeeSheetHeader({
  date,
  courseName,
  totalSlots,
  bookedSlots,
  revenue,
}: TeeSheetHeaderProps) {
  const utilization = totalSlots > 0 ? Math.round((bookedSlots / totalSlots) * 100) : 0;

  return (
    <div className="rounded-lg bg-white p-6 shadow-sm">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">{courseName}</h1>
          <p className="mt-1 text-sm text-gray-500">{format(date, 'EEEE, MMMM d, yyyy')}</p>
        </div>

        <div className="flex gap-6">
          <div className="text-center">
            <p className="text-2xl font-bold text-green-600">{bookedSlots}</p>
            <p className="text-xs text-gray-500">Booked</p>
          </div>
          <div className="text-center">
            <p className="text-2xl font-bold text-gray-400">{totalSlots - bookedSlots}</p>
            <p className="text-xs text-gray-500">Available</p>
          </div>
          <div className="text-center">
            <p className="text-2xl font-bold text-blue-600">{utilization}%</p>
            <p className="text-xs text-gray-500">Utilization</p>
          </div>
          <div className="text-center">
            <p className="text-2xl font-bold text-emerald-600">
              ${(revenue / 100).toLocaleString()}
            </p>
            <p className="text-xs text-gray-500">Revenue</p>
          </div>
        </div>
      </div>
    </div>
  );
}
