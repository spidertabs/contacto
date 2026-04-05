// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../data/database/database_helper.dart';
import '../../../data/models/contact.dart';
import '../../../shared/widgets/contact_avatar.dart';
import '../../../shared/theme/app_theme.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _db = DatabaseHelper();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    await _db.insertContact(Contact(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      notes: _notesController.text.trim(),
    ));

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: ContactoTheme.background,
      appBar: AppBar(title: const Text('New Contact')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Dynamic avatar preview
              ValueListenableBuilder(
                valueListenable: _nameController,
                builder: (_, __, ___) => ContactAvatar(
                    name: _nameController.text.isEmpty
                        ? '?'
                        : _nameController.text,
                    radius: 40),
              ),
              const SizedBox(height: 28),

              _FormCard(children: [
                _FormField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  onChanged: (_) => setState(() {}),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required.' : null,
                ),
                const _CardDivider(),
                _FormField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v != null &&
                          v.isNotEmpty &&
                          !RegExp(r'^[0-9+\s\-()]+$').hasMatch(v))
                      ? 'Enter a valid phone number.'
                      : null,
                ),
                const _CardDivider(),
                _FormField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v != null &&
                          v.isNotEmpty &&
                          !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v))
                      ? 'Enter a valid email address.'
                      : null,
                ),
              ]),
              const SizedBox(height: 12),

              _FormCard(children: [
                _FormField(
                  controller: _notesController,
                  label: 'Notes',
                  icon: Icons.notes_outlined,
                  maxLines: 3,
                ),
              ]),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveContact,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? 'Saving…' : 'Save Contact'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ContactoTheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 56, endIndent: 16);
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(icon, color: ContactoTheme.primary, size: 20),
        border: InputBorder.none,
        filled: false,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
