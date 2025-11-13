package com.example.chat.service;

import com.example.chat.model.ChatMessageDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChatMessageListener {

    private final SimpMessagingTemplate messagingTemplate;

    /**
     * Listen for messages from RabbitMQ and broadcast via WebSocket
     */
    @RabbitListener(queues = "${chat.queue.name}")
    public void receiveMessage(ChatMessageDTO message) {
        log.info("Received message from RabbitMQ: {} - {}", message.getUsername(), message.getContent());

        // Broadcast message to all WebSocket subscribers
        messagingTemplate.convertAndSend("/topic/messages", message);
    }
}
