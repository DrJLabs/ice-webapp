import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import {
  cn,
  formatCurrency,
  truncateText,
  generateId,
  debounce,
  sleep,
  kebabToTitle,
  safeJsonParse,
  delay,
  copyToClipboard
} from '../../src/lib/utils';

describe('Utility Functions', () => {
  describe('cn (classname utility)', () => {
    it('should combine class names correctly', () => {
      expect(cn('btn', 'btn-primary')).toBe('btn btn-primary');
      expect(cn('btn', { 'btn-primary': true, 'btn-large': false })).toBe('btn btn-primary');
      expect(cn('btn', null, undefined, 'btn-primary')).toBe('btn btn-primary');
    });

    it('should handle Tailwind conflicts using tailwind-merge', () => {
      expect(cn('p-4', 'p-6')).toBe('p-6');
      expect(cn('text-red-500', 'text-blue-500')).toBe('text-blue-500');
    });
  });

  describe('formatCurrency', () => {
    it('should format currency with default USD', () => {
      expect(formatCurrency(1000)).toBe('$1,000.00');
      expect(formatCurrency(1000.5)).toBe('$1,000.50');
    });

    it('should format currency with specified currency', () => {
      expect(formatCurrency(1000, 'EUR')).toBe('€1,000.00');
      expect(formatCurrency(1000, 'JPY')).toBe('¥1,000');
    });
  });

  describe('truncateText', () => {
    it('should truncate text longer than specified length', () => {
      expect(truncateText('Hello World', 5)).toBe('Hello...');
    });

    it('should not truncate text shorter than specified length', () => {
      expect(truncateText('Hello', 10)).toBe('Hello');
    });

    it('should handle empty strings', () => {
      expect(truncateText('', 5)).toBe('');
    });
  });

  describe('generateId', () => {
    it('should generate a non-empty string', () => {
      expect(typeof generateId()).toBe('string');
      expect(generateId().length).toBeGreaterThan(0);
    });

    it('should generate unique IDs', () => {
      const id1 = generateId();
      const id2 = generateId();
      expect(id1).not.toBe(id2);
    });
  });

  describe('debounce', () => {
    beforeEach(() => {
      vi.useFakeTimers();
    });

    afterEach(() => {
      vi.restoreAllMocks();
    });

    it('should debounce function calls', () => {
      const mockFn = vi.fn();
      const debouncedFn = debounce(mockFn, 500);

      debouncedFn();
      expect(mockFn).not.toHaveBeenCalled();

      vi.advanceTimersByTime(200);
      debouncedFn();
      expect(mockFn).not.toHaveBeenCalled();

      vi.advanceTimersByTime(500);
      expect(mockFn).toHaveBeenCalledTimes(1);
    });
  });

  describe('sleep and delay', () => {
    beforeEach(() => {
      vi.useFakeTimers();
    });

    afterEach(() => {
      vi.restoreAllMocks();
    });

    it('should resolve after the specified time with sleep', async () => {
      const promise = sleep(1000);
      vi.advanceTimersByTime(1000);
      await expect(promise).resolves.toBeUndefined();
    });

    it('should resolve after the specified time with delay', async () => {
      const promise = delay(1000);
      vi.advanceTimersByTime(1000);
      await expect(promise).resolves.toBeUndefined();
    });
  });

  describe('kebabToTitle', () => {
    it('should convert kebab-case to title case', () => {
      expect(kebabToTitle('hello-world')).toBe('Hello World');
      expect(kebabToTitle('user-profile-settings')).toBe('User Profile Settings');
    });

    it('should handle single words', () => {
      expect(kebabToTitle('hello')).toBe('Hello');
    });

    it('should handle empty strings', () => {
      expect(kebabToTitle('')).toBe('');
    });
  });

  describe('safeJsonParse', () => {
    it('should parse valid JSON', () => {
      expect(safeJsonParse('{"name":"John","age":30}', null)).toEqual({ name: 'John', age: 30 });
    });

    it('should return fallback for invalid JSON', () => {
      const fallback = { name: 'Default', age: 0 };
      expect(safeJsonParse('invalid json', fallback)).toBe(fallback);
    });
  });

  describe('copyToClipboard', () => {
    beforeEach(() => {
      Object.defineProperty(navigator, 'clipboard', {
        value: {
          writeText: vi.fn().mockResolvedValue(undefined),
        },
        configurable: true,
      });
      document.execCommand = vi.fn().mockReturnValue(true);
    });

    it('should use clipboard API when available', async () => {
      const result = await copyToClipboard('test text');
      expect(navigator.clipboard.writeText).toHaveBeenCalledWith('test text');
      expect(result).toBe(true);
    });

    it('should fallback to execCommand when clipboard API fails', async () => {
      // Mock clipboard API to fail
      Object.defineProperty(navigator, 'clipboard', {
        value: {
          writeText: vi.fn().mockRejectedValue(new Error('Not allowed')),
        },
        configurable: true,
      });
      
      const appendChildSpy = vi.spyOn(document.body, 'appendChild').mockImplementation(() => {});
      const removeChildSpy = vi.spyOn(document.body, 'removeChild').mockImplementation(() => {});
      
      const result = await copyToClipboard('test text');
      
      expect(document.execCommand).toHaveBeenCalledWith('copy');
      expect(appendChildSpy).toHaveBeenCalled();
      expect(removeChildSpy).toHaveBeenCalled();
      expect(result).toBe(true);
      
      appendChildSpy.mockRestore();
      removeChildSpy.mockRestore();
    });
  });
}); 