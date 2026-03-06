import { Card } from '../components/ui/Card';

export function CustomersPage() {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Customers</h1>
      </div>

      <Card className="p-8 text-center">
        <p className="text-gray-500">Customer management coming in Phase 2 (CRM).</p>
      </Card>
    </div>
  );
}
