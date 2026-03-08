import { useState } from "react";
import { useForm } from "react-hook-form";
import { Link } from "react-router-dom";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Button } from "../ui/Button";
import { Input } from "../ui/Input";

const forgotPasswordSchema = z.object({
  email: z.string().email("Invalid email address"),
});

type ForgotPasswordFormValues = z.infer<typeof forgotPasswordSchema>;

export function ForgotPasswordForm() {
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<ForgotPasswordFormValues>({
    resolver: zodResolver(forgotPasswordSchema),
  });

  const onSubmit = async (data: ForgotPasswordFormValues) => {
    try {
      setError(null);
      const response = await fetch("/api/auth/password/reset", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email: data.email }),
      });

      if (!response.ok) {
        const result = await response.json();
        throw new Error(result.errors?.[0] || "Request failed");
      }

      setSuccess(true);
    } catch (err) {
      setError(
        err instanceof Error ? err.message : "Failed to send reset email"
      );
    }
  };

  if (success) {
    return (
      <div className="space-y-4 text-center">
        <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-fairway-100">
          <span className="text-2xl">✉️</span>
        </div>
        <h3 className="text-lg font-medium text-rough-900">Check your email</h3>
        <p className="text-sm text-rough-500">
          If an account exists with that email, we've sent password reset
          instructions.
        </p>
        <Link
          to="/login"
          className="inline-block text-sm font-medium text-fairway-600 hover:text-fairway-700"
        >
          Back to sign in
        </Link>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      {error && (
        <div className="rounded-lg bg-red-50 p-3 text-sm text-red-700">
          {error}
        </div>
      )}

      <p className="text-sm text-rough-500">
        Enter your email address and we'll send you a link to reset your
        password.
      </p>

      <div>
        <label
          htmlFor="email"
          className="block text-sm font-medium text-rough-700 mb-1"
        >
          Email
        </label>
        <Input
          id="email"
          type="email"
          placeholder="you@example.com"
          {...register("email")}
          error={errors.email?.message}
        />
      </div>

      <Button type="submit" variant="primary" fullWidth loading={isSubmitting}>
        Send Reset Link
      </Button>

      <p className="text-center text-sm text-rough-500">
        <Link
          to="/login"
          className="font-medium text-fairway-600 hover:text-fairway-700"
        >
          Back to sign in
        </Link>
      </p>
    </form>
  );
}
