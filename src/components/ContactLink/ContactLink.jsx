import React from 'react';
import { DownOutlined, SettingOutlined, UserOutlined } from '@ant-design/icons';
import { Dropdown, Space, Avatar } from 'antd';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import avatar from '../../assets/testusericon.jpg';
import classes from './ContactLink.module.css'
import clsx from 'clsx';


const ContactLink = ({social, url, children, variant = 'default', ...props}) => {
    const navigate = useNavigate();
    const { userLogin, logout } = useAuth();
    const name = social;
    const link = url;

    const contactLinkClass = clsx(
        classes.ContactLink,
        classes[variant]
    );

    const handleContactLinkClick = (e) => {
        alert("Контакт нажат: ", name, link);
    };

    return (
        <div
            className={contactLinkClass}
            onClick={handleContactLinkClick}
            {...props}
        >
            <div>Соцсеть: {social}</div>
            {/* <div>Ссылка: {url}</div> */}
            <div>Ссылка: <a href={url} target="_blank" rel="noopener noreferrer">{url}</a></div>
            <div>Описание: {social}</div>
            {children}
        </div>
    );
};
export default ContactLink;