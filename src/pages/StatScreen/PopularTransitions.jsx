import { Card, Typography, Box } from '@mui/material';
import styled from 'styled-components';
import { FaTelegram, FaLinkedin, FaGithub } from 'react-icons/fa';
import IconStat from './IconStat';
import { motion, useInView } from 'framer-motion';
import { useRef } from 'react';
import CountUp from 'react-countup';

const StyledCard = styled(motion(Card))`
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
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, threshold: 0.1 });

  return (
    <StyledCard
      ref={ref}
      initial={{ opacity: 0, y: 20 }}
      animate={isInView ? { opacity: 1, y: 0 } : { opacity: 0, y: 20 }}
      transition={{ duration: 0.5, ease: 'easeOut' }}
    >
      <Typography variant="subtitle1" sx={{ fontWeight: 600, fontSize: 16 }}>
        Популярные переходы:
      </Typography>
      <Box sx={{ height: 12 }} />
      <Row>
        <IconStat icon={<FaTelegram size={32} />} value={isInView ? <CountUp end={1112} duration={1} /> : 0} />
        <VerticalDivider />
        <IconStat icon={<FaLinkedin size={32} />} value={isInView ? <CountUp end={511} duration={1} /> : 0} />
        <VerticalDivider />
        <IconStat icon={<FaGithub size={32} />} value={isInView ? <CountUp end={92} duration={1} /> : 0} />
      </Row>
    </StyledCard>
  );
};

export default PopularTransitions;
