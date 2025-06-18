#!/usr/bin/env python3
"""
Comprehensive Test Suite Runner for LaendleGuessr REST API Controllers

This script runs all comprehensive unit tests for the controller layer,
including edge cases, performance tests, and integration scenarios.

Usage:
    python run_comprehensive_tests.py [--verbose] [--performance] [--coverage]
"""

import unittest
import sys
import time
import argparse
from io import StringIO

# Import all comprehensive test modules
from test_user_controller_comprehensive import TestUserControllerComprehensive
from test_quest_controller_comprehensive import TestQuestControllerComprehensive  
from test_item_controller_comprehensive import TestItemControllerComprehensive
from test_security_controller_comprehensive import TestSecurityControllerComprehensive
from test_controller_edge_cases import TestControllerEdgeCases
from test_controller_performance import TestControllerPerformance, TestControllerStability


class ComprehensiveTestRunner:
    """Custom test runner with detailed reporting"""
    
    def __init__(self, verbosity=1, run_performance=False):
        self.verbosity = verbosity
        self.run_performance = run_performance
        self.results = {}
        
    def run_test_suite(self, test_class, suite_name):
        """Run a specific test suite and collect results"""
        print(f"\n{'='*60}")
        print(f"Running {suite_name}")
        print(f"{'='*60}")
        
        loader = unittest.TestLoader()
        suite = loader.loadTestsFromTestCase(test_class)
        
        # Capture test output
        stream = StringIO()
        runner = unittest.TextTestRunner(
            stream=stream, 
            verbosity=self.verbosity,
            buffer=True
        )
        
        start_time = time.time()
        result = runner.run(suite)
        end_time = time.time()
        
        # Store results
        self.results[suite_name] = {
            'tests_run': result.testsRun,
            'failures': len(result.failures),
            'errors': len(result.errors),
            'skipped': len(result.skipped) if hasattr(result, 'skipped') else 0,
            'time': end_time - start_time,
            'success_rate': (result.testsRun - len(result.failures) - len(result.errors)) / result.testsRun * 100 if result.testsRun > 0 else 0
        }
        
        # Print summary
        print(f"Tests run: {result.testsRun}")
        print(f"Failures: {len(result.failures)}")
        print(f"Errors: {len(result.errors)}")
        print(f"Time: {end_time - start_time:.2f}s")
        
        if result.failures:
            print(f"\nFAILURES:")
            for test, traceback in result.failures:
                print(f"  - {test}: {traceback.split('AssertionError:')[-1].strip() if 'AssertionError:' in traceback else 'Unknown failure'}")
        
        if result.errors:
            print(f"\nERRORS:")
            for test, traceback in result.errors:
                print(f"  - {test}: {traceback.split('Exception:')[-1].strip() if 'Exception:' in traceback else 'Unknown error'}")
                
        return result.wasSuccessful()
    
    def run_all_tests(self):
        """Run all comprehensive test suites"""
        print("LaendleGuessr REST API - Comprehensive Controller Test Suite")
        print("=" * 60)
        
        # Core controller tests
        test_suites = [
            (TestUserControllerComprehensive, "User Controller Tests"),
            (TestQuestControllerComprehensive, "Quest Controller Tests"),
            (TestItemControllerComprehensive, "Item Controller Tests"),
            (TestSecurityControllerComprehensive, "Security Controller Tests"),
            (TestControllerEdgeCases, "Edge Cases & Integration Tests"),
        ]
        
        # Add performance tests if requested
        if self.run_performance:
            test_suites.extend([
                (TestControllerPerformance, "Performance Tests"),
                (TestControllerStability, "Stability Tests"),
            ])
        
        all_successful = True
        
        for test_class, suite_name in test_suites:
            success = self.run_test_suite(test_class, suite_name)
            if not success:
                all_successful = False
        
        self.print_final_summary()
        return all_successful
    
    def print_final_summary(self):
        """Print comprehensive test summary"""
        print(f"\n{'='*60}")
        print("COMPREHENSIVE TEST SUMMARY")
        print(f"{'='*60}")
        
        total_tests = sum(r['tests_run'] for r in self.results.values())
        total_failures = sum(r['failures'] for r in self.results.values())
        total_errors = sum(r['errors'] for r in self.results.values())
        total_time = sum(r['time'] for r in self.results.values())
        
        print(f"Total Tests Run: {total_tests}")
        print(f"Total Failures: {total_failures}")
        print(f"Total Errors: {total_errors}")
        print(f"Total Time: {total_time:.2f}s")
        print(f"Overall Success Rate: {((total_tests - total_failures - total_errors) / total_tests * 100):.1f}%")
        
        print(f"\nDetailed Results by Suite:")
        print(f"{'Suite':<35} {'Tests':<8} {'Failures':<10} {'Errors':<8} {'Success%':<10} {'Time':<8}")
        print("-" * 80)
        
        for suite_name, results in self.results.items():
            print(f"{suite_name:<35} {results['tests_run']:<8} {results['failures']:<10} {results['errors']:<8} {results['success_rate']:<10.1f} {results['time']:<8.2f}")
        
        # Coverage recommendations
        print(f"\n{'='*60}")
        print("COVERAGE RECOMMENDATIONS")
        print(f"{'='*60}")
        print("1. Run with --coverage flag to generate coverage report")
        print("2. Focus on edge cases with low success rates")
        print("3. Review failed tests for potential controller improvements")
        print("4. Consider adding integration tests for real database scenarios")
        
        if self.run_performance:
            print("5. Monitor performance degradation in CI/CD pipeline")
            print("6. Set up performance benchmarks based on these results")


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description='Run comprehensive controller tests')
    parser.add_argument('--verbose', '-v', action='store_true', 
                       help='Verbose test output')
    parser.add_argument('--performance', '-p', action='store_true',
                       help='Include performance and stability tests')
    parser.add_argument('--coverage', '-c', action='store_true',
                       help='Generate coverage report (requires coverage.py)')
    parser.add_argument('--quick', '-q', action='store_true',
                       help='Run only basic tests, skip edge cases')
    
    args = parser.parse_args()
    
    # Set up coverage if requested
    if args.coverage:
        try:
            import coverage
            cov = coverage.Coverage()
            cov.start()
        except ImportError:
            print("Coverage.py not installed. Install with: pip install coverage")
            sys.exit(1)
    
    # Run tests
    verbosity = 2 if args.verbose else 1
    runner = ComprehensiveTestRunner(verbosity=verbosity, run_performance=args.performance)
    
    success = runner.run_all_tests()
    
    # Generate coverage report if requested
    if args.coverage:
        cov.stop()
        cov.save()
        
        print(f"\n{'='*60}")
        print("COVERAGE REPORT")
        print(f"{'='*60}")
        cov.report()
        cov.html_report(directory='htmlcov')
        print("HTML coverage report generated in 'htmlcov' directory")
    
    # Exit with appropriate code
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
