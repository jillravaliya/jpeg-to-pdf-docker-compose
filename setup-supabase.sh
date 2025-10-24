#!/bin/bash

# Supabase Database Setup Script for JPEG to PDF Converter
# This script handles all Supabase database operations

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENV_FILE=".env"
EXAMPLE_ENV_FILE=".env.example"
SCHEMA_FILE="supabase-schema.sql"
BACKUP_DIR="database-backups"

echo -e "${BLUE}🚀 Supabase Database Setup for JPEG to PDF Converter${NC}"
echo "=================================================="

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if Supabase CLI is installed
check_supabase_cli() {
    if ! command -v supabase &> /dev/null; then
        print_warning "Supabase CLI not found. Installing..."
        
        # Detect OS and install accordingly
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            if command -v brew &> /dev/null; then
                brew install supabase/tap/supabase
            else
                print_error "Homebrew not found. Please install Supabase CLI manually:"
                print_info "Visit: https://supabase.com/docs/guides/cli/getting-started"
                exit 1
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            curl -fsSL https://supabase.com/install.sh | sh
        else
            print_error "Unsupported OS. Please install Supabase CLI manually:"
            print_info "Visit: https://supabase.com/docs/guides/cli/getting-started"
            exit 1
        fi
        
        print_status "Supabase CLI installed successfully"
    else
        print_status "Supabase CLI is already installed"
    fi
}

# Create environment file
create_env_file() {
    if [ ! -f "$ENV_FILE" ]; then
        print_info "Creating environment file..."
        
        cat > "$ENV_FILE" << EOF
# Supabase Configuration
# Get these values from your Supabase project dashboard
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# Optional: For admin operations
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# Application Configuration
NODE_ENV=development
PORT=3000
EOF
        
        print_status "Environment file created: $ENV_FILE"
        print_warning "Please update $ENV_FILE with your actual Supabase credentials"
    else
        print_status "Environment file already exists: $ENV_FILE"
    fi
}

# Create example environment file
create_example_env() {
    if [ ! -f "$EXAMPLE_ENV_FILE" ]; then
        print_info "Creating example environment file..."
        
        cat > "$EXAMPLE_ENV_FILE" << EOF
# Supabase Configuration
# Get these values from your Supabase project dashboard
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# Optional: For admin operations
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# Application Configuration
NODE_ENV=development
PORT=3000
EOF
        
        print_status "Example environment file created: $EXAMPLE_ENV_FILE"
    else
        print_status "Example environment file already exists: $EXAMPLE_ENV_FILE"
    fi
}

# Initialize Supabase project
init_supabase_project() {
    if [ ! -d "supabase" ]; then
        print_info "Initializing Supabase project..."
        supabase init
        print_status "Supabase project initialized"
    else
        print_status "Supabase project already initialized"
    fi
}

# Create database schema
create_database_schema() {
    print_info "Creating database schema..."
    
    # Create migrations directory if it doesn't exist
    mkdir -p supabase/migrations
    
    # Create the initial migration
    cat > supabase/migrations/$(date +%Y%m%d%H%M%S)_create_conversions_table.sql << 'EOF'
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
EOF
    
    print_status "Database schema created in migrations"
}

# Create seed data
create_seed_data() {
    print_info "Creating seed data..."
    
    mkdir -p supabase/seed
    
    cat > supabase/seed/seed_conversions.sql << 'EOF'
-- Insert sample conversion data
INSERT INTO conversions (filename, file_count, compression_level, user_id, created_at) VALUES
('sample-document-1', 3, 'normal', 'demo-user', NOW() - INTERVAL '1 day'),
('sample-document-2', 5, 'compressed', 'demo-user', NOW() - INTERVAL '2 days'),
('sample-document-3', 2, 'ultra', 'demo-user', NOW() - INTERVAL '3 days'),
('sample-document-4', 4, 'normal', 'demo-user', NOW() - INTERVAL '4 days'),
('sample-document-5', 6, 'compressed', 'demo-user', NOW() - INTERVAL '5 days');
EOF
    
    print_status "Seed data created"
}

# Create database management scripts
create_db_scripts() {
    print_info "Creating database management scripts..."
    
    # Create backup script
    cat > scripts/backup-database.sh << 'EOF'
#!/bin/bash
# Database backup script

BACKUP_DIR="database-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/conversions_backup_$TIMESTAMP.sql"

mkdir -p "$BACKUP_DIR"

echo "Creating database backup..."
supabase db dump --data-only --table conversions > "$BACKUP_FILE"

echo "Backup created: $BACKUP_FILE"
EOF
    
    # Create restore script
    cat > scripts/restore-database.sh << 'EOF'
#!/bin/bash
# Database restore script

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
EOF
    
    # Create stats script
    cat > scripts/database-stats.sh << 'EOF'
#!/bin/bash
# Database statistics script

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
EOF
    
    # Make scripts executable
    chmod +x scripts/*.sh
    
    print_status "Database management scripts created"
}

# Create database configuration
create_db_config() {
    print_info "Creating database configuration..."
    
    cat > supabase/config.toml << 'EOF'
# A string used to distinguish different Supabase projects on the same host. Defaults to the
# working directory name when running `supabase init`.
project_id = "jpeg-to-pdf-converter"

[api]
enabled = true
# Port to use for the API URL.
port = 54321
# Schemas to expose in your API. Tables, views and stored procedures in this schema will get API endpoints.
# public and storage are always included.
schemas = ["public", "storage", "graphql_public"]
# Extra schemas to add to the search_path of every request. public is always included.
extra_search_path = ["public", "extensions"]
# The maximum number of rows returned from a table or view. Limits payload size
# for accidental or malicious requests.
max_rows = 1000

[db]
# Port to use for the local database URL.
port = 54322
# Port used by db diff command to initialize the shadow database.
shadow_port = 54320
# The database major version to use. This has to be the same as your remote database's. Run `SHOW server_version;` on the remote database to check.
major_version = 15

[db.pooler]
enabled = false
# Port to use for the local connection pooler.
port = 54329
# Specifies when a server connection can be reused by other clients.
# Configure one of the supported pooler modes: `transaction`, `session`.
pool_mode = "transaction"
# How many server connections to allow per user/database pair.
default_pool_size = 15
# Maximum number of client connections allowed.
max_client_conn = 100

[realtime]
enabled = true
# Bind realtime via either IPv4 or IPv6. (default: IPv6)
# ip_version = "IPv6"

[studio]
enabled = true
# Port to use for Supabase Studio.
port = 54323
# External URL of the API server that frontend connects to.
api_url = "http://localhost:54321"

# Email testing server. Emails sent with the local dev setup are not actually sent - rather, they
# are monitored, and you can view the emails that would have been sent from the web interface.
[inbucket]
enabled = true
# Port to use for the email testing server web interface.
port = 54324
# Uncomment to expose additional ports for testing user applications that send emails.
# smtp_port = 54325
# pop3_port = 54326

[storage]
enabled = true
# The maximum file size allowed (e.g. "5MB", "500KB").
file_size_limit = "50MiB"

[auth]
enabled = true
# The base URL of your website. Used as an allow-list for redirects and for constructing URLs used
# in emails.
site_url = "http://localhost:3000"
# A list of *exact* URLs that auth providers are permitted to redirect to post authentication.
additional_redirect_urls = ["https://localhost:3000"]
# How long tokens are valid for, in seconds. Defaults to 3600 (1 hour), maximum 604800 (1 week).
jwt_expiry = 3600
# If disabled, the refresh token will never expire.
enable_refresh_token_rotation = true
# Allows refresh tokens to be reused after expiry, up to the specified interval in seconds.
# Requires enable_refresh_token_rotation = true.
refresh_token_reuse_interval = 10
# Allow/disallow new user signups to your project.
enable_signup = true

[auth.email]
# Allow/disallow new user signups via email to your project.
enable_signup = true
# If enabled, a user will be required to confirm any email change on both the old, and new email addresses. If disabled, only the new email is required to confirm.
double_confirm_changes = true
# If enabled, users need to confirm their email address before signing in.
enable_confirmations = false

# Uncomment to customize email template
# [auth.email.template.invite]
# subject = "You have been invited"
# content_path = "./supabase/templates/invite.html"

[auth.sms]
# Allow/disallow new user signups via SMS to your project.
enable_signup = true
# If enabled, users need to confirm their phone number before signing in.
enable_confirmations = false

# Configure one of the supported SMS providers: `twilio`, `messagebird`, `textlocal`, `vonage`.
[auth.sms.twilio]
enabled = false
account_sid = ""
message_service_sid = ""
# DO NOT commit your Twilio auth token to git. Use environment variable substitution instead:
auth_token = "env(SUPABASE_AUTH_SMS_TWILIO_AUTH_TOKEN)"

# Use pre-defined map of phone number to OTP for testing.
[auth.sms.test_otp]
# 4152127777 = "123456"

# Configure one of the supported captcha providers: `hcaptcha`, `turnstile`.
[auth.captcha]
enabled = false
provider = "hcaptcha"
secret = "env(SUPABASE_AUTH_CAPTCHA_SECRET)"

# Use an external OAuth provider. The full list of providers are: `apple`, `azure`, `bitbucket`,
# `discord`, `facebook`, `github`, `gitlab`, `google`, `keycloak`, `linkedin`, `notion`, `twitch`,
# `twitter`, `slack`, `spotify`, `workos`, `zoom`.
[auth.external.apple]
enabled = false
client_id = ""
secret = "env(SUPABASE_AUTH_EXTERNAL_APPLE_SECRET)"
# Overrides the default auth redirectUrl.
redirect_uri = ""
# Overrides the default auth provider URL. Used to support self-hosted gitlab, single-tenant Azure,
# or any other third-party OIDC providers.
url = ""

[auth.external.azure]
enabled = false
client_id = ""
secret = "env(SUPABASE_AUTH_EXTERNAL_AZURE_SECRET)"
redirect_uri = ""
url = ""

[auth.external.bitbucket]
enabled = false
client_id = ""
secret = "env(SUPABASE_AUTH_EXTERNAL_BITBUCKET_SECRET)"
redirect_uri = ""
url = ""

[auth.external.discord]
enabled = false
client_id = ""
secret = "env(SUPABASE_AUTH_EXTERNAL_DISCORD_SECRET)"
redirect_uri = ""
url = ""

[auth.external.facebook]
enabled = false
client_id = ""
secret = "env(SUPABASE_AUTH_EXTERNAL_FACEBOOK_SECRET)"
redirect_uri = ""
url = ""

[auth.external.github]
enabled = false
client_id = ""
secret = "env(SUPABASE_AUTH_EXTERNAL_GITHUB_SECRET)"
redirect_uri = ""
url = ""

[auth.external.gitlab]
enabled = false
client_id = ""
secret = "env(SUPABASE_AUTH_EXTERNAL_GITLAB_SECRET)"
redirect_uri = ""
url = ""

[auth.external.google]
enabled = false
client_id = ""
secret = "env(SUPABASE_AUTH_EXTERNAL_GOOGLE_SECRET)"
redirect_uri = ""
url = ""

[auth.external.keycloak]
enabled = false
client_id = ""
secret = "env(SUPABASE_AUTH_EXTERNAL_KEYCLOAK_SECRET)"
redirect_uri = ""
url = ""

[auth.external.linkedin]
enabled = false
client_id = ""
secret = "env(SUPABASE_AUTH_EXTERNAL_LINKEDIN_SECRET)"
redirect_uri = ""
url = ""

[auth.external.notion]
enabled = false
client_id = ""
secret = "env(SUPABASE_AUTH_EXTERNAL_NOTION_SECRET)"
redirect_uri = ""
url = ""

[auth.external.twitch]
enabled = false
client_id = ""
secret = "env(SUPABASE_AUTH_EXTERNAL_TWITCH_SECRET)"
redirect_uri = ""
url = ""

[auth.external.twitter]
enabled = false
client_id = ""
secret = "env(SUPABASE_AUTH_EXTERNAL_TWITTER_SECRET)"
redirect_uri = ""
url = ""

[auth.external.slack]
enabled = false
client_id = ""
secret = "env(SUPABASE_AUTH_EXTERNAL_SLACK_SECRET)"
redirect_uri = ""
url = ""

[auth.external.spotify]
enabled = false
client_id = ""
secret = "env(SUPABASE_AUTH_EXTERNAL_SPOTIFY_SECRET)"
redirect_uri = ""
url = ""

[auth.external.workos]
enabled = false
client_id = ""
secret = "env(SUPABASE_AUTH_EXTERNAL_WORKOS_SECRET)"
redirect_uri = ""
url = ""

[auth.external.zoom]
enabled = false
client_id = ""
secret = "env(SUPABASE_AUTH_EXTERNAL_ZOOM_SECRET)"
redirect_uri = ""
url = ""

[analytics]
enabled = false
port = 54327
vector_port = 54328
# Configure one of the supported backends: `postgres`, `bigquery`.
backend = "postgres"
EOF
    
    print_status "Database configuration created"
}

# Create database documentation
create_db_docs() {
    print_info "Creating database documentation..."
    
    cat > DATABASE.md << 'EOF'
# Database Documentation

## Overview
This project uses Supabase as the database backend for storing conversion history and statistics.

## Schema

### Tables

#### `conversions`
Stores information about each PDF conversion.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key (auto-generated) |
| `filename` | TEXT | Name of the generated PDF file |
| `file_count` | INTEGER | Number of images converted |
| `compression_level` | TEXT | Compression level used ('normal', 'compressed', 'ultra') |
| `user_id` | TEXT | User identifier (defaults to 'anonymous') |
| `created_at` | TIMESTAMP | When the conversion was performed |

#### `conversion_stats` (View)
Aggregated statistics by date.

| Column | Type | Description |
|--------|------|-------------|
| `date` | DATE | Date of conversions |
| `total_conversions` | INTEGER | Number of conversions on this date |
| `total_files` | INTEGER | Total files processed on this date |
| `avg_files_per_conversion` | DECIMAL | Average files per conversion |

## Security

- **Row Level Security (RLS)** is enabled on the `conversions` table
- **Public Access**: Anyone can read and insert conversions
- **No Authentication Required**: The application works without user authentication

## API Endpoints

### Backend API
- `GET /conversions` - Get conversion history
- `POST /conversions` - Log a new conversion
- `GET /health` - Health check

### Database Queries

#### Get Recent Conversions
```sql
SELECT * FROM conversions 
ORDER BY created_at DESC 
LIMIT 10;
```

#### Get Conversion Statistics
```sql
SELECT * FROM conversion_stats 
ORDER BY date DESC 
LIMIT 30;
```

#### Get Compression Level Distribution
```sql
SELECT compression_level, COUNT(*) as count 
FROM conversions 
GROUP BY compression_level;
```

## Management Scripts

### Backup Database
```bash
./scripts/backup-database.sh
```

### Restore Database
```bash
./scripts/restore-database.sh <backup-file>
```

### View Statistics
```bash
./scripts/database-stats.sh
```

## Local Development

### Start Local Supabase
```bash
supabase start
```

### Stop Local Supabase
```bash
supabase stop
```

### Reset Database
```bash
supabase db reset
```

### View Database
```bash
supabase db shell
```

## Production Deployment

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Run the schema migration in the SQL editor
3. Update environment variables with production credentials
4. Deploy your application

## Environment Variables

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
```
EOF
    
    print_status "Database documentation created: DATABASE.md"
}

# Main execution
main() {
    print_info "Starting Supabase database setup..."
    
    # Create necessary directories
    mkdir -p scripts
    mkdir -p "$BACKUP_DIR"
    
    # Run setup steps
    check_supabase_cli
    create_env_file
    create_example_env
    init_supabase_project
    create_database_schema
    create_seed_data
    create_db_scripts
    create_db_config
    create_db_docs
    
    print_status "Supabase database setup completed!"
    
    echo ""
    print_info "Next steps:"
    echo "1. Update $ENV_FILE with your Supabase credentials"
    echo "2. Run 'supabase start' to start local development"
    echo "3. Run 'supabase db reset' to apply migrations"
    echo "4. Run 'docker-compose up --build' to start the application"
    echo ""
    print_info "Useful commands:"
    echo "- View database: supabase db shell"
    echo "- Backup database: ./scripts/backup-database.sh"
    echo "- View stats: ./scripts/database-stats.sh"
    echo "- Stop Supabase: supabase stop"
}

# Run main function
main "$@"
