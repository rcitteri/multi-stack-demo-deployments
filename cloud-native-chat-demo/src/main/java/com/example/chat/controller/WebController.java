package com.example.chat.controller;

import com.example.chat.model.ChatMessageDTO;
import com.example.chat.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Controller
@RequiredArgsConstructor
public class WebController {

    private final ChatService chatService;
    private final String instanceId = UUID.randomUUID().toString();

    @Value("${app.version}")
    private String appVersion;

    @Value("${app.deployment.color}")
    private String deploymentColor;

    @GetMapping("/")
    public String index(Model model) {
        model.addAttribute("version", appVersion);
        model.addAttribute("color", deploymentColor);
        return "index";
    }

    @GetMapping("/chat")
    public String chat(Model model) {
        model.addAttribute("instanceId", instanceId);
        model.addAttribute("version", appVersion);
        model.addAttribute("color", deploymentColor);
        model.addAttribute("recentMessages", chatService.getRecentMessages());
        return "chat";
    }

    /**
     * Polling endpoint for fallback when WebSocket is not available
     * Returns messages since the specified timestamp
     */
    @GetMapping("/api/messages/poll")
    @ResponseBody
    public ResponseEntity<List<ChatMessageDTO>> pollMessages(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime since) {
        List<ChatMessageDTO> messages = chatService.getMessagesSince(since);
        return ResponseEntity.ok(messages);
    }

    /**
     * REST endpoint for sending messages when polling mode is active
     */
    @PostMapping("/api/chat/send")
    @ResponseBody
    public ResponseEntity<Void> sendMessage(@RequestBody ChatMessageDTO message) {
        message.setTimestamp(LocalDateTime.now());
        chatService.sendMessage(message);
        return ResponseEntity.ok().build();
    }
}
