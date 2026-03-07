import { Switch } from '@headlessui/react';
import { useMutation } from '@apollo/client';
import { Button } from '../ui/Button';
import { UPDATE_PRICING_RULE } from '../../graphql/mutations';
import type { PricingRule, PricingRuleType } from '../../types';

const RULE_TYPE_LABELS: Record<PricingRuleType, string> = {
  'DAY_OF_WEEK': 'Day of Week',
  'TIME_OF_DAY': 'Time of Day', 
  'OCCUPANCY': 'Course Occupancy',
  'WEATHER': 'Weather',
  'ADVANCE_BOOKING': 'Advance Booking',
  'LAST_MINUTE': 'Last Minute',
};

interface PricingRulesListProps {
  rules: PricingRule[];
  onEdit: (rule: PricingRule) => void;
  onDelete: (ruleId: string) => void;
  loading: boolean;
}

export function PricingRulesList({ rules, onEdit, onDelete, loading }: PricingRulesListProps) {
  const [updateRule] = useMutation(UPDATE_PRICING_RULE);

  const handleToggleActive = async (rule: PricingRule) => {
    try {
      await updateRule({
        variables: {
          id: rule.id,
          active: !rule.active,
        },
      });
      // The list will re-render when the cache updates
    } catch (error) {
      console.error('Error toggling rule active status:', error);
    }
  };

  const formatConditions = (rule: PricingRule) => {
    const { ruleType, conditions } = rule;

    switch (ruleType) {
      case 'DAY_OF_WEEK': {
        const days = conditions.days as string[];
        if (days?.length) {
          return `${days.map(d => d.charAt(0).toUpperCase() + d.slice(1)).join(', ')}`;
        }
        return 'All days';
      }

      case 'TIME_OF_DAY': {
        const hours = conditions.hours as { start: number; end: number };
        if (hours?.start !== undefined && hours?.end !== undefined) {
          return `${hours.start}:00 - ${hours.end}:00`;
        }
        return 'All hours';
      }

      case 'OCCUPANCY': {
        const threshold = conditions.threshold as number;
        const operator = conditions.operator as string;
        if (threshold !== undefined) {
          const operatorText = operator === 'greater_than' ? '>' : 
                              operator === 'less_than' ? '<' : '=';
          return `${operatorText} ${threshold}% occupancy`;
        }
        return 'Any occupancy';
      }

      case 'ADVANCE_BOOKING': {
        const advanceHours = conditions.hours as number;
        const advanceOp = conditions.operator as string;
        if (advanceHours !== undefined) {
          const opText = advanceOp === 'greater_than' ? 'more than' : 'less than';
          return `${opText} ${advanceHours} hours in advance`;
        }
        return 'Any advance time';
      }

      case 'LAST_MINUTE': {
        const lastMinuteHours = conditions.hours as number;
        return `Within ${lastMinuteHours || 2} hours`;
      }

      default:
        return 'All conditions';
    }
  };

  const formatPriceAdjustment = (rule: PricingRule) => {
    const multiplierText = rule.multiplier !== 1.0 ? 
      `${((rule.multiplier - 1) * 100).toFixed(0)}%` : '';
    
    const flatText = rule.flatAdjustmentCents !== 0 ? 
      rule.flatAdjustment : '';

    if (multiplierText && flatText) {
      return `${multiplierText} ${flatText}`;
    }
    return multiplierText || flatText || 'No adjustment';
  };

  const formatDateRange = (startDate: string | null, endDate: string | null) => {
    if (!startDate && !endDate) return 'No date limits';
    if (startDate && !endDate) return `From ${new Date(startDate).toLocaleDateString()}`;
    if (!startDate && endDate) return `Until ${new Date(endDate).toLocaleDateString()}`;
    return `${new Date(startDate!).toLocaleDateString()} - ${new Date(endDate!).toLocaleDateString()}`;
  };

  if (loading) {
    return (
      <div className="text-center py-8 text-gray-500">
        Loading pricing rules...
      </div>
    );
  }

  if (rules.length === 0) {
    return (
      <div className="text-center py-8">
        <div className="text-gray-500 text-sm mb-4">
          No pricing rules configured yet
        </div>
        <p className="text-xs text-gray-400">
          Add your first pricing rule to start using dynamic pricing
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {rules
        .sort((a, b) => b.priority - a.priority) // Sort by priority (highest first)
        .map((rule) => (
          <div
            key={rule.id}
            className={`p-4 border rounded-lg ${
              rule.active ? 'border-gray-200 bg-white' : 'border-gray-100 bg-gray-50'
            }`}
          >
            <div className="flex items-center justify-between">
              <div className="flex-1">
                <div className="flex items-center space-x-4 mb-2">
                  <h3 className={`font-medium ${rule.active ? 'text-gray-900' : 'text-gray-500'}`}>
                    {rule.name}
                  </h3>
                  <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${
                    rule.active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-500'
                  }`}>
                    {RULE_TYPE_LABELS[rule.ruleType]}
                  </span>
                  <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                    Priority: {rule.priority}
                  </span>
                  {rule.course && (
                    <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                      {rule.course.name}
                    </span>
                  )}
                </div>
                
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                  <div>
                    <span className="text-gray-500">Conditions:</span>
                    <div className="text-gray-900">{formatConditions(rule)}</div>
                  </div>
                  <div>
                    <span className="text-gray-500">Price Adjustment:</span>
                    <div className="text-gray-900">{formatPriceAdjustment(rule)}</div>
                  </div>
                  <div>
                    <span className="text-gray-500">Date Range:</span>
                    <div className="text-gray-900">{formatDateRange(rule.startDate, rule.endDate)}</div>
                  </div>
                </div>
              </div>
              
              <div className="flex items-center space-x-3 ml-6">
                <Switch
                  checked={rule.active}
                  onChange={() => handleToggleActive(rule)}
                  className={`${
                    rule.active ? 'bg-green-600' : 'bg-gray-200'
                  } relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2`}
                >
                  <span className="sr-only">Toggle active</span>
                  <span
                    className={`${
                      rule.active ? 'translate-x-6' : 'translate-x-1'
                    } inline-block h-4 w-4 transform rounded-full bg-white transition-transform`}
                  />
                </Switch>
                
                <Button
                  variant="secondary"
                  size="sm"
                  onClick={() => onEdit(rule)}
                >
                  Edit
                </Button>
                
                <Button
                  variant="secondary"
                  size="sm"
                  onClick={() => onDelete(rule.id)}
                  className="text-red-600 hover:text-red-800 hover:bg-red-50"
                >
                  Delete
                </Button>
              </div>
            </div>
          </div>
        ))}
    </div>
  );
}