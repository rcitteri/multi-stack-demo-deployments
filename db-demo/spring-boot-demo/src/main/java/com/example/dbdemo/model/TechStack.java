package com.example.dbdemo.model;

public record TechStack(
    String framework,
    String version,
    String language,
    String languageVersion,
    String runtime,
    String database
) {}
