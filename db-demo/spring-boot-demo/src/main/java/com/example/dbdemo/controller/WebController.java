package com.example.dbdemo.controller;

import com.example.dbdemo.config.AppConfig;
import com.example.dbdemo.repository.PetRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class WebController {

    @Autowired
    private AppConfig appConfig;

    @Autowired
    private PetRepository petRepository;

    @GetMapping("/")
    public String index(Model model) {
        String javaVersion = System.getProperty("java.version");
        String springBootVersion = org.springframework.boot.SpringBootVersion.getVersion();

        model.addAttribute("uuid", appConfig.getUuid());
        model.addAttribute("version", appConfig.getVersion());
        model.addAttribute("deploymentColor", appConfig.getDeploymentColor());
        model.addAttribute("framework", "Spring Boot");
        model.addAttribute("frameworkVersion", springBootVersion != null ? springBootVersion : "3.5.7");
        model.addAttribute("language", "Java");
        model.addAttribute("languageVersion", javaVersion);
        model.addAttribute("runtime", "JVM");
        model.addAttribute("database", "PostgreSQL 17");
        model.addAttribute("pets", petRepository.findAll());

        return "index";
    }
}
