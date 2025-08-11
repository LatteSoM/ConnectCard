
import { Avatar, Typography, Box } from '@mui/material';
import styled from 'styled-components';
import VisibilityIcon from '@mui/icons-material/Visibility';
import PersonAddIcon from '@mui/icons-material/PersonAdd';
import ShareIcon from '@mui/icons-material/Share';
import { motion, useInView } from 'framer-motion';
import { useRef } from 'react';
import CountUp from 'react-countup';

const Container = styled(motion(Box))`
  display: flex;
  align-items: center;
  padding: 16px;

  @media (max-width: 600px) {
    flex-direction: column;
    align-items: flex-start;
  }
`;

const VerticalDivider = styled(Box)`
  width: 1px;
  height: 60px;
  background-color: #fff;

  @media (max-width: 600px) {
    width: 100%;
    height: 1px;
    margin: 8px 0;
  }
`;

const StatItem = styled(Box)`
  display: flex;
  align-items: center;
  gap: 11px;
`;

const VisitItem = ({ image, name, position, company, views, adds, shares }) => {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, threshold: 0.1 });

  return (
    <Container
      ref={ref}
      initial={{ opacity: 0, y: 20 }}
      animate={isInView ? { opacity: 1, y: 0 } : { opacity: 0, y: 20 }}
      transition={{ duration: 0.6, ease: 'easeOut' }}
    >
      <Avatar sx={{ width: 66, height: 66 }} />
      <Box sx={{ width: 16 }} />
      <Box>
        <Typography variant="subtitle1" sx={{ fontWeight: 'bold', fontSize: 16 }}>
          {name}
        </Typography>
        <Typography variant="body2" sx={{ fontWeight: 300, fontSize: 12 }}>
          {position}
        </Typography>
        <Typography variant="body2" sx={{ fontWeight: 300, fontSize: 12 }}>
          {company}
        </Typography>
      </Box>
      <Box sx={{ width: 16 }} />
      <VerticalDivider />
      <Box sx={{ width: 16 }} />
      <Box>
        <StatItem>
          <VisibilityIcon sx={{ fontSize: 20 }} />
          <Typography variant="body2">
            {isInView ? <CountUp end={views} duration={0.8} delay={0} /> : 0}
          </Typography>
        </StatItem>
        <Box sx={{ height: 5 }} />
        <StatItem>
          <PersonAddIcon sx={{ fontSize: 20 }} />
          <Typography variant="body2">
            {isInView ? <CountUp end={adds} duration={0.8} delay={0.4} /> : 0}
          </Typography>
        </StatItem>
        <Box sx={{ height: 5 }} />
        <StatItem>
          <ShareIcon sx={{ fontSize: 20 }} />
          <Typography variant="body2">
            {isInView ? <CountUp end={shares} duration={0.8} delay={0.8} /> : 0}
          </Typography>
        </StatItem>
      </Box>
    </Container>
  );
};

export default VisitItem;