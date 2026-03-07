
import { 
  ExclamationTriangleIcon, 
  UserMinusIcon,
  CurrencyDollarIcon 
} from '@heroicons/react/24/outline';
import { Button } from '../ui/Button';
import { Modal } from '../ui/Modal';

interface WithdrawalConfirmationModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
  loading: boolean;
  tournamentName: string;
  entryFeeDisplay: string;
  hasRefundPolicy?: boolean;
}

export function WithdrawalConfirmationModal({
  isOpen,
  onClose,
  onConfirm,
  loading,
  tournamentName,
  entryFeeDisplay,
  hasRefundPolicy = false,
}: WithdrawalConfirmationModalProps) {
  return (
    <Modal 
      isOpen={isOpen} 
      onClose={onClose} 
      title="Withdraw from Tournament"
      size="md"
    >
      <div className="space-y-6">
        <div className="flex items-start space-x-3">
          <ExclamationTriangleIcon className="h-6 w-6 text-amber-600 mt-1 flex-shrink-0" />
          <div className="flex-1">
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              Are you sure you want to withdraw?
            </h3>
            <p className="text-gray-600 mb-4">
              You are about to withdraw from <strong>{tournamentName}</strong>. 
              This action cannot be undone.
            </p>
            
            {entryFeeDisplay !== "$0.00" && (
              <div className="bg-amber-50 border border-amber-200 rounded-lg p-4 mb-4">
                <div className="flex items-center mb-2">
                  <CurrencyDollarIcon className="h-5 w-5 text-amber-600 mr-2" />
                  <span className="font-medium text-amber-800">Refund Policy</span>
                </div>
                <p className="text-sm text-amber-700">
                  {hasRefundPolicy 
                    ? `Your entry fee of ${entryFeeDisplay} will be refunded according to the tournament's refund policy.`
                    : `Entry fees are typically non-refundable. Your ${entryFeeDisplay} entry fee may not be refunded.`
                  }
                </p>
              </div>
            )}

            <div className="space-y-2 text-sm text-gray-600">
              <h4 className="font-medium text-gray-900">What happens next:</h4>
              <ul className="list-disc pl-5 space-y-1">
                <li>You will be removed from the tournament</li>
                <li>Your spot may be given to someone on the waitlist</li>
                <li>You will receive a confirmation email</li>
                {hasRefundPolicy && entryFeeDisplay !== "$0.00" && (
                  <li>Any applicable refunds will be processed within 5-7 business days</li>
                )}
              </ul>
            </div>
          </div>
        </div>

        <div className="flex justify-end space-x-3 pt-6 border-t border-gray-200">
          <Button 
            type="button" 
            variant="outline" 
            onClick={onClose}
            disabled={loading}
          >
            Cancel
          </Button>
          <Button 
            variant="danger" 
            onClick={onConfirm}
            loading={loading}
            disabled={loading}
          >
            <UserMinusIcon className="h-4 w-4 mr-2" />
            {loading ? 'Withdrawing...' : 'Withdraw from Tournament'}
          </Button>
        </div>
      </div>
    </Modal>
  );
}