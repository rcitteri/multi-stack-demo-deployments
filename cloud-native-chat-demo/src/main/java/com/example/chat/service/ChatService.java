package com.example.chat.service;

import com.example.chat.model.ChatMessage;
import com.example.chat.model.ChatMessageDTO;
import com.example.chat.repository.ChatMessageRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChatService {

    private final ChatMessageRepository chatMessageRepository;
    private final RabbitTemplate rabbitTemplate;

    @Value("${chat.exchange.name}")
    private String exchangeName;

    @Value("${chat.routing.key}")
    private String routingKey;

    @Value("${chat.history.retention.hours}")
    private int retentionHours;

    /**
     * Send a chat message via RabbitMQ
     */
    public void sendMessage(ChatMessageDTO messageDTO) {
        // Save to database
        ChatMessage entity = messageDTO.toEntity();
        chatMessageRepository.save(entity);

        log.info("Sending message from {} via RabbitMQ", messageDTO.getUsername());

        // Publish to RabbitMQ
        rabbitTemplate.convertAndSend(exchangeName, routingKey, messageDTO);
    }

    /**
     * Get recent chat history (last 24 hours)
     */
    public List<ChatMessageDTO> getRecentMessages() {
        LocalDateTime since = LocalDateTime.now().minusHours(retentionHours);
        return chatMessageRepository.findMessagesSince(since)
            .stream()
            .map(ChatMessageDTO::fromEntity)
            .collect(Collectors.toList());
    }

    /**
     * Get count of chat messages in the last 24 hours
     */
    public long getChatMessageCount() {
        LocalDateTime since = LocalDateTime.now().minusHours(retentionHours);
        return chatMessageRepository.countChatMessagesSince(since);
    }

    /**
     * Scheduled cleanup of old messages (runs every hour)
     */
    @Scheduled(fixedRate = 3600000) // Every hour
    @Transactional
    public void cleanupOldMessages() {
        LocalDateTime cutoff = LocalDateTime.now().minusHours(retentionHours);
        log.info("Cleaning up messages older than {}", cutoff);
        chatMessageRepository.deleteMessagesOlderThan(cutoff);
    }
}
