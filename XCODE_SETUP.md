# 📱 Xcode Setup - Szczegółowa instrukcja

## 🎯 Cel

Utworzenie natywnego projektu iOS bez zewnętrznych zależności.

---

## ⏱️ Czas: ~5 minut

---

## Krok 1: Utwórz nowy projekt

1. **Uruchom Xcode**

2. **File → New → Project** (Cmd+Shift+N)

3. Wybierz szablon:
   - **iOS** (górna zakładka)
   - **App** (pierwszy kafelek)
   - **Next**

4. Wypełnij formularz:
   ```
   Product Name: WebViewBridge
   Team: None (lub wybierz)
   Organization Identifier: com.yourcompany
   Interface: SwiftUI  ⭐️ WAŻNE!
   Language: Swift
   Storage: None
   
   ❌ Use Core Data
   ❌ Include Tests
   ```

5. **Next** → Zapisz na **Desktop** → **Create**

---

## Krok 2: Usuń domyślne pliki

W **Project Navigator** (lewa strona) usuń:

1. Kliknij prawym na `WebViewBridgeApp.swift`
   → **Delete** → **Move to Trash**

2. Kliknij prawym na `ContentView.swift`
   → **Delete** → **Move to Trash**

Pozostaw:
- `Assets.xcassets`
- `Preview Content`

---

## Krok 3: Dodaj nasze pliki

**Z Findera:**

1. Otwórz folder `WebViewBridge-Native/iOS-App/`

2. **Przeciągnij do Xcode** (Project Navigator):
   - `WebViewBridgeApp.swift`
   - `WebViewViewModel.swift`
   - `ContentView.swift`
   - `WebViewContainer.swift`

**W oknie dialogowym:**
- ✅ **Copy items if needed**
- ✅ **Create groups**
- ✅ Target: **WebViewBridge**
- **Finish**

---

## Krok 4: Zaktualizuj Info.plist

### Opcja A: Zastąp plik (łatwiejsze)

1. Usuń istniejący `Info.plist`:
   - Kliknij prawym → Delete → Move to Trash

2. Przeciągnij nasz `Info.plist` z `iOS-App/`
   - ✅ Copy items if needed

### Opcja B: Edytuj ręcznie (jeśli wolisz)

1. Kliknij na projekt (niebieski plik)
2. Target: **WebViewBridge**
3. Tab: **Info**
4. Dodaj:
   ```
   App Transport Security Settings (Dictionary)
       → Allow Arbitrary Loads in Web Content: YES
       → NSAllowsLocalNetworking: YES
   ```

---

## Krok 5: Weryfikacja struktury

**Project Navigator powinien wyglądać:**

```
WebViewBridge (niebieski folder)
├── WebViewBridgeApp.swift
├── WebViewViewModel.swift
├── ContentView.swift
├── WebViewContainer.swift
├── Assets.xcassets
├── Preview Content
└── Info.plist
```

Jeśli masz inne pliki - usuń je.

---

## Krok 6: Build

```
Product → Build (Cmd+B)
```

Powinno zbudować się **bez błędów**.

---

## Krok 7: Uruchom

```
Product → Run (Cmd+R)
```

**Wybierz symulator:** iPhone 15 Pro (lub inny)

---

## ✅ Weryfikacja

### W Xcode Console (dolny panel) powinieneś zobaczyć:

```
✅ WebView Bridge App initialized
📊 [HH:MM:SS] Event 'app_initialized': ...
```

### W aplikacji zobaczysz:

- Header: "Native WebView Bridge"
- WebView (z React app jeśli server działa)
- Przyciski: "Wyślij wiadomość", "Start Sesji", "Reset"
- Statystyki komunikacji

---

## 🐛 Troubleshooting

### Błąd: "Cannot find 'WKWebView' in scope"

**Rozwiązanie:**
- Sprawdź czy na górze `WebViewContainer.swift` jest:
  ```swift
  import WebKit
  ```

### WebView jest pusty

**Rozwiązanie:**
1. Sprawdź czy React server działa: `http://localhost:3000`
2. Sprawdź logi w Console

### Build fails

**Rozwiązanie:**
1. Clean Build Folder: **Product → Clean Build Folder** (Cmd+Shift+K)
2. Build Again: **Product → Build** (Cmd+B)

---

## 📱 Testowanie na prawdziwym urządzeniu

### 1. Podłącz iPhone

- Kablem USB do Mac

### 2. Wybierz urządzenie

- Górny toolbar → wybierz swój iPhone

### 3. Trust Certificate (jeśli pierwszy raz)

- iPhone: Settings → General → Device Management
- Trust developer certificate

### 4. Zmień URL na IP (nie localhost)

W `ContentView.swift`:
```swift
private let reactAppURL = URL(string: "http://192.168.1.XXX:3000")!
```

Znajdź IP Maca:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

### 5. Run

```
Cmd + R
```

---

## 🎯 Co dalej?

✅ **Działa?** Świetnie! Przeczytaj README.md
✅ **Modyfikuj kod** - eksperymentuj
✅ **Dodaj funkcje** - zbuduj swoją aplikację

---

## 📊 Checklist

Przed uruchomieniem sprawdź:

- [ ] Utworzyłeś projekt przez File → New → **Project** (nie File)
- [ ] Wybrałeś **iOS → App**
- [ ] Ustawiłeś **Interface: SwiftUI**
- [ ] Dodałeś wszystkie 4 pliki Swift
- [ ] Zastąpiłeś Info.plist
- [ ] Build się udał bez błędów (Cmd+B)
- [ ] React server działa (`npm start`)

---

**Wszystko gotowe!** 🚀

Teraz możesz eksperymentować z kodem i budować swoją aplikację!
