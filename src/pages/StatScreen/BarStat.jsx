import { Typography, Box } from '@mui/material';
import styled from 'styled-components';
import { motion, useInView } from 'framer-motion';
import { useRef } from 'react';

const Bar = styled(motion.div)`
  width: 20px;
  background-color: #fff;
  border-radius: 4px;
`;

const Container = styled(Box)`
  display: flex;
  flex-direction: column;
  align-items: center;
`;

const BarStat = ({ label, heightFactor }) => {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, threshold: 0.1 });

  return (
    <Container ref={ref}>
      <Box sx={{ height: 100, display: 'flex', alignItems: 'flex-end' }}>
        <Bar
          initial={{ height: 0 }}
          animate={isInView ? { height: heightFactor * 100 } : { height: 0 }}
          transition={{ duration: 0.5, ease: 'easeOut' }}
        />
      </Box>
      <Box sx={{ height: 8 }} />
      <Typography variant="caption" sx={{ width: 24, textAlign: 'center', fontSize: 12 }}>
        {label}
      </Typography>
    </Container>
  );
};

export default BarStat;