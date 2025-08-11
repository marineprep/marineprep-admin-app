-- Comprehensive Fix for Storage RLS Policy Issue
-- Run this in your Supabase SQL Editor to fix the file upload problem

-- Step 1: Ensure the buckets exist with correct configuration
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('videos', 'videos', true, 104857600, ARRAY['video/mp4', 'video/mov', 'video/avi', 'video/webm', 'video/quicktime']),
  ('notes', 'notes', true, 52428800, ARRAY['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'text/plain']),
  ('images', 'images', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Step 2: Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Step 3: Drop ALL existing policies to start fresh
DROP POLICY IF EXISTS "Allow authenticated users to upload files" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to view files" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to update files" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to delete files" ON storage.objects;
DROP POLICY IF EXISTS "Allow all operations for authenticated users" ON storage.objects;
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can view files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete files" ON storage.objects;

-- Step 4: Create comprehensive policies for all operations
-- Policy for INSERT (uploading files)
CREATE POLICY "Allow authenticated users to upload files" ON storage.objects
FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy for SELECT (viewing files)
CREATE POLICY "Allow authenticated users to view files" ON storage.objects
FOR SELECT USING (auth.role() = 'authenticated');

-- Policy for UPDATE (updating files)
CREATE POLICY "Allow authenticated users to update files" ON storage.objects
FOR UPDATE USING (auth.role() = 'authenticated');

-- Policy for DELETE (deleting files)
CREATE POLICY "Allow authenticated users to delete files" ON storage.objects
FOR DELETE USING (auth.role() = 'authenticated');

-- Step 5: Alternative comprehensive policy (if the above doesn't work)
-- Uncomment the following if the individual policies don't work:
-- DROP POLICY IF EXISTS "Allow all operations for authenticated users" ON storage.objects;
-- CREATE POLICY "Allow all operations for authenticated users" ON storage.objects
-- FOR ALL USING (auth.role() = 'authenticated');

-- Step 6: Verify the policies were created
-- You can run this query to check if policies exist:
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check 
-- FROM pg_policies 
-- WHERE tablename = 'objects' AND schemaname = 'storage';

-- Step 7: Test the configuration
-- Try uploading a small test file to verify the policies work
