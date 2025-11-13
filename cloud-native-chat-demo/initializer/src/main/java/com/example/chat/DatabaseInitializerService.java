package com.example.chat;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * Service responsible for database initialization tasks
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class DatabaseInitializerService {

    private final JdbcTemplate jdbcTemplate;

    @Transactional
    public void initialize() {
        log.info("Starting database initialization...");

        // Step 1: Verify database connection
        verifyConnection();

        // Step 2: Create tables if they don't exist
        createTables();

        // Step 3: Seed initial data (optional)
        seedInitialData();

        // Step 4: Verify initialization
        verifyInitialization();

        log.info("Database initialization completed successfully");
    }

    private void verifyConnection() {
        log.info("Step 1/4: Verifying database connection...");
        try {
            Integer result = jdbcTemplate.queryForObject("SELECT 1", Integer.class);
            if (result != null && result == 1) {
                log.info("✓ Database connection verified");
            }
        } catch (Exception e) {
            log.error("✗ Database connection failed", e);
            throw new RuntimeException("Failed to connect to database", e);
        }
    }

    private void createTables() {
        log.info("Step 2/4: Creating database tables...");

        // Check if table exists
        try {
            String checkTableSQL = """
                SELECT COUNT(*)
                FROM information_schema.tables
                WHERE table_schema = DATABASE()
                AND table_name = 'chat_messages'
                """;

            Integer count = jdbcTemplate.queryForObject(checkTableSQL, Integer.class);

            if (count != null && count > 0) {
                log.info("✓ Table 'chat_messages' already exists");
                return;
            }
        } catch (Exception e) {
            log.warn("Could not check if table exists, will attempt to create: {}", e.getMessage());
        }

        // Create chat_messages table
        try {
            String createTableSQL = """
                CREATE TABLE IF NOT EXISTS chat_messages (
                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                    username VARCHAR(100) NOT NULL,
                    content TEXT NOT NULL,
                    timestamp DATETIME(6) NOT NULL,
                    type VARCHAR(20) NOT NULL,
                    INDEX idx_timestamp (timestamp),
                    INDEX idx_type (type)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
                """;

            jdbcTemplate.execute(createTableSQL);
            log.info("✓ Table 'chat_messages' created successfully");
        } catch (Exception e) {
            log.error("✗ Failed to create table 'chat_messages'", e);
            throw new RuntimeException("Failed to create tables", e);
        }
    }

    private void seedInitialData() {
        log.info("Step 3/4: Seeding initial data...");

        try {
            // Check if we already have data
            String countSQL = "SELECT COUNT(*) FROM chat_messages";
            Integer count = jdbcTemplate.queryForObject(countSQL, Integer.class);

            if (count != null && count > 0) {
                log.info("✓ Database already contains {} messages, skipping seed", count);
                return;
            }

            String insertSQL = """
                INSERT INTO chat_messages (username, content, timestamp, type)
                VALUES (?, ?, ?, ?)
                """;

            // Seed sample conversation between John Doe and Jane Smith
            LocalDateTime baseTime = LocalDateTime.now().minusMinutes(30);

            // System welcome message
            jdbcTemplate.update(
                insertSQL,
                "System",
                "Welcome to Cloud Native Chat! This is a 12-factor application demo.",
                baseTime,
                "CHAT"
            );

            // John Doe joins
            jdbcTemplate.update(
                insertSQL,
                "John Doe",
                "John Doe joined the chat",
                baseTime.plusMinutes(1),
                "JOIN"
            );

            // John's first message
            jdbcTemplate.update(
                insertSQL,
                "John Doe",
                "Hello everyone! Excited to test this cloud-native chat application!",
                baseTime.plusMinutes(2),
                "CHAT"
            );

            // Jane Smith joins
            jdbcTemplate.update(
                insertSQL,
                "Jane Smith",
                "Jane Smith joined the chat",
                baseTime.plusMinutes(3),
                "JOIN"
            );

            // Jane's first message
            jdbcTemplate.update(
                insertSQL,
                "Jane Smith",
                "Hi John! Great to see this running on Cloud Foundry!",
                baseTime.plusMinutes(4),
                "CHAT"
            );

            // Conversation continues
            jdbcTemplate.update(
                insertSQL,
                "John Doe",
                "Jane! Good to see you here. Have you seen the actuator endpoints?",
                baseTime.plusMinutes(5),
                "CHAT"
            );

            jdbcTemplate.update(
                insertSQL,
                "Jane Smith",
                "Yes! I checked /actuator/chat and it shows our online users and message count. Very cool!",
                baseTime.plusMinutes(6),
                "CHAT"
            );

            jdbcTemplate.update(
                insertSQL,
                "John Doe",
                "The RabbitMQ integration is impressive. Messages scale across multiple instances seamlessly.",
                baseTime.plusMinutes(8),
                "CHAT"
            );

            jdbcTemplate.update(
                insertSQL,
                "Jane Smith",
                "Absolutely! And the database initializer running as a one-off task is a perfect example of Factor XII.",
                baseTime.plusMinutes(10),
                "CHAT"
            );

            jdbcTemplate.update(
                insertSQL,
                "John Doe",
                "Indeed! This demonstrates all 12 factors beautifully. The dark UI theme is nice too!",
                baseTime.plusMinutes(12),
                "CHAT"
            );

            jdbcTemplate.update(
                insertSQL,
                "Jane Smith",
                "Agreed! Looking forward to deploying more instances and testing the horizontal scaling.",
                baseTime.plusMinutes(14),
                "CHAT"
            );

            log.info("✓ Initial data seeded: Welcome message + conversation between John Doe and Jane Smith (11 messages)");
        } catch (Exception e) {
            log.warn("Could not seed initial data: {}", e.getMessage());
            // Non-critical, don't fail initialization
        }
    }

    private void verifyInitialization() {
        log.info("Step 4/4: Verifying initialization...");

        try {
            // Verify table exists and is accessible
            String verifySQL = "SELECT COUNT(*) FROM chat_messages";
            Integer count = jdbcTemplate.queryForObject(verifySQL, Integer.class);

            log.info("✓ Database initialized successfully. Message count: {}", count);
        } catch (Exception e) {
            log.error("✗ Database verification failed", e);
            throw new RuntimeException("Database verification failed", e);
        }
    }
}
