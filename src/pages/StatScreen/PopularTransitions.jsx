import { Card, Typography, Box } from '@mui/material';
import styled from 'styled-components';
import { FaTelegram, FaLinkedin, FaGithub } from 'react-icons/fa';
import IconStat from './IconStat';

const StyledCard = styled(Card)`
  background-color: #1e1e1e;
  padding: 16px;
`;

const Row = styled(Box)`
  display: flex;
  justify-content: space-around;

  @media (max-width: 600px) {
    flex-direction: row;
    align-items: center;
    gap: 16px;
  }
`;

const VerticalDivider = styled(Box)`
  width: 1px;
  height: 60px;
  background-color: #616161;

  @media (max-width: 600px) {
    display: none;
  }
`;

const PopularTransitions = () => {
  return (
    <StyledCard>
      <Typography variant="subtitle1" sx={{ fontWeight: 600, fontSize: 16 }}>
        Популярные переходы:
      </Typography>
      <Box sx={{ height: 12 }} />
      <Row>
        <IconStat icon={<FaTelegram size={32} />} value="1112" />
        <VerticalDivider />
        <IconStat icon={<FaLinkedin size={32} />} value="511" />
        <VerticalDivider />
        <IconStat icon={<FaGithub size={32} />} value="92" />
      </Row>
    </StyledCard>
  );
};

export default PopularTransitions;
