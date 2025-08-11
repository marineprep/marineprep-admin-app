import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../models/question.dart';

class AddQuestionDialog extends StatefulWidget {
  final String subjectId;
  final String sectionType; // 'question_bank' or 'practice_test'
  final Question? question;

  const AddQuestionDialog({
    super.key,
    required this.subjectId,
    required this.sectionType,
    this.question,
  });

  @override
  State<AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  
  // Answer choices
  final List<TextEditingController> _choiceControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  
  // Images
  PlatformFile? _questionImage;
  PlatformFile? _explanationImage;
  
  bool get isEditing => widget.question != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _initializeEditData();
    }
  }

  void _initializeEditData() {
    final question = widget.question!;
    for (int i = 0; i < question.answerChoices.length && i < 4; i++) {
      _choiceControllers[i].text = question.answerChoices[i].text;
    }
  }

  @override
  void dispose() {
    for (final controller in _choiceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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

                FormBuilderTextField(
                  name: 'questionText',
                  initialValue: widget.question?.questionText,
                  decoration: const InputDecoration(
                    labelText: 'Question Text',
                    hintText: 'Enter your question here...',
                    prefixIcon: Icon(Iconsax.message_question),
                  ),
                  maxLines: 3,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(10),
                  ]),
                ),
                const SizedBox(height: 16),

                // Question Image
                _ImageUploadSection(
                  title: 'Question Image (Optional)',
                  file: _questionImage,
                  onFilePicked: (file) => setState(() => _questionImage = file),
                  onFileRemoved: () => setState(() => _questionImage = null),
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
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
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
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _choiceControllers[index],
                            decoration: InputDecoration(
                              hintText: 'Enter choice $label',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter choice $label';
                              }
                              return null;
                            },
                          ),
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
                      .map((choice) => DropdownMenuItem(
                            value: choice,
                            child: Text('Choice $choice'),
                          ))
                      .toList(),
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

                FormBuilderTextField(
                  name: 'explanationText',
                  initialValue: widget.question?.explanationText,
                  decoration: const InputDecoration(
                    labelText: 'Explanation Text',
                    hintText: 'Explain why this is the correct answer...',
                    prefixIcon: Icon(Iconsax.note_text),
                  ),
                  maxLines: 3,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(10),
                  ]),
                ),
                const SizedBox(height: 16),

                // Explanation Image
                _ImageUploadSection(
                  title: 'Explanation Image (Optional)',
                  file: _explanationImage,
                  onFilePicked: (file) => setState(() => _explanationImage = file),
                  onFileRemoved: () => setState(() => _explanationImage = null),
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
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveQuestion,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
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
    );
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    // Validate answer choices
    for (int i = 0; i < 4; i++) {
      if (_choiceControllers[i].text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in choice ${String.fromCharCode(65 + i)}'),
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

      // TODO: Upload images to Supabase Storage
      // TODO: Save question to Supabase database

      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

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

class _ImageUploadSection extends StatelessWidget {
  final String title;
  final PlatformFile? file;
  final Function(PlatformFile) onFilePicked;
  final VoidCallback onFileRemoved;

  const _ImageUploadSection({
    required this.title,
    required this.file,
    required this.onFilePicked,
    required this.onFileRemoved,
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
                Icon(
                  Iconsax.image,
                  color: AppColors.success,
                  size: 20,
                ),
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
          onPressed: _pickImage,
          icon: const Icon(Iconsax.image),
          label: Text(file != null ? 'Change Image' : 'Upload Image'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
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
