import { describe, it, expect } from 'vitest'
import {
  formatCurrency,
  truncateText,
  isValidEmail,
  kebabToTitle,
} from '@/lib/utils'

describe('utils', () => {
  describe('formatCurrency', () => {
    it('should format a number into USD currency', () => {
      expect(formatCurrency(123.45)).toBe('$123.45')
    })

    it('should format a number into EUR currency', () => {
      expect(formatCurrency(543.21, 'EUR')).toBe('€543.21')
    })
  })

  describe('truncateText', () => {
    it('should not truncate text if it is shorter than or equal to the length', () => {
      expect(truncateText('short', 10)).toBe('short')
    })

    it('should truncate text if it is longer than the length', () => {
      expect(truncateText('this is a long text', 10)).toBe('this is a ...')
    })
  })

  describe('isValidEmail', () => {
    it('should return true for a valid email', () => {
      expect(isValidEmail('test@example.com')).toBe(true)
    })

    it('should return false for an invalid email', () => {
      expect(isValidEmail('not-an-email')).toBe(false)
      expect(isValidEmail('test@.com')).toBe(false)
      expect(isValidEmail('@example.com')).toBe(false)
    })
  })

  describe('kebabToTitle', () => {
    it('should convert kebab-case to Title Case', () => {
      expect(kebabToTitle('hello-world')).toBe('Hello World')
    })

    it('should handle single words', () => {
      expect(kebabToTitle('hello')).toBe('Hello')
    })
  })
}) 