import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useQuery, useMutation } from '@apollo/client';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { PricingRulesSection } from '../components/pricing/PricingRulesSection';
import { useCourse } from '../contexts/CourseContext';
import { GET_COURSE, GET_VOICE_CALL_LOGS } from '../graphql/queries';
import { UPDATE_COURSE_VOICE_CONFIG } from '../graphql/mutations';
import type { VoiceCallLog } from '../types';

export function SettingsPage() {
  const { selectedCourseId, selectedCourse, loading } = useCourse();

  // Fetch voice config for selected course
  const { data: courseData } = useQuery(GET_COURSE, {
    variables: { id: selectedCourseId },
    skip: !selectedCourseId,
  });
  const voiceConfig = courseData?.course?.voiceConfig || selectedCourse?.voiceConfig;

  const [systemPrompt, setSystemPrompt] = useState('');
  const [greeting, setGreeting] = useState('');
  const [voiceModel, setVoiceModel] = useState('');
  const [llmProvider, setLlmProvider] = useState('');
  const [llmModel, setLlmModel] = useState('');
  const [saved, setSaved] = useState(false);

  const [updateVoiceConfig, { loading: saving }] = useMutation(UPDATE_COURSE_VOICE_CONFIG);

  // Call logs — filter by selected course
  const { data: logsData, loading: logsLoading, refetch: refetchLogs } = useQuery(GET_VOICE_CALL_LOGS, {
    variables: { courseId: selectedCourseId || undefined, limit: 50 },
  });
  const callLogs: VoiceCallLog[] = logsData?.voiceCallLogs || [];

  // Load voice config when course selection changes
  useEffect(() => {
    if (voiceConfig) {
      setSystemPrompt(voiceConfig.system_prompt || '');
      setGreeting(voiceConfig.greeting || '');
      setVoiceModel(voiceConfig.voice_model || 'aura-2-odysseus-en');
      setLlmProvider(voiceConfig.llm_provider || 'google');
      setLlmModel(voiceConfig.llm_model || 'gemini-2.5-flash');
    }
    setSaved(false);
  }, [selectedCourseId, voiceConfig]);

  async function handleSave() {
    if (!selectedCourseId) return;
    setSaved(false);
    try {
      const { data } = await updateVoiceConfig({
        variables: {
          courseId: selectedCourseId,
          systemPrompt,
          greeting,
          voiceModel,
          llmProvider,
          llmModel,
        },
      });
      if (data?.updateCourseVoiceConfig?.errors?.length) {
        alert(data.updateCourseVoiceConfig.errors.join(', '));
      } else {
        setSaved(true);
        setTimeout(() => setSaved(false), 3000);
      }
    } catch (err) {
      alert('Failed to save voice config');
    }
  }

  function formatDuration(seconds: number | null) {
    if (!seconds) return '--';
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
    return m > 0 ? `${m}m ${s}s` : `${s}s`;
  }

  function formatTime(iso: string) {
    return new Date(iso).toLocaleString();
  }

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

      {/* Voice Bot Configuration */}
      <Card className="p-6">
        <div className="mb-4 flex items-center justify-between">
          <div>
            <h2 className="text-lg font-semibold text-gray-900">Voice Bot</h2>
            <p className="text-sm text-gray-500">Configure the AI voice assistant for phone bookings</p>
          </div>
          <a
            href={`${window.location.protocol}//${window.location.hostname}:3005/playground`}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-1.5 rounded-md bg-gray-100 px-3 py-1.5 text-sm font-medium text-gray-700 hover:bg-gray-200"
          >
            <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
              <path strokeLinecap="round" strokeLinejoin="round" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            Test in Playground
          </a>
        </div>

        {loading ? (
          <p className="text-sm text-gray-500">Loading...</p>
        ) : !selectedCourseId ? (
          <p className="text-sm text-gray-500">Select a course from the sidebar to configure voice settings.</p>
        ) : (
          <>
            {/* Greeting */}
            <div className="mb-5">
              <label className="block text-sm font-medium text-gray-700">Greeting</label>
              <p className="mb-1 text-xs text-gray-400">The first thing the voice bot says when answering a call</p>
              <input
                type="text"
                value={greeting}
                onChange={(e) => { setGreeting(e.target.value); setSaved(false); }}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
              />
            </div>

            {/* System Prompt */}
            <div className="mb-5">
              <label className="block text-sm font-medium text-gray-700">System Prompt</label>
              <p className="mb-1 text-xs text-gray-400">
                Instructions that control how the voice bot behaves, what it says, and how it handles bookings
              </p>
              <textarea
                value={systemPrompt}
                onChange={(e) => { setSystemPrompt(e.target.value); setSaved(false); }}
                rows={16}
                className="mt-1 block w-full rounded-md border-gray-300 font-mono text-sm shadow-sm focus:border-green-500 focus:ring-green-500"
              />
            </div>

            {/* Model Settings */}
            <div className="mb-5 grid grid-cols-1 gap-4 sm:grid-cols-3">
              <div>
                <label className="block text-sm font-medium text-gray-700">LLM Provider</label>
                <select
                  value={llmProvider}
                  onChange={(e) => { setLlmProvider(e.target.value); setSaved(false); }}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
                >
                  <option value="google">Google</option>
                  <option value="openai">OpenAI</option>
                  <option value="anthropic">Anthropic</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">LLM Model</label>
                <input
                  type="text"
                  value={llmModel}
                  onChange={(e) => { setLlmModel(e.target.value); setSaved(false); }}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Voice Model</label>
                <input
                  type="text"
                  value={voiceModel}
                  onChange={(e) => { setVoiceModel(e.target.value); setSaved(false); }}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
                />
              </div>
            </div>

            {/* Save */}
            <div className="flex items-center gap-3">
              <Button variant="primary" onClick={handleSave} disabled={saving}>
                {saving ? 'Saving...' : 'Save Voice Config'}
              </Button>
              {saved && (
                <span className="text-sm font-medium text-green-600">Saved successfully</span>
              )}
            </div>
          </>
        )}
      </Card>

      {/* Call Logs */}
      <Card className="p-6">
        <div className="mb-4 flex items-center justify-between">
          <div>
            <h2 className="text-lg font-semibold text-gray-900">Call Logs</h2>
            <p className="text-sm text-gray-500">View voice bot conversation history</p>
          </div>
          <Button variant="secondary" size="sm" onClick={() => refetchLogs()}>
            Refresh
          </Button>
        </div>

        {logsLoading ? (
          <p className="text-sm text-gray-500">Loading call logs...</p>
        ) : callLogs.length === 0 ? (
          <p className="text-sm text-gray-500">No call logs yet. Make a call via the playground or phone to see logs here.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead>
                <tr>
                  <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-gray-500">Time</th>
                  <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-gray-500">Channel</th>
                  <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-gray-500">Course</th>
                  <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-gray-500">Caller</th>
                  <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-gray-500">Duration</th>
                  <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-gray-500">Messages</th>
                  <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-gray-500">Booking</th>
                  <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-gray-500"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {callLogs.map((log) => (
                  <tr key={log.id} className="hover:bg-gray-50">
                    <td className="whitespace-nowrap px-3 py-2 text-sm text-gray-900">
                      {formatTime(log.startedAt)}
                    </td>
                    <td className="whitespace-nowrap px-3 py-2 text-sm">
                      <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ${
                        log.channel === 'twilio' ? 'bg-blue-100 text-blue-800' : 'bg-purple-100 text-purple-800'
                      }`}>
                        {log.channel === 'twilio' ? 'Phone' : 'Browser'}
                      </span>
                    </td>
                    <td className="whitespace-nowrap px-3 py-2 text-sm text-gray-700">
                      {log.courseName || '--'}
                    </td>
                    <td className="whitespace-nowrap px-3 py-2 text-sm text-gray-700">
                      {log.callerName || log.callerPhone || '--'}
                    </td>
                    <td className="whitespace-nowrap px-3 py-2 text-sm text-gray-700">
                      {formatDuration(log.durationSeconds)}
                    </td>
                    <td className="whitespace-nowrap px-3 py-2 text-sm text-gray-700">
                      {log.summary?.message_count || 0}
                    </td>
                    <td className="whitespace-nowrap px-3 py-2 text-sm">
                      {log.summary?.booking_created ? (
                        <span className="inline-flex items-center rounded-full bg-green-100 px-2 py-0.5 text-xs font-medium text-green-800">
                          {log.summary.confirmation_code || 'Yes'}
                        </span>
                      ) : (
                        <span className="text-gray-400">--</span>
                      )}
                    </td>
                    <td className="whitespace-nowrap px-3 py-2 text-sm">
                      <Link
                        to={`/call-logs/${log.id}`}
                        className="font-medium text-green-600 hover:text-green-800"
                      >
                        View
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Card>

      {/* Dynamic Pricing Rules */}
      <PricingRulesSection />

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
              <p className="text-sm text-gray-500">SMS reminders & phone voice bot</p>
            </div>
            <Button variant="secondary" size="sm">Configure</Button>
          </div>
          <div className="flex items-center justify-between rounded-lg border p-4">
            <div>
              <p className="font-medium text-gray-900">Deepgram</p>
              <p className="text-sm text-gray-500">Voice AI (STT + TTS)</p>
            </div>
            <span className="text-sm font-medium text-green-600">Connected</span>
          </div>
        </div>
      </Card>
    </div>
  );
}
