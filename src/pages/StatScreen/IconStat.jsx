import { Typography, Box } from '@mui/material';
import { motion, useInView } from 'framer-motion';
import { useRef } from 'react';

const IconStat = ({ icon, value }) => {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, threshold: 0.1 });

  return (
    <motion.div
      ref={ref}
      initial={{ scale: 0.8 }}
      animate={isInView ? { scale: 1 } : { scale: 0.8 }}
      transition={{ duration: 0.4, ease: 'easeOut' }}
      whileTap={{ scale: 0.9 }}
      sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}
    >
      {icon}
      <Box sx={{ height: 4 }} />
      <Typography variant="body2">{value}</Typography>
    </motion.div>
  );
};

export default IconStat;
