import { Card, Typography, Box, Divider } from '@mui/material';
import styled from 'styled-components';
import ActionItem from './ActionItem';
import VisibilityIcon from '@mui/icons-material/Visibility';
import PersonAddIcon from '@mui/icons-material/PersonAdd';
import ShareIcon from '@mui/icons-material/Share';
import { motion, useInView } from 'framer-motion';
import { useRef } from 'react';

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.15, delayChildren: 0.3 }
  }
};

const childVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease: 'easeOut' } }
};

const StyledCard = styled(motion(Card))`
  background-color: #1e1e1e;
  padding: 16px;
`;

const TopActions = () => {
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
        Топ действий:
      </Typography>
      <Box sx={{ height: 12 }} />
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate={isInView ? "visible" : "hidden"}
      >
        <motion.div variants={childVariants}>
          <ActionItem icon={<VisibilityIcon sx={{ fontSize: 32 }} />} title="Просмотры" percent="78%" />
        </motion.div>
        <motion.div variants={childVariants}>
          <Divider sx={{ my: 1, bgcolor: '#fff', mx: 1 }} />
        </motion.div>
        <motion.div variants={childVariants}>
          <ActionItem icon={<PersonAddIcon sx={{ fontSize: 32 }} />} title="Добавление в контакты" percent="55%" />
        </motion.div>
        <motion.div variants={childVariants}>
          <Divider sx={{ my: 1, bgcolor: '#fff', mx: 1 }} />
        </motion.div>
        <motion.div variants={childVariants}>
          <ActionItem icon={<ShareIcon sx={{ fontSize: 32 }} />} title="Поделиться" percent="34%" />
        </motion.div>
      </motion.div>
    </StyledCard>
  );
};

export default TopActions;
