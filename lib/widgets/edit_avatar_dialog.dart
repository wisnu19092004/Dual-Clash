import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game_papan/models/user_profile.dart';
import 'package:game_papan/services/auth_service.dart';
import 'package:game_papan/widgets/interactive_button.dart';
import 'package:game_papan/theme/app_colors.dart';

class EditAvatarDialog extends StatefulWidget {
  final UserProfile user;
  final AuthService auth;

  const EditAvatarDialog({super.key, required this.user, required this.auth});

  @override
  State<EditAvatarDialog> createState() => _EditAvatarDialogState();
}

class _EditAvatarDialogState extends State<EditAvatarDialog> {
  late TextEditingController _nameController;
  late String _selectedAvatarUrl;

  // Curated list of stylish gaming & avatar presets
  static const List<String> avatarPresets = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1628157582853-a796fa650a6a?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1566492031773-4f4e44671857?w=150&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _selectedAvatarUrl = widget.user.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (bytes == null || !mounted) return;

    final extension = result!.files.single.extension?.toLowerCase();
    final mimeType = switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/png',
    };

    setState(() {
      _selectedAvatarUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';
    });
  }

  ImageProvider? _avatarImage(String source) {
    if (source.startsWith('data:')) {
      final commaIndex = source.indexOf(',');
      if (commaIndex != -1) {
        return MemoryImage(base64Decode(source.substring(commaIndex + 1)));
      }
    }
    if (source.startsWith('http')) return NetworkImage(source);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: AppColors.surface(context),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(22),
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ubah Profil Pemain',
                    style: GoogleFonts.outfit(
                      color: AppColors.textColor(context),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSecondaryColor(context),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Selected Avatar Preview
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primary,
                      child: _selectedAvatarUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(44),
                              child: Image(
                                image: _avatarImage(_selectedAvatarUrl)!,
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.person,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.white,
                            ),
                    ),
                    if (_selectedAvatarUrl.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedAvatarUrl = ''),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              Text(
                'NAMA PEMAIN',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondaryColor(context),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                style: TextStyle(
                  color: AppColors.textColor(context),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceDark(context),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  hintText: 'Masukkan nama tampilan...',
                  hintStyle: TextStyle(
                    color: AppColors.textMutedColor(context),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.borderColor(context),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.borderColor(context),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.8,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),
              Text(
                'PILIH FOTO PROFIL (AVATAR)',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondaryColor(context),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickAvatar,
                  icon: const Icon(Icons.upload_rounded, size: 18),
                  label: const Text('Pilih foto dari perangkat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Avatar Presets Grid
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  // Default Avatar Option (Icon)
                  GestureDetector(
                    onTap: () => setState(() => _selectedAvatarUrl = ''),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceDark(context),
                        border: Border.all(
                          color: _selectedAvatarUrl.isEmpty
                              ? AppColors.primary
                              : AppColors.borderColor(context),
                          width: _selectedAvatarUrl.isEmpty ? 2.5 : 1,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        color: _selectedAvatarUrl.isEmpty
                            ? AppColors.primary
                            : AppColors.textSecondaryColor(context),
                        size: 26,
                      ),
                    ),
                  ),
                  ...avatarPresets.map((url) {
                    final isSelected = _selectedAvatarUrl == url;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatarUrl = url),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: isSelected ? 2.5 : 0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.person, color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),

              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: InteractiveButton(
                  onPressed: () async {
                    final rawName = _nameController.text.trim();
                    final cleanName = rawName.isEmpty
                        ? widget.user.displayName
                        : (rawName.length > 30 ? rawName.substring(0, 30) : rawName);

                    await widget.auth.updateProfile(
                      displayName: cleanName,
                      photoUrl: _selectedAvatarUrl,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil berhasil diperbarui!'),
                        ),
                      );
                    }
                  },
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Text(
                      'Simpan Perubahan',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
