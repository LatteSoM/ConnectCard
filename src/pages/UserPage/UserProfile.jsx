import { useParams } from 'react-router-dom';
import { useEffect, useState } from 'react';
import classes from './User.module.css';
import axios from 'axios';
import { useAuth } from '../../context/AuthContext';


const User = () => {
  const { userId } = useParams();
  const [userCard, setUserCard] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const { accessToken } = useAuth();

  useEffect(() => {
    const fetchData = async () => {
      if (!accessToken) return;

      try {
        const response = await axios.get(`http://127.0.0.1:8000/users/${userId}`, {
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
  }, [userId, accessToken]);

  // 👉 Рендер условий — здесь, НЕ внутри useEffect
  if (!accessToken) return <p>Не авторизован</p>;
  if (loading) return <p>Загрузка...</p>;
  if (error) return <p>{error}</p>;
  if (!userCard) return <p>Профиль не найден</p>;

  return (
    <>
      <h2>Профиль пользователя</h2>
      <div className={classes.container}>
        <p><strong>ФИО:</strong> {userCard.name}</p>
        <p><strong>Компания:</strong> {userCard.company}</p>
        <p><strong>Должность:</strong> {userCard.position}</p>
        <p><strong>О себе:</strong> {userCard.about}</p>

        <h3>Контакты:</h3>
        <ul>
          {userCard.contact_info?.map((info, index) => (
            <li key={index}>
              <strong>{info.name}:</strong> {info.description}
            </li>
          ))}
        </ul>

        <h3>Ссылки:</h3>
        <ul>
          {userCard.link_widgets?.map((link, index) => (
            <li key={index}>
              <strong>{link.name}:</strong> <a href={link.link}>{link.link}</a>
            </li>
          ))}
        </ul>
      </div>
    </>
  );
};

export default User;
