import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/core/config/supabase_config.dart';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  final supabase = Supabase.instance.client;

  try {
    print('Testing database connection...');

    // Test 1: Check if exam_categories table exists and has IMUCET
    print('\n1. Checking exam_categories table...');
    final examCategories = await supabase
        .from('exam_categories')
        .select()
        .eq('name', 'IMUCET');

    print('Exam categories response: $examCategories');

    if (examCategories.isNotEmpty) {
      final imucet = examCategories.first;
      print('IMUCET exam category found: ${imucet['id']}');

      // Test 2: Check if practice_tests table exists
      print('\n2. Checking practice_tests table...');
      final practiceTests = await supabase
          .from('practice_tests')
          .select()
          .eq('exam_category_id', imucet['id']);

      print('Practice tests response: $practiceTests');
      print('Number of practice tests: ${practiceTests.length}');

      // Test 3: Try to create a test practice test
      print('\n3. Testing practice test creation...');
      final newTest = await supabase
          .from('practice_tests')
          .insert({
            'name': 'Test Practice Test',
            'description': 'This is a test practice test',
            'exam_category_id': imucet['id'],
            'total_questions': 10,
            'is_active': true,
          })
          .select()
          .single();

      print('Created test practice test: ${newTest['id']}');

      // Test 4: Verify the test was created
      print('\n4. Verifying test creation...');
      final verifyTest = await supabase
          .from('practice_tests')
          .select()
          .eq('id', newTest['id']);

      print('Verification response: $verifyTest');

      // Test 5: Clean up - delete the test
      print('\n5. Cleaning up test data...');
      await supabase.from('practice_tests').delete().eq('id', newTest['id']);

      print('Test practice test deleted successfully');
    } else {
      print('IMUCET exam category not found!');
    }
  } catch (e) {
    print('Error during testing: $e');
    if (e is PostgrestException) {
      print('PostgrestException details: ${e.message}');
      print('PostgrestException code: ${e.code}');
      print('PostgrestException details: ${e.details}');
      print('PostgrestException hint: ${e.hint}');
    }
  }
}
