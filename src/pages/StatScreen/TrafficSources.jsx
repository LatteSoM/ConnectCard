// import { Card, Typography, Box } from '@mui/material';
// import styled from 'styled-components';
// import ProgressItem from './ProgressItem';
// import { motion, useInView } from 'framer-motion';
// import { useRef } from 'react';

// const StyledCard = styled(motion(Card))`
//   background-color: #1e1e1e;
//   padding: 16px;
// `;

// const TrafficSources = () => {
//   const ref = useRef(null);
//   const isInView = useInView(ref, { once: true, threshold: 0.1 });

//   return (
//     <StyledCard
//       ref={ref}
//       initial={{ opacity: 0, y: 20 }}
//       animate={isInView ? { opacity: 1, y: 0 } : { opacity: 0, y: 20 }}
//       transition={{ duration: 0.5, ease: 'easeOut' }}
//     >
//       <Typography variant="subtitle1" sx={{ fontWeight: 600, fontSize: 16 }}>
//         Источники трафика:
//       </Typography>
//       <Box sx={{ height: 12 }} />
//       <ProgressItem label="Прямые переходы" value={551} percent={0.5} isInView={isInView} />
//       <ProgressItem label="QR-коды" value={782} percent={0.75} isInView={isInView} />
//       <ProgressItem label="Другое" value={144} percent={0.2} isInView={isInView} />
//     </StyledCard>
//   );
// };

// export default TrafficSources;


import { Card, Typography, Box } from '@mui/material';
import styled from 'styled-components';
import ProgressItem from './ProgressItem';
import { motion, useInView } from 'framer-motion';
import { useRef } from 'react';

const StyledCard = styled(motion(Card))`
  background-color: #1e1e1e;
  padding: 16px;
`;

const TrafficSources = () => {
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
        Источники трафика:
      </Typography>
      <Box sx={{ height: 12 }} />
      <ProgressItem label="Прямые переходы" value={551} percent={0.5} isInView={isInView} />
      <ProgressItem label="QR-коды" value={782} percent={0.75} isInView={isInView} />
      <ProgressItem label="Другое" value={144} percent={0.2} isInView={isInView} />
    </StyledCard>
  );
};

export default TrafficSources;