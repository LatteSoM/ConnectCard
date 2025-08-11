// import { Typography, Box, LinearProgress } from '@mui/material';
// import styled from 'styled-components';

// const Container = styled(Box)`
//   padding: 6px 0;
// `;

// const ProgressBar = styled(LinearProgress)`
//   height: 12px;
//   border-radius: 50px;
//   background-color: #8f8888;

//   .MuiLinearProgress-bar {
//     border-radius: 50px;
//     background-color: #fff;
//   }
// `;

// const ProgressItem = ({ label, value, percent }) => {
//   return (
//     <Container>
//       <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
//         <Typography variant="body2" sx={{ fontWeight: 600, fontSize: 14 }}>
//           {label}
//         </Typography>
//         <Typography variant="body2" sx={{ fontWeight: 600, fontSize: 14 }}>
//           {value}
//         </Typography>
//       </Box>
//       <Box sx={{ height: 4 }} />
//       <ProgressBar variant="determinate" value={percent * 100} />
//     </Container>
//   );
// };

// export default ProgressItem;


// import { Typography, Box, LinearProgress } from '@mui/material';
// import styled from 'styled-components';
// import { motion } from 'framer-motion';
// import CountUp from 'react-countup';

// const Container = styled(Box)`
//   padding: 6px 0;
// `;

// const ProgressBar = styled(motion(LinearProgress))`
//   height: 12px;
//   border-radius: 50px;
//   background-color: #8f8888;

//   .MuiLinearProgress-bar {
//     border-radius: 50px;
//     background-color: #fff;
//   }
// `;

// const ProgressItem = ({ label, value, percent, isInView }) => {
//   return (
//     <Container>
//       <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
//         <Typography variant="body2" sx={{ fontWeight: 600, fontSize: 14 }}>
//           {label}
//         </Typography>
//         <Typography variant="body2" sx={{ fontWeight: 600, fontSize: 14 }}>
//           {isInView ? <CountUp end={value} duration={1} /> : 0}
//         </Typography>
//       </Box>
//       <Box sx={{ height: 4 }} />
//       <ProgressBar
//         variant="determinate"
//         value={0}
//         initial={{ value: 0 }}
//         animate={isInView ? { value: percent * 100 } : { value: 0 }}
//         transition={{ duration: 1, ease: 'easeOut' }}
//       />
//     </Container>
//   );
// };

// export default ProgressItem;


import { Typography, Box } from '@mui/material';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import CountUp from 'react-countup';

const Container = styled(Box)`
  padding: 6px 0;
`;

const ProgressWrapper = styled(Box)`
  height: 12px;
  border-radius: 50px;
  background-color: #8f8888;
  overflow: hidden;
`;

const ProgressBar = styled(motion.div)`
  height: 100%;
  background-color: #fff;
  border-radius: 50px;
`;

const ProgressItem = ({ label, value, percent, isInView }) => {
  return (
    <Container>
      <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
        <Typography variant="body2" sx={{ fontWeight: 600, fontSize: 14 }}>
          {label}
        </Typography>
        <Typography variant="body2" sx={{ fontWeight: 600, fontSize: 14 }}>
          {isInView ? <CountUp end={value} duration={1} /> : 0}
        </Typography>
      </Box>
      <Box sx={{ height: 4 }} />
      <ProgressWrapper>
        <ProgressBar
          initial={{ width: 0 }}
          animate={isInView ? { width: `${percent * 100}%` } : { width: 0 }}
          transition={{ duration: 1, ease: 'easeOut' }}
        />
      </ProgressWrapper>
    </Container>
  );
};

export default ProgressItem;