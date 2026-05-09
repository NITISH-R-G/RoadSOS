import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/mesh_chat_service.dart';

class MeshChatScreen extends ConsumerStatefulWidget {
  const MeshChatScreen({super.key});

  @override
  ConsumerState<MeshChatScreen> createState() => _MeshChatScreenState();
}

class _MeshChatScreenState extends ConsumerState<MeshChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(meshChatProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('SCENE COORDINATION (OFFLINE)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
<<<<<<< HEAD
            color: Colors.blue.withOpacity(0.1),
=======
            color: Colors.blue.withValues(alpha: 0.1),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
            child: const Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.blue, size: 16),
                SizedBox(width: 8),
<<<<<<< HEAD
                Text('Using BLE Mesh Network - No Internet Required', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
=======
                Expanded(
                  child: Text(
                    'BLE broadcast (foreground only). No delivery guarantee; use for short scene coordination.',
                    style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
<<<<<<< HEAD
                final isMe = msg.senderId == 'ME';
=======
                final isMe = msg.senderId == 'SELF';
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
<<<<<<< HEAD
                      color: isMe ? Colors.blue : Colors.white.withOpacity(0.1),
=======
                      color: isMe ? Colors.blue : Colors.white.withValues(alpha: 0.1),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(msg.senderId, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isMe ? Colors.white70 : Colors.blue)),
                        const SizedBox(height: 4),
                        Text(msg.content, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(16),
<<<<<<< HEAD
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05)),
=======
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05)),
>>>>>>> 11eadcec90ad9567a8ccab6309695935049f4e41
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Coordinate with others...',
                hintStyle: const TextStyle(color: Colors.white24),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filled(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                ref.read(meshChatProvider.notifier).sendMessage(_controller.text);
                _controller.clear();
              }
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
