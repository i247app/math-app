import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/contact/contact_model.dart';
import '../../../data/providers/contact_provider.dart';

class ContactDetailScreen extends StatefulWidget {
  final ContactModel contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  bool _marking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.contact.isRead != true) {
        setState(() => _marking = true);
        await context.read<ContactProvider>().markAsRead(widget.contact.id);
        if (mounted) setState(() => _marking = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contact = context.select<ContactProvider, ContactModel?>(
      (p) => p.items?.firstWhere(
        (it) => it.id == widget.contact.id,
        orElse: () => widget.contact,
      ),
    );
    final isRead = contact?.isRead ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Contact Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue,
                  child: Text(
                    (contact?.contactName.split(' ').first.characters.first ??
                            'A')
                        .toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact?.contactName ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact?.contactEmail ?? '',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contact?.contactPhone ?? '',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                if (_marking)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Message',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  contact?.contactMessage ?? '',
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
                const SizedBox(width: 12),
                if (isRead)
                  OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.mark_email_read),
                    label: const Text('Read'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
