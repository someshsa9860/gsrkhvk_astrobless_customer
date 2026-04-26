import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/app_config.dart';

enum SocketConnectionState { disconnected, connecting, connected }

class ChatMessage {
  final String id;
  final String consultationId;
  final String senderType;
  final String? senderId;
  final String type;
  final String? body;
  final String? mediaUrl;
  final String? clientMsgId;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.consultationId,
    required this.senderType,
    this.senderId,
    required this.type,
    this.body,
    this.mediaUrl,
    this.clientMsgId,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] as String? ?? '',
        consultationId: j['consultationId'] as String? ?? '',
        senderType: j['senderType'] as String? ?? 'system',
        senderId: j['senderId'] as String?,
        type: j['type'] as String? ?? 'text',
        body: j['body'] as String?,
        mediaUrl: j['mediaUrl'] as String?,
        clientMsgId: j['clientMsgId'] as String?,
        createdAt: j['createdAt'] != null
            ? DateTime.parse(j['createdAt'] as String)
            : DateTime.now(),
      );
}

class BillingTick {
  final String consultationId;
  final int remainingSeconds;
  final double balance;

  const BillingTick({
    required this.consultationId,
    required this.remainingSeconds,
    required this.balance,
  });

  factory BillingTick.fromJson(Map<String, dynamic> j) => BillingTick(
        consultationId: j['consultationId'] as String? ?? '',
        remainingSeconds: (j['remainingSeconds'] as num? ?? 0).toInt(),
        balance: (j['balance'] as num? ?? 0).toDouble(),
      );
}

class SocketService {
  io.Socket? _socket;
  io.Socket? _presenceSocket;

  final _newMessageCtrl = StreamController<ChatMessage>.broadcast();
  final _billingTickCtrl = StreamController<BillingTick>.broadcast();
  final _consultationEndedCtrl = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionCtrl = StreamController<SocketConnectionState>.broadcast();
  final _lowBalanceCtrl = StreamController<Map<String, dynamic>>.broadcast();
  final _presenceUpdateCtrl = StreamController<Map<String, dynamic>>.broadcast();

  Stream<ChatMessage> get onNewMessage => _newMessageCtrl.stream;
  Stream<BillingTick> get onBillingTick => _billingTickCtrl.stream;
  Stream<Map<String, dynamic>> get onConsultationEnded => _consultationEndedCtrl.stream;
  Stream<SocketConnectionState> get onConnectionChanged => _connectionCtrl.stream;
  Stream<Map<String, dynamic>> get onLowBalance => _lowBalanceCtrl.stream;
  // Broadcasts { astrologerId, isOnline, timestamp } when astrologer presence changes
  Stream<Map<String, dynamic>> get onPresenceUpdate => _presenceUpdateCtrl.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String accessToken) {
    if (_socket?.connected == true) return;

    _connectionCtrl.add(SocketConnectionState.connecting);

    _socket = io.io(
      AppConfig.wsBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': accessToken})
          .enableAutoConnect()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[Socket] connected');
      _connectionCtrl.add(SocketConnectionState.connected);
    });

    _socket!.onDisconnect((_) {
      debugPrint('[Socket] disconnected');
      _connectionCtrl.add(SocketConnectionState.disconnected);
    });

    _socket!.onConnectError((e) {
      debugPrint('[Socket] connect error: $e');
      _connectionCtrl.add(SocketConnectionState.disconnected);
    });

    _socket!.on('message:new', (data) {
      try {
        final map = _toMap(data);
        final msg = map['message'] as Map<String, dynamic>? ?? map;
        _newMessageCtrl.add(ChatMessage.fromJson(msg));
      } catch (e) {
        debugPrint('[Socket] message:new parse error: $e');
      }
    });

    _socket!.on('billing:tick', (data) {
      try {
        _billingTickCtrl.add(BillingTick.fromJson(_toMap(data)));
      } catch (e) {
        debugPrint('[Socket] billing:tick parse error: $e');
      }
    });

    _socket!.on('consultation:ended', (data) {
      try {
        _consultationEndedCtrl.add(_toMap(data));
      } catch (e) {
        debugPrint('[Socket] consultation:ended parse error: $e');
      }
    });

    _socket!.on('billing:lowBalance', (data) {
      try {
        _lowBalanceCtrl.add(_toMap(data));
      } catch (e) {
        debugPrint('[Socket] billing:lowBalance parse error: $e');
      }
    });

    _connectPresence(accessToken);
  }

  void _connectPresence(String accessToken) {
    _presenceSocket?.disconnect();

    _presenceSocket = io.io(
      '${AppConfig.wsBaseUrl}/presence',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': accessToken})
          .enableAutoConnect()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(3000)
          .build(),
    );

    _presenceSocket!.onConnect((_) {
      debugPrint('[Presence] subscribed to astrologer presence updates');
    });

    _presenceSocket!.onConnectError((e) {
      debugPrint('[Presence] connect error: $e');
    });

    _presenceSocket!.on('presence:update', (data) {
      try {
        _presenceUpdateCtrl.add(_toMap(data));
      } catch (e) {
        debugPrint('[Presence] presence:update parse error: $e');
      }
    });
  }

  void disconnect() {
    _presenceSocket?.disconnect();
    _presenceSocket = null;
    _socket?.disconnect();
    _socket = null;
  }

  void joinConsultation(String consultationId) {
    _socket?.emit('consultation:join', {'consultationId': consultationId});
  }

  void leaveConsultation(String consultationId) {
    _socket?.emit('consultation:leave', {'consultationId': consultationId});
  }

  void sendMessage({
    required String consultationId,
    required String body,
    required String clientMsgId,
    String type = 'text',
    String? mediaUrl,
  }) {
    _socket?.emit('message:send', {
      'consultationId': consultationId,
      'type': type,
      'body': body,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      'clientMsgId': clientMsgId,
    });
  }

  void sendReadReceipt(String consultationId, String upToMessageId) {
    _socket?.emit('message:read', {
      'consultationId': consultationId,
      'upToMessageId': upToMessageId,
    });
  }

  void sendTypingStart(String consultationId) {
    _socket?.emit('typing:start', {'consultationId': consultationId});
  }

  void sendTypingStop(String consultationId) {
    _socket?.emit('typing:stop', {'consultationId': consultationId});
  }

  void dispose() {
    disconnect();
    _newMessageCtrl.close();
    _billingTickCtrl.close();
    _consultationEndedCtrl.close();
    _connectionCtrl.close();
    _lowBalanceCtrl.close();
    _presenceUpdateCtrl.close();
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();
  ref.onDispose(service.dispose);
  return service;
});
