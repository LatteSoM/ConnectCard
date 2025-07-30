import React from 'react';
import { Button, Result } from 'antd';
import Icon, { QuestionCircleFilled } from '@ant-design/icons';
import classes from './NotFound.module.css'
import { useLocation, useNavigate, Link } from 'react-router-dom';

const NotFound = () => {
    return (
        <>
            <Result
                status="404"
                title="Такой страницы мы не делали :("
                subTitle="Может Вы ошиблись?"
                extra={
                    <Link to='/'>
                        <Button className={classes.goToHomeBtn} type="primary">
                            На главную
                        </Button>
                    </Link>
                }
            />
        </>
    );
};

export default NotFound;
