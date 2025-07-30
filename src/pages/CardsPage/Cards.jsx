import { useEffect, useState } from 'react';
import { useAuth } from '../../context/AuthContext.jsx';
import { useNavigate, Link } from 'react-router-dom';
import axios from 'axios';

import { Spin, Result, Button } from 'antd';
import { LoadingOutlined, FrownOutlined } from '@ant-design/icons';

import ContactLink from '../../components/ContactLink/ContactLink.jsx';

import NotFound from '../Statuses/NotFoundPage/NotFound.jsx';
import NotAuthorized from '../Statuses/NotAuthorizedPage/NotAuthorized.jsx';
import InternalError from '../Statuses/InternalErrorPage/InternalError.jsx';

import classes from './Cards.module.css';

const Cards = () => {
    const { accessToken, userLogin, loading } = useAuth();
    const userId = userLogin?.id;

    const navigate = useNavigate();

    const [cards, setCards] = useState([]);
    const [errorStatus, setErrorStatus] = useState(null);

    useEffect(() => {
        const fetchCards = async () => {
            if (!accessToken || !userId) return;

            try {
                const response = await axios.get(`http://127.0.0.1:8000/cards/user/${userId}`, {
                    headers: {
                        Authorization: `Bearer ${accessToken}`,
                    },
                });
                setCards(response.data);
            } catch (error) {
                console.error(error);
                setErrorStatus(error.response?.status || 500);
            }
        };

        fetchCards();
    }, [accessToken, userId]);

    if (loading) return (
        <div className="loadingContainer">
            <Spin indicator={<LoadingOutlined style={{ fontSize: 48 }} spin />} />
        </div>
    ); if (!accessToken || !userLogin) return <NotAuthorized />;
    if (errorStatus === 401) return <NotAuthorized />;
    if (errorStatus === 404) return <NotFound />;
    if (errorStatus && errorStatus >= 500) return <InternalError error={`Ошибка ${errorStatus}`} />;

    if (!cards || cards.length === 0) {
        return (
            <Result
                icon={<FrownOutlined />}
                title="У Вас еще нет ни одной визитки"
                subTitle="Давайте создадим Вашу первую визитную карточку?"
                extra={[
                    <Link to="/cards/creation" key="createcardlink">
                        <Button className={classes.createCardBtn} type="primary">
                            Создать
                        </Button>
                    </Link>,
                ]}
            />
        );
    }

    return (
        <div className={classes.cardList}>
            <h2>Мои визитки</h2>
            {cards.map((card) => (
                <div className={classes.card} key={card.id}>
                    <p><strong>ФИО:</strong> {card.fullname}</p>
                    <p><strong>Компания:</strong> {card.company}</p>
                    <p><strong>Должность:</strong> {card.position}</p>
                    <p><strong>О себе:</strong> {card.about}</p>

                    <h3>Контакты:</h3>
                    {card.contact_infos?.map((info) => (
                        <ContactLink key={info.id} social={info.name} url={info.description} variant="default" />
                    ))}

                    <h3>Ссылки:</h3>
                    {card.link_widgets?.map((link) => (
                        <ContactLink key={link.id} social={link.name} url={link.link} variant="default" />
                    ))}
                </div>
            ))}
        </div>
    );
};

export default Cards;
