import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  define: {
    "process.env": {
      NODE_ENV: process.env.NODE_ENV,
    },
  },
  build: {
    lib: {
      entry: "src/index.ts",
      name: "shared-ui",
      fileName: "shared-ui",
      formats: ["es"],
    },
    rollupOptions: {
      external: ["react", "react-dom"],
    },
    minify: "esbuild",
    target: "es2020",
  },
})
