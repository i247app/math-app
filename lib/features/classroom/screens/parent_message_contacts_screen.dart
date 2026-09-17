import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/classroom/widgets/parent_messages/parent_message_contact_data.dart';
import 'package:numi/features/classroom/widgets/parent_messages/parent_message_contact_list_tile.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/shared/widgets/app_search_field.dart';

class ParentMessageContactsScreen extends StatefulWidget {
  const ParentMessageContactsScreen({
    super.key,
    required this.primaryTeacherName,
  });

  final String primaryTeacherName;

  @override
  State<ParentMessageContactsScreen> createState() =>
      _ParentMessageContactsScreenState();
}

class _ParentMessageContactsScreenState
    extends State<ParentMessageContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final query = _query.trim().toLowerCase();
    final contacts =
        parentMessageContacts(
              context,
              primaryTeacherName: widget.primaryTeacherName,
            )
            .where((contact) {
              return query.isEmpty ||
                  contact.name.toLowerCase().contains(query) ||
                  contact.status.toLowerCase().contains(query);
            })
            .toList(growable: false);
    final online = contacts
        .where((contact) => contact.isOnline)
        .toList(growable: false);
    final offline = contacts
        .where((contact) => !contact.isOnline)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: Column(
        children: [
          PageHeader(
            title: context.getText(AppKeys.parentMessagesContactsTitle),
            backgroundColor: colors.pageBackground,
            actionWidth: 52,
            horizontalPadding: 12,
            titleFontSize: FontSize.xxxl,
            leading: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              color: colors.brandStrong,
              tooltip: context.getText(AppKeys.back),
            ),
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(14, 14, 14, 24 + bottomInset),
              children: [
                AppSearchField(
                  controller: _searchController,
                  hintText: context.getText(AppKeys.searchHint),
                  onChanged: (value) => setState(() => _query = value),
                ),
                if (online.isNotEmpty) ...[
                  _ContactSectionLabel(
                    label: context.getText(AppKeys.parentMessagesOnlineLabel),
                    color: colors.brandStrong,
                  ),
                  for (final contact in online)
                    ParentMessageContactListTile(
                      key: ValueKey('online-contact-${contact.name}'),
                      contact: contact,
                      onTap: _showComingSoon,
                      onMore: _showComingSoon,
                    ),
                ],
                if (offline.isNotEmpty) ...[
                  _ContactSectionLabel(
                    label: context.getText(AppKeys.parentMessagesOfflineLabel),
                    color: colors.textMuted,
                  ),
                  for (final contact in offline)
                    ParentMessageContactListTile(
                      key: ValueKey('offline-contact-${contact.name}'),
                      contact: contact,
                      onTap: _showComingSoon,
                      onMore: _showComingSoon,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon() {
    HapticFeedback.selectionClick();
    context.showInfoDialog(context.getText(AppKeys.studentClassComingSoon));
  }
}

class _ContactSectionLabel extends StatelessWidget {
  const _ContactSectionLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 6),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: FontSize.xxxs,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
