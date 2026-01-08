# Dreams WebView React App

Aplikacja React działająca w WKWebView z dwukierunkową komunikacją z aplikacją iOS Swift.

## 🎯 Funkcjonalność

- ✅ Pełna integracja z WKWebView
- ✅ Wysyłanie wiadomości do iOS przez `window.webkit.messageHandlers`
- ✅ Odbieranie wiadomości z iOS przez globalną funkcję JavaScript
- ✅ Format wiadomości JSON z typem i payload
- ✅ Historia odebranych wiadomości
- ✅ Licznik wysłanych wiadomości
- ✅ Detekcja środowiska WebView vs przeglądarka
- ✅ Responsywny UI z gradientowym designem

## 🏗 Architektura

### Struktura aplikacji

```
src/
├── index.js          # Entry point React
├── index.css         # Globalne style
├── App.js            # Główny komponent z logiką komunikacji
└── App.css           # Style komponentu
```

### Główne komponenty

1. **App.js** - Komponent główny z:
   - State management dla wiadomości
   - Logika komunikacji WebView
   - Obsługa zdarzeń użytkownika
   - Detekcja środowiska

2. **Komunikacja** - Dwa kierunki:
   - React → iOS: `window.webkit.messageHandlers.nativeApp.postMessage()`
   - iOS → React: `window.receiveMessageFromNative(message)`

## 🚀 Instalacja

### Wymagania

- Node.js 16.0+
- npm lub yarn

### Kroki instalacji

1. Zainstaluj zależności:
   ```bash
   npm install
   ```

2. Uruchom serwer deweloperski:
   ```bash
   npm start
   ```
   Aplikacja uruchomi się na `http://localhost:3000`

3. Build dla produkcji:
   ```bash
   npm run build
   ```
   Pliki znajdą się w `build/`

## 📱 Użytkowanie

### Testowanie w przeglądarce

Aplikacja działa również w przeglądarce z symulacją środowiska WebView:
- Przyciski wysyłania są wyłączone
- Wyświetlany jest status "Browser Mode"
- Można testować UI i layout

### Testowanie w WKWebView

1. Uruchom React dev server (`npm start`)
2. Uruchom aplikację iOS w Xcode
3. iOS automatycznie załaduje `http://localhost:3000`
4. Testuj komunikację przyciskami

## 🔄 API Komunikacji

### Wysyłanie wiadomości do iOS

```javascript
const message = {
  type: 'greeting',           // Typ wiadomości
  payload: {                  // Dane
    text: 'Cześć z React!',
    timestamp: new Date().toISOString()
  }
};

// Sprawdź dostępność interfejsu
if (window.webkit?.messageHandlers?.nativeApp) {
  window.webkit.messageHandlers.nativeApp.postMessage(message);
}
```

### Odbieranie wiadomości z iOS

```javascript
// Zarejestruj globalną funkcję
useEffect(() => {
  window.receiveMessageFromNative = (message) => {
    console.log('Received from iOS:', message);
    // Przetwórz wiadomość
  };
  
  return () => {
    delete window.receiveMessageFromNative;
  };
}, []);
```

### Format wiadomości

Wszystkie wiadomości mają strukturę:

```json
{
  "type": "string",      // Typ: greeting, user_action, app_ready
  "payload": {           // Dane specyficzne dla typu
    "text": "string",    // Opcjonalna treść
    "timestamp": "ISO8601",
    "custom_fields": "..."
  }
}
```

### Typy wiadomości

| Typ | Kierunek | Opis |
|-----|----------|------|
| `greeting` | ↔ Obie strony | Testowa wiadomość powitania |
| `user_action` | React → iOS | Akcja użytkownika w React |
| `app_ready` | React → iOS | Gotowość aplikacji React |
| `session_started` | iOS → React | Informacja o rozpoczęciu sesji |

## 🎨 Interfejs użytkownika

### Sekcje

1. **Header**
   - Tytuł aplikacji
   - Status połączenia (WKWebView vs Browser)

2. **Wysyłanie wiadomości**
   - Główny przycisk wysyłania
   - Przyciski akcji (Klik, Dane)
   - Licznik wysłanych wiadomości

3. **Odebrane wiadomości**
   - Lista wiadomości od iOS
   - Wyświetlanie typu i timestamp
   - Szczegóły payload w JSON

4. **Informacje**
   - Opis mechanizmu komunikacji
   - Kluczowe API

### Responsywność

Aplikacja jest w pełni responsywna:
- Mobile-first design
- Dostosowanie do różnych rozdzielczości
- Grid layout dla akcji
- Scrollowalna lista wiadomości

## 🔧 Konfiguracja

### Zmiana URL API

Jeśli chcesz połączyć się z backendem:

```javascript
const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001';
```

### Zmiana nazwy message handler

W `App.js` zmień:

```javascript
window.webkit.messageHandlers.TWOJA_NAZWA.postMessage(message);
```

**Uwaga:** Nazwa musi być identyczna z tą w iOS (`contentController.add(..., name: "TWOJA_NAZWA")`)

## 🐛 Debugging

### Logi konsoli

Aplikacja loguje wszystkie zdarzenia:

```javascript
console.log('📤 Sent to Native:', message);      // Wysłano
console.log('📨 Received from Native:', message); // Odebrano
console.log('✅ Running in WKWebView');           // Środowisko OK
console.log('⚠️ Not in WKWebView');               // Browser mode
```

### Chrome DevTools

Dla przeglądarki:
1. F12 - otwórz DevTools
2. Console - zobacz logi
3. Network - monitoruj zapytania

### Safari Web Inspector

Dla WKWebView:
1. Safari → Develop → [Twój symulator]
2. Wybierz aplikację
3. Console - zobacz logi JavaScript

## 📊 Stan aplikacji (React Hooks)

### State Variables

```javascript
const [messagesFromNative, setMessagesFromNative] = useState([]);
// Lista odebranych wiadomości

const [messagesSent, setMessagesSent] = useState(0);
// Licznik wysłanych wiadomości

const [isWebViewEnvironment, setIsWebViewEnvironment] = useState(false);
// Czy działa w WKWebView?
```

### Effects

```javascript
// Detekcja środowiska
useEffect(() => {
  const inWebView = window.webkit?.messageHandlers?.nativeApp;
  setIsWebViewEnvironment(!!inWebView);
}, []);

// Rejestracja funkcji odbierającej
useEffect(() => {
  window.receiveMessageFromNative = receiveMessageFromNative;
  return () => delete window.receiveMessageFromNative;
}, [receiveMessageFromNative]);

// Wysłanie wiadomości app_ready
useEffect(() => {
  if (isWebViewEnvironment) {
    // Wyślij po 500ms
  }
}, [isWebViewEnvironment]);
```

## 🌐 Deployment

### Build produkcyjny

```bash
npm run build
```

### Hosting statyczny

Build można hostować na:
- AWS S3 + CloudFront
- Netlify
- Vercel
- GitHub Pages

### Dla iOS (lokalny build)

1. Zbuduj aplikację: `npm run build`
2. Skopiuj zawartość `build/` do iOS Assets
3. Zmień URL w iOS na lokalny bundle path
4. Załaduj HTML z bundle:
   ```swift
   let url = Bundle.main.url(forResource: "index", withExtension: "html")!
   webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
   ```

## 🔗 Powiązane

- [README główny projektu](../README.md)
- [Aplikacja iOS](../iOS-App/README.md)
- [React Documentation](https://react.dev)
- [WKWebView Documentation](https://developer.apple.com/documentation/webkit/wkwebview)

## 🤝 Contributing

Pull requesty mile widziane!

1. Fork projektu
2. Stwórz branch (`git checkout -b feature/amazing`)
3. Commit zmian (`git commit -m 'Add amazing feature'`)
4. Push do branch (`git push origin feature/amazing`)
5. Otwórz Pull Request

## 📄 Licencja

MIT License
