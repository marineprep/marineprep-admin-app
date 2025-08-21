import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/config/supabase_config.dart';
import '../models/topic.dart';
import '../providers/topics_provider.dart';
import '../../auth/providers/auth_provider.dart';

class AddTopicDialog extends ConsumerStatefulWidget {
  final String subjectId;
  final Topic? topic;

  const AddTopicDialog({super.key, required this.subjectId, this.topic});

  @override
  ConsumerState<AddTopicDialog> createState() => _AddTopicDialogState();
}

class _AddTopicDialogState extends ConsumerState<AddTopicDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  // File uploads - supporting multiple videos
  List<PlatformFile> _selectedVideos = [];
  PlatformFile? _selectedNotes;
  bool _isUploadingVideos = false;
  bool _isUploadingNotes = false;

  bool get isEditing => widget.topic != null;

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
          Text(isEditing ? 'Edit Topic' : 'Add New Topic'),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 600,
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information
                Text(
                  'Basic Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray700,
                  ),
                ),
                const SizedBox(height: 16),

                FormBuilderTextField(
                  name: 'name',
                  initialValue: widget.topic?.name,
                  decoration: const InputDecoration(
                    labelText: 'Topic Name',
                    hintText: 'e.g., Algebra, Trigonometry',
                    prefixIcon: Icon(Iconsax.document_text),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(2),
                    FormBuilderValidators.maxLength(200),
                  ]),
                ),
                const SizedBox(height: 16),

                FormBuilderTextField(
                  name: 'description',
                  initialValue: widget.topic?.description,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Brief description of the topic',
                    prefixIcon: Icon(Iconsax.note_text),
                  ),
                  maxLines: 3,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.maxLength(500),
                  ]),
                ),
                const SizedBox(height: 16),

                // Video Section
                Text(
                  'Video Content',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray700,
                  ),
                ),
                const SizedBox(height: 16),

                _VideoUploadSection(),
                const SizedBox(height: 24),

                // Notes Section
                Text(
                  'Notes/Documents',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray700,
                  ),
                ),
                const SizedBox(height: 16),

                _NotesUploadSection(),
                const SizedBox(height: 24),

                // Active Checkbox
                FormBuilderCheckbox(
                  name: 'isActive',
                  initialValue: widget.topic?.isActive ?? true,
                  title: const Text('Active'),
                  subtitle: const Text('Topic will be visible to users'),
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
          onPressed: _isLoading ? null : _saveTopic,
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

  Widget _VideoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current videos from existing topic
        if (isEditing && widget.topic!.videos.isNotEmpty) ...[
          Text(
            'Current Videos',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          ...widget.topic!.videos
              .map(
                (video) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.video_play,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.fileName,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              _formatFileSize(video.fileSize),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.gray600),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Handle existing video removal
                        },
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 16),
        ],

        // Selected new videos
        if (_selectedVideos.isNotEmpty) ...[
          Text(
            'Selected Videos (${_selectedVideos.length}/10)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          ..._selectedVideos.asMap().entries.map((entry) {
            final index = entry.key;
            final video = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.video, color: AppColors.warning, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          _formatFileSize(video.size),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.gray600),
                        ),
                      ],
                    ),
                  ),
                  if (_isUploadingVideos)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedVideos.removeAt(index);
                        });
                      },
                      child: const Text('Remove'),
                    ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
        ],

        // Upload button
        OutlinedButton.icon(
          onPressed: (_isUploadingVideos || _selectedVideos.length >= 10)
              ? null
              : _pickVideos,
          icon: Icon(
            _isUploadingVideos ? Iconsax.video_play : Iconsax.video_add,
          ),
          label: Text(
            _selectedVideos.isEmpty
                ? 'Upload Videos (Max 10)'
                : 'Add More Videos',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
          ),
        ),

        if (_selectedVideos.length >= 10)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Maximum 10 videos allowed',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.warning),
            ),
          ),
      ],
    );
  }

  Widget _NotesUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.topic?.notesUrl != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Iconsax.document_text, color: AppColors.success, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Notes',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.topic?.notesFileName ?? 'Notes file',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Handle notes removal
                  },
                  child: const Text('Remove'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (_selectedNotes != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Iconsax.document, color: AppColors.warning, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Notes',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _selectedNotes!.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        _formatFileSize(_selectedNotes!.size),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isUploadingNotes)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedNotes = null;
                      });
                    },
                    child: const Text('Remove'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        OutlinedButton.icon(
          onPressed: _isUploadingNotes ? null : _pickNotes,
          icon: Icon(
            _isUploadingNotes ? Iconsax.document : Iconsax.document_upload,
          ),
          label: Text(_selectedNotes != null ? 'Change Notes' : 'Upload Notes'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Future<void> _pickVideos() async {
    try {
      setState(() {
        _isUploadingVideos = true;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          // Filter to ensure we don't exceed 10 videos total
          final remainingSlots = 10 - _selectedVideos.length;
          final newVideos = result.files.take(remainingSlots).toList();

          // Check file sizes
          final validVideos = <PlatformFile>[];
          for (final video in newVideos) {
            if (video.size <= AppConstants.maxFileSize) {
              validVideos.add(video);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${video.name} is too large. Maximum size is ${AppConstants.maxFileSize ~/ (1024 * 1024)}MB',
                  ),
                  backgroundColor: AppColors.warning,
                ),
              );
            }
          }

          _selectedVideos.addAll(validVideos);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking videos: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploadingVideos = false;
      });
    }
  }

  Future<void> _pickNotes() async {
    try {
      setState(() {
        _isUploadingNotes = true;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedNotes = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking notes: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploadingNotes = false;
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _saveTopic() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Debug: Check authentication status
      final authState = ref.read(authNotifierProvider);
      log('Auth state: $authState');

      // Safely get current user from auth state
      final currentUser = authState.when(
        data: (user) => user,
        loading: () => null,
        error: (error, stack) => null,
      );

      log('Current user: ${currentUser?.email}');
      log('Is authenticated: ${currentUser != null}');

      // Check if user is authenticated
      if (currentUser == null) {
        throw Exception('User must be authenticated to upload files');
      }

      // Debug: Test storage access
      try {
        final testResponse = await SupabaseConfig.client.storage
            .from('videos')
            .list();
        log('Storage access test successful: ${testResponse.length} files');
      } catch (e) {
        log('Storage access test failed: $e');
        // Don't throw here, just log the error for debugging
      }

      final formData = _formKey.currentState!.value;
      log('Form data: $formData');

      // Safely extract form values with validation
      final name = formData['name'] as String?;
      final description = formData['description'] as String?;
      final isActive = formData['isActive'] as bool?;

      // Validate required fields
      if (name == null || name.trim().isEmpty) {
        throw Exception('Topic name is required');
      }
      if (description == null || description.trim().isEmpty) {
        throw Exception('Topic description is required');
      }

      final finalIsActive = isActive ?? true;

      // For editing, keep the current order index
      int orderIndex;
      if (isEditing) {
        orderIndex = widget.topic!.orderIndex; // Keep current order index
      } else {
        // For new topics, order index will be auto-assigned
        orderIndex = 1; // This will be overridden by the service
      }

      log(
        'Extracted form data - Name: $name, Description: $description, Order: $orderIndex, Active: $finalIsActive',
      );

      // Prepare videos data
      List<VideoFile> videosData = [];
      log('Preparing videos data. Editing mode: $isEditing');

      // Keep existing videos if editing
      if (isEditing) {
        videosData = List<VideoFile>.from(widget.topic!.videos);
        log('Keeping ${videosData.length} existing videos');
      }

      // Upload new video files and add to videos data
      final topicsService = ref.read(topicsServiceProvider);
      log('Starting video uploads for ${_selectedVideos.length} videos');

      for (final videoFile in _selectedVideos) {
        if (videoFile.bytes != null) {
          log(
            'Uploading video: ${videoFile.name}, size: ${videoFile.size} bytes',
          );
          try {
            final videoUrl = await topicsService.uploadFile(
              path: videoFile.name,
              bucket: AppConstants.videosBucket,
              fileBytes: videoFile.bytes!,
            );

            videosData.add(
              VideoFile(
                url: videoUrl,
                fileName: videoFile.name,
                fileSize: videoFile.size,
              ),
            );
            log('Video uploaded successfully: $videoUrl');
          } catch (e) {
            log('Failed to upload video ${videoFile.name}: $e');
            rethrow; // Re-throw to stop the process
          }
        } else {
          log('Video file ${videoFile.name} has no bytes');
        }
      }

      // Upload notes file if selected
      String? notesUrl;
      String? notesFileName;

      if (_selectedNotes != null && _selectedNotes!.bytes != null) {
        log(
          'Uploading notes: ${_selectedNotes!.name}, size: ${_selectedNotes!.size} bytes',
        );
        try {
          notesUrl = await topicsService.uploadFile(
            bucket: AppConstants.notesBucket,
            path: _selectedNotes!.name,
            fileBytes: _selectedNotes!.bytes!,
          );
          notesFileName = _selectedNotes!.name;
          log('Notes uploaded successfully: $notesUrl');
        } catch (e) {
          log('Failed to upload notes ${_selectedNotes!.name}: $e');
          rethrow; // Re-throw to stop the process
        }
      } else if (isEditing) {
        // Keep existing notes if no new notes selected
        notesUrl = widget.topic!.notesUrl;
        notesFileName = widget.topic!.notesFileName;
        log('Keeping existing notes: $notesUrl');
      } else {
        // For new topics, ensure notes fields are null if no notes selected
        notesUrl = null;
        notesFileName = null;
        log('No notes selected for new topic');
      }

      // Save topic to database
      log(
        'About to save topic. Videos count: ${videosData.length}, Notes URL: $notesUrl',
      );

      // Validate videos data
      for (int i = 0; i < videosData.length; i++) {
        final video = videosData[i];
        log(
          'Video $i: URL=${video.url}, FileName=${video.fileName}, FileSize=${video.fileSize}',
        );
        if (video.url.isEmpty || video.fileName.isEmpty) {
          throw Exception('Invalid video data at index $i');
        }
      }

      // Additional validation for null safety
      if (name.isEmpty || description.isEmpty) {
        throw Exception('Name and description cannot be empty');
      }

      log('Final validation passed. Proceeding to save topic...');

      if (isEditing) {
        log('Updating existing topic with ID: ${widget.topic!.id}');
        await ref
            .read(topicsProvider(widget.subjectId).notifier)
            .updateTopic(
              id: widget.topic!.id,
              name: name,
              description: description,
              orderIndex: orderIndex,
              videos: videosData,
              notesUrl: notesUrl,
              notesFileName: notesFileName,
              isActive: finalIsActive,
            );
      } else {
        log('Creating new topic');
        await ref
            .read(topicsProvider(widget.subjectId).notifier)
            .addTopic(
              name: name,
              description: description,
              videos: videosData,
              notesUrl: notesUrl,
              notesFileName: notesFileName,
              isActive: finalIsActive,
            );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Topic updated successfully'
                  : 'Topic added successfully',
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
