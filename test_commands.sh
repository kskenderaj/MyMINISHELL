#!/bin/bash

# Test script for MyMINISHELL
# This script tests if every command is working properly

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test results
print_result() {
    local test_name=$1
    local result=$2
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ $result -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Function to print section header
print_section() {
    echo ""
    echo -e "${YELLOW}=== $1 ===${NC}"
}

# Build the minishell
print_section "Building minishell"
make re > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Build successful"
else
    echo -e "${RED}✗${NC} Build failed"
    exit 1
fi

# Check if minishell binary exists
if [ ! -f "./minishell" ]; then
    echo -e "${RED}✗${NC} minishell binary not found"
    exit 1
fi

# Test 1: Test basic external commands
print_section "Testing External Commands"

# Test echo command
OUTPUT=$(echo "echo Hello World" | ./minishell 2>&1 | grep "Hello World")
if [ -n "$OUTPUT" ]; then
    print_result "echo command" 0
else
    print_result "echo command" 1
fi

# Test ls command
OUTPUT=$(echo "ls" | ./minishell 2>&1 | grep -E "(minishell|Makefile)")
if [ -n "$OUTPUT" ]; then
    print_result "ls command" 0
else
    print_result "ls command" 1
fi

# Test pwd command
OUTPUT=$(echo "pwd" | ./minishell 2>&1 | grep "/")
if [ -n "$OUTPUT" ]; then
    print_result "pwd command" 0
else
    print_result "pwd command" 1
fi

# Test date command
OUTPUT=$(echo "date" | ./minishell 2>&1 | grep -E "[0-9]{4}")
if [ -n "$OUTPUT" ]; then
    print_result "date command" 0
else
    print_result "date command" 1
fi

# Test whoami command
OUTPUT=$(echo "whoami" | ./minishell 2>&1)
if [ -n "$OUTPUT" ] && [ "$OUTPUT" != "minishell>" ]; then
    print_result "whoami command" 0
else
    print_result "whoami command" 1
fi

# Test 2: Test built-in commands
print_section "Testing Built-in Commands"

# Test env command
OUTPUT=$(echo "env" | ./minishell 2>&1 | grep -E "PATH=|HOME=")
if [ -n "$OUTPUT" ]; then
    print_result "env command" 0
else
    print_result "env command" 1
fi

# Test cd command - create a test directory
mkdir -p /tmp/minishell_test_dir
ORIGINAL_DIR=$(pwd)

# Test cd to /tmp
OUTPUT=$(echo -e "cd /tmp\npwd" | ./minishell 2>&1 | grep "/tmp")
if [ -n "$OUTPUT" ]; then
    print_result "cd command (absolute path)" 0
else
    print_result "cd command (absolute path)" 1
fi

# Test cd with relative path
cd /tmp
OUTPUT=$(echo -e "cd minishell_test_dir\npwd" | "$ORIGINAL_DIR/minishell" 2>&1 | grep "minishell_test_dir")
cd "$ORIGINAL_DIR"
if [ -n "$OUTPUT" ]; then
    print_result "cd command (relative path)" 0
else
    print_result "cd command (relative path)" 1
fi

# Cleanup
rm -rf /tmp/minishell_test_dir

# Test 3: Test command with arguments
print_section "Testing Commands with Arguments"

# Test echo with multiple arguments
OUTPUT=$(echo "echo one two three" | ./minishell 2>&1 | grep "one two three")
if [ -n "$OUTPUT" ]; then
    print_result "echo with multiple arguments" 0
else
    print_result "echo with multiple arguments" 1
fi

# Test ls with flags
OUTPUT=$(echo "ls -l" | ./minishell 2>&1 | grep -E "minishell|total")
if [ -n "$OUTPUT" ]; then
    print_result "ls with flags" 0
else
    print_result "ls with flags" 1
fi

# Test 4: Test error handling
print_section "Testing Error Handling"

# Test nonexistent command
OUTPUT=$(echo "nonexistentcommand12345" | ./minishell 2>&1 | grep -i "not found\|No such")
if [ -n "$OUTPUT" ]; then
    print_result "nonexistent command error" 0
else
    print_result "nonexistent command error" 1
fi

# Test cd with invalid directory
OUTPUT=$(echo "cd /nonexistent_directory_12345" | ./minishell 2>&1 | grep -i "No such")
if [ -n "$OUTPUT" ]; then
    print_result "cd error handling" 0
else
    print_result "cd error handling" 1
fi

# Test cd without arguments
OUTPUT=$(echo "cd" | ./minishell 2>&1 | grep -i "missing argument")
if [ -n "$OUTPUT" ]; then
    print_result "cd without arguments" 0
else
    print_result "cd without arguments" 1
fi

# Test 5: Test empty input
print_section "Testing Edge Cases"

# Test empty line (just press enter)
OUTPUT=$(echo "" | timeout 1 ./minishell 2>&1)
if [ $? -eq 0 ] || [ $? -eq 124 ]; then
    print_result "empty input handling" 0
else
    print_result "empty input handling" 1
fi

# Test whitespace only
OUTPUT=$(echo "   " | timeout 1 ./minishell 2>&1)
if [ $? -eq 0 ] || [ $? -eq 124 ]; then
    print_result "whitespace input handling" 0
else
    print_result "whitespace input handling" 1
fi

# Print summary
print_section "Test Summary"
echo "Total tests run: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
else
    echo -e "${GREEN}Failed: $TESTS_FAILED${NC}"
fi

echo ""
if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed! ✗${NC}"
    exit 1
fi
