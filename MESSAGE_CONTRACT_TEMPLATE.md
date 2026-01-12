# 📜 Example Message Contract - iOS ↔ React

## Contract Information

```yaml
contract_name: "iOS-React Hybrid Communication Protocol"
version: "1.0.0"
effective_date: "2024-01-15"
owners:
  ios_team: "iOS Development Team"
  react_team: "React Development Team"
status: "active"
```

---

## Message Types

### 1. Session Management

#### 1.1 session_started (iOS → React)

**Description:** Sent by iOS when user successfully authenticates and session is established.

**Direction:** iOS → React

**Payload Schema:**
```json
{
  "type": "session_started",
  "version": "1.0.0",
  "payload": {
    "userId": "string (required)",
    "sessionToken": "string (required, encrypted)",
    "userEmail": "string (optional)",
    "userPermissions": ["string"] (required),
    "timestamp": "ISO8601 (required)",
    "locale": "string (optional, default: 'en')",
    "deviceInfo": {
      "platform": "ios",
      "osVersion": "string",
      "appVersion": "string"
    }
  }
}
```

**Example:**
```json
{
  "type": "session_started",
  "version": "1.0.0",
  "payload": {
    "userId": "user_abc12345",
    "sessionToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "userEmail": "john@example.com",
    "userPermissions": ["read_profile", "write_messages", "view_transactions"],
    "timestamp": "2024-01-15T10:30:00Z",
    "locale": "en_US",
    "deviceInfo": {
      "platform": "ios",
      "osVersion": "17.2",
      "appVersion": "2.5.1"
    }
  }
}
```

**React Response:** session_acknowledged

---

#### 1.2 session_acknowledged (React → iOS)

**Description:** React confirms it received session start and is ready for communication.

**Direction:** React → iOS

**Payload Schema:**
```json
{
  "type": "session_acknowledged",
  "version": "1.0.0",
  "payload": {
    "status": "ready" | "error",
    "timestamp": "ISO8601 (required)",
    "reactVersion": "string (required)"
  }
}
```

**Example:**
```json
{
  "type": "session_acknowledged",
  "version": "1.0.0",
  "payload": {
    "status": "ready",
    "timestamp": "2024-01-15T10:30:01Z",
    "reactVersion": "18.2.0"
  }
}
```

---

#### 1.3 session_ended (iOS → React)

**Description:** iOS notifies React that session has ended (logout, timeout, or reset).

**Direction:** iOS → React

**Payload Schema:**
```json
{
  "type": "session_ended",
  "version": "1.0.0",
  "payload": {
    "reason": "user_logout" | "timeout" | "user_reset" | "force_logout",
    "timestamp": "ISO8601 (required)",
    "message": "string (optional)"
  }
}
```

**Example:**
```json
{
  "type": "session_ended",
  "version": "1.0.0",
  "payload": {
    "reason": "user_logout",
    "timestamp": "2024-01-15T11:45:00Z",
    "message": "User clicked logout button"
  }
}
```

**React Action:** Clear all user data, reset to initial state

---

### 2. Navigation

#### 2.1 navigate_to_screen (iOS → React)

**Description:** iOS instructs React to navigate to specific screen/route.

**Direction:** iOS → React

**Payload Schema:**
```json
{
  "type": "navigate_to_screen",
  "version": "1.0.0",
  "payload": {
    "screen": "string (required)",
    "params": "object (optional)",
    "timestamp": "ISO8601 (required)",
    "animation": "push" | "modal" | "none" (optional, default: "push")
  }
}
```

**Example:**
```json
{
  "type": "navigate_to_screen",
  "version": "1.0.0",
  "payload": {
    "screen": "profile",
    "params": {
      "userId": "user_abc12345",
      "tab": "settings"
    },
    "timestamp": "2024-01-15T10:35:00Z",
    "animation": "push"
  }
}
```

**React Response:** navigation_complete

---

#### 2.2 navigation_complete (React → iOS)

**Description:** React confirms navigation completed successfully.

**Direction:** React → iOS

**Payload Schema:**
```json
{
  "type": "navigation_complete",
  "version": "1.0.0",
  "payload": {
    "screen": "string (required)",
    "success": "boolean (required)",
    "error": "string (optional)",
    "timestamp": "ISO8601 (required)"
  }
}
```

**Example:**
```json
{
  "type": "navigation_complete",
  "version": "1.0.0",
  "payload": {
    "screen": "profile",
    "success": true,
    "timestamp": "2024-01-15T10:35:01Z"
  }
}
```

---

#### 2.3 request_native_screen (React → iOS)

**Description:** React requests iOS to show native screen.

**Direction:** React → iOS

**Payload Schema:**
```json
{
  "type": "request_native_screen",
  "version": "1.0.0",
  "payload": {
    "screen": "string (required)",
    "params": "object (optional)",
    "timestamp": "ISO8601 (required)",
    "reason": "string (optional)"
  }
}
```

**Example:**
```json
{
  "type": "request_native_screen",
  "version": "1.0.0",
  "payload": {
    "screen": "camera",
    "params": {
      "mode": "photo",
      "allowsEditing": true
    },
    "timestamp": "2024-01-15T10:40:00Z",
    "reason": "User wants to update profile photo"
  }
}
```

**iOS Response:** native_screen_result

---

### 3. Native Features

#### 3.1 request_camera (React → iOS)

**Description:** React requests camera access.

**Direction:** React → iOS

**Payload Schema:**
```json
{
  "type": "request_camera",
  "version": "1.0.0",
  "payload": {
    "mode": "photo" | "video",
    "allowsEditing": "boolean (optional, default: false)",
    "timestamp": "ISO8601 (required)"
  }
}
```

**Example:**
```json
{
  "type": "request_camera",
  "version": "1.0.0",
  "payload": {
    "mode": "photo",
    "allowsEditing": true,
    "timestamp": "2024-01-15T10:45:00Z"
  }
}
```

**iOS Response:** camera_result

---

#### 3.2 camera_result (iOS → React)

**Description:** iOS returns camera result (photo/video or error).

**Direction:** iOS → React

**Payload Schema:**
```json
{
  "type": "camera_result",
  "version": "1.0.0",
  "payload": {
    "success": "boolean (required)",
    "imageData": "string (base64, optional)",
    "videoUrl": "string (optional)",
    "error": "string (optional)",
    "timestamp": "ISO8601 (required)"
  }
}
```

**Example - Success:**
```json
{
  "type": "camera_result",
  "version": "1.0.0",
  "payload": {
    "success": true,
    "imageData": "data:image/jpeg;base64,/9j/4AAQSkZJRg...",
    "timestamp": "2024-01-15T10:45:15Z"
  }
}
```

**Example - Error:**
```json
{
  "type": "camera_result",
  "version": "1.0.0",
  "payload": {
    "success": false,
    "error": "camera_permission_denied",
    "timestamp": "2024-01-15T10:45:05Z"
  }
}
```

---

#### 3.3 request_location (React → iOS)

**Description:** React requests current location.

**Direction:** React → iOS

**Payload Schema:**
```json
{
  "type": "request_location",
  "version": "1.0.0",
  "payload": {
    "accuracy": "high" | "balanced" | "low" (optional, default: "balanced"),
    "timestamp": "ISO8601 (required)"
  }
}
```

**iOS Response:** location_result

---

### 4. User Actions

#### 4.1 user_action (React → iOS)

**Description:** React notifies iOS of user action that may require native handling.

**Direction:** React → iOS

**Payload Schema:**
```json
{
  "type": "user_action",
  "version": "1.0.0",
  "payload": {
    "action": "string (required)",
    "data": "object (optional)",
    "timestamp": "ISO8601 (required)"
  }
}
```

**Example:**
```json
{
  "type": "user_action",
  "version": "1.0.0",
  "payload": {
    "action": "share_content",
    "data": {
      "url": "https://example.com/article/123",
      "title": "Interesting Article",
      "description": "Check this out!"
    },
    "timestamp": "2024-01-15T11:00:00Z"
  }
}
```

---

### 5. Data Exchange

#### 5.1 request_data (React → iOS)

**Description:** React requests data from iOS (e.g., user profile, settings).

**Direction:** React → iOS

**Payload Schema:**
```json
{
  "type": "request_data",
  "version": "1.0.0",
  "payload": {
    "dataType": "string (required)",
    "params": "object (optional)",
    "timestamp": "ISO8601 (required)"
  }
}
```

**Example:**
```json
{
  "type": "request_data",
  "version": "1.0.0",
  "payload": {
    "dataType": "user_profile",
    "params": {
      "includeSettings": true
    },
    "timestamp": "2024-01-15T11:10:00Z"
  }
}
```

**iOS Response:** data_response

---

#### 5.2 data_response (iOS → React)

**Description:** iOS sends requested data to React.

**Direction:** iOS → React

**Payload Schema:**
```json
{
  "type": "data_response",
  "version": "1.0.0",
  "payload": {
    "dataType": "string (required)",
    "success": "boolean (required)",
    "data": "object (optional)",
    "error": "string (optional)",
    "timestamp": "ISO8601 (required)"
  }
}
```

**Example:**
```json
{
  "type": "data_response",
  "version": "1.0.0",
  "payload": {
    "dataType": "user_profile",
    "success": true,
    "data": {
      "userId": "user_abc12345",
      "name": "John Doe",
      "email": "john@example.com",
      "avatarUrl": "https://cdn.example.com/avatars/john.jpg",
      "settings": {
        "notifications": true,
        "darkMode": false
      }
    },
    "timestamp": "2024-01-15T11:10:01Z"
  }
}
```

---

### 6. Errors & Logging

#### 6.1 error_occurred (React → iOS or iOS → React)

**Description:** Report error to other party for logging/handling.

**Direction:** Bidirectional

**Payload Schema:**
```json
{
  "type": "error_occurred",
  "version": "1.0.0",
  "payload": {
    "errorCode": "string (required)",
    "errorMessage": "string (required)",
    "severity": "low" | "medium" | "high" | "critical",
    "context": "object (optional)",
    "timestamp": "ISO8601 (required)"
  }
}
```

**Example:**
```json
{
  "type": "error_occurred",
  "version": "1.0.0",
  "payload": {
    "errorCode": "NETWORK_TIMEOUT",
    "errorMessage": "Failed to fetch user data: network timeout after 30s",
    "severity": "medium",
    "context": {
      "endpoint": "/api/user/profile",
      "attempt": 3,
      "lastError": "timeout"
    },
    "timestamp": "2024-01-15T11:15:00Z"
  }
}
```

---

## Security Model

### Message Signing

**All messages MUST include signature:**

```json
{
  "type": "...",
  "version": "1.0.0",
  "payload": {...},
  "security": {
    "signature": "HMAC-SHA256 hash",
    "timestamp": "ISO8601",
    "nonce": "UUID"
  }
}
```

**Signature Generation (iOS):**
```swift
let messageString = JSONSerialization.string(from: message)
let signature = HMAC.hash(messageString + timestamp + nonce, key: sharedSecret)
```

**Signature Validation (React):**
```javascript
const expectedSignature = HMAC.hash(
  messageString + timestamp + nonce, 
  sharedSecret
);
return signature === expectedSignature;
```

### Token Management

**iOS responsibilities:**
- Generate and encrypt session tokens
- Refresh tokens before expiry
- Revoke tokens on logout

**React responsibilities:**
- Store token in memory only (never localStorage)
- Include token in requests to backend
- Request new token from iOS if expired

---

## Error Codes

| Code | Description | Severity | Handling |
|------|-------------|----------|----------|
| AUTH_EXPIRED | Session token expired | high | iOS: refresh token, React: show login |
| PERMISSION_DENIED | User denied permission | medium | Show explanation, retry |
| NETWORK_ERROR | Network unavailable | low | Retry with backoff |
| INVALID_MESSAGE | Message doesn't match schema | critical | Log and report bug |
| CAMERA_UNAVAILABLE | Camera hardware issue | medium | Show error message |
| LOCATION_DISABLED | Location services off | low | Prompt user to enable |

---

## Versioning

### Version Format: MAJOR.MINOR.PATCH

**MAJOR:** Breaking changes (incompatible messages)
**MINOR:** New optional fields (backward compatible)
**PATCH:** Documentation updates, bug fixes

### Compatibility Matrix

| iOS Contract | React Contract | Compatible? |
|--------------|----------------|-------------|
| 1.0.0 | 1.0.0 | ✅ Yes |
| 1.1.0 | 1.0.0 | ✅ Yes (backward compatible) |
| 2.0.0 | 1.x.x | ❌ No (breaking changes) |
| 1.0.0 | 1.1.0 | ✅ Yes (React added optional fields) |

### Version Negotiation

**On bridge initialization:**
```json
iOS sends: {
  "type": "bridge_init",
  "ios_contract_version": "1.1.0",
  "supported_versions": ["1.0.0", "1.1.0"]
}

React responds: {
  "type": "bridge_ready",
  "react_contract_version": "1.0.0",
  "compatible": true
}
```

---

## Testing

### Contract Validation Tests

```typescript
describe('Contract Validation', () => {
  it('should validate session_started message', () => {
    const message = {
      type: 'session_started',
      version: '1.0.0',
      payload: {
        userId: 'user_123',
        sessionToken: 'token',
        userPermissions: ['read'],
        timestamp: new Date().toISOString(),
        deviceInfo: {
          platform: 'ios',
          osVersion: '17.0',
          appVersion: '1.0.0'
        }
      }
    };
    
    expect(validateContract(message)).toBe(true);
  });
});
```

---

## Change Log

### Version 1.0.0 (2024-01-15)
- Initial contract definition
- Session management messages
- Navigation messages
- Native feature requests (camera, location)
- Data exchange protocol
- Error handling

---

## Approval

**iOS Team Lead:** _________________ Date: _______

**React Team Lead:** _________________ Date: _______

**Security Review:** _________________ Date: _______

---

**This contract is the source of truth for all iOS-React communication.**
