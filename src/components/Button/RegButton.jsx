import React from 'react';
import classes from './RegButton.module.css';

export default function RegButton({ children, isActive, ...props}) {
    return (
        <button
            {...props}
            className={isActive ? `${classes.button} ${classes.active}` : classes.button}
        >
            {children}
        </button>
    )
}