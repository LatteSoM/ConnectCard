import { createContext, useContext, useState, useEffect } from 'react';
import axios from 'axios';

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [userLogin, setUserLogin] = useState(null);
  const [accessToken, setAccessToken] = useState(null);
  const [refreshToken, setRefreshToken] = useState(null);
  const [loading, setLoading] = useState(true);

  // Логин
  const login = async (username, password) => {
    const form = new URLSearchParams();
    form.append("grant_type", "password");
    form.append("username", username);
    form.append("password", password);

    const response = await axios.post("http://127.0.0.1:8002/auth/token", form, {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    });

    const { access_token, refresh_token } = response.data;

    localStorage.setItem("access_token", access_token);
    localStorage.setItem("refresh_token", refresh_token);

    setAccessToken(access_token);
    setRefreshToken(refresh_token);

    await fetchCurrentUser(access_token);
  };

  // Выход
  const logout = () => {
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
    setAccessToken(null);
    setRefreshToken(null);
    setUserLogin(null);
  };

  // Получение текущего пользователя
  const fetchCurrentUser = async (token = null) => {
    const access = token || localStorage.getItem("access_token");
    if (!access) {
      setLoading(false);
      return;
    }

    try {
      const response = await axios.get("http://127.0.0.1:8002/auth/current_user", {
        headers: { Authorization: `Bearer ${access}` },
      });
      setUserLogin(response.data);
      setAccessToken(access);
    } catch (error) {
      logout();
    } finally {
      setLoading(false);
    }
  };

  // Обновление access_token по refresh_token
  const refreshAccessToken = async () => {
    const storedRefreshToken = refreshToken || localStorage.getItem("refresh_token");
    if (!storedRefreshToken) {
      logout();
      return null;
    }

    try {
      const response = await axios.post("http://127.0.0.1:8002/auth/refresh", storedRefreshToken, {
        headers: { 'Content-Type': 'application/json' },
      });

      const { access_token, refresh_token } = response.data;

      localStorage.setItem("access_token", access_token);
      localStorage.setItem("refresh_token", refresh_token);

      setAccessToken(access_token);
      setRefreshToken(refresh_token);

      return access_token;
    } catch (error) {
      logout();
      return null;
    }
  };

  // Установка токенов при старте
  useEffect(() => {
    const storedAccessToken = localStorage.getItem("access_token");
    const storedRefreshToken = localStorage.getItem("refresh_token");

    if (storedAccessToken && storedRefreshToken) {
      setAccessToken(storedAccessToken);
      setRefreshToken(storedRefreshToken);
      fetchCurrentUser(storedAccessToken);
    } else {
      setLoading(false);
    }
  }, []);

  // Axios интерцептор для автоматического обновления токена. Както работает
  useEffect(() => {
    const interceptor = axios.interceptors.response.use(
      (response) => response,
      async (error) => {
        const originalRequest = error.config;

        if (
          error.response?.status === 401 &&
          !originalRequest._retry &&
          refreshToken
        ) {
          originalRequest._retry = true;
          const newAccessToken = await refreshAccessToken();

          if (newAccessToken) {
            originalRequest.headers['Authorization'] = `Bearer ${newAccessToken}`;
            return axios(originalRequest);
          }
        }

        return Promise.reject(error);
      }
    );

    return () => {
      axios.interceptors.response.eject(interceptor);
    };
  }, [refreshToken]);

  return (
    <AuthContext.Provider
      value={{
        userLogin,
        accessToken,
        login,
        logout,
        loading,
        refetchUserData: fetchCurrentUser,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
