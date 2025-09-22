import { useState } from 'react';
import { UserOutlined, MailOutlined, KeyOutlined, LoadingOutlined } from '@ant-design/icons';
import { Button, Input, Flex, Tooltip, Spin } from 'antd';
import MyButton from '../../components/Button/Button.jsx';
import { useAuth } from '../../context/AuthContext';
import { useNavigate, Link } from 'react-router-dom';
import classes from './Registration.module.css';
import axios from 'axios';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

const Registration = () => {
  const [form, setForm] = useState({
    login: '',
    password: '',
    email: '',
    name: '',
  });
  const [errors, setErrors] = useState({});
  const [serverError, setServerError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleChange = (field) => (e) => {
    setForm({ ...form, [field]: e.target.value });
    setErrors((prev) => ({ ...prev, [field]: null }));
    setServerError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

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

    if (Object.keys(newErrors).length) {
      setErrors(newErrors);
      return;
    }

    try {
      setLoading(true);
      setErrors({});
      setServerError('');

      const response = await axios.post('http://172.18.0.4:8000/auth/register', {
        name: form.name.trim(),
        email: form.email.trim(),
        login: form.login.trim(),
        password: form.password,
        consent_given: true, // Добавляем для соответствия схеме
      });
      const { access_token } = response.data;
      localStorage.setItem('token', access_token);
      await login(form.login, form.password);
      navigate('/');
    } catch (error) {
      if (error.response && error.response.data && error.response.data.detail) {
        const detail = error.response.data.detail;
        if (detail === 'Username already registered') {
          setServerError('Логин уже занят. Один из вас мой напарник, а другой лживый...');
        } else if (detail === 'Email уже зарегистрирован') {
          setServerError('Эта почта уже занята');
        } else {
          setServerError('Ошибка при регистрации. Попробуйте позже.');
        }
      } else {
        setServerError('Ошибка сети. Проверьте подключение или настройки сервера.');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={classes.wrapper}>
      <Flex vertical justify="center" align="center" gap="large" className={classes.container}>
        <div className={classes.titleBlock}>
          <div className={classes.titleBlockLogo}>
            <img src="/src/assets/LogoNight.svg" alt="Logo" />
          </div>
          <div className={classes.titleBlockText}>
            <div className={classes.title}>
              Connect<span>Card</span>
            </div>
            <div className={classes.subtitle}>Создайте свою цифровую визитку</div>
          </div>
        </div>

        <div className={classes.loginFormContainer}>
          <form className={classes.loginForm} onSubmit={handleSubmit}>
            <Flex vertical justify="center" align="center" gap="small">
              <Input
                size="large"
                value={form.login}
                placeholder="Введите логин"
                onChange={handleChange('login')}
                prefix={<UserOutlined />}
                status={errors.login ? 'error' : ''}
                maxLength={32}
              />
              {errors.login && (
                <div style={{ color: 'red', fontSize: '0.9rem' }}>{errors.login}</div>
              )}

              <Input.Password
                size="large"
                value={form.password}
                placeholder="Пароль"
                onChange={handleChange('password')}
                prefix={<KeyOutlined />}
                status={errors.password ? 'error' : ''}
                maxLength={255}
              />
              {errors.password && (
                <div style={{ color: 'red', fontSize: '0.9rem' }}>{errors.password}</div>
              )}

              <Input
                size="large"
                value={form.email}
                placeholder="Введите почту"
                onChange={handleChange('email')}
                prefix={<MailOutlined />}
                status={errors.email ? 'error' : ''}
                maxLength={255}
              />
              {errors.email && (
                <div style={{ color: 'red', fontSize: '0.9rem' }}>{errors.email}</div>
              )}

              <Input
                size="large"
                value={form.name}
                placeholder="Как Вас зовут?"
                onChange={handleChange('name')}
                status={errors.name ? 'error' : ''}
                maxLength={255}
              />
              {errors.name && (
                <div style={{ color: 'red', fontSize: '0.9rem' }}>{errors.name}</div>
              )}
            </Flex>

            <br />
            {serverError && (
              <div style={{ color: 'red', marginBottom: '1rem' }}>{serverError}</div>
            )}

            <MyButton variant="primary" type="submit" disabled={loading}>
              {loading ? (
                <Spin style={{ color: 'white' }} indicator={<LoadingOutlined spin />} />
              ) : (
                'Зарегистрироваться'
              )}
            </MyButton>
          </form>
          <div className={classes.touContainer}>
            <div className={classes.touContainerText}>
              Регистрируясь, Вы даете согласие на обработку Ваших персональных данных, а также соглашаетесь с правилами использования сервиса.{' '}
              <a href="#">Подробнее...</a>
            </div>
          </div>
        </div>

        <div className={classes.registerContainer}>
          <div className={classes.registerContainerText}>
            Уже с нами? <Link to="/login">Войдите в меня 🤤</Link>
          </div>
        </div>

        <div className={classes.socialContainer}>
          <div className={classes.socialDivider} aria-orientation="horizontal">
            <span className={classes.socialDividerMiddleText}>или</span>
          </div>
          <div className={classes.socialOptionsContainer}>
            <Tooltip title="LinkedIn">
              <Button
                size="large"
                shape="circle"
                icon={<FontAwesomeIcon icon={['fab', 'square-linkedin']} />}
                onClick={() => navigate('/auth/linkedin')}
              />
            </Tooltip>
            <Tooltip title="Telegram">
              <Button
                size="large"
                shape="circle"
                icon={<FontAwesomeIcon icon={['fab', 'telegram']} />}
                onClick={() => navigate('/auth/telegram')}
              />
            </Tooltip>
            <Tooltip title="VK">
              <Button
                size="large"
                shape="square"
                icon={<FontAwesomeIcon icon={['fab', 'vk']} />}
                onClick={() => navigate('/auth/vk')}
              />
            </Tooltip>
          </div>
        </div>
      </Flex>
      <Flex vertical justify="center" align="center" gap="large">
        <Link to="/" className={classes.toHomeLink}>
          На главную
        </Link>
      </Flex>
    </div>
  );
};

export default Registration;