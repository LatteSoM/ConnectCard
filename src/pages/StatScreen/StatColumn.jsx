import { Typography, Box } from '@mui/material';
import styled from 'styled-components';

const Container = styled(Box)`
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 0 8px;

  @media (max-width: 600px) {
    width: 100%;
    padding: 8px 0;
  }
`;

const StatColumn = ({ title, value, sub, subColor }) => {
  return (
    <Container>
      <Typography variant="subtitle1" sx={{ fontWeight: 600, fontSize: 16 }}>
        {title}
      </Typography>
      <Box sx={{ height: 8 }} />
      <Typography variant="body1" sx={{ fontWeight: 600, fontSize: 14 }}>
        {value}
      </Typography>
      <Box sx={{ height: 4 }} />
      <Typography variant="caption" sx={{ color: subColor, fontSize: 8 }}>
        {sub}
      </Typography>
    </Container>
  );
};

export default StatColumn;
