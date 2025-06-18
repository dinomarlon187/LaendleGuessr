#!/usr/bin/env python3
"""
Main test runner for all controller tests.
Run this file to execute all test suites.
"""

import pytest
import sys
import os

# Add the project root to the Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))

def run_all_tests():
    """Run all controller tests."""
    print("="*80)
    print("Running comprehensive controller tests for LaendleGuessr API")
    print("="*80)
    
    # Define test files to run
    test_files = [
        'test_item_controller.py',
        'test_quest_controller.py', 
        'test_user_controller.py',
        'test_security_controller.py'
    ]
    
    # Get the directory of this script
    test_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Build full paths to test files
    test_paths = [os.path.join(test_dir, test_file) for test_file in test_files]
    
    # Run pytest with verbose output
    pytest_args = [
        '-v',  # Verbose output
        '--tb=short',  # Short traceback format
        '--color=yes',  # Colored output
        '-x',  # Stop on first failure
        '--disable-warnings'  # Disable warnings for cleaner output
    ] + test_paths
    
    print(f"Running tests from: {test_dir}")
    print(f"Test files: {test_files}")
    print("-"*80)
    
    # Run the tests
    exit_code = pytest.main(pytest_args)
    
    print("-"*80)
    if exit_code == 0:
        print("✅ All tests passed!")
    else:
        print("❌ Some tests failed!")
    print("="*80)
    
    return exit_code

if __name__ == '__main__':
    exit_code = run_all_tests()
    sys.exit(exit_code)
