import forms from "@tailwindcss/forms";
import typography from "@tailwindcss/typography";

export default {
  content: ["./src/**/*.vue"],
  theme: {
    extend: {},
  },
  plugins: [typography, forms],
};
