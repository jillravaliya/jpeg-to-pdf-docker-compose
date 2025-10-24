# Supabase Database Management for JPEG to PDF Converter

This file contains all the necessary scripts and configurations to manage the Supabase database for the JPEG to PDF Converter application.

## Quick Setup

Run the setup script to configure everything:

```bash
chmod +x setup-supabase.sh
./setup-supabase.sh
```

## Manual Setup Steps

### 1. Install Supabase CLI

**macOS (with Homebrew):**
```bash
brew install supabase/tap/supabase
```

**Linux:**
```bash
curl -fsSL https://supabase.com/install.sh | sh
```

**Windows:**
```bash
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

### 2. Create Environment File

Create `.env` file in the root directory:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# Application Configuration
NODE_ENV=development
PORT=3000
```

### 3. Initialize Supabase Project

```bash
supabase init
```

### 4. Create Database Schema

Run this SQL in your Supabase SQL editor or create a migration:

```sql
-- Create conversions table
CREATE TABLE IF NOT EXISTS conversions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  filename TEXT NOT NULL,
  file_count INTEGER NOT NULL,
  compression_level TEXT NOT NULL CHECK (compression_level IN ('normal', 'compressed', 'ultra')),
  user_id TEXT DEFAULT 'anonymous',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_conversions_created_at ON conversions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_conversions_user_id ON conversions(user_id);

-- Enable Row Level Security (RLS)
ALTER TABLE conversions ENABLE ROW LEVEL SECURITY;

-- Create policy to allow anyone to insert conversions
CREATE POLICY "Allow anyone to insert conversions" ON conversions
  FOR INSERT WITH CHECK (true);

-- Create policy to allow anyone to read conversions
CREATE POLICY "Allow anyone to read conversions" ON conversions
  FOR SELECT USING (true);

-- Create a view for public statistics
CREATE OR REPLACE VIEW conversion_stats AS
SELECT 
  DATE(created_at) as date,
  COUNT(*) as total_conversions,
  SUM(file_count) as total_files,
  AVG(file_count) as avg_files_per_conversion
FROM conversions
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Grant access to the view
GRANT SELECT ON conversion_stats TO anon;
GRANT SELECT ON conversion_stats TO authenticated;
```

### 5. Add Sample Data (Optional)

```sql
-- Insert sample conversion data
INSERT INTO conversions (filename, file_count, compression_level, user_id, created_at) VALUES
('sample-document-1', 3, 'normal', 'demo-user', NOW() - INTERVAL '1 day'),
('sample-document-2', 5, 'compressed', 'demo-user', NOW() - INTERVAL '2 days'),
('sample-document-3', 2, 'ultra', 'demo-user', NOW() - INTERVAL '3 days'),
('sample-document-4', 4, 'normal', 'demo-user', NOW() - INTERVAL '4 days'),
('sample-document-5', 6, 'compressed', 'demo-user', NOW() - INTERVAL '5 days');
```

## Database Management Commands

### Local Development

```bash
# Start local Supabase instance
supabase start

# Stop local Supabase instance
supabase stop

# Reset database (applies all migrations)
supabase db reset

# View database in terminal
supabase db shell

# Generate TypeScript types
supabase gen types typescript --local > types/supabase.ts
```

### Production Management

```bash
# Link to remote project
supabase link --project-ref your-project-ref

# Push migrations to production
supabase db push

# Pull schema from production
supabase db pull

# Generate types from production
supabase gen types typescript --project-id your-project-id > types/supabase.ts
```

## Database Scripts

### Backup Script

Create `scripts/backup-database.sh`:

```bash
#!/bin/bash
BACKUP_DIR="database-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/conversions_backup_$TIMESTAMP.sql"

mkdir -p "$BACKUP_DIR"

echo "Creating database backup..."
supabase db dump --data-only --table conversions > "$BACKUP_FILE"

echo "Backup created: $BACKUP_FILE"
```

### Restore Script

Create `scripts/restore-database.sh`:

```bash
#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: $0 <backup-file>"
    echo "Available backups:"
    ls -la database-backups/
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "Restoring database from: $BACKUP_FILE"
supabase db reset
psql "$DATABASE_URL" < "$BACKUP_FILE"

echo "Database restored successfully"
```

### Statistics Script

Create `scripts/database-stats.sh`:

```bash
#!/bin/bash
echo "📊 Database Statistics"
echo "===================="

# Get total conversions
TOTAL_CONVERSIONS=$(supabase db shell --command "SELECT COUNT(*) FROM conversions;" | tail -n 1)
echo "Total Conversions: $TOTAL_CONVERSIONS"

# Get total files processed
TOTAL_FILES=$(supabase db shell --command "SELECT SUM(file_count) FROM conversions;" | tail -n 1)
echo "Total Files Processed: $TOTAL_FILES"

# Get compression level distribution
echo ""
echo "Compression Level Distribution:"
supabase db shell --command "SELECT compression_level, COUNT(*) as count FROM conversions GROUP BY compression_level ORDER BY count DESC;"

# Get recent activity
echo ""
echo "Recent Activity (Last 7 days):"
supabase db shell --command "SELECT DATE(created_at) as date, COUNT(*) as conversions FROM conversions WHERE created_at >= NOW() - INTERVAL '7 days' GROUP BY DATE(created_at) ORDER BY date DESC;"
```

## API Integration

### Backend Integration

The backend automatically logs conversions to the database:

```javascript
// In backend/app.js
const { data, error } = await supabase
  .from('conversions')
  .insert({
    filename: sanitizedFilename,
    file_count: req.files.length,
    compression_level: compressionLevel,
    user_id: req.headers['user-id'] || 'anonymous',
    created_at: new Date().toISOString()
  });
```

### Frontend Integration

The frontend displays conversion history:

```javascript
// In frontend/src/App.jsx
const loadConversions = async () => {
  try {
    const response = await fetch(`${API_URL}/conversions`);
    if (response.ok) {
      const data = await response.json();
      setConversions(data);
    }
  } catch (error) {
    console.error("Failed to load conversions:", error);
  }
};
```

## Monitoring and Analytics

### Key Metrics to Track

1. **Total Conversions**: Number of PDF conversions performed
2. **Files Processed**: Total number of images converted
3. **Compression Usage**: Distribution of compression levels
4. **User Activity**: Conversion patterns by user
5. **Performance**: Average files per conversion

### Useful Queries

```sql
-- Daily conversion trends
SELECT DATE(created_at) as date, COUNT(*) as conversions
FROM conversions
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Compression level popularity
SELECT compression_level, COUNT(*) as count
FROM conversions
GROUP BY compression_level
ORDER BY count DESC;

-- Average files per conversion
SELECT AVG(file_count) as avg_files
FROM conversions;

-- Peak usage hours
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as conversions
FROM conversions
GROUP BY EXTRACT(HOUR FROM created_at)
ORDER BY conversions DESC;
```

## Troubleshooting

### Common Issues

1. **Connection Failed**
   - Check SUPABASE_URL and SUPABASE_ANON_KEY
   - Verify network connectivity
   - Check if Supabase project is active

2. **Permission Denied**
   - Verify RLS policies are correct
   - Check if user has proper permissions
   - Ensure API keys are valid

3. **Migration Errors**
   - Check SQL syntax
   - Verify table doesn't already exist
   - Run migrations in correct order

### Debug Commands

```bash
# Check Supabase status
supabase status

# View logs
supabase logs

# Test connection
supabase db shell --command "SELECT version();"

# Check table structure
supabase db shell --command "\d conversions"
```

## Security Considerations

1. **Row Level Security**: Enabled on all tables
2. **API Keys**: Store securely, never commit to version control
3. **Public Access**: Limited to read/insert operations only
4. **Data Validation**: Input validation on all endpoints
5. **Rate Limiting**: Consider implementing rate limiting for production

## Production Deployment

1. **Environment Variables**: Set production Supabase credentials
2. **Database Migrations**: Run all migrations in production
3. **Monitoring**: Set up monitoring and alerting
4. **Backups**: Regular automated backups
5. **Scaling**: Monitor usage and scale as needed

## Support

For issues with:
- **Supabase**: Check [Supabase Documentation](https://supabase.com/docs)
- **Database**: Run `supabase db shell` for direct access
- **Application**: Check application logs and error messages
