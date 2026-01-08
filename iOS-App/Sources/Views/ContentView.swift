import SwiftUI

struct ContentView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = WebViewViewModel()
    @State private var webViewCoordinator: WebViewContainer.Coordinator?
    
    // URL do aplikacji React - w produkcji można to zmienić na zdalny URL
    private let reactAppURL = URL(string: "http://localhost:3000")!
    
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
            Text("Dreams SDK + WebView Demo")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("Dwukierunkowa komunikacja Swift ↔ JavaScript")
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
            // Przycisk wysyłania wiadomości
            Button(action: sendMessageToReact) {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("Wyślij wiadomość do React")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // Dodatkowe przyciski akcji
            HStack(spacing: 12) {
                Button(action: startDreamsSession) {
                    VStack {
                        Image(systemName: "person.fill")
                        Text("Start Sesji")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
                }
                
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
        }
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            StatusRow(
                icon: "message.fill",
                title: "Ostatnia wiadomość:",
                value: viewModel.lastReceivedMessage
            )
            
            StatusRow(
                icon: "number",
                title: "Wysłano wiadomości:",
                value: "\(viewModel.messagesSentCount)"
            )
            
            StatusRow(
                icon: "circle.fill",
                title: "Dreams SDK:",
                value: viewModel.dreamsSDKStatus,
                valueColor: .green
            )
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Actions
    
    private func sendMessageToReact() {
        guard let coordinator = webViewCoordinator else {
            print("⚠️ Coordinator not available")
            return
        }
        
        let message = viewModel.prepareMessageForJavaScript()
        coordinator.sendMessageToJavaScript(message)
    }
    
    private func startDreamsSession() {
        let userId = "user_\(UUID().uuidString.prefix(8))"
        viewModel.startDreamsSession(userId: userId)
    }
    
    private func resetApp() {
        viewModel.reset()
    }
}

// MARK: - Supporting Views

/// Wrapper dla WebViewContainer umożliwiający dostęp do coordinator
struct WebViewContainerWrapper: UIViewRepresentable {
    let url: URL
    let viewModel: WebViewViewModel
    @Binding var coordinator: WebViewContainer.Coordinator?
    
    func makeUIView(context: Context) -> WKWebView {
        let webViewContainer = WebViewContainer(url: url, viewModel: viewModel)
        let webView = webViewContainer.makeUIView(context: context)
        
        // Zapisz coordinator dla późniejszego użycia
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

/// Wiersz statusu z ikoną, tytułem i wartością
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
