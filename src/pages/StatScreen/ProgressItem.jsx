import { Typography, Box, LinearProgress } from '@mui/material';
import styled from 'styled-components';

const Container = styled(Box)`
  padding: 6px 0;
`;

const ProgressBar = styled(LinearProgress)`
  height: 12px;
  border-radius: 50px;
  background-color: #8f8888;

  .MuiLinearProgress-bar {
    border-radius: 50px;
    background-color: #fff;
  }
`;

const ProgressItem = ({ label, value, percent }) => {
  return (
    <Container>
      <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
        <Typography variant="body2" sx={{ fontWeight: 600, fontSize: 14 }}>
          {label}
        </Typography>
        <Typography variant="body2" sx={{ fontWeight: 600, fontSize: 14 }}>
          {value}
        </Typography>
      </Box>
      <Box sx={{ height: 4 }} />
      <ProgressBar variant="determinate" value={percent * 100} />
    </Container>
  );
};

export default ProgressItem;