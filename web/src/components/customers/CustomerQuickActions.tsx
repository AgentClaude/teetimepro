import { useNavigate } from 'react-router-dom';
import { Button } from '../ui/Button';

interface CustomerQuickActionsProps {
  customer: {
    id: string;
    fullName: string;
    email: string;
  };
}

export function CustomerQuickActions({ customer }: CustomerQuickActionsProps) {
  const navigate = useNavigate();

  return (
    <div className="flex items-center gap-2">
      <Button
        variant="primary"
        size="sm"
        onClick={() => navigate('/tee-sheet')}
      >
        New Booking
      </Button>
      <Button
        variant="secondary"
        size="sm"
        onClick={() => {
          window.location.href = `mailto:${customer.email}`;
        }}
      >
        Send Email
      </Button>
    </div>
  );
}
