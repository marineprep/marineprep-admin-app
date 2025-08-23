-- =============================================
-- Marine Prep Admin Database Schema
-- Designed for Supabase PostgreSQL
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- 1. EXAM CATEGORIES TABLE
-- Stores different exam types (IMUCET, DECK, ENGINE, etc.)
-- =============================================
CREATE TABLE IF NOT EXISTS exam_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default exam categories if they don't exist
INSERT INTO exam_categories (name, description)
VALUES
    ('IMUCET', 'Indian Maritime University Common Entrance Test'),
    ('DECK', 'Deck Officer Examinations'),
    ('ENGINE', 'Marine Engineering Examinations')
ON CONFLICT (name) DO NOTHING;

-- =============================================
-- 2. SUBJECTS TABLE
-- Stores subjects for each exam category
-- =============================================
CREATE TABLE IF NOT EXISTS subjects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    exam_category_id UUID NOT NULL REFERENCES exam_categories(id) ON DELETE CASCADE,
    order_index INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(exam_category_id, name)
);

-- =============================================
-- 3. TOPICS TABLE
-- Stores topics for each subject with video and notes
-- =============================================
CREATE TABLE IF NOT EXISTS topics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    order_index INTEGER NOT NULL DEFAULT 0,
    
    -- Video Information (JSONB for multiple videos)
    videos JSONB DEFAULT '[]'::jsonb,
    
    -- Notes Information
    notes_url TEXT,
    notes_file_name VARCHAR(255),
    notes_file_size BIGINT,
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(subject_id, name)
);

-- =============================================
-- 4. QUESTIONS TABLE
-- Stores questions for both question bank and practice tests
-- =============================================
CREATE TABLE IF NOT EXISTS questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_text TEXT NOT NULL,
    question_image_url TEXT,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    topic_id UUID REFERENCES topics(id) ON DELETE SET NULL,
    section_type VARCHAR(50) NOT NULL CHECK (section_type IN ('question_bank', 'practice_test')),
    
    -- Answer choices stored as JSONB for flexibility
    answer_choices JSONB NOT NULL, -- [{"label": "A", "text": "Option A", "image_url": null}, ...]
    correct_answer VARCHAR(1) NOT NULL CHECK (correct_answer IN ('A', 'B', 'C', 'D')),
    
    -- Explanation
    explanation_text TEXT NOT NULL,
    explanation_image_url TEXT,
    
    -- Metadata
    difficulty_level INTEGER DEFAULT 1 CHECK (difficulty_level BETWEEN 1 AND 5),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 5. ROADMAP STEPS TABLE
-- Stores the learning roadmap steps (can be static or dynamic)
-- =============================================
CREATE TABLE IF NOT EXISTS roadmap_steps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    exam_category_id UUID NOT NULL REFERENCES exam_categories(id) ON DELETE CASCADE,
    
    -- Step type determines what kind of content this step represents
    step_type VARCHAR(50) NOT NULL CHECK (step_type IN ('video', 'notes', 'question_bank', 'practice_test', 'custom')),
    
    -- Resource ID points to the related content (topic id, subject id, etc.)
    resource_id UUID,
    
    order_index INTEGER NOT NULL DEFAULT 0,
    is_required BOOLEAN DEFAULT true,
    estimated_minutes INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(exam_category_id, order_index)
);

-- =============================================
-- 6. USER ROADMAP PROGRESS TABLE
-- Tracks individual user progress through roadmap
-- This allows for personalized roadmaps per user
-- =============================================
CREATE TABLE IF NOT EXISTS user_roadmap_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL, -- This would reference your users table when authentication is added
    roadmap_step_id UUID NOT NULL REFERENCES roadmap_steps(id) ON DELETE CASCADE,
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, roadmap_step_id)
);

-- =============================================
-- 7. PRACTICE TEST SESSIONS TABLE
-- Stores user practice test sessions
-- =============================================
CREATE TABLE IF NOT EXISTS practice_test_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL, -- This would reference your users table
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    total_questions INTEGER NOT NULL,
    correct_answers INTEGER DEFAULT 0,
    score_percentage DECIMAL(5,2) DEFAULT 0.00,
    time_taken_minutes INTEGER,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    is_completed BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 8. PRACTICE TEST ANSWERS TABLE
-- Stores individual answers for practice test sessions
-- =============================================
CREATE TABLE IF NOT EXISTS practice_test_answers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES practice_test_sessions(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    user_answer VARCHAR(1) CHECK (user_answer IN ('A', 'B', 'C', 'D')),
    is_correct BOOLEAN,
    time_taken_seconds INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(session_id, question_id)
);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

-- Subjects
CREATE INDEX IF NOT EXISTS idx_subjects_exam_category ON subjects(exam_category_id);
CREATE INDEX IF NOT EXISTS idx_subjects_active ON subjects(is_active);

-- Topics
CREATE INDEX IF NOT EXISTS idx_topics_subject ON topics(subject_id);
CREATE INDEX IF NOT EXISTS idx_topics_active ON topics(is_active);

-- Questions
CREATE INDEX IF NOT EXISTS idx_questions_subject ON questions(subject_id);
CREATE INDEX IF NOT EXISTS idx_questions_section_type ON questions(section_type);
CREATE INDEX IF NOT EXISTS idx_questions_active ON questions(is_active);
CREATE INDEX IF NOT EXISTS idx_questions_difficulty ON questions(difficulty_level);

-- Roadmap Steps
CREATE INDEX IF NOT EXISTS idx_roadmap_steps_exam_category ON roadmap_steps(exam_category_id);
CREATE INDEX IF NOT EXISTS idx_roadmap_steps_order ON roadmap_steps(order_index);
CREATE INDEX IF NOT EXISTS idx_roadmap_steps_type ON roadmap_steps(step_type);

-- User Progress
CREATE INDEX IF NOT EXISTS idx_user_progress_user ON user_roadmap_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_completed ON user_roadmap_progress(is_completed);

-- Practice Tests
CREATE INDEX IF NOT EXISTS idx_practice_sessions_user ON practice_test_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_practice_sessions_subject ON practice_test_sessions(subject_id);
CREATE INDEX IF NOT EXISTS idx_practice_answers_session ON practice_test_answers(session_id);

-- =============================================
-- FUNCTIONS FOR AUTOMATIC UPDATED_AT
-- =============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to all tables
DROP TRIGGER IF EXISTS update_exam_categories_updated_at ON exam_categories;
CREATE TRIGGER update_exam_categories_updated_at BEFORE UPDATE ON exam_categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_subjects_updated_at ON subjects;
CREATE TRIGGER update_subjects_updated_at BEFORE UPDATE ON subjects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_topics_updated_at ON topics;
CREATE TRIGGER update_topics_updated_at BEFORE UPDATE ON topics FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_questions_updated_at ON questions;
CREATE TRIGGER update_questions_updated_at BEFORE UPDATE ON questions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_roadmap_steps_updated_at ON roadmap_steps;
CREATE TRIGGER update_roadmap_steps_updated_at BEFORE UPDATE ON roadmap_steps FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_roadmap_progress_updated_at ON user_roadmap_progress;
CREATE TRIGGER update_user_roadmap_progress_updated_at BEFORE UPDATE ON user_roadmap_progress FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_practice_test_sessions_updated_at ON practice_test_sessions;
CREATE TRIGGER update_practice_test_sessions_updated_at BEFORE UPDATE ON practice_test_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- STORAGE BUCKETS (Run these in Supabase Storage)
-- =============================================

-- Create storage buckets for file uploads
-- You'll need to run these commands in the Supabase dashboard or via API:

/*
-- Videos bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('videos', 'videos', true);

-- Notes/Documents bucket  
INSERT INTO storage.buckets (id, name, public)
VALUES ('notes', 'notes', true);

-- Images bucket (for question images, etc.)
INSERT INTO storage.buckets (id, name, public)
VALUES ('images', 'images', true);
*/

-- =============================================
-- SAMPLE DATA FOR TESTING
-- =============================================

-- Insert sample subjects for IMUCET
INSERT INTO subjects (name, description, exam_category_id, order_index) VALUES 
('Mathematics', 'Mathematical concepts and problem solving', (SELECT id FROM exam_categories WHERE name = 'IMUCET'), 1),
('Physics', 'Physics principles and applications', (SELECT id FROM exam_categories WHERE name = 'IMUCET'), 2),
('Chemistry', 'Chemical processes and reactions', (SELECT id FROM exam_categories WHERE name = 'IMUCET'), 3),
('English', 'English language and comprehension', (SELECT id FROM exam_categories WHERE name = 'IMUCET'), 4)
ON CONFLICT (exam_category_id, name) DO NOTHING;

-- Insert sample topics for Mathematics
INSERT INTO topics (name, description, subject_id, order_index) VALUES 
('Algebra', 'Basic algebraic concepts and equations', (SELECT id FROM subjects WHERE name = 'Mathematics'), 1),
('Trigonometry', 'Trigonometric functions and identities', (SELECT id FROM subjects WHERE name = 'Mathematics'), 2),
('Calculus', 'Differential and integral calculus', (SELECT id FROM subjects WHERE name = 'Mathematics'), 3)
ON CONFLICT (subject_id, name) DO NOTHING;

-- Insert sample roadmap steps
INSERT INTO roadmap_steps (title, description, exam_category_id, step_type, order_index, estimated_minutes) VALUES
('Complete Mathematics Foundation', 'Master basic mathematical concepts', (SELECT id FROM exam_categories WHERE name = 'IMUCET'), 'custom', 1, 180),
('Practice Question Banks', 'Solve practice questions for all subjects', (SELECT id FROM exam_categories WHERE name = 'IMUCET'), 'question_bank', 2, 120),
('Take Practice Tests', 'Complete timed practice examinations', (SELECT id FROM exam_categories WHERE name = 'IMUCET'), 'practice_test', 3, 90)
ON CONFLICT (exam_category_id, order_index) DO NOTHING;
