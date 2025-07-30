import { useEffect, useState } from 'react';
import {
  UserOutlined,
  KeyOutlined,
  LinkedinOutlined,
  GoogleOutlined,
  LoadingOutlined,
} from '@ant-design/icons';
import { Button, Input, Flex, Tooltip, Spin } from 'antd';
import MyButton from '../../components/Button/Button.jsx';
import { useAuth } from '../../context/AuthContext';
import { useNavigate, Link } from 'react-router-dom';
import classes from './Login.module.css';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';


const LoginPage = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [errors, setErrors] = useState({ username: '', password: '' });
  const [serverError, setServerError] = useState('');
  const [loading, setLoading] = useState(false);

  const { userLogin, login } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (!loading && userLogin) {
      navigate('/');
    }
  }, [loading, userLogin]);

  const handleChange = (field) => (e) => {
    if (field === 'username') {
      setUsername(e.target.value);
      setErrors((prev) => ({ ...prev, username: '' }));
    } else if (field === 'password') {
      setPassword(e.target.value);
      setErrors((prev) => ({ ...prev, password: '' }));
    }
    setServerError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrors({});
    setServerError('');

    const newErrors = {};
    const usernameRegex = /^[A-Za-z0-9]{1,32}$/;

    if (!username) {
      newErrors.username = 'Логин не может быть пустым';
    } else if (!usernameRegex.test(username)) {
      newErrors.username = 'Логин должен содержать только латинские буквы и цифры (до 32 символов)';
    }

    if (!password) {
      newErrors.password = 'Пароль не может быть пустым';
    } else if (password.length < 8) {
      newErrors.password = 'Пароль должен быть не короче 8 символов';
    }

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }

    try {
      setLoading(true);
      await login(username, password);
      navigate('/');
    } catch (err) {
      console.error(err);
      setServerError('Неверный логин или пароль');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={classes.wrapper}>
      <Flex vertical justify="center" align="center" gap="large" className={classes.container}>
        <div className={classes.titleBlock}>
          <div className={classes.titleBlockLogo}>
            <img src="src/assets/LogoNight.svg" alt="Logo" />
          </div>
          <div className={classes.titleBlockText}>
            <div className={classes.title}>
              Connect<span>Card</span>
            </div>
            <div className={classes.subtitle}>Рады, что Вы с нами!</div>
          </div>
        </div>

        <div className={classes.loginFormContainer}>
          <form className={classes.loginForm} onSubmit={handleSubmit}>
            <Flex vertical justify="center" align="center" gap="small">
              <Input
                size="large"
                value={username}
                placeholder="Логин"
                onChange={handleChange('username')}
                prefix={<UserOutlined />}
                status={errors.username ? 'error' : ''}
              />
              {errors.username && (
                <div style={{ color: 'red', fontSize: '0.9rem' }}>{errors.username}</div>
              )}

              <Input.Password
                size="large"
                value={password}
                placeholder="Пароль"
                onChange={handleChange('password')}
                prefix={<KeyOutlined />}
                status={errors.password ? 'error' : ''}
              />
              {errors.password && (
                <div style={{ color: 'red', fontSize: '0.9rem' }}>{errors.password}</div>
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
                'Войти'
              )}
            </MyButton>
          </form>
        </div>

        <div className={classes.registerContainer}>
          <div className={classes.registerContainerText}>
            Нет аккаунта? <Link to="/registration">Зарегистрируйтесь</Link>
          </div>
        </div>

        <div className={classes.socialContainer}>
          <div className={classes.socialDivider} aria-orientation="horizontal">
            <span className={classes.socialDividerMiddleText}>или</span>
          </div>
          <div className={classes.socialOptionsContainer}>
            <Tooltip title="LinkedIn">
              <FontAwesomeIcon icon={['fab', 'square-linkedin']} size='2x' />
              {/* <Button size="large" shape="circle" icon={<GoogleOutlined />} /> */}
            </Tooltip>
            <Tooltip title="Telegram">
              <FontAwesomeIcon icon={['fab', 'telegram']} size='2x' />
              {/* <Button size="large" shape="circle" icon={<LinkedinOutlined />} /> */}
            </Tooltip>
            <Tooltip title="VK">
              {/* <FontAwesomeIcon icon={['fab', 'vk']} size='2x'/> */}
              <Button size="large" shape="square" icon={<FontAwesomeIcon icon={['fab', 'vk']} size='2x' />} />
            </Tooltip>
          </div>
        </div>
      </Flex>
      <Flex vertical justify='center' align='center' gap='large'>
        <Link to="/" className={classes.toHomeLink}>На главную</Link>
      </Flex>
    </div>
  );
};

export default LoginPage;
