import { Card, Box } from '@mui/material';
import styled from 'styled-components';
import VisitItem from './VisitItem';
import { motion } from 'framer-motion';

const StyledCard = styled(motion(Card))`
  background-color: #1e1e1e;
  padding: 16px;
`;

const VisitStat = () => {
  return (
    <StyledCard>
      <Box sx={{ fontWeight: 600, fontSize: 16 }}>
        Статистика по визитке
      </Box>
      <Box sx={{ height: 12 }} />
      <VisitItem
        image="image"
        name="Барак Обама"
        position="Старший кассир"
        company="ООО KFC"
        views={551}
        adds={782}
        shares={144}
      />
    </StyledCard>
  );
};

export default VisitStat;