// chat_data.dart
// Central in-memory data store. Replace with Firestore streams in production.

enum ChatType { personal, event, myGroup }

class ChatMember {
  final String uid;
  final String displayName;
  final MemberRole role;
  final bool isCurrentUser;
  bool isOnline;

  ChatMember({
    required this.uid,
    required this.displayName,
    this.role = MemberRole.member,
    this.isCurrentUser = false,
    this.isOnline = false,
  });
}

enum MemberRole { member, coLeader, leader }

class PinnedMessage {
  final String id;
  final String text;
  final String fromName;
  final String time;

  PinnedMessage({
    required this.id,
    required this.text,
    required this.fromName,
    required this.time,
  });
}

class SharedMedia {
  final String id;
  final SharedMediaType type;
  final String name;
  final String? size;
  final String? thumbnailEmoji; // placeholder; replace with real URLs

  SharedMedia({
    required this.id,
    required this.type,
    required this.name,
    this.size,
    this.thumbnailEmoji,
  });
}

enum SharedMediaType { image, video, document }

class ChatMessage {
  final String id;
  final String senderUid;
  final String senderName;
  final MemberRole? senderRole;
  final String text;
  final String time;
  final bool isMe;
  final bool hasImages;
  List<String> imageEmojis;

  ChatMessage({
    required this.id,
    required this.senderUid,
    required this.senderName,
    this.senderRole,
    required this.text,
    required this.time,
    required this.isMe,
    this.hasImages = false,
    this.imageEmojis = const [],
  });
}

class ChatItem {
  final String id;
  final ChatType type;
  String name;
  String? avatarUrl;
  String groupEmoji; // used as group logo placeholder
  String lastMessage;
  String lastMessageTime;
  int unreadCount;
  bool isOnline;
  int onlineCount;
  int totalCount;
  bool notificationsEnabled;
  bool isAdmin;
  String description;
  List<ChatMember> members;
  List<PinnedMessage> pinnedMessages;
  List<SharedMedia> sharedMedia;
  List<ChatMessage> messages;

  ChatItem({
    required this.id,
    required this.type,
    required this.name,
    this.avatarUrl,
    this.groupEmoji = '👥',
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.onlineCount = 0,
    this.totalCount = 0,
    this.notificationsEnabled = true,
    this.isAdmin = false,
    this.description = '',
    this.members = const [],
    this.pinnedMessages = const [],
    this.sharedMedia = const [],
    this.messages = const [],
  });
}

// ─── Singleton store ──────────────────────────────────────────────────────────
class ChatStore {
  ChatStore._();

  static final List<ChatItem> chats = [
    // ── Personal: Darlene Lopez ───────────────────────────────────────────────
    ChatItem(
      id: 'p_darlene',
      type: ChatType.personal,
      name: 'Darlene Lopez',
      groupEmoji: '👩',
      lastMessage: 'Pls take a look at the donations.',
      lastMessageTime: '5 min',
      unreadCount: 5,
      isOnline: true,
      description: '',
      members: [
        ChatMember(uid: 'me', displayName: 'Juan De La Cruz', isCurrentUser: true, isOnline: true),
        ChatMember(uid: 'u_darlene', displayName: 'Darlene Lopez', isOnline: true),
      ],
      pinnedMessages: [
        PinnedMessage(id: 'pin1', text: 'Reminder: donation drop-off is at the barangay hall before 5PM.', fromName: 'Darlene Lopez', time: '3:00 PM'),
      ],
      sharedMedia: [
        SharedMedia(id: 'm1', type: SharedMediaType.image, name: 'Donations Photo.jpg', thumbnailEmoji: '📦'),
        SharedMedia(id: 'm2', type: SharedMediaType.document, name: 'Donation List.pdf', size: '80 KB'),
      ],
      messages: [
        ChatMessage(id: '1', senderUid: 'u_darlene', senderName: 'Darlene Lopez', text: 'Hi Juan! Are you around this Saturday for the donation drive?', time: '4:10 PM', isMe: false),
        ChatMessage(id: '2', senderUid: 'me', senderName: 'Juan De La Cruz', text: 'Yes, I\'ll be there early to help sort.', time: '4:15 PM', isMe: true),
        ChatMessage(id: '3', senderUid: 'u_darlene', senderName: 'Darlene Lopez', text: 'Pls take a look at the donations. Some items may already be expired.', time: '4:25 PM', isMe: false),
      ],
    ),

    // ── Group: T.S. Cruz Food Bank ────────────────────────────────────────────
    ChatItem(
      id: 'g_foodbank',
      type: ChatType.myGroup,
      name: 'T.S. Cruz Food Bank',
      groupEmoji: '🍱',
      lastMessage: 'Hello guys, we have discussed about ...',
      lastMessageTime: '30 min',
      unreadCount: 0,
      isOnline: true,
      onlineCount: 7,
      totalCount: 12,
      isAdmin: true,
      description: 'We are a group dedicated to helping out the T.S. Cruz community by giving food.',
      members: [
        ChatMember(uid: 'me', displayName: 'Juan De La Cruz', role: MemberRole.coLeader, isCurrentUser: true, isOnline: true),
        ChatMember(uid: 'u_jose', displayName: 'Jose De La Cruz', role: MemberRole.leader, isOnline: true),
        ChatMember(uid: 'u_marvin', displayName: 'Marvin Reyes', role: MemberRole.coLeader, isOnline: true),
        ChatMember(uid: 'u_gregory', displayName: 'Gregory Bautista', isOnline: false),
        ChatMember(uid: 'u_samuel', displayName: 'Samuel Del Rosario', isOnline: true),
        ChatMember(uid: 'u_bambang', displayName: 'Bambang Gonzales', isOnline: false),
        ChatMember(uid: 'u_sururi', displayName: 'Sururi Aquino', isOnline: true),
        ChatMember(uid: 'u_michael', displayName: 'Michael Ramos', isOnline: false),
        ChatMember(uid: 'u_jackobs', displayName: 'Jackobs Garcia', isOnline: false),
        ChatMember(uid: 'u_anastasia', displayName: 'Anastasia Lopez', isOnline: true),
        ChatMember(uid: 'u_fuelta', displayName: 'Fuelta Fernandez', isOnline: false),
        ChatMember(uid: 'u_kimini', displayName: 'Kimini Mendoza', isOnline: true),
      ],
      pinnedMessages: [
        PinnedMessage(id: 'pin1', text: 'The next thing we will consider is how to approach the citizens of T.S. Cruz as we gather volunteers for the distribution day.', fromName: 'Jose De La Cruz', time: '12:00 PM'),
        PinnedMessage(id: 'pin2', text: 'Pls keep a note that we will proceed with the event as scheduled. Make sure you join the roll call at 7AM sharp.', fromName: 'Jose De La Cruz', time: '10:00 AM'),
        PinnedMessage(id: 'pin3', text: 'The event will be held in front of the T.S. Cruz Elementary School this coming Monday morning.', fromName: 'Marvin Reyes', time: 'Yesterday'),
      ],
      sharedMedia: [
        SharedMedia(id: 'm1', type: SharedMediaType.image, name: 'Setup Photo 1.jpg', thumbnailEmoji: '🏫'),
        SharedMedia(id: 'm2', type: SharedMediaType.image, name: 'Volunteers.jpg', thumbnailEmoji: '🤝'),
        SharedMedia(id: 'm3', type: SharedMediaType.image, name: 'Food Packs.jpg', thumbnailEmoji: '🍱'),
        SharedMedia(id: 'm4', type: SharedMediaType.video, name: 'Day 1 Recap.mp4', size: '16 MB', thumbnailEmoji: '🎬'),
        SharedMedia(id: 'm5', type: SharedMediaType.document, name: 'Food Bank Progress Report.pdf', size: '200 KB'),
        SharedMedia(id: 'm6', type: SharedMediaType.document, name: 'Volunteer Schedule.xlsx', size: '45 KB'),
      ],
      messages: [
        ChatMessage(id: '1', senderUid: 'u_jose', senderName: 'Jose De La Cruz', senderRole: MemberRole.leader, text: 'Hello guys, we have discussed about the TS Cruz Food Bank plan and our decision is to go to start today. We will have a very big gathering once this event starts! These are some images about our agenda.', time: '12:30 PM', isMe: false, hasImages: true, imageEmojis: ['🏝️', '🏫', '🌿']),
        ChatMessage(id: '2', senderUid: 'me', senderName: 'Juan De La Cruz', text: "That's very nice deed! You guys made a very good decision. Can't wait to go help out!", time: '1:00 PM', isMe: true),
      ],
    ),

    // ── Personal: Lee Fernandez ───────────────────────────────────────────────
    ChatItem(
      id: 'p_lee',
      type: ChatType.personal,
      name: 'Lee Fernandez',
      groupEmoji: '🧑',
      lastMessage: "Yes, that's gonna help them out, hopefully.",
      lastMessageTime: '1 hr',
      unreadCount: 0,
      isOnline: false,
      description: '',
      members: [
        ChatMember(uid: 'me', displayName: 'Juan De La Cruz', isCurrentUser: true, isOnline: true),
        ChatMember(uid: 'u_lee', displayName: 'Lee Fernandez', isOnline: false),
      ],
      pinnedMessages: [],
      sharedMedia: [],
      messages: [
        ChatMessage(id: '1', senderUid: 'me', senderName: 'Juan De La Cruz', text: 'Lee, are you joining the food bank event this weekend?', time: '11:00 AM', isMe: true),
        ChatMessage(id: '2', senderUid: 'u_lee', senderName: 'Lee Fernandez', text: "Yes, that's gonna help them out, hopefully. I'll bring extra bags.", time: '11:30 AM', isMe: false),
      ],
    ),

    // ── Personal: Ronald Mendoza ──────────────────────────────────────────────
    ChatItem(
      id: 'p_ronald',
      type: ChatType.personal,
      name: 'Ronald Mendoza',
      groupEmoji: '👨',
      lastMessage: '✔✔ Thank you po! 😊',
      lastMessageTime: 'Yesterday',
      unreadCount: 0,
      isOnline: false,
      description: '',
      members: [
        ChatMember(uid: 'me', displayName: 'Juan De La Cruz', isCurrentUser: true, isOnline: true),
        ChatMember(uid: 'u_ronald', displayName: 'Ronald Mendoza', isOnline: false),
      ],
      pinnedMessages: [],
      sharedMedia: [
        SharedMedia(id: 'm1', type: SharedMediaType.document, name: 'Aid Request Form.pdf', size: '55 KB'),
      ],
      messages: [
        ChatMessage(id: '1', senderUid: 'me', senderName: 'Juan De La Cruz', text: 'Ronald, I already forwarded your aid request to the barangay captain.', time: 'Yesterday', isMe: true),
        ChatMessage(id: '2', senderUid: 'u_ronald', senderName: 'Ronald Mendoza', text: '✔✔ Thank you po! 😊', time: 'Yesterday', isMe: false),
      ],
    ),

    // ── Event: Barangay Medical Mission ───────────────────────────────────────
    ChatItem(
      id: 'e_medmission',
      type: ChatType.event,
      name: 'Barangay Medical Mission',
      groupEmoji: '🏥',
      lastMessage: "I'm happy this event has such great ...",
      lastMessageTime: 'Yesterday',
      unreadCount: 0,
      isOnline: false,
      onlineCount: 4,
      totalCount: 20,
      isAdmin: false,
      description: 'Free medical check-up and medicine distribution for all barangay residents. Bring your Barangay ID.',
      members: [
        ChatMember(uid: 'me', displayName: 'Juan De La Cruz', isCurrentUser: true, isOnline: true),
        ChatMember(uid: 'u_albert', displayName: 'Albert Flores', role: MemberRole.leader, isOnline: false),
        ChatMember(uid: 'u_drreyes', displayName: 'Dr. Maria Reyes', role: MemberRole.coLeader, isOnline: true),
        ChatMember(uid: 'u_nena', displayName: 'Nena Cruz', isOnline: false),
      ],
      pinnedMessages: [
        PinnedMessage(id: 'pin1', text: 'Bring your Barangay ID and a companion if needed. Queue starts at 8AM sharp at the covered court.', fromName: 'Dr. Maria Reyes', time: '10:00 AM'),
      ],
      sharedMedia: [
        SharedMedia(id: 'm1', type: SharedMediaType.image, name: 'Medical Booth Setup.jpg', thumbnailEmoji: '🏥'),
        SharedMedia(id: 'm2', type: SharedMediaType.image, name: 'Medicine Packs.jpg', thumbnailEmoji: '💊'),
        SharedMedia(id: 'm3', type: SharedMediaType.document, name: 'Medical Mission Schedule.pdf', size: '120 KB'),
      ],
      messages: [
        ChatMessage(id: '1', senderUid: 'u_albert', senderName: 'Albert Flores', senderRole: MemberRole.leader, text: 'Welcome to the Barangay Medical Mission chat! We are coordinating volunteers and supplies here.', time: 'Yesterday', isMe: false),
        ChatMessage(id: '2', senderUid: 'me', senderName: 'Juan De La Cruz', text: "I'm happy this event has such great community support! Looking forward to helping.", time: 'Yesterday', isMe: true),
      ],
    ),
  ];

  static void markRead(String chatId) {
    final idx = chats.indexWhere((c) => c.id == chatId);
    if (idx != -1) chats[idx].unreadCount = 0;
  }

  static void addChat(ChatItem chat) {
    chats.insert(0, chat);
  }

  static ChatItem? findById(String id) {
    try {
      return chats.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static void addMessage(String chatId, ChatMessage msg) {
    final chat = findById(chatId);
    if (chat == null) return;
    chat.messages.add(msg);
    chat.lastMessage = msg.text;
    chat.lastMessageTime = 'Just now';
  }

  static void pinMessage(String chatId, ChatMessage msg) {
    final chat = findById(chatId);
    if (chat == null) return;
    final alreadyPinned = chat.pinnedMessages.any((p) => p.id == msg.id);
    if (!alreadyPinned) {
      chat.pinnedMessages.add(PinnedMessage(
        id: msg.id,
        text: msg.text,
        fromName: msg.senderName,
        time: msg.time,
      ));
    }
  }

  static void unpinMessage(String chatId, String pinId) {
    final chat = findById(chatId);
    chat?.pinnedMessages.removeWhere((p) => p.id == pinId);
  }

  static void removeMember(String chatId, String uid) {
    final chat = findById(chatId);
    chat?.members.removeWhere((m) => m.uid == uid);
  }

  static void addMember(String chatId, ChatMember member) {
    final chat = findById(chatId);
    if (chat == null) return;
    final exists = chat.members.any((m) => m.uid == member.uid);
    if (!exists) chat.members.add(member);
  }
}