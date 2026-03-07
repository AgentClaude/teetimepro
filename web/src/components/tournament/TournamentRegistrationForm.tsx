import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useMutation } from '@apollo/client';
import { 
  UserPlusIcon, 
  CurrencyDollarIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon
} from '@heroicons/react/24/outline';

import { Button } from '../ui/Button';
import { Input } from '../ui/Input';
import { Card } from '../ui/Card';
import { Modal } from '../ui/Modal';
import { PaymentForm } from '../payment/PaymentForm';
import { StripeProvider } from '../payment/StripeProvider';
import { REGISTER_FOR_TOURNAMENT, CREATE_PAYMENT_INTENT } from '../../graphql/mutations';

interface Tournament {
  id: string;
  name: string;
  format: string;
  entryFeeCents: number;
  entryFeeDisplay: string;
  handicapEnabled: boolean;
  maxHandicap?: number;
  teamSize: number;
  maxParticipants?: number;
  entriesCount: number;
}

interface TournamentRegistrationFormProps {
  tournament: Tournament;
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

const registrationSchema = z.object({
  handicapIndex: z.string().optional().refine(
    (val) => !val || (!isNaN(Number(val)) && Number(val) >= 0),
    { message: "Handicap must be a valid number" }
  ),
  teamName: z.string().optional(),
});

type RegistrationFormData = z.infer<typeof registrationSchema>;

type RegistrationStep = 'form' | 'payment' | 'success' | 'error';

export function TournamentRegistrationForm({ 
  tournament, 
  isOpen, 
  onClose, 
  onSuccess 
}: TournamentRegistrationFormProps) {
  const [currentStep, setCurrentStep] = useState<RegistrationStep>('form');
  const [clientSecret, setClientSecret] = useState<string | null>(null);
  const [errorMessage, setErrorMessage] = useState<string>('');

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
    getValues,
  } = useForm<RegistrationFormData>({
    resolver: zodResolver(registrationSchema),
  });

  const [createPaymentIntent, { loading: paymentIntentLoading }] = useMutation(CREATE_PAYMENT_INTENT);
  const [registerForTournament, { loading: registerLoading }] = useMutation(REGISTER_FOR_TOURNAMENT);

  const needsPayment = tournament.entryFeeCents > 0;
  const needsTeamName = ['SCRAMBLE', 'BEST_BALL'].includes(tournament.format);

  const handleClose = () => {
    setCurrentStep('form');
    setClientSecret(null);
    setErrorMessage('');
    reset();
    onClose();
  };

  const validateHandicap = (handicap?: string) => {
    if (!tournament.handicapEnabled) return true;
    if (!handicap) return !tournament.handicapEnabled; // Required if handicap enabled
    
    const numericHandicap = Number(handicap);
    if (isNaN(numericHandicap) || numericHandicap < 0) {
      setErrorMessage('Handicap must be a valid positive number');
      return false;
    }
    
    if (tournament.maxHandicap && numericHandicap > tournament.maxHandicap) {
      setErrorMessage(`Handicap cannot exceed ${tournament.maxHandicap}`);
      return false;
    }
    
    return true;
  };

  const onFormSubmit = async (data: RegistrationFormData) => {
    setErrorMessage('');

    // Validate handicap if required
    if (tournament.handicapEnabled && !validateHandicap(data.handicapIndex)) {
      return;
    }

    // Check if tournament is full
    if (tournament.maxParticipants && tournament.entriesCount >= tournament.maxParticipants) {
      setErrorMessage('This tournament is full. You will be added to the waitlist.');
    }

    if (needsPayment) {
      try {
        // Create payment intent for tournament registration
        const { data: paymentData } = await createPaymentIntent({
          variables: {
            tournamentId: tournament.id,
            entryFeeCents: tournament.entryFeeCents,
          },
        });

        if (paymentData?.createPaymentIntent?.clientSecret) {
          setClientSecret(paymentData.createPaymentIntent.clientSecret);
          setCurrentStep('payment');
        } else {
          setErrorMessage('Failed to initialize payment. Please try again.');
          setCurrentStep('error');
        }
      } catch (error) {
        console.error('Error creating payment intent:', error);
        setErrorMessage('Failed to initialize payment. Please try again.');
        setCurrentStep('error');
      }
    } else {
      // Register directly without payment
      await handleRegistration();
    }
  };

  const handleRegistration = async (paymentMethodId?: string) => {
    const formData = getValues();
    
    try {
      const { data } = await registerForTournament({
        variables: {
          tournamentId: tournament.id,
          handicapIndex: formData.handicapIndex ? Number(formData.handicapIndex) : undefined,
          teamName: formData.teamName || undefined,
          paymentMethodId,
        },
      });

      if (data?.registerForTournament?.errors?.length > 0) {
        setErrorMessage(data.registerForTournament.errors.join(', '));
        setCurrentStep('error');
      } else {
        setCurrentStep('success');
        setTimeout(() => {
          handleClose();
          onSuccess();
        }, 2000);
      }
    } catch (error) {
      console.error('Error registering for tournament:', error);
      setErrorMessage('Registration failed. Please try again.');
      setCurrentStep('error');
    }
  };

  const handlePaymentSuccess = (paymentMethodId: string) => {
    handleRegistration(paymentMethodId);
  };

  const handlePaymentError = (error: string) => {
    setErrorMessage(error);
    setCurrentStep('error');
  };

  const renderFormStep = () => (
    <div className="space-y-6">
      {/* Tournament Summary */}
      <Card className="bg-blue-50 border-blue-200">
        <div className="p-4">
          <div className="flex items-center mb-3">
            <UserPlusIcon className="h-5 w-5 text-blue-600 mr-2" />
            <h3 className="font-semibold text-blue-900">Tournament Registration</h3>
          </div>
          <h4 className="font-medium text-blue-900 mb-2">{tournament.name}</h4>
          <div className="flex items-center justify-between text-sm">
            <span className="text-blue-700">Entry Fee:</span>
            <span className="font-medium text-blue-900">{tournament.entryFeeDisplay}</span>
          </div>
          {tournament.maxParticipants && (
            <div className="flex items-center justify-between text-sm mt-1">
              <span className="text-blue-700">Spots Available:</span>
              <span className="font-medium text-blue-900">
                {tournament.maxParticipants - tournament.entriesCount} of {tournament.maxParticipants}
              </span>
            </div>
          )}
        </div>
      </Card>

      {/* Registration Form */}
      <form onSubmit={handleSubmit(onFormSubmit)} className="space-y-4">
        {tournament.handicapEnabled && (
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Handicap Index *
              {tournament.maxHandicap && (
                <span className="text-gray-500 font-normal"> (Maximum: {tournament.maxHandicap})</span>
              )}
            </label>
            <Input
              type="number"
              step="0.1"
              min="0"
              max={tournament.maxHandicap}
              placeholder="Enter your handicap index"
              {...register('handicapIndex')}
              error={errors.handicapIndex?.message}
              required={tournament.handicapEnabled}
            />
            <p className="text-xs text-gray-500 mt-1">
              Your official handicap index as maintained by your golf association
            </p>
          </div>
        )}

        {needsTeamName && (
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Team Name {tournament.teamSize === 1 ? '(Optional)' : ''}
            </label>
            <Input
              type="text"
              placeholder="Enter your team name"
              {...register('teamName')}
              error={errors.teamName?.message}
            />
            {tournament.teamSize > 1 && (
              <p className="text-xs text-gray-500 mt-1">
                Teams consist of {tournament.teamSize} players
              </p>
            )}
          </div>
        )}

        {/* Terms and Conditions */}
        <div className="p-4 bg-gray-50 rounded-lg text-sm text-gray-600">
          <p className="mb-2">By registering, you agree to:</p>
          <ul className="list-disc pl-5 space-y-1">
            <li>Follow all tournament rules and golf course policies</li>
            <li>Arrive on time for your assigned tee time</li>
            <li>Play in a sporting manner and maintain pace of play</li>
            {needsPayment && <li>Entry fees are non-refundable unless tournament is cancelled</li>}
          </ul>
        </div>

        {errorMessage && (
          <div className="flex items-center p-3 bg-red-50 border border-red-200 rounded-lg">
            <ExclamationTriangleIcon className="h-5 w-5 text-red-600 mr-2 flex-shrink-0" />
            <span className="text-sm text-red-700">{errorMessage}</span>
          </div>
        )}

        <div className="flex justify-end space-x-3 pt-4">
          <Button type="button" variant="outline" onClick={handleClose}>
            Cancel
          </Button>
          <Button 
            type="submit" 
            disabled={paymentIntentLoading}
            loading={paymentIntentLoading}
          >
            {needsPayment ? 'Continue to Payment' : 'Register'}
          </Button>
        </div>
      </form>
    </div>
  );

  const renderPaymentStep = () => (
    <div className="space-y-6">
      <div className="flex items-center mb-6">
        <CurrencyDollarIcon className="h-6 w-6 text-green-600 mr-3" />
        <div>
          <h3 className="text-lg font-semibold">Tournament Registration Payment</h3>
          <p className="text-sm text-gray-600">{tournament.name}</p>
        </div>
      </div>

      {clientSecret && (
        <StripeProvider clientSecret={clientSecret}>
          <PaymentForm
            clientSecret={clientSecret}
            amount={tournament.entryFeeCents}
            onSuccess={handlePaymentSuccess}
            onError={handlePaymentError}
            loading={registerLoading}
          />
        </StripeProvider>
      )}

      <div className="flex justify-end space-x-3 pt-4">
        <Button 
          type="button" 
          variant="outline" 
          onClick={() => setCurrentStep('form')}
          disabled={registerLoading}
        >
          Back
        </Button>
      </div>
    </div>
  );

  const renderSuccessStep = () => (
    <div className="text-center py-8">
      <CheckCircleIcon className="h-12 w-12 text-green-600 mx-auto mb-4" />
      <h3 className="text-lg font-semibold text-gray-900 mb-2">Registration Successful!</h3>
      <p className="text-gray-600 mb-6">
        You have been successfully registered for <strong>{tournament.name}</strong>.
        {tournament.maxParticipants && tournament.entriesCount >= tournament.maxParticipants 
          ? ' You have been added to the waitlist and will be notified if a spot opens up.'
          : ' You will receive confirmation details via email.'}
      </p>
    </div>
  );

  const renderErrorStep = () => (
    <div className="text-center py-8">
      <ExclamationTriangleIcon className="h-12 w-12 text-red-600 mx-auto mb-4" />
      <h3 className="text-lg font-semibold text-gray-900 mb-2">Registration Failed</h3>
      <p className="text-gray-600 mb-6">{errorMessage}</p>
      <div className="flex justify-center space-x-3">
        <Button variant="outline" onClick={handleClose}>
          Close
        </Button>
        <Button onClick={() => setCurrentStep('form')}>
          Try Again
        </Button>
      </div>
    </div>
  );

  const getStepTitle = () => {
    switch (currentStep) {
      case 'form':
        return 'Register for Tournament';
      case 'payment':
        return 'Payment Information';
      case 'success':
        return 'Registration Complete';
      case 'error':
        return 'Registration Error';
      default:
        return 'Tournament Registration';
    }
  };

  const renderStepContent = () => {
    switch (currentStep) {
      case 'form':
        return renderFormStep();
      case 'payment':
        return renderPaymentStep();
      case 'success':
        return renderSuccessStep();
      case 'error':
        return renderErrorStep();
      default:
        return renderFormStep();
    }
  };

  return (
    <Modal 
      isOpen={isOpen} 
      onClose={handleClose} 
      title={getStepTitle()}
      size="lg"
    >
      {renderStepContent()}
    </Modal>
  );
}