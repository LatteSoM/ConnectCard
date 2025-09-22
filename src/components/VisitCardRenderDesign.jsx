// src/components/VisitCardRenderDesign.jsx
import React from 'react';
import { Box, Typography } from '@mui/material';
import classes from './VisitCardRenderDesign.module.css';

function VisitCardRenderDesign({ elements }) {
  // Render elements with CSS transforms
  return (
    <Box className={classes.container}>
      <Box className={classes.gradient} />
      {elements.map((el, i) => {
        const style = {
          transform: `matrix(${el.matrix}) rotate(${el.rotation_angle}deg)`,
          width: el.width,
          height: el.height,
          color: el.color,
          // etc
        };
        if (el.type === 'text') {
          return <Typography key={i} style={style}>{el.text}</Typography>;
        } else if (el.type === 'shape') {
          // Use div with border-radius for circle, etc
          return <Box key={i} style={style} />;
        } else if (el.type === 'image') {
          return <img key={i} src={el.image_url} style={style} alt="" />;
        }
        return null;
      })}
    </Box>
  );
}

export default VisitCardRenderDesign;