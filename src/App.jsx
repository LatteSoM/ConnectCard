import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';

import './App.css'

import MainLayout from './layouts/MainLayout';

import Home from './pages/HomePage/Home';
import Contacts from './pages/ContactsPage/Contacts';
import Cards from './pages/CardsPage/Cards.jsx';
import CardCreation from './pages/CardsPage/CardCreation.jsx';
import CardDetails from './pages/CardsPage/CardDetails.jsx';
import LoginPage from './pages/LoginPage/Login';
import Registration from './pages/RegistrationPage/Registration';
import User from './pages/UserPage/UserProfile'
import CurrentUserProfile from './pages/UserPage/CurrUserProfile.jsx';
import NotFound from './pages/Statuses/NotFoundPage/NotFound.jsx';
import StatScreen from './pages/StatScreen/StatScreen.jsx';
import TelegramAuthScreen from './components/TelegramAuthScreen.jsx';
import VkAuthScreen from './components/VkAuthScreen.jsx';
import WelcomeScreen from './components/WelcomeScreen.jsx';
import LoginScreen from './pages/LoginScreen/LoginScreen.jsx';
import RegistrationScreen from './pages/RegisterScreen/RegisterScreen.jsx';
import ProfileScreen from './pages/ProfilePage/ProfileScreen.jsx';
import SettingsScreen from './pages/SettingsScreen/SettingsScreen.jsx';
import VisitCardProfile from './pages/VisitCardProfile/VisitCardProfile.jsx';
import VisitCardDesigner from './pages/VisitCardDesigner/VisitCardDesigner.jsx';
import VisitCardsList from './pages/ListOfVisitCards/ListOfVisitCards.jsx';


const App = () => {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Home />} />

        <Route element={<MainLayout />}>
          {/* <Route path="/" element={<Home />} /> */}
          <Route path="/home" element={<Home />} />
          <Route path="/contacts" element={<Contacts />} />
          <Route path="/cards" element={<Cards />} />
          <Route path="/cards/creation" element={<CardCreation />} />
          <Route path="/users/card/:cardId" element={<CardDetails />} />
          <Route path="/users/:userId" element={<User />} />
          <Route path="/profile" element={<CurrentUserProfile />} />
          <Route path="/stat" element={<StatScreen />} />
          <Route path="/settings" element={<SettingsScreen />} />
          <Route path="/list_of_visit_cards" element={<VisitCardsList />} />

          {/* <Route path="/profile" element={<ProfileScreen />} /> */}
          <Route path="*" element={<NotFound />} />
        </Route>

        <Route path="/login" element={<LoginPage />} />
        <Route path="/card_profile" element={<VisitCardProfile />} />
        <Route path="/designer/:id" element={<VisitCardDesigner />} />
        {/* <Route path="/login" element={<LoginScreen />} /> */}
        <Route path="/registration" element={<Registration />} />
        {/* <Route path="/register" element={<RegistrationScreen />} /> */}


      </Routes>
    </Router>
  );
};

export default App;
