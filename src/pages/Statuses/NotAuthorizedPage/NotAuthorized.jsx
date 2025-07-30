import React from 'react';
import { Button, Result } from 'antd';
import { QuestionCircleFilled } from '@ant-design/icons';
import classes from './NotAuthorized.module.css'
import { useLocation, useNavigate, Link } from 'react-router-dom';


const NotAuthorized = () => {
    return (
        <>
            <Result
                status="403"
                title="Вы не авторизованы!"
                subTitle="Для просмотра этой страницы войдите в свой аккаунт"
                extra={
                    <>
                    <Link to='/login'>
                        <Button className={classes.goToLoginBtn} type="primary">
                            Войти
                        </Button>
                    </Link>
                    <Link to='/'>
                        <Button className={classes.goToHomeBtn} type="default">
                            На главную
                        </Button>
                    </Link>
                    </>
                }
            />
        </>
    );
};

export default NotAuthorized;
