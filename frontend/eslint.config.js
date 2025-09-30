/** @type {import("eslint").FlatConfig[]} */
export default [
  {
    files: ["*.js"],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
    },
    rules: {
      "no-unused-vars": "warn",
      "no-console": "off",
      "eqeqeq": "error",
      "semi": ["error", "always"],
    },
  },
];
