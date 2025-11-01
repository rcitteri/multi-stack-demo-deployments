package com.example.demo.controller;

import com.example.demo.config.AppConfig;
import com.example.demo.model.TechStack;
import com.example.demo.model.TechStackInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class InfoController {

    @Autowired
    private AppConfig appConfig;

    @GetMapping("/api/infos")
    public TechStackInfo getInfo() {
        String javaVersion = System.getProperty("java.version");
        String springBootVersion = org.springframework.boot.SpringBootVersion.getVersion();

        TechStack techStack = new TechStack(
            "Spring Boot",
            springBootVersion != null ? springBootVersion : "3.5.7",
            "Java",
            javaVersion,
            "JVM"
        );

        return new TechStackInfo(
            appConfig.getUuid(),
            appConfig.getVersion(),
            appConfig.getDeploymentColor(),
            techStack
        );
    }
}
