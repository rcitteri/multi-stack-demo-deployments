package com.example.chat.controller;

import com.example.chat.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

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
}
