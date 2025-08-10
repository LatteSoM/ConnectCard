import { useState, useCallback } from 'react';
import { Select, Switch, Button, Flex, Divider } from 'antd';
import { useNavigate } from 'react-router-dom';
import MyButton from '../../components/Button/Button.jsx';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import classes from './SettingsScreen.module.css';

const SettingsScreen = () => {
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [selectedLanguage, setSelectedLanguage] = useState('Русский');
  const [selectedTheme, setSelectedTheme] = useState('Системная');
  const navigate = useNavigate();

  const languages = ['Русский', 'English', 'Español', 'Deutsch', 'Français', '中文', '日本語'];
  const themes = ['Светлая', 'Темная'];

  const handleSave = useCallback(() => {
    // TODO: Интеграция с API для сохранения настроек, если нужно
    // Например: axios.post('http://127.0.0.1:8002/settings', { language: selectedLanguage, notifications: notificationsEnabled, theme: selectedTheme })
    console.log('Settings saved:', { selectedLanguage, notificationsEnabled, selectedTheme });
    navigate('/profile');
  }, [selectedLanguage, notificationsEnabled, selectedTheme, navigate]);

  return (
    <div className={classes.wrapper}>
      <Flex vertical gap="large" className={classes.container}>
        <Flex justify="space-between" align="center">
          <Button
            shape="circle"
            className={classes.backButton}
            icon={<FontAwesomeIcon icon="arrow-left" />}
            onClick={() => navigate('/profile')}
          />
          <Button
            shape="circle"
            className={classes.saveButton}
            icon={<FontAwesomeIcon icon="check" />}
            onClick={handleSave}
          />
        </Flex>
        <div className={classes.title}>Настройки</div>
        <Divider className={classes.divider} />
        <Flex vertical gap="middle">
          <Flex align="center" gap="middle" className={classes.settingRow}>
            <FontAwesomeIcon icon="globe" className={classes.icon} />
            <span className={classes.label}>Язык</span>
            <Select
              value={selectedLanguage}
              onChange={setSelectedLanguage}
              options={languages.map((lang) => ({ label: lang, value: lang }))}
              className={classes.select}
              popupClassName={classes.dropdown}
            />
          </Flex>
          <Flex align="center" gap="middle" className={classes.settingRow}>
            <FontAwesomeIcon icon="bell" className={classes.icon} />
            <span className={classes.label}>Уведомления</span>
            <Switch
              checked={notificationsEnabled}
              onChange={setNotificationsEnabled}
              checkedChildren="Вкл"
              unCheckedChildren="Выкл"
              className={classes.switch}
            />
          </Flex>
          <Flex align="center" gap="middle" className={classes.settingRow}>
            <FontAwesomeIcon icon="adjust" className={classes.icon} />
            <span className={classes.label}>Тема</span>
            <Flex className={classes.themeSelector}>
              {themes.map((theme) => (
                <Button
                  key={theme}
                  type={selectedTheme === theme ? 'primary' : 'default'}
                  className={classes.themeButton}
                  onClick={() => setSelectedTheme(theme)}
                >
                  {theme}
                </Button>
              ))}
            </Flex>
          </Flex>
        </Flex>
        <MyButton
          type="primary"
          icon={<FontAwesomeIcon icon="question-circle" />}
          onClick={() => console.log('Open FAQ')}
          className={classes.faqButton}
        >
          ConnectCard FAQ
        </MyButton>
      </Flex>
    </div>
  );
};

export default SettingsScreen;