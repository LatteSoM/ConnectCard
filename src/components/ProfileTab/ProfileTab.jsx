import React from 'react';
import { DownOutlined, SettingOutlined, UserOutlined } from '@ant-design/icons';
import { Dropdown, Space, Avatar } from 'antd';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import avatar from '../../assets/testusericon.jpg';


const ProfileTab = () => {
  const navigate = useNavigate();
  const { userLogin, logout } = useAuth();

  const handleMenuClick = (e) => {
    switch (e.key) {
      case '2': navigate('/profile'); break;
      case '5': navigate('/settings'); break;
      case 'logout': logout(); break;
      default: break;
    }
  };

  const items = [
    { key: '1', label: userLogin?.login || 'Гость', disabled: true },
    { type: 'divider' },
    { key: '2', label: 'Профиль', icon: <UserOutlined /> },
    { key: '5', label: 'Настройки', icon: <SettingOutlined /> },
    { type: 'divider' },
    { key: 'logout', label: 'Выйти' },
  ];

  return (
    <Dropdown menu={{ items, onClick: handleMenuClick }}>
      <a onClick={(e) => e.preventDefault()}>
        <Space>
          <Avatar size="large" src={<img src={avatar} alt="avatar" />} />

          {userLogin?.name || 'Гость'}
          <DownOutlined />
        </Space>
      </a>
    </Dropdown>
  );
};
export default ProfileTab;