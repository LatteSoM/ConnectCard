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
import { useAuth } from '../../context/AuthContext'; // Используем useAuth
import LogoNight from '../../assets/LogoNight.svg'; // Проверьте путь

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
  const [form, setForm] = useState({
    login: '',
    password: '',
    email: '',
    name: '',
    consentGiven: false,
  });
  const [errors, setErrors] = useState({});
  const [serverError, setServerError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth(); // Используем useAuth вместо AuthContext
  const navigate = useNavigate();
  const { enqueueSnackbar } = useSnackbar();

  const handleChange = (field) => (e) => {
    const value = field === 'consentGiven' ? e.target.checked : e.target.value;
    setForm({ ...form, [field]: value });
    setErrors((prev) => ({ ...prev, [field]: null }));
    setServerError('');
  };

  const handleSubmit = async () => {
    const newErrors = {};
    const loginRegex = /^[a-zA-Z0-9]{1,32}$/;
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const nameRegex = /^(?!.*\d)(?!.* {3,})[a-zA-Zа-яА-ЯёЁ\s'-]+$/u;

    if (!form.login || !loginRegex.test(form.login)) {
      newErrors.login = 'Логин должен содержать только латинские буквы и цифры, максимум 32 символа';
    }
    if (!form.password || form.password.length < 8) {
      newErrors.password = 'Минимум 8 символов';
    }
    if (!form.email || !emailRegex.test(form.email)) {
      newErrors.email = 'Некорректный email';
    }
    if (!form.name || !nameRegex.test(form.name.trim())) {
      newErrors.name = 'Имя не должно содержать цифры, спецсимволы или более двух пробелов подряд';
    }
    if (!form.consentGiven) {
      newErrors.consentGiven = 'Необходимо согласие на обработку данных';
    }

    if (Object.keys(newErrors).length) {
      setErrors(newErrors);
      return;
    }

    try {
      setLoading(true);
      setErrors({});
      setServerError('');

      const response = await axios.post('http://127.0.0.1:8002/auth/register', {
        name: form.name.trim(),
        email: form.email.trim(),
        login: form.login.trim(),
        password: form.password,
        consent_given: form.consentGiven, // Добавляем поле для соответствия API
      });
      const { access_token } = response.data;
      localStorage.setItem('token', access_token);
      await login(form.login, form.password);
      enqueueSnackbar('Пользователь успешно зарегистрирован', { variant: 'success' });
      navigate('/');
    } catch (error) {
      const detail = error.response?.data?.detail;
      if (detail === 'Username already registered') {
        setServerError('Логин уже занят. Один из вас мой напарник, а другой лживый...');
      } else if (detail === 'Email уже зарегистрирован') {
        setServerError('Эта почта уже занята');
      } else {
        setServerError('Ошибка при регистрации. Попробуйте позже.');
      }
    } finally {
      setLoading(false);
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
        value={form.name}
        onChange={handleChange('name')}
        placeholder="Имя"
        variant="filled"
        error={!!errors.name}
        helperText={errors.name}
        inputProps={{ maxLength: 255 }}
        sx={{
          '& .MuiFilledInput-root': {
            backgroundColor: '#1A1A1A',
            borderRadius: '12px',
            '&:before, &:after': { borderBottom: 'none' },
          },
          '& .MuiInputBase-input': { color: '#fff' },
          '& .MuiInputLabel-root': { color: '#9C9C9C' },
          '& .MuiFormHelperText-root': { color: 'red' },
        }}
      />
      <Box sx={{ height: 15 }} />
      <TextField
        fullWidth
        value={form.email}
        onChange={handleChange('email')}
        placeholder="Email"
        variant="filled"
        error={!!errors.email}
        helperText={errors.email}
        inputProps={{ maxLength: 255 }}
        sx={{
          '& .MuiFilledInput-root': {
            backgroundColor: '#1A1A1A',
            borderRadius: '12px',
            '&:before, &:after': { borderBottom: 'none' },
          },
          '& .MuiInputBase-input': { color: '#fff' },
          '& .MuiInputLabel-root': { color: '#9C9C9C' },
          '& .MuiFormHelperText-root': { color: 'red' },
        }}
      />
      <Box sx={{ height: 15 }} />
      <TextField
        fullWidth
        value={form.login}
        onChange={handleChange('login')}
        placeholder="Логин"
        variant="filled"
        error={!!errors.login}
        helperText={errors.login}
        inputProps={{ maxLength: 32 }}
        sx={{
          '& .MuiFilledInput-root': {
            backgroundColor: '#1A1A1A',
            borderRadius: '12px',
            '&:before, &:after': { borderBottom: 'none' },
          },
          '& .MuiInputBase-input': { color: '#fff' },
          '& .MuiInputLabel-root': { color: '#9C9C9C' },
          '& .MuiFormHelperText-root': { color: 'red' },
        }}
      />
      <Box sx={{ height: 15 }} />
      <TextField
        fullWidth
        type="password"
        value={form.password}
        onChange={handleChange('password')}
        placeholder="Пароль"
        variant="filled"
        error={!!errors.password}
        helperText={errors.password}
        inputProps={{ maxLength: 255 }}
        sx={{
          '& .MuiFilledInput-root': {
            backgroundColor: '#1A1A1A',
            borderRadius: '12px',
            '&:before, &:after': { borderBottom: 'none' },
          },
          '& .MuiInputBase-input': { color: '#fff' },
          '& .MuiInputLabel-root': { color: '#9C9C9C' },
          '& .MuiFormHelperText-root': { color: 'red' },
        }}
      />
      <Box sx={{ height: 15 }} />
      <TextField
        fullWidth
        type="password"
        value={form.password}
        onChange={handleChange('password')}
        placeholder="Подтверждение пароля"
        variant="filled"
        error={!!errors.password}
        helperText={errors.password}
        inputProps={{ maxLength: 255 }}
        sx={{
          '& .MuiFilledInput-root': {
            backgroundColor: '#1A1A1A',
            borderRadius: '12px',
            '&:before, &:after': { borderBottom: 'none' },
          },
          '& .MuiInputBase-input': { color: '#fff' },
          '& .MuiInputLabel-root': { color: '#9C9C9C' },
          '& .MuiFormHelperText-root': { color: 'red' },
        }}
      />
      <Box sx={{ height: 15 }} />
      <FormControlLabel
        control={
          <Checkbox
            checked={form.consentGiven}
            onChange={handleChange('consentGiven')}
            sx={{ color: '#7C4DFF', '&.Mui-checked': { color: '#7C4DFF' } }}
          />
        }
        label="Я согласен на обработку персональных данных"
        sx={{ color: '#fff', m: 0 }}
      />
      {serverError && (
        <Typography sx={{ color: 'red', fontSize: '0.9rem', textAlign: 'center', mt: 2 }}>
          {serverError}
        </Typography>
      )}
      <Box sx={{ height: 30 }} />
      <Button
        fullWidth
        variant="contained"
        onClick={handleSubmit}
        disabled={loading}
        sx={{
          backgroundColor: '#7C4DFF',
          borderRadius: '12px',
          padding: '16px',
          fontSize: '18px',
          fontWeight: 700,
          textTransform: 'none',
        }}
      >
        {loading ? 'Загрузка...' : 'Создать аккаунт'}
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