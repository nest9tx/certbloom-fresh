#!/bin/bash

# 🌸 CertBloom Clean Slate Rebuild Execution Script
# This script executes the clean slate foundation rebuild

echo "🔄 Starting CertBloom Clean Slate Rebuild..."

# Check if bulletproof-clean-slate.sql exists
if [ ! -f "bulletproof-clean-slate.sql" ]; then
    echo "❌ Error: bulletproof-clean-slate.sql not found"
    exit 1
fi

echo "📋 Found bulletproof-clean-slate.sql"
echo "🎯 This will completely rebuild your database structure:"
echo "   - Drop existing problematic tables"
echo "   - Create clean table structure with proper foreign keys"
echo "   - Create Math 902 certification with exemplary content"

echo ""
read -p "⚠️  Are you sure you want to proceed? This will DELETE existing data (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Operation cancelled"
    exit 1
fi

echo "🚀 Proceeding with bulletproof clean slate rebuild..."
echo ""
echo "📝 Please copy and paste the contents of bulletproof-clean-slate.sql"
echo "   into your Supabase SQL Editor and run it."
echo ""
echo "🔍 The script includes verification queries that will show:"
echo "   - Check certifications: SELECT * FROM certifications WHERE test_code = '902';"
echo "   - Check domains: SELECT * FROM domains;"
echo "   - Check concepts: SELECT * FROM concepts;"
echo "   - Check content: SELECT * FROM content_items;"
echo "   - Check answers: SELECT * FROM answer_choices;"
echo ""
echo "✅ Once complete, your Math 902 practice sessions should work correctly!"

# Open the SQL file for easy copying
if command -v code &> /dev/null; then
    echo "📂 Opening bulletproof-clean-slate.sql in VS Code..."
    code bulletproof-clean-slate.sql
elif command -v cat &> /dev/null; then
    echo "📄 Displaying bulletproof-clean-slate.sql contents:"
    echo "=================================================="
    cat bulletproof-clean-slate.sql
fi
