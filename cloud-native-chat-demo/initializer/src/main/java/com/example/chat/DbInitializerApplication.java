package com.example.chat;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

/**
 * Database Initializer - One-off Admin Process (Standalone Application)
 *
 * This application demonstrates Factor XII of 12-Factor Apps:
 * "Run admin/management tasks as one-off processes"
 *
 * This is a separate Spring Boot application that:
 * - Runs as a Cloud Foundry task (no profile parameters needed)
 * - Initializes database schema
 * - Seeds initial data if needed
 * - Exits with code 0 on success, non-zero on failure
 */
@SpringBootApplication
public class DbInitializerApplication {

    public static void main(String[] args) {
        System.out.println("========================================");
        System.out.println("Database Initializer - Starting...");
        System.out.println("========================================");

        SpringApplication app = new SpringApplication(DbInitializerApplication.class);
        // Disable web server - run as command-line application only
        app.setWebApplicationType(org.springframework.boot.WebApplicationType.NONE);

        System.exit(SpringApplication.exit(app.run(args)));
    }

    @Bean
    public CommandLineRunner initializeDatabase(DatabaseInitializerService initializerService) {
        return args -> {
            try {
                initializerService.initialize();
                System.out.println("========================================");
                System.out.println("Database initialization completed successfully");
                System.out.println("========================================");
            } catch (Exception e) {
                System.err.println("========================================");
                System.err.println("Database initialization failed: " + e.getMessage());
                System.err.println("========================================");
                throw e;
            }
        };
    }
}
