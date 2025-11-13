package com.example.chat.actuator;

import com.example.chat.service.ChatService;
import com.example.chat.service.UserSessionService;
import lombok.RequiredArgsConstructor;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.boot.actuate.endpoint.annotation.Endpoint;
import org.springframework.boot.actuate.endpoint.annotation.ReadOperation;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Component
@Endpoint(id = "chat")
@RequiredArgsConstructor
@ConditionalOnBean(RabbitTemplate.class)
public class ChatStatsEndpoint {

    private final UserSessionService userSessionService;
    private final ChatService chatService;

    @ReadOperation
    public Map<String, Object> chatStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("onlineUsers", userSessionService.getOnlineUserCount());
        stats.put("messagesLast24Hours", chatService.getChatMessageCount());
        stats.put("activeUsernames", userSessionService.getActiveUsers());
        return stats;
    }
}
