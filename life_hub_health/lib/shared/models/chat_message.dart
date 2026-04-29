import 'package:json_annotation/json_annotation.dart';

part 'chat_message.g.dart';

@JsonSerializable()
class ChatMessage {
  final int? id;
  final int? userId;
  final String role;
  final String content;
  final String? emotionTags;
  final DateTime? createdAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isStreaming;

  ChatMessage({
    this.id,
    this.userId,
    required this.role,
    required this.content,
    this.emotionTags,
    this.createdAt,
    this.isStreaming = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  ChatMessage copyWith({
    int? id,
    int? userId,
    String? role,
    String? content,
    String? emotionTags,
    DateTime? createdAt,
    bool? isStreaming,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      content: content ?? this.content,
      emotionTags: emotionTags ?? this.emotionTags,
      createdAt: createdAt ?? this.createdAt,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}
