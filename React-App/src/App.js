import React, { useState, useEffect, useCallback } from 'react';
import './App.css';

function App() {
  // Stan dla przechowywania wiadomości
  const [messagesFromNative, setMessagesFromNative] = useState([]);
  const [messagesSent, setMessagesSent] = useState(0);
  const [isWebViewEnvironment, setIsWebViewEnvironment] = useState(false);

  // Sprawdź czy aplikacja działa w WebView
  useEffect(() => {
    const inWebView = window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp;
    setIsWebViewEnvironment(!!inWebView);
    
    if (inWebView) {
      console.log('✅ Running in WKWebView environment');
    } else {
      console.log('⚠️ Not running in WKWebView - using mock environment');
    }
  }, []);

  // Funkcja odbierająca wiadomości z aplikacji natywnej (Swift)
  // Ta funkcja jest wywoływana przez Swift przez evaluateJavaScript
  const receiveMessageFromNative = useCallback((message) => {
    console.log('📨 Received from Native:', message);
    
    const timestamp = new Date().toLocaleTimeString('pl-PL');
    const messageWithTimestamp = {
      ...message,
      receivedAt: timestamp
    };
    
    setMessagesFromNative(prev => [messageWithTimestamp, ...prev]);
  }, []);

  // Zarejestruj globalną funkcję do odbierania wiadomości
  useEffect(() => {
    window.receiveMessageFromNative = receiveMessageFromNative;
    
    return () => {
      delete window.receiveMessageFromNative;
    };
  }, [receiveMessageFromNative]);

  // Funkcja wysyłająca wiadomość do aplikacji natywnej (Swift)
  const sendMessageToNative = () => {
    const message = {
      type: 'greeting',
      payload: {
        text: 'Cześć z React! 🎉',
        count: messagesSent + 1,
        timestamp: new Date().toISOString(),
        source: 'React-JavaScript'
      }
    };

    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
      try {
        window.webkit.messageHandlers.nativeApp.postMessage(message);
        console.log('📤 Sent to Native:', message);
        setMessagesSent(prev => prev + 1);
      } catch (error) {
        console.error('❌ Error sending message:', error);
        alert('Błąd wysyłania wiadomości: ' + error.message);
      }
    } else {
      console.warn('⚠️ WKWebView interface not available');
      alert('Ta funkcja działa tylko w WKWebView!');
    }
  };

  // Wysłanie testowej wiadomości akcji użytkownika
  const sendActionMessage = (actionType) => {
    const message = {
      type: 'user_action',
      payload: {
        action: actionType,
        timestamp: new Date().toISOString(),
        userAgent: navigator.userAgent
      }
    };

    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
      try {
        window.webkit.messageHandlers.nativeApp.postMessage(message);
        console.log('📤 Sent action to Native:', message);
        setMessagesSent(prev => prev + 1);
      } catch (error) {
        console.error('❌ Error sending action:', error);
      }
    }
  };

  // Wyślij gotowość aplikacji do native przy pierwszym renderze
  useEffect(() => {
    if (isWebViewEnvironment) {
      setTimeout(() => {
        const readyMessage = {
          type: 'app_ready',
          payload: {
            timestamp: new Date().toISOString(),
            message: 'React app is ready to communicate'
          }
        };
        
        window.webkit.messageHandlers.nativeApp.postMessage(readyMessage);
        console.log('📤 Sent ready message to Native');
      }, 500);
    }
  }, [isWebViewEnvironment]);

  return (
    <div className="App">
      {/* Header */}
      <header className="App-header">
        <h1>🌐 React WebView App</h1>
        <p className="subtitle">Komunikacja z iOS Swift</p>
        <div className={`status-badge ${isWebViewEnvironment ? 'connected' : 'disconnected'}`}>
          {isWebViewEnvironment ? '✓ WKWebView' : '⚠ Browser Mode'}
        </div>
      </header>

      {/* Main Content */}
      <main className="App-main">
        {/* Send Message Section */}
        <section className="card">
          <h2>📤 Wyślij do iOS</h2>
          <button 
            className="primary-button" 
            onClick={sendMessageToNative}
            disabled={!isWebViewEnvironment}
          >
            Wyślij wiadomość do Swift
          </button>
          
          <div className="action-buttons">
            <button 
              className="secondary-button" 
              onClick={() => sendActionMessage('button_clicked')}
              disabled={!isWebViewEnvironment}
            >
              📱 Akcja: Klik
            </button>
            <button 
              className="secondary-button" 
              onClick={() => sendActionMessage('data_requested')}
              disabled={!isWebViewEnvironment}
            >
              📊 Akcja: Dane
            </button>
          </div>

          <div className="stats">
            Wysłano wiadomości: <strong>{messagesSent}</strong>
          </div>
        </section>

        {/* Received Messages Section */}
        <section className="card">
          <h2>📨 Odebrane z iOS</h2>
          {messagesFromNative.length === 0 ? (
            <div className="empty-state">
              Brak wiadomości od aplikacji natywnej
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
          <h3>ℹ️ Informacje</h3>
          <ul className="info-list">
            <li>✅ Komunikacja JavaScript → Swift przez <code>window.webkit.messageHandlers</code></li>
            <li>✅ Komunikacja Swift → JavaScript przez <code>window.receiveMessageFromNative()</code></li>
            <li>✅ Format wiadomości: JSON z polami <code>type</code> i <code>payload</code></li>
            <li>✅ Dwukierunkowa komunikacja w czasie rzeczywistym</li>
          </ul>
        </section>
      </main>

      {/* Footer */}
      <footer className="App-footer">
        <p>Dreams SDK + WKWebView Demo • React 18</p>
      </footer>
    </div>
  );
}

export default App;
