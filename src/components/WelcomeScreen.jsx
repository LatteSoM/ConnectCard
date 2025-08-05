import { Box, Typography } from '@mui/material';
import { useLocation } from 'react-router-dom';

const WelcomeScreen = () => {
  const { state } = useLocation();
  const userName = state?.userName || 'User';

  return (
    <Box sx={{ p: 3, color: '#fff', textAlign: 'center' }}>
      <Typography variant="h4">Добро пожаловать, {userName}!</Typography>
    </Box>
  );
};

export default WelcomeScreen;