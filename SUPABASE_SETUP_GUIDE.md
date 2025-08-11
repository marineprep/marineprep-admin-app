# Supabase Setup Guide for Marine Prep Admin

This guide will help you configure Supabase for authentication and storage access in your Marine Prep Admin application.

## 🔧 Required Supabase Configuration

### 1. Authentication Settings

#### Enable Email Authentication
1. Go to your Supabase Dashboard
2. Navigate to **Authentication** → **Providers**
3. Enable **Email** provider
4. Configure the following settings:
   - **Enable email confirmations**: `ON` (recommended for production)
   - **Enable secure email change**: `ON`
   - **Enable double confirm changes**: `OFF` (for development)
   - **Enable delete user**: `ON`

#### Email Templates (Optional)
1. Go to **Authentication** → **Email Templates**
2. Customize the following templates:
   - **Confirm signup**
   - **Reset password**
   - **Change email address**

### 2. Storage Buckets Configuration

#### Create Storage Buckets
Run these SQL commands in your Supabase SQL Editor:

```sql
-- Create videos bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'videos', 
  'videos', 
  true, 
  104857600, -- 100MB limit
  ARRAY['video/mp4', 'video/mov', 'video/avi', 'video/webm']
) ON CONFLICT (id) DO NOTHING;

-- Create notes bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'notes', 
  'notes', 
  true, 
  52428800, -- 50MB limit
  ARRAY['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
) ON CONFLICT (id) DO NOTHING;

-- Create images bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'images', 
  'images', 
  true, 
  10485760, -- 10MB limit
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
) ON CONFLICT (id) DO NOTHING;
```

#### Storage RLS (Row Level Security) Policies

**IMPORTANT**: Run these SQL commands in your Supabase SQL Editor to fix the file upload issue:

```sql
-- Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Authenticated users can upload files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can view files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete files" ON storage.objects;

-- Policy for authenticated users to upload files
CREATE POLICY "Authenticated users can upload files" ON storage.objects
FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy for authenticated users to view files
CREATE POLICY "Authenticated users can view files" ON storage.objects
FOR SELECT USING (auth.role() = 'authenticated');

-- Policy for authenticated users to update their files
CREATE POLICY "Authenticated users can update files" ON storage.objects
FOR UPDATE USING (auth.role() = 'authenticated');

-- Policy for authenticated users to delete their files
CREATE POLICY "Authenticated users can delete files" ON storage.objects
FOR DELETE USING (auth.role() = 'authenticated');

-- Alternative: If you want to allow all operations for authenticated users
-- CREATE POLICY "Allow all operations for authenticated users" ON storage.objects
-- FOR ALL USING (auth.role() = 'authenticated');
```

### 3. Database RLS Policies

#### Enable RLS on Tables
```sql
-- Enable RLS on all tables
ALTER TABLE exam_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE roadmap_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roadmap_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE practice_test_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE practice_test_answers ENABLE ROW LEVEL SECURITY;
```

#### Create RLS Policies for Admin Access
```sql
-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Authenticated users can access exam categories" ON exam_categories;
DROP POLICY IF EXISTS "Authenticated users can access subjects" ON subjects;
DROP POLICY IF EXISTS "Authenticated users can access topics" ON topics;
DROP POLICY IF EXISTS "Authenticated users can access questions" ON questions;
DROP POLICY IF EXISTS "Authenticated users can access roadmap steps" ON roadmap_steps;
DROP POLICY IF EXISTS "Users can access their own progress" ON user_roadmap_progress;
DROP POLICY IF EXISTS "Users can access their own practice sessions" ON practice_test_sessions;
DROP POLICY IF EXISTS "Users can access their own practice answers" ON practice_test_answers;

-- Policy for authenticated users to access exam categories
CREATE POLICY "Authenticated users can access exam categories" ON exam_categories
FOR ALL USING (auth.role() = 'authenticated');

-- Policy for authenticated users to access subjects
CREATE POLICY "Authenticated users can access subjects" ON subjects
FOR ALL USING (auth.role() = 'authenticated');

-- Policy for authenticated users to access topics
CREATE POLICY "Authenticated users can access topics" ON topics
FOR ALL USING (auth.role() = 'authenticated');

-- Policy for authenticated users to access questions
CREATE POLICY "Authenticated users can access questions" ON questions
FOR ALL USING (auth.role() = 'authenticated');

-- Policy for authenticated users to access roadmap steps
CREATE POLICY "Authenticated users can access roadmap steps" ON roadmap_steps
FOR ALL USING (auth.role() = 'authenticated');

-- Policy for authenticated users to access their own progress
CREATE POLICY "Users can access their own progress" ON user_roadmap_progress
FOR ALL USING (auth.uid()::text = user_id::text);

-- Policy for authenticated users to access practice test sessions
CREATE POLICY "Users can access their own practice sessions" ON practice_test_sessions
FOR ALL USING (auth.uid()::text = user_id::text);

-- Policy for authenticated users to access practice test answers
CREATE POLICY "Users can access their own practice answers" ON practice_test_answers
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM practice_test_sessions 
    WHERE practice_test_sessions.id = practice_test_answers.session_id 
    AND practice_test_sessions.user_id::text = auth.uid()::text
  )
);
```

### 4. Environment Variables

Make sure your Flutter app has the correct Supabase configuration in `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  // Update these with your actual Supabase project values
  static const String supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // ... rest of the constants
}
```

## 🚀 Testing the Setup

### 1. Test Authentication
1. Run your Flutter app
2. Navigate to the login page
3. Try creating a new account
4. Verify email confirmation (if enabled)
5. Test login functionality

### 2. Test Storage Access
1. Try uploading a video file in the topics section
2. Try uploading a document in the topics section
3. Verify files are accessible after upload

### 3. Test Database Access
1. Navigate to the subjects page
2. Try creating a new subject
3. Try creating a new topic with videos/notes
4. Verify all CRUD operations work

## 🔒 Security Considerations

### For Production
1. **Enable email confirmations** for new user registrations
2. **Set up proper email templates** with your branding
3. **Configure CORS settings** in Supabase dashboard
4. **Set up proper backup strategies** for your database
5. **Monitor authentication logs** for suspicious activity

### For Development
1. You can disable email confirmations for easier testing
2. Use test email addresses
3. Set up local development environment variables

## 🐛 Troubleshooting

### Common Issues

1. **"Storage bucket not found" error**
   - Make sure you've created the storage buckets using the SQL commands above
   - Verify bucket names match exactly: `videos`, `notes`, `images`

2. **"RLS policy violation" error**
   - Ensure RLS policies are created for all tables
   - Verify the user is authenticated before accessing data
   - **For storage uploads**: Make sure you've run the storage RLS policies above

3. **"Authentication failed" error**
   - Check your Supabase URL and anon key
   - Verify email authentication is enabled
   - Check if email confirmation is required

4. **"File upload failed" error**
   - Check file size limits in bucket configuration
   - Verify allowed MIME types
   - Ensure RLS policies allow file uploads
   - **Most common fix**: Run the storage RLS policies in section 2

### Debug Steps
1. Check browser console for detailed error messages
2. Verify Supabase dashboard logs
3. Test API calls directly in Supabase dashboard
4. Check authentication state in your app

## 📞 Support

If you encounter issues:
1. Check the [Supabase documentation](https://supabase.com/docs)
2. Review the [Flutter Supabase documentation](https://supabase.com/docs/reference/dart)
3. Check the app logs for detailed error messages
4. Verify all configuration steps are completed

## ✅ Checklist

- [ ] Email authentication enabled
- [ ] Storage buckets created
- [ ] Storage RLS policies configured (IMPORTANT for file uploads)
- [ ] Database RLS policies configured
- [ ] Environment variables set
- [ ] Authentication tested
- [ ] Storage access tested
- [ ] Database access tested
- [ ] Security settings reviewed
