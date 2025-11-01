package com.example.dbdemo.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AppConfig {

    @Value("${app.version:1.0.0}")
    private String version;

    @Value("${app.deployment.color:blue}")
    private String deploymentColor;

    private final String uuid = java.util.UUID.randomUUID().toString();

    public String getVersion() {
        return version;
    }

    public String getDeploymentColor() {
        return deploymentColor;
    }

    public String getUuid() {
        return uuid;
    }
}
