# Manual Storage Setup Guide

Since the SQL approach might not work due to permission restrictions, here's how to configure storage policies manually through the Supabase dashboard.

## 🔧 Manual Storage Configuration

### Step 1: Create Storage Buckets

1. Go to your **Supabase Dashboard**
2. Navigate to **Storage** in the left sidebar
3. Click **"New bucket"** and create the following buckets:

#### Videos Bucket
- **Name**: `videos`
- **Public bucket**: ✅ **Checked**
- **File size limit**: `104857600` (100MB)
- **Allowed MIME types**: 
  - `video/mp4`
  - `video/mov`
  - `video/avi`
  - `video/webm`
  - `video/quicktime`

#### Notes Bucket
- **Name**: `notes`
- **Public bucket**: ✅ **Checked**
- **File size limit**: `52428800` (50MB)
- **Allowed MIME types**:
  - `application/pdf`
  - `application/msword`
  - `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
  - `text/plain`

#### Images Bucket
- **Name**: `images`
- **Public bucket**: ✅ **Checked**
- **File size limit**: `10485760` (10MB)
- **Allowed MIME types**:
  - `image/jpeg`
  - `image/png`
  - `image/gif`
  - `image/webp`

### Step 2: Configure Storage Policies

For each bucket you created, follow these steps:

1. Click on the bucket name (e.g., `videos`)
2. Go to the **"Policies"** tab
3. **Delete any existing policies** first
4. Click **"New Policy"**
5. Choose **"Create a policy from scratch"**
6. Configure the policy as follows:

#### Policy Name
```
Allow authenticated users full access
```

#### Target roles
```
authenticated
```

#### Policy definition
```sql
true
```

#### Operations
- ✅ **SELECT** (for viewing files)
- ✅ **INSERT** (for uploading files)
- ✅ **UPDATE** (for updating files)
- ✅ **DELETE** (for deleting files)

7. Click **"Review"** and then **"Save policy"**

### Step 3: Repeat for All Buckets

Repeat the policy configuration for:
- `notes` bucket
- `images` bucket

### Step 4: Alternative - Disable RLS (Development Only)

If you're still having issues, you can temporarily disable RLS for development:

1. Go to **Storage** → **Settings**
2. Find **"Row Level Security (RLS)"**
3. Toggle it **OFF** for development
4. **⚠️ Remember to enable it back for production**

## 🧪 Testing the Configuration

After setting up the policies:

1. **Sign in** to your app
2. **Try uploading a video file** in the add topic dialog
3. **Try uploading a notes file** in the add topic dialog
4. **Check the browser console** for any errors
5. **Verify the file appears** in your Supabase Storage dashboard

## 🔍 Troubleshooting

### If you still get RLS errors:

1. **Check authentication status**:
   ```dart
   // Add this debug code temporarily
   final user = SupabaseConfig.client.auth.currentUser;
   print('Current user: ${user?.email}');
   print('Is authenticated: ${user != null}');
   ```

2. **Verify bucket names** match exactly:
   - `videos` (not `video`)
   - `notes` (not `note`)
   - `images` (not `image`)

3. **Check file size limits**:
   - Videos: 100MB max
   - Notes: 50MB max
   - Images: 10MB max

4. **Verify MIME types** are allowed for your file

5. **Check if policies were created correctly**:
   - Go to Storage → [Bucket Name] → Policies
   - You should see the policy listed
   - Make sure it has all 4 operations enabled

### Alternative Debug Approach

Add this temporary debug code to your `add_topic_dialog.dart`:

```dart
// Add this before the upload attempt
final user = ref.read(authNotifierProvider).value;
print('Auth state: ${ref.read(authNotifierProvider)}');
print('Current user: ${user?.email}');

// Test storage access
try {
  final testResponse = await SupabaseConfig.client.storage
      .from('videos')
      .list();
  print('Storage access test successful: ${testResponse.length} files');
} catch (e) {
  print('Storage access test failed: $e');
}
```

## 🚀 Production Considerations

For production, make sure to:

1. **Enable RLS** on all storage buckets
2. **Use specific policies** instead of `true` for better security
3. **Monitor storage usage** and costs
4. **Set up proper backup strategies**
5. **Configure CORS settings** if needed

## 📞 Support

If you continue to have issues:

1. Check the [Supabase Storage documentation](https://supabase.com/docs/guides/storage)
2. Verify your Supabase project settings
3. Check the browser network tab for detailed error responses
4. Review the Supabase dashboard logs
5. Try the SQL script approach if manual setup doesn't work

## 🔧 Quick Fix Commands

If you have SQL access, run this in your Supabase SQL Editor:

```sql
-- Quick fix: Disable RLS temporarily for testing
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

-- Or enable with a simple policy
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all authenticated users" ON storage.objects FOR ALL USING (auth.role() = 'authenticated');
```
