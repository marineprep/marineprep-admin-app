# Marine Prep Admin - Setup Instructions

This is a Flutter web application for managing marine exam preparation content, specifically designed for IMUCET and other marine examinations.

## 🚀 Quick Start

### Prerequisites

- Flutter 3.8.1 or higher
- Dart SDK
- A Supabase account

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Set up Supabase

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to Settings > API to get your project URL and anon key
3. Update the constants in `lib/core/constants/app_constants.dart`:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 3. Set up Database

1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Copy and paste the contents of `database_schema.sql`
4. Run the script to create all tables and initial data

### 4. Set up Storage Buckets

In your Supabase dashboard, go to Storage and create these buckets:

- `videos` (public) - for video uploads
- `notes` (public) - for document uploads  
- `images` (public) - for question images

### 5. Generate Code

Run the code generation for models:

```bash
flutter packages pub run build_runner build
```

### 6. Run the Application

```bash
flutter run -d chrome
```

## 🏗️ Architecture

The application follows clean architecture principles:

```
lib/
├── core/
│   ├── constants/     # App constants
│   ├── config/        # Configuration files
│   ├── theme/         # App theme and styling
│   └── router/        # App routing
├── features/
│   ├── dashboard/     # Dashboard functionality
│   ├── subjects/      # Subject management
│   ├── questions/     # Question bank & practice tests
│   ├── roadmap/       # Learning roadmap
│   └── shared/        # Shared widgets and models
```

## 📊 Database Schema

The database is designed to be scalable and supports:

- **Multiple Exam Categories** (IMUCET, DECK, ENGINE, etc.)
- **Subjects** with hierarchical topics
- **File Storage** for videos and documents
- **Question Management** with images and explanations
- **Learning Roadmap** (static and dynamic)
- **User Progress Tracking**

### Key Tables:

- `exam_categories` - Different types of exams
- `subjects` - Subjects within each exam category
- `topics` - Topics with video and notes
- `questions` - Questions for both question bank and practice tests
- `roadmap_steps` - Learning roadmap configuration
- `user_roadmap_progress` - Individual user progress

## 🎨 Features

### ✅ Completed Features

- **Dashboard** with overview and quick actions
- **Subject Management** with topics, videos, and notes upload
- **Question Bank** with rich question creation (text + images)
- **Practice Test** management (similar to question bank)
- **Roadmap** configuration with static/dynamic options
- **Modern UI** with responsive design
- **File Upload** support for videos, documents, and images

### 📋 Admin Capabilities

- Add/edit/delete subjects dynamically
- Upload videos and notes for each topic
- Create questions with multiple choice answers
- Add images to questions and explanations
- Configure learning roadmap steps
- Manage different difficulty levels
- Control content visibility (active/inactive)

## 🔧 Technologies Used

- **Flutter** 3.8.1+ for web UI
- **Riverpod** for state management
- **Supabase** for backend and database
- **Go Router** for navigation
- **Google Fonts** for typography
- **Form Builder** for form handling
- **File Picker** for file uploads

## 🎯 Next Steps

To make this production-ready:

1. **Add Authentication** - implement admin login
2. **Connect to Supabase** - replace mock data with real API calls
3. **File Upload Integration** - implement actual file upload to Supabase Storage
4. **Data Validation** - add server-side validation
5. **Error Handling** - implement comprehensive error handling
6. **Testing** - add unit and integration tests
7. **Performance Optimization** - add caching and pagination

## 🚦 Environment Setup

For different environments, you can create separate constant files:

- `app_constants_dev.dart` for development
- `app_constants_prod.dart` for production

## 📱 Responsive Design

The application is optimized for web but can be adapted for:
- Desktop applications
- Tablet interfaces
- Mobile web browsers

## 🔐 Security Considerations

- Implement Row Level Security (RLS) in Supabase
- Add proper authentication and authorization
- Validate file uploads and types
- Sanitize user inputs
- Implement rate limiting

## 📈 Scalability

The database schema supports:
- Multiple exam categories
- Unlimited subjects and topics
- Large question banks
- User progress tracking
- Analytics and reporting (can be added)

---

## 🐛 Troubleshooting

### Common Issues:

1. **Build errors** - Run `flutter clean && flutter pub get`
2. **Code generation issues** - Run `flutter packages pub run build_runner clean`
3. **Supabase connection** - Check your URL and API keys
4. **File upload errors** - Ensure storage buckets are created and public

### Support

For issues or questions, check:
- Flutter documentation
- Supabase documentation
- Riverpod documentation

---

**Note**: This is an MVP implementation. For production use, implement proper authentication, error handling, and testing.
