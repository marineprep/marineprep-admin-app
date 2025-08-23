-- Migration script to add topic_id column to questions table
-- Run this script on your existing database to add topic support

-- Add topic_id column to questions table
ALTER TABLE questions 
ADD COLUMN topic_id UUID REFERENCES topics(id) ON DELETE SET NULL;

-- Add index for better performance when filtering by topic
CREATE INDEX IF NOT EXISTS idx_questions_topic_id ON questions(topic_id);

-- Update existing questions to have NULL topic_id (they will be assigned to topics later)
-- This is safe as the column allows NULL values
