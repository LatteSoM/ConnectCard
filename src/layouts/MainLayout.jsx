import { Layout } from 'antd';
import Breadcrumbs from '../components/Breadcrums';
import { Outlet } from 'react-router-dom';
import BottomNav from '../components/BottomNav/BottomNav';
import './MainLayout.css';

const { Content } = Layout;

const MainLayout = () => {
  return (
    <Layout>
      <Content style={{ padding: '0 15px', marginBottom: '50px' }}>
        <Breadcrumbs />

        <Outlet />

      </Content>
      <BottomNav />
    </Layout>
  );
};

export default MainLayout;
