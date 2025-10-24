#!/bin/bash
# Database statistics script for JPEG to PDF Converter

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}📊 Database Statistics${NC}"
echo "===================="

# Check if Supabase CLI is available
if ! command -v supabase &> /dev/null; then
    echo -e "${YELLOW}⚠️  Supabase CLI not found. Please install it first.${NC}"
    exit 1
fi

# Function to run SQL command
run_sql() {
    supabase db shell --command "$1" 2>/dev/null | tail -n +2 | head -n -1
}

echo -e "${GREEN}📈 Overall Statistics${NC}"
echo "-------------------"

# Get total conversions
TOTAL_CONVERSIONS=$(run_sql "SELECT COUNT(*) FROM conversions;")
echo "Total Conversions: $TOTAL_CONVERSIONS"

# Get total files processed
TOTAL_FILES=$(run_sql "SELECT COALESCE(SUM(file_count), 0) FROM conversions;")
echo "Total Files Processed: $TOTAL_FILES"

# Get average files per conversion
AVG_FILES=$(run_sql "SELECT ROUND(AVG(file_count), 2) FROM conversions;")
echo "Average Files per Conversion: $AVG_FILES"

echo ""
echo -e "${GREEN}🗜️  Compression Level Distribution${NC}"
echo "--------------------------------"
run_sql "SELECT compression_level, COUNT(*) as count FROM conversions GROUP BY compression_level ORDER BY count DESC;"

echo ""
echo -e "${GREEN}📅 Recent Activity (Last 7 days)${NC}"
echo "----------------------------"
run_sql "SELECT DATE(created_at) as date, COUNT(*) as conversions FROM conversions WHERE created_at >= NOW() - INTERVAL '7 days' GROUP BY DATE(created_at) ORDER BY date DESC;"

echo ""
echo -e "${GREEN}👥 User Activity${NC}"
echo "---------------"
run_sql "SELECT user_id, COUNT(*) as conversions FROM conversions GROUP BY user_id ORDER BY conversions DESC LIMIT 10;"

echo ""
echo -e "${GREEN}⏰ Peak Usage Hours${NC}"
echo "-------------------"
run_sql "SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as conversions FROM conversions GROUP BY EXTRACT(HOUR FROM created_at) ORDER BY conversions DESC LIMIT 5;"

echo ""
echo -e "${GREEN}📊 Daily Trends (Last 30 days)${NC}"
echo "-------------------------------"
run_sql "SELECT DATE(created_at) as date, COUNT(*) as conversions, SUM(file_count) as total_files FROM conversions WHERE created_at >= NOW() - INTERVAL '30 days' GROUP BY DATE(created_at) ORDER BY date DESC LIMIT 10;"

echo ""
echo -e "${BLUE}ℹ️  Database Info${NC}"
echo "---------------"
echo "Database: $(run_sql "SELECT current_database();")"
echo "Version: $(run_sql "SELECT version();" | head -n 1)"
echo "Last Updated: $(run_sql "SELECT MAX(created_at) FROM conversions;")"

echo ""
echo -e "${GREEN}✅ Statistics generated successfully!${NC}"
