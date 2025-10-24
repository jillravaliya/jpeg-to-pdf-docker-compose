#!/bin/bash
# Database restore script for JPEG to PDF Converter

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Database Restore Script${NC}"
echo "=========================="

if [ -z "$1" ]; then
    echo -e "${YELLOW}⚠️  Usage: $0 <backup-file>${NC}"
    echo ""
    echo "Available backups:"
    if [ -d "database-backups" ]; then
        ls -la database-backups/*.sql 2>/dev/null || echo "No backups found in database-backups/"
    else
        echo "No backup directory found"
    fi
    exit 1
fi

BACKUP_FILE="$1"

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}❌ Backup file not found: $BACKUP_FILE${NC}"
    exit 1
fi

# Check if Supabase CLI is available
if ! command -v supabase &> /dev/null; then
    echo -e "${RED}❌ Supabase CLI not found. Please install it first.${NC}"
    exit 1
fi

echo -e "${YELLOW}⚠️  WARNING: This will reset your database and restore from backup!${NC}"
echo "Backup file: $BACKUP_FILE"
echo ""
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restore cancelled."
    exit 0
fi

echo -e "${BLUE}🔄 Restoring database from: $BACKUP_FILE${NC}"

# Reset database
if supabase db reset --yes; then
    echo -e "${GREEN}✅ Database reset successful${NC}"
else
    echo -e "${RED}❌ Database reset failed${NC}"
    exit 1
fi

# Restore from backup
if psql "$DATABASE_URL" < "$BACKUP_FILE" 2>/dev/null || supabase db shell < "$BACKUP_FILE" 2>/dev/null; then
    echo -e "${GREEN}✅ Database restored successfully${NC}"
    
    # Verify restore
    echo "🔍 Verifying restore..."
    CONVERSION_COUNT=$(supabase db shell --command "SELECT COUNT(*) FROM conversions;" 2>/dev/null | tail -n 1)
    if [ ! -z "$CONVERSION_COUNT" ]; then
        echo "📊 Conversions restored: $CONVERSION_COUNT"
    fi
else
    echo -e "${RED}❌ Database restore failed${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Restore completed successfully!${NC}"
