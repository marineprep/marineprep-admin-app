import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../models/subject.dart';
import '../providers/subjects_provider.dart';

class AddSubjectDialog extends ConsumerStatefulWidget {
  final String examCategoryId;
  final Subject? subject; // For editing existing subject

  const AddSubjectDialog({
    super.key,
    required this.examCategoryId,
    this.subject,
  });

  @override
  ConsumerState<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends ConsumerState<AddSubjectDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  bool get isEditing => widget.subject != null;

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
          Text(isEditing ? 'Edit Subject' : 'Add New Subject'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormBuilderTextField(
                name: 'name',
                initialValue: widget.subject?.name,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  hintText: 'e.g., Mathematics, Physics',
                  prefixIcon: Icon(Iconsax.book_1),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(2),
                  FormBuilderValidators.maxLength(100),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'description',
                initialValue: widget.subject?.description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Brief description of the subject',
                  prefixIcon: Icon(Iconsax.document_text),
                ),
                maxLines: 3,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.maxLength(500),
                ]),
              ),
              const SizedBox(height: 16),
              // Order index is now automatically managed
              FormBuilderCheckbox(
                name: 'isActive',
                initialValue: widget.subject?.isActive ?? true,
                title: const Text('Active'),
                subtitle: const Text('Subject will be visible to users'),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveSubject,
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

  Future<void> _saveSubject() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final formData = _formKey.currentState!.value;
      final name = formData['name'] as String;
      final description = formData['description'] as String;
      final isActive = formData['isActive'] as bool;

      if (isEditing) {
        await ref.read(subjectsProvider(widget.examCategoryId).notifier)
            .updateSubject(
              id: widget.subject!.id,
              name: name,
              description: description,
              orderIndex: widget.subject!.orderIndex, // Keep current order index
              isActive: isActive,
            );
      } else {
        // For new subjects, order index is automatic
        await ref.read(subjectsProvider(widget.examCategoryId).notifier)
            .addSubject(
              name: name,
              description: description,
              isActive: isActive,
            );
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing 
                  ? 'Subject updated successfully' 
                  : 'Subject added successfully',
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
