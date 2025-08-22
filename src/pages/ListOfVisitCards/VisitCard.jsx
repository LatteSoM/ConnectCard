// VisitCard.jsx
import React from 'react';
import { Box, Typography, Avatar, IconButton } from '@mui/material';
import { Business as BuildingIcon, Person as PersonIcon } from '@mui/icons-material';
import QRCode from 'react-qr-code';

const prioritySocials = ['telegram', 'instagram', 'twitter', 'github', 'linkedin'];

const socialIcons = {
  twitter: <IconButton>Twitter</IconButton>, // Use actual icons
  telegram: <IconButton>Telegram</IconButton>,
  instagram: <IconButton>Instagram</IconButton>,
  github: <IconButton>Github</IconButton>,
  linkedin: <IconButton>LinkedIn</IconButton>,
};

const VisitCard = ({ fullName, position, company, socialLinks, avatar, isSelected, cardColor = '#1B1A20' }) => {
  const topSocialLinks = socialLinks
    .filter(link => prioritySocials.some(social => link.name.toLowerCase().includes(social)))
    .sort((a, b) => {
      const aIndex = prioritySocials.findIndex(social => a.name.toLowerCase().includes(social));
      const bIndex = prioritySocials.findIndex(social => b.name.toLowerCase().includes(social));
      return aIndex - bIndex;
    })
    .slice(0, 3);

  return (
    <Box sx={{ width: '90%', bgcolor: cardColor, borderRadius: 2.5, p: 2, border: `2px solid ${isSelected ? 'white' : 'transparent'}`, boxShadow: isSelected ? '0 0 10px white' : 'none' }}>
      <Box sx={{ display: 'flex' }}>
        <Box sx={{ width: '40%', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          <Avatar src={avatar} sx={{ width: 96, height: 96 }}>
            {!avatar && <PersonIcon sx={{ fontSize: 96 }} />}
          </Avatar>
          <Box sx={{ mt: 2 }}>
            {topSocialLinks.map((link, i) => {
              const key = prioritySocials.find(social => link.name.toLowerCase().includes(social));
              return (
                <Box key={i} sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                  {socialIcons[key]}
                  <Typography sx={{ ml: 1, fontSize: 14, fontWeight: 300, overflow: 'hidden', textOverflow: 'ellipsis' }}>{link.link}</Typography>
                </Box>
              );
            })}
          </Box>
        </Box>
        <Box sx={{ flex: 1, pl: 2, textAlign: 'center' }}>
          <Typography sx={{ fontSize: 18, fontWeight: 'bold' }}>{fullName}</Typography>
          <Typography sx={{ fontSize: 14, fontWeight: 300 }}>{position}</Typography>
          <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <BuildingIcon sx={{ fontSize: 20 }} />
            <Typography sx={{ ml: 0.5, fontSize: 14, fontWeight: 300 }}>{company}</Typography>
          </Box>
          <Box sx={{ mt: 2 }}>
            <QRCode value={`https://example.com/qr-link`} size={80} />
          </Box>
        </Box>
      </Box>
    </Box>
  );
};

export default VisitCard;