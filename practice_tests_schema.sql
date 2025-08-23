-- =============================================
-- PRACTICE TESTS SCHEMA
-- =============================================

-- Practice Tests Table
CREATE TABLE IF NOT EXISTS practice_tests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    exam_category_id UUID NOT NULL REFERENCES exam_categories(id) ON DELETE CASCADE,
    total_questions INTEGER NOT NULL DEFAULT 0,
    time_limit_minutes INTEGER,
    passing_score DECIMAL(5,2) CHECK (passing_score >= 0 AND passing_score <= 100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(exam_category_id, name)
);

-- Practice Test Subjects Table (Many-to-Many relationship)
CREATE TABLE IF NOT EXISTS practice_test_subjects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    practice_test_id UUID NOT NULL REFERENCES practice_tests(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    question_count INTEGER NOT NULL DEFAULT 0,
    order_index INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(practice_test_id, subject_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_practice_tests_exam_category ON practice_tests(exam_category_id);
CREATE INDEX IF NOT EXISTS idx_practice_tests_active ON practice_tests(is_active);
CREATE INDEX IF NOT EXISTS idx_practice_test_subjects_test ON practice_test_subjects(practice_test_id);
CREATE INDEX IF NOT EXISTS idx_practice_test_subjects_subject ON practice_test_subjects(subject_id);

-- RLS Policies for practice_tests
ALTER TABLE practice_tests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read access for authenticated users" ON practice_tests
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert for authenticated users" ON practice_tests
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for authenticated users" ON practice_tests
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Enable delete for authenticated users" ON practice_tests
    FOR DELETE USING (auth.role() = 'authenticated');

-- RLS Policies for practice_test_subjects
ALTER TABLE practice_test_subjects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read access for authenticated users" ON practice_test_subjects
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert for authenticated users" ON practice_test_subjects
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for authenticated users" ON practice_test_subjects
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Enable delete for authenticated users" ON practice_test_subjects
    FOR DELETE USING (auth.role() = 'authenticated');

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_practice_tests_updated_at 
    BEFORE UPDATE ON practice_tests 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- SAMPLE DATA FOR TESTING (Optional)
-- =============================================

-- Insert a sample practice test for IMUCET if you want to test
-- Uncomment the lines below to insert sample data

/*
INSERT INTO practice_tests (name, description, exam_category_id, total_questions, time_limit_minutes, passing_score)
VALUES (
    'IMUCET Practice Test 1',
    'Comprehensive practice test covering all IMUCET subjects',
    (SELECT id FROM exam_categories WHERE name = 'IMUCET'),
    50,
    90,
    60.0
) ON CONFLICT (exam_category_id, name) DO NOTHING;
*/
