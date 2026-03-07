import { useState } from 'react';
import { useQuery, useMutation } from '@apollo/client';
import { Card } from '../ui/Card';
import { Button } from '../ui/Button';
import { PricingRuleForm } from './PricingRuleForm';
import { PricingRulesList } from './PricingRulesList';
import { GET_PRICING_RULES } from '../../graphql/queries';
import { DELETE_PRICING_RULE } from '../../graphql/mutations';
import { useCourse } from '../../contexts/CourseContext';
import type { PricingRule, PricingRuleFormData } from '../../types';

export function PricingRulesSection() {
  const { selectedCourseId } = useCourse();
  const [isCreating, setIsCreating] = useState(false);
  const [editingRule, setEditingRule] = useState<PricingRule | null>(null);

  // Fetch pricing rules
  const { data, loading, refetch } = useQuery(GET_PRICING_RULES, {
    variables: { courseId: selectedCourseId || undefined },
  });

  const [deleteRule] = useMutation(DELETE_PRICING_RULE, {
    onCompleted: () => {
      refetch();
    },
    onError: (error) => {
      console.error('Error deleting pricing rule:', error);
    },
  });

  const pricingRules: PricingRule[] = data?.pricingRules || [];

  const handleCreateRule = () => {
    setIsCreating(true);
    setEditingRule(null);
  };

  const handleEditRule = (rule: PricingRule) => {
    setEditingRule(rule);
    setIsCreating(false);
  };

  const handleDeleteRule = async (ruleId: string) => {
    if (!confirm('Are you sure you want to delete this pricing rule?')) {
      return;
    }

    try {
      await deleteRule({ variables: { id: ruleId } });
    } catch (error) {
      console.error('Error deleting pricing rule:', error);
    }
  };

  const handleFormSuccess = () => {
    setIsCreating(false);
    setEditingRule(null);
    refetch();
  };

  const handleFormCancel = () => {
    setIsCreating(false);
    setEditingRule(null);
  };

  if (loading) {
    return (
      <Card className="p-6">
        <div className="flex items-center justify-center py-8">
          <div className="text-gray-500">Loading pricing rules...</div>
        </div>
      </Card>
    );
  }

  return (
    <Card className="p-6">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-lg font-semibold text-gray-900">Dynamic Pricing Rules</h2>
          <p className="text-sm text-gray-500">
            Configure automatic price adjustments based on demand, time, and other factors
          </p>
        </div>
        <Button onClick={handleCreateRule} disabled={isCreating || editingRule !== null}>
          + Add Rule
        </Button>
      </div>

      {isCreating && (
        <div className="mb-6 p-4 border border-gray-200 rounded-lg bg-gray-50">
          <h3 className="text-md font-medium text-gray-900 mb-4">Create New Pricing Rule</h3>
          <PricingRuleForm
            onSuccess={handleFormSuccess}
            onCancel={handleFormCancel}
          />
        </div>
      )}

      {editingRule && (
        <div className="mb-6 p-4 border border-gray-200 rounded-lg bg-gray-50">
          <h3 className="text-md font-medium text-gray-900 mb-4">Edit Pricing Rule</h3>
          <PricingRuleForm
            rule={editingRule}
            onSuccess={handleFormSuccess}
            onCancel={handleFormCancel}
          />
        </div>
      )}

      <PricingRulesList
        rules={pricingRules}
        onEdit={handleEditRule}
        onDelete={handleDeleteRule}
        loading={loading}
      />
    </Card>
  );
}