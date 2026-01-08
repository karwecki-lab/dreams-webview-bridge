# 📘 Przykłady użycia - Dreams WebView Demo

Ten dokument zawiera praktyczne przykłady użycia komunikacji WebView i Dreams SDK.

---

## 📨 Przykłady komunikacji Swift ↔ React

### Przykład 1: Wysyłanie danych użytkownika

**iOS (Swift):**
```swift
// WebViewViewModel.swift
func sendUserData(user: User) {
    let message: [String: Any] = [
        "type": "user_data",
        "payload": [
            "userId": user.id,
            "name": user.name,
            "email": user.email,
            "isAuthenticated": true
        ]
    ]
    
    coordinator?.sendMessageToJavaScript(message)
    
    logDreamsEvent(
        type: "user_data_sent",
        data: ["userId": user.id]
    )
}
```

**React (JavaScript):**
```javascript
useEffect(() => {
  window.receiveMessageFromNative = (message) => {
    if (message.type === 'user_data') {
      const { userId, name, email, isAuthenticated } = message.payload;
      setUser({ userId, name, email });
      setIsAuthenticated(isAuthenticated);
      console.log('User logged in:', name);
    }
  };
}, []);
```

### Przykład 2: Aktualizacja stanu z React do iOS

**React (JavaScript):**
```javascript
const updateProgress = (progress) => {
  const message = {
    type: 'progress_update',
    payload: {
      progress: progress,
      stage: 'processing',
      timestamp: new Date().toISOString()
    }
  };
  
  window.webkit.messageHandlers.nativeApp.postMessage(message);
};

// Użycie
updateProgress(75); // 75% completed
```

**iOS (Swift):**
```swift
// WebViewViewModel.swift
func handleMessageFromJavaScript(_ message: [String: Any]) {
    guard let type = message["type"] as? String else { return }
    
    if type == "progress_update",
       let payload = message["payload"] as? [String: Any],
       let progress = payload["progress"] as? Int {
        
        updateProgress(progress: progress)
        
        logDreamsEvent(
            type: "progress_updated",
            data: ["progress": progress]
        )
    }
}

func updateProgress(progress: Int) {
    // Aktualizuj UI lub business logic
    print("Progress: \(progress)%")
}
```

### Przykład 3: Obsługa błędów

**React (JavaScript):**
```javascript
const handleError = (error) => {
  const message = {
    type: 'error_occurred',
    payload: {
      errorCode: error.code,
      errorMessage: error.message,
      stackTrace: error.stack,
      timestamp: new Date().toISOString()
    }
  };
  
  window.webkit.messageHandlers.nativeApp.postMessage(message);
};

// Użycie w try-catch
try {
  // Ryzykowna operacja
} catch (error) {
  handleError(error);
}
```

**iOS (Swift):**
```swift
// WebViewViewModel.swift
func handleMessageFromJavaScript(_ message: [String: Any]) {
    if let type = message["type"] as? String,
       type == "error_occurred",
       let payload = message["payload"] as? [String: Any] {
        
        let errorCode = payload["errorCode"] as? String ?? "unknown"
        let errorMessage = payload["errorMessage"] as? String ?? "No message"
        
        // Loguj błąd do Dreams SDK
        logDreamsEvent(
            type: "webview_error",
            data: [
                "errorCode": errorCode,
                "errorMessage": errorMessage,
                "source": "react"
            ]
        )
        
        // Pokaż alert użytkownikowi
        showErrorAlert(message: errorMessage)
    }
}
```

---

## 🌟 Przykłady integracji Dreams SDK

### Przykład 1: Śledzenie ekranów (Screen Views)

**iOS (Swift):**
```swift
// WebViewViewModel.swift
func trackScreenView(screenName: String, properties: [String: Any] = [:]) {
    var eventData = properties
    eventData["screen_name"] = screenName
    eventData["timestamp"] = Date().ISO8601Format()
    
    logDreamsEvent(
        type: "screen_view",
        data: eventData
    )
}

// Użycie
trackScreenView(
    screenName: "home",
    properties: [
        "user_segment": "premium",
        "previous_screen": "login"
    ]
)
```

### Przykład 2: Śledzenie akcji użytkownika

**iOS (Swift):**
```swift
// WebViewViewModel.swift
func trackUserAction(
    action: String,
    category: String,
    label: String? = nil,
    value: Int? = nil
) {
    var eventData: [String: Any] = [
        "action": action,
        "category": category,
        "timestamp": Date().ISO8601Format()
    ]
    
    if let label = label {
        eventData["label"] = label
    }
    
    if let value = value {
        eventData["value"] = value
    }
    
    logDreamsEvent(
        type: "user_action",
        data: eventData
    )
}

// Użycie
trackUserAction(
    action: "button_click",
    category: "navigation",
    label: "home_button",
    value: 1
)
```

### Przykład 3: Śledzenie konwersji

**iOS (Swift):**
```swift
// WebViewViewModel.swift
func trackConversion(
    conversionType: String,
    value: Double,
    currency: String = "USD"
) {
    logDreamsEvent(
        type: "conversion",
        data: [
            "conversion_type": conversionType,
            "value": value,
            "currency": currency,
            "timestamp": Date().ISO8601Format()
        ]
    )
}

// Użycie
trackConversion(
    conversionType: "purchase",
    value: 99.99,
    currency: "PLN"
)
```

### Przykład 4: Niestandardowe atrybuty użytkownika

**iOS (Swift):**
```swift
// WebViewViewModel.swift
func updateUserAttributes(_ attributes: [String: Any]) {
    Dreams.shared.setUserAttributes(attributes)
    
    logDreamsEvent(
        type: "user_attributes_updated",
        data: attributes
    )
}

// Użycie
updateUserAttributes([
    "subscription_tier": "premium",
    "registration_date": "2024-01-15",
    "preferred_language": "pl",
    "push_notifications_enabled": true
])
```

### Przykład 5: Śledzenie czasu spędzonego

**iOS (Swift):**
```swift
// WebViewViewModel.swift
class SessionTimer {
    private var startTime: Date?
    private let viewModel: WebViewViewModel
    
    init(viewModel: WebViewViewModel) {
        self.viewModel = viewModel
    }
    
    func startSession() {
        startTime = Date()
        viewModel.logDreamsEvent(
            type: "session_started",
            data: ["timestamp": Date().ISO8601Format()]
        )
    }
    
    func endSession() {
        guard let start = startTime else { return }
        
        let duration = Date().timeIntervalSince(start)
        
        viewModel.logDreamsEvent(
            type: "session_ended",
            data: [
                "duration_seconds": Int(duration),
                "timestamp": Date().ISO8601Format()
            ]
        )
        
        startTime = nil
    }
}

// Użycie
let sessionTimer = SessionTimer(viewModel: viewModel)
sessionTimer.startSession()
// ... aplikacja działa
sessionTimer.endSession()
```

---

## 🔄 Zaawansowane wzorce komunikacji

### Wzorzec 1: Request-Response

**React → iOS (Request):**
```javascript
const requestData = async () => {
  const requestId = Date.now().toString();
  
  const message = {
    type: 'data_request',
    payload: {
      requestId: requestId,
      dataType: 'user_profile'
    }
  };
  
  // Wyślij request
  window.webkit.messageHandlers.nativeApp.postMessage(message);
  
  // Czekaj na response (w prawdziwej implementacji użyj Promise)
  return new Promise((resolve) => {
    const originalHandler = window.receiveMessageFromNative;
    
    window.receiveMessageFromNative = (msg) => {
      if (msg.type === 'data_response' && msg.payload.requestId === requestId) {
        resolve(msg.payload.data);
        window.receiveMessageFromNative = originalHandler;
      } else if (originalHandler) {
        originalHandler(msg);
      }
    };
  });
};

// Użycie
const userData = await requestData();
```

**iOS → React (Response):**
```swift
// WebViewViewModel.swift
func handleMessageFromJavaScript(_ message: [String: Any]) {
    if let type = message["type"] as? String,
       type == "data_request",
       let payload = message["payload"] as? [String: Any],
       let requestId = payload["requestId"] as? String {
        
        // Pobierz dane
        let userData = getUserProfile()
        
        // Wyślij response
        let response: [String: Any] = [
            "type": "data_response",
            "payload": [
                "requestId": requestId,
                "data": userData
            ]
        ]
        
        coordinator?.sendMessageToJavaScript(response)
    }
}
```

### Wzorzec 2: Pub-Sub (Obserwowanie zmian)

**iOS (Publisher):**
```swift
// WebViewViewModel.swift
import Combine

class WebViewViewModel: ObservableObject {
    @Published var batteryLevel: Int = 100
    
    private var cancellables = Set<AnyCancellable>()
    
    func setupBatteryObserver() {
        $batteryLevel
            .dropFirst() // Skip initial value
            .sink { [weak self] level in
                self?.notifyReactAboutBatteryChange(level: level)
            }
            .store(in: &cancellables)
    }
    
    func notifyReactAboutBatteryChange(level: Int) {
        let message: [String: Any] = [
            "type": "battery_changed",
            "payload": ["level": level]
        ]
        
        coordinator?.sendMessageToJavaScript(message)
    }
}
```

**React (Subscriber):**
```javascript
useEffect(() => {
  const originalHandler = window.receiveMessageFromNative;
  
  window.receiveMessageFromNative = (message) => {
    if (message.type === 'battery_changed') {
      setBatteryLevel(message.payload.level);
      
      if (message.payload.level < 20) {
        showLowBatteryWarning();
      }
    }
    
    // Przekaż dalej do innych handlerów
    if (originalHandler) {
      originalHandler(message);
    }
  };
  
  return () => {
    window.receiveMessageFromNative = originalHandler;
  };
}, []);
```

### Wzorzec 3: Batch Updates (Optymalizacja)

**React (Grupowanie wiadomości):**
```javascript
class MessageQueue {
  constructor() {
    this.queue = [];
    this.flushInterval = 1000; // 1 sekunda
    this.startFlushing();
  }
  
  enqueue(message) {
    this.queue.push({
      ...message,
      queuedAt: Date.now()
    });
  }
  
  startFlushing() {
    setInterval(() => {
      if (this.queue.length > 0) {
        this.flush();
      }
    }, this.flushInterval);
  }
  
  flush() {
    if (this.queue.length === 0) return;
    
    const batch = {
      type: 'batch_update',
      payload: {
        messages: this.queue,
        count: this.queue.length
      }
    };
    
    window.webkit.messageHandlers.nativeApp.postMessage(batch);
    this.queue = [];
  }
}

// Użycie
const queue = new MessageQueue();
queue.enqueue({ type: 'event', data: {...} });
queue.enqueue({ type: 'metric', data: {...} });
// Automatycznie wysyłane co sekundę
```

**iOS (Przetwarzanie batch'y):**
```swift
// WebViewViewModel.swift
func handleMessageFromJavaScript(_ message: [String: Any]) {
    if let type = message["type"] as? String,
       type == "batch_update",
       let payload = message["payload"] as? [String: Any],
       let messages = payload["messages"] as? [[String: Any]] {
        
        // Przetwórz wszystkie wiadomości
        messages.forEach { msg in
            processIndividualMessage(msg)
        }
        
        logDreamsEvent(
            type: "batch_processed",
            data: ["count": messages.count]
        )
    }
}
```

---

## 🎯 Praktyczne scenariusze

### Scenariusz 1: Uwierzytelnianie użytkownika

**Przepływ:**
1. React pokazuje formularz logowania
2. Użytkownik wprowadza dane
3. React wysyła dane do iOS
4. iOS uwierzytelnia przez Dreams SDK
5. iOS wysyła token do React
6. React zapisuje token i aktualizuje UI

**Implementacja:**

```javascript
// React
const login = async (email, password) => {
  const message = {
    type: 'login_request',
    payload: { email, password }
  };
  
  window.webkit.messageHandlers.nativeApp.postMessage(message);
};
```

```swift
// iOS
func handleMessageFromJavaScript(_ message: [String: Any]) {
    if message["type"] as? String == "login_request",
       let payload = message["payload"] as? [String: Any],
       let email = payload["email"] as? String,
       let password = payload["password"] as? String {
        
        // Uwierzytelnij
        authenticateUser(email: email, password: password) { result in
            switch result {
            case .success(let token):
                self.sendLoginSuccess(token: token)
            case .failure(let error):
                self.sendLoginError(error: error)
            }
        }
    }
}
```

### Scenariusz 2: Przesyłanie plików

```javascript
// React - konwersja pliku do base64
const uploadFile = async (file) => {
  const base64 = await fileToBase64(file);
  
  const message = {
    type: 'file_upload',
    payload: {
      fileName: file.name,
      fileType: file.type,
      fileSize: file.size,
      fileData: base64
    }
  };
  
  window.webkit.messageHandlers.nativeApp.postMessage(message);
};
```

```swift
// iOS - przetwarzanie pliku
func handleFileUpload(_ payload: [String: Any]) {
    guard let base64String = payload["fileData"] as? String,
          let fileName = payload["fileName"] as? String,
          let data = Data(base64Encoded: base64String) else {
        return
    }
    
    // Zapisz plik
    saveFile(data: data, fileName: fileName)
    
    logDreamsEvent(
        type: "file_uploaded",
        data: [
            "fileName": fileName,
            "fileSize": data.count
        ]
    )
}
```

---

## 💾 Persystencja danych

### Przykład: Zapisywanie preferencji użytkownika

**React → iOS:**
```javascript
const savePreferences = (preferences) => {
  const message = {
    type: 'save_preferences',
    payload: preferences
  };
  
  window.webkit.messageHandlers.nativeApp.postMessage(message);
};
```

**iOS (UserDefaults):**
```swift
func savePreferences(_ preferences: [String: Any]) {
    UserDefaults.standard.set(preferences, forKey: "userPreferences")
    
    logDreamsEvent(
        type: "preferences_saved",
        data: preferences
    )
}
```

---

## 📊 Monitorowanie wydajności

```swift
// WebViewViewModel.swift
class PerformanceMonitor {
    func measureWebViewLoadTime() {
        let startTime = Date()
        
        // Po załadowaniu
        let loadTime = Date().timeIntervalSince(startTime)
        
        logDreamsEvent(
            type: "webview_performance",
            data: [
                "load_time_ms": Int(loadTime * 1000),
                "timestamp": Date().ISO8601Format()
            ]
        )
    }
}
```

---

To tylko przykłady - możliwości są nieograniczone! Dostosuj wzorce do swoich potrzeb.
