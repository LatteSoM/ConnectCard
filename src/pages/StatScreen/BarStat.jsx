import { Typography, Box } from '@mui/material';
import styled from 'styled-components';

const Bar = styled(Box)`
  width: 20px;
  height: ${props => props.height * 100}px;
  background-color: #fff;
  border-radius: 4px;
`;

const Container = styled(Box)`
  display: flex;
  flex-direction: column;
  align-items: center;
`;

const BarStat = ({ label, heightFactor }) => {
  return (
    <Container>
      <Box sx={{ height: 100, display: 'flex', alignItems: 'flex-end' }}>
        <Bar height={heightFactor} />
      </Box>
      <Box sx={{ height: 8 }} />
      <Typography variant="caption" sx={{ width: 24, textAlign: 'center', fontSize: 12 }}>
        {label}
      </Typography>
    </Container>
  );
};

export default BarStat;