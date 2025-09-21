import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../models/question.dart';
import '../providers/questions_provider.dart';
import '../services/questions_service.dart';
import '../../shared/widgets/rich_text_editor.dart';

class AddQuestionDialog extends ConsumerStatefulWidget {
  final String subjectId;
  final String? topicId;
  final String sectionType; // 'question_bank' or 'practice_test'
  final Question? question;

  const AddQuestionDialog({
    super.key,
    required this.subjectId,
    this.topicId,
    required this.sectionType,
    this.question,
  });

  @override
  ConsumerState<AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends ConsumerState<AddQuestionDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  // Rich text controllers
  late QuillController _questionController;
  late QuillController _explanationController;
  final List<QuillController> _choiceControllers = [
    QuillController.basic(),
    QuillController.basic(),
    QuillController.basic(),
    QuillController.basic(),
  ];

  // Images
  PlatformFile? _questionImage;
  PlatformFile? _explanationImage;

  // Answer choice images
  final List<PlatformFile?> _choiceImages = [null, null, null, null];

  // Track images to be removed from storage
  String? _questionImageToRemove;
  String? _explanationImageToRemove;
  final List<String?> _choiceImagesToRemove = [null, null, null, null];

  bool get isEditing => widget.question != null;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _questionController = QuillController.basic();
    _explanationController = QuillController.basic();

    if (isEditing) {
      _initializeEditData();
    }

    // Listen to form changes
    _questionController.addListener(_markAsChanged);
    _explanationController.addListener(_markAsChanged);
    for (final controller in _choiceControllers) {
      controller.addListener(_markAsChanged);
    }
  }

  void _initializeEditData() {
    final question = widget.question!;

    // Initialize question content
    _questionController.document = Document.fromDelta(
      question.getQuestionDelta(),
    );

    // Initialize explanation content
    _explanationController.document = Document.fromDelta(
      question.getExplanationDelta(),
    );

    // Initialize answer choices
    for (int i = 0; i < question.answerChoices.length && i < 4; i++) {
      _choiceControllers[i].document = Document.fromDelta(
        question.answerChoices[i].getDelta(),
      );
    }
  }

  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
      print('Form marked as changed');
    }
  }

  // Remove existing question image
  void _removeExistingQuestionImage() {
    if (widget.question?.questionImageUrl != null) {
      setState(() {
        _questionImageToRemove = widget.question!.questionImageUrl;
        _questionImage = null;
      });
      _markAsChanged();

      // Show feedback to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Question image marked for removal. Upload new image after saving.',
            ),
            backgroundColor: AppColors.warning,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Remove existing explanation image
  void _removeExistingExplanationImage() {
    if (widget.question?.explanationImageUrl != null) {
      setState(() {
        _explanationImageToRemove = widget.question!.explanationImageUrl;
        _markAsChanged();
      });

      // Show feedback to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Explanation image marked for removal. Upload new image after saving.',
            ),
            backgroundColor: AppColors.warning,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Remove existing choice image
  void _removeExistingChoiceImage(int index) {
    if (widget.question != null &&
        index < widget.question!.answerChoices.length &&
        widget.question!.answerChoices[index].imageUrl != null) {
      setState(() {
        _choiceImagesToRemove[index] =
            widget.question!.answerChoices[index].imageUrl;
        _choiceImages[index] = null;
        _markAsChanged();
      });

      // Show feedback to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Choice ${String.fromCharCode(65 + index)} image marked for removal. Upload new image after saving.',
            ),
            backgroundColor: AppColors.warning,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<bool> _showCancelConfirmation() async {
    print('Checking for changes: $_hasUnsavedChanges');

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
    _questionController.removeListener(_markAsChanged);
    _explanationController.removeListener(_markAsChanged);
    _questionController.dispose();
    _explanationController.dispose();

    for (final controller in _choiceControllers) {
      controller.removeListener(_markAsChanged);
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _showCancelConfirmation,
      child: AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isEditing ? Iconsax.edit : Iconsax.add,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(isEditing ? 'Edit Question' : 'Add New Question'),
          ],
        ),
        content: SizedBox(
          width: 700,
          height: 700,
          child: SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              onChanged: () => _markAsChanged(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Section
                  Text(
                    'Question',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  RichTextEditor(
                    controller: _questionController,
                    labelText: 'Question Text',
                    hintText: 'Enter your question here...',
                    isRequired: true,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Question text is required';
                      }
                      if (value.trim().length < 10) {
                        return 'Question text must be at least 10 characters';
                      }
                      return null;
                    },
                    onChanged: (value) => _markAsChanged(),
                  ),
                  const SizedBox(height: 16),

                  // Question Image
                  _QuestionImageSection(
                    title: 'Question Image (Optional)',
                    file: _questionImage,
                    existingImageUrl: widget.question?.questionImageUrl,
                    onFilePicked: (file) {
                      setState(() {
                        _questionImage = file;
                      });
                      _markAsChanged();
                    },
                    onFileRemoved: () {
                      setState(() {
                        _questionImage = null;
                      });
                      _markAsChanged();
                    },
                    onExistingImageRemoved: _removeExistingQuestionImage,
                  ),
                  const SizedBox(height: 24),

                  // Answer Choices
                  Text(
                    'Answer Choices',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...List.generate(4, (index) {
                    final label = String.fromCharCode(65 + index); // A, B, C, D
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CompactRichTextEditor(
                                  controller: _choiceControllers[index],
                                  hintText:
                                      'Enter choice $label (or upload image)',
                                  onChanged: (value) => _markAsChanged(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Choice Image Section
                          _ChoiceImageSection(
                            title: 'Choice $label Image (Optional)',
                            file: _choiceImages[index],
                            existingImageUrl:
                                widget.question != null &&
                                    index <
                                        widget.question!.answerChoices.length
                                ? widget.question!.answerChoices[index].imageUrl
                                : null,
                            onFilePicked: (file) {
                              setState(() {
                                _choiceImages[index] = file;
                              });
                              _markAsChanged();
                            },
                            onFileRemoved: () {
                              setState(() {
                                _choiceImages[index] = null;
                              });
                              _markAsChanged();
                            },
                            onExistingImageRemoved: () =>
                                _removeExistingChoiceImage(index),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // Correct Answer
                  FormBuilderDropdown<String>(
                    name: 'correctAnswer',
                    initialValue: widget.question?.correctAnswer,
                    decoration: const InputDecoration(
                      labelText: 'Correct Answer',
                      prefixIcon: Icon(Iconsax.tick_circle),
                    ),
                    items: ['A', 'B', 'C', 'D']
                        .map(
                          (choice) => DropdownMenuItem(
                            value: choice,
                            child: Text('Choice $choice'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => _markAsChanged(),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 24),

                  // Explanation
                  Text(
                    'Explanation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  RichTextEditor(
                    controller: _explanationController,
                    labelText: 'Explanation Text',
                    hintText: 'Explain why this is the correct answer...',
                    isRequired: true,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Explanation text is required';
                      }
                      if (value.trim().length < 10) {
                        return 'Explanation text must be at least 10 characters';
                      }
                      return null;
                    },
                    onChanged: (value) => _markAsChanged(),
                  ),
                  const SizedBox(height: 16),

                  // Explanation Image
                  _QuestionImageSection(
                    title: 'Explanation Image (Optional)',
                    file: _explanationImage,
                    existingImageUrl: widget.question?.explanationImageUrl,
                    onFilePicked: (file) {
                      setState(() {
                        _explanationImage = file;
                      });
                      _markAsChanged();
                    },
                    onFileRemoved: () {
                      setState(() {
                        _explanationImage = null;
                      });
                      _markAsChanged();
                    },
                    onExistingImageRemoved: _removeExistingExplanationImage,
                  ),
                  const SizedBox(height: 24),

                  // Difficulty Level
                  FormBuilderDropdown<int>(
                    name: 'difficultyLevel',
                    initialValue: widget.question?.difficultyLevel ?? 1,
                    decoration: const InputDecoration(
                      labelText: 'Difficulty Level',
                      prefixIcon: Icon(Iconsax.flash),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 - Very Easy')),
                      DropdownMenuItem(value: 2, child: Text('2 - Easy')),
                      DropdownMenuItem(value: 3, child: Text('3 - Medium')),
                      DropdownMenuItem(value: 4, child: Text('4 - Hard')),
                      DropdownMenuItem(value: 5, child: Text('5 - Very Hard')),
                    ],
                    onChanged: (value) => _markAsChanged(),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),

                  // Active Checkbox
                  FormBuilderCheckbox(
                    name: 'isActive',
                    initialValue: widget.question?.isActive ?? true,
                    title: const Text('Active'),
                    subtitle: const Text('Question will be available to users'),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) => _markAsChanged(),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
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
          ElevatedButton(
            onPressed: (_isLoading || (isEditing && !_hasUnsavedChanges))
                ? null
                : _saveQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: (isEditing && !_hasUnsavedChanges)
                  ? AppColors.gray400
                  : AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveQuestion() async {
    // Validate rich text fields
    final questionText = _questionController.document.toPlainText().trim();
    final explanationText = _explanationController.document
        .toPlainText()
        .trim();

    if (questionText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question text is required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (questionText.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question text must be at least 10 characters'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (explanationText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Explanation text is required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (explanationText.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Explanation text must be at least 10 characters'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    // Validate answer choices - each choice must have either text or image
    for (int i = 0; i < 4; i++) {
      final hasText = _choiceControllers[i].document
          .toPlainText()
          .trim()
          .isNotEmpty;
      final hasImage =
          _choiceImages[i] != null ||
          (widget.question != null &&
              widget.question!.answerChoices.length > i &&
              widget.question!.answerChoices[i].imageUrl != null);

      if (!hasText && !hasImage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Choice ${String.fromCharCode(65 + i)} must have either text or image',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final formData = _formKey.currentState!.value;

      // Upload images to Supabase Storage if provided
      String? questionImageUrl;
      String? explanationImageUrl;
      List<String?> choiceImageUrls = [null, null, null, null];

      final questionsNotifier = ref.read(
        questionsProvider(
          QuestionsFilter(
            subjectId: widget.subjectId,
            topicId: widget.topicId,
            sectionType: widget.sectionType,
          ),
        ).notifier,
      );

      if (_questionImage != null) {
        questionImageUrl = await questionsNotifier.uploadImage(
          _questionImage!.bytes!,
          _questionImage!.name,
          'images',
        );
      } else if (isEditing && widget.question!.questionImageUrl != null) {
        questionImageUrl = widget.question!.questionImageUrl;
      }

      if (_explanationImage != null) {
        explanationImageUrl = await questionsNotifier.uploadImage(
          _explanationImage!.bytes!,
          _explanationImage!.name,
          'images',
        );
      } else if (isEditing && widget.question!.explanationImageUrl != null) {
        explanationImageUrl = widget.question!.explanationImageUrl;
      }

      // Upload choice images
      for (int i = 0; i < 4; i++) {
        if (_choiceImages[i] != null) {
          choiceImageUrls[i] = await questionsNotifier.uploadImage(
            _choiceImages[i]!.bytes!,
            _choiceImages[i]!.name,
            'images',
          );
        } else if (isEditing &&
            i < widget.question!.answerChoices.length &&
            widget.question!.answerChoices[i].imageUrl != null) {
          choiceImageUrls[i] = widget.question!.answerChoices[i].imageUrl;
        }
      }

      // Create answer choices
      final answerChoices = <AnswerChoice>[];
      for (int i = 0; i < 4; i++) {
        final choiceText = _choiceControllers[i].document.toPlainText().trim();
        final choiceDelta = _choiceControllers[i].document.toDelta();

        answerChoices.add(
          AnswerChoice(
            label: String.fromCharCode(65 + i), // A, B, C, D
            text: choiceText, // Keep legacy text for backwards compatibility
            content: choiceDelta, // New rich content
            imageUrl: choiceImageUrls[i],
          ),
        );
      }

      // Get rich text content
      final questionContent = _questionController.document.toDelta();
      final explanationContent = _explanationController.document.toDelta();

      if (isEditing) {
        // Update existing question
        await questionsNotifier.updateQuestion(
          id: widget.question!.id,
          questionText: questionText, // Legacy field
          questionContent: questionContent, // New rich content
          questionImageUrl: questionImageUrl,
          sectionType: widget.sectionType,
          topicId: widget.topicId,
          answerChoices: answerChoices,
          correctAnswer: formData['correctAnswer'],
          explanationText: explanationText, // Legacy field
          explanationContent: explanationContent, // New rich content
          explanationImageUrl: explanationImageUrl,
          difficultyLevel: formData['difficultyLevel'],
          isActive: formData['isActive'] ?? true,
        );
      } else {
        // Create new question
        await questionsNotifier.addQuestion(
          questionText: questionText, // Legacy field
          questionContent: questionContent, // New rich content
          questionImageUrl: questionImageUrl,
          sectionType: widget.sectionType,
          topicId: widget.topicId,
          answerChoices: answerChoices,
          correctAnswer: formData['correctAnswer'],
          explanationText: explanationText, // Legacy field
          explanationContent: explanationContent, // New rich content
          explanationImageUrl: explanationImageUrl,
          difficultyLevel: formData['difficultyLevel'],
          isActive: formData['isActive'] ?? true,
        );
      }

      // Delete removed images from storage
      if (isEditing &&
          (_questionImageToRemove != null ||
              _explanationImageToRemove != null ||
              _choiceImagesToRemove.any((img) => img != null))) {
        log('Deleting removed images from storage');

        try {
          final questionsService = QuestionsService();

          // Delete removed question image
          if (_questionImageToRemove != null) {
            await questionsService.deleteImage(
              _questionImageToRemove!,
              'images',
            );
            log('Deleted question image: $_questionImageToRemove');
          }

          // Delete removed explanation image
          if (_explanationImageToRemove != null) {
            await questionsService.deleteImage(
              _explanationImageToRemove!,
              'images',
            );
            log('Deleted explanation image: $_explanationImageToRemove');
          }

          // Delete removed choice images
          int deletedChoiceImages = 0;
          for (int i = 0; i < 4; i++) {
            if (_choiceImagesToRemove[i] != null) {
              await questionsService.deleteImage(
                _choiceImagesToRemove[i]!,
                'images',
              );
              log(
                'Deleted choice ${String.fromCharCode(65 + i)} image: ${_choiceImagesToRemove[i]}',
              );
              deletedChoiceImages++;
            }
          }

          log(
            'Successfully deleted ${_questionImageToRemove != null ? 1 : 0} question images, ${_explanationImageToRemove != null ? 1 : 0} explanation images, and $deletedChoiceImages choice images',
          );
        } catch (e) {
          log('Warning: Failed to delete some images from storage: $e');
          // Don't fail the entire operation if image deletion fails
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Question updated successfully'
                  : 'Question added successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class _QuestionImageSection extends StatelessWidget {
  final String title;
  final PlatformFile? file;
  final String? existingImageUrl;
  final Function(PlatformFile) onFilePicked;
  final VoidCallback onFileRemoved;
  final VoidCallback onExistingImageRemoved;

  const _QuestionImageSection({
    required this.title,
    required this.file,
    this.existingImageUrl,
    required this.onFilePicked,
    required this.onFileRemoved,
    required this.onExistingImageRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(height: 8),

        // Show existing image if available
        if (existingImageUrl != null && file == null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gray400.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gray400.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Iconsax.image, color: AppColors.gray400, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Image',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Image attached',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onExistingImageRemoved,
                  child: const Text('Remove'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        if (file != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Iconsax.image, color: AppColors.success, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file!.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        _formatFileSize(file!.size),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onFileRemoved,
                  child: const Text('Remove'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        OutlinedButton.icon(
          onPressed: (existingImageUrl != null && file == null)
              ? null
              : _pickImage,
          icon: const Icon(Iconsax.image),
          label: Text(
            file != null
                ? 'Change Image'
                : (existingImageUrl != null
                      ? 'Remove existing image first'
                      : 'Upload Image'),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: (existingImageUrl != null && file == null)
                ? AppColors.gray400
                : AppColors.primary,
            side: BorderSide(
              color: (existingImageUrl != null && file == null)
                  ? AppColors.gray400
                  : AppColors.primary,
            ),
          ),
        ),

        // Help text for editing mode
        if (existingImageUrl != null && file == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Remove existing image before uploading a new one',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.gray600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        onFilePicked(result.files.first);
      }
    } catch (e) {
      // Handle error
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _ChoiceImageSection extends StatelessWidget {
  final String title;
  final PlatformFile? file;
  final String? existingImageUrl;
  final Function(PlatformFile) onFilePicked;
  final VoidCallback onFileRemoved;
  final VoidCallback onExistingImageRemoved;

  const _ChoiceImageSection({
    required this.title,
    required this.file,
    this.existingImageUrl,
    required this.onFilePicked,
    required this.onFileRemoved,
    required this.onExistingImageRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.gray600,
          ),
        ),
        const SizedBox(height: 6),

        // Show existing image if available
        if (existingImageUrl != null && file == null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray400.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.gray400.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Iconsax.image, color: AppColors.gray400, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Image',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Image attached',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onExistingImageRemoved,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Remove', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],

        if (file != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Iconsax.image, color: AppColors.success, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file!.name,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        _formatFileSize(file!.size),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onFileRemoved,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Remove', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],

        OutlinedButton.icon(
          onPressed: (existingImageUrl != null && file == null)
              ? null
              : _pickImage,
          icon: const Icon(Iconsax.image, size: 16),
          label: Text(
            file != null
                ? 'Change Image'
                : (existingImageUrl != null
                      ? 'Remove existing image first'
                      : 'Upload Image'),
            style: const TextStyle(fontSize: 12),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: (existingImageUrl != null && file == null)
                ? AppColors.gray400
                : AppColors.primary,
            side: BorderSide(
              color: (existingImageUrl != null && file == null)
                  ? AppColors.gray400
                  : AppColors.primary,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),

        // Help text for editing mode
        if (existingImageUrl != null && file == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Remove existing image before uploading a new one',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.gray600,
                fontStyle: FontStyle.italic,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        onFilePicked(result.files.first);
      }
    } catch (e) {
      // Handle error
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
