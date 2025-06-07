module.exports = {
  root: true,
  env: {
    browser: true,
    node: true,
    es6: true,
  },
  extends: [
    'eslint:recommended',
    'next/core-web-vitals',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaFeatures: {
      jsx: true,
    },
    ecmaVersion: 2021,
    sourceType: 'module',
  },
  plugins: [],
  rules: {
    // Custom rules here
  },
  overrides: [
    {
      // Special configuration for Node.js scripts
      files: ['scripts/**/*.js'],
      env: {
        node: true,
        es6: true,
      },
      globals: {
        require: 'readonly',
        process: 'readonly',
        __dirname: 'readonly',
        console: 'readonly',
      },
      rules: {
        'no-undef': 'error',
      },
    },
  ],
}; 