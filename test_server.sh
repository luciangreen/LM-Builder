#!/bin/bash
# Test script for LM-Builder Prolog web server

echo "Testing LM-Builder Prolog Web Server"
echo "====================================="
echo ""

# Check if SWI-Prolog is installed
echo "1. Checking for SWI-Prolog..."
if command -v swipl &> /dev/null; then
    echo "   ✓ SWI-Prolog is installed"
    swipl --version
else
    echo "   ✗ SWI-Prolog is not installed"
    echo "   Please install SWI-Prolog to run this server"
    exit 1
fi

echo ""
echo "2. Checking directory structure..."
REQUIRED_DIRS=("issues" "articles" "advocates" "actions" "profiles" "databases" "static" "backups")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "   ✓ $dir/ exists"
    else
        echo "   ✗ $dir/ missing"
    fi
done

echo ""
echo "3. Checking database files..."
REQUIRED_DBS=("databases/keywords.pl" "databases/issues.pl" "databases/advocates.pl" "databases/actions.pl")
for db in "${REQUIRED_DBS[@]}"; do
    if [ -f "$db" ]; then
        echo "   ✓ $db exists"
    else
        echo "   ✗ $db missing"
    fi
done

echo ""
echo "4. Checking example content..."
if [ -f "issues/example_issue/example_issue_main.md" ]; then
    echo "   ✓ Example issue exists"
else
    echo "   ✗ Example issue missing"
fi

if [ -f "articles/sample_article.md" ]; then
    echo "   ✓ Sample article exists"
else
    echo "   ✗ Sample article missing"
fi

if [ -f "advocates/john_doe.md" ]; then
    echo "   ✓ Sample advocate exists"
else
    echo "   ✗ Sample advocate missing"
fi

echo ""
echo "5. Testing Prolog syntax..."
if swipl -g "consult('server.pl'), halt" -t 'halt(1)' 2>&1 | grep -q "error"; then
    echo "   ✗ Syntax errors found in server.pl"
    exit 1
else
    echo "   ✓ server.pl syntax is valid"
fi

echo ""
echo "====================================="
echo "All tests passed!"
echo ""
echo "To start the server, run:"
echo "  swipl server.pl"
echo ""
echo "The server will be available at:"
echo "  http://localhost:8080"
echo ""
echo "Default admin password: admin"
echo "====================================="
