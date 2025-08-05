import { Typography, Box } from '@mui/material';

const IconStat = ({ icon, value }) => {
  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
      {icon}
      <Box sx={{ height: 4 }} />
      <Typography variant="body2">{value}</Typography>
    </Box>
  );
};

export default IconStat;
