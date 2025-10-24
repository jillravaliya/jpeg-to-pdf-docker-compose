#!/bin/bash
# Database backup script for JPEG to PDF Converter

BACKUP_DIR="database-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/conversions_backup_$TIMESTAMP.sql"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📦 Creating database backup...${NC}"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Check if Supabase CLI is available
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI not found. Please install it first."
    exit 1
fi

# Create backup
if supabase db dump --data-only --table conversions > "$BACKUP_FILE" 2>/dev/null; then
    echo -e "${GREEN}✅ Backup created: $BACKUP_FILE${NC}"
    
    # Show backup file size
    FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "📊 Backup size: $FILE_SIZE"
    
    # List all backups
    echo ""
    echo "📋 All available backups:"
    ls -la "$BACKUP_DIR"/*.sql 2>/dev/null || echo "No previous backups found"
else
    echo "❌ Backup failed. Make sure Supabase is running and accessible."
    exit 1
fi
