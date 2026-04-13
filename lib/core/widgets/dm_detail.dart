// dm_detail_screen.dart
// Personal chat detail — shows only notifications toggle + media tabs (no members list).

import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';
import 'chat_data.dart';
// import 'pinned_messages_modal.dart';

class DmDetailScreen extends StatefulWidget {
  final String chatId;
  const DmDetailScreen({super.key, required this.chatId});

  @override
  State<DmDetailScreen> createState() => _DmDetailScreenState();
}

class _DmDetailScreenState extends State<DmDetailScreen> {
  int _mediaTab = 0;
  final List<String> _mediaTabs = ['Pinned', 'Images', 'Videos', 'Documents'];

  ChatItem get _chat => ChatStore.findById(widget.chatId)!;

  void _toggleNotifications() {
    if (_chat.notificationsEnabled) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Disable Notifications?',
              style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
          content: const Text('You will no longer receive alerts for new messages from this person.',
              style: TextStyle(fontFamily: 'Outfit', fontSize: 13)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit'))),
            TextButton(
              onPressed: () {
                setState(() => _chat.notificationsEnabled = false);
                Navigator.pop(ctx);
              },
              child: const Text('Disable', style: TextStyle(color: Colors.red, fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      setState(() => _chat.notificationsEnabled = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = _chat;
    final other = chat.members.firstWhere((m) => !m.isCurrentUser, orElse: () => chat.members.first);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Container(
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
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profile avatar
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: feastLightGreen.withAlpha(150),
                      child: const Icon(Icons.person, size: 40, color: feastGreen),
                    ),
                    const SizedBox(height: 12),
                    Text(chat.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit', color: feastBlack)),
                    Text(
                      other.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(fontSize: 13, fontFamily: 'Outfit', color: other.isOnline ? feastGreen : feastGray),
                    ),
                    const SizedBox(height: 20),

                    // Notifications toggle
                    Container(
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
                          const Expanded(child: Text('Notifications',
                              style: TextStyle(fontSize: 14, fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: feastBlack))),
                          Switch(value: chat.notificationsEnabled, activeColor: feastGreen, onChanged: (_) => _toggleNotifications()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Media tabs
                    Row(
                      children: List.generate(_mediaTabs.length, (i) {
                        final selected = i == _mediaTab;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _mediaTab = i),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(_mediaTabs[i],
                                      style: TextStyle(
                                        fontSize: 13, fontFamily: 'Outfit',
                                        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                                        color: selected ? feastGreen : feastGray.withAlpha(160),
                                      ), textAlign: TextAlign.center),
                                ),
                                Container(height: 2, color: selected ? feastGreen : Colors.transparent),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    _buildDmMediaContent(chat),
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

  Widget _buildDmMediaContent(ChatItem chat) {
    switch (_mediaTab) {
      case 0:
        final pins = chat.pinnedMessages;
        if (pins.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(20),
              child: Text('No pinned messages yet.', style: TextStyle(fontSize: 13, fontFamily: 'Outfit', color: feastGray))));
        }
        return Column(
          children: [
            ...pins.take(3).map((p) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: feastGray.withAlpha(30)),
              ),
              child: Row(children: [
                const Icon(Icons.push_pin, size: 14, color: feastGreen),
                const SizedBox(width: 8),
                Expanded(child: Text(p.text, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontFamily: 'Outfit', color: feastGray.withAlpha(210)))),
                const Icon(Icons.chevron_right, size: 18, color: feastGray),
              ]),
            )),
            GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => PinnedMessagesModal(chat: chat, onChanged: () => setState(() {})),
              ),
              child: const Text('See More',
                  style: TextStyle(fontSize: 13, fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: feastGreen)),
            ),
          ],
        );
      case 1:
        final imgs = chat.sharedMedia.where((m) => m.type == SharedMediaType.image).toList();
        if (imgs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No images shared.', style: TextStyle(fontFamily: 'Outfit', color: feastGray))));
        return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
          itemCount: imgs.length,
          itemBuilder: (_, i) => ClipRRect(borderRadius: BorderRadius.circular(8),
            child: Container(color: feastLightGreen.withAlpha(150),
              child: Center(child: Text(imgs[i].thumbnailEmoji ?? '🖼️', style: const TextStyle(fontSize: 28))))),
        );
      case 2:
        final vids = chat.sharedMedia.where((m) => m.type == SharedMediaType.video).toList();
        if (vids.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No videos shared.', style: TextStyle(fontFamily: 'Outfit', color: feastGray))));
        return Column(children: vids.map((v) => ListTile(leading: const Icon(Icons.play_circle_outline, color: feastGreen), title: Text(v.name, style: const TextStyle(fontFamily: 'Outfit', fontSize: 13)))).toList());
      case 3:
        final docs = chat.sharedMedia.where((m) => m.type == SharedMediaType.document).toList();
        if (docs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No documents shared.', style: TextStyle(fontFamily: 'Outfit', color: feastGray))));
        return Column(children: docs.map((d) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: feastLightGreen.withAlpha(60), borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Icon(Icons.insert_drive_file_outlined, size: 22, color: feastGreen),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d.name, style: const TextStyle(fontSize: 12, fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: feastBlack)),
              if (d.size != null) Text(d.size!, style: TextStyle(fontSize: 11, fontFamily: 'Outfit', color: feastGray.withAlpha(160))),
            ])),
            const Icon(Icons.download_outlined, size: 18, color: feastGreen),
          ]),
        )).toList());
      default:
        return const SizedBox.shrink();
    }
  }
}