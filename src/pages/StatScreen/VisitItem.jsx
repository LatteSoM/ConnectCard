import { Avatar, Typography, Box } from '@mui/material';
import styled from 'styled-components';
import VisibilityIcon from '@mui/icons-material/Visibility';
import PersonAddIcon from '@mui/icons-material/PersonAdd';
import ShareIcon from '@mui/icons-material/Share';

const Container = styled(Box)`
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
  return (
    <Container>
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
          <Typography variant="body2">{views}</Typography>
        </StatItem>
        <Box sx={{ height: 5 }} />
        <StatItem>
          <PersonAddIcon sx={{ fontSize: 20 }} />
          <Typography variant="body2">{adds}</Typography>
        </StatItem>
        <Box sx={{ height: 5 }} />
        <StatItem>
          <ShareIcon sx={{ fontSize: 20 }} />
          <Typography variant="body2">{shares}</Typography>
        </StatItem>
      </Box>
    </Container>
  );
};

export default VisitItem;