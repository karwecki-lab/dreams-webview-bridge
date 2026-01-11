# ⚡ Quick Start - Native WebView Bridge

## 🎯 Uruchom w 5 minut!

---

## Krok 1: React App (2 minuty)

```bash
cd React-App
npm install
npm start
```

✅ Aplikacja uruchomi się na `http://localhost:3000`

---

## Krok 2: iOS App (3 minuty)

### A. Utwórz projekt Xcode

1. Otwórz Xcode
2. File → New → Project
3. iOS → App → Next
4. Wypełnij:
   ```
   Product Name: WebViewBridge
   Interface: SwiftUI  ⭐️
   Language: Swift
   ```
5. Zapisz na Desktop → Create

### B. Dodaj pliki

1. **Usuń** domyślne pliki:
   - `WebViewBridgeApp.swift` (Xcode created)
   - `ContentView.swift` (Xcode created)

2. **Przeciągnij** z Findera do Xcode wszystkie pliki z `iOS-App/`:
   - `WebViewBridgeApp.swift`
   - `WebViewViewModel.swift`
   - `ContentView.swift`
   - `WebViewContainer.swift`
   - `Info.plist` (zastąp istniejący)

3. Zaznacz: ✅ **Copy items if needed**

### C. Uruchom

```
Cmd + R
```

---

## Krok 3: Test komunikacji

### Z iOS → React:
Kliknij "Wyślij wiadomość do React"

### Z React → iOS:
Kliknij "Wyślij wiadomość do Swift"

---

## ✅ Gotowe!

Masz działającą komunikację Swift ↔ React!

**Logi w Xcode Console:**
```
✅ WebView Bridge App initialized
✅ WebView finished loading
📤 Sending to React: ...
📨 Received from React: ...
```

---

## 🔧 Troubleshooting

### WebView pokazuje pustą stronę?
→ Sprawdź czy React server działa: `http://localhost:3000`

### Brak wiadomości?
→ Sprawdź logi w Xcode Console (ikona 🟰)

### Build error?
→ Clean Build: Cmd + Shift + K, potem Cmd + B

---

## 📚 Co dalej?

- Przeczytaj **README.md** - pełna dokumentacja
- Modyfikuj kod - eksperymentuj!
- Dodaj własne funkcje

---

**Happy Coding!** 🚀
