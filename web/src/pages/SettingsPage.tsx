import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';

export function SettingsPage() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Settings</h1>

      {/* Course Settings */}
      <Card className="p-6">
        <h2 className="mb-4 text-lg font-semibold text-gray-900">Course Configuration</h2>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <div>
            <label className="block text-sm font-medium text-gray-700">Course Name</label>
            <input
              type="text"
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
              placeholder="Mountain View Golf Club"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Holes</label>
            <select className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500">
              <option value="9">9 Holes</option>
              <option value="18">18 Holes</option>
              <option value="27">27 Holes</option>
              <option value="36">36 Holes</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Tee Time Interval</label>
            <select className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500">
              <option value="7">7 minutes</option>
              <option value="8">8 minutes</option>
              <option value="9">9 minutes</option>
              <option value="10">10 minutes</option>
              <option value="12">12 minutes</option>
              <option value="15">15 minutes</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Max Players Per Slot</label>
            <select className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500">
              <option value="4">4 Players</option>
              <option value="5">5 Players</option>
            </select>
          </div>
        </div>
        <div className="mt-4">
          <Button variant="primary">Save Changes</Button>
        </div>
      </Card>

      {/* Pricing */}
      <Card className="p-6">
        <h2 className="mb-4 text-lg font-semibold text-gray-900">Default Pricing</h2>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
          <div>
            <label className="block text-sm font-medium text-gray-700">Weekday Rate</label>
            <div className="relative mt-1">
              <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-500">$</span>
              <input
                type="number"
                className="block w-full rounded-md border-gray-300 pl-7 shadow-sm focus:border-green-500 focus:ring-green-500"
                placeholder="55.00"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Weekend Rate</label>
            <div className="relative mt-1">
              <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-500">$</span>
              <input
                type="number"
                className="block w-full rounded-md border-gray-300 pl-7 shadow-sm focus:border-green-500 focus:ring-green-500"
                placeholder="75.00"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Twilight Rate</label>
            <div className="relative mt-1">
              <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-500">$</span>
              <input
                type="number"
                className="block w-full rounded-md border-gray-300 pl-7 shadow-sm focus:border-green-500 focus:ring-green-500"
                placeholder="35.00"
              />
            </div>
          </div>
        </div>
      </Card>

      {/* Integrations */}
      <Card className="p-6">
        <h2 className="mb-4 text-lg font-semibold text-gray-900">Integrations</h2>
        <div className="space-y-4">
          <div className="flex items-center justify-between rounded-lg border p-4">
            <div>
              <p className="font-medium text-gray-900">Stripe</p>
              <p className="text-sm text-gray-500">Payment processing</p>
            </div>
            <Button variant="secondary" size="sm">Connect</Button>
          </div>
          <div className="flex items-center justify-between rounded-lg border p-4">
            <div>
              <p className="font-medium text-gray-900">Twilio</p>
              <p className="text-sm text-gray-500">SMS reminders</p>
            </div>
            <Button variant="secondary" size="sm">Configure</Button>
          </div>
          <div className="flex items-center justify-between rounded-lg border p-4">
            <div>
              <p className="font-medium text-gray-900">Deepgram</p>
              <p className="text-sm text-gray-500">Voice booking bot</p>
            </div>
            <Button variant="secondary" size="sm">Coming Soon</Button>
          </div>
        </div>
      </Card>
    </div>
  );
}
