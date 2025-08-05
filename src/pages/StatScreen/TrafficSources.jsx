import { Card, Typography, Box } from '@mui/material';
import styled from 'styled-components';
import ProgressItem from './ProgressItem';

const StyledCard = styled(Card)`
  background-color: #1e1e1e;
  padding: 16px;
`;

const TrafficSources = () => {
  return (
    <StyledCard>
      <Typography variant="subtitle1" sx={{ fontWeight: 600, fontSize: 16 }}>
        Источники трафика:
      </Typography>
      <Box sx={{ height: 12 }} />
      <ProgressItem label="Прямые переходы" value={551} percent={0.5} />
      <ProgressItem label="QR-коды" value={782} percent={0.75} />
      <ProgressItem label="Другое" value={144} percent={0.2} />
    </StyledCard>
  );
};

export default TrafficSources;
