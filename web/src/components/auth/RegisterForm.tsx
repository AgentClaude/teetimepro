import { useState } from "react";
import { useForm } from "react-hook-form";
import { useNavigate, Link } from "react-router-dom";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useAuth } from "../../hooks/useAuth";
import { Button } from "../ui/Button";
import { Input } from "../ui/Input";

const registerSchema = z
  .object({
    firstName: z.string().min(1, "First name is required"),
    lastName: z.string().min(1, "Last name is required"),
    email: z.string().email("Invalid email address"),
    password: z.string().min(6, "Password must be at least 6 characters"),
    passwordConfirmation: z.string().min(1, "Please confirm your password"),
    organizationName: z.string().optional(),
  })
  .refine((data) => data.password === data.passwordConfirmation, {
    message: "Passwords don't match",
    path: ["passwordConfirmation"],
  });

type RegisterFormValues = z.infer<typeof registerSchema>;

export function RegisterForm() {
  const { register: authRegister } = useAuth();
  const navigate = useNavigate();
  const [error, setError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<RegisterFormValues>({
    resolver: zodResolver(registerSchema),
  });

  const onSubmit = async (data: RegisterFormValues) => {
    try {
      setError(null);
      await authRegister({
        email: data.email,
        password: data.password,
        passwordConfirmation: data.passwordConfirmation,
        firstName: data.firstName,
        lastName: data.lastName,
        organizationName: data.organizationName,
      });
      navigate("/dashboard", { replace: true });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Registration failed");
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      {error && (
        <div className="rounded-lg bg-red-50 p-3 text-sm text-red-700">
          {error}
        </div>
      )}

      <div className="grid grid-cols-2 gap-3">
        <div>
          <label
            htmlFor="firstName"
            className="block text-sm font-medium text-rough-700 mb-1"
          >
            First Name
          </label>
          <Input
            id="firstName"
            type="text"
            placeholder="John"
            {...register("firstName")}
            error={errors.firstName?.message}
          />
        </div>

        <div>
          <label
            htmlFor="lastName"
            className="block text-sm font-medium text-rough-700 mb-1"
          >
            Last Name
          </label>
          <Input
            id="lastName"
            type="text"
            placeholder="Smith"
            {...register("lastName")}
            error={errors.lastName?.message}
          />
        </div>
      </div>

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

      <div>
        <label
          htmlFor="password"
          className="block text-sm font-medium text-rough-700 mb-1"
        >
          Password
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
          Confirm Password
        </label>
        <Input
          id="passwordConfirmation"
          type="password"
          placeholder="••••••••"
          {...register("passwordConfirmation")}
          error={errors.passwordConfirmation?.message}
        />
      </div>

      <div>
        <label
          htmlFor="organizationName"
          className="block text-sm font-medium text-rough-700 mb-1"
        >
          Organization Name{" "}
          <span className="text-rough-400">(optional)</span>
        </label>
        <Input
          id="organizationName"
          type="text"
          placeholder="Pebble Beach Golf Club"
          {...register("organizationName")}
          error={errors.organizationName?.message}
        />
      </div>

      <Button type="submit" variant="primary" fullWidth loading={isSubmitting}>
        Create Account
      </Button>

      <p className="text-center text-sm text-rough-500">
        Already have an account?{" "}
        <Link
          to="/login"
          className="font-medium text-fairway-600 hover:text-fairway-700"
        >
          Sign in
        </Link>
      </p>
    </form>
  );
}
