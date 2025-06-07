declare module '@testing-library/react';

interface GlobalTestUtils {
  [key: string]: unknown;
}

declare var testUtils: GlobalTestUtils;
