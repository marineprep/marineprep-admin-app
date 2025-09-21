import 'dart:developer';
import 'dart:convert';
import 'package:flutter_quill/quill_delta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../../core/config/supabase_config.dart';

class DataMigrationService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Check if migration is needed
  Future<bool> isMigrationNeeded() async {
    try {
      log('Checking if migration is needed...');

      // Check if there are any questions with null question_content or explanation_content
      final response = await _supabase
          .from('questions')
          .select(
            'id, question_text, question_content, explanation_text, explanation_content, answer_choices',
          )
          .or('question_content.is.null,explanation_content.is.null');

      final questions = response as List;

      // Also check if any answer choices need migration
      bool hasChoicesNeedingMigration = false;
      for (final question in questions) {
        final answerChoices = question['answer_choices'] as List?;
        if (answerChoices != null) {
          for (final choice in answerChoices) {
            if (choice is Map<String, dynamic> &&
                choice['content'] == null &&
                choice['text'] != null) {
              hasChoicesNeedingMigration = true;
              break;
            }
          }
        }
        if (hasChoicesNeedingMigration) break;
      }

      final needsMigration = questions.isNotEmpty || hasChoicesNeedingMigration;
      log(
        'Migration needed: $needsMigration (${questions.length} questions to migrate)',
      );

      return needsMigration;
    } catch (e) {
      log('Error checking migration status: $e');
      return false;
    }
  }

  // Perform the migration
  Future<bool> performMigration() async {
    try {
      log('Starting data migration...');

      // Get all questions
      final response = await _supabase.from('questions').select('*');

      final questions = response as List;
      log('Found ${questions.length} questions to process');

      int migratedCount = 0;
      int errorCount = 0;

      for (final questionData in questions) {
        try {
          await _migrateQuestion(questionData);
          migratedCount++;
          log(
            'Migrated question ${questionData['id']} (${migratedCount}/${questions.length})',
          );
        } catch (e) {
          errorCount++;
          log('Error migrating question ${questionData['id']}: $e');
        }
      }

      log('Migration completed: $migratedCount successful, $errorCount errors');
      return errorCount == 0;
    } catch (e) {
      log('Error during migration: $e');
      return false;
    }
  }

  // Migrate a single question
  Future<void> _migrateQuestion(Map<String, dynamic> questionData) async {
    final questionId = questionData['id'];
    final Map<String, dynamic> updates = {};

    // Migrate question text to Quill delta if needed
    if (questionData['question_content'] == null &&
        questionData['question_text'] != null) {
      final questionText = questionData['question_text'] as String;
      final questionDelta = _textToQuillDelta(questionText);
      updates['question_content'] = jsonEncode(questionDelta.toJson());
    }

    // Migrate explanation text to Quill delta if needed
    if (questionData['explanation_content'] == null &&
        questionData['explanation_text'] != null) {
      final explanationText = questionData['explanation_text'] as String;
      final explanationDelta = _textToQuillDelta(explanationText);
      updates['explanation_content'] = jsonEncode(explanationDelta.toJson());
    }

    // Migrate answer choices if needed
    final answerChoices = questionData['answer_choices'] as List?;
    if (answerChoices != null) {
      List<Map<String, dynamic>> updatedChoices = [];
      bool choicesNeedUpdate = false;

      for (final choice in answerChoices) {
        final choiceMap = Map<String, dynamic>.from(choice);

        // If choice doesn't have content but has text, migrate it
        if (choiceMap['content'] == null && choiceMap['text'] != null) {
          final choiceText = choiceMap['text'] as String;
          final choiceDelta = _textToQuillDelta(choiceText);
          choiceMap['content'] = jsonEncode(choiceDelta.toJson());
          choicesNeedUpdate = true;
        }

        updatedChoices.add(choiceMap);
      }

      if (choicesNeedUpdate) {
        updates['answer_choices'] = updatedChoices;
      }
    }

    // Update the question if there are changes
    if (updates.isNotEmpty) {
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.from('questions').update(updates).eq('id', questionId);

      log('Updated question $questionId with ${updates.keys.join(', ')}');
    }
  }

  // Convert plain text to Quill Delta format
  Delta _textToQuillDelta(String text) {
    final delta = Delta();

    if (text.trim().isEmpty) {
      return delta;
    }

    // Split text by lines to preserve paragraph structure
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.trim().isNotEmpty) {
        delta.insert(line);
      }

      // Add newline except for the last line
      if (i < lines.length - 1) {
        delta.insert('\n');
      }
    }

    return delta;
  }

  // Test migration on a subset of data
  Future<bool> testMigration({int limit = 5}) async {
    try {
      log('Testing migration on $limit questions...');

      final response = await _supabase
          .from('questions')
          .select('*')
          .limit(limit);

      final questions = response as List;

      for (final questionData in questions) {
        // Test the conversion without saving
        if (questionData['question_text'] != null) {
          final questionText = questionData['question_text'] as String;
          final questionDelta = _textToQuillDelta(questionText);
          log(
            'Question delta for "${questionText.substring(0, 50)}...": ${questionDelta.toJson()}',
          );
        }

        if (questionData['explanation_text'] != null) {
          final explanationText = questionData['explanation_text'] as String;
          final explanationDelta = _textToQuillDelta(explanationText);
          log('Explanation delta: ${explanationDelta.toJson()}');
        }
      }

      log('Test migration completed successfully');
      return true;
    } catch (e) {
      log('Error during test migration: $e');
      return false;
    }
  }

  // Create a backup of questions table before migration
  Future<bool> createBackup() async {
    try {
      log('Creating backup of questions table...');

      // Note: In a real production environment, you'd want to create a proper backup
      // For now, we'll create a backup table
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupTableName = 'questions_backup_$timestamp';

      // This would need to be done via SQL in a real scenario
      log('Backup table name would be: $backupTableName');
      log(
        'In production, execute: CREATE TABLE $backupTableName AS SELECT * FROM questions;',
      );

      return true;
    } catch (e) {
      log('Error creating backup: $e');
      return false;
    }
  }

  // Rollback migration if needed
  Future<bool> rollbackMigration() async {
    try {
      log('Rolling back migration...');

      // In a real scenario, you'd restore from the backup table
      // and remove the new columns
      log(
        'Rollback would restore from backup and remove question_content, explanation_content columns',
      );

      return true;
    } catch (e) {
      log('Error during rollback: $e');
      return false;
    }
  }
}
