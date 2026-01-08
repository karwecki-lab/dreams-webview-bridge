import Foundation
import Combine
import DreamsKit

/// ViewModel zarządzający komunikacją między Swift a JavaScript oraz integracją z Dreams SDK
@MainActor
class WebViewViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Ostatnia wiadomość otrzymana z React (JavaScript)
    @Published var lastReceivedMessage: String = "Brak wiadomości"
    
    /// Status inicjalizacji Dreams SDK
    @Published var dreamsSDKStatus: String = "SDK gotowy"
    
    /// Counter wiadomości wysłanych do React
    @Published var messagesSentCount: Int = 0
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        setupDreamsSDKObservers()
    }
    
    // MARK: - Dreams SDK Integration
    
    /// Konfiguruje obserwatory dla Dreams SDK
    private func setupDreamsSDKObservers() {
        // W prawdziwej aplikacji można tutaj nasłuchiwać na zdarzenia SDK
        logDreamsEvent(type: "app_initialized", data: ["timestamp": Date().ISO8601Format()])
    }
    
    /// Loguje zdarzenie do Dreams SDK
    /// - Parameters:
    ///   - type: Typ zdarzenia
    ///   - data: Dodatkowe dane zdarzenia
    func logDreamsEvent(type: String, data: [String: Any]) {
        Dreams.shared.trackEvent(
            name: type,
            properties: data
        )
        
        print("📊 Dreams SDK: Logged event '\(type)' with data: \(data)")
    }
    
    /// Rozpoczyna sesję Dreams dla użytkownika
    /// - Parameter userId: Identyfikator użytkownika
    func startDreamsSession(userId: String) {
        Dreams.shared.identify(userId: userId)
        dreamsSDKStatus = "Sesja aktywna dla: \(userId)"
        
        logDreamsEvent(
            type: "session_started",
            data: [
                "userId": userId,
                "timestamp": Date().ISO8601Format()
            ]
        )
        
        print("🔐 Dreams SDK: Session started for user \(userId)")
    }
    
    // MARK: - Message Handling
    
    /// Obsługuje wiadomość otrzymaną z JavaScript (React)
    /// - Parameter message: Treść wiadomości w formacie JSON
    func handleMessageFromJavaScript(_ message: [String: Any]) {
        guard let type = message["type"] as? String else {
            print("⚠️ Invalid message format from JavaScript")
            return
        }
        
        let payload = message["payload"] as? [String: Any] ?? [:]
        
        // Aktualizuj UI
        if let text = payload["text"] as? String {
            lastReceivedMessage = "[\(type)] \(text)"
        } else {
            lastReceivedMessage = "[\(type)] Otrzymano: \(payload)"
        }
        
        // Loguj do Dreams SDK
        logDreamsEvent(
            type: "message_received_from_react",
            data: [
                "messageType": type,
                "payload": payload,
                "timestamp": Date().ISO8601Format()
            ]
        )
        
        print("📨 Received from React: \(message)")
    }
    
    /// Przygotowuje wiadomość do wysłania do JavaScript (React)
    /// - Returns: Wiadomość w formacie JSON
    func prepareMessageForJavaScript() -> [String: Any] {
        messagesSentCount += 1
        
        let message: [String: Any] = [
            "type": "greeting",
            "payload": [
                "text": "Witaj z Swift! 🚀",
                "count": messagesSentCount,
                "timestamp": Date().ISO8601Format(),
                "source": "iOS-Swift"
            ]
        ]
        
        // Loguj do Dreams SDK
        logDreamsEvent(
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
    
    /// Resetuje stan aplikacji
    func reset() {
        lastReceivedMessage = "Brak wiadomości"
        messagesSentCount = 0
        
        logDreamsEvent(
            type: "app_reset",
            data: ["timestamp": Date().ISO8601Format()]
        )
    }
}
