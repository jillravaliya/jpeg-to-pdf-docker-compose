# Complete Supabase Database Setup for JPEG to PDF Converter

This document provides everything you need to set up and manage the Supabase database for your JPEG to PDF Converter application.

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)
```bash
# Run the automated setup script
chmod +x setup-supabase.sh
./setup-supabase.sh
```

### Option 2: Manual Setup
Follow the step-by-step instructions below.

## 📋 Prerequisites

1. **Supabase Account**: Sign up at [supabase.com](https://supabase.com)
2. **Supabase CLI**: Install the command-line interface
3. **Docker**: For running the application locally

## 🛠️ Manual Setup Steps

### Step 1: Install Supabase CLI

**macOS:**
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

### Step 2: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click "New Project"
3. Choose your organization
4. Enter project details:
   - **Name**: `jpeg-to-pdf-converter`
   - **Database Password**: Choose a strong password
   - **Region**: Choose closest to your users
5. Click "Create new project"
6. Wait for the project to be created (2-3 minutes)

### Step 3: Get Project Credentials

1. Go to your project dashboard
2. Navigate to **Settings** > **API**
3. Copy the following values:
   - **Project URL** (e.g., `https://abcdefghijklmnop.supabase.co`)
   - **anon public** key
   - **service_role** key (keep this secret!)

### Step 4: Create Environment File

Create a `.env` file in your project root:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# Application Configuration
NODE_ENV=development
PORT=3000
VITE_API_URL=http://localhost:3000
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

### Step 5: Set Up Database Schema

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Run the following SQL:

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

### Step 6: Add Sample Data (Optional)

```sql
-- Insert sample conversion data
INSERT INTO conversions (filename, file_count, compression_level, user_id, created_at) VALUES
('sample-document-1', 3, 'normal', 'demo-user', NOW() - INTERVAL '1 day'),
('sample-document-2', 5, 'compressed', 'demo-user', NOW() - INTERVAL '2 days'),
('sample-document-3', 2, 'ultra', 'demo-user', NOW() - INTERVAL '3 days'),
('sample-document-4', 4, 'normal', 'demo-user', NOW() - INTERVAL '4 days'),
('sample-document-5', 6, 'compressed', 'demo-user', NOW() - INTERVAL '5 days');
```

### Step 7: Test the Setup

```bash
# Build and run the application
docker-compose up --build

# Test the API endpoints
curl http://localhost:3000/health
curl http://localhost:3000/conversions
```

## 📊 Database Management

### Available Scripts

1. **Backup Database**:
   ```bash
   ./scripts/backup-database.sh
   ```

2. **Restore Database**:
   ```bash
   ./scripts/restore-database.sh <backup-file>
   ```

3. **View Statistics**:
   ```bash
   ./scripts/database-stats.sh
   ```

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
```

## 🔧 Configuration Files

### Files Created by Setup

1. **`setup-supabase.sh`** - Automated setup script
2. **`SUPABASE_SETUP.md`** - Detailed setup documentation
3. **`database-config.json`** - Database configuration
4. **`supabase-schema.sql`** - Database schema
5. **`scripts/`** - Database management scripts
   - `backup-database.sh` - Backup script
   - `restore-database.sh` - Restore script
   - `database-stats.sh` - Statistics script

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `SUPABASE_URL` | Your Supabase project URL | `https://abc123.supabase.co` |
| `SUPABASE_ANON_KEY` | Public API key | `eyJhbGciOiJIUzI1NiIs...` |
| `SUPABASE_SERVICE_ROLE_KEY` | Secret API key | `eyJhbGciOiJIUzI1NiIs...` |

## 🚀 Running the Application

### Development Mode
```bash
# Start with Docker Compose
docker-compose up --build

# Access the application
# Frontend: http://localhost:5173
# Backend: http://localhost:3000
```

### Production Mode
```bash
# Set production environment
export NODE_ENV=production

# Start the application
docker-compose up --build -d
```

## 📈 Monitoring and Analytics

### Key Metrics Tracked

1. **Total Conversions**: Number of PDF conversions
2. **Files Processed**: Total images converted
3. **Compression Usage**: Distribution of compression levels
4. **User Activity**: Conversion patterns
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

-- Peak usage hours
SELECT EXTRACT(HOUR FROM created_at) as hour, COUNT(*) as conversions
FROM conversions
GROUP BY EXTRACT(HOUR FROM created_at)
ORDER BY conversions DESC;
```

## 🔒 Security Features

1. **Row Level Security (RLS)**: Enabled on all tables
2. **Public Access**: Limited to read/insert operations
3. **API Key Protection**: Service role key kept secret
4. **Input Validation**: All inputs validated
5. **CORS Configuration**: Proper CORS setup

## 🆘 Troubleshooting

### Common Issues

1. **Connection Failed**
   - Check SUPABASE_URL and SUPABASE_ANON_KEY
   - Verify network connectivity
   - Check if Supabase project is active

2. **Permission Denied**
   - Verify RLS policies are correct
   - Check API key permissions
   - Ensure database schema is up to date

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

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase CLI Reference](https://supabase.com/docs/guides/cli)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)

## 🎉 Success!

Once everything is set up, you should have:

✅ A fully functional Supabase database  
✅ Automatic conversion logging  
✅ Conversion history display  
✅ Database management scripts  
✅ Production-ready configuration  
✅ Comprehensive monitoring  

Your JPEG to PDF Converter now has full database integration! 🚀
