import { Layout } from 'antd';
import classes from './Footer.module.css'

const { Footer } = Layout

const FooterCustom = () => {
    return (
        <>
        <Footer style={{ textAlign: 'center' }}>
            ConnectCard ©{new Date().getFullYear()}
        </Footer>
        </>
    );
}

export default FooterCustom;