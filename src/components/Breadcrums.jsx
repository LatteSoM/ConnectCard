import { Breadcrumb } from 'antd';
import { Link, useLocation } from 'react-router-dom';

const Breadcrumbs = () => {
  const location = useLocation();
  const pathSnippets = location.pathname.split('/').filter(i => i);

  const breadcrumbItems = [
    {
      title: <Link to="/">Главная</Link>,
    },
    ...pathSnippets.map((_, index) => {
      const url = '/' + pathSnippets.slice(0, index + 1).join('/');
      const label = decodeURIComponent(pathSnippets[index]);

      return {
        title: <Link to={url}>{label.charAt(0).toUpperCase() + label.slice(1)}</Link>,
      };
    }),
  ];

  return <Breadcrumb style={{ margin: '16px 0' }} items={breadcrumbItems} />;
};

export default Breadcrumbs;