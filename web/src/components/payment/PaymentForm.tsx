import React, { useState } from 'react';
import { PaymentElement, useStripe, useElements } from '@stripe/react-stripe-js';
import { Button } from '../ui/Button';

interface PaymentFormProps {
  clientSecret: string;
  amount: number;
  onSuccess: (paymentMethodId: string) => void;
  onError: (error: string) => void;
  loading?: boolean;
}

export function PaymentForm({ 
  amount, 
  onSuccess, 
  onError, 
  loading = false 
}: PaymentFormProps) {
  const stripe = useStripe();
  const elements = useElements();
  const [isProcessing, setIsProcessing] = useState(false);

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();

    if (!stripe || !elements) {
      onError('Stripe has not loaded yet. Please try again.');
      return;
    }

    setIsProcessing(true);

    try {
      const { error, paymentIntent } = await stripe.confirmPayment({
        elements,
        confirmParams: {
          return_url: `${window.location.origin}/booking/complete`,
        },
        redirect: 'if_required',
      });

      if (error) {
        onError(error.message || 'Payment failed. Please try again.');
      } else if (paymentIntent && paymentIntent.payment_method) {
        const paymentMethodId = typeof paymentIntent.payment_method === 'string' 
          ? paymentIntent.payment_method 
          : paymentIntent.payment_method.id;
        
        onSuccess(paymentMethodId);
      } else {
        onError('Payment failed. Please try again.');
      }
    } catch (err) {
      onError('An unexpected error occurred. Please try again.');
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <h4 className="text-lg font-medium text-gray-900 mb-4">Payment Information</h4>
        <div className="p-4 border border-gray-200 rounded-lg">
          <PaymentElement 
            options={{
              layout: 'tabs',
              wallets: {
                applePay: 'auto',
                googlePay: 'auto',
              },
            }}
          />
        </div>
      </div>

      <div className="rounded-lg bg-gray-50 p-4">
        <div className="flex items-center justify-between">
          <span className="text-sm font-medium text-gray-600">Total Amount</span>
          <span className="text-lg font-bold text-gray-900">${(amount / 100).toFixed(2)}</span>
        </div>
      </div>

      <Button
        type="submit"
        variant="primary"
        className="w-full"
        disabled={!stripe || isProcessing || loading}
      >
        {isProcessing ? 'Processing...' : `Pay $${(amount / 100).toFixed(2)}`}
      </Button>
    </form>
  );
}