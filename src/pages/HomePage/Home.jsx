// import classes from './Home.module.css';

// const Home = () => (
//     <div className={classes.container}>

//         <h1>ЭТОТ КРИНЖ ПЕРЕДЕЛАЮ</h1>
//         <h1 className={classes.heading}>🎯 Что такое ConnectCard и зачем мы его создаём?</h1>

//         <p className={classes.paragraph}>
//             В современном мире бумажные визитки теряют актуальность. Люди всё чаще знакомятся и обмениваются контактами на мероприятиях, в коворкингах, на конференциях — и делают это через смартфоны.
//             Обычные способы — Telegram, LinkedIn, Instagram — работают, но обмениваться каждым контактом по отдельности бывает долго и неудобно.
//             Хочется решения, где достаточно отсканировать один QR-код, чтобы сразу поделиться всеми своими контактами и ссылками в одном месте.
//         </p>

//         <h2 className={classes.subheading}>💡 ConnectCard — это платформа для создания персонализированных цифровых визиток с акцентом на профессиональный нетворкинг.</h2>

//         <h3 className={classes.listTitle}>✅ Что умеет ConnectCard:</h3>
//         <ul className={classes.list}>
//             <li>📇 Создание визиток с фото, ссылками, навыками и контактами.</li>
//             <li>➤ Создавайте визитку с уникальным дизайном или выбирайте из готовых шаблонов.</li>
//             <li>➤ Сохраняйте чужие визитки, добавляя их в свои контакты.</li>
//             <li>📲 QR-код для обмена контактами в одно касание.</li>
//             <li>📍 Поиск людей по событиям и геолокации.</li>
//             <li>🔔 Интеграция с Telegram для мгновенного обмена и уведомлений.</li>
//         </ul>

//         <h3 className={classes.listTitle}>🇷🇺 Почему именно для российского рынка:</h3>
//         <ul className={classes.list}>
//             <li>➤ Растущая культура нетворкинга среди фрилансеров и предпринимателей.</li>
//             <li>➤ Устаревание бумажных визиток и отсутствие локальных удобных решений.</li>
//             <li>➤ Упор на простоту и быструю связь именно в профессиональной среде.</li>
//         </ul>

//         <p className={classes.paragraph}>
//             🤝 <strong>Цель ConnectCard</strong> — упростить обмен контактами и дать людям инструмент для реального, живого общения на мероприятиях и в бизнесе.
//         </p>

//         <p className={classes.paragraph}>
//             💬 Оставляйте обратную связь прямо в комментариях — нам важно ваше мнение!
//         </p>

//         <h3 className={classes.listTitle}>🎯 Анализ конкурентов:</h3>
//         <ul className={classes.list}>
//             <li>➤ ❗ Ориентированы на корпоративных клиентов.</li>
//             <li>➤ 🎨 Нет возможности создавать уникальный стиль самостоятельно.</li>
//             <li>➤ 📱 Приложения устаревшие и неудобные, интерфейс не интуитивный.</li>
//         </ul>

//         <h3 className={classes.listTitle}>✅ Что предлагает ConnectCard:</h3>
//         <ul className={classes.list}>
//             <li>➤ 🎨 Полная свобода дизайна.</li>
//             <li>➤ 📁 Несколько визиток.</li>
//             <li>➤ 📲 Современный UX.</li>
//             <li>➤ 🔄 Сохранение контактов.</li>
//             <li>➤ 📍 Поиск по событиям.</li>
//             <li>➤ 💡 Гибкость и независимость.</li>
//         </ul>

//         <p className={classes.highlight}>
//             🌐 <strong>ConnectCard</strong> — это не просто электронная визитка. Это инструмент, который сочетает дизайн, удобство, мобильность и свободу — именно то, чего так не хватает на рынке РФ.
//         </p>
//     </div>
// );


// import { Grid, Typography, Box } from '@mui/material';
// import { motion } from 'framer-motion';
// import { Link } from 'react-router-dom';
// import { UserOutlined, QrcodeOutlined, TeamOutlined, GlobalOutlined } from '@ant-design/icons';
// import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
// import { faAddressCard, faClipboardList, faPalette, faSave, faSearch } from '@fortawesome/free-solid-svg-icons';
// import MyButton from '../../components/Button/Button.jsx';
// import classes from './Home.module.css';

// // Responsive font size function
// const responsiveFontSize = (minSize, maxSize, vwFactor) => {
//   return `clamp(${minSize}px, ${vwFactor}vw, ${maxSize}px)`;
// };

// // Animation variants for stagger effect
// const containerVariants = {
//   hidden: { opacity: 0 },
//   visible: {
//     opacity: 1,
//     transition: { staggerChildren: 0.2, delayChildren: 0.3 },
//   },
// };

// const childVariants = {
//   hidden: { opacity: 0, y: 20 },
//   visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease: 'easeOut' } },
// };

// const Home = () => (
//   <div className={classes.wrapper}>
//     <motion.div
//       initial={{ opacity: 0, y: 50 }}
//       animate={{ opacity: 1, y: 0 }}
//       transition={{ duration: 0.8 }}
//       className={classes.hero}
//     >
//       <div className={classes.titleBlock}>
//         <div className={classes.titleBlockLogo}>
//           <img src="/src/assets/LogoNight.svg" alt="ConnectCard Logo" />
//         </div>
//         <div className={classes.titleBlockText}>
//           <div className={classes.title}>
//             Connect<span>Card</span>
//           </div>
//           <div className={classes.subtitle}>Ваши связи — в одном касании</div>
//         </div>
//       </div>
//       <Typography
//         variant="body1"
//         sx={{
//           fontSize: responsiveFontSize(14, 16, 1.5),
//           maxWidth: '600px',
//           margin: '0 auto',
//           color: '#fff',
//           opacity: 0.9,
//           mb: 3,
//         }}
//       >
//         Создавайте стильные цифровые визитки нового поколения и делитесь контактами через QR-код. Идеально для нетворкинга и бизнеса.
//       </Typography>
//       <motion.div whileHover={{ scale: 1.05 }} whileTap={{ scale: 0.95 }}>
//         <MyButton variant="primary" href="/register">
//           Создать визитку
//         </MyButton>
//       </motion.div>
//     </motion.div>

//     <motion.div variants={containerVariants} initial="hidden" animate="visible">
//       <Grid container spacing={3} justifyContent="center">
//         <Grid item xs={12} md={6}>
//           <motion.div variants={childVariants} className={classes.card}>
//             <Typography
//               sx={{
//                 fontWeight: 600,
//                 fontSize: responsiveFontSize(18, 24, 2),
//                 mb: 2,
//               }}
//             >
//               Возможности ConnectCard
//             </Typography>
//             <ul className={classes.list}>
//               <li><UserOutlined className={classes.icon} /> Персонализированные визитки</li>
//               <li><QrcodeOutlined className={classes.icon} /> Мгновенный обмен QR-кодом</li>
//               <li><TeamOutlined className={classes.icon} /> Поиск по событиям</li>
//             </ul>
//           </motion.div>
//         </Grid>
//         <Grid item xs={12} md={6}>
//           <motion.div variants={childVariants} className={classes.card}>
//             <Typography
//               sx={{
//                 fontWeight: 600,
//                 fontSize: responsiveFontSize(18, 24, 2),
//                 mb: 2,
//               }}
//             >
//               Почему мы?
//             </Typography>
//             <ul className={classes.list}>
//               <li><GlobalOutlined className={classes.icon} /> Для российского рынка</li>
//               <li><FontAwesomeIcon icon={faPalette} className={classes.icon} /> Свобода дизайна</li>
//               <li><FontAwesomeIcon icon={faSave} className={classes.icon} /> Легкое сохранение</li>
//             </ul>
//           </motion.div>
//         </Grid>
//       </Grid>
              
//       <motion.div variants={childVariants} className={classes.card} sx={{ mt: 3 }}>
//         <Typography
//           sx={{
//             fontWeight: 600,
//             fontSize: responsiveFontSize(18, 24, 2),
//             mb: 2,
//             textAlign: 'center',
//           }}
//         >
//           Наше преимущество
//         </Typography>
//         <Grid container spacing={2} justifyContent="center">
//           <Grid item xs={12} sm={6}>
//             <Typography
//               sx={{
//                 fontWeight: 500,
//                 fontSize: responsiveFontSize(16, 18, 1.8),
//                 mb: 1,
//               }}
//             >
//               Конкуренты
//             </Typography>
//             <ul className={classes.list}>
//               <li>❌ Ограниченный дизайн</li>
//               <li>❌ Корпаративный фокус</li>
//               <li>❌ Устаревший UX</li>
//             </ul>
//           </Grid>
//           <Grid item xs={12} sm={6}>
//             <Typography
//               sx={{
//                 fontWeight: 500,
//                 fontSize: responsiveFontSize(16, 18, 1.8),
//                 mb: 1,
//               }}
//             >
//               ConnectCard
//             </Typography>
//             <ul className={classes.list}>
//               <li><FontAwesomeIcon icon={faPalette} className={classes.icon} /> Кастомизация</li>
//               <li><FontAwesomeIcon icon={faSearch} className={classes.icon} /> Интуитивный интерфейс</li>
//               <li><FontAwesomeIcon icon={faAddressCard} className={classes.icon} /> Множество визиток</li>
//             </ul>
//           </Grid>
//         </Grid>
//       </motion.div>

//       <motion.div
//         variants={childVariants}
//         sx={{ textAlign: 'center', mt: 3 }}
//       >
//         <Typography
//           sx={{
//             fontSize: responsiveFontSize(14, 16, 1.5),
//             color: '#fff',
//             opacity: 0.9,
//             mb: 2,
//           }}
//         >
//           Помогите нам стать лучше — поделитесь идеями!
//         </Typography>
//         <motion.div whileHover={{ scale: 1.05 }} whileTap={{ scale: 0.95 }}>
//           <MyButton variant="primary" href="/feedback">
//             Оставить отзыв
//           </MyButton>
//         </motion.div>
//       </motion.div>
//     </motion.div>
//   </div>
// );

// export default Home;

import { Grid, Typography, Box } from '@mui/material';
import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';
import { UserOutlined, QrcodeOutlined, TeamOutlined, GlobalOutlined } from '@ant-design/icons';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faAddressCard, faDisplay, faPalette, faSave, faSearch } from '@fortawesome/free-solid-svg-icons';
import MyButton from '../../components/Button/Button.jsx';
import classes from './Home.module.css';

// Responsive font size function
const responsiveFontSize = (minSize, maxSize, vwFactor) => {
  return `clamp(${minSize}px, ${vwFactor}vw, ${maxSize}px)`;
};

// Animation variants
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.2, delayChildren: 0.3 },
  },
};

const childVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease: 'easeOut' } },
};

const Home = () => (
  <div className={classes.wrapper}>
    <motion.div
      initial={{ opacity: 0, y: 50 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.8 }}
      className={classes.hero}
    >
      <div className={classes.titleBlock}>
        <div className={classes.titleBlockLogo}>
          <img src="/src/assets/LogoNight.svg" alt="ConnectCard Logo" />
        </div>
        <div className={classes.titleBlockText}>
          <div className={classes.title}>
            Connect<span>Card</span>
          </div>
          <div className={classes.subtitle}>Ваши связи — в одном касании</div>
        </div>
      </div>
      <Typography
        sx={{
          fontSize: responsiveFontSize(14, 16, 1.5),
          maxWidth: '600px',
          margin: '0 auto',
          color: '#fff',
          opacity: 0.8,
          mb: 4,
        }}
      >
        Создавайте уникальные цифровые визитки нового поколения и делитесь контактами мгновенно через QR-код. Ваш инструмент для профессионального нетворкинга.
      </Typography>
      <motion.div className={classes.ctaContainer}>
        <motion.div whileHover={{ scale: 1.05 }} whileTap={{ scale: 0.95 }}>
          <MyButton variant="primary" href="/registration">
            <Link to="/registration" className="link">Создать визитку</Link>
          </MyButton>
        </motion.div>
        {/* <motion.div whileHover={{ scale: 1.05 }} whileTap={{ scale: 0.95 }}>
          <MyButton variant="primary" href="/login">
            Войти
          </MyButton>
        </motion.div> */}
      </motion.div>
    </motion.div>

    <motion.div variants={containerVariants} initial="hidden" animate="visible">
      <Grid container spacing={3} justifyContent="center">
        <Grid item xs={12} md={6}>
          <motion.div variants={childVariants} className={classes.card}>
            <Typography
              sx={{
                fontWeight: 600,
                fontSize: responsiveFontSize(18, 24, 2),
                mb: 2,
              }}
            >
              Возможности ConnectCard
            </Typography>
            <ul className={classes.list}>
              <li><UserOutlined className={classes.icon} /> Стильные визитки с вашим дизайном</li>
              <li><QrcodeOutlined className={classes.icon} /> Обмен контактами через QR-код</li>
              <li><TeamOutlined className={classes.icon} /> Поиск по событиям и локациям</li>
            </ul>
          </motion.div>
        </Grid>
        <Grid item xs={12} md={6}>
          <motion.div variants={childVariants} className={classes.card}>
            <Typography
              sx={{
                fontWeight: 600,
                fontSize: responsiveFontSize(18, 24, 2),
                mb: 2,
              }}
            >
              Почему выбирают нас
            </Typography>
            <ul className={classes.list}>
              <li><GlobalOutlined className={classes.icon} /> Создано для России</li>
              <li><FontAwesomeIcon icon={faPalette} className={classes.icon} /> Полная кастомизация</li>
              <li><FontAwesomeIcon icon={faSave} className={classes.icon} /> Сохранение контактов</li>
            </ul>
          </motion.div>
        </Grid>
      </Grid>

      <Grid container spacing={3} justifyContent="center" sx={{ mt: 3 }}>
        <Grid item xs={12}>
          <motion.div variants={childVariants} className={classes.card}>
            <Typography
              sx={{
                fontWeight: 600,
                fontSize: responsiveFontSize(18, 24, 2),
                mb: 2,
                textAlign: 'center',
              }}
            >
              Отличия от других
            </Typography>
            <Grid container spacing={2} justifyContent="center">
              <Grid item xs={12} sm={6}>
                <Typography
                  sx={{
                    fontWeight: 500,
                    fontSize: responsiveFontSize(16, 18, 1.8),
                    mb: 1,
                  }}
                >
                  <div className={classes.title}>
                        Конкуренты:
                    </div>
                </Typography>
                <ul className={classes.list}>
                  <li>❌ Ограниченный дизайн</li>
                  <li>❌ Корпоративнфй фокус</li>
                  <li>❌ Устаревший интерфейс</li>
                </ul>
              </Grid>
              <Grid item xs={12} sm={6}>
                <Typography
                  sx={{
                    fontWeight: 500,
                    fontSize: responsiveFontSize(16, 18, 1.8),
                    mb: 1,
                  }}
                >
                <div className={classes.title}>
                    Connect<span>Card</span>:
                </div>
                </Typography>
                <ul className={classes.list}>
                  <li><FontAwesomeIcon icon={faPalette} className={classes.icon} /> Свобода дизайна</li>
                  <li><FontAwesomeIcon icon={faAddressCard} className={classes.icon} /> Множество визиток</li>
                  <li><FontAwesomeIcon icon={faSearch} className={classes.icon} /> Интуитивный интерфейс</li>

                </ul>
              </Grid>
            </Grid>
          </motion.div>
        </Grid>
      </Grid>

    
      <motion.div variants={childVariants} sx={{ textAlign: 'center', mt: 3,  }}>
        <motion.div className={classes.ctaContainer}>
          <motion.div whileHover={{ scale: 1.05 }} whileTap={{ scale: 0.95 }}>
          <Typography
            sx={{
            fontSize: responsiveFontSize(14, 16, 1.5),
            maxWidth: '600px',
            margin: '0 auto',
            color: '#fff',
            opacity: 0.8,
            mb: 4,
            }}
        >
            Станьте частью будущего нетворкинга — начните сейчас!
        </Typography>

            <MyButton variant="primary" href="/registration">
                <Link to="/registration" className="link">Попробовать бесплатно</Link>
            </MyButton>
          </motion.div>
        </motion.div>
      </motion.div>
    </motion.div>
  </div>
);

export default Home;