import { resolve } from "path";
import { defineConfig } from "vite";
import rails from "vite-plugin-rails";

export default defineConfig({
  plugins: [rails()],
  extensions: ["tsx", "ts", "jsx", "js", "scss", "css"],
  resolve: {
    alias: {
      "@app": resolve(__dirname, "app/javascript/app"),
      "@novnc/novnc/core/rfb.js": resolve(
        __dirname,
        "node_modules/@novnc/novnc/core/rfb.js",
      ),
    },
  },
});
