package com.example.dbdemo.controller;

import com.example.dbdemo.config.AppConfig;
import com.example.dbdemo.model.TechStack;
import com.example.dbdemo.model.TechStackInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class InfoController {

    @Autowired
    private AppConfig appConfig;

    @Value("${spring.datasource.url}")
    private String datasourceUrl;

    @GetMapping("/api/infos")
    public TechStackInfo getInfo() {
        String javaVersion = System.getProperty("java.version");
        String springBootVersion = org.springframework.boot.SpringBootVersion.getVersion();

        // Auto-detect database type from JDBC URL
        String databaseType = detectDatabaseType(datasourceUrl);

        TechStack techStack = new TechStack(
            "Spring Boot",
            springBootVersion != null ? springBootVersion : "3.5.7",
            "Java",
            javaVersion,
            "JVM",
            databaseType
        );

        return new TechStackInfo(
            appConfig.getUuid(),
            appConfig.getVersion(),
            appConfig.getDeploymentColor(),
            techStack
        );
    }

    private String detectDatabaseType(String jdbcUrl) {
        if (jdbcUrl == null) {
            return "Unknown Database";
        }
        if (jdbcUrl.contains("mysql")) {
            return "MySQL";
        } else if (jdbcUrl.contains("postgresql")) {
            return "PostgreSQL";
        }
        return "Unknown Database";
    }
}
