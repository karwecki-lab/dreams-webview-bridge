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
  const [appUrl, setAppUrl] = useState('');

  // Check if running in WebView and get URL
  useEffect(() => {
    const inWebView = window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp;
    setIsWebViewEnvironment(!!inWebView);
    setAppUrl(window.location.href);
    
    if (inWebView) {
      console.log('✅ Running in WKWebView environment');
    } else {
      console.log('⚠️ Not running in WKWebView');
    }
  }, []);

  // Receive messages from native app (Swift)
  const receiveMessageFromNative = useCallback((message) => {
    console.log('📨 Received from Native:', message);
    
    // Handle different message types
    if (message.type === 'session_started') {
      // START SESSION
      const newUserId = message.payload?.userId || 'unknown';
      setIsSessionActive(true);
      setUserId(newUserId);
      setMessagesReceivedCount(prev => prev + 1);
      console.log('🟢 Session started:', newUserId);
      
      // Add message to history
      const timestamp = new Date().toLocaleTimeString('en-US');
      setMessagesFromNative(prev => [{
        ...message,
        receivedAt: timestamp
      }, ...prev]);
      
    } else if (message.type === 'session_ended') {
      // END SESSION (RESET)
      console.log('🔴 Session ended - clearing state');
      setIsSessionActive(false);
      setUserId(null);
      setMessagesFromNative([]);
      setMessagesReceivedCount(0);
      setMessagesSentCount(0);
      
    } else {
      // REGULAR MESSAGE
      if (!isSessionActive) {
        console.warn('⚠️ Message rejected - no active session');
        return;
      }
      
      const timestamp = new Date().toLocaleTimeString('en-US');
      const messageWithTimestamp = {
        ...message,
        receivedAt: timestamp
      };
      
      setMessagesFromNative(prev => [messageWithTimestamp, ...prev]);
      setMessagesReceivedCount(prev => prev + 1);
    }
  }, [isSessionActive]);

  // Register global function to receive messages
  useEffect(() => {
    window.receiveMessageFromNative = receiveMessageFromNative;
    
    return () => {
      delete window.receiveMessageFromNative;
    };
  }, [receiveMessageFromNative]);

  // Send message to native app (Swift)
  const sendMessageToNative = () => {
    if (!isWebViewEnvironment) {
      alert('This function works only in WKWebView!');
      return;
    }

    if (!isSessionActive) {
      alert('⚠️ Session is not active!\nClick "Start Session" in iOS to establish connection.');
      return;
    }

    const message = {
      type: 'greeting',
      payload: {
        text: 'Hello from React! 🎉',
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
      alert('Error sending message: ' + error.message);
    }
  };

  // Send user action
  const sendActionMessage = (actionType) => {
    if (!isSessionActive) {
      alert('⚠️ Session is not active!');
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
        <p className="subtitle">Communication with iOS Swift</p>
        
        {/* Status badges */}
        <div className="status-badges">
          <div className={`status-badge ${isWebViewEnvironment ? 'connected' : 'disconnected'}`}>
            {isWebViewEnvironment ? '✓ WKWebView' : '⚠ Browser Mode'}
          </div>
          
          <div className={`status-badge ${isSessionActive ? 'session-active' : 'session-inactive'}`}>
            {isSessionActive ? '🟢 Session Active' : '🔴 No Session'}
          </div>
        </div>

        {/* User ID Display */}
        {isSessionActive && userId && (
          <div className="user-info">
            <span className="user-icon">👤</span>
            <span className="user-id">User: {userId}</span>
          </div>
        )}

        {/* App URL Display */}
        <div className="url-info">
          <span className="url-icon">🔗</span>
          <span className="url-text">{appUrl}</span>
        </div>
      </header>

      {/* Main Content */}
      <main className="App-main">
        
        {/* Session Warning */}
        {!isSessionActive && isWebViewEnvironment && (
          <div className="warning-box">
            <h3>⚠️ Session Inactive</h3>
            <p>Click <strong>"Start Session"</strong> button in iOS app to establish connection.</p>
            <p>You cannot send or receive messages until the session is started.</p>
          </div>
        )}

        {/* Statistics Section */}
        <section className="stats-card">
          <h2>📊 Statistics</h2>
          <div className="stats-grid">
            <div className="stat-item">
              <div className="stat-icon">📨</div>
              <div className="stat-value">{messagesReceivedCount}</div>
              <div className="stat-label">Received</div>
            </div>
            <div className="stat-item">
              <div className="stat-icon">📤</div>
              <div className="stat-value">{messagesSentCount}</div>
              <div className="stat-label">Sent</div>
            </div>
            <div className="stat-item">
              <div className="stat-icon">💬</div>
              <div className="stat-value">{messagesReceivedCount + messagesSentCount}</div>
              <div className="stat-label">Total</div>
            </div>
            <div className="stat-item">
              <div className="stat-icon">{isSessionActive ? '🟢' : '🔴'}</div>
              <div className="stat-value">{isSessionActive ? 'ON' : 'OFF'}</div>
              <div className="stat-label">Session</div>
            </div>
          </div>
        </section>

        {/* Send Message Section */}
        <section className="card">
          <h2>📤 Send to iOS</h2>
          
          <button 
            className="primary-button" 
            onClick={sendMessageToNative}
            disabled={!isWebViewEnvironment || !isSessionActive}
          >
            {!isSessionActive && '🔒 '}
            Action: Send Message to Swift
          </button>
          
          <div className="action-buttons">
            <button 
              className="secondary-button" 
              onClick={() => sendActionMessage('button_clicked')}
              disabled={!isWebViewEnvironment || !isSessionActive}
            >
              {!isSessionActive && '🔒 '}
              📱 Action: Request Customer Data
            </button>
            <button 
              className="secondary-button" 
              onClick={() => sendActionMessage('data_requested')}
              disabled={!isSessionActive || !isWebViewEnvironment}
            >
              {!isSessionActive && '🔒 '}
              📊 Action: Request Payment
            </button>
          </div>

          {!isSessionActive && (
            <div className="button-hint">
              🔒 Buttons locked - active session required
            </div>
          )}
        </section>

        {/* Received Messages Section */}
        <section className="card">
          <h2>📨 Received from iOS</h2>
          {messagesFromNative.length === 0 ? (
            <div className="empty-state">
              {isSessionActive 
                ? 'No messages - send something from iOS!'
                : 'Start session to receive messages'
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
          <h3>ℹ️ How it works?</h3>
          <ul className="info-list">
            <li>
              <strong>1. Start Session</strong>
              <br/>Click "Start Session" in iOS to activate communication
            </li>
            <li>
              <strong>2. Send Messages</strong>
              <br/>When session is active, you can freely exchange messages
            </li>
            <li>
              <strong>3. Reset</strong>
              <br/>Reset in iOS ends the session and clears all data
            </li>
          </ul>
        </section>
      </main>

      {/* Footer */}
      <footer className="App-footer">
        <p>Native WebView Bridge • React 18</p>
        {isSessionActive && (
          <p className="session-info">Active session: {userId}</p>
        )}
      </footer>
    </div>
  );
}

export default App;
