# Practice Tests Management

This document explains the new practice test flow implemented in the Marine Prep Admin App.

## Overview

The practice test system allows administrators to create multiple practice tests, each containing questions from different subjects. This provides a more flexible and comprehensive approach to test creation compared to the previous single-subject question management.

## New Flow

### 1. Practice Test Creation
- Admins can create multiple practice tests from the Practice Tests page
- Each test has:
  - Name and description
  - Total question count
  - Optional time limit
  - Optional passing score
  - Active/Inactive status

### 2. Subject Management
- After creating a test, admins can add subjects to it
- Each subject within a test specifies:
  - Which subject to include
  - How many questions to pull from that subject
  - Order/index for display

### 3. Question Management
- Questions are still managed through the existing question bank system
- Questions marked with `section_type = 'practice_test'` are available for practice tests
- The system automatically pulls random questions from each subject based on the specified count

## Database Schema

### New Tables

#### `practice_tests`
- Stores test metadata (name, description, settings)
- Links to exam categories
- Tracks total questions, time limits, and passing scores

#### `practice_test_subjects`
- Many-to-many relationship between tests and subjects
- Specifies question count per subject
- Maintains order/index for display

### Relationships
```
exam_categories (1) → (many) practice_tests
practice_tests (1) → (many) practice_test_subjects
subjects (1) → (many) practice_test_subjects
questions (many) → (1) subjects (for practice_test section_type)
```

## Usage

### Creating a Practice Test

1. Navigate to Practice Tests page
2. Click "Create Test" button
3. Fill in test details:
   - Test name (required)
   - Description (required)
   - Total questions (required)
   - Time limit (optional)
   - Passing score (optional)
4. Click "Create Test"

### Adding Subjects to a Test

1. From the test card, click "Add Subject" button
2. Or use the "Manage Subjects" option from the test menu
3. Select a subject from the dropdown
4. Specify how many questions to include from that subject
5. Click "Add"

### Managing Test Subjects

- View all subjects currently in the test
- Remove subjects if needed
- See question count per subject
- Add new subjects to existing tests

### Deleting Tests

- Use the menu option on each test card
- Confirmation dialog prevents accidental deletion
- All associated subjects are automatically removed

## Benefits

1. **Multiple Tests**: Admins can create different test configurations
2. **Subject Mixing**: Tests can include questions from multiple subjects
3. **Flexible Configuration**: Customizable time limits and passing scores
4. **Better Organization**: Clear separation between test structure and question content
5. **Scalability**: Easy to add new tests without affecting existing ones

## Technical Implementation

### Files Modified/Created

- `lib/features/questions/models/practice_test.dart` - New model classes
- `lib/features/questions/services/practice_tests_service.dart` - Service layer
- `lib/features/questions/providers/practice_tests_provider.dart` - State management
- `lib/features/questions/widgets/create_practice_test_dialog.dart` - Test creation UI
- `lib/features/questions/widgets/manage_test_subjects_dialog.dart` - Subject management UI
- `lib/features/questions/pages/practice_test_page.dart` - Main page (completely rewritten)
- `practice_tests_schema.sql` - Database schema

### Key Features

- **Riverpod State Management**: Uses providers for reactive state updates
- **Real-time Updates**: UI automatically refreshes when data changes
- **Error Handling**: Comprehensive error handling with user feedback
- **Responsive Design**: Works on different screen sizes
- **Form Validation**: Input validation for all required fields

## Future Enhancements

1. **Test Templates**: Pre-configured test templates for common scenarios
2. **Question Pooling**: Advanced algorithms for question selection
3. **Test Scheduling**: Set when tests become available
4. **Analytics**: Track test performance and usage
5. **Bulk Operations**: Import/export test configurations
6. **Question Preview**: See sample questions before adding subjects

## Migration Notes

- Existing practice test questions remain in the `questions` table
- New system is additive and doesn't break existing functionality
- Questions with `section_type = 'practice_test'` are still accessible
- Old single-subject approach can coexist with new multi-test system

## Database Setup

Run the `practice_tests_schema.sql` file in your Supabase database to create the necessary tables and policies.

```sql
-- Execute this in your Supabase SQL editor
\i practice_tests_schema.sql
```

## Testing

1. Create a new practice test
2. Add subjects with different question counts
3. Verify subjects appear in the test
4. Test subject removal functionality
5. Verify test deletion works correctly
6. Check that UI updates properly after operations
