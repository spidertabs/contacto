#!/bin/bash
# run_tests.sh — runs all Contacto tests
# Usage: bash run_tests.sh

set -e

echo ""
echo "================================================"
echo "  Contacto Test Suite"
echo "================================================"

echo ""
echo "[ 1/3 ] Unit tests — Contact model"
flutter test test/unit/contact_model_test.dart --reporter expanded

echo ""
echo "[ 2/3 ] Unit tests — Validation logic"
flutter test test/unit/validation_test.dart --reporter expanded

echo ""
echo "[ 3/3 ] Unit tests — DatabaseHelper (in-memory SQLite)"
flutter test test/unit/database_helper_test.dart --reporter expanded

echo ""
echo "[ + ] Widget tests"
flutter test test/widget/widget_test.dart --reporter expanded

echo ""
echo "================================================"
echo "  All unit + widget tests passed."
echo "================================================"
echo ""
echo "To run integration tests on a physical device:"
echo "  flutter test integration_test/app_test.dart"
echo ""
