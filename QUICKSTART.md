# 🚀 Szybki Start - Dreams WebView Demo

Ten przewodnik pomoże Ci uruchomić obie aplikacje w mniej niż 5 minut.

## ⚡ Szybka instalacja

### Krok 1: React App (Terminal 1)

```bash
cd React-App
npm install
npm start
```

✅ React powinien uruchomić się na `http://localhost:3000`

### Krok 2: iOS App (Xcode)

1. Otwórz `iOS-App` w Xcode
2. Poczekaj na pobranie Dreams SDK (Swift Package Manager)
3. Naciśnij **Cmd + R** aby uruchomić

✅ iOS app automatycznie załaduje React z localhost:3000

---

## 🎯 Test komunikacji

### Test 1: Swift → React

1. W aplikacji iOS kliknij **"Wyślij wiadomość do React"**
2. W React powinien pojawić się nowy komunikat w sekcji "Odebrane z iOS"
3. Sprawdź logi w Xcode Console: `📤 Sending to React`

### Test 2: React → Swift

1. W aplikacji React kliknij **"Wyślij wiadomość do Swift"**
2. W iOS powinien zaktualizować się tekst "Ostatnia wiadomość"
3. Sprawdź logi w Safari Web Inspector: `📨 Received from Native`

---

## 🔍 Weryfikacja Dreams SDK

### W Xcode Console sprawdź:

```
✅ Dreams SDK initialized successfully
📊 Dreams SDK: Logged event 'app_initialized'
📊 Dreams SDK: Logged event 'webview_loaded'
```

### Jeśli nie widzisz logów:

1. Sprawdź konfigurację w `DreamsWebViewApp.swift`:
   ```swift
   Dreams.shared.enableDebugLogging(true)
   ```

2. Upewnij się, że masz ustawiony API key (nawet testowy):
   ```swift
   apiKey: "test-api-key"
   ```

---

## 📱 Testowanie na prawdziwym urządzeniu

### Problem: Nie mogę połączyć się z localhost

**Rozwiązanie:**

1. Znajdź IP swojego komputera:
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   ```

2. Zmień URL w `ContentView.swift`:
   ```swift
   private let reactAppURL = URL(string: "http://192.168.1.XXX:3000")!
   ```

3. Upewnij się, że iPhone i Mac są w tej samej sieci WiFi

---

## 🐛 Najczęstsze problemy

### Problem: "Cannot find package 'dreams-ios-sdk'"

**Rozwiązanie:**
- File → Add Packages w Xcode
- Wklej: `https://github.com/getdreams/dreams-ios-sdk`
- Wybierz wersję 3.0.0+

### Problem: React pokazuje "Not in WKWebView"

**Rozwiązanie:**
- To normalne w przeglądarce
- Uruchom aplikację iOS, żeby zobaczyć pełną funkcjonalność

### Problem: WebView pokazuje pustą stronę

**Rozwiązanie:**
1. Sprawdź czy React dev server działa: `http://localhost:3000`
2. Sprawdź logi w Xcode: `didFail navigation`
3. Sprawdź Info.plist - `NSAllowsLocalNetworking` musi być `true`

---

## 📊 Co zobaczyć w logach

### Xcode Console (iOS)

```
✅ Dreams SDK initialized successfully
✅ WebView finished loading
📤 Sending to React: ["type": "greeting", "payload": {...}]
📨 Received from React: ["type": "greeting", "payload": {...}]
📊 Dreams SDK: Logged event 'message_sent_to_react' with data: {...}
```

### Safari Web Inspector (React)

```
✅ Running in WKWebView environment
📤 Sent ready message to Native
📤 Sent to Native: {type: "greeting", payload: {...}}
📨 Received from Native: {type: "greeting", payload: {...}}
```

---

## 🎨 Dostosowywanie

### Zmiana wyglądu React

Edytuj `React-App/src/App.css`:
- Gradient: `.App { background: linear-gradient(...) }`
- Kolory przycisków: `.primary-button { background: ... }`

### Dodanie nowych typów wiadomości

1. **iOS** - w `WebViewViewModel.swift`:
   ```swift
   let message: [String: Any] = [
       "type": "custom_type",
       "payload": ["data": "value"]
   ]
   ```

2. **React** - w `App.js`:
   ```javascript
   const message = {
       type: 'custom_type',
       payload: { data: 'value' }
   };
   ```

### Dodanie nowych zdarzeń Dreams SDK

W `WebViewViewModel.swift`:

```swift
viewModel.logDreamsEvent(
    type: "custom_event",
    data: [
        "event_name": "button_clicked",
        "screen": "main",
        "timestamp": Date().ISO8601Format()
    ]
)
```

---

## 📚 Następne kroki

1. **Przeczytaj [README.md](README.md)** - pełna dokumentacja architektury
2. **Eksploruj kod** - wszystkie pliki są dobrze skomentowane
3. **Dostosuj do swoich potrzeb** - dodaj własną logikę biznesową
4. **Integruj z backendem** - połącz Dreams SDK z prawdziwym API

---

## 💡 Przydatne komendy

### React

```bash
npm start              # Uruchom dev server
npm run build          # Zbuduj dla produkcji
npm test               # Uruchom testy
```

### iOS

```
Cmd + R                # Uruchom aplikację
Cmd + B                # Build
Cmd + .                # Stop
Cmd + Shift + K        # Clean build folder
```

---

## 🆘 Potrzebujesz pomocy?

1. Sprawdź [README.md](README.md) - szczegółowa dokumentacja
2. Sprawdź [iOS-App/README.md](iOS-App/README.md) - iOS specifics
3. Sprawdź [React-App/README.md](React-App/README.md) - React specifics
4. Sprawdź logi w Xcode Console i Safari Web Inspector

---

## ✨ Gratulacje!

Masz działający system komunikacji między iOS a React z integracją Dreams SDK! 🎉

Teraz możesz:
- ✅ Wysyłać wiadomości w obie strony
- ✅ Śledzić zdarzenia w Dreams SDK
- ✅ Budować zaawansowane aplikacje webview
- ✅ Integrować z prawdziwymi serwisami

**Happy coding!** 🚀
