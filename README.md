# Dreams WebView Demo - Dokumentacja

## 📋 Spis treści

1. [Architektura rozwiązania](#architektura-rozwiązania)
2. [Mechanizm komunikacji](#mechanizm-komunikacji)
3. [Integracja Dreams iOS SDK](#integracja-dreams-ios-sdk)
4. [Instalacja i uruchomienie](#instalacja-i-uruchomienie)
5. [Struktura projektów](#struktura-projektów)
6. [API komunikacji](#api-komunikacji)

---

## 🏗 Architektura rozwiązania

### Komponenty systemu

```
┌─────────────────────────────────────────┐
│         Aplikacja iOS (SwiftUI)         │
│  ┌───────────────────────────────────┐  │
│  │      DreamsWebViewApp.swift       │  │
│  │  (Inicjalizacja Dreams SDK)       │  │
│  └───────────────────────────────────┘  │
│                   │                      │
│  ┌───────────────────────────────────┐  │
│  │        ContentView.swift          │  │
│  │  (Główny widok z kontrolkami)     │  │
│  └───────────────────────────────────┘  │
│                   │                      │
│  ┌───────────────────────────────────┐  │
│  │      WebViewContainer.swift       │  │
│  │  (UIViewRepresentable wrapper)    │  │
│  │         + Coordinator              │  │
│  └───────────────────────────────────┘  │
│                   │                      │
│  ┌───────────────────────────────────┐  │
│  │      WebViewViewModel.swift       │  │
│  │  (Logika biznesowa + Dreams)      │  │
│  └───────────────────────────────────┘  │
│                   │                      │
│         WKWebView (Bridge)               │
│                   │                      │
└─────────────────────────────────────────┘
                    │
            JavaScript Bridge
                    │
┌─────────────────────────────────────────┐
│       Aplikacja React (WebView)         │
│  ┌───────────────────────────────────┐  │
│  │           App.js                  │  │
│  │  - window.webkit.messageHandlers  │  │
│  │  - window.receiveMessageFromNative│  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### Przepływ danych

1. **Inicjalizacja**
   - iOS inicjalizuje Dreams SDK w `DreamsWebViewApp.swift`
   - React app uruchamia się w WKWebView
   - React wysyła wiadomość `app_ready` do iOS

2. **Komunikacja Swift → React**
   - Użytkownik klika przycisk w iOS
   - `WebViewViewModel` przygotowuje wiadomość JSON
   - `Coordinator` wywołuje `evaluateJavaScript` z wiadomością
   - React odbiera wiadomość przez `window.receiveMessageFromNative()`

3. **Komunikacja React → Swift**
   - Użytkownik klika przycisk w React
   - React wywołuje `window.webkit.messageHandlers.nativeApp.postMessage()`
   - `WKScriptMessageHandler` odbiera wiadomość w `Coordinator`
   - `WebViewViewModel` przetwarza wiadomość i aktualizuje UI

---

## 🔄 Mechanizm komunikacji SwiftUI ↔ JavaScript

### 1. JavaScript → Swift (React → iOS)

**React (JavaScript):**
```javascript
const message = {
  type: 'greeting',
  payload: {
    text: 'Cześć z React!',
    timestamp: new Date().toISOString()
  }
};

window.webkit.messageHandlers.nativeApp.postMessage(message);
```

**Swift (iOS):**
```swift
// WebViewContainer.swift - Coordinator
func userContentController(
    _ userContentController: WKUserContentController,
    didReceive message: WKScriptMessage
) {
    guard message.name == "nativeApp" else { return }
    
    if let messageBody = message.body as? [String: Any] {
        viewModel.handleMessageFromJavaScript(messageBody)
    }
}
```

**Kluczowe elementy:**
- `window.webkit.messageHandlers.<nazwa>` - interfejs WebKit do komunikacji
- Nazwa handlera (`nativeApp`) musi być zarejestrowana w `WKUserContentController`
- Wiadomości są automatycznie serializowane do formatu Swift
- Obsługa odbywa się przez protokół `WKScriptMessageHandler`

### 2. Swift → JavaScript (iOS → React)

**Swift (iOS):**
```swift
// WebViewContainer.swift - Coordinator
func sendMessageToJavaScript(_ message: [String: Any]) {
    guard let jsonData = try? JSONSerialization.data(withJSONObject: message),
          let jsonString = String(data: jsonData, encoding: .utf8) else {
        return
    }
    
    let script = "window.receiveMessageFromNative(\(jsonString));"
    webView.evaluateJavaScript(script) { result, error in
        // Handle result
    }
}
```

**React (JavaScript):**
```javascript
// Globalna funkcja rejestrowana w useEffect
useEffect(() => {
  window.receiveMessageFromNative = (message) => {
    console.log('Received from Native:', message);
    setMessagesFromNative(prev => [message, ...prev]);
  };
  
  return () => {
    delete window.receiveMessageFromNative;
  };
}, []);
```

**Kluczowe elementy:**
- `evaluateJavaScript()` - metoda WKWebView do wykonywania kodu JavaScript
- Globalna funkcja JavaScript musi być zdefiniowana przed wywołaniem
- Serializacja JSON po stronie Swift, deserializacja automatyczna w JavaScript
- Asynchroniczna obsługa z callback'iem

### 3. Format wiadomości

**Struktura JSON:**
```json
{
  "type": "string",      // Typ wiadomości (np. 'greeting', 'user_action')
  "payload": {           // Dane wiadomości
    "text": "string",    // Opcjonalna treść tekstowa
    "timestamp": "ISO8601",
    "custom_field": "value"
  }
}
```

**Typy wiadomości:**
- `greeting` - powitanie/testowa wiadomość
- `user_action` - akcja użytkownika
- `app_ready` - gotowość aplikacji React
- `session_started` - rozpoczęcie sesji Dreams

---

## 🌟 Integracja Dreams iOS SDK

### 1. Gdzie jest wykorzystywany Dreams SDK

#### A. Inicjalizacja (DreamsWebViewApp.swift)
```swift
private func configureDreamsSDK() {
    let configuration = DreamsConfiguration(
        apiKey: "your-api-key-here",
        environment: .sandbox
    )
    
    Dreams.shared.configure(with: configuration)
    Dreams.shared.enableDebugLogging(true)
}
```

**Cel:** Jednorazowa konfiguracja SDK przy starcie aplikacji z parametrami środowiska.

#### B. Logowanie zdarzeń (WebViewViewModel.swift)
```swift
func logDreamsEvent(type: String, data: [String: Any]) {
    Dreams.shared.trackEvent(
        name: type,
        properties: data
    )
    
    print("📊 Dreams SDK: Logged event '\(type)'")
}
```

**Cel:** Śledzenie wszystkich istotnych zdarzeń w aplikacji:
- Inicjalizacja aplikacji
- Załadowanie WebView
- Wysłanie/otrzymanie wiadomości
- Akcje użytkownika
- Błędy

#### C. Zarządzanie sesją (WebViewViewModel.swift)
```swift
func startDreamsSession(userId: String) {
    Dreams.shared.identify(userId: userId)
    dreamsSDKStatus = "Sesja aktywna dla: \(userId)"
    
    logDreamsEvent(
        type: "session_started",
        data: ["userId": userId]
    )
}
```

**Cel:** Identyfikacja użytkownika i śledzenie jego aktywności w ramach sesji.

### 2. Przykładowe zdarzenia logowane do Dreams SDK

| Zdarzenie | Kiedy | Dane |
|-----------|-------|------|
| `app_initialized` | Start aplikacji | timestamp |
| `webview_loaded` | Załadowanie React | url, timestamp |
| `webview_error` | Błąd WebView | error, timestamp |
| `message_received_from_react` | Otrzymanie wiadomości | messageType, payload |
| `message_sent_to_react` | Wysłanie wiadomości | messageType, count |
| `session_started` | Start sesji użytkownika | userId, timestamp |
| `app_reset` | Reset aplikacji | timestamp |

### 3. Korzyści z integracji Dreams SDK

- **Analityka**: Pełna widoczność interakcji użytkownika
- **Debugging**: Szczegółowe logi komunikacji WebView
- **Sesje**: Śledzenie zachowań użytkowników
- **Metryki**: Liczniki wiadomości, błędów, akcji
- **Produkcja**: Gotowe do integracji z backendem Dreams

### 4. Rozszerzanie funkcjonalności Dreams SDK

W rzeczywistej aplikacji można dodać:

```swift
// Śledzenie czasu spędzonego w WebView
Dreams.shared.trackTiming(
    category: "webview",
    variable: "session_duration",
    time: sessionDuration
)

// Śledzenie błędów
Dreams.shared.trackError(
    error: error,
    context: ["location": "webview_communication"]
)

// Zapisywanie atrybutów użytkownika
Dreams.shared.setUserAttributes([
    "platform": "iOS",
    "app_version": "1.0.0",
    "webview_enabled": true
])
```

---

## 🚀 Instalacja i uruchomienie

### Wymagania wstępne

- **iOS:**
  - Xcode 15.0+
  - iOS 16.0+
  - Swift 5.9+
  - CocoaPods lub Swift Package Manager

- **React:**
  - Node.js 16.0+
  - npm lub yarn

### Instalacja aplikacji iOS

1. **Otwórz projekt w Xcode:**
   ```bash
   cd iOS-App
   open DreamsWebViewApp.xcodeproj
   ```

2. **Zainstaluj zależności (Swift Package Manager):**
   - Xcode automatycznie pobierze Dreams iOS SDK
   - Lub ręcznie: File → Add Packages → `https://github.com/getdreams/dreams-ios-sdk`

3. **Konfiguracja Dreams SDK:**
   - Otwórz `DreamsWebViewApp.swift`
   - Zamień `"your-api-key-here"` na prawdziwy klucz API
   - Ustaw odpowiednie środowisko (`.sandbox` lub `.production`)

4. **Uruchom aplikację:**
   - Wybierz symulator lub urządzenie
   - Cmd + R

### Instalacja aplikacji React

1. **Zainstaluj zależności:**
   ```bash
   cd React-App
   npm install
   ```

2. **Uruchom serwer deweloperski:**
   ```bash
   npm start
   ```
   Aplikacja uruchomi się na `http://localhost:3000`

3. **Dla produkcji - build:**
   ```bash
   npm run build
   ```
   Zbudowane pliki znajdą się w katalogu `build/`

### Uruchomienie pełnego demo

1. **Uruchom React app:**
   ```bash
   cd React-App
   npm start
   ```

2. **Uruchom iOS app w Xcode**
   - Aplikacja automatycznie połączy się z `http://localhost:3000`

3. **Test komunikacji:**
   - Kliknij "Wyślij wiadomość do React" w iOS
   - Kliknij "Wyślij wiadomość do Swift" w React
   - Obserwuj logi w Xcode Console i Browser Console

---

## 📁 Struktura projektów

### Aplikacja iOS

```
iOS-App/
├── Package.swift                 # Definicja pakietu SPM
├── Info.plist                    # Konfiguracja aplikacji
└── Sources/
    ├── DreamsWebViewApp.swift    # Entry point + Dreams init
    ├── ViewModels/
    │   └── WebViewViewModel.swift    # Logika + Dreams integration
    └── Views/
        ├── ContentView.swift         # Główny widok UI
        └── WebViewContainer.swift    # WKWebView wrapper + Bridge
```

### Aplikacja React

```
React-App/
├── package.json              # Zależności npm
├── public/
│   └── index.html           # HTML template
└── src/
    ├── index.js             # Entry point React
    ├── index.css            # Global styles
    ├── App.js               # Główny komponent + komunikacja
    └── App.css              # Style komponentu
```

---

## 📡 API komunikacji

### Swift API

#### WebViewViewModel

```swift
// Obsługa wiadomości z JavaScript
func handleMessageFromJavaScript(_ message: [String: Any])

// Przygotowanie wiadomości do JavaScript
func prepareMessageForJavaScript() -> [String: Any]

// Logowanie zdarzenia do Dreams SDK
func logDreamsEvent(type: String, data: [String: Any])

// Rozpoczęcie sesji Dreams
func startDreamsSession(userId: String)

// Reset stanu
func reset()
```

#### WebViewContainer.Coordinator

```swift
// Wysłanie wiadomości do JavaScript
func sendMessageToJavaScript(_ message: [String: Any])

// WKScriptMessageHandler - odbieranie z JavaScript
func userContentController(
    _ userContentController: WKUserContentController,
    didReceive message: WKScriptMessage
)

// WKNavigationDelegate - obsługa nawigacji
func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
```

### JavaScript API

#### Wysyłanie do Swift

```javascript
window.webkit.messageHandlers.nativeApp.postMessage({
  type: 'message_type',
  payload: { /* dane */ }
});
```

#### Odbieranie z Swift

```javascript
window.receiveMessageFromNative = (message) => {
  // Przetwarzanie wiadomości
  console.log('Received:', message);
};
```

#### React Hooks

```javascript
const [messagesFromNative, setMessagesFromNative] = useState([]);
const [messagesSent, setMessagesSent] = useState(0);
const [isWebViewEnvironment, setIsWebViewEnvironment] = useState(false);
```

---

## 🔧 Rozwiązywanie problemów

### Problem: WebView nie łączy się z localhost

**Rozwiązanie:**
- Sprawdź czy React dev server działa na porcie 3000
- Upewnij się że `NSAllowsLocalNetworking` jest ustawione w Info.plist
- Użyj IP komputera zamiast localhost jeśli testujesz na fizycznym urządzeniu

### Problem: Wiadomości nie są odbierane

**Rozwiązanie:**
- Sprawdź czy handler jest zarejestrowany: `contentController.add(coordinator, name: "nativeApp")`
- Sprawdź nazwę handlera w JavaScript: `window.webkit.messageHandlers.nativeApp`
- Sprawdź czy `window.receiveMessageFromNative` jest zdefiniowana przed wywołaniem

### Problem: Dreams SDK nie loguje zdarzeń

**Rozwiązanie:**
- Sprawdź czy SDK jest poprawnie skonfigurowany w `DreamsWebViewApp.swift`
- Upewnij się że używasz prawdziwego API key
- Włącz debug logging: `Dreams.shared.enableDebugLogging(true)`
- Sprawdź logi w Xcode Console

---

## 📚 Dodatkowe zasoby

- [Dreams iOS SDK Documentation](https://github.com/getdreams/dreams-ios-sdk)
- [WKWebView Apple Documentation](https://developer.apple.com/documentation/webkit/wkwebview)
- [React Documentation](https://react.dev)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

---

## 📝 Licencja

MIT License - dostosuj według potrzeb projektu.

## 👥 Autorzy

Stworzone jako demo integracji Dreams SDK z WKWebView i React.
