import React, { useState, useEffect, useCallback } from 'react';
import './App.css';

function App() {
  // Session state
  const [isSessionActive, setIsSessionActive] = useState(false);
  const [userId, setUserId] = useState(null);
  
  // Messages state
  const [messagesFromNative, setMessagesFromNative] = useState([]);
  const [messagesReceivedCount, setMessagesReceivedCount] = useState(0);
  const [messagesSentCount, setMessagesSentCount] = useState(0);
  
  // Environment
  const [isWebViewEnvironment, setIsWebViewEnvironment] = useState(false);

  // Sprawdź czy aplikacja działa w WebView
  useEffect(() => {
    const inWebView = window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp;
    setIsWebViewEnvironment(!!inWebView);
    
    if (inWebView) {
      console.log('✅ Running in WKWebView environment');
    } else {
      console.log('⚠️ Not running in WKWebView');
    }
  }, []);

  // Funkcja odbierająca wiadomości z aplikacji natywnej (Swift)
  const receiveMessageFromNative = useCallback((message) => {
    console.log('📨 Received from Native:', message);
    
    // Obsługa różnych typów wiadomości
    if (message.type === 'session_started') {
      // START SESJI
      const newUserId = message.payload?.userId || 'unknown';
      setIsSessionActive(true);
      setUserId(newUserId);
      setMessagesReceivedCount(prev => prev + 1);
      console.log('🟢 Session started:', newUserId);
      
      // Dodaj wiadomość do historii
      const timestamp = new Date().toLocaleTimeString('pl-PL');
      setMessagesFromNative(prev => [{
        ...message,
        receivedAt: timestamp
      }, ...prev]);
      
    } else if (message.type === 'session_ended') {
      // KONIEC SESJI (RESET)
      console.log('🔴 Session ended - clearing state');
      setIsSessionActive(false);
      setUserId(null);
      setMessagesFromNative([]);
      setMessagesReceivedCount(0);
      setMessagesSentCount(0);
      
    } else {
      // NORMALNA WIADOMOŚĆ
      if (!isSessionActive) {
        console.warn('⚠️ Message rejected - no active session');
        return;
      }
      
      const timestamp = new Date().toLocaleTimeString('pl-PL');
      const messageWithTimestamp = {
        ...message,
        receivedAt: timestamp
      };
      
      setMessagesFromNative(prev => [messageWithTimestamp, ...prev]);
      setMessagesReceivedCount(prev => prev + 1);
    }
  }, [isSessionActive]);

  // Zarejestruj globalną funkcję do odbierania wiadomości
  useEffect(() => {
    window.receiveMessageFromNative = receiveMessageFromNative;
    
    return () => {
      delete window.receiveMessageFromNative;
    };
  }, [receiveMessageFromNative]);

  // Funkcja wysyłająca wiadomość do aplikacji natywnej (Swift)
  const sendMessageToNative = () => {
    if (!isWebViewEnvironment) {
      alert('Ta funkcja działa tylko w WKWebView!');
      return;
    }

    if (!isSessionActive) {
      alert('⚠️ Sesja nie jest aktywna!\nKliknij "Start Sesji" w iOS aby nawiązać połączenie.');
      return;
    }

    const message = {
      type: 'greeting',
      payload: {
        text: 'Cześć z React! 🎉',
        count: messagesSentCount + 1,
        timestamp: new Date().toISOString(),
        source: 'React-JavaScript'
      }
    };

    try {
      window.webkit.messageHandlers.nativeApp.postMessage(message);
      console.log('📤 Sent to Native:', message);
      setMessagesSentCount(prev => prev + 1);
    } catch (error) {
      console.error('❌ Error sending message:', error);
      alert('Błąd wysyłania wiadomości: ' + error.message);
    }
  };

  // Wysłanie akcji użytkownika
  const sendActionMessage = (actionType) => {
    if (!isSessionActive) {
      alert('⚠️ Sesja nie jest aktywna!');
      return;
    }

    const message = {
      type: 'user_action',
      payload: {
        action: actionType,
        timestamp: new Date().toISOString(),
        userAgent: navigator.userAgent
      }
    };

    try {
      window.webkit.messageHandlers.nativeApp.postMessage(message);
      console.log('📤 Sent action to Native:', message);
      setMessagesSentCount(prev => prev + 1);
    } catch (error) {
      console.error('❌ Error sending action:', error);
    }
  };

  return (
    <div className="App">
      {/* Header */}
      <header className="App-header">
        <h1>🌐 React WebView App</h1>
        <p className="subtitle">Komunikacja z iOS Swift</p>
        
        {/* Status badges */}
        <div className="status-badges">
          <div className={`status-badge ${isWebViewEnvironment ? 'connected' : 'disconnected'}`}>
            {isWebViewEnvironment ? '✓ WKWebView' : '⚠ Browser Mode'}
          </div>
          
          <div className={`status-badge ${isSessionActive ? 'session-active' : 'session-inactive'}`}>
            {isSessionActive ? '🟢 Sesja aktywna' : '🔴 Brak sesji'}
          </div>
        </div>

        {/* User ID Display */}
        {isSessionActive && userId && (
          <div className="user-info">
            <span className="user-icon">👤</span>
            <span className="user-id">User: {userId}</span>
          </div>
        )}
      </header>

      {/* Main Content */}
      <main className="App-main">
        
        {/* Session Warning */}
        {!isSessionActive && isWebViewEnvironment && (
          <div className="warning-box">
            <h3>⚠️ Sesja nieaktywna</h3>
            <p>Kliknij przycisk <strong>"Start Sesji"</strong> w aplikacji iOS aby nawiązać połączenie.</p>
            <p>Dopóki sesja nie zostanie rozpoczęta, nie możesz wysyłać ani odbierać wiadomości.</p>
          </div>
        )}

        {/* Statistics Section */}
        <section className="card stats-card">
          <h2>📊 Statystyki</h2>
          <div className="stats-grid">
            <div className="stat-item">
              <div className="stat-value">{messagesReceivedCount}</div>
              <div className="stat-label">Otrzymano</div>
            </div>
            <div className="stat-item">
              <div className="stat-value">{messagesSentCount}</div>
              <div className="stat-label">Wysłano</div>
            </div>
          </div>
        </section>

        {/* Send Message Section */}
        <section className="card">
          <h2>📤 Wyślij do iOS</h2>
          
          <button 
            className="primary-button" 
            onClick={sendMessageToNative}
            disabled={!isWebViewEnvironment || !isSessionActive}
          >
            {!isSessionActive && '🔒 '}
            Wyślij wiadomość do Swift
          </button>
          
          <div className="action-buttons">
            <button 
              className="secondary-button" 
              onClick={() => sendActionMessage('button_clicked')}
              disabled={!isWebViewEnvironment || !isSessionActive}
            >
              {!isSessionActive && '🔒 '}
              📱 Akcja: Klik
            </button>
            <button 
              className="secondary-button" 
              onClick={() => sendActionMessage('data_requested')}
              disabled={!isSessionActive || !isWebViewEnvironment}
            >
              {!isSessionActive && '🔒 '}
              📊 Akcja: Dane
            </button>
          </div>

          {!isSessionActive && (
            <div className="button-hint">
              🔒 Przyciski zablokowane - wymagana aktywna sesja
            </div>
          )}
        </section>

        {/* Received Messages Section */}
        <section className="card">
          <h2>📨 Odebrane z iOS</h2>
          {messagesFromNative.length === 0 ? (
            <div className="empty-state">
              {isSessionActive 
                ? 'Brak wiadomości - wyślij coś z iOS!'
                : 'Rozpocznij sesję aby odbierać wiadomości'
              }
            </div>
          ) : (
            <div className="messages-list">
              {messagesFromNative.map((msg, index) => (
                <div key={index} className="message-card">
                  <div className="message-header">
                    <span className="message-type">{msg.type}</span>
                    <span className="message-time">{msg.receivedAt}</span>
                  </div>
                  <div className="message-body">
                    {msg.payload && msg.payload.text ? (
                      <p className="message-text">{msg.payload.text}</p>
                    ) : null}
                    {msg.payload && msg.payload.message ? (
                      <p className="message-text">{msg.payload.message}</p>
                    ) : null}
                    <pre className="message-data">
                      {JSON.stringify(msg.payload, null, 2)}
                    </pre>
                  </div>
                </div>
              ))}
            </div>
          )}
        </section>

        {/* Info Section */}
        <section className="info-card">
          <h3>ℹ️ Jak to działa?</h3>
          <ul className="info-list">
            <li>
              <strong>1. Start Sesji</strong>
              <br/>Kliknij "Start Sesji" w iOS aby aktywować komunikację
            </li>
            <li>
              <strong>2. Wysyłanie wiadomości</strong>
              <br/>Gdy sesja aktywna, możesz swobodnie wymieniać wiadomości
            </li>
            <li>
              <strong>3. Reset</strong>
              <br/>Reset w iOS kończy sesję i czyści wszystkie dane
            </li>
          </ul>
        </section>
      </main>

      {/* Footer */}
      <footer className="App-footer">
        <p>Native WebView Bridge • React 18</p>
        {isSessionActive && (
          <p className="session-info">Sesja aktywna: {userId}</p>
        )}
      </footer>
    </div>
  );
}

export default App;
