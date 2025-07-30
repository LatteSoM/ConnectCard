import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'
import { ThemeProvider } from 'antd-style'
import { ConfigProvider, theme } from 'antd'
import 'antd/dist/reset.css'
import { AuthProvider } from './context/AuthContext';
import './utils/setupFontAwesome';

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <ThemeProvider 
      theme={{
        token: {
          colorPrimary: '#7a4bfc',
          colorBgBase: '#141218',
          colorBgContainer: '#121015',
          colorTextBase: '#ffffff',
          colorTextSecondary: '#bfbfbf',
          colorTextTertiary: '#8c8c8c',
          colorTextQuaternary: '#595959',
          colorBorder: '#333333',
          colorBgElevated: '#1f1c2b',
          colorBgLayout: '#141218',
          colorBgContainerDisabled: '#1f1c2b',
          colorBgSpotlight: '#1f1c2b',
          colorFill: '#7a4bfc',
          colorFillSecondary: '#4c2b9f',
          colorFillTertiary: '#3a1f7c',
          colorFillQuaternary: '#2a1459',
          colorError: '#ff4d4f',
          colorWarning: '#faad14',
          colorSuccess: '#52c41a',
          colorInfo: '#1890ff',
          colorLink: '#7a4bfc',
          colorLinkHover: '#6a3acb',
          colorLinkActive: '#5a2aa2',
          colorTextLightSolid: '#ffffff',
          colorTextLightSolidSecondary: '#d9d9d9',
          colorTextLightSolidTertiary: '#bfbfbf',
          colorTextLightSolidQuaternary: '#8c8c8c',
          colorTextLightSolidQuinary: '#595959',
          colorTextLightSolidSenary: '#333333',
          colorTextLightSolidSeventh: '#1f1c2b',
        },
      }}

      >
        <AuthProvider>
          <App />
        </AuthProvider>
    </ThemeProvider>
  </StrictMode>,
)