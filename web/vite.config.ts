import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";

const proxyTarget = process.env.API_PROXY_TARGET || "http://localhost:3003";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  server: {
    port: 3004,
    proxy: {
      "/graphql": {
        target: proxyTarget,
        changeOrigin: true,
      },
      "/api": {
        target: proxyTarget,
        changeOrigin: true,
      },
    },
  },
});
