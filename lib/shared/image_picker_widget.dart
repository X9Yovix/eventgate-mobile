import 'dart:io';
import 'package:eventgate_flutter/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerWidget extends StatelessWidget {
  final List<File> images;
  final Function(List<File>) onImagesChanged;

  const ImagePickerWidget({
    super.key,
    required this.images,
    required this.onImagesChanged,
  });

  Future<void> _requestPermissions(BuildContext context) async {
    try {
      PermissionStatus permission = await Permission.storage.request();
      if (permission.isGranted) {
        _pickImages();
      } else {
        permission = await Permission.manageExternalStorage.request();
        if (permission.isGranted) {
          _pickImages();
        } else {
          AppUtils.showToast(
            context,
            'Permission to access photos was denied. Please enable it from settings.',
            'error',
          );
        }
      }
    } catch (e) {
      AppUtils.showToast(
        context,
        'An error occurred while requesting photo permissions',
        'error',
      );
    }
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      final files = result.files.map((file) => File(file.path!)).toList();
      onImagesChanged(files);
    }
  }

  void _removeImage(int index) {
    List<File> updatedImages = List.from(images);
    updatedImages.removeAt(index);
    onImagesChanged(updatedImages);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.image_outlined),
            label: const Text('Select Event Images'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color.fromARGB(255, 44, 2, 51)),
              foregroundColor: const Color.fromARGB(255, 44, 2, 51),
            ),
            onPressed: () => _requestPermissions(context),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: images
                .asMap()
                .entries
                .map(
                  (entry) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          entry.value,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: -10,
                        right: -10,
                        child: IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                          onPressed: () => _removeImage(entry.key),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
