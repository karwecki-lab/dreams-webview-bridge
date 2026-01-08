# Dreams WebView iOS App

Aplikacja iOS w SwiftUI demonstrująca integrację z Dreams SDK i dwukierunkową komunikację z aplikacją React w WKWebView.

## 🎯 Funkcjonalność

- ✅ WKWebView osadzony w SwiftUI przez UIViewRepresentable
- ✅ Dwukierunkowa komunikacja Swift ↔ JavaScript
- ✅ Integracja Dreams iOS SDK z pełnym logowaniem zdarzeń
- ✅ Obsługa sesji użytkowników
- ✅ UI z kontrolkami do testowania komunikacji
- ✅ Wyświetlanie statusu połączenia i historii wiadomości

## 🏗 Architektura

### Komponenty

1. **DreamsWebViewApp.swift** - Entry point aplikacji z inicjalizacją Dreams SDK
2. **ContentView.swift** - Główny widok z interfejsem użytkownika
3. **WebViewContainer.swift** - Wrapper dla WKWebView z komunikacją JavaScript
4. **WebViewViewModel.swift** - ViewModel zarządzający logiką i Dreams SDK

### Wzorce projektowe

- **MVVM** - Model-View-ViewModel dla separacji logiki
- **Coordinator Pattern** - Zarządzanie komunikacją WKWebView
- **ObservableObject** - Reaktywne zarządzanie stanem
- **UIViewRepresentable** - Bridge UIKit ↔ SwiftUI

## 🚀 Instalacja

### Wymagania

- Xcode 15.0+
- iOS 16.0+
- Swift 5.9+

### Kroki instalacji

1. Otwórz projekt w Xcode:
   ```bash
   open DreamsWebViewApp.xcodeproj
   ```

2. Zainstaluj zależności:
   - Xcode automatycznie pobierze Dreams iOS SDK przez SPM
   - Lub: File → Add Packages → `https://github.com/getdreams/dreams-ios-sdk`

3. Skonfiguruj Dreams SDK:
   - Otwórz `DreamsWebViewApp.swift`
   - Zamień `"your-api-key-here"` na prawdziwy klucz API Dreams
   - Wybierz środowisko: `.sandbox` lub `.production`

4. Uruchom aplikację:
   - Wybierz symulator lub urządzenie
   - Cmd + R

## 📱 Użytkowanie

### Komunikacja Swift → React

1. Kliknij przycisk "Wyślij wiadomość do React"
2. ViewModel przygotuje wiadomość JSON
3. Coordinator wywoła `evaluateJavaScript` z wiadomością
4. React odbierze wiadomość przez `window.receiveMessageFromNative()`

### Komunikacja React → Swift

1. React wywołuje `window.webkit.messageHandlers.nativeApp.postMessage()`
2. WKScriptMessageHandler odbiera wiadomość w Coordinator
3. ViewModel przetwarza wiadomość
4. UI aktualizuje się automatycznie przez @Published

### Dreams SDK Integration

SDK automatycznie loguje zdarzenia:
- Inicjalizacja aplikacji
- Załadowanie/błędy WebView
- Wysłane/odebrane wiadomości
- Sesje użytkowników
- Akcje użytkownika

## 🔧 Konfiguracja

### Info.plist

Aplikacja wymaga uprawnień dla localhost:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

### URL React App

Domyślnie: `http://localhost:3000`

Aby zmienić, edytuj w `ContentView.swift`:

```swift
private let reactAppURL = URL(string: "YOUR_URL_HERE")!
```

## 📊 Dreams SDK - Przykłady użycia

### Logowanie zdarzeń

```swift
viewModel.logDreamsEvent(
    type: "custom_event",
    data: [
        "key": "value",
        "timestamp": Date().ISO8601Format()
    ]
)
```

### Sesje użytkowników

```swift
viewModel.startDreamsSession(userId: "user_123")
```

## 🐛 Debugging

### Włącz szczegółowe logi Dreams SDK

W `DreamsWebViewApp.swift`:

```swift
Dreams.shared.enableDebugLogging(true)
```

### Logi w Xcode Console

- ✅ = sukces operacji
- 📊 = zdarzenie Dreams SDK
- 📨 = wiadomość otrzymana
- 📤 = wiadomość wysłana
- ⚠️ = ostrzeżenie
- ❌ = błąd

## 📚 Dokumentacja API

### WebViewViewModel

| Metoda | Opis |
|--------|------|
| `handleMessageFromJavaScript(_:)` | Obsługuje wiadomości z React |
| `prepareMessageForJavaScript()` | Tworzy wiadomość do React |
| `logDreamsEvent(type:data:)` | Loguje zdarzenie do Dreams SDK |
| `startDreamsSession(userId:)` | Rozpoczyna sesję użytkownika |
| `reset()` | Resetuje stan aplikacji |

### Published Properties

| Property | Typ | Opis |
|----------|-----|------|
| `lastReceivedMessage` | String | Ostatnia wiadomość z React |
| `dreamsSDKStatus` | String | Status Dreams SDK |
| `messagesSentCount` | Int | Licznik wysłanych wiadomości |

## 🔗 Powiązane

- [README główny projektu](../README.md)
- [Aplikacja React](../React-App/README.md)
- [Dreams iOS SDK](https://github.com/getdreams/dreams-ios-sdk)

## 📄 Licencja

MIT License
