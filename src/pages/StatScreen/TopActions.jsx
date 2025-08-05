import { Card, Typography, Box, Divider } from '@mui/material';
import styled from 'styled-components';
import ActionItem from './ActionItem';
import VisibilityIcon from '@mui/icons-material/Visibility';
import PersonAddIcon from '@mui/icons-material/PersonAdd';
import ShareIcon from '@mui/icons-material/Share';

const StyledCard = styled(Card)`
  background-color: #1e1e1e;
  padding: 16px;
`;

const TopActions = () => {
  return (
    <StyledCard>
      <Typography variant="subtitle1" sx={{ fontWeight: 600, fontSize: 16 }}>
        Топ действий:
      </Typography>
      <Box sx={{ height: 12 }} />
      <ActionItem icon={<VisibilityIcon sx={{ fontSize: 32 }} />} title="Просмотры" percent="78%" />
      <Divider sx={{ my: 1, bgcolor: '#fff', mx: 1 }} />
      <ActionItem icon={<PersonAddIcon sx={{ fontSize: 32 }} />} title="Добавление в контакты" percent="55%" />
      <Divider sx={{ my: 1, bgcolor: '#fff', mx: 1 }} />
      <ActionItem icon={<ShareIcon sx={{ fontSize: 32 }} />} title="Поделиться" percent="34%" />
    </StyledCard>
  );
};

export default TopActions;