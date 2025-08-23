# Topic-Based Question Management

## Overview
The question bank system has been enhanced to support topic-based organization. Now administrators can:

1. Select a subject from the dropdown
2. Select a specific topic within that subject
3. Add, edit, and manage questions for each specific topic
4. View questions filtered by both subject and topic

## Database Changes
A new `topic_id` column has been added to the `questions` table to establish the relationship between questions and topics.

### Migration Script
Run the `add_topic_id_to_questions.sql` script on your existing database to add the new column:

```sql
-- Add topic_id column to questions table
ALTER TABLE questions 
ADD COLUMN topic_id UUID REFERENCES topics(id) ON DELETE SET NULL;

-- Add index for better performance
CREATE INDEX IF NOT EXISTS idx_questions_topic_id ON questions(topic_id);
```

## Code Changes Made

### 1. Question Model (`lib/features/questions/models/question.dart`)
- Added `topicId` field (nullable String)
- Updated constructor and copyWith method

### 2. Questions Filter (`lib/features/questions/providers/questions_provider.dart`)
- Added `topicId` parameter to `QuestionsFilter` class
- Updated equality and hashCode methods

### 3. Questions Service (`lib/features/questions/services/questions_service.dart`)
- Modified `getQuestions()` method to filter by topicId
- Updated `createQuestion()` and `updateQuestion()` methods to include topicId
- Enhanced `getQuestionsStats()` to support topic-based statistics

### 4. Question Bank Page (`lib/features/questions/pages/question_bank_page.dart`)
- Added topic selection dropdown after subject selection
- Updated UI to show questions only when both subject and topic are selected
- Added `_NoTopicSelected` widget for better UX
- Modified question filtering to include topicId

### 5. Add Question Dialog (`lib/features/questions/widgets/add_question_dialog.dart`)
- Added `topicId` parameter to constructor
- Updated question creation and editing to include topicId

## How to Use

### For Administrators
1. Navigate to the Question Bank page
2. Select a subject from the first dropdown
3. Select a topic from the second dropdown (appears after subject selection)
4. Add new questions or manage existing ones for that specific topic
5. Questions are now organized by both subject and topic

### Benefits
- **Better Organization**: Questions are now categorized by specific topics within subjects
- **Improved Navigation**: Users can quickly find questions related to specific topics
- **Enhanced Learning**: Students can focus on specific topics for targeted practice
- **Better Analytics**: More granular statistics and reporting capabilities

## Backward Compatibility
- Existing questions will have `topic_id` set to NULL
- The system gracefully handles questions without topics
- All existing functionality remains intact

## Future Enhancements
- Bulk topic assignment for existing questions
- Topic-based question statistics and analytics
- Topic-specific question difficulty distribution
- Topic-based practice test generation
