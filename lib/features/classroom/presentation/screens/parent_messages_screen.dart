import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/classroom/presentation/screens/parent_message_contacts_screen.dart';
import 'package:numi/features/classroom/widgets/parent_messages/parent_message_contact_data.dart';
import 'package:numi/features/classroom/widgets/parent_messages/parent_message_contact_item.dart';
import 'package:numi/features/classroom/widgets/parent_messages/parent_message_preview_tile.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/shared/widgets/app_search_field.dart';

class ParentMessagesScreen extends StatefulWidget {
  const ParentMessagesScreen({
    super.key,
    required this.className,
    required this.teacherName,
  });

  final String className;
  final String teacherName;

  @override
  State<ParentMessagesScreen> createState() => _ParentMessagesScreenState();
}

class _ParentMessagesScreenState extends State<ParentMessagesScreen> {
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
    final contacts = _contacts(context);
    final conversations = _conversations(context)
        .where((conversation) {
          final query = _query.trim().toLowerCase();
          return query.isEmpty ||
              conversation.name.toLowerCase().contains(query) ||
              conversation.preview.toLowerCase().contains(query);
        })
        .toList(growable: false);

    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: Column(
        children: [
          PageHeader(
            title: context.getText(AppKeys.parentMessagesTitle),
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
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _openContacts,
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.chevron_right_rounded, size: 18),
                      label: Text(
                        context.getText(AppKeys.viewAll),
                        style: const TextStyle(
                          fontSize: FontSize.xs,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 82,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: contacts.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return ParentMessageContactItem(
                        name: contact.name,
                        asset: contact.asset,
                        onTap: _showComingSoon,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Column(
                    spacing: 10,
                    children: [
                      for (final conversation in conversations)
                        ParentMessagePreviewTile(
                          key: ValueKey('parent-message-${conversation.name}'),
                          name: conversation.name,
                          preview: conversation.preview,
                          time: conversation.time,
                          asset: conversation.asset,
                          isGroup: conversation.isGroup,
                          unreadCount: conversation.unreadCount,
                          onTap: _showComingSoon,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<ParentMessageContactData> _contacts(BuildContext context) =>
      parentMessageContacts(
        context,
        primaryTeacherName: widget.teacherName,
      ).where((contact) => contact.isOnline).toList(growable: false);

  List<_ParentMessageConversation> _conversations(BuildContext context) => [
    _ParentMessageConversation(
      name: widget.className,
      preview: context.getText(AppKeys.parentMessagesGroupPreview),
      time: '09:30',
      isGroup: true,
      unreadCount: 5,
    ),
    _ParentMessageConversation(
      name: widget.teacherName,
      preview: context.getText(AppKeys.homeMessageBodyOne),
      time: context.getText(AppKeys.homeMessageTimeOne),
      asset: homeTeacherAvatarOneAsset,
    ),
    _ParentMessageConversation(
      name: context.getText(AppKeys.homeMessageTeacherTwo),
      preview: context.getText(AppKeys.homeMessageBodyTwo),
      time: context.getText(AppKeys.homeMessageTimeTwo),
      asset: homeTeacherAvatarTwoAsset,
    ),
    _ParentMessageConversation(
      name: context.getText(AppKeys.parentMessagesTeacherThree),
      preview: context.getText(AppKeys.parentMessagesBodyThree),
      time: context.getText(AppKeys.parentMessagesTimeThree),
      asset: homeTeacherAvatarOneAsset,
    ),
    _ParentMessageConversation(
      name: context.getText(AppKeys.parentMessagesTeacherFour),
      preview: context.getText(AppKeys.parentMessagesBodyFour),
      time: context.getText(AppKeys.parentMessagesTimeFour),
      asset: homeTeacherAvatarTwoAsset,
    ),
  ];

  void _showComingSoon() {
    HapticFeedback.selectionClick();
    context.showInfoDialog(context.getText(AppKeys.studentClassComingSoon));
  }

  void _openContacts() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            ParentMessageContactsScreen(primaryTeacherName: widget.teacherName),
      ),
    );
  }
}

class _ParentMessageConversation {
  const _ParentMessageConversation({
    required this.name,
    required this.preview,
    required this.time,
    this.asset,
    this.isGroup = false,
    this.unreadCount = 0,
  });

  final String name;
  final String preview;
  final String time;
  final String? asset;
  final bool isGroup;
  final int unreadCount;
}
