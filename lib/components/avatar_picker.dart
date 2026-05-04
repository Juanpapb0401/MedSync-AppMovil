import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'app_colors.dart';

// AM-34 — DS-06 AvatarPicker
// Círculo grande: fondo #E0F5F3, ícono persona #049B83
// Botón cámara bottom-right: círculo #049B83, ícono cámara blanco
// Con imagen: muestra foto circular recortada
class AvatarPicker extends StatefulWidget {
  final void Function(Uint8List imageBytes, String ext) onImageSelected;

  const AvatarPicker({super.key, required this.onImageSelected});

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last;
      setState(() => _imageBytes = bytes);
      widget.onImageSelected(bytes, ext);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
            child: _imageBytes == null
                ? const Icon(Icons.person, color: AppColors.primary, size: 48)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
