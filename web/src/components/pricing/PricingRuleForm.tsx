import { useState } from 'react';
import { useMutation, useQuery } from '@apollo/client';
import { Button } from '../ui/Button';
import { CREATE_PRICING_RULE, UPDATE_PRICING_RULE } from '../../graphql/mutations';
import { GET_COURSES } from '../../graphql/queries';
import { useCourse } from '../../contexts/CourseContext';
import type { PricingRule, PricingRuleType } from '../../types';

const RULE_TYPES: { value: PricingRuleType; label: string; description: string }[] = [
  {
    value: 'DAY_OF_WEEK',
    label: 'Day of Week',
    description: 'Price adjustment based on the day of the week (e.g., weekend premium)',
  },
  {
    value: 'TIME_OF_DAY',
    label: 'Time of Day',
    description: 'Price adjustment based on time (e.g., peak morning hours)',
  },
  {
    value: 'OCCUPANCY',
    label: 'Course Occupancy',
    description: 'Price adjustment based on how booked the course is',
  },
  {
    value: 'ADVANCE_BOOKING',
    label: 'Advance Booking',
    description: 'Price adjustment for bookings made well in advance',
  },
  {
    value: 'LAST_MINUTE',
    label: 'Last Minute',
    description: 'Price adjustment for last-minute bookings (usually a discount)',
  },
];

const DAYS_OF_WEEK = [
  { value: 'monday', label: 'Monday' },
  { value: 'tuesday', label: 'Tuesday' },
  { value: 'wednesday', label: 'Wednesday' },
  { value: 'thursday', label: 'Thursday' },
  { value: 'friday', label: 'Friday' },
  { value: 'saturday', label: 'Saturday' },
  { value: 'sunday', label: 'Sunday' },
];

interface PricingRuleFormProps {
  rule?: PricingRule;
  onSuccess: () => void;
  onCancel: () => void;
}

export function PricingRuleForm({ rule, onSuccess, onCancel }: PricingRuleFormProps) {
  const { selectedCourseId } = useCourse();
  const isEditing = !!rule;

  // Form state
  const [name, setName] = useState(rule?.name || '');
  const [ruleType, setRuleType] = useState<PricingRuleType>(rule?.ruleType || 'DAY_OF_WEEK');
  const [courseId, setCourseId] = useState<string>(rule?.courseId || selectedCourseId || '');
  const [multiplier, setMultiplier] = useState(rule?.multiplier || 1.0);
  const [flatAdjustmentCents, setFlatAdjustmentCents] = useState(rule?.flatAdjustmentCents || 0);
  const [priority, setPriority] = useState(rule?.priority || 100);
  const [active, setActive] = useState(rule?.active ?? true);
  const [startDate, setStartDate] = useState(rule?.startDate || '');
  const [endDate, setEndDate] = useState(rule?.endDate || '');

  // Rule-specific conditions
  const [selectedDays, setSelectedDays] = useState<string[]>(
    rule?.conditions?.days as string[] || []
  );
  const hoursCondition = rule?.conditions?.hours as { start?: number; end?: number } | undefined;
  const [timeStart, setTimeStart] = useState(
    hoursCondition?.start?.toString() || ''
  );
  const [timeEnd, setTimeEnd] = useState(
    hoursCondition?.end?.toString() || ''
  );
  const [occupancyThreshold, setOccupancyThreshold] = useState(
    rule?.conditions?.threshold?.toString() || ''
  );
  const [occupancyOperator, setOccupancyOperator] = useState(
    rule?.conditions?.operator as string || 'greater_than'
  );
  const [advanceHours, setAdvanceHours] = useState(
    rule?.conditions?.hours?.toString() || ''
  );
  const [advanceOperator, setAdvanceOperator] = useState(
    rule?.conditions?.operator as string || 'greater_than'
  );
  const [lastMinuteHours, setLastMinuteHours] = useState(
    rule?.conditions?.hours?.toString() || '2'
  );

  // Get available courses
  const { data: coursesData } = useQuery(GET_COURSES);
  const courses = coursesData?.courses || [];

  const [createRule, { loading: creating }] = useMutation(CREATE_PRICING_RULE, {
    onCompleted: () => {
      onSuccess();
    },
    onError: (error) => {
      console.error('Error creating pricing rule:', error);
    },
  });

  const [updateRule, { loading: updating }] = useMutation(UPDATE_PRICING_RULE, {
    onCompleted: () => {
      onSuccess();
    },
    onError: (error) => {
      console.error('Error updating pricing rule:', error);
    },
  });

  const loading = creating || updating;

  const buildConditions = () => {
    const conditions: Record<string, unknown> = {};

    switch (ruleType) {
      case 'DAY_OF_WEEK':
        if (selectedDays.length > 0) {
          conditions.days = selectedDays;
        }
        break;
      case 'TIME_OF_DAY':
        if (timeStart && timeEnd) {
          conditions.hours = {
            start: parseInt(timeStart),
            end: parseInt(timeEnd),
          };
        }
        break;
      case 'OCCUPANCY':
        if (occupancyThreshold) {
          conditions.threshold = parseFloat(occupancyThreshold);
          conditions.operator = occupancyOperator;
        }
        break;
      case 'ADVANCE_BOOKING':
        if (advanceHours) {
          conditions.hours = parseInt(advanceHours);
          conditions.operator = advanceOperator;
        }
        break;
      case 'LAST_MINUTE':
        conditions.hours = parseInt(lastMinuteHours);
        break;
    }

    return conditions;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const variables = {
      name,
      ruleType,
      courseId: courseId || null,
      conditions: buildConditions(),
      multiplier: parseFloat(multiplier.toString()),
      flatAdjustmentCents: parseInt(flatAdjustmentCents.toString()) || 0,
      priority: parseInt(priority.toString()),
      active,
      startDate: startDate || null,
      endDate: endDate || null,
    };

    try {
      if (isEditing) {
        await updateRule({ variables: { id: rule.id, ...variables } });
      } else {
        await createRule({ variables });
      }
    } catch (error) {
      console.error('Error saving pricing rule:', error);
    }
  };

  const renderRuleTypeSpecificFields = () => {
    switch (ruleType) {
      case 'DAY_OF_WEEK':
        return (
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Days of Week
            </label>
            <div className="grid grid-cols-2 gap-2">
              {DAYS_OF_WEEK.map((day) => (
                <label key={day.value} className="flex items-center space-x-2">
                  <input
                    type="checkbox"
                    checked={selectedDays.includes(day.value)}
                    onChange={(e) => {
                      if (e.target.checked) {
                        setSelectedDays([...selectedDays, day.value]);
                      } else {
                        setSelectedDays(selectedDays.filter(d => d !== day.value));
                      }
                    }}
                    className="rounded border-gray-300 text-green-600 focus:ring-green-500"
                  />
                  <span className="text-sm text-gray-700">{day.label}</span>
                </label>
              ))}
            </div>
          </div>
        );

      case 'TIME_OF_DAY':
        return (
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Start Hour (0-23)
              </label>
              <input
                type="number"
                min="0"
                max="23"
                value={timeStart}
                onChange={(e) => setTimeStart(e.target.value)}
                className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                End Hour (0-23)
              </label>
              <input
                type="number"
                min="0"
                max="23"
                value={timeEnd}
                onChange={(e) => setTimeEnd(e.target.value)}
                className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
              />
            </div>
          </div>
        );

      case 'OCCUPANCY':
        return (
          <div className="grid grid-cols-3 gap-4">
            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Occupancy Threshold (%)
              </label>
              <input
                type="number"
                min="0"
                max="100"
                value={occupancyThreshold}
                onChange={(e) => setOccupancyThreshold(e.target.value)}
                className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                When occupancy is
              </label>
              <select
                value={occupancyOperator}
                onChange={(e) => setOccupancyOperator(e.target.value)}
                className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
              >
                <option value="greater_than">Greater than</option>
                <option value="less_than">Less than</option>
                <option value="equal">Equal to</option>
              </select>
            </div>
          </div>
        );

      case 'ADVANCE_BOOKING':
        return (
          <div className="grid grid-cols-3 gap-4">
            <div className="col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Hours in advance
              </label>
              <input
                type="number"
                min="1"
                value={advanceHours}
                onChange={(e) => setAdvanceHours(e.target.value)}
                className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                When booking is
              </label>
              <select
                value={advanceOperator}
                onChange={(e) => setAdvanceOperator(e.target.value)}
                className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
              >
                <option value="greater_than">More than</option>
                <option value="less_than">Less than</option>
              </select>
            </div>
          </div>
        );

      case 'LAST_MINUTE':
        return (
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Hours before tee time (default: 2)
            </label>
            <input
              type="number"
              min="1"
              max="24"
              value={lastMinuteHours}
              onChange={(e) => setLastMinuteHours(e.target.value)}
              className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
            />
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="grid grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Rule Name *
          </label>
          <input
            type="text"
            required
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="e.g., Weekend Premium"
            className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
          />
        </div>
        
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Rule Type *
          </label>
          <select
            required
            value={ruleType}
            onChange={(e) => setRuleType(e.target.value as PricingRuleType)}
            className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
          >
            {RULE_TYPES.map((type) => (
              <option key={type.value} value={type.value}>
                {type.label}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Course (optional)
        </label>
        <select
          value={courseId}
          onChange={(e) => setCourseId(e.target.value)}
          className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
        >
          <option value="">All courses</option>
          {courses.map((course: { id: string; name: string }) => (
            <option key={course.id} value={course.id}>
              {course.name}
            </option>
          ))}
        </select>
        <p className="mt-1 text-xs text-gray-500">
          Leave blank to apply this rule to all courses in your organization
        </p>
      </div>

      {renderRuleTypeSpecificFields()}

      <div className="grid grid-cols-3 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Price Multiplier
          </label>
          <input
            type="number"
            min="0"
            step="0.01"
            value={multiplier}
            onChange={(e) => setMultiplier(parseFloat(e.target.value) || 1.0)}
            className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
          />
          <p className="mt-1 text-xs text-gray-500">
            1.0 = no change, 1.25 = 25% increase, 0.75 = 25% discount
          </p>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Flat Adjustment ($)
          </label>
          <input
            type="number"
            step="0.01"
            value={flatAdjustmentCents / 100}
            onChange={(e) => setFlatAdjustmentCents(Math.round((parseFloat(e.target.value) || 0) * 100))}
            className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
          />
          <p className="mt-1 text-xs text-gray-500">
            Fixed amount added/subtracted after multiplier
          </p>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Priority
          </label>
          <input
            type="number"
            min="0"
            value={priority}
            onChange={(e) => setPriority(parseInt(e.target.value) || 0)}
            className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
          />
          <p className="mt-1 text-xs text-gray-500">
            Higher numbers = higher priority
          </p>
        </div>
      </div>

      <div className="grid grid-cols-3 gap-4">
        <div>
          <label className="flex items-center space-x-2">
            <input
              type="checkbox"
              checked={active}
              onChange={(e) => setActive(e.target.checked)}
              className="rounded border-gray-300 text-green-600 focus:ring-green-500"
            />
            <span className="text-sm font-medium text-gray-700">Active</span>
          </label>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Start Date (optional)
          </label>
          <input
            type="date"
            value={startDate}
            onChange={(e) => setStartDate(e.target.value)}
            className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            End Date (optional)
          </label>
          <input
            type="date"
            value={endDate}
            onChange={(e) => setEndDate(e.target.value)}
            className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
          />
        </div>
      </div>

      <div className="flex justify-end space-x-3">
        <Button
          type="button"
          variant="secondary"
          onClick={onCancel}
          disabled={loading}
        >
          Cancel
        </Button>
        <Button
          type="submit"
          disabled={loading}
        >
          {loading ? 'Saving...' : isEditing ? 'Update Rule' : 'Create Rule'}
        </Button>
      </div>
    </form>
  );
}