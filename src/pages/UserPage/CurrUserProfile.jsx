import classes from './User.module.css';
import { useAuth } from '../../context/AuthContext';
import {
  UserOutlined, CloseOutlined, SmileFilled, EditOutlined,
  MailOutlined, PhoneOutlined, LoadingOutlined
} from '@ant-design/icons';
import {
  Avatar, Divider, Flex, Button, Spin
} from 'antd';

import testavatar from '../../assets/testusericon.jpg';
import MyButton from '../../components/Button/Button.jsx';
import EditProfileModal from './EditProfileModal';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import NotFound from '../Statuses/NotFoundPage/NotFound.jsx';
import NotAuthorized from '../Statuses/NotAuthorizedPage/NotAuthorized.jsx';
import InternalError from '../Statuses/InternalErrorPage/InternalError.jsx';
import { useState } from 'react';

const CurrentUserProfile = () => {
  const { accessToken, userLogin, loading, refetchUserData } = useAuth();
  const [isModalVisible, setIsModalVisible] = useState(false);

  if (loading) return (
    <div className="loadingContainer">
      <Spin indicator={<LoadingOutlined style={{ fontSize: 48 }} spin />} />
    </div>
  );
  if (!accessToken) return <NotAuthorized />;
  if (!userLogin) return <NotFound />;


  const userCard = userLogin;

  return (
    <>
      <h2>Мой профиль</h2>

      <div className={classes.container}>
        <div className={classes.profileInfoBlock}>
          <Flex className={classes.profileContainer} align='center' justify='center'>
            <Avatar shape='square' size={164} src={<img src={testavatar} alt="avatar" />} />

            <Flex className={classes.profileInfoContainer} gap='small' vertical justify='space-between'>
              <div className={classes.profileInfoStrokeTitle}>
                <div className={classes.profileInfoText}>{userCard.name}</div>
              </div>

              <div className={classes.profileInfoStroke}>
                <div className={classes.profileInfoTitle}><MailOutlined /> Почта:</div>
                <div className={classes.profileInfoText}>{userCard.email || 'Не указана'}</div>
              </div>

              <div className={classes.profileInfoStroke}>
                <div className={classes.profileInfoTitle}><UserOutlined /> Логин:</div>
                <div className={classes.profileInfoText}>{userCard.login}</div>
              </div>

              <div className={classes.profileInfoStroke}>
                <div className={classes.profileInfoTitle}><PhoneOutlined /> Телефон:</div>
                <div className={classes.profileInfoText}>{userCard.phone || 'Не указан'}</div>
              </div>

              <div className={classes.profileInfoStroke}>
                <div className={classes.profileInfoTitle}>Дата регистрации:</div>
                <div className={classes.profileInfoText}>
                  {new Date(userCard.created_at).toLocaleString()}
                </div>
              </div>
            </Flex>
          </Flex>

          <Flex justify='flex-end'>
            <Button
              className={classes.editBtn}
              icon={<EditOutlined />}
              onClick={() => setIsModalVisible(true)}
            >
              Изменить
            </Button>

            <EditProfileModal
              visible={isModalVisible}
              onClose={() => setIsModalVisible(false)}
              userData={userCard}
              accessToken={accessToken}
              onUpdate={refetchUserData}
            />
          </Flex>
        </div>

        <Divider size="small" type="vertical" className={classes.hrVert} />

        <div className={classes.socialAuthBlock}>
          <Flex className={classes.socialAuthContainer} gap='small' vertical justify='space-between'>
            <div className={classes.socialAuthStrokeTitle}>
              <div className={classes.socialAuthText}>Привязка соцсетей</div>
            </div>

            <div className={classes.socialAuthStroke}>
              <div className={classes.socialAuthTitle}>
                <FontAwesomeIcon icon={['fab', 'telegram']} size='2x' />
              </div>

              {userCard.telegram_authorized === false ? (
                <Button className={classes.addAuthBtn} type="default" size='large'>
                  Войти через телеграм
                </Button>
              ) : (
                <>
                  <div className={classes.socialAuthTextContainer}>
                    <div className={classes.socialAuthText}>t.me/memberRemember</div>
                  </div>
                  <div>
                    <Button className={classes.removeAuthBtn} type="default" icon={<CloseOutlined />} size='large' />
                  </div>
                </>
              )}
            </div>

            <div className={classes.socialAuthStroke}>
              <div className={classes.socialAuthTitle}>
                <FontAwesomeIcon icon={['fab', 'vk']} size='2x' />
              </div>

              {userCard.vk_authorized === false ? (
                <Button className={classes.addAuthBtn} type="default" size='large'>
                  Войти через ВК
                </Button>
              ) : (
                <>
                  <div className={classes.socialAuthTextContainer}>
                    <div className={classes.socialAuthText}>id123456789</div>
                  </div>
                  <div>
                    <Button className={classes.removeAuthBtn} type="default" icon={<CloseOutlined />} size='large' />
                  </div>
                </>
              )}
            </div>
          </Flex>
        </div>
      </div>
    </>
  );
};

export default CurrentUserProfile;
