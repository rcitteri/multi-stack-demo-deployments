package com.example.chat.controller;

import com.example.chat.model.ChatMessage;
import com.example.chat.model.ChatMessageDTO;
import com.example.chat.service.ChatService;
import com.example.chat.service.UserSessionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.stereotype.Controller;

import java.time.LocalDateTime;

@Controller
@RequiredArgsConstructor
@Slf4j
public class ChatController {

    private final ChatService chatService;
    private final UserSessionService userSessionService;

    /**
     * Handle incoming chat messages from WebSocket clients
     */
    @MessageMapping("/chat.send")
    public void sendMessage(@Payload ChatMessageDTO message) {
        message.setTimestamp(LocalDateTime.now());
        log.info("Received WebSocket message from {}: {}", message.getUsername(), message.getContent());
        chatService.sendMessage(message);
    }

    /**
     * Handle user joining the chat
     */
    @MessageMapping("/chat.join")
    public void addUser(@Payload ChatMessageDTO message, SimpMessageHeaderAccessor headerAccessor) {
        String username = message.getUsername();
        log.info("User joining: {}", username);

        // Add username to WebSocket session
        headerAccessor.getSessionAttributes().put("username", username);

        // Track user session
        userSessionService.addUser(username);

        // Send join notification
        message.setType(ChatMessage.MessageType.JOIN);
        message.setContent(username + " joined the chat");
        message.setTimestamp(LocalDateTime.now());
        chatService.sendMessage(message);
    }

    /**
     * Handle user leaving the chat
     */
    @MessageMapping("/chat.leave")
    public void removeUser(@Payload ChatMessageDTO message) {
        String username = message.getUsername();
        log.info("User leaving: {}", username);

        // Remove user from tracking
        userSessionService.removeUser(username);

        // Send leave notification
        message.setType(ChatMessage.MessageType.LEAVE);
        message.setContent(username + " left the chat");
        message.setTimestamp(LocalDateTime.now());
        chatService.sendMessage(message);
    }
}
