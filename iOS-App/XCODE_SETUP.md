# Tworzenie projektu Xcode - Instrukcja krok po kroku

## Opcja 1: Swift Package Manager (Zalecana)

### 1. Utwórz nowy projekt w Xcode

1. Otwórz Xcode
2. File → New → Project
3. Wybierz **iOS** → **App**
4. Ustaw:
   - Product Name: `DreamsWebViewApp`
   - Team: Twój team
   - Organization Identifier: `com.yourcompany`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: None
   - Uncheck wszystkie checkboxy (Tests, Core Data, etc.)

### 2. Dodaj Dreams iOS SDK

1. File → Add Packages...
2. Wklej URL: `https://github.com/getdreams/dreams-ios-sdk`
3. Wybierz **Up to Next Major Version**: 3.0.0
4. Kliknij **Add Package**
5. Wybierz **DreamsKit** i kliknij **Add Package**

### 3. Skopiuj pliki źródłowe

Skopiuj wszystkie pliki z katalogu `Sources/` do swojego projektu Xcode:

```
DreamsWebViewApp/
├── DreamsWebViewApp.swift
├── ViewModels/
│   └── WebViewViewModel.swift
└── Views/
    ├── ContentView.swift
    └── WebViewContainer.swift
```

### 4. Zaktualizuj Info.plist

Dodaj następujące klucze do `Info.plist`:

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

### 5. Konfiguracja Build Settings

1. Wybierz target aplikacji
2. Build Settings → Deployment
3. iOS Deployment Target: **16.0** lub wyższy

### 6. Uruchom aplikację

1. Wybierz symulator lub urządzenie
2. Cmd + R

---

## Opcja 2: CocoaPods

### 1. Utwórz Podfile

```ruby
# Podfile
platform :ios, '16.0'
use_frameworks!

target 'DreamsWebViewApp' do
  # Dreams SDK
  pod 'DreamsKit', '~> 3.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    end
  end
end
```

### 2. Zainstaluj zależności

```bash
cd iOS-App
pod install
```

### 3. Otwórz workspace

```bash
open DreamsWebViewApp.xcworkspace
```

### 4. Dodaj pliki źródłowe

(Jak w opcji 1, punkt 3)

### 5. Zaktualizuj Info.plist

(Jak w opcji 1, punkt 4)

---

## Opcja 3: Manual Integration

### 1. Pobierz Dreams SDK

```bash
git clone https://github.com/getdreams/dreams-ios-sdk.git
```

### 2. Dodaj framework do projektu

1. Przeciągnij `DreamsKit.framework` do projektu Xcode
2. Wybierz **Copy items if needed**
3. Target → General → Frameworks, Libraries, and Embedded Content
4. Ustaw **Embed & Sign**

### 3. Dodaj pliki źródłowe

(Jak w opcji 1, punkt 3)

---

## Struktura projektu Xcode

Po poprawnej konfiguracji struktura powinna wyglądać tak:

```
DreamsWebViewApp/
├── DreamsWebViewApp.xcodeproj  (lub .xcworkspace dla CocoaPods)
├── DreamsWebViewApp/
│   ├── DreamsWebViewApp.swift
│   ├── ViewModels/
│   │   └── WebViewViewModel.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   └── WebViewContainer.swift
│   ├── Assets.xcassets/
│   ├── Preview Content/
│   └── Info.plist
├── Podfile (opcjonalnie dla CocoaPods)
├── Pods/ (opcjonalnie dla CocoaPods)
└── README.md
```

---

## Weryfikacja instalacji

### 1. Build projekt (Cmd + B)

Powinno zakończyć się sukcesem bez błędów.

### 2. Sprawdź logi

Po uruchomieniu aplikacji w konsoli Xcode powinien pojawić się:

```
✅ Dreams SDK initialized successfully
```

### 3. Test komunikacji

1. Uruchom React dev server (`npm start` w React-App)
2. Uruchom iOS app (Cmd + R)
3. WebView powinien załadować aplikację React
4. Sprawdź czy przyciski działają

---

## Troubleshooting

### Problem: "No such module 'DreamsKit'"

**Rozwiązanie:**
1. Upewnij się, że Dreams SDK jest dodany do Dependencies
2. File → Add Packages → sprawdź czy DreamsKit jest na liście
3. Clean Build Folder (Cmd + Shift + K)
4. Build Again (Cmd + B)

### Problem: "Cannot find type 'Dreams' in scope"

**Rozwiązanie:**
1. Dodaj import: `import DreamsKit` na górze pliku
2. Sprawdź czy target ma dodany DreamsKit w Dependencies

### Problem: Build fails z linker errors

**Rozwiązanie dla CocoaPods:**
```bash
pod deintegrate
pod install
```

**Rozwiązanie dla SPM:**
1. File → Packages → Reset Package Caches
2. Clean Build Folder
3. Build

---

## Deployment na urządzenie

### 1. Konfiguracja Signing

1. Target → Signing & Capabilities
2. Wybierz **Team**
3. Automatyczne signing (zalecane) lub Manual

### 2. Bundle Identifier

Ustaw unikalny Bundle ID:
- `com.yourcompany.DreamsWebViewApp`

### 3. Provisioning Profile

Dla manual signing:
1. Utwórz App ID w Apple Developer Portal
2. Utwórz Provisioning Profile
3. Pobierz i zainstaluj

### 4. Run na urządzeniu

1. Podłącz iPhone przez USB
2. Wybierz urządzenie w Xcode
3. Cmd + R

---

## Następne kroki

Po poprawnej instalacji:

1. Przeczytaj [README.md](README.md) - pełna dokumentacja
2. Przeczytaj [QUICKSTART.md](QUICKSTART.md) - szybki start
3. Zobacz [EXAMPLES.md](EXAMPLES.md) - przykłady użycia

Happy coding! 🚀
