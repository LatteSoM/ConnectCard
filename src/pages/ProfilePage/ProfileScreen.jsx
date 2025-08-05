import { useState, useEffect, useCallback } from 'react';
import { MailOutlined, PhoneOutlined, LockOutlined, CheckOutlined, CloseOutlined } from '@ant-design/icons';
import { Button, Card, Input, Flex, Modal, Avatar, Spin, Tooltip } from 'antd';
import MyButton from '../../components/Button/Button.jsx';
import { useAuth } from '../../context/AuthContext';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import classes from './ProfileScreen.module.css';

const ProfileScreen = () => {
  const [user, setUser] = useState({
    id: '',
    name: '',
    login: '',
    email: '',
    phone: null,
    isVkAuth: false,
    isTelegramAuth: false,
    hasPassword: false,
  });
  const [isEditing, setIsEditing] = useState(false);
  const [isChangingPassword, setIsChangingPassword] = useState(false);
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [modalMessage, setModalMessage] = useState({ title: '', subtitle: '', icon: null });
  const { logout } = useAuth();
  const navigate = useNavigate();

  const baseUrl = 'http://127.0.0.1:8002';

  const loadUser = useCallback(async () => {
    setLoading(true);
    try {
      const token = localStorage.getItem('token');
      if (!token) throw new Error('No token found');
      const response = await axios.get(`${baseUrl}/auth/current_user`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      const userData = response.data;
      setUser({
        id: userData.id,
        name: userData.name,
        login: userData.login,
        email: userData.email || 'Не указана',
        phone: userData.phone || 'Не указан',
        isVkAuth: userData.vk_authorized,
        isTelegramAuth: userData.telegram_authorized,
        hasPassword: !!userData.password,
      });
      setEmail(userData.email || 'Не указана');
      setPhone(userData.phone || 'Не указан');
    } catch (error) {
      console.error(error);
      Modal.error({
        title: 'Ошибка',
        content: 'Не удалось загрузить данные пользователя',
      });
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadUser();
  }, [loadUser]);

  const showModal = (type) => {
    let title, subtitle, icon;
    switch (type) {
      case 'enteringEdit':
        title = 'Режим редактирования';
        subtitle = 'Измените нужные поля';
        icon = <FontAwesomeIcon icon="edit" />;
        break;
      case 'savingChanges':
        title = 'Изменения сохранены';
        subtitle = 'Ваши данные успешно обновлены';
        icon = <CheckOutlined />;
        break;
      case 'cancelingEdit':
        title = 'Редактирование отменено';
        subtitle = 'Изменения не были сохранены';
        icon = <CloseOutlined />;
        break;
      default:
        return;
    }
    setModalMessage({ title, subtitle, icon });
    setModalVisible(true);
    setTimeout(() => setModalVisible(false), 1500);
  };

  const enterEditMode = () => {
    showModal('enteringEdit');
    setIsEditing(true);
  };

  const cancelEditing = () => {
    showModal('cancelingEdit');
    setIsEditing(false);
    setIsChangingPassword(false);
    setNewPassword('');
    setConfirmPassword('');
    setEmail(user.email);
    setPhone(user.phone);
  };

  const changeInfo = async () => {
    if (isChangingPassword && newPassword !== confirmPassword) {
      Modal.error({ title: 'Ошибка', content: 'Пароли не совпадают' });
      return;
    }
    showModal('savingChanges');
    try {
      const updateData = {
        email: email.trim(),
        phone: phone || null,
        ...(newPassword && { password: newPassword }),
      };
      await axios.put(`${baseUrl}/users/${user.id}`, updateData, {
        headers: { Authorization: `Bearer ${localStorage.getItem('token')}` },
      });
      setUser((prev) => ({ ...prev, email: email.trim(), phone: phone || 'Не указан' }));
      setIsEditing(false);
      setIsChangingPassword(false);
      setNewPassword('');
      setConfirmPassword('');
    } catch (error) {
      const detail = error.response?.data?.detail;
      Modal.error({
        title: 'Ошибка',
        content: detail === 'Email already registered' ? 'Данный email уже занят' : 'Ошибка сети',
      });
      setEmail(user.email);
      setPhone(user.phone);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    logout();
    navigate('/login');
    Modal.success({ title: 'Выход', content: 'Вы успешно вышли из аккаунта' });
  };

  const SocialField = ({ icon, value, isAuthorized, isFirstTwo, isPassword, onAuth }) => (
    <div className={classes.socialField}>
      <Flex align="center" gap="middle">
        <FontAwesomeIcon icon={icon} className={classes.socialIcon} />
        {isPassword && isEditing && !isChangingPassword ? (
          <Button
            type="primary"
            shape="round"
            onClick={() => setIsChangingPassword(true)}
            className={classes.actionButton}
          >
            {user.hasPassword ? 'Изменить пароль' : 'Задать пароль'}
          </Button>
        ) : isEditing && isChangingPassword && isPassword ? (
          <Flex vertical gap="small" style={{ width: '100%' }}>
            <Input.Password
              placeholder="Новый пароль"
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              className={classes.input}
            />
            <Input.Password
              placeholder="Подтвердите пароль"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              className={classes.input}
            />
            <Flex gap="small">
              <Button
                type="primary"
                shape="round"
                onClick={changeInfo}
                disabled={!newPassword || newPassword !== confirmPassword}
                className={classes.actionButton}
              >
                Сохранить
              </Button>
              <Button
                shape="circle"
                icon={<CloseOutlined />}
                onClick={() => {
                  setIsChangingPassword(false);
                  setNewPassword('');
                  setConfirmPassword('');
                }}
                danger
              />
            </Flex>
          </Flex>
        ) : isEditing && !isPassword ? (
          <Flex align="center" gap="small" style={{ width: '100%' }}>
            {isAuthorized ? (
              <Input value={value} readOnly className={classes.input} />
            ) : (
              <span className={classes.placeholder}>Не авторизован</span>
            )}
            {isFirstTwo && (
              <Button
                type="link"
                onClick={onAuth}
                disabled={isAuthorized}
                className={classes.authButton}
              >
                {isAuthorized ? <CloseOutlined /> : 'Авторизовать'}
              </Button>
            )}
          </Flex>
        ) : (
          <span className={classes.text}>
            {isPassword && isAuthorized ? '••••••••••••••••' : value}
          </span>
        )}
      </Flex>
    </div>
  );

  return (
    <div className={classes.wrapper}>
      <Spin spinning={loading}>
        <Flex vertical gap="large" className={classes.container}>
          {isEditing && (
            <Flex justify="flex-end">
              <Button
                type="primary"
                shape="circle"
                icon={<CheckOutlined />}
                onClick={changeInfo}
                className={classes.saveButton}
              />
            </Flex>
          )}
          <Flex vertical align="center" gap="middle">
            <Avatar size={110} className={classes.avatar} />
            <div className={classes.name}>{user.name}</div>
            <div className={classes.login}>{user.login}</div>
          </Flex>
          <Card className={classes.card}>
            <Flex vertical gap="middle">
              <div className={classes.sectionTitle}>Аккаунт</div>
              <SocialField
                icon={['fab', 'vk']}
                value={user.isVkAuth ? 'Авторизован' : 'Не авторизован'}
                isAuthorized={user.isVkAuth}
                isFirstTwo
                onAuth={() => navigate('/auth/vk')}
              />
              <SocialField
                icon={['fab', 'telegram']}
                value={user.isTelegramAuth ? 'Авторизован' : 'Не авторизован'}
                isAuthorized={user.isTelegramAuth}
                isFirstTwo
                onAuth={() => navigate('/auth/telegram')}
              />
              <SocialField
                icon="mail"
                value={email}
                isAuthorized={email !== 'Не указана'}
                onAuth={() => {}}
                onChange={(e) => setEmail(e.target.value)}
              >
                {isEditing && (
                  <Input
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    prefix={<MailOutlined />}
                    className={classes.input}
                  />
                )}
              </SocialField>
              <SocialField
                icon="phone"
                value={phone}
                isAuthorized={phone !== 'Не указан'}
                onAuth={() => {}}
                onChange={(e) => setPhone(e.target.value)}
              >
                {isEditing && (
                  <Input
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    prefix={<PhoneOutlined />}
                    className={classes.input}
                  />
                )}
              </SocialField>
              <SocialField
                icon="lock"
                value={user.hasPassword ? 'Пароль установлен' : 'Пароль не установлен'}
                isAuthorized={user.hasPassword}
                isPassword
              />
            </Flex>
          </Card>
          <Flex vertical gap="middle">
            {!isEditing ? (
              <>
                <MyButton type="primary" onClick={enterEditMode}>
                  Редактировать профиль
                </MyButton>
                <MyButton type="primary" onClick={() => navigate('/settings')}>
                  Настройки приложения
                </MyButton>
                <MyButton type="primary" danger onClick={handleLogout}>
                  Выйти из аккаунта
                </MyButton>
              </>
            ) : (
              <MyButton type="primary" danger onClick={cancelEditing}>
                Выйти из редактирования
              </MyButton>
            )}
          </Flex>
        </Flex>
      </Spin>
      <Modal
        open={modalVisible}
        footer={null}
        closable={false}
        centered
        bodyStyle={{ background: '#141218', color: 'white', textAlign: 'center' }}
      >
        <Flex vertical align="center" gap="middle">
          <div className={classes.modalIcon}>{modalMessage.icon}</div>
          <div className={classes.modalTitle}>{modalMessage.title}</div>
          <div className={classes.modalSubtitle}>{modalMessage.subtitle}</div>
        </Flex>
      </Modal>
    </div>
  );
};

export default ProfileScreen;