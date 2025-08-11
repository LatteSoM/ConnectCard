
import { IconButton, Typography, Box } from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import styled from 'styled-components';
import TopStats from './TopStat';
import PopularTransitions from './PopularTransitions';
import DeviceUsage from './DeviceUsage';
import WeeklyViews from './WeeklyViews';
import TrafficSources from './TrafficSources';
import TopActions from './TopActions';
import VisitStat from './VisitStat';

const Container = styled(Box)`
  padding: 16px;
  width: 100%;
  align-items:center;
  max-width: 1200px; /* Limit width on desktop */
  margin: 0 auto;
  box-sizing: border-box;

  @media (max-width: 600px) {
    padding: 8px; /* Reduced padding on mobile */
  }
`;

const BackButtonContainer = styled(Box)`
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: rgba(156, 39, 176, 0.2); /* PurpleAccent with opacity */
  border-radius: 50%;
  width: 40px;
  height: 40px;
`;

const StatScreen = () => {
  return (
    <Container>
      {/* <Box sx={{ backgroundColor: '#000', color: '#fff', padding: '16px' }}>
            <Typography variant="h5">Тестовый текст</Typography>
        </Box> */}
      {/* <BackButtonContainer>
        <IconButton sx={{ color: '#9C27B0' }}>
          <ArrowBackIcon />
        </IconButton>
      </BackButtonContainer> */}
      <Typography variant="h5" align="center" sx={{ fontWeight: 'bold', mt: 2 }}>
        Аналитика
      </Typography>
      <Box sx={{ mt: 3 }}>
        <TopStats />
      </Box>
      <Box sx={{ mt: 2 }}>
        <PopularTransitions />
      </Box>
      <Box sx={{ mt: 2 }}>
        <DeviceUsage />
      </Box>
      <Box sx={{ mt: 2 }}>
        <WeeklyViews />
      </Box>
      <Box sx={{ mt: 2 }}>
        <TrafficSources />
      </Box>
      <Box sx={{ mt: 2 }}>
        <TopActions />
      </Box>
      <Box sx={{ mt: 2 }}>
        <VisitStat />
      </Box>
    </Container>
  );
};

export default StatScreen;