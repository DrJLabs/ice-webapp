#!/usr/bin/env python3

import os
import subprocess
import sys
import json

# Debug flag - set to False for production
DEBUG = False

# Check if hooks should be skipped
if os.environ.get('SKIP_HOOKS') == '1' or os.environ.get('SKIP_PRE_PUSH') == '1':
    print("🧊 Skipping ICE-WEBAPP pre-push quality gates (SKIP_HOOKS=1 or SKIP_PRE_PUSH=1)")
    sys.exit(0)

print("🧊 Running ICE-WEBAPP pre-push quality gates...")

# 1. Run tests with coverage
print("Running tests with coverage...")
try:
    result = subprocess.run(['pnpm', 'run', 'test:coverage'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if result.returncode != 0:
        print("❌ Tests failed! Fix tests before pushing or use git push --no-verify to bypass.")
        print("   Or set environment variable: SKIP_PRE_PUSH=1 git push")
        sys.exit(1)
except Exception as e:
    print(f"❌ Error running tests: {e}")
    sys.exit(1)

# 2. Check coverage thresholds
print("\nChecking coverage thresholds...")

# Define thresholds
LINES_THRESHOLD = 70
STATEMENTS_THRESHOLD = 70
FUNCTIONS_THRESHOLD = 65
BRANCHES_THRESHOLD = 60

# Read coverage from the coverage summary file
if os.path.exists('coverage/coverage-summary.json'):
    try:
        with open('coverage/coverage-summary.json', 'r') as f:
            coverage_data = json.load(f)

        if DEBUG:
            print("Debug: Coverage data loaded")
            print(f"Debug: Keys in coverage_data: {list(coverage_data.keys())}")

        # Get the total coverage from the file
        total_coverage = coverage_data.get('total', {})

        if DEBUG:
            print(f"Debug: total_coverage: {total_coverage}")

        # Get the percentage values
        lines_pct = total_coverage.get('lines', {}).get('pct')
        statements_pct = total_coverage.get('statements', {}).get('pct')
        functions_pct = total_coverage.get('functions', {}).get('pct')
        branches_pct = total_coverage.get('branches', {}).get('pct')

        if DEBUG:
            print(f"Debug: Raw values - lines_pct={lines_pct}, statements_pct={statements_pct}")
            print(f"Debug: Raw values - functions_pct={functions_pct}, branches_pct={branches_pct}")

        # Safe conversion to float
        def safe_float(value, default=0.0):
            try:
                if value == 'Unknown':
                    return default
                return float(value)
            except (ValueError, TypeError):
                return default

        # Convert to float
        lines_cov = safe_float(lines_pct)
        statements_cov = safe_float(statements_pct)
        functions_cov = safe_float(functions_pct)
        branches_cov = safe_float(branches_pct)

        if DEBUG:
            print(f"Debug: Converted values - lines_cov={lines_cov}, statements_cov={statements_cov}")
            print(f"Debug: Converted values - functions_cov={functions_cov}, branches_cov={branches_cov}")

    except Exception as e:
        print(f"⚠️ Error parsing coverage data: {e}")
        print("   Attempting to continue with minimal checks...")
        lines_cov = statements_cov = functions_cov = branches_cov = 0
else:
    print("⚠️ No coverage summary found (coverage/coverage-summary.json)")
    print("   Attempting to continue with minimal checks...")
    lines_cov = statements_cov = functions_cov = branches_cov = 0

# Check thresholds
checks_passed = True

# Lines coverage
if lines_cov < LINES_THRESHOLD:
    print(f"❌ Lines coverage: {lines_cov}% (threshold: {LINES_THRESHOLD}%)")
    checks_passed = False
else:
    print(f"✅ Lines coverage: {lines_cov}% (threshold: {LINES_THRESHOLD}%)")

# Statements coverage
if statements_cov < STATEMENTS_THRESHOLD:
    print(f"❌ Statements coverage: {statements_cov}% (threshold: {STATEMENTS_THRESHOLD}%)")
    checks_passed = False
else:
    print(f"✅ Statements coverage: {statements_cov}% (threshold: {STATEMENTS_THRESHOLD}%)")

# Functions coverage
if functions_cov < FUNCTIONS_THRESHOLD:
    print(f"❌ Functions coverage: {functions_cov}% (threshold: {FUNCTIONS_THRESHOLD}%)")
    checks_passed = False
else:
    print(f"✅ Functions coverage: {functions_cov}% (threshold: {FUNCTIONS_THRESHOLD}%)")

# Branches coverage
if branches_cov < BRANCHES_THRESHOLD:
    print(f"❌ Branches coverage: {branches_cov}% (threshold: {BRANCHES_THRESHOLD}%)")
    checks_passed = False
else:
    print(f"✅ Branches coverage: {branches_cov}% (threshold: {BRANCHES_THRESHOLD}%)")

# Upload coverage to Codacy
print("\nUploading coverage to Codacy...")
if os.path.exists('coverage/lcov.info'):
    try:
        upload_result = subprocess.run(['pnpm', 'run', 'coverage:upload'],
                                      stdout=subprocess.PIPE,
                                      stderr=subprocess.PIPE,
                                      text=True)
        if upload_result.returncode != 0:
            print("⚠️ Coverage upload failed, but continuing...")
    except Exception as e:
        print(f"⚠️ Coverage upload error: {e}, but continuing...")
else:
    print("⚠️ No lcov.info coverage report found. Skipping upload.")

# Final result
if not checks_passed:
    print("\n❌ One or more coverage thresholds not met!")
    print("   Fix coverage before pushing or use git push --no-verify to bypass.")
    print("   Or set environment variable: SKIP_PRE_PUSH=1 git push")
    sys.exit(1)

print("\n✅ All coverage thresholds met!")
print("🧊 Pre-push quality gates passed!")
sys.exit(0)