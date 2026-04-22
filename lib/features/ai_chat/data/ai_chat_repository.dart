import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

/// Repository for AI astrologer chat (Server-Sent Events streaming).
///
/// Requests go through [ApiClient.streamAiChat] which calls
/// [Endpoints.ai.chatStream] with `ResponseType.stream`.
class AiChatRepository {
  AiChatRepository(this._client);
  final ApiClient _client;

  /// Streams delta tokens from an AI astrologer chat response.
  ///
  /// [messages] is the conversation history in `{role, content}` format.
  /// [kundliProfileId] optionally injects the customer's birth chart context.
  ///
  /// Yields each text delta as it arrives; completes when the `[DONE]`
  /// sentinel is received or the stream closes.
  Stream<String> streamChat({
    required List<Map<String, String>> messages,
    String? kundliProfileId,
  }) async* {
    final response = await _client.streamAiChat(
      messages: messages,
      kundliProfileId: kundliProfileId,
    );

    final stream = response.data.stream as Stream<List<int>>;
    String buffer = '';

    await for (final chunk in stream) {
      buffer += utf8.decode(chunk);
      final lines = buffer.split('\n');
      buffer = lines.last;

      for (final line in lines.sublist(0, lines.length - 1)) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6).trim();
          if (data == '[DONE]') return;
          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final delta = json['choices']?[0]?['delta']?['content'] as String?;
            if (delta != null && delta.isNotEmpty) yield delta;
          } catch (_) {}
        }
      }
    }
  }
}

final aiChatRepositoryProvider = Provider<AiChatRepository>((ref) {
  return AiChatRepository(ref.read(apiClientProvider));
});
