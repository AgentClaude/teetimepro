import { RegisterForm } from "../components/auth/RegisterForm";

export function RegisterPage() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-gray-50">
      <div className="w-full max-w-md">
        <div className="mb-8 text-center">
          <span className="text-5xl">⛳</span>
          <h1 className="mt-4 text-3xl font-bold text-gray-900">
            TeeTimes Pro
          </h1>
          <p className="mt-2 text-gray-500">Create your account</p>
        </div>

        <div className="rounded-xl bg-white p-8 shadow-sm">
          <RegisterForm />
        </div>
      </div>
    </div>
  );
}
