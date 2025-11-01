package com.example.demo.model;

public record TechStack(
    String framework,
    String version,
    String language,
    String languageVersion,
    String runtime
) {}
