import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/practice_tests_provider.dart';

class CreatePracticeTestDialog extends ConsumerStatefulWidget {
  final String examCategoryId;

  const CreatePracticeTestDialog({super.key, required this.examCategoryId});

  @override
  ConsumerState<CreatePracticeTestDialog> createState() =>
      _CreatePracticeTestDialogState();
}

class _CreatePracticeTestDialogState
    extends ConsumerState<CreatePracticeTestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalQuestionsController = TextEditingController();
  final _timeLimitController = TextEditingController();
  final _passingScoreController = TextEditingController();

  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();

    // Listen to form changes
    _nameController.addListener(_markAsChanged);
    _descriptionController.addListener(_markAsChanged);
    _totalQuestionsController.addListener(_markAsChanged);
    _timeLimitController.addListener(_markAsChanged);
    _passingScoreController.addListener(_markAsChanged);
  }

  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
      print('Practice test form marked as changed');
    }
  }

  Future<bool> _showCancelConfirmation() async {
    print('Practice test checking for changes: $_hasUnsavedChanges');

    if (!_hasUnsavedChanges) {
      return true; // No changes, allow immediate cancel
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to cancel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continue Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Discard Changes'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  void dispose() {
    _nameController.removeListener(_markAsChanged);
    _descriptionController.removeListener(_markAsChanged);
    _totalQuestionsController.removeListener(_markAsChanged);
    _timeLimitController.removeListener(_markAsChanged);
    _passingScoreController.removeListener(_markAsChanged);

    _nameController.dispose();
    _descriptionController.dispose();
    _totalQuestionsController.dispose();
    _timeLimitController.dispose();
    _passingScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _showCancelConfirmation,
      child: Dialog(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Iconsax.clipboard_tick,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Create New Practice Test',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        if (await _showCancelConfirmation()) {
                          if (mounted) Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Iconsax.close_circle),
                      color: AppColors.gray400,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Form Fields
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Test Name *',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'Enter test name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Test name is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Questions *',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _totalQuestionsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'e.g., 50',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Total questions is required';
                              }
                              final number = int.tryParse(value);
                              if (number == null || number <= 0) {
                                return 'Must be a positive number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description *',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter test description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time Limit (minutes)',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _timeLimitController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Optional',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value != null && value.trim().isNotEmpty) {
                                final number = int.tryParse(value);
                                if (number == null || number <= 0) {
                                  return 'Must be a positive number';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Passing Score (%)',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passingScoreController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Optional',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value != null && value.trim().isNotEmpty) {
                                final number = double.tryParse(value);
                                if (number == null ||
                                    number < 0 ||
                                    number > 100) {
                                  return 'Must be 0-100';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (await _showCancelConfirmation()) {
                                if (mounted) Navigator.of(context).pop();
                              }
                            },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: (_isLoading || !_hasUnsavedChanges) ? null : _createTest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasUnsavedChanges ? AppColors.primary : AppColors.gray400,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Create Test'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createTest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(
        practiceTestsNotifierProvider(widget.examCategoryId).notifier,
      );

      await notifier.createTest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        totalQuestions: int.parse(_totalQuestionsController.text.trim()),
        timeLimitMinutes: _timeLimitController.text.trim().isNotEmpty
            ? int.parse(_timeLimitController.text.trim())
            : null,
        passingScore: _passingScoreController.text.trim().isNotEmpty
            ? double.parse(_passingScoreController.text.trim())
            : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Practice test created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating test: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
