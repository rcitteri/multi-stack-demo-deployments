let stompClient = null;
let username = null;

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    username = sessionStorage.getItem('chatUsername');

    if (!username) {
        window.location.href = '/';
        return;
    }

    initializeUserProfile();
    connect();
    setupEventHandlers();
});

function initializeUserProfile() {
    // Display username
    document.getElementById('currentUsername').textContent = username;

    // Generate and display avatar initial
    const initial = username.charAt(0).toUpperCase();
    document.getElementById('avatarInitial').textContent = initial;

    // Generate a consistent color for the avatar based on username
    const avatarColor = generateAvatarColor(username);
    document.getElementById('userAvatar').style.background = avatarColor;
}

function generateAvatarColor(name) {
    // Generate a color based on the username for consistency
    let hash = 0;
    for (let i = 0; i < name.length; i++) {
        hash = name.charCodeAt(i) + ((hash << 5) - hash);
    }

    // Use specific color palette for better visibility on dark theme
    const colors = [
        'linear-gradient(135deg, #667eea 0%, #764ba2 100%)', // Purple
        'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)', // Pink
        'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)', // Blue
        'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)', // Green
        'linear-gradient(135deg, #fa709a 0%, #fee140 100%)', // Warm
        'linear-gradient(135deg, #30cfd0 0%, #330867 100%)', // Teal
        'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)', // Pastel
        'linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%)', // Rose
    ];

    const index = Math.abs(hash) % colors.length;
    return colors[index];
}

function connect() {
    const socket = new SockJS('/ws-chat');
    stompClient = Stomp.over(socket);

    // Disable debug logging
    stompClient.debug = null;

    stompClient.connect({}, onConnected, onError);
}

function onConnected() {
    console.log('WebSocket connected');

    // Subscribe to the message topic
    stompClient.subscribe('/topic/messages', onMessageReceived);

    // Send join notification
    const joinMessage = {
        username: username,
        type: 'JOIN'
    };

    stompClient.send('/app/chat.join', {}, JSON.stringify(joinMessage));
}

function onError(error) {
    console.error('WebSocket connection error:', error);
    showSystemMessage('Connection error. Please refresh the page.', 'error');
}

function sendMessage(event) {
    event.preventDefault();

    const messageInput = document.getElementById('messageInput');
    const messageContent = messageInput.value.trim();

    if (messageContent && stompClient) {
        const chatMessage = {
            username: username,
            content: messageContent,
            type: 'CHAT'
        };

        stompClient.send('/app/chat.send', {}, JSON.stringify(chatMessage));
        messageInput.value = '';
    }
}

function onMessageReceived(payload) {
    const message = JSON.parse(payload.body);
    displayMessage(message);
}

function displayMessage(message) {
    const messageArea = document.getElementById('messageArea');
    const messageElement = document.createElement('div');

    if (message.type === 'JOIN') {
        messageElement.className = 'system-message join';
        messageElement.innerHTML = `<div class="system-text">${escapeHtml(message.content)}</div>`;
    } else if (message.type === 'LEAVE') {
        messageElement.className = 'system-message leave';
        messageElement.innerHTML = `<div class="system-text">${escapeHtml(message.content)}</div>`;
    } else {
        messageElement.className = 'message';
        const timestamp = formatTimestamp(message.timestamp);
        messageElement.innerHTML = `
            <div class="message-content">
                <div class="message-header">
                    <span class="message-user">${escapeHtml(message.username)}</span>
                    <span class="message-time">${timestamp}</span>
                </div>
                <div class="message-text">${escapeHtml(message.content)}</div>
            </div>
        `;
    }

    messageArea.appendChild(messageElement);
    messageArea.scrollTop = messageArea.scrollHeight;
}

function formatTimestamp(timestamp) {
    if (!timestamp) return '';

    // Parse ISO timestamp
    const date = new Date(timestamp);
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');

    return `${hours}:${minutes}:${seconds}`;
}

function showSystemMessage(text, type = 'info') {
    const messageArea = document.getElementById('messageArea');
    const messageElement = document.createElement('div');
    messageElement.className = `system-message ${type}`;
    messageElement.innerHTML = `<div class="system-text">${escapeHtml(text)}</div>`;
    messageArea.appendChild(messageElement);
    messageArea.scrollTop = messageArea.scrollHeight;
}

function leaveChat() {
    if (stompClient && username) {
        const leaveMessage = {
            username: username,
            type: 'LEAVE'
        };

        stompClient.send('/app/chat.leave', {}, JSON.stringify(leaveMessage));

        // Disconnect after a short delay
        setTimeout(() => {
            stompClient.disconnect(() => {
                sessionStorage.removeItem('chatUsername');
                window.location.href = '/';
            });
        }, 500);
    } else {
        sessionStorage.removeItem('chatUsername');
        window.location.href = '/';
    }
}

function setupEventHandlers() {
    const messageForm = document.getElementById('messageForm');
    const leaveBtn = document.getElementById('leaveBtn');
    const messageInput = document.getElementById('messageInput');

    messageForm.addEventListener('submit', sendMessage);
    leaveBtn.addEventListener('click', leaveChat);

    // Auto-scroll on new messages
    const messageArea = document.getElementById('messageArea');
    messageArea.scrollTop = messageArea.scrollHeight;

    // Focus on input
    messageInput.focus();
}

// Escape HTML to prevent XSS
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Handle page unload
window.addEventListener('beforeunload', function() {
    if (stompClient && stompClient.connected) {
        const leaveMessage = {
            username: username,
            type: 'LEAVE'
        };
        stompClient.send('/app/chat.leave', {}, JSON.stringify(leaveMessage));
    }
});
