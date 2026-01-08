# 📑 Dreams WebView Demo - Mapa projektu

## 📂 Struktura katalogów

```
DreamsWebViewDemo/
│
├── 📄 README.md                    # Główna dokumentacja projektu
├── 📄 QUICKSTART.md                # Szybki start (5 minut)
├── 📄 EXAMPLES.md                  # Przykłady użycia i wzorce
├── 📄 ARCHITECTURE.md              # Szczegółowa architektura systemu
│
├── 📱 iOS-App/                     # Aplikacja iOS w SwiftUI
│   ├── 📄 README.md                # Dokumentacja iOS
│   ├── 📄 XCODE_SETUP.md           # Instrukcje konfiguracji Xcode
│   ├── 📄 Package.swift            # Swift Package Manager
│   ├── 📄 Info.plist               # Konfiguracja aplikacji
│   ├── 📄 .gitignore               # Git ignore dla iOS
│   └── Sources/
│       ├── DreamsWebViewApp.swift              # Entry point + Dreams init
│       ├── ViewModels/
│       │   └── WebViewViewModel.swift          # Business logic + Dreams SDK
│       └── Views/
│           ├── ContentView.swift               # Główny widok UI
│           └── WebViewContainer.swift          # WKWebView wrapper
│
└── ⚛️ React-App/                   # Aplikacja React (WebView)
    ├── 📄 README.md                # Dokumentacja React
    ├── 📄 package.json             # npm dependencies
    ├── 📄 .gitignore               # Git ignore dla React
    ├── public/
    │   └── index.html              # HTML template
    └── src/
        ├── index.js                # Entry point
        ├── index.css               # Global styles
        ├── App.js                  # Główny komponent + komunikacja
        └── App.css                 # Component styles
```

---

## 📚 Dokumentacja - Przewodnik po plikach

### 🎯 START TUTAJ

| Plik | Przeznaczenie | Czas czytania |
|------|---------------|---------------|
| **[README.md](README.md)** | Kompletna dokumentacja projektu | 15 min |
| **[QUICKSTART.md](QUICKSTART.md)** | Uruchom aplikacje w 5 minut | 5 min |

### 📖 Szczegółowa dokumentacja

| Plik | Zawartość | Dla kogo |
|------|-----------|----------|
| **[EXAMPLES.md](EXAMPLES.md)** | Praktyczne przykłady użycia | Developerzy |
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | Diagramy architektury | Tech leads |
| **[iOS-App/README.md](iOS-App/README.md)** | Dokumentacja iOS | iOS developers |
| **[React-App/README.md](React-App/README.md)** | Dokumentacja React | Frontend developers |
| **[iOS-App/XCODE_SETUP.md](iOS-App/XCODE_SETUP.md)** | Setup Xcode | iOS beginners |

---

## 🎯 Co znajdziesz w każdym pliku?

### README.md (Główny)
- ✅ Pełna architektura rozwiązania
- ✅ Mechanizm komunikacji Swift ↔ JavaScript
- ✅ Integracja Dreams iOS SDK
- ✅ Instalacja krok po kroku
- ✅ Struktura projektów
- ✅ API komunikacji
- ✅ Troubleshooting

### QUICKSTART.md
- ⚡ Instalacja w 2 krokach
- ⚡ Test komunikacji
- ⚡ Weryfikacja Dreams SDK
- ⚡ Najczęstsze problemy
- ⚡ Co zobaczyć w logach

### EXAMPLES.md
- 📘 Wysyłanie danych użytkownika
- 📘 Aktualizacja stanu
- 📘 Obsługa błędów
- 📘 Śledzenie ekranów (Dreams SDK)
- 📘 Śledzenie akcji (Dreams SDK)
- 📘 Request-Response pattern
- 📘 Pub-Sub pattern
- 📘 Batch updates
- 📘 Scenariusze praktyczne

### ARCHITECTURE.md
- 🏗 Pełny diagram architektury
- 🏗 Przepływ wiadomości krok po kroku
- 🏗 Rejestracja message handlers
- 🏗 Format wiadomości JSON
- 🏗 Dreams SDK integration points
- 🏗 Stan aplikacji data flow
- 🏗 Bezpieczeństwo
- 🏗 Optymalizacja wydajności

### iOS-App/README.md
- 📱 Funkcjonalność aplikacji iOS
- 📱 Architektura MVVM
- 📱 Instalacja i konfiguracja
- 📱 Użytkowanie
- 📱 Dreams SDK examples
- 📱 Debugging
- 📱 API dokumentacja

### React-App/README.md
- ⚛️ Funkcjonalność aplikacji React
- ⚛️ Struktura projektu
- ⚛️ Instalacja npm
- ⚛️ API komunikacji
- ⚛️ Interfejs użytkownika
- ⚛️ Debugging
- ⚛️ Deployment

### iOS-App/XCODE_SETUP.md
- 🔧 Tworzenie projektu Xcode
- 🔧 Swift Package Manager
- 🔧 CocoaPods alternative
- 🔧 Manual integration
- 🔧 Struktura projektu
- 🔧 Weryfikacja instalacji
- 🔧 Troubleshooting
- 🔧 Deployment

---

## 🗺 Ścieżki uczenia się

### 🟢 Początkujący (Zero to Hero)

1. Przeczytaj: **[QUICKSTART.md](QUICKSTART.md)** (5 min)
2. Uruchom obie aplikacje
3. Przetestuj komunikację
4. Przeczytaj: **[README.md](README.md)** sekcja "Mechanizm komunikacji" (10 min)
5. Zobacz: **[EXAMPLES.md](EXAMPLES.md)** przykłady 1-3 (10 min)

**Czas total:** ~30 minut
**Rezultat:** Rozumiesz podstawy i masz działający system

### 🟡 Średniozaawansowany (Deep Dive)

1. Przeczytaj całe: **[README.md](README.md)** (15 min)
2. Przeczytaj: **[ARCHITECTURE.md](ARCHITECTURE.md)** (20 min)
3. Przestudiuj: **[EXAMPLES.md](EXAMPLES.md)** wszystkie przykłady (30 min)
4. Przeczytaj kod źródłowy:
   - `WebViewViewModel.swift` (15 min)
   - `WebViewContainer.swift` (15 min)
   - `App.js` (15 min)
5. Implementuj własne przykłady

**Czas total:** ~2 godziny
**Rezultat:** Głęboka znajomość architektury i wzorców

### 🔴 Zaawansowany (Master Level)

1. Wszystkie powyższe materiały
2. Przeczytaj dokumentację Dreams SDK: https://github.com/getdreams/dreams-ios-sdk
3. Przeczytaj dokumentację WKWebView: https://developer.apple.com/documentation/webkit/wkwebview
4. Implementuj zaawansowane wzorce z **[EXAMPLES.md](EXAMPLES.md)**
5. Dostosuj architekturę do swoich potrzeb
6. Dodaj własne integracje (backend, inne SDK)

**Czas total:** ~1 dzień
**Rezultat:** Expertise w iOS-React komunikacji

---

## 🎓 Materiały według roli

### 👨‍💻 iOS Developer

**Must read:**
1. [iOS-App/README.md](iOS-App/README.md)
2. [iOS-App/XCODE_SETUP.md](iOS-App/XCODE_SETUP.md)
3. [README.md](README.md) - sekcja "Swift API"
4. [EXAMPLES.md](EXAMPLES.md) - przykłady iOS

**Nice to have:**
- [ARCHITECTURE.md](ARCHITECTURE.md) - scenariusz Swift → React
- [React-App/README.md](React-App/README.md) - zrozumienie drugiej strony

### 👨‍💻 Frontend Developer (React)

**Must read:**
1. [React-App/README.md](React-App/README.md)
2. [README.md](README.md) - sekcja "JavaScript API"
3. [EXAMPLES.md](EXAMPLES.md) - przykłady React

**Nice to have:**
- [ARCHITECTURE.md](ARCHITECTURE.md) - scenariusz React → Swift
- [iOS-App/README.md](iOS-App/README.md) - zrozumienie natywnej strony

### 👨‍💼 Product Manager / Tech Lead

**Must read:**
1. [README.md](README.md) - Overview
2. [ARCHITECTURE.md](ARCHITECTURE.md) - Diagrams
3. [QUICKSTART.md](QUICKSTART.md) - Demo capabilities

**Nice to have:**
- [EXAMPLES.md](EXAMPLES.md) - Use cases

### 👨‍🎓 Student / Beginner

**Must read:**
1. [QUICKSTART.md](QUICKSTART.md)
2. [README.md](README.md)
3. [EXAMPLES.md](EXAMPLES.md) - przykłady 1-5

**Practice:**
- Uruchom aplikacje
- Przetestuj komunikację
- Zmodyfikuj przykłady
- Dodaj własne funkcje

---

## 🔍 Szukasz konkretnej informacji?

### Jak uruchomić aplikacje?
→ [QUICKSTART.md](QUICKSTART.md)

### Jak działa komunikacja Swift ↔ JavaScript?
→ [README.md](README.md) sekcja "Mechanizm komunikacji"
→ [ARCHITECTURE.md](ARCHITECTURE.md)

### Jak używać Dreams SDK?
→ [README.md](README.md) sekcja "Integracja Dreams iOS SDK"
→ [EXAMPLES.md](EXAMPLES.md) przykłady 1-5

### Jak wysłać wiadomość z React do iOS?
→ [React-App/README.md](React-App/README.md) sekcja "API Komunikacji"
→ [EXAMPLES.md](EXAMPLES.md) przykład 2

### Jak wysłać wiadomość z iOS do React?
→ [iOS-App/README.md](iOS-App/README.md) sekcja "Komunikacja Swift → React"
→ [EXAMPLES.md](EXAMPLES.md) przykład 1

### Jak obsłużyć błędy?
→ [EXAMPLES.md](EXAMPLES.md) przykład 3

### Jak śledzić zdarzenia użytkownika?
→ [EXAMPLES.md](EXAMPLES.md) przykład 2 (Dreams SDK)

### Jak stworzyć projekt w Xcode?
→ [iOS-App/XCODE_SETUP.md](iOS-App/XCODE_SETUP.md)

### Problemy z instalacją?
→ [README.md](README.md) sekcja "Rozwiązywanie problemów"
→ [QUICKSTART.md](QUICKSTART.md) sekcja "Najczęstsze problemy"

### Jak zdeployować do produkcji?
→ [React-App/README.md](React-App/README.md) sekcja "Deployment"
→ [iOS-App/XCODE_SETUP.md](iOS-App/XCODE_SETUP.md) sekcja "Deployment"

---

## 📊 Statystyki projektu

- **Pliki Swift:** 4
- **Pliki JavaScript/React:** 4
- **Pliki dokumentacji:** 7
- **Linie kodu iOS:** ~600
- **Linie kodu React:** ~200
- **Linie dokumentacji:** ~2000
- **Przykłady:** 15+

---

## 🚀 Szybkie linki

### Dokumentacja zewnętrzna
- [Dreams iOS SDK](https://github.com/getdreams/dreams-ios-sdk)
- [WKWebView Documentation](https://developer.apple.com/documentation/webkit/wkwebview)
- [React Documentation](https://react.dev)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

### Narzędzia
- [Xcode](https://developer.apple.com/xcode/)
- [Node.js](https://nodejs.org/)
- [Safari Web Inspector](https://developer.apple.com/safari/tools/)

---

## ✨ Następne kroki

Po przestudiowaniu dokumentacji:

1. ✅ Uruchom aplikacje lokalnie
2. ✅ Przetestuj komunikację
3. ✅ Zmodyfikuj przykłady
4. ✅ Dodaj własne funkcje
5. ✅ Integruj z prawdziwym backendem
6. ✅ Wdróż na produkcję

---

## 🤝 Contributing

Znalazłeś błąd? Masz sugestie? 

1. Przeczytaj dokumentację
2. Sprawdź istniejące issues
3. Utwórz nowy issue z opisem
4. Lub wyślij Pull Request

---

## 📄 Licencja

MIT License - wolne użycie do projektów komercyjnych i open source.

---

**Happy Coding!** 🎉

---

*Dokument ostatnio aktualizowany: 2025-01-08*
