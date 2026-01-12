import SwiftUI
import WebKit

struct ContentView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = WebViewViewModel()
    @State private var webViewCoordinator: WebViewContainer.Coordinator?
    
    // React app URL - change for production
    private let reactAppURL = URL(string: "https://dreams-webview-bridge.rafkar.workers.dev")!
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // WebView
            webViewSection
            
            // Controls Section
            controlsSection
            
            // Status Section
            statusSection
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    // MARK: - View Components
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Native WebView Bridge")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("Bidirectional Swift ↔ JavaScript Communication")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 2, y: 2)
    }
    
    private var webViewSection: some View {
        WebViewContainerWrapper(
            url: reactAppURL,
            viewModel: viewModel,
            coordinator: $webViewCoordinator
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .border(Color.gray.opacity(0.3), width: 1)
    }
    
    private var controlsSection: some View {
        VStack(spacing: 12) {
            // Send message button
            Button(action: sendMessageToReact) {
                HStack {
                    if !viewModel.isSessionActive {
                        Image(systemName: "lock.fill")
                    }
                    Image(systemName: "paperplane.fill")
                    Text("Send Message to React")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isSessionActive ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(!viewModel.isSessionActive)
            .padding(.horizontal)
            
            // Additional action buttons
            HStack(spacing: 12) {
                Button(action: startSession) {
                    VStack {
                        Image(systemName: "person.fill")
                        Text("Start Session")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
                }
                
                Button(action: sendCustomAction) {
                    VStack {
                        if !viewModel.isSessionActive {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                        }
                        Image(systemName: "star.fill")
                        Text("Action")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(viewModel.isSessionActive ? Color.purple.opacity(0.2) : Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
                .disabled(!viewModel.isSessionActive)
                
                Button(action: resetApp) {
                    VStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            // Hint when session inactive
            if !viewModel.isSessionActive {
                Text("🔒 Buttons locked - start session")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            StatusRow(
                icon: "message.fill",
                title: "Last message:",
                value: viewModel.lastReceivedMessage
            )
            
            StatusRow(
                icon: "arrow.up.circle.fill",
                title: "Sent:",
                value: "\(viewModel.messagesSentCount)",
                valueColor: .blue
            )
            
            StatusRow(
                icon: "arrow.down.circle.fill",
                title: "Received:",
                value: "\(viewModel.messagesReceivedCount)",
                valueColor: .green
            )
            
            StatusRow(
                icon: "circle.fill",
                title: "Status:",
                value: viewModel.appStatus,
                valueColor: viewModel.appStatus.contains("active") ? .green : .secondary
            )
            
            // Display userId if session active
            if viewModel.isSessionActive,
               let userId = extractUserId(from: viewModel.appStatus) {
                StatusRow(
                    icon: "person.badge.key.fill",
                    title: "User ID:",
                    value: userId,
                    valueColor: .blue
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Actions
    
    private func sendMessageToReact() {
        guard viewModel.isSessionActive else {
            print("⚠️ Cannot send - session not active")
            return
        }
        
        guard let coordinator = webViewCoordinator else {
            print("⚠️ Coordinator not available")
            return
        }
        
        let message = viewModel.prepareMessageForJavaScript()
        coordinator.sendMessageToJavaScript(message)
    }
    
    private func startSession() {
        let userId = "user_\(UUID().uuidString.prefix(8))"
        viewModel.startSession(userId: userId)
        
        // Send session info to React
        guard let coordinator = webViewCoordinator else { return }
        
        let message: [String: Any] = [
            "type": "session_started",
            "payload": [
                "userId": userId,
                "timestamp": Date().ISO8601Format(),
                "message": "Session started for \(userId)"
            ]
        ]
        
        coordinator.sendMessageToJavaScript(message)
        viewModel.messagesSentCount += 1
    }
    
    private func sendCustomAction() {
        guard viewModel.isSessionActive else {
            print("⚠️ Cannot send - session not active")
            return
        }
        
        guard let coordinator = webViewCoordinator else { return }
        
        let message: [String: Any] = [
            "type": "custom_action",
            "payload": [
                "action": "subscribe",
                "timestamp": Date().ISO8601Format(),
                "data": "Custom action from Swift"
            ]
        ]
        
        // Increment counter BEFORE sending
        viewModel.messagesSentCount += 1
        
        coordinator.sendMessageToJavaScript(message)
        viewModel.logEvent(
            type: "custom_action_sent",
            data: ["count": viewModel.messagesSentCount]
        )
    }
    
    private func resetApp() {
        // If session was active, send session_ended to React
        if viewModel.isSessionActive, let coordinator = webViewCoordinator {
            let message: [String: Any] = [
                "type": "session_ended",
                "payload": [
                    "timestamp": Date().ISO8601Format(),
                    "reason": "user_reset"
                ]
            ]
            coordinator.sendMessageToJavaScript(message)
            print("📤 Sent session_ended to React")
        }
        
        // Reset ViewModel state
        viewModel.reset()
    }
    
    // MARK: - Helper Methods
    
    /// Extracts userId from status text
    private func extractUserId(from status: String) -> String? {
        // Status format: "Session active for: user_abc12345"
        let components = status.components(separatedBy: ": ")
        return components.count > 1 ? components[1] : nil
    }
}

// MARK: - Supporting Views

/// Wrapper for WebViewContainer enabling coordinator access
struct WebViewContainerWrapper: UIViewRepresentable {
    let url: URL
    let viewModel: WebViewViewModel
    @Binding var coordinator: WebViewContainer.Coordinator?
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
        
        let contentController = configuration.userContentController
        contentController.add(context.coordinator, name: "nativeApp")
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.bounces = true
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        context.coordinator.webView = webView
        
        // Save coordinator for later use
        DispatchQueue.main.async {
            self.coordinator = context.coordinator
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> WebViewContainer.Coordinator {
        WebViewContainer.Coordinator(viewModel: viewModel)
    }
}

/// Status row with icon, title and value
struct StatusRow: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(valueColor)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
