import SwiftUI
import WebKit

/// Wrapper dla WKWebView umożliwiający dwukierunkową komunikację z JavaScript
struct WebViewContainer: UIViewRepresentable {
    
    // MARK: - Properties
    
    let url: URL
    let viewModel: WebViewViewModel
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        
        // Konfiguracja preferences
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
        
        // Rejestracja message handler dla komunikacji JavaScript → Swift
        let contentController = configuration.userContentController
        contentController.add(context.coordinator, name: "nativeApp")
        
        // Utworzenie WKWebView
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.bounces = true
        
        // Załadowanie URL
        let request = URLRequest(url: url)
        webView.load(request)
        
        // Zapisz referencję do webView w coordinator
        context.coordinator.webView = webView
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Nie ma potrzeby aktualizacji dla tego prostego przypadku
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    // MARK: - Coordinator
    
    /// Coordinator obsługujący komunikację między WKWebView a SwiftUI
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        
        let viewModel: WebViewViewModel
        weak var webView: WKWebView?
        
        init(viewModel: WebViewViewModel) {
            self.viewModel = viewModel
            super.init()
        }
        
        // MARK: - WKScriptMessageHandler
        
        /// Obsługuje wiadomości wysłane z JavaScript do Swift
        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard message.name == "nativeApp" else { return }
            
            // Parsowanie wiadomości JSON z JavaScript
            if let messageBody = message.body as? [String: Any] {
                Task { @MainActor in
                    viewModel.handleMessageFromJavaScript(messageBody)
                }
            } else if let messageString = message.body as? String {
                // Fallback dla prostych stringów
                Task { @MainActor in
                    viewModel.handleMessageFromJavaScript([
                        "type": "text",
                        "payload": ["text": messageString]
                    ])
                }
            }
        }
        
        // MARK: - WKNavigationDelegate
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ WebView finished loading")
            
            // Loguj załadowanie strony w Dreams SDK
            Task { @MainActor in
                viewModel.logDreamsEvent(
                    type: "webview_loaded",
                    data: [
                        "url": webView.url?.absoluteString ?? "unknown",
                        "timestamp": Date().ISO8601Format()
                    ]
                )
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView failed to load: \(error.localizedDescription)")
            
            // Loguj błąd w Dreams SDK
            Task { @MainActor in
                viewModel.logDreamsEvent(
                    type: "webview_error",
                    data: [
                        "error": error.localizedDescription,
                        "timestamp": Date().ISO8601Format()
                    ]
                )
            }
        }
        
        // MARK: - Public Methods
        
        /// Wysyła wiadomość z Swift do JavaScript
        /// - Parameter message: Wiadomość w formacie słownika
        func sendMessageToJavaScript(_ message: [String: Any]) {
            guard let webView = webView else {
                print("⚠️ WebView not available")
                return
            }
            
            // Konwertuj słownik do JSON string
            guard let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                print("❌ Failed to serialize message to JSON")
                return
            }
            
            // Wywołaj globalną funkcję JavaScript z wiadomością
            let script = "window.receiveMessageFromNative(\(jsonString));"
            
            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("❌ Error sending message to JavaScript: \(error.localizedDescription)")
                } else {
                    print("✅ Message sent to JavaScript successfully")
                }
            }
        }
    }
}

// MARK: - WebView Extension

extension WebViewContainer {
    
    /// Wysyła wiadomość do JavaScript przez coordinator
    func sendMessage(_ message: [String: Any]) {
        // Ta metoda będzie wywołana z ContentView
    }
}
