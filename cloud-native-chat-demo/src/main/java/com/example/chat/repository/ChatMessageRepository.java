package com.example.chat.repository;

import com.example.chat.model.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {

    /**
     * Find messages within the last N hours
     */
    @Query("SELECT m FROM ChatMessage m WHERE m.timestamp >= :since ORDER BY m.timestamp ASC")
    List<ChatMessage> findMessagesSince(@Param("since") LocalDateTime since);

    /**
     * Count messages in the last 24 hours
     */
    @Query("SELECT COUNT(m) FROM ChatMessage m WHERE m.timestamp >= :since AND m.type = 'CHAT'")
    long countChatMessagesSince(@Param("since") LocalDateTime since);

    /**
     * Delete messages older than specified timestamp
     */
    @Modifying
    @Query("DELETE FROM ChatMessage m WHERE m.timestamp < :before")
    void deleteMessagesOlderThan(@Param("before") LocalDateTime before);
}
