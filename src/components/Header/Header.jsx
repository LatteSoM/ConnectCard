import React from 'react';
import { Layout, Menu } from 'antd';
import classes from './Header.module.css';
import MyButton from '../Button/Button.jsx';
import ProfileTab from '../ProfileTab/ProfileTab.jsx';
import { useLocation, useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import logo from '../../assets/LogoNight.svg';

const { Header } = Layout;

const headerItems = [
  { key: '/', label: 'Главная' },
  { key: '/contacts', label: 'Контакты' },
  { key: '/cards', label: 'Мои визитки' },
];

const AppHeader = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const { userLogin } = useAuth();

  const handleMenuClick = ({ key }) => {
    navigate(key);
  };

  const menuItems = [
    { key: '/', label: 'Главная' },
    ...(userLogin ? [
      { key: '/contacts', label: 'Контакты' },
      { key: '/cards', label: 'Мои визитки' },
    ] : []),
  ];

  return (
    <Header style={{ display: 'flex', alignItems: 'center' }}>
      <div className={classes.logo}>
        <Link className={classes.logo} to="/">
          <img src={logo} alt="Logo" />
          <div className={classes.logotitle}>ConnectCard</div>
        </Link>
      </div>

      <Menu
        theme="dark"
        mode="horizontal"
        selectedKeys={[location.pathname]}
        items={menuItems}
        onClick={handleMenuClick}
        style={{
          flex: 1,
          minWidth: 0,
          height: '100%',
          display: 'flex',
          alignItems: 'center',
        }}
      />

      <div className={classes.controls}>
        {userLogin ? (
          <ProfileTab />
        ) : (
          <MyButton variant="reg" isActive={true} onClick={() => navigate('/login')}>
            Войти
          </MyButton>
        )}
      </div>
    </Header>
  );
};


export default AppHeader;