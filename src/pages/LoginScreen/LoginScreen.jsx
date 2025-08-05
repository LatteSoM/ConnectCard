import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useSnackbar } from 'notistack';
import {
  Box,
  Button,
  TextField,
  Typography,
  IconButton,
} from '@mui/material';
import { styled } from '@mui/material/styles';
import { FaTelegram, FaVk } from 'react-icons/fa';
import axios from 'axios';
import LogoNight from '../../assets/LogoNight.svg';

const Container = styled(Box)`
  padding: 24px;
  width: 100%;
  max-width: 600px;
  margin: 0 auto;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  align-items: center;
  min-height: 100vh;

  @media (max-width: 600px) {
    padding: 16px;
  }
`;

const SocialButton = styled(Button)`
  height: 51px;
  border-radius: 12px;
  text-transform: none;
  font-size: 13px;
  font-weight: 700;
`;

const LoginScreen = () => {
  const [login, setLogin] = useState('');
  const [password, setPassword] = useState('');
  const navigate = useNavigate();
  const { enqueueSnackbar } = useSnackbar();
  const baseUrl = import.meta.env.VITE_BASE_URL;

  const extractToken = async (token) => {
    try {
      const response = await axios.get(`${baseUrl}/auth/current_user`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (response.status === 200) {
        localStorage.setItem('token', token);
        localStorage.setItem('id', response.data.id);
        navigate('/welcome', { state: { userName: response.data.name } });
      } else {
        enqueueSnackbar('Извините, произошла ошибка', { variant: 'error' });
      }
    } catch (e) {
      enqueueSnackbar(`Произошла ошибка сети: ${e.message}`, { variant: 'error' });
    }
  };

  const signIn = async () => {
    if (!login || !password) {
      enqueueSnackbar('Не все поля заполнены', { variant: 'error' });
      return;
    }

    try {
      const response = await axios.post(
        `${baseUrl}/auth/token`,
        new URLSearchParams({
          username: login,
          password: password,
          grant_type: 'password',
        }),
        { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
      );

      if (response.status === 200) {
        extractToken(response.data.access_token);
      } else {
        enqueueSnackbar('Неверный логин или пароль', { variant: 'error' });
      }
    } catch (e) {
      enqueueSnackbar('Произошла ошибка сети', { variant: 'error' });
    }
  };

  return (
    <Container>
      <Box sx={{ height: 87 }} />
      <img src={LogoNight} alt="ConnectCard Logo" style={{ maxWidth: '200px' }} />
      <Box sx={{ height: 14 }} />
      <Typography variant="h5" align="center">
        <span>Connect</span>
        <span style={{ color: '#7C4DFF' }}>Card</span>
      </Typography>
      <Box sx={{ height: 50 }} />
      <Typography variant="h6" align="center">
        <span>Создавай и делись </span>
        <span style={{ color: '#7C4DFF' }}>визитками нового поколения</span>
      </Typography>
      <Box sx={{ height: 50 }} />
      <TextField
        fullWidth
        value={login}
        onChange={(e) => setLogin(e.target.value)}
        placeholder="Почта или телефон"
        variant="filled"
        sx={{
          '& .MuiFilledInput-root': {
            backgroundColor: '#1A1A1A',
            borderRadius: '12px',
            '&:before, &:after': { borderBottom: 'none' },
          },
          '& .MuiInputBase-input': { color: '#fff' },
          '& .MuiInputLabel-root': { color: '#9C9C9C' },
        }}
      />
      <Box sx={{ height: 15 }} />
      <TextField
        fullWidth
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Пароль"
        variant="filled"
        sx={{
          '& .MuiFilledInput-root': {
            backgroundColor: '#1A1A1A',
            borderRadius: '12px',
            '&:before, &:after': { borderBottom: 'none' },
          },
          '& .MuiInputBase-input': { color: '#fff' },
          '& .MuiInputLabel-root': { color: '#9C9C9C' },
        }}
      />
      <Box sx={{ height: 50 }} />
      <Button
        fullWidth
        variant="contained"
        onClick={signIn}
        sx={{
          backgroundColor: '#7C4DFF',
          borderRadius: '12px',
          padding: '16px',
          fontSize: '18px',
          fontWeight: 700,
          textTransform: 'none',
        }}
      >
        Войти
      </Button>
      <Box sx={{ height: 15 }} />
      <Button
        fullWidth
        variant="contained"
        onClick={() => navigate('/register')}
        sx={{
          backgroundColor: '#7C4DFF',
          borderRadius: '12px',
          padding: '16px',
          fontSize: '18px',
          fontWeight: 700,
          textTransform: 'none',
        }}
      >
        Зарегистрироваться
      </Button>
      <Box sx={{ height: 20 }} />
      <Typography variant="caption" sx={{ color: '#9C9C9C' }}>
        или войти через
      </Typography>
      <Box sx={{ height: 20 }} />
      <Box sx={{ display: 'flex', gap: 1, width: '100%', justifyContent: 'center' }}>
        <SocialButton
          variant="contained"
          startIcon={<FaTelegram size={28} />}
          onClick={() => navigate('/auth/telegram')}
          sx={{ backgroundColor: '#40C4FF' }}
        >
          Telegram
        </SocialButton>
        <SocialButton
          variant="contained"
          startIcon={<FaVk size={28} />}
          onClick={() => navigate('/auth/vk')}
          sx={{ backgroundColor: '#4C75A3' }}
        >
          ВКонтакте
        </SocialButton>
      </Box>
      <Box sx={{ flexGrow: 1 }} />
      <Typography variant="caption" sx={{ pb: 2 }}>
        ConnectCard v.1.0.0
      </Typography>
    </Container>
  );
};

export default LoginScreen;