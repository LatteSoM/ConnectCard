import { Card, Typography, Box } from '@mui/material';
import styled from 'styled-components';
import ProgressItem from './ProgressItem';

const StyledCard = styled(Card)`
  background-color: #1e1e1e;
  padding: 16px;
`;

const DeviceUsage = () => {
  return (
    <StyledCard>
      <Typography variant="subtitle1" sx={{ fontWeight: 600, fontSize: 16 }}>
        Устройства:
      </Typography>
      <Box sx={{ height: 12 }} />
      <ProgressItem label="Мобильные" value={1148} percent={1.0} />
      <ProgressItem label="Десктоп" value={548} percent={0.6} />
      <ProgressItem label="Планшеты" value={144} percent={0.2} />
    </StyledCard>
  );
};

export default DeviceUsage;