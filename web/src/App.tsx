import { Routes, Route, Navigate } from "react-router-dom";
import { AppLayout } from "./components/layout/AppLayout";
import { ProtectedRoute } from "./components/auth/ProtectedRoute";
import { LoginPage } from "./pages/LoginPage";
import { PublicBookingPage } from "./pages/PublicBookingPage";
import { DashboardPage } from "./pages/DashboardPage";
import { TeeSheetPage } from "./pages/TeeSheetPage";
import { BookingsPage } from "./pages/BookingsPage";
import { BookingDetailPage } from "./pages/BookingDetailPage";
import { CustomersPage } from "./pages/CustomersPage";
import { CustomerDetailPage } from "./pages/CustomerDetailPage";
import { SettingsPage } from "./pages/SettingsPage";
import { CallLogPage } from "./pages/CallLogPage";
import { NotificationsPage } from "./pages/NotificationsPage";
import { ReportsPage } from "./pages/ReportsPage";
import { VoiceAnalyticsPage } from "./pages/VoiceAnalyticsPage";
import CampaignsPage from "./pages/CampaignsPage";
import { SegmentsPage } from "./pages/SegmentsPage";
import { TournamentsPage } from "./pages/TournamentsPage";
import { TournamentDetailPage } from "./pages/TournamentDetailPage";
import { PosPage } from "./pages/PosPage";

function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      
      {/* Public booking routes (no auth required) */}
      <Route path="/book/:courseSlug" element={<PublicBookingPage />} />
      <Route path="/book" element={<PublicBookingPage />} />
      <Route
        element={
          <ProtectedRoute>
            <AppLayout />
          </ProtectedRoute>
        }
      >
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/tee-sheet" element={<TeeSheetPage />} />
        <Route path="/bookings" element={<BookingsPage />} />
        <Route path="/bookings/:id" element={<BookingDetailPage />} />
        <Route path="/customers" element={<CustomersPage />} />
        <Route path="/customers/:id" element={<CustomerDetailPage />} />
        <Route path="/tournaments" element={<TournamentsPage />} />
        <Route path="/tournaments/:id" element={<TournamentDetailPage />} />
        <Route path="/notifications" element={<NotificationsPage />} />
        <Route path="/reports" element={<ReportsPage />} />
        <Route path="/voice-analytics" element={<VoiceAnalyticsPage />} />
        <Route path="/campaigns" element={<CampaignsPage />} />
        <Route path="/segments" element={<SegmentsPage />} />
        <Route path="/pos" element={<PosPage />} />
        <Route path="/settings" element={<SettingsPage />} />
        <Route path="/call-logs/:id" element={<CallLogPage />} />
      </Route>
    </Routes>
  );
}

export default App;
