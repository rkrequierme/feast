// selected_group_screen.dart
// Used for both event chats AND custom group chats (MyGroup).

import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class SelectedGroupScreen extends StatefulWidget {
  final String chatId;
  const SelectedGroupScreen({super.key, required this.chatId});

  @override
  State<SelectedGroupScreen> createState() => _SelectedGroupScreenState();
}

class _SelectedGroupScreenState extends State<SelectedGroupScreen> {
  int _mediaTab = 0; // 0=Pinned, 1=Images, 2=Videos, 3=Documents
  final List<String> _mediaTabs = ['Pinned', 'Images', 'Videos', 'Documents'];
  final TextEditingController _memberSearchController = TextEditingController();

  ChatItem get _chat => ChatStore.findById(widget.chatId)!;

  @override
  void dispose() {
    _memberSearchController.dispose();
    super.dispose();
  }

  List<ChatMember> get _filteredMembers {
    final q = _memberSearchController.text.toLowerCase();
    if (q.isEmpty) return _chat.members;
    return _chat.members
        .where((m) => m.displayName.toLowerCase().contains(q))
        .toList();
  }

  void _toggleNotifications() {
    if (_chat.notificationsEnabled) {
      // Ask for confirmation before disabling
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Disable Notifications?',
            style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 17),
          ),
          content: const Text(
            'You will no longer receive alerts for new messages in this chat.',
            style: TextStyle(fontFamily: 'Outfit', fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit')),
            ),
            TextButton(
              onPressed: () {
                setState(() => _chat.notificationsEnabled = false);
                Navigator.pop(ctx);
              },
              child: const Text('Disable',
                  style: TextStyle(color: Colors.red, fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      setState(() => _chat.notificationsEnabled = true);
    }
  }

  void _editGroupName() {
    final c = TextEditingController(text: _chat.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Group Name', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Group Name',
            labelStyle: TextStyle(fontFamily: 'Outfit'),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit'))),
          TextButton(
            onPressed: () {
              if (c.text.trim().isNotEmpty) setState(() => _chat.name = c.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: feastGreen, fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _editGroupDescription() {
    final c = TextEditingController(text: _chat.description);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Description', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        content: TextField(
          controller: c,
          maxLines: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Description',
            labelStyle: TextStyle(fontFamily: 'Outfit'),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit'))),
          TextButton(
            onPressed: () {
              if (c.text.trim().isNotEmpty) setState(() => _chat.description = c.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: feastGreen, fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _editGroupEmoji() {
    final emojis = ['🍱', '👥', '🏥', '🌿', '🎗️', '🏫', '🤝', '🌟', '🍚', '💚', '🏡', '🎉'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Group Logo', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: emojis.map((e) => GestureDetector(
            onTap: () {
              setState(() => _chat.groupEmoji = e);
              Navigator.pop(ctx);
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: feastGray.withAlpha(60)),
              ),
              child: Center(child: Text(e, style: const TextStyle(fontSize: 24))),
            ),
          )).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit'))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = _chat;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(chat),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  children: [
                    _buildGroupHeader(chat),
                    _buildGroupName(chat),
                    _buildDescription(chat),
                    _buildNotificationsToggle(chat),
                    const SizedBox(height: 16),
                    _buildMediaTabs(),
                    const SizedBox(height: 10),
                    _buildMediaContent(chat),
                    const SizedBox(height: 16),
                    Divider(height: 1, color: feastGray.withAlpha(40)),
                    const SizedBox(height: 12),
                    _buildParticipantsHeader(chat),
                    _buildMemberSearch(),
                    ..._filteredMembers.map((m) => _buildMemberItem(m, chat)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FeastBottomNav(currentIndex: 3),
    );
  }

  Widget _buildAppBar(ChatItem chat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: feastLightGreen,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: feastBlack), onPressed: () => Navigator.pop(context)),
          Expanded(
            child: Center(
              child: Text(chat.name,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Outfit', color: feastBlack)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: feastBlack),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link, color: feastGreen),
              title: const Text('Share Group Link', style: TextStyle(fontFamily: 'Outfit')),
              onTap: () { Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined, color: Colors.orange),
              title: const Text('Report Group', style: TextStyle(fontFamily: 'Outfit')),
              onTap: () { Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Leave Group', style: TextStyle(fontFamily: 'Outfit', color: Colors.red)),
              onTap: () { Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeader(ChatItem chat) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [feastLightGreen.withAlpha(200), feastLighterBlue.withAlpha(160)],
            ),
          ),
          child: Center(
            child: Text(chat.groupEmoji, style: const TextStyle(fontSize: 60)),
          ),
        ),
        if (chat.isAdmin)
          Positioned(
            bottom: 10,
            right: 14,
            child: GestureDetector(
              onTap: _editGroupEmoji,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.edit, size: 16, color: feastGreen),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGroupName(ChatItem chat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            chat.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit', color: feastBlack),
            textAlign: TextAlign.center,
          ),
          if (chat.isAdmin) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _editGroupName,
              child: const Icon(Icons.edit, size: 16, color: feastGreen),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescription(ChatItem chat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: feastGray.withAlpha(30)),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 17, color: feastGray.withAlpha(160)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                chat.description.isNotEmpty ? chat.description : 'No description.',
                style: TextStyle(fontSize: 13, fontFamily: 'Outfit', color: feastGray.withAlpha(210), height: 1.4),
              ),
            ),
            if (chat.isAdmin)
              GestureDetector(
                onTap: _editGroupDescription,
                child: const Icon(Icons.edit, size: 16, color: feastGreen),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsToggle(ChatItem chat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: feastGray.withAlpha(30)),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Icon(Icons.notifications_outlined, size: 20, color: feastBlack),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Notifications',
                  style: TextStyle(fontSize: 14, fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: feastBlack)),
            ),
            Switch(
              value: chat.notificationsEnabled,
              activeColor: feastGreen,
              onChanged: (_) => _toggleNotifications(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(_mediaTabs.length, (i) {
          final selected = i == _mediaTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _mediaTab = i),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Text(
                      _mediaTabs[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Outfit',
                        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                        color: selected ? feastGreen : feastGray.withAlpha(160),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(height: 2, color: selected ? feastGreen : Colors.transparent),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMediaContent(ChatItem chat) {
    switch (_mediaTab) {
      case 0:
        return _buildPinnedTab(chat);
      case 1:
        return _buildMediaGrid(chat, SharedMediaType.image, '🖼️', 'No images shared yet.');
      case 2:
        return _buildMediaGrid(chat, SharedMediaType.video, '🎬', 'No videos shared yet.');
      case 3:
        return _buildDocumentsList(chat);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPinnedTab(ChatItem chat) {
    final pins = chat.pinnedMessages;
    if (pins.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text('No pinned messages yet.',
              style: TextStyle(fontSize: 13, fontFamily: 'Outfit', color: feastGray)),
        ),
      );
    }

    final preview = pins.take(3).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ...preview.map((p) => _buildPinnedItem(p, chat)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _showAllPinned(chat),
            child: const Text(
              'See More',
              style: TextStyle(fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: feastGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllPinned(ChatItem chat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PinnedMessagesModal(
        chat: chat,
        onChanged: () => setState(() {}),
      ),
    );
  }

  Widget _buildPinnedItem(PinnedMessage p, ChatItem chat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: feastGray.withAlpha(30)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          const Icon(Icons.push_pin, size: 14, color: feastGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              p.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontFamily: 'Outfit', color: feastGray.withAlpha(210), height: 1.4),
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: feastGray),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(ChatItem chat, SharedMediaType type, String emptyIcon, String emptyText) {
    final items = chat.sharedMedia.where((m) => m.type == type).toList();
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Text(emptyIcon, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(emptyText, style: TextStyle(fontSize: 13, fontFamily: 'Outfit', color: feastGray.withAlpha(160))),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: feastLightGreen.withAlpha(150),
            child: Center(
              child: Text(items[i].thumbnailEmoji ?? '🖼️', style: const TextStyle(fontSize: 28)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentsList(ChatItem chat) {
    final docs = chat.sharedMedia
        .where((m) => m.type != SharedMediaType.image && m.type != SharedMediaType.video)
        .toList();
    if (docs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No documents shared yet.',
            style: TextStyle(fontSize: 13, fontFamily: 'Outfit', color: feastGray))),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: docs.map((d) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: feastLightGreen.withAlpha(60),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.insert_drive_file_outlined, size: 22, color: feastGreen),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.name, style: const TextStyle(fontSize: 12, fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: feastBlack)),
                    if (d.size != null)
                      Text(d.size!, style: TextStyle(fontSize: 11, fontFamily: 'Outfit', color: feastGray.withAlpha(160))),
                  ],
                ),
              ),
              const Icon(Icons.download_outlined, size: 18, color: feastGreen),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildParticipantsHeader(ChatItem chat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.people, size: 18, color: feastBlack),
          const SizedBox(width: 6),
          Text(
            '${chat.members.length} Participants',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Outfit', color: feastBlack),
          ),
          const Spacer(),
          if (chat.isAdmin)
            IconButton(
              icon: const Icon(Icons.person_remove_outlined, size: 20),
              color: feastGray,
              splashRadius: 20,
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => RemoveMemberModal(
                  chat: chat,
                  onChanged: () => setState(() {}),
                ),
              ),
            ),
          if (chat.isAdmin)
            IconButton(
              icon: const Icon(Icons.person_add_outlined, size: 20),
              color: feastGray,
              splashRadius: 20,
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddMemberModal(
                  chatId: chat.id,
                  onAdded: () => setState(() {}),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMemberSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: feastLightGreen.withAlpha(80),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Icon(Icons.search, size: 18, color: feastGray.withAlpha(160)),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: _memberSearchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 13, fontFamily: 'Outfit', color: feastBlack),
                decoration: InputDecoration(
                  hintText: 'Search members...',
                  hintStyle: TextStyle(fontSize: 13, fontFamily: 'Outfit', color: feastGray.withAlpha(150)),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberItem(ChatMember m, ChatItem chat) {
    String? roleLabel;
    Color? badgeColor;
    if (m.role == MemberRole.leader) { roleLabel = 'Leader'; badgeColor = feastGreen; }
    if (m.role == MemberRole.coLeader) { roleLabel = 'Co-Leader'; badgeColor = const Color(0xFF0F6E56); }

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: feastLightGreen.withAlpha(140),
                  child: const Icon(Icons.person, size: 22, color: feastGreen),
                ),
                if (m.isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: feastGreen, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Text(m.displayName, style: const TextStyle(fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.w500, color: feastBlack)),
                  if (m.isCurrentUser) ...[
                    const SizedBox(width: 4),
                    Text('(You)', style: TextStyle(fontSize: 11, fontFamily: 'Outfit', color: feastGray.withAlpha(150))),
                  ],
                ],
              ),
            ),
            if (roleLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12)),
                child: Text(roleLabel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
              ),
          ],
        ),
      ),
    );
  }
}