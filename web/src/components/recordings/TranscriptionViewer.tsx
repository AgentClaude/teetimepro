import { useState } from "react";
import { Card, CardHeader } from "../ui/Card";
import { Badge } from "../ui/Badge";
import { Button } from "../ui/Button";
import { LoadingSpinner } from "../ui/LoadingSpinner";
import { 
  ClipboardDocumentIcon, 
  ArrowDownTrayIcon,
  SpeakerWaveIcon,
  CalendarIcon,
  UserIcon
} from "@heroicons/react/24/outline";
import type { CallRecording, CallTranscription } from "../../types";

interface TranscriptionViewerProps {
  recording: CallRecording;
  transcription: CallTranscription;
  loading?: boolean;
  onCopyToClipboard: (text: string) => void;
  onDownloadTranscript: (transcription: CallTranscription) => void;
  onPlayRecording?: (recording: CallRecording) => void;
}

export function TranscriptionViewer({
  recording,
  transcription,
  loading = false,
  onCopyToClipboard,
  onDownloadTranscript,
  onPlayRecording,
}: TranscriptionViewerProps) {
  const [copied, setCopied] = useState(false);

  const handleCopyToClipboard = () => {
    onCopyToClipboard(transcription.transcriptionText);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const getConfidenceBadgeVariant = () => {
    if (transcription.highConfidence) return "success";
    if (transcription.mediumConfidence) return "warning";
    return "danger";
  };

  const getConfidenceLabel = () => {
    const score = Math.round(transcription.confidenceScore * 100);
    return `${score}%`;
  };

  const getProviderDisplayName = (provider: string) => {
    switch (provider) {
      case "deepgram":
        return "Deepgram";
      case "whisper":
        return "OpenAI Whisper";
      default:
        return provider;
    }
  };

  const formatDateTime = (datetime: string) => {
    return new Date(datetime).toLocaleString();
  };

  const highlightConfidenceText = (text: string) => {
    // In a real implementation, we would use word-level confidence scores
    // from the raw_response to highlight low-confidence words
    // For now, we'll just return the plain text
    return text;
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center p-12">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader
          title="Call Transcription"
          subtitle={`Transcribed by ${getProviderDisplayName(transcription.provider)}`}
        />

        {/* Recording Info */}
        <div className="bg-gray-50 rounded-lg p-4 mb-6">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <div className="flex items-center gap-2">
              <CalendarIcon className="h-5 w-5 text-gray-400" />
              <div>
                <div className="text-sm font-medium">Date</div>
                <div className="text-sm text-gray-600">
                  {formatDateTime(recording.createdAt)}
                </div>
              </div>
            </div>

            <div className="flex items-center gap-2">
              <SpeakerWaveIcon className="h-5 w-5 text-gray-400" />
              <div>
                <div className="text-sm font-medium">Duration</div>
                <div className="text-sm text-gray-600">
                  {recording.formattedDuration}
                </div>
              </div>
            </div>

            <div className="flex items-center gap-2">
              <UserIcon className="h-5 w-5 text-gray-400" />
              <div>
                <div className="text-sm font-medium">Call ID</div>
                <div className="text-sm text-gray-600 font-mono">
                  {recording.callSid.substring(0, 10)}...
                </div>
              </div>
            </div>

            <div>
              <div className="text-sm font-medium">Confidence</div>
              <Badge variant={getConfidenceBadgeVariant()}>
                {getConfidenceLabel()}
              </Badge>
            </div>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex items-center gap-3 mb-6">
          <Button
            variant="outline"
            onClick={handleCopyToClipboard}
            className="flex items-center gap-2"
          >
            <ClipboardDocumentIcon className="h-4 w-4" />
            {copied ? "Copied!" : "Copy to Clipboard"}
          </Button>

          <Button
            variant="outline"
            onClick={() => onDownloadTranscript(transcription)}
            className="flex items-center gap-2"
          >
            <ArrowDownTrayIcon className="h-4 w-4" />
            Download as Text
          </Button>

          {onPlayRecording && (
            <Button
              variant="outline"
              onClick={() => onPlayRecording(recording)}
              className="flex items-center gap-2"
            >
              <SpeakerWaveIcon className="h-4 w-4" />
              Play Recording
            </Button>
          )}
        </div>

        {/* Transcription Text */}
        <div className="border rounded-lg p-6">
          <div className="mb-4 flex items-center justify-between">
            <h3 className="text-lg font-medium">Transcript</h3>
            <div className="flex items-center gap-4 text-sm text-gray-500">
              <span>{transcription.wordCount} words</span>
              <span>Language: {transcription.language.toUpperCase()}</span>
            </div>
          </div>

          <div className="prose max-w-none">
            <p className="text-gray-900 leading-relaxed whitespace-pre-wrap">
              {highlightConfidenceText(transcription.transcriptionText)}
            </p>
          </div>

          {transcription.transcriptionText.trim() === "" && (
            <div className="text-center py-8">
              <p className="text-gray-500">No transcription available</p>
            </div>
          )}
        </div>

        {/* Technical Details */}
        <div className="mt-6 border-t pt-6">
          <h4 className="text-sm font-medium text-gray-700 mb-3">Technical Details</h4>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
            <div>
              <span className="text-gray-500">Provider:</span>
              <span className="ml-2 font-medium">
                {getProviderDisplayName(transcription.provider)}
              </span>
            </div>
            <div>
              <span className="text-gray-500">Status:</span>
              <span className="ml-2">
                <Badge variant={transcription.status === "completed" ? "success" : "warning"}>
                  {transcription.status}
                </Badge>
              </span>
            </div>
            <div>
              <span className="text-gray-500">Created:</span>
              <span className="ml-2 font-mono">
                {formatDateTime(transcription.createdAt)}
              </span>
            </div>
            <div>
              <span className="text-gray-500">Updated:</span>
              <span className="ml-2 font-mono">
                {formatDateTime(transcription.updatedAt)}
              </span>
            </div>
          </div>
        </div>

        {/* Raw Response (Debug) */}
        {transcription.rawResponse && (
          <details className="mt-4">
            <summary className="text-sm font-medium text-gray-700 cursor-pointer">
              Raw API Response (Debug)
            </summary>
            <pre className="mt-2 p-3 bg-gray-100 rounded text-xs overflow-auto">
              {JSON.stringify(transcription.rawResponse, null, 2)}
            </pre>
          </details>
        )}
      </Card>
    </div>
  );
}