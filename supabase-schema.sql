-- Supabase Database Schema for JPEG to PDF Converter
-- Run this SQL in your Supabase SQL editor

-- Create conversions table
CREATE TABLE IF NOT EXISTS conversions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  filename TEXT NOT NULL,
  file_count INTEGER NOT NULL,
  compression_level TEXT NOT NULL CHECK (compression_level IN ('normal', 'compressed', 'ultra')),
  user_id TEXT DEFAULT 'anonymous',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for better performance
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

-- Optional: Create a view for public statistics
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
