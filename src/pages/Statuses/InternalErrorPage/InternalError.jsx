import React from 'react';
import { Button, Result } from 'antd';
import classes from './InternalError.module.css';
import { Link } from 'react-router-dom';

const InternalError = ({ error }) => {
    return (
        <Result
            status="500"
            title="Что-то пошло не так :/"
            subTitle="Попробуйте позже, либо сообщите о проблеме на почту support@connectcard.ru"
            extra={
                <>
                    {error && (
                        <div className={classes.errorContainer}>
                            <div className={classes.errorTitle}>Ошибка:</div>
                            <div className={classes.errorBlock}>{error}</div>
                        </div>
                    )}
                    <Link to='/'>
                        <Button className={classes.goToHomeBtn} type="primary">
                            На главную
                        </Button>
                    </Link>
                </>
            }
        />
    );
};

export default InternalError;
