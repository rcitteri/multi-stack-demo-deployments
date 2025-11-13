package com.example.chat;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.amqp.RabbitAutoConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Profile;

/**
 * Database Initializer - One-off Admin Process
 *
 * This application demonstrates Factor XII of 12-Factor Apps:
 * "Run admin/management tasks as one-off processes"
 *
 * This process:
 * - Runs before the main application starts
 * - Initializes database schema
 * - Seeds initial data if needed
 * - Exits after completion
 * - Does NOT require RabbitMQ (excluded from autoconfiguration)
 */
@SpringBootApplication(exclude = {RabbitAutoConfiguration.class})
@Profile("initializer")
public class DbInitializerApplication {

    public static void main(String[] args) {
        System.out.println("========================================");
        System.out.println("Database Initializer - Starting...");
        System.out.println("========================================");

        SpringApplication app = new SpringApplication(DbInitializerApplication.class);
        app.setAdditionalProfiles("initializer");
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
