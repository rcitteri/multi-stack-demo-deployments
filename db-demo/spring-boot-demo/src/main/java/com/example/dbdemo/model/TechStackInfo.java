package com.example.dbdemo.model;

public record TechStackInfo(
    String uuid,
    String version,
    String deploymentColor,
    TechStack techStack
) {}
