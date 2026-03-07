import { useState } from "react";
import { Card, CardHeader } from "../ui/Card";
import { LoadingSpinner } from "../ui/LoadingSpinner";
import { Badge } from "../ui/Badge";
import { Button } from "../ui/Button";
import { Input } from "../ui/Input";
import { Select } from "../ui/Select";
import { Table, TableHeader, TableRow, TableHead, TableBody, TableCell } from "../ui/Table";
import { PlayIcon, DocumentTextIcon, MagnifyingGlassIcon } from "@heroicons/react/24/outline";
import type { CallRecording } from "../../types";

interface RecordingsListProps {
  recordings: CallRecording[];
  loading: boolean;
  totalCount: number;
  currentPage: number;
  totalPages: number;
  onSearch: (query: string) => void;
  onFilterStatus: (status: string) => void;
  onFilterDateRange: (dateFrom: string, dateTo: string) => void;
  onPageChange: (page: number) => void;
  onPlayRecording: (recording: CallRecording) => void;
  onViewTranscription: (recording: CallRecording) => void;
  onRequestTranscription: (recording: CallRecording) => void;
}

export function RecordingsList({
  recordings,
  loading,
  totalCount,
  currentPage,
  totalPages,
  onSearch,
  onFilterStatus,
  onFilterDateRange,
  onPageChange,
  onPlayRecording,
  onViewTranscription,
  onRequestTranscription,
}: RecordingsListProps) {
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("");
  const [dateFrom, setDateFrom] = useState("");
  const [dateTo, setDateTo] = useState("");

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSearch(searchQuery);
  };

  const handleStatusChange = (value: string) => {
    setStatusFilter(value);
    onFilterStatus(value);
  };

  const handleDateRangeChange = () => {
    onFilterDateRange(dateFrom, dateTo);
  };

  const getStatusBadgeVariant = (status: string) => {
    switch (status) {
      case "completed":
        return "success";
      case "pending":
        return "warning";
      case "processing":
        return "info";
      case "failed":
        return "danger";
      default:
        return "secondary";
    }
  };

  const getConfidenceBadgeVariant = (recording: CallRecording) => {
    if (!recording.latestTranscription) return "secondary";
    
    if (recording.latestTranscription.highConfidence) return "success";
    if (recording.latestTranscription.mediumConfidence) return "warning";
    return "danger";
  };

  const getConfidenceLabel = (recording: CallRecording) => {
    if (!recording.latestTranscription) return "No transcription";
    
    const score = Math.round(recording.latestTranscription.confidenceScore * 100);
    return `${score}%`;
  };

  const formatDateTime = (datetime: string) => {
    return new Date(datetime).toLocaleString();
  };

  const formatFileSize = (bytes?: number) => {
    if (!bytes) return "Unknown";
    
    const sizes = ["Bytes", "KB", "MB", "GB"];
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + " " + sizes[i];
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
          title="Call Recordings"
          subtitle={`${totalCount} recordings found`}
        />

        {/* Filters */}
        <div className="space-y-4 mb-6">
          <form onSubmit={handleSearchSubmit} className="flex gap-4">
            <div className="flex-1">
              <Input
                placeholder="Search transcriptions..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                icon={<MagnifyingGlassIcon className="h-5 w-5" />}
              />
            </div>
            <Button type="submit" variant="outline">
              Search
            </Button>
          </form>

          <div className="flex gap-4">
            <Select
              placeholder="Filter by status"
              value={statusFilter}
              onChange={handleStatusChange}
              options={[
                { value: "", label: "All statuses" },
                { value: "completed", label: "Completed" },
                { value: "pending", label: "Pending" },
                { value: "processing", label: "Processing" },
                { value: "failed", label: "Failed" },
              ]}
            />

            <Input
              type="date"
              placeholder="From date"
              value={dateFrom}
              onChange={(e) => setDateFrom(e.target.value)}
            />

            <Input
              type="date"
              placeholder="To date"
              value={dateTo}
              onChange={(e) => setDateTo(e.target.value)}
            />

            <Button
              variant="outline"
              onClick={handleDateRangeChange}
              disabled={!dateFrom || !dateTo}
            >
              Apply Date Filter
            </Button>
          </div>
        </div>

        {/* Results Table */}
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Date</TableHead>
              <TableHead>Call Duration</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Transcription</TableHead>
              <TableHead>File Size</TableHead>
              <TableHead>Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {recordings.map((recording) => (
              <TableRow key={recording.id}>
                <TableCell>
                  {formatDateTime(recording.createdAt)}
                </TableCell>
                <TableCell>
                  <span className="font-mono">
                    {recording.formattedDuration}
                  </span>
                </TableCell>
                <TableCell>
                  <Badge variant={getStatusBadgeVariant(recording.status)}>
                    {recording.status}
                  </Badge>
                </TableCell>
                <TableCell>
                  {recording.transcribed ? (
                    <div className="flex items-center gap-2">
                      <Badge variant={getConfidenceBadgeVariant(recording)}>
                        {getConfidenceLabel(recording)}
                      </Badge>
                      <span className="text-sm text-gray-600">
                        {recording.latestTranscription?.wordCount} words
                      </span>
                    </div>
                  ) : (
                    <Badge variant="secondary">
                      Not transcribed
                    </Badge>
                  )}
                </TableCell>
                <TableCell>
                  <span className="text-sm text-gray-600">
                    {formatFileSize(recording.fileSizeBytes)}
                  </span>
                </TableCell>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <Button
                      size="sm"
                      variant="ghost"
                      onClick={() => onPlayRecording(recording)}
                      title="Play recording"
                    >
                      <PlayIcon className="h-4 w-4" />
                    </Button>

                    {recording.transcribed ? (
                      <Button
                        size="sm"
                        variant="ghost"
                        onClick={() => onViewTranscription(recording)}
                        title="View transcription"
                      >
                        <DocumentTextIcon className="h-4 w-4" />
                      </Button>
                    ) : (
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => onRequestTranscription(recording)}
                        disabled={recording.status !== "completed"}
                        title="Request transcription"
                      >
                        Transcribe
                      </Button>
                    )}
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>

        {recordings.length === 0 && (
          <div className="text-center py-12">
            <p className="text-gray-500">No recordings found</p>
          </div>
        )}

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="flex items-center justify-between mt-6">
            <div className="text-sm text-gray-500">
              Page {currentPage} of {totalPages}
            </div>
            <div className="flex items-center gap-2">
              <Button
                size="sm"
                variant="outline"
                onClick={() => onPageChange(currentPage - 1)}
                disabled={currentPage <= 1}
              >
                Previous
              </Button>
              <Button
                size="sm"
                variant="outline"
                onClick={() => onPageChange(currentPage + 1)}
                disabled={currentPage >= totalPages}
              >
                Next
              </Button>
            </div>
          </div>
        )}
      </Card>
    </div>
  );
}