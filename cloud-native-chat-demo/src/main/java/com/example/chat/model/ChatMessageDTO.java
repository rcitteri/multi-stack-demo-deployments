package com.example.chat.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageDTO implements Serializable {

    private String username;
    private String content;
    private ChatMessage.MessageType type;
    private LocalDateTime timestamp;

    public static ChatMessageDTO fromEntity(ChatMessage message) {
        return new ChatMessageDTO(
            message.getUsername(),
            message.getContent(),
            message.getType(),
            message.getTimestamp()
        );
    }

    public ChatMessage toEntity() {
        return new ChatMessage(null, username, content, timestamp, type);
    }
}
