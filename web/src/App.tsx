import { Routes, Route, Navigate } from "react-router-dom";
import { AppLayout } from "./components/layout/AppLayout";
import { ProtectedRoute } from "./components/auth/ProtectedRoute";
import { LoginPage } from "./pages/LoginPage";
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
import CampaignsPage from "./pages/CampaignsPage";
import { SegmentsPage } from "./pages/SegmentsPage";

function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
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
        <Route path="/notifications" element={<NotificationsPage />} />
        <Route path="/reports" element={<ReportsPage />} />
        <Route path="/campaigns" element={<CampaignsPage />} />
        <Route path="/segments" element={<SegmentsPage />} />
        <Route path="/settings" element={<SettingsPage />} />
        <Route path="/call-logs/:id" element={<CallLogPage />} />
      </Route>
    </Routes>
  );
}

export default App;
