# 🏗 Architektura systemu - Szczegółowy diagram

## Pełny przepływ komunikacji

```
┌─────────────────────────────────────────────────────────────────────┐
│                        APLIKACJA iOS (SwiftUI)                       │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              DreamsWebViewApp.swift (Entry Point)            │   │
│  │  ┌──────────────────────────────────────────────────────┐   │   │
│  │  │  func configureDreamsSDK() {                         │   │   │
│  │  │    Dreams.shared.configure(with: configuration)      │   │   │
│  │  │    Dreams.shared.enableDebugLogging(true)            │   │   │
│  │  │  }                                                    │   │   │
│  │  └──────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                       │
│                              │ WindowGroup                           │
│                              ▼                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                   ContentView.swift                          │   │
│  │  ┌──────────────────────────────────────────────────────┐   │   │
│  │  │  @StateObject private var viewModel                  │   │   │
│  │  │  @State private var webViewCoordinator               │   │   │
│  │  │                                                       │   │   │
│  │  │  VStack {                                             │   │   │
│  │  │    HeaderView                                         │   │   │
│  │  │    WebViewContainer ◄────────┐                       │   │   │
│  │  │    ControlsSection            │                       │   │   │
│  │  │    StatusSection              │                       │   │   │
│  │  │  }                            │                       │   │   │
│  │  └───────────────────────────────┼───────────────────────┘   │   │
│  └────────────────────────────────────────────────────────────┘   │
│                              │                                       │
│                              │ Binding                               │
│                              ▼                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              WebViewViewModel.swift (ObservableObject)       │   │
│  │  ┌──────────────────────────────────────────────────────┐   │   │
│  │  │  @Published var lastReceivedMessage: String          │   │   │
│  │  │  @Published var dreamsSDKStatus: String              │   │   │
│  │  │  @Published var messagesSentCount: Int               │   │   │
│  │  │                                                       │   │   │
│  │  │  func handleMessageFromJavaScript(_ message)  ◄──┐   │   │   │
│  │  │  func prepareMessageForJavaScript() ─────────────┼─┐ │   │   │
│  │  │  func logDreamsEvent(type, data) ────────┐       │ │ │   │   │
│  │  │  func startDreamsSession(userId)          │       │ │ │   │   │
│  │  └───────────────────────────────────────────┼───────┼─┼─┘   │   │
│  └────────────────────────────────────────────────────────────┘   │
│                              │                  │       │ │         │
│                              │                  │       │ │         │
│                              ▼                  │       │ │         │
│  ┌─────────────────────────────────────────────┼───────┼─┼─────┐   │
│  │        Dreams iOS SDK                       │       │ │     │   │
│  │  ┌──────────────────────────────────────────▼───┐   │ │     │   │
│  │  │  Dreams.shared.trackEvent(...)               │   │ │     │   │
│  │  │  Dreams.shared.identify(userId)              │   │ │     │   │
│  │  │  Dreams.shared.setUserAttributes(...)        │   │ │     │   │
│  │  └──────────────────────────────────────────────┘   │ │     │   │
│  └─────────────────────────────────────────────────────┘ │     │   │
│                              │                            │     │   │
│                              ▼                            │     │   │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │            WebViewContainer.swift (UIViewRepresentable)      │   │
│  │  ┌──────────────────────────────────────────────────────┐   │   │
│  │  │  func makeUIView(context) -> WKWebView              │   │   │
│  │  │  func makeCoordinator() -> Coordinator               │   │   │
│  │  │                                                       │   │   │
│  │  │  Coordinator: WKScriptMessageHandler {               │   │   │
│  │  │    func userContentController(didReceive) ───────────┼───┘   │
│  │  │    func sendMessageToJavaScript() ◄──────────────────┼───────┘
│  │  │  }                                                    │       │
│  │  └───────────────────────────────────────────────────────┘       │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                       │
│                              │ WKWebView                             │
│                              ▼                                       │
└─────────────────────────────────────────────────────────────────────┘
                               │
                               │ JavaScript Bridge
                               │
┌──────────────────────────────┼───────────────────────────────────────┐
│                        WKWEBVIEW (Safari Engine)                     │
│                              │                                       │
│    ┌─────────────────────────┼───────────────────────────────────┐  │
│    │  JavaScript Context     │                                   │  │
│    │                         ▼                                   │  │
│    │  window.webkit.messageHandlers.nativeApp.postMessage()     │  │
│    │                         │                                   │  │
│    │                         ▼                                   │  │
│    │  {                                                          │  │
│    │    name: "nativeApp",                                       │  │
│    │    postMessage: function(message) {                         │  │
│    │      // Bridge to native code                              │  │
│    │      [coordinator userContentController:didReceive:]       │  │
│    │    }                                                        │  │
│    │  }                                                          │  │
│    │                         │                                   │  │
│    └─────────────────────────┼───────────────────────────────────┘  │
│                              │                                       │
│                              │ HTTP Request                          │
│                              ▼                                       │
└─────────────────────────────────────────────────────────────────────┘
                               │
                               │ http://localhost:3000
                               │
┌──────────────────────────────┼───────────────────────────────────────┐
│                    REACT DEV SERVER (Node.js)                        │
│                              │                                       │
│                              ▼                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                      public/index.html                       │   │
│  │  ┌──────────────────────────────────────────────────────┐   │   │
│  │  │  <div id="root"></div>                               │   │   │
│  │  └──────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                       │
│                              ▼                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                        src/index.js                          │   │
│  │  ┌──────────────────────────────────────────────────────┐   │   │
│  │  │  ReactDOM.createRoot(...)                            │   │   │
│  │  │    .render(<App />)                                  │   │   │
│  │  └──────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                       │
│                              ▼                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                         App.js                               │   │
│  │  ┌──────────────────────────────────────────────────────┐   │   │
│  │  │  const [messagesFromNative, setMessages] = useState  │   │   │
│  │  │  const [messagesSent, setMessagesSent] = useState    │   │   │
│  │  │  const [isWebViewEnvironment, setIsWebView]          │   │   │
│  │  │                                                       │   │   │
│  │  │  useEffect(() => {                                    │   │   │
│  │  │    // Detekcja WebView                               │   │   │
│  │  │    const inWebView = !!window.webkit?.messageHandlers│   │   │
│  │  │    setIsWebView(inWebView)                           │   │   │
│  │  │                                                       │   │   │
│  │  │    // Rejestracja handlera                           │   │   │
│  │  │    window.receiveMessageFromNative = (msg) => {      │   │   │
│  │  │      setMessages(prev => [msg, ...prev])            │   │   │
│  │  │    }                                                  │   │   │
│  │  │  }, [])                                               │   │   │
│  │  │                                                       │   │   │
│  │  │  const sendMessageToNative = () => {                 │   │   │
│  │  │    window.webkit.messageHandlers                     │   │   │
│  │  │      .nativeApp.postMessage(message)                 │   │   │
│  │  │  }                                                    │   │   │
│  │  └──────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                       │
└──────────────────────────────┼───────────────────────────────────────┘
                               │
                               ▼
                          Browser Render
```

---

## Przepływ wiadomości - Krok po kroku

### Scenariusz 1: Swift → React

```
1. Użytkownik klika przycisk w iOS
   │
   ▼
2. ContentView.swift
   func sendMessageToReact()
   │
   ▼
3. WebViewViewModel.swift
   func prepareMessageForJavaScript() -> [String: Any]
   │
   ├─► Dreams SDK: logDreamsEvent("message_sent_to_react")
   │
   ▼
4. WebViewContainer.Coordinator
   func sendMessageToJavaScript(_ message: [String: Any])
   │
   ├─► Serialize message to JSON string
   │
   ▼
5. WKWebView.evaluateJavaScript()
   let script = "window.receiveMessageFromNative(\(jsonString));"
   │
   ▼
6. JavaScript Context (WKWebView)
   window.receiveMessageFromNative(message)
   │
   ▼
7. React App.js
   useEffect handler odbiera wiadomość
   │
   ├─► setMessagesFromNative(prev => [message, ...prev])
   │
   ▼
8. React UI aktualizuje się automatycznie
   Nowa wiadomość pojawia się w liście
```

### Scenariusz 2: React → Swift

```
1. Użytkownik klika przycisk w React
   │
   ▼
2. App.js
   sendMessageToNative()
   │
   ├─► Przygotowanie message object
   │
   ▼
3. window.webkit.messageHandlers.nativeApp.postMessage(message)
   │
   ▼
4. WebKit Bridge (automatyczna serializacja)
   JavaScript Object → Native Dictionary
   │
   ▼
5. WebViewContainer.Coordinator
   func userContentController(_:didReceive:)
   │
   ├─► Parse message.body as [String: Any]
   │
   ▼
6. WebViewViewModel.swift
   func handleMessageFromJavaScript(_ message: [String: Any])
   │
   ├─► Aktualizacja @Published properties
   ├─► Dreams SDK: logDreamsEvent("message_received_from_react")
   │
   ▼
7. SwiftUI reaktywność
   ContentView automatycznie re-renderuje
   │
   ▼
8. iOS UI pokazuje nową wiadomość
```

---

## Rejestracja i czyszczenie

### iOS - Message Handler Setup

```swift
// WebViewContainer.swift - makeUIView()
let configuration = WKWebViewConfiguration()
let contentController = configuration.userContentController

// KLUCZOWE: Rejestracja message handler
contentController.add(
    context.coordinator,        // WKScriptMessageHandler
    name: "nativeApp"           // Nazwa dostępna w JavaScript
)

let webView = WKWebView(frame: .zero, configuration: configuration)
```

### React - Function Registration

```javascript
// App.js - useEffect
useEffect(() => {
  // Rejestracja globalnej funkcji
  window.receiveMessageFromNative = (message) => {
    console.log('Received:', message);
    setMessagesFromNative(prev => [message, ...prev]);
  };
  
  // WAŻNE: Cleanup przy unmount
  return () => {
    delete window.receiveMessageFromNative;
  };
}, []);
```

---

## Format wiadomości - Struktura JSON

```json
{
  "type": "string",           // Typ wiadomości (routing key)
  "payload": {                // Dane (dowolna struktura)
    "text": "string",         // Opcjonalnie: treść tekstowa
    "timestamp": "ISO8601",   // Timestamp
    "custom_field": "value",  // Dodatkowe pola
    "nested": {               // Zagnieżdżone obiekty
      "data": "value"
    }
  }
}
```

### Przykładowe typy wiadomości:

| Typ | Kierunek | Opis | Payload |
|-----|----------|------|---------|
| `greeting` | ↔ | Powitanie | `{text, count, timestamp}` |
| `user_action` | React→iOS | Akcja użytkownika | `{action, timestamp}` |
| `app_ready` | React→iOS | Gotowość aplikacji | `{timestamp, message}` |
| `user_data` | iOS→React | Dane użytkownika | `{userId, name, email}` |
| `error_occurred` | ↔ | Błąd | `{errorCode, errorMessage}` |
| `data_request` | ↔ | Żądanie danych | `{requestId, dataType}` |
| `data_response` | ↔ | Odpowiedź | `{requestId, data}` |

---

## Dreams SDK - Punkty integracji

```
┌────────────────────────────────────────────────────────┐
│              Dreams SDK Integration Points              │
├────────────────────────────────────────────────────────┤
│                                                         │
│  1. DreamsWebViewApp.swift                             │
│     └─► Dreams.shared.configure(with: configuration)   │
│         └─► Dreams.shared.enableDebugLogging(true)     │
│                                                         │
│  2. WebViewViewModel.swift                             │
│     ├─► Dreams.shared.trackEvent(name, properties)     │
│     ├─► Dreams.shared.identify(userId)                 │
│     └─► Dreams.shared.setUserAttributes(attributes)    │
│                                                         │
│  3. Event Types Logged:                                │
│     ├─► app_initialized                                │
│     ├─► webview_loaded                                 │
│     ├─► webview_error                                  │
│     ├─► message_sent_to_react                          │
│     ├─► message_received_from_react                    │
│     ├─► session_started                                │
│     └─► app_reset                                      │
│                                                         │
└────────────────────────────────────────────────────────┘
```

---

## Stan aplikacji - Data Flow

```
┌─────────────────────────────────────────────────────────┐
│              WebViewViewModel (@Published)              │
│                                                          │
│  lastReceivedMessage ─────┐                             │
│  dreamsSDKStatus ──────────┼─► @Published              │
│  messagesSentCount ────────┘                             │
│                            │                             │
│                            ▼                             │
│                     ObjectWillChange                     │
│                            │                             │
│                            ▼                             │
└────────────────────────────┼─────────────────────────────┘
                             │
                             │ SwiftUI Reactivity
                             │
┌────────────────────────────▼─────────────────────────────┐
│                      ContentView                         │
│                                                          │
│  @StateObject var viewModel ◄──────────── Observes      │
│                                                          │
│  View aktualizuje się automatycznie                      │
│  gdy @Published properties się zmieniają                 │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Bezpieczeństwo i autoryzacja

```
┌──────────────────────────────────────────────────────────┐
│                  Security Considerations                  │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  1. Walidacja wiadomości                                 │
│     ├─► Sprawdź typ wiadomości przed przetworzeniem     │
│     ├─► Waliduj strukturę payload                        │
│     └─► Sanityzuj dane wejściowe                         │
│                                                           │
│  2. HTTPS w produkcji                                    │
│     ├─► Tylko HTTPS dla zdalnych URL                    │
│     ├─► Certificate pinning dla API                      │
│     └─► Nie używaj localhost w produkcji                 │
│                                                           │
│  3. Token management                                     │
│     ├─► Nie przechowuj tokenów w JavaScript             │
│     ├─► Używaj secure storage (Keychain)                │
│     └─► Implementuj token refresh                        │
│                                                           │
│  4. Content Security Policy                              │
│     ├─► Ogranicz dozwolone źródła                       │
│     ├─► Blokuj inline scripts w produkcji               │
│     └─► Używaj CSP headers                               │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

---

## Wydajność i optymalizacja

```
┌──────────────────────────────────────────────────────────┐
│              Performance Optimizations                    │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  1. Message batching                                     │
│     └─► Grupuj wiele wiadomości w jedną                 │
│                                                           │
│  2. Debouncing                                           │
│     └─► Ogranicz częstotliwość wysyłania                │
│                                                           │
│  3. Lazy loading                                         │
│     └─► Ładuj komponenty on-demand                       │
│                                                           │
│  4. Memory management                                    │
│     └─► Cleanup przy unmount/deinit                      │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

To kompletny, szczegółowy diagram architektury całego systemu!
