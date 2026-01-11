import Foundation
import Combine

/// ViewModel managing communication between Swift and JavaScript
@MainActor
class WebViewViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Last message received from React (JavaScript)
    @Published var lastReceivedMessage: String = "No messages"
    
    /// Application status
    @Published var appStatus: String = "Ready"
    
    /// Whether session is active
    @Published var isSessionActive: Bool = false
    
    /// Counter of messages sent to React
    @Published var messagesSentCount: Int = 0
    
    /// Counter of messages received from React
    @Published var messagesReceivedCount: Int = 0
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        setupLogger()
    }
    
    // MARK: - Logging
    
    private func setupLogger() {
        logEvent(type: "app_initialized", data: ["timestamp": Date().ISO8601Format()])
    }
    
    /// Logs event to console
    func logEvent(type: String, data: [String: Any]) {
        let timestamp = Date().formatted(.dateTime.hour().minute().second())
        print("📊 [\(timestamp)] Event '\(type)': \(data)")
    }
    
    /// Starts session for user
    func startSession(userId: String) {
        appStatus = "Session active for: \(userId)"
        isSessionActive = true
        
        logEvent(
            type: "session_started",
            data: [
                "userId": userId,
                "timestamp": Date().ISO8601Format()
            ]
        )
        
        print("🔐 Session started for user \(userId)")
    }
    
    // MARK: - Message Handling (JavaScript → Swift)
    
    /// Handles message received from JavaScript (React)
    func handleMessageFromJavaScript(_ message: [String: Any]) {
        guard let type = message["type"] as? String else {
            print("⚠️ Invalid message format from JavaScript")
            return
        }
        
        let payload = message["payload"] as? [String: Any] ?? [:]
        
        // Increment counter
        messagesReceivedCount += 1
        
        // Update UI
        if let text = payload["text"] as? String {
            lastReceivedMessage = "[\(type)] \(text)"
        } else {
            lastReceivedMessage = "[\(type)] Received: \(payload)"
        }
        
        // Log
        logEvent(
            type: "message_received_from_react",
            data: [
                "messageType": type,
                "count": messagesReceivedCount,
                "payload": payload,
                "timestamp": Date().ISO8601Format()
            ]
        )
        
        print("📨 Received from React: \(message)")
    }
    
    // MARK: - Message Handling (Swift → JavaScript)
    
    /// Prepares message to send to JavaScript (React)
    func prepareMessageForJavaScript() -> [String: Any] {
        messagesSentCount += 1
        
        let message: [String: Any] = [
            "type": "greeting",
            "payload": [
                "text": "Hello from Swift! 🚀",
                "count": messagesSentCount,
                "timestamp": Date().ISO8601Format(),
                "source": "iOS-Swift-Native"
            ]
        ]
        
        // Log
        logEvent(
            type: "message_sent_to_react",
            data: [
                "messageType": "greeting",
                "count": messagesSentCount,
                "timestamp": Date().ISO8601Format()
            ]
        )
        
        print("📤 Sending to React: \(message)")
        
        return message
    }
    
    /// Sends custom message to React
    func sendCustomMessage(type: String, text: String) {
        let message: [String: Any] = [
            "type": type,
            "payload": [
                "text": text,
                "timestamp": Date().ISO8601Format(),
                "source": "iOS-Swift-Native"
            ]
        ]
        
        messagesSentCount += 1
        
        logEvent(
            type: "custom_message_sent",
            data: [
                "messageType": type,
                "timestamp": Date().ISO8601Format()
            ]
        )
        
        print("📤 Sending custom message: \(message)")
    }
    
    // MARK: - Utility Methods
    
    /// Resets application state and ends session
    func reset() {
        lastReceivedMessage = "No messages"
        messagesSentCount = 0
        messagesReceivedCount = 0
        appStatus = "Ready"
        isSessionActive = false
        
        logEvent(
            type: "app_reset",
            data: ["timestamp": Date().ISO8601Format()]
        )
        
        print("🔄 Application state reset - session ended")
    }
    
    /// Returns communication statistics
    func getStatistics() -> [String: Int] {
        return [
            "sent": messagesSentCount,
            "received": messagesReceivedCount,
            "total": messagesSentCount + messagesReceivedCount
        ]
    }
}
