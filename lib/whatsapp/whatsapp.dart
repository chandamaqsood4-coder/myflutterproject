import 'package:flutter/material.dart';

const Color mintGreen = Color(0xFFA8E6CF);
const Color tealColor = Color(0xFF66BFBF);
const Color lightGrey = Color(0xFFF2F2F2);

class WhatsAppApp extends StatelessWidget {
  const WhatsAppApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WhatsApp Premium',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: tealColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const WhatsAppPremiumWhite(),
    );
  }
}

// ======================================================
// CHAT MODEL
// ======================================================

class Chat {
  final String name;
  String msg;
  final String time;
  int count;
  final bool pinned;
  final Color color;
  final bool isGroup;

  Chat({
    required this.name,
    required this.msg,
    required this.time,
    required this.count,
    required this.pinned,
    required this.color,
    required this.isGroup,
  });
}

// ======================================================
// MAIN CHAT SCREEN
// ======================================================

class WhatsAppPremiumWhite extends StatefulWidget {
  const WhatsAppPremiumWhite({super.key});

  @override
  State<WhatsAppPremiumWhite> createState() => _WhatsAppPremiumWhiteState();
}

class _WhatsAppPremiumWhiteState extends State<WhatsAppPremiumWhite> {
  String selectedFilter = 'All';

  int selectedBottomIndex = 0;

  final TextEditingController searchController = TextEditingController();

  final List<Chat> chats = [
    Chat(
      name: ' Team',
      msg: 'Sarah: The new mockups are ready to review',
      time: '10:04',
      count: 3,
      pinned: true,
      color: Colors.blueGrey,
      isGroup: true,
    ),
    Chat(
      name: 'bhai',
      msg: "You: Sounds good! Let's meet tomorrow",
      time: '09:32',
      count: 0,
      pinned: false,
      color: const Color.fromARGB(255, 161, 124, 112),
      isGroup: false,
    ),
    Chat(
      name: 'Mom',
      msg: 'Calling you now ❤️',
      time: 'Yesterday',
      count: 0,
      pinned: false,
      color: const Color.fromARGB(255, 131, 109, 77),
      isGroup: false,
    ),
    Chat(
      name: 'Family Group',
      msg: 'sister: assalam o alikum',
      time: 'Yesterday',
      count: 7,
      pinned: false,
      color: const Color.fromARGB(255, 73, 108, 104),
      isGroup: true,
    ),
    Chat(
      name: 'friend',
      msg: "Haha that's hilarious 😂",
      time: 'Monday',
      count: 0,
      pinned: false,
      color: const Color.fromARGB(255, 86, 92, 124),
      isGroup: false,
    ),
  ];

  List<Chat> get filteredChats {
    final query = searchController.text.toLowerCase().trim();

    return chats.where((chat) {
      final matchesSearch =
          chat.name.toLowerCase().contains(query) ||
          chat.msg.toLowerCase().contains(query);

      bool matchesFilter = true;

      if (selectedFilter == 'Unread') {
        matchesFilter = chat.count > 0;
      } else if (selectedFilter == 'Groups') {
        matchesFilter = chat.isGroup;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void openPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= HEADER =================
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chats',
                    style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900),
                  ),

                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Camera',
                        onPressed: () {
                          openPage(const CameraScreen());
                        },
                        icon: const Icon(Icons.camera_alt_outlined, size: 27),
                      ),

                      IconButton(
                        tooltip: 'New Chat',
                        onPressed: () {
                          openPage(
                            NewChatScreen(
                              onSelectContact: (name) {
                                final existing = chats.where(
                                  (chat) => chat.name == name,
                                );

                                if (existing.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatDetailScreen(
                                        chat: existing.first,
                                      ),
                                    ),
                                  );
                                } else {
                                  final newChat = Chat(
                                    name: name,
                                    msg: 'Start a conversation',
                                    time: 'Now',
                                    count: 0,
                                    pinned: false,
                                    color: Colors.teal,
                                    isGroup: false,
                                  );

                                  setState(() {
                                    chats.insert(0, newChat);
                                  });

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ChatDetailScreen(chat: newChat),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 25),
                      ),

                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz, size: 27),
                        onSelected: (value) {
                          switch (value) {
                            case 'settings':
                              openPage(const SettingsScreen());
                              break;

                            case 'starred':
                              openPage(const StarredMessagesScreen());
                              break;

                            case 'select':
                              openPage(SelectChatsScreen(chats: chats));
                              break;
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'starred',
                            child: Text('Starred Messages'),
                          ),
                          PopupMenuItem(
                            value: 'select',
                            child: Text('Select Chats'),
                          ),
                          PopupMenuItem(
                            value: 'settings',
                            child: Text('Settings'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ================= SEARCH BAR =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: mintGreen, width: 1.5),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search chats',
                    prefixIcon: const Icon(Icons.search, color: tealColor),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ================= FILTER CHIPS =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _filterChip('All'),
                  const SizedBox(width: 10),
                  _filterChip('Unread'),
                  const SizedBox(width: 10),
                  _filterChip('Groups'),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ================= CHAT LIST =================
            Expanded(
              child: filteredChats.isEmpty
                  ? const Center(
                      child: Text(
                        'No chats found',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),

                          onTap: () {
                            setState(() {
                              chat.count = 0;
                            });

                            openPage(ChatDetailScreen(chat: chat));
                          },

                          onLongPress: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return SafeArea(
                                  child: Wrap(
                                    children: [
                                      ListTile(
                                        leading: const Icon(
                                          Icons.push_pin_outlined,
                                        ),
                                        title: Text(
                                          chat.pinned
                                              ? 'Pinned Chat'
                                              : 'Pin Chat',
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Pin management can be '
                                                'added to the chat model.',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(
                                          Icons.mark_chat_read_outlined,
                                        ),
                                        title: const Text('Mark as Read'),
                                        onTap: () {
                                          setState(() {
                                            chat.count = 0;
                                          });

                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },

                          leading: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 27,
                                backgroundColor: chat.color,
                                child: Icon(
                                  chat.isGroup ? Icons.groups : Icons.person,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),

                              if (chat.pinned)
                                const Positioned(
                                  top: -5,
                                  left: -5,
                                  child: Icon(
                                    Icons.push_pin,
                                    size: 18,
                                    color: tealColor,
                                  ),
                                ),
                            ],
                          ),

                          title: Text(
                            chat.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),

                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              chat.msg,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),

                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                chat.time,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: chat.count > 0
                                      ? tealColor
                                      : Colors.grey,
                                  fontWeight: chat.count > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),

                              const SizedBox(height: 5),

                              if (chat.count > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: mintGreen,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${chat.count}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ================= BOTTOM NAVIGATION =================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomItem(Icons.chat_bubble, 'Chats', 0, '10'),
            _bottomItem(Icons.circle_outlined, 'Updates', 1, ''),
            _bottomItem(Icons.groups_outlined, 'Communities', 2, ''),
            _bottomItem(Icons.call_outlined, 'Calls', 3, ''),
          ],
        ),
      ),

      // ================= FLOATING BUTTON =================
      floatingActionButton: FloatingActionButton(
        backgroundColor: mintGreen,
        elevation: 4,
        onPressed: () {
          openPage(
            NewChatScreen(
              onSelectContact: (name) {
                final existing = chats.where((chat) => chat.name == name);

                if (existing.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(chat: existing.first),
                    ),
                  );
                } else {
                  final newChat = Chat(
                    name: name,
                    msg: 'Start a conversation',
                    time: 'Now',
                    count: 0,
                    pinned: false,
                    color: Colors.teal,
                    isGroup: false,
                  );

                  setState(() {
                    chats.insert(0, newChat);
                  });

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(chat: newChat),
                    ),
                  );
                }
              },
            ),
          );
        },
        child: const Icon(Icons.edit, color: Colors.black, size: 27),
      ),
    );
  }

  // ================= FILTER CHIP =================

  Widget _filterChip(String label) {
    final isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? mintGreen : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? mintGreen : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  // ================= BOTTOM ITEM =================

  Widget _bottomItem(IconData icon, String label, int index, String badge) {
    final active = selectedBottomIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (index == 0) {
          setState(() {
            selectedBottomIndex = 0;
          });
          return;
        }

        late Widget page;

        switch (index) {
          case 1:
            page = const UpdatesScreen();
            break;

          case 2:
            page = const CommunitiesScreen();
            break;

          case 3:
            page = const CallsScreen();
            break;

          default:
            page = const UpdatesScreen();
        }

        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: active ? tealColor : Colors.grey, size: 25),

                if (badge.isNotEmpty)
                  Positioned(
                    right: -9,
                    top: -7,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: mintGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: active ? tealColor : Colors.grey,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// CHAT DETAIL SCREEN
// ======================================================

class ChatDetailScreen extends StatefulWidget {
  final Chat chat;

  const ChatDetailScreen({super.key, required this.chat});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController messageController = TextEditingController();

  final List<String> messages = [];

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() {
    final message = messageController.text.trim();

    if (message.isEmpty) return;

    setState(() {
      messages.add(message);
      widget.chat.msg = 'You: $message';
    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: const BackButton(),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.chat.color,
              child: Icon(
                widget.chat.isGroup ? Icons.groups : Icons.person,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.chat.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Video calling UI')));
            },
            icon: const Icon(Icons.videocam_outlined),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Voice calling UI')));
            },
            icon: const Icon(Icons.call_outlined),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContactProfileScreen(chat: widget.chat),
                  ),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'profile', child: Text('View Profile')),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: const Text(
                        'No messages yet.\nSend a message to start chatting!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, height: 1.6),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78,
                          ),
                          decoration: BoxDecoration(
                            color: mintGreen,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(messages[index]),
                        ),
                      );
                    },
                  ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Emoji picker UI')),
                      );
                    },
                    icon: const Icon(Icons.emoji_emotions_outlined),
                  ),

                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        filled: true,
                        fillColor: lightGrey,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  CircleAvatar(
                    backgroundColor: mintGreen,
                    child: IconButton(
                      onPressed: sendMessage,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// NEW CHAT SCREEN
// ======================================================

class NewChatScreen extends StatelessWidget {
  final ValueChanged<String> onSelectContact;

  const NewChatScreen({super.key, required this.onSelectContact});

  final List<String> contacts = const [
    'bhai',
    'Mom',
    'sister',
    'friends',
    'cousin',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chat'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),

      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: mintGreen,
              child: Icon(Icons.group_add, color: Colors.black),
            ),
            title: const Text('New Group'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
              );
            },
          ),

          ListTile(
            leading: const CircleAvatar(
              backgroundColor: mintGreen,
              child: Icon(Icons.person_add_alt_1, color: Colors.black),
            ),
            title: const Text('New Contact'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewContactScreen()),
              );
            },
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'CONTACTS',
              style: TextStyle(color: tealColor, fontWeight: FontWeight.bold),
            ),
          ),

          ...contacts.map(
            (name) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal.shade100,
                child: const Icon(Icons.person, color: Colors.teal),
              ),
              title: Text(name),
              subtitle: const Text('Available'),
              onTap: () => onSelectContact(name),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// CONTACT PROFILE SCREEN
// ======================================================

class ContactProfileScreen extends StatelessWidget {
  final Chat chat;

  const ContactProfileScreen({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Info'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),

      body: ListView(
        children: [
          const SizedBox(height: 35),

          CircleAvatar(
            radius: 55,
            backgroundColor: chat.color,
            child: Icon(
              chat.isGroup ? Icons.groups : Icons.person,
              color: Colors.white,
              size: 55,
            ),
          ),

          const SizedBox(height: 18),

          Center(
            child: Text(
              chat.name,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 8),

          const Center(
            child: Text('Available', style: TextStyle(color: Colors.grey)),
          ),

          const SizedBox(height: 30),

          ListTile(
            leading: const Icon(Icons.message_outlined),
            title: const Text('Message'),
            onTap: () => Navigator.pop(context),
          ),

          ListTile(
            leading: const Icon(Icons.call_outlined),
            title: const Text('Voice Call'),
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Voice calling UI')));
            },
          ),

          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search Conversation'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search conversation UI')),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ======================================================
// UPDATES SCREEN
// ======================================================

class UpdatesScreen extends StatelessWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CameraScreen()),
              );
            },
            icon: const Icon(Icons.camera_alt_outlined),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Status',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 18),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              radius: 28,
              backgroundColor: mintGreen,
              child: Icon(Icons.add, color: Colors.black, size: 30),
            ),
            title: const Text('My Status'),
            subtitle: const Text('Tap to add status update'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CameraScreen()),
              );
            },
          ),

          const SizedBox(height: 25),

          const Text(
            'Recent Updates',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 12),

          _statusItem('Sister', Colors.pink),
          _statusItem('friend', Colors.blue),
          _statusItem('bhi', Colors.orange),
        ],
      ),
    );
  }

  Widget _statusItem(String name, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: color,
        child: const Icon(Icons.person, color: Colors.white),
      ),
      title: Text(name),
      subtitle: const Text('Today, 10:30 AM'),
      onTap: () {
        // Status viewer can be added here.
      },
    );
  }
}

// ======================================================
// COMMUNITIES SCREEN
// ======================================================

class CommunitiesScreen extends StatelessWidget {
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),

      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: mintGreen,
              child: Icon(Icons.groups, color: Colors.black),
            ),
            title: const Text('New Community'),
            subtitle: const Text('Bring groups together'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
              );
            },
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Your Communities',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),

          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.groups, color: Colors.white),
            ),
            title: const Text('Design Community'),
            subtitle: const Text('3 groups'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CommunityDetailScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ======================================================
// COMMUNITY DETAIL SCREEN
// ======================================================

class CommunityDetailScreen extends StatelessWidget {
  const CommunityDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Community'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: mintGreen,
              child: Icon(Icons.campaign),
            ),
            title: Text('Announcements'),
            subtitle: Text('Community announcements'),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.groups, color: Colors.white),
            ),
            title: Text('Design Team'),
            subtitle: Text('Team discussions'),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// CALLS SCREEN
// ======================================================

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calls = [
      ['friend', 'Today, 10:30 AM', Icons.call_received],
      ['Mom', 'Yesterday, 08:15 PM', Icons.call_made],
      ['Sister', 'Monday, 05:20 PM', Icons.call_missed],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calls'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewCallScreen()),
              );
            },
            icon: const Icon(Icons.add_call),
          ),
        ],
      ),

      body: ListView(
        children: [
          ...calls.map(
            (call) => ListTile(
              leading: CircleAvatar(
                backgroundColor: mintGreen,
                child: Icon(call[2] as IconData, color: Colors.black),
              ),
              title: Text(call[0] as String),
              subtitle: Text(call[1] as String),
              trailing: IconButton(
                icon: const Icon(Icons.call_outlined, color: tealColor),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calling ${call[0]}...')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// NEW CALL SCREEN
// ======================================================

class NewCallScreen extends StatelessWidget {
  const NewCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = ['friends', 'Mom', 'Sister', 'bhai'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start a Call'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        children: contacts.map((name) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: mintGreen,
              child: Icon(Icons.person),
            ),
            title: Text(name),
            trailing: IconButton(
              icon: const Icon(Icons.call, color: tealColor),
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Calling $name...')));
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ======================================================
// CAMERA SCREEN
// ======================================================

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined, size: 90, color: tealColor),

            const SizedBox(height: 20),

            const Text(
              'Camera Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Camera preview can be added here.',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Connect a camera plugin to capture photos.'),
                  ),
                );
              },
              icon: const Icon(Icons.camera),
              label: const Text('Capture Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: mintGreen,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// SETTINGS SCREEN
// ======================================================

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),

      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(
              radius: 28,
              backgroundColor: mintGreen,
              child: Icon(Icons.person, size: 30, color: Colors.black),
            ),
            title: const Text(
              'My Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Edit your profile information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyProfileScreen()),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Privacy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SimpleDetailScreen(
                    title: 'Privacy',
                    description: 'Manage your privacy preferences here.',
                    icon: Icons.lock_outline,
                  ),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.chat_outlined),
            title: const Text('Chats'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SimpleDetailScreen(
                    title: 'Chat Settings',
                    description: 'Customize your chat preferences here.',
                    icon: Icons.chat_outlined,
                  ),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SimpleDetailScreen(
                    title: 'Notifications',
                    description: 'Manage notification preferences here.',
                    icon: Icons.notifications_outlined,
                  ),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SimpleDetailScreen(
                    title: 'Help',
                    description: 'Help and support information.',
                    icon: Icons.help_outline,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ======================================================
// MY PROFILE SCREEN
// ======================================================

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final TextEditingController nameController = TextEditingController(
    text: 'My Name',
  );

  final TextEditingController aboutController = TextEditingController(
    text: 'Hey there! I am using WhatsApp.',
  );

  @override
  void dispose() {
    nameController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile saved for this screen.')),
              );
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),

          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 55,
                  backgroundColor: mintGreen,
                  child: Icon(Icons.person, size: 65, color: Colors.black),
                ),

                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: tealColor,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CameraScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 35),

          const Text(
            'Name',
            style: TextStyle(fontWeight: FontWeight.bold, color: tealColor),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              filled: true,
              fillColor: lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'About',
            style: TextStyle(fontWeight: FontWeight.bold, color: tealColor),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: aboutController,
            decoration: InputDecoration(
              hintText: 'About yourself',
              filled: true,
              fillColor: lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// CREATE GROUP SCREEN
// ======================================================

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController groupController = TextEditingController();

  @override
  void dispose() {
    groupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: mintGreen,
              child: Icon(Icons.groups, size: 45, color: Colors.black),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: groupController,
              decoration: InputDecoration(
                hintText: 'Enter group name',
                prefixIcon: const Icon(Icons.edit),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mintGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: () {
                  final name = groupController.text.trim();

                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a group name'),
                      ),
                    );
                    return;
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SimpleDetailScreen(
                        title: name,
                        description: 'Your group screen is ready to customize.',
                        icon: Icons.groups,
                      ),
                    ),
                  );
                },
                child: const Text('Create Group'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// NEW CONTACT SCREEN
// ======================================================

class NewContactScreen extends StatefulWidget {
  const NewContactScreen({super.key});

  @override
  State<NewContactScreen> createState() => _NewContactScreenState();
}

class _NewContactScreenState extends State<NewContactScreen> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Contact'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: saveContact),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mintGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: saveContact,
                child: const Text('Save Contact'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveContact() {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter both name and phone number')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Contact details entered. Phone contact saving '
          'requires contact integration.',
        ),
      ),
    );
  }
}

// ======================================================
// STARRED MESSAGES SCREEN
// ======================================================

class StarredMessagesScreen extends StatelessWidget {
  const StarredMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starred Messages'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),

      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 75, color: tealColor),
            SizedBox(height: 15),
            Text(
              'No starred messages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your starred messages will appear here.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// SELECT CHATS SCREEN
// ======================================================

class SelectChatsScreen extends StatefulWidget {
  final List<Chat> chats;

  const SelectChatsScreen({super.key, required this.chats});

  @override
  State<SelectChatsScreen> createState() => _SelectChatsScreenState();
}

class _SelectChatsScreenState extends State<SelectChatsScreen> {
  final Set<String> selectedNames = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${selectedNames.length} Selected'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: widget.chats.length,
        itemBuilder: (context, index) {
          final chat = widget.chats[index];

          return CheckboxListTile(
            value: selectedNames.contains(chat.name),
            activeColor: tealColor,
            secondary: CircleAvatar(
              backgroundColor: chat.color,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(chat.name),
            onChanged: (selected) {
              setState(() {
                if (selected == true) {
                  selectedNames.add(chat.name);
                } else {
                  selectedNames.remove(chat.name);
                }
              });
            },
          );
        },
      ),
    );
  }
}

// ======================================================
// REUSABLE DETAIL SCREEN
// ======================================================

class SimpleDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const SimpleDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: tealColor),

              const SizedBox(height: 20),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
