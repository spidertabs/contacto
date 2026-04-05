// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../data/database/database_helper.dart';
import '../../../data/models/contact.dart';
import '../../../shared/widgets/contact_avatar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/theme/app_theme.dart';
import '../../auth/screens/login_screen.dart';
import 'add_contact_screen.dart';
import 'edit_contact_screen.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();

  List<Contact> _contacts = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text);
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final results = _searchQuery.isEmpty
        ? await _db.getAllContacts()
        : await _db.searchContacts(_searchQuery);
    if (!mounted) return;
    setState(() {
      _contacts = results;
      _isLoading = false;
    });
  }

  Future<void> _deleteContact(Contact contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Delete "${contact.name}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style:
                TextButton.styleFrom(foregroundColor: ContactoTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && contact.id != null) {
      await _db.deleteContact(contact.id!);
      await _loadContacts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('"${contact.name}" deleted.'),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ContactoTheme.background,
      appBar: AppBar(
        title: const Text('Contacto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: 'Lock',
            onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen())),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search contacts…',
                hintStyle:
                    TextStyle(color: Colors.white.withOpacity(0.65)),
                prefixIcon: Icon(Icons.search,
                    color: Colors.white.withOpacity(0.8)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () => _searchController.clear())
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.18),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? EmptyState(
                  icon: Icons.people_outline,
                  title: _searchQuery.isNotEmpty
                      ? 'No results for "$_searchQuery"'
                      : 'No contacts yet',
                  subtitle: _searchQuery.isEmpty
                      ? 'Tap the button below to add your first contact.'
                      : null,
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _contacts.length,
                  itemBuilder: (ctx, i) => _buildTile(_contacts[i]),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const AddContactScreen()));
          _loadContacts();
        },
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Contact',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildTile(Contact contact) {
    return Dismissible(
      key: Key('contact_${contact.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _deleteContact(contact);
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
            color: ContactoTheme.error,
            borderRadius: BorderRadius.circular(14)),
        child:
            const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
        child: ListTile(
          leading: ContactAvatar(name: contact.name),
          title: Text(contact.name,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: ContactoTheme.textPrimary)),
          subtitle: _buildSubtitle(contact),
          trailing: const Icon(Icons.chevron_right,
              color: Color(0xFFD1D5DB), size: 20),
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => EditContactScreen(contact: contact)));
            _loadContacts();
          },
        ),
      ),
    );
  }

  Widget? _buildSubtitle(Contact contact) {
    final sub = (contact.phone != null && contact.phone!.isNotEmpty)
        ? contact.phone!
        : (contact.email != null && contact.email!.isNotEmpty)
            ? contact.email!
            : null;
    if (sub == null) return null;
    return Text(sub,
        style: const TextStyle(
            color: ContactoTheme.textSecondary, fontSize: 13));
  }
}
