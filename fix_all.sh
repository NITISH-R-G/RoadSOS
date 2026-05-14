#!/bin/bash
dart fix --apply
# Fix empty_catches, avoid_print, etc. are informational or handled.
# But let's check for any remaining errors.
dart analyze > analysis.txt
