import React from 'react';
import clsx from 'clsx';
import classes from './Button.module.css';

export default function MyButton({ children, isActive = true, variant = 'default', ...props }) {
  const buttonClass = clsx(
    classes.button,
    classes[variant],
    { [classes.disabled]: !isActive }
  );

  return (
    <button
      className={buttonClass}
      disabled={!isActive}
      {...props}
    >
      {children}
    </button>
  );
}
