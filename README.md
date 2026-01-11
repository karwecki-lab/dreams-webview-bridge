# 🚀 Native WebView Bridge - Pure Swift ↔ React Communication

Kompletna, **natywna** implementacja dwukierunkowej komunikacji między iOS (SwiftUI) a React (WebView).

**✨ Zero external dependencies - czysty Swift + React**

---

## 🎯 Co to jest?

Minimalistyczny, produkcyjny przykład komunikacji między:
- **iOS natywny** (Swift/SwiftUI + WKWebView)
- **React app** uruchomiony w WebView

**Bez dodatkowych bibliotek!** Tylko standard library iOS i React.

---

## ✅ Funkcjonalność

### Komunikacja
- ✅ **Swift → JavaScript** przez `evaluateJavaScript()`
- ✅ **JavaScript → Swift** przez `webkit.messageHandlers`
- ✅ Format JSON z `type` i `payload`
- ✅ Dwukierunkowa w czasie rzeczywistym

### UI Features
- ✅ Profesjonalny interfejs
- ✅ Historia wiadomości
- ✅ Liczniki wysłanych/otrzymanych
- ✅ Status połączenia
- ✅ Resetowanie stanu

### Logging
- ✅ Szczegółowe logi do konsoli
- ✅ Timestampy dla każdego zdarzenia
- ✅ Tracking statystyk komunikacji

---

## 📦 Struktura projektu

```
WebViewBridge-Native/
├── iOS-App/
│   ├── WebViewBridgeApp.swift      # Entry point
│   ├── WebViewViewModel.swift      # Business logic
│   ├── ContentView.swift           # UI
│   ├── WebViewContainer.swift      # WKWebView bridge
│   └── Info.plist                  # Configuration
│
├── React-App/
│   ├── src/
│   │   ├── App.js                  # Main component
│   │   └── App.css                 # Styling
│   └── package.json                # Dependencies
│
└── README.md                       # Ten plik
```

---

## 🚀 Szybki start

### Wymagania
- Xcode 15.0+
- Node.js 16.0+
- iOS 16.0+

### 1. Uruchom React App

```bash
cd React-App
npm install
npm start
```

Aplikacja uruchomi się na `http://localhost:3000`

### 2. Uruchom iOS App

#### Opcja A: Utwórz nowy projekt Xcode (ZALECANE)

1. **Otwórz Xcode**
2. **File → New → Project**
3. **iOS → App**
4. Wypełnij:
   ```
   Product Name: WebViewBridge
   Interface: SwiftUI
   Language: Swift
   ```
5. **Zapisz projekt**

6. **Usuń domyślne pliki:**
   - `WebViewBridgeApp.swift` (domyślny)
   - `ContentView.swift` (domyślny)

7. **Dodaj nasze pliki:**
   - Przeciągnij wszystkie 4 pliki Swift z `iOS-App/`
   - Zaznacz: ✅ **Copy items if needed**
   - Zastąp `Info.plist` naszym plikiem

8. **Build i Run:**
   ```
   Cmd + B  (build)
   Cmd + R  (run)
   ```

#### Opcja B: Manual Setup (dla zaawansowanych)

Zobacz: `XCODE_SETUP.md` dla szczegółowych instrukcji

---

## 📡 API Komunikacji

### Swift → JavaScript

```swift
// Przygotuj wiadomość
let message = viewModel.prepareMessageForJavaScript()

// Wyślij przez coordinator
coordinator.sendMessageToJavaScript(message)
```

### JavaScript → Swift

```javascript
// Wyślij wiadomość
window.webkit.messageHandlers.nativeApp.postMessage({
  type: 'greeting',
  payload: {
    text: 'Hello from React!',
    timestamp: new Date().toISOString()
  }
});
```

### Format wiadomości

```json
{
  "type": "string",
  "payload": {
    "text": "string",
    "timestamp": "ISO8601",
    "custom_fields": "..."
  }
}
```

---

## 💡 Przykłady użycia

### 1. Wysyłanie danych użytkownika (Swift → React)

```swift
let message: [String: Any] = [
    "type": "user_data",
    "payload": [
        "userId": "user123",
        "name": "John Doe",
        "email": "john@example.com"
    ]
]
coordinator.sendMessageToJavaScript(message)
```

### 2. Odbieranie akcji (React → Swift)

```javascript
const sendAction = () => {
  window.webkit.messageHandlers.nativeApp.postMessage({
    type: 'user_action',
    payload: {
      action: 'button_clicked',
      buttonId: 'submit',
      timestamp: new Date().toISOString()
    }
  });
};
```

### 3. Obsługa w Swift

```swift
func handleMessageFromJavaScript(_ message: [String: Any]) {
    guard let type = message["type"] as? String else { return }
    
    switch type {
    case "user_action":
        handleUserAction(message)
    case "data_request":
        sendDataToReact()
    default:
        print("Unknown message type: \(type)")
    }
}
```

---

## 🏗 Architektura

### iOS (MVVM Pattern)

```
ContentView (SwiftUI)
    ↓
WebViewViewModel (ObservableObject)
    ↓
WebViewContainer (UIViewRepresentable)
    ↓
WKWebView + Coordinator (Bridge)
```

### Przepływ danych

```
User Action (iOS)
    → ViewModel.prepareMessage()
    → Coordinator.sendMessageToJavaScript()
    → evaluateJavaScript()
    → window.receiveMessageFromNative() [JS]
    → React State Update
    → UI Render

User Action (React)
    → window.webkit.messageHandlers.nativeApp.postMessage()
    → WKScriptMessageHandler
    → Coordinator.userContentController()
    → ViewModel.handleMessageFromJavaScript()
    → @Published property update
    → SwiftUI View update
```

---

## 🔧 Konfiguracja

### Zmiana URL React App

W `ContentView.swift`:

```swift
private let reactAppURL = URL(string: "YOUR_URL_HERE")!
```

### Dla prawdziwego urządzenia

Zamień `localhost` na IP komputera:

```swift
private let reactAppURL = URL(string: "http://192.168.1.XXX:3000")!
```

Znajdź IP:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

### Production Build (React)

```bash
cd React-App
npm run build
```

Hostuj `build/` folder i zmień URL w iOS app.

---

## 📊 Features

| Feature | Status | Opis |
|---------|--------|------|
| Swift → JS | ✅ | evaluateJavaScript |
| JS → Swift | ✅ | webkit.messageHandlers |
| JSON Format | ✅ | Strukturyzowane wiadomości |
| Type Safety | ✅ | Swift type checking |
| Error Handling | ✅ | Try-catch + logging |
| UI Feedback | ✅ | Real-time updates |
| Logging | ✅ | Console + timestamps |
| Statistics | ✅ | Sent/received counters |
| Reset State | ✅ | Clean reset function |

---

## 🐛 Troubleshooting

### Problem: WebView pokazuje pustą stronę

**Rozwiązanie:**
1. Sprawdź czy React dev server działa: `http://localhost:3000`
2. Sprawdź logi Xcode Console
3. Sprawdź `Info.plist` - `NSAllowsLocalNetworking` = `true`

### Problem: Wiadomości nie są odbierane

**Rozwiązanie:**
1. Sprawdź Console w Xcode - czy są logi?
2. Sprawdź Safari Web Inspector (dla WebView)
3. Upewnij się że `window.receiveMessageFromNative` jest zdefiniowana

### Problem: Build error w Xcode

**Rozwiązanie:**
1. Clean Build Folder: Cmd + Shift + K
2. Sprawdź czy wszystkie pliki są dodane do target
3. Sprawdź czy Interface = SwiftUI w projekcie

---

## 📚 Dlaczego Native (bez SDK)?

### Zalety

✅ **Zero dependencies** - tylko standard library
✅ **Prostsze** - łatwiej zrozumieć i utrzymać
✅ **Szybsze** - brak dodatkowych warstw
✅ **Mniejsze** - mniej kodu, mniejszy build
✅ **Bardziej stabilne** - brak zewnętrznych breaking changes
✅ **Łatwiejszy debugging** - mniej abstrakcji

### Kiedy dodać SDK?

Rozważ dodanie SDK (np. Dreams, Analytics) gdy:
- Potrzebujesz zaawansowanej analytics
- Masz gotową integrację z backendem
- Zespół już używa tego SDK
- Potrzebujesz konkretnych features SDK

**Ten projekt to idealna baza** do dodania dowolnego SDK później!

---

## 🎓 Nauka

### Dla początkujących

1. Przestudiuj `WebViewViewModel.swift` - prosta logika
2. Zobacz `WebViewContainer.swift` - bridge implementacja
3. Przetestuj wysyłanie wiadomości
4. Zmodyfikuj `App.js` - dodaj własne akcje

### Dla zaawansowanych

1. Dodaj własne typy wiadomości
2. Implementuj error handling
3. Dodaj persistence (UserDefaults)
4. Zintegruj z backendem
5. Dodaj testy jednostkowe

---

## 🔐 Security

### Najlepsze praktyki

1. **Waliduj wiadomości:**
   ```swift
   guard let type = message["type"] as? String,
         type.count < 50 else { return }
   ```

2. **Whitelist typów wiadomości:**
   ```swift
   let allowedTypes = ["greeting", "user_action", "data_request"]
   guard allowedTypes.contains(type) else { return }
   ```

3. **Sanityzuj dane:**
   ```swift
   let text = (payload["text"] as? String)?
       .trimmingCharacters(in: .whitespacesAndNewlines)
   ```

4. **Używaj HTTPS w produkcji**

---

## 📄 Licencja

MIT License - wolne użycie komercyjne i open source.

---

## 🤝 Contributing

Pull requesty mile widziane!

1. Fork projektu
2. Utwórz branch (`git checkout -b feature/amazing`)
3. Commit (`git commit -m 'Add feature'`)
4. Push (`git push origin feature/amazing`)
5. Otwórz Pull Request

---

## 📞 Support

Masz pytania? Problemy?

1. Sprawdź ten README
2. Zobacz logi w Xcode Console
3. Sprawdź Safari Web Inspector
4. Otwórz Issue na GitHub

---

## ✨ Co dalej?

Po opanowaniu podstaw:

1. ✅ Dodaj własne typy wiadomości
2. ✅ Zintegruj z backendem
3. ✅ Dodaj persistence
4. ✅ Implementuj authentication
5. ✅ Dodaj analytics (opcjonalnie)
6. ✅ Wdróż na produkcję

---

**Happy Coding!** 🚀

Prosty, czysty, produkcyjny kod bez magii i zależności.
