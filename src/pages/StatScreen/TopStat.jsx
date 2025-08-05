import { Card, Box } from '@mui/material';
import styled from 'styled-components';
import StatColumn from './StatColumn';

const StyledCard = styled(Card)`
  background-color: #1e1e1e;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  padding: 12px;

  @media (max-width: 600px) {
    flex-direction: row;
    align-items: center;
  }
`;

const VerticalDivider = styled(Box)`
  width: 1px;
  height: 60px;
  background-color: #616161;

  @media (max-width: 600px) {
    width: 1px;
    height: 60px;
    margin: 8px 0;
  }
`;

const TopStats = () => {
  return (
    <StyledCard>
      <StatColumn title="Просмотры" value="1112" sub="+112 с прошлой недели" subColor="#4CAF50" />
      <VerticalDivider />
      <StatColumn title="Репосты" value="511" sub="+53 с прошлой недели" subColor="#4CAF50" />
      <VerticalDivider />
      <StatColumn title="Конверсия" value="2.8%" sub="-0.5%" subColor="#F44336" />
    </StyledCard>
  );
};

export default TopStats;