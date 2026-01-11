import Foundation
import Combine

/// ViewModel zarządzający komunikacją między Swift a JavaScript
@MainActor
class WebViewViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Ostatnia wiadomość otrzymana z React (JavaScript)
    @Published var lastReceivedMessage: String = "Brak wiadomości"
    
    /// Status aplikacji
    @Published var appStatus: String = "Gotowa"
    
    /// Czy sesja jest aktywna
    @Published var isSessionActive: Bool = false
    
    /// Counter wiadomości wysłanych do React
    @Published var messagesSentCount: Int = 0
    
    /// Counter wiadomości otrzymanych z React
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
    
    /// Loguje zdarzenie do konsoli
    func logEvent(type: String, data: [String: Any]) {
        let timestamp = Date().formatted(.dateTime.hour().minute().second())
        print("📊 [\(timestamp)] Event '\(type)': \(data)")
    }
    
    /// Rozpoczyna sesję dla użytkownika
    func startSession(userId: String) {
        appStatus = "Sesja aktywna dla: \(userId)"
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
    
    /// Obsługuje wiadomość otrzymaną z JavaScript (React)
    func handleMessageFromJavaScript(_ message: [String: Any]) {
        guard let type = message["type"] as? String else {
            print("⚠️ Invalid message format from JavaScript")
            return
        }
        
        let payload = message["payload"] as? [String: Any] ?? [:]
        
        // Inkrementuj licznik
        messagesReceivedCount += 1
        
        // Aktualizuj UI
        if let text = payload["text"] as? String {
            lastReceivedMessage = "[\(type)] \(text)"
        } else {
            lastReceivedMessage = "[\(type)] Otrzymano: \(payload)"
        }
        
        // Loguj
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
    
    /// Przygotowuje wiadomość do wysłania do JavaScript (React)
    func prepareMessageForJavaScript() -> [String: Any] {
        messagesSentCount += 1
        
        let message: [String: Any] = [
            "type": "greeting",
            "payload": [
                "text": "Witaj z Swift! 🚀",
                "count": messagesSentCount,
                "timestamp": Date().ISO8601Format(),
                "source": "iOS-Swift-Native"
            ]
        ]
        
        // Loguj
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
    
    /// Wysyła niestandardową wiadomość do React
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
    
    /// Resetuje stan aplikacji i kończy sesję
    func reset() {
        lastReceivedMessage = "Brak wiadomości"
        messagesSentCount = 0
        messagesReceivedCount = 0
        appStatus = "Gotowa"
        isSessionActive = false
        
        logEvent(
            type: "app_reset",
            data: ["timestamp": Date().ISO8601Format()]
        )
        
        print("🔄 Application state reset - session ended")
    }
    
    /// Zwraca statystyki komunikacji
    func getStatistics() -> [String: Int] {
        return [
            "sent": messagesSentCount,
            "received": messagesReceivedCount,
            "total": messagesSentCount + messagesReceivedCount
        ]
    }
}
