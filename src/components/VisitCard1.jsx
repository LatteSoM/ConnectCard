// src/components/VisitCard1.jsx
import React from 'react';
import { Box, Typography } from '@mui/material';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faBuilding } from '@fortawesome/free-solid-svg-icons';
import QRCode from 'qrcode.react';
import classes from './VisitCard1.module.css';

function VisitCard1({ fullName, position, company, socialLinks, template, avatar, selectedImage, isSelected, isList }) {
  // Implement similar to Flutter, with different templates as conditional renders
  // For brevity, implement one template, extend for others
  const topLinks = socialLinks.slice(0, 3);
  return (
    <Box className={classes.container} style={{ border: isSelected ? '3px solid white' : '2px solid white' }}>
      <Box className={classes.left}>
        <img src={selectedImage ? URL.createObjectURL(selectedImage) : avatar} alt="avatar" className={classes.avatar} />
        {topLinks.map(link => (
          <Box key={link.name}>
            {/* <FontAwesomeIcon icon={} /> */}
            <Typography>{link.link}</Typography>
          </Box>
        ))}
      </Box>
      <Box className={classes.right}>
        <Typography>{fullName}</Typography>
        <Typography>{position}</Typography>
        <Box>
          <FontAwesomeIcon icon={faBuilding} />
          <Typography>{company}</Typography>
        </Box>
        <QRCode value="https://example.com" size={70} />
      </Box>
    </Box>
  );
}

export default VisitCard1;