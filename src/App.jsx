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

        <Route element={<MainLayout />}>
          <Route path="/" element={<Home />} />
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





// import { isValidElement, useEffect, useState } from 'react'
// import reactLogo from './assets/react.svg'
// import viteLogo from '/vite.svg'
// import './App.css'

// import { Breadcrumb, Layout, Menu, theme } from 'antd';

// const { Header, Content, Footer } = Layout;

// const items = Array.from({ length: 3 }).map((_, index) => ({
//   key: index + 1,
//   label: `nav ${index + 1}`,
// }));

// const headerItems = [{key: '1', label: 'Главная'}, {key: '2', label: 'Контакты'}, {key: '3', label: 'Мои визитки'}];



// const App = () => {
//   // const [count, setCount] = useState(0);

//   {/* <Header />
//     <main>
//       <div>
//         <span>
//           ето спан
//         </span>
//       </div>

//     </main>
//     <footer>
//       <div>
//         <span>
//           ето футер
//         </span>
//       </div>
//     </footer> */}

//   const {
//     token: { colorBgContainer, borderRadiusLG },
//   } = theme.useToken();


//   return (
//     <Layout>

//       <Header style={{ display: 'flex', alignItems: 'center',height: '3rem' }}>
//         <div className="demo-logo" />
//         <Menu
//           theme="dark"
//           mode="horizontal"
//           defaultSelectedKeys={['1']}
//           items={headerItems}
//           style={{ flex: 1, minWidth: 0,height: '100%', display: 'flex', alignItems: 'center',

//            }}
//         />
//       </Header>

//       <Content style={{ padding: '0 48px' }}>

//         <Breadcrumb
//           style={{ margin: '16px 0' }}
//           items={[{ title: 'Home' }, { title: 'List' }, { title: 'App' }]}
//         />

//         <div
//           style={{
//             background: colorBgContainer,
//             minHeight: 280,
//             padding: 24,
//             borderRadius: borderRadiusLG,
//             border: '1px solid #1B1A20',
//           }}
//         >
//           Тут типа будет чето контент там да катчественнный продукт так называемый
//         </div>
//       </Content>

//       <Footer style={{ textAlign: 'center' }}>
//         ConnectCard ©{new Date().getFullYear()}
//       </Footer>

//     </Layout>
//   );
// }

// export default App
