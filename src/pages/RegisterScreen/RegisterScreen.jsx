import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useSnackbar } from 'notistack';
import {
  Box,
  Button,
  TextField,
  Typography,
  Checkbox,
  FormControlLabel,
  IconButton,
} from '@mui/material';
import { styled } from '@mui/material/styles';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
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

const BackButtonContainer = styled(Box)`
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(156, 39, 176, 0.2);
  border-radius: 50%;
  width: 40px;
  height: 40px;
  align-self: flex-start;
`;

const SocialButton = styled(Button)`
  height: 51px;
  border-radius: 12px;
  text-transform: none;
  font-size: 13px;
  font-weight: 700;
`;

const RegisterScreen = () => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [login, setLogin] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [consentGiven, setConsentGiven] = useState(false);
  const navigate = useNavigate();
  const { enqueueSnackbar } = useSnackbar();
  const baseUrl = import.meta.env.VITE_BASE_URL;

  const registerUser = async () => {
    if (!name || !email || !login || !password || !confirmPassword) {
      enqueueSnackbar('Обязательное поле', { variant: 'error' });
      return;
    }
    if (!email.includes('@')) {
      enqueueSnackbar('Некорректный email', { variant: 'error' });
      return;
    }
    if (password.length < 6) {
      enqueueSnackbar('Минимум 6 символов', { variant: 'error' });
      return;
    }
    if (password !== confirmPassword) {
      enqueueSnackbar('Пароли не совпадают', { variant: 'error' });
      return;
    }
    if (!consentGiven) {
      enqueueSnackbar('Необходимо согласие на обработку данных', { variant: 'error' });
      return;
    }

    try {
      const response = await axios.post(
        `${baseUrl}/auth/register`,
        {
          name: name.trim(),
          email: email.trim(),
          login: login.trim(),
          password,
        },
        { headers: { 'Content-Type': 'application/json' } }
      );

      if (response.status === 200) {
        enqueueSnackbar('Пользователь успешно зарегистрирован', { variant: 'success' });
        navigate('/login');
      } else {
        const error = response.data.detail;
        enqueueSnackbar(
          error === 'Username already registered' ? 'Данный логин уже занят' : 'Ошибка регистрации',
          { variant: 'error' }
        );
      }
    } catch (e) {
      enqueueSnackbar('Извините, произошла ошибка сети', { variant: 'error' });
    }
  };

  return (
    <Container>
      <BackButtonContainer>
        <IconButton sx={{ color: '#9C27B0' }} onClick={() => navigate('/login')}>
          <ArrowBackIcon />
        </IconButton>
      </BackButtonContainer>
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
        value={name}
        onChange={(e) => setName(e.target.value)}
        placeholder="Имя"
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
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
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
        value={login}
        onChange={(e) => setLogin(e.target.value)}
        placeholder="Логин"
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
      <Box sx={{ height: 15 }} />
      <TextField
        fullWidth
        type="password"
        value={confirmPassword}
        onChange={(e) => setConfirmPassword(e.target.value)}
        placeholder="Подтверждение пароля"
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
      <FormControlLabel
        control={
          <Checkbox
            checked={consentGiven}
            onChange={(e) => setConsentGiven(e.target.checked)}
            sx={{ color: '#7C4DFF', '&.Mui-checked': { color: '#7C4DFF' } }}
          />
        }
        label="Я согласен на обработку персональных данных"
        sx={{ color: '#fff', m: 0 }}
      />
      <Box sx={{ height: 30 }} />
      <Button
        fullWidth
        variant="contained"
        onClick={registerUser}
        sx={{
          backgroundColor: '#7C4DFF',
          borderRadius: '12px',
          padding: '16px',
          fontSize: '18px',
          fontWeight: 700,
          textTransform: 'none',
        }}
      >
        Создать аккаунт
      </Button>
      <Box sx={{ height: 20 }} />
      <Typography variant="caption" sx={{ color: '#9C9C9C' }}>
        или зарегистрироваться через
      </Typography>
      <Box sx={{ height: 20 }} />
      <Box sx={{ display: 'flex', gap: 1, width: '100%' }}>
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
      <Box sx={{ height: 20 }} />
      <Typography variant="caption" sx={{ pb: 2 }}>
        ConnectCard v.1.0.0
      </Typography>
    </Container>
  );
};

export default RegisterScreen;