import { useState } from 'react';
import { Routes, Route, HashRouter } from 'react-router-dom';
import { createTheme, ThemeProvider } from '@mui/material';

import './App.css';
import Top from './routes/top';
import ChatReader from './routes/chatreader/chatreader';
import OBS from './routes/obs/obs';
import Main from './routes/main/main';
import Rick from './routes/rick/rick';

const darkTheme = createTheme({
  palette: {
    mode: 'dark',
  },
});

function App() {
  const [ttsConfig, setTTSConfig] = useState({
      channelName: "",
      ignoreExclamationPrefix: true,
      readUsername: true,
      languages: ['id', 'en', 'ja'],
      isConnected: false,
      isLoading: false,
  });

  function _handleTTSConfigChange(newTTSConfig) {
    setTTSConfig(newTTSConfig);
  }

  function _handleTTSConnect(connect) {
    if(connect) {
      window.api.tts(ttsConfig, true, _handleTTSOnSuccess, _handleTTSOnDisconnect, _handleTTSOnConnecting);
    } else {
      window.api.tts(ttsConfig, false, _handleTTSOnSuccess, _handleTTSOnDisconnect, _handleTTSOnConnecting);
    }
  }

  function _handleTTSOnSuccess() {
    setTTSConfig({...ttsConfig, isConnected: true, isLoading: false});
  }

  function _handleTTSOnDisconnect() {
    setTTSConfig({...ttsConfig, isConnected: false, isLoading: false});
  }

  function _handleTTSOnConnecting() {
    setTTSConfig({...ttsConfig, isConnected: false, isLoading: true});
  }

  return (
    <ThemeProvider theme={darkTheme}>
      <HashRouter>
        <Routes>
          <Route path="/" element={<Top />}>
            <Route path="/" element={<Main />} />
            <Route path="/chat" 
              element={<ChatReader 
                config={ttsConfig} 
                onRequestConnect={_handleTTSConnect} 
                onConfigChange={_handleTTSConfigChange} />
            } />
            <Route path="/obs" element={<OBS />} />
            <Route path="/rick" element={<Rick />} />
          </Route>
        </Routes>
      </HashRouter>
    </ThemeProvider>
  );
}

export default App;
