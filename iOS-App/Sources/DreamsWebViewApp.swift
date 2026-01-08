import SwiftUI
import DreamsKit

@main
struct DreamsWebViewApp: App {
    
    init() {
        // Inicjalizacja Dreams SDK przy starcie aplikacji
        configureDreamsSDK()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    /// Konfiguruje Dreams SDK z podstawowymi parametrami
    /// W produkcji należy użyć prawdziwych wartości API Key i Environment
    private func configureDreamsSDK() {
        let configuration = DreamsConfiguration(
            apiKey: "your-api-key-here",
            environment: .sandbox // lub .production
        )
        
        Dreams.shared.configure(with: configuration)
        
        // Opcjonalnie: włącz szczegółowe logowanie dla developmentu
        Dreams.shared.enableDebugLogging(true)
        
        print("✅ Dreams SDK initialized successfully")
    }
}
