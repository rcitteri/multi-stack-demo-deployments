package com.example.chat.service;

import org.springframework.stereotype.Service;

import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class UserSessionService {

    private final Set<String> activeUsers = ConcurrentHashMap.newKeySet();

    public void addUser(String username) {
        activeUsers.add(username);
    }

    public void removeUser(String username) {
        activeUsers.remove(username);
    }

    public boolean isUserOnline(String username) {
        return activeUsers.contains(username);
    }

    public int getOnlineUserCount() {
        return activeUsers.size();
    }

    public Set<String> getActiveUsers() {
        return Set.copyOf(activeUsers);
    }
}
