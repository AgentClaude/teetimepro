import { useState } from "react";
import { useForm } from "react-hook-form";
import { useNavigate, useSearchParams, Link } from "react-router-dom";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Button } from "../ui/Button";
import { Input } from "../ui/Input";

const resetPasswordSchema = z
  .object({
    password: z.string().min(6, "Password must be at least 6 characters"),
    passwordConfirmation: z.string().min(1, "Please confirm your password"),
  })
  .refine((data) => data.password === data.passwordConfirmation, {
    message: "Passwords don't match",
    path: ["passwordConfirmation"],
  });

type ResetPasswordFormValues = z.infer<typeof resetPasswordSchema>;

export function ResetPasswordForm() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const token = searchParams.get("token");
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<ResetPasswordFormValues>({
    resolver: zodResolver(resetPasswordSchema),
  });

  if (!token) {
    return (
      <div className="space-y-4 text-center">
        <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-red-100">
          <span className="text-2xl">⚠️</span>
        </div>
        <h3 className="text-lg font-medium text-rough-900">Invalid Link</h3>
        <p className="text-sm text-rough-500">
          This password reset link is invalid or has expired.
        </p>
        <Link
          to="/forgot-password"
          className="inline-block text-sm font-medium text-fairway-600 hover:text-fairway-700"
        >
          Request a new link
        </Link>
      </div>
    );
  }

  if (success) {
    return (
      <div className="space-y-4 text-center">
        <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-fairway-100">
          <span className="text-2xl">✅</span>
        </div>
        <h3 className="text-lg font-medium text-rough-900">
          Password Reset Successfully
        </h3>
        <p className="text-sm text-rough-500">
          Your password has been updated. You can now sign in with your new
          password.
        </p>
        <Button
          variant="primary"
          onClick={() => navigate("/login")}
          fullWidth
        >
          Sign In
        </Button>
      </div>
    );
  }

  const onSubmit = async (data: ResetPasswordFormValues) => {
    try {
      setError(null);
      const response = await fetch("/api/auth/password/reset", {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          token,
          password: data.password,
          password_confirmation: data.passwordConfirmation,
        }),
      });

      if (!response.ok) {
        const result = await response.json();
        throw new Error(result.errors?.[0] || "Reset failed");
      }

      setSuccess(true);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to reset password");
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      {error && (
        <div className="rounded-lg bg-red-50 p-3 text-sm text-red-700">
          {error}
        </div>
      )}

      <p className="text-sm text-rough-500">Enter your new password below.</p>

      <div>
        <label
          htmlFor="password"
          className="block text-sm font-medium text-rough-700 mb-1"
        >
          New Password
        </label>
        <Input
          id="password"
          type="password"
          placeholder="••••••••"
          {...register("password")}
          error={errors.password?.message}
        />
      </div>

      <div>
        <label
          htmlFor="passwordConfirmation"
          className="block text-sm font-medium text-rough-700 mb-1"
        >
          Confirm New Password
        </label>
        <Input
          id="passwordConfirmation"
          type="password"
          placeholder="••••••••"
          {...register("passwordConfirmation")}
          error={errors.passwordConfirmation?.message}
        />
      </div>

      <Button type="submit" variant="primary" fullWidth loading={isSubmitting}>
        Reset Password
      </Button>
    </form>
  );
}
