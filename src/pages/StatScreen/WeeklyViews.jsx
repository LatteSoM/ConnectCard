
import { Card, Typography, Box } from '@mui/material';
import styled from 'styled-components';
import BarStat from './BarStat';
import { motion, useInView } from 'framer-motion';
import { useRef } from 'react';

const containerVariants = {
  hidden: {},
  visible: {
    transition: { staggerChildren: 0.1 }
  }
};

const StyledCard = styled(motion(Card))`
  background-color: #1e1e1e;
  padding: 16px;
`;

const Row = styled(motion(Box))`
  display: flex;
  justify-content: space-evenly;

  @media (max-width: 600px) {
    flex-wrap: wrap;
    gap: 8px;
  }
`;

const WeeklyViews = () => {
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
        Просмотры за неделю:
      </Typography>
      <Box sx={{ height: 12 }} />
      <Row
        variants={containerVariants}
        initial="hidden"
        animate={isInView ? "visible" : "hidden"}
      >
        <BarStat label="пн" heightFactor={0.6} />
        <BarStat label="вт" heightFactor={1.0} />
        <BarStat label="ср" heightFactor={0.5} />
        <BarStat label="чт" heightFactor={0.7} />
        <BarStat label="пт" heightFactor={0.9} />
        <BarStat label="сб" heightFactor={0.8} />
        <BarStat label="вс" heightFactor={0.3} />
      </Row>
    </StyledCard>
  );
};

export default WeeklyViews;