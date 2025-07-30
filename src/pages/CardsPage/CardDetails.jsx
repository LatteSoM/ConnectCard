import { useParams } from 'react-router-dom';
import { useEffect, useState } from 'react';
import classes from './CardDetails.module.css';
import axios from 'axios';
import { useAuth } from '../../context/AuthContext.jsx';

import { Spin } from 'antd'
import { LoadingOutlined } from '@ant-design/icons';


import ContactLink from '../../components/ContactLink/ContactLink.jsx';

import NotFound from '../Statuses/NotFoundPage/NotFound.jsx';
import NotAuthorized from '../Statuses/NotAuthorizedPage/NotAuthorized.jsx';
import InternalError from '../Statuses/InternalErrorPage/InternalError.jsx';

const CardDetails = () => {
  const { cardId } = useParams();
  const [userCard, setUserCard] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const { accessToken } = useAuth();

  useEffect(() => {
    const fetchData = async () => {
      if (!accessToken) return;

      try {
        const response = await axios.get(`http://127.0.0.1:8000/cards/${cardId}`, {
          headers: {
            Authorization: `Bearer ${accessToken}`,
          },
        });
        setUserCard(response.data);
      } catch (err) {
        console.error(err);
        setError('Ошибка загрузки данных');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [cardId, accessToken]);


  if (!accessToken) return <NotAuthorized />;
  if (loading) return (
    <div className="loadingContainer">
      <Spin indicator={<LoadingOutlined style={{ fontSize: 48 }} spin />} />
    </div>
  ); if (error) return <InternalError error={error} />;
  if (!userCard) return <NotFound />;

  return (
    <>
      <h2>Профиль пользователя</h2>
      <div className={classes.container}>
        <p><strong>ФИО:</strong> {userCard.name}</p>
        <p><strong>Компания:</strong> {userCard.company}</p>
        <p><strong>Должность:</strong> {userCard.position}</p>
        <p><strong>О себе:</strong> {userCard.about}</p>

        <h3>Контакты:</h3>
        {/* <ul>
          {userCard.contact_info?.map((info, index) => (
            <li key={index}>
              <strong>{info.name}:</strong> {info.description}
            </li>
          ))}
        </ul> */}
        {userCard.contact_info?.map((info, index) => (
          <ContactLink key={index} social={info.name} url={info.description} variant="default" />
        ))}

        <h3>Ссылки:</h3>
        {userCard.link_widgets?.map((link, index) => (
          <ContactLink key={index} social={link.name} url={link.link} variant="default" />
        ))}
        {/* <ul>
          {userCard.link_widgets?.map((link, index) => (
            <li key={index}>
                <ContactLink social={link.name} url={link.link} />
            </li>
            // <li key={index}>
            //   <strong>{link.name}:</strong> <a href={link.link}>{link.link}</a>
            // </li>
          ))}
        </ul> */}
      </div>
    </>
  );
};

export default CardDetails;
