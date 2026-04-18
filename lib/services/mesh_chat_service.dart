import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mesh_network_service.dart';

class MeshMessage {
  final String senderId;
  final String content;
  final DateTime timestamp;

  MeshMessage({
    required this.senderId,
    required this.content,
    required this.timestamp,
  });
}

class MeshChatService extends StateNotifier<List<MeshMessage>> {
  final MeshNetworkService _meshService;
  
  MeshChatService(this._meshService) : super([]) {
    _listenForIncomingMessages();
  }

  void _listenForIncomingMessages() {
    _meshService.discoveredBeacons.listen((beacons) {
      // In a real app, we would parse the manufacturerData for message packets
      // For the demo, we simulate receiving a coordination message when a node is near
      if (beacons.contains('SIM_NODE_77') && state.isEmpty) {
        receiveMessage('SIM_NODE_77', 'I am at the scene. I have a first-aid kit.');
      }
    });
  }

  Future<void> sendMessage(String content) async {
    final newMessage = MeshMessage(
      senderId: 'ME',
      content: content,
      timestamp: DateTime.now(),
    );
    state = [...state, newMessage];
    
    // Broadcast via Mesh
    await _meshService.startBroadcasting('MSG:$content');
  }

  void receiveMessage(String sender, String content) {
    final newMessage = MeshMessage(
      senderId: sender,
      content: content,
      timestamp: DateTime.now(),
    );
    state = [...state, newMessage];
  }
}

final meshChatProvider = StateNotifierProvider.autoDispose<MeshChatService, List<MeshMessage>>((ref) {
  final mesh = ref.watch(meshNetworkServiceProvider);
  return MeshChatService(mesh);
});
