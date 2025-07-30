import { Layout } from 'antd';
import AppHeader from '../components/Header/Header';
import Breadcrumbs from '../components/Breadcrums';
import FooterCustom from '../components/Footer/Footer';
import { Outlet } from 'react-router-dom';
import './MainLayout.css'

const { Content } = Layout;

const MainLayout = () => {
  return (
    <Layout>
      <AppHeader />
      <Content style={{ padding: '0 48px' }}>
        <Breadcrumbs />

        <Outlet />

      </Content>
      <FooterCustom />
    </Layout>
  );
};

export default MainLayout;
