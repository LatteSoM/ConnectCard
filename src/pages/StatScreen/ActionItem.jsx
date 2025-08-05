import { Typography, Box } from '@mui/material';
import styled from 'styled-components';

const Container = styled(Box)`
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
`;

const ActionItem = ({ icon, title, percent }) => {
  return (
    <Container>
      {icon}
      <Typography variant="subtitle2" sx={{ fontWeight: 600, fontSize: 16 }}>
        {title}
      </Typography>
      <Typography variant="body2" sx={{ fontWeight: 600, fontSize: 14 }}>
        {percent}
      </Typography>
    </Container>
  );
};

export default ActionItem;