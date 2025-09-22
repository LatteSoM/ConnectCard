import React, { useState } from "react";
import classes from "./Home.module.css";
import { ClockCircleOutlined } from '@ant-design/icons';
import { MenuOutlined, CloseOutlined } from '@ant-design/icons';
import logo from "../../assets/LogoNight.svg";
import ava from "../../assets/testusericon1.jpg"

const Home = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const toggleMenu = () => {
    setIsMenuOpen(!isMenuOpen);
  };

  const closeMenu = () => {
    setIsMenuOpen(false);
  };

  return (
    <div className={classes.container}>
      <header className={classes.header}>
        <div className={classes.headerInner}>
          <div className={classes.leftSide}>
            <MenuOutlined className={classes.burgerMenu} onClick={toggleMenu} />
            <div className={classes.headerLogo}>
              <img src={logo} alt="ConnectCard Logo" className={classes.logoImg} />
              <div>
                <h1 className={classes.logoTitle}>ConnectCard</h1>
                <p className={classes.logoSubtitle}>
                  Цифровые визитки для профессионального нетворкинга
                </p>
              </div>
            </div>
          </div>
          <nav className={classes.nav}>
            <a href="#features">Функции</a>
            <a href="#pricing">Тарифы</a>
            <a href="#mvp">MVP</a>
            <a href="#faq">FAQ</a>
            <button className={classes.buttonPrimary}>Войти</button>
          </nav>
        </div>
      </header>

      {/* Side Menu Overlay */}
      <div className={`${classes.overlay} ${isMenuOpen ? classes.show : ''}`} onClick={closeMenu}></div>

      {/* Side Menu */}
      <div className={`${classes.sideMenu} ${isMenuOpen ? classes.open : ''}`}>
        <div className={classes.sideMenuHeader}>
          <CloseOutlined className={classes.closeIcon} onClick={closeMenu} />
        </div>
        <nav className={classes.sideNav}>
          <a href="#features" onClick={closeMenu}>Функции</a>
          <a href="#pricing" onClick={closeMenu}>Тарифы</a>
          <a href="#mvp" onClick={closeMenu}>MVP</a>
          <a href="#faq" onClick={closeMenu}>FAQ</a>
        </nav>
      </div>

      <main className={classes.main}>
        <section className={classes.hero}>
          <div className={classes.heroText}>
            <h1 className={classes.sectionTitle}>
              Создавайте и обменивайтесь цифровыми визитками за 3 секунды
            </h1>
            <p className={classes.textGray}>
              ConnectCard — мобильное и веб-приложение для фрилансеров,
              предпринимателей и специалистов, которые ценят быстрый и современный
              нетворкинг на мероприятиях и конференциях.
            </p>

            <ul className={classes.checkboxList}>
              <li className={classes.checkboxItem}>
                <span className={classes.checkboxIcon}>✓</span>
                <span>
                  Создавайте кастомные визитки с фото, ссылками на портфолио и соцсети
                </span>
              </li>
              <li className={classes.checkboxItem}>
                <span className={classes.checkboxIcon}>✓</span>
                <span>Генерация QR-кода для мгновенного обмена контактом</span>
              </li>
              <li className={classes.checkboxItem}>
                <span className={classes.checkboxIcon}>✓</span>
                <span>Детальная статистика просмотров</span>
              </li>
            </ul>

            <div className={classes.heroButtons}>
              <a href="#signup" className={classes.buttonPrimary}>
                Попробовать бесплатно
              </a>
              <a href="#pricing" className={classes.buttonSecondary}>
                Перейти к тарифам
              </a>
            </div>

            <div className={classes.heroNote}>
              Идеально для конференций, митапов и бизнес-завтраков — быстрое добавление
              в контакты без бумажных визиток.
            </div>
          </div>

          <div className={classes.heroCard}>
            <div className={classes.card}>
              <div className={classes.cardHeader}>
                <div className={classes.avatar}>
                  <img src={ava} alt="avatar" />
                </div>
                <div className={classes.cardHeaderText}>
                  <h3>Иван Иванов</h3>
                  <p>Frontend-разработчик • Москва</p>
                </div>
              </div>

              <div className={classes.cardBody}>
                <div>
                  Портфолио:{" "}
                  <a className={classes.textPurple} href="#">
                    ivan.dev
                  </a>
                </div>
                <div>Email: ivan@dev.example</div>
                <div>Навыки: React, TypeScript, UI/UX</div>
              </div>
            </div>
          </div>
        </section>

        <section id="features" className={classes.section}>
          <h3 className={classes.sectionTitle}>Ключевые функции</h3>
          <div className={classes.grid3}>
            <div className={classes.card}>
              <h4 className={classes.textPurple}>Кастомизация</h4>
              <p className={classes.textGray}>
                Выбирайте шаблоны, добавляйте фото, цвета, иконки и создавайте визитку
                под ваш персональный бренд.
              </p>
            </div>
            <div className={classes.card}>
              <h4 className={classes.textPurple}>QR + Мгновенный обмен</h4>
              <p className={classes.textGray}>
                Генерируйте QR для перехода на профиль и отправляйте визитку в пару
                кликов.
              </p>
            </div>
            <div className={classes.card}>
              <h4 className={classes.textPurple}>Аналитика</h4>
              <p className={classes.textGray}>
                Смотрите, кто и где просматривает вашу визитку, какие ссылки кликают,
                и улучшайте представление.
              </p>
            </div>
          </div>
        </section>

        <section id="mvp" className={classes.section}>
          <h3 className={classes.sectionTitle}>MVP: мобильное приложение</h3>
          <p className={classes.textGray}>
            Первый релиз включает мобильное приложение на Flutter: сканирование QR,
            обмен визитками, просмотр профилей и базовая статистика. Все основные
            функции доступны бесплатно, премиум-дизайны и расширенная аналитика —
            платно.
          </p>

          <div className={classes.grid2}>
            <div className={classes.card}>
              <h4 className={classes.textPurple}>Что входит в MVP</h4>
              <ul className={classes.textGray}>
                <li>Создание и редактирование визитки</li>
                <li>Генерация QR и обмен контактами</li>
                <li>Сканер QR в приложении</li>
                <li>Объемная статистика просмотров</li>
              </ul>
            </div>
            <div className={classes.card}>
              <h4 className={classes.textPurple}>Технологии</h4>
              <ul className={classes.textGray}>
                <li>Backend: FastAPI </li>
                <li>Mobile: Flutter</li>
                <li>DB: PostgreSQL</li>
                <li>Хранение файлов: S3-совместимое хранилище</li>
              </ul>
            </div>
          </div>
        </section>

        <section id="pricing" className={classes.section}>
          <h3 className={classes.sectionTitle}>Тарифы</h3>
          <p className={classes.textGray}>
            Freemium-модель: базовые визитки бесплатно, платные функции для
            профессионалов.
          </p>

          <div className={classes.grid3}>
            <div className={classes.card}>
              <h4>Free</h4>
              <p className={classes.textGray}>
                Одна визитка, стандартный шаблон, QR-обмен
              </p>
              <div className={classes.price}>0 ₽</div>
              <ul className={classes.textGray}>
                <li>Основной функционал</li>
                <li>QR-генерация</li>
                <li>Добавление в контакты</li>
              </ul>
              {/* <br /> */}
              <button className={classes.buttonPrimary}>Начать бесплатно</button>
            </div>

            <div className={`${classes.card} ${classes.cardPro}`}>
              <h4>Pro</h4>
              <p className={classes.textGray}>
                Премиум-дизайны, 3 визитки, расширенная аналитика
              </p>
              <div className={classes.price}>199 ₽/мес</div>
              <ul className={classes.textGray}>
                <li>3 кастомные визитки</li>
                <li>Детальная аналитика</li>
                <li>Приоритетная поддержка</li>
              </ul>
              {/* <br /> */}
              <button className={classes.buttonPrimary}>Попробовать Pro</button>
            </div>

            <div className={classes.card}>
              <h4>Business</h4>
              <p className={classes.textGray}>
                Командный план для небольших команд и агентств
              </p>
              <div className={classes.price}>699 ₽/мес</div>
              <ul className={classes.textGray}>
                <li>До 10 визиток</li>
                <li>Командная аналитика</li>
                <li>Экспорт CSV</li>
              </ul>
              {/* <br /> */}
              <button className={classes.buttonSecondary}>
                Запросить для команды
              </button>
            </div>
          </div>
        </section>

        <section id="faq" className={classes.section}>
          <h3 className={classes.sectionTitle}>Часто задаваемые вопросы</h3>
          <div className={classes.faqList}>
            <details className={classes.card}>
              <summary className={classes.textPurple}>
                Как быстро сменить визитку на мероприятии?
              </summary>
              <p className={classes.textGray}>
                В мобильном приложении выберите нужную визитку и покажите QR —
                другой человек отсканирует и добавит ваши контакты.
              </p>
            </details>
            <details className={classes.card}>
              <summary className={classes.textPurple}>
                Безопасно ли хранить данные?
              </summary>
              <p className={classes.textGray}>
                Да. Мы используем защиту доступа через OAuth2. Защита 
                персональных данных пользователя в соответствии с Федеральным закон от 
                27 июля 2006 года № 149-ФЗ "Об информации, информационных технологиях 
                и о защите информации", и Федеральный закон от 27 июля 2006 года № 152-ФЗ "О персональных данных"
              </p>
            </details>
            <details className={classes.card}>
              <summary className={classes.textPurple}>
                Какая статистические данные доступны?
              </summary>
              <p className={classes.textGray}>
                Просматривайте подробные метрики по своей визитке: например статистика просмотров,
                по типу устройств, популярные действия, и статистика переходов по указанным ресурсам.
              </p>
            </details>
          </div>
        </section>

        <section id="roadmap" className={classes.section}>
          <h3 className={classes.sectionTitle}>Дорожная карта</h3>
          <p className={classes.textGray}>
            План развития ConnectCard: от запуска до полноценного релиза с фокусом на масштабируемость и пользовательский опыт.
          </p>
          <div className={classes.timelineContainer}>
            <div className={classes.timeline}>
              <div className={`${classes.timelineItem} ${classes.completed}`}>
                <div className={classes.timelineIcon}>
                  <span>✓</span>
                </div>
                <div className={classes.timelineContent}>
                  <h4>Старт проекта</h4>
                  <p>Июль 2025: Формирование команды и планирование MVP.</p>
                </div>
              </div>
              <div className={`${classes.timelineItem} ${classes.completed}`}>
                <div className={classes.timelineIcon}>
                  <span>✓</span>
                </div>
                <div className={classes.timelineContent}>
                  <h4>Разработка дизайна</h4>
                  <p>Июль 2025: UI/UX прототипы и брендинг.</p>
                </div>
              </div>
              <div className={`${classes.timelineItem} ${classes.completed}`}>
                <div className={classes.timelineIcon}>
                  <span>✓</span>
                </div>
                <div className={classes.timelineContent}>
                  <h4>Базовый API</h4>
                  <p>Август 2025: Backend на FastAPI с аутентификацией.</p>
                </div>
              </div>
              <div className={`${classes.timelineItem} ${classes.completed}`}>
                <div className={classes.timelineIcon}>
                  <span>✓</span>
                </div>
                <div className={classes.timelineContent}>
                  <h4>Мобильная версия (Flutter)</h4>
                  <p>Октябрь 2025: QR-сканер, обмен визитками, базовая аналитика.</p>
                </div>
              </div>
              <div className={`${classes.timelineItem} ${classes.completed}`}>
                <div className={classes.timelineIcon}>
                  <span>✓</span>
                </div>
                <div className={classes.timelineContent}>
                  <h4>Web версия</h4>
                  <p>Октябрь 2025: Дашборд для создания и управления визитками.</p>
                </div>
              </div>
              <div className={`${classes.timelineItem} ${classes.inProgress}`}>
                <ClockCircleOutlined className={classes.timelineIcon} style={{ fontSize: '24px' }} />
                <div className={classes.timelineContent}>
                  <h4>Деплой + тестирование</h4>
                  <p>Ноябрь 2025: CI/CD, бета-тестирование, фикс багов.</p>
                </div>
              </div>
              <div className={`${classes.timelineItem} ${classes.future}`}>
                <div className={classes.timelineIcon}>
                  <span>→</span>
                </div>
                <div className={classes.timelineContent}>
                  <h4>Выпуск MVP</h4>
                  <p>Декабрь 2025: Релиз на App Store/Google Play, freemium-модель.</p>
                </div>
              </div>
              <div className={`${classes.timelineItem} ${classes.future}`}>
                <div className={classes.timelineIcon}>
                  <span>→</span>
                </div>
                <div className={classes.timelineContent}>
                  <h4>Собрать обратную связь</h4>
                  <p>Январь 2026: Опросы, A/B-тесты, обновления на основе фидбека.</p>
                </div>
              </div>
              <div className={`${classes.timelineItem} ${classes.future}`}>
                <div className={classes.timelineIcon}>
                  <span>→</span>
                </div>
                <div className={classes.timelineContent}>
                  <h4>Доработка продукта</h4>
                  <p>Февраль–Март 2026: Интеграции CRM, расширенная аналитика, премиум-функции.</p>
                </div>
              </div>
              <div className={`${classes.timelineItem} ${classes.future}`}>
                <div className={classes.timelineIcon}>
                  <span>→</span>
                </div>
                <div className={classes.timelineContent}>
                  <h4>Релиз v1.0</h4>
                  <p>Апрель 2026: Полный запуск, маркетинг, партнерства.</p>
                </div>
              </div>
            </div>
          </div>
        </section>


        <section className={classes.cta}>
          <div className={classes.ctaInner}>
            <h3 className={classes.sectionTitle}>Готовы упростить нетворкинг?</h3>
            <p className={classes.textGray}>
              Создайте первую визитку за минуту и начните обмениваться контактами
              на следующем мероприятии.
            </p>
            <div className={classes.heroButtons}>
              <button className={classes.buttonPrimary}>
                Создать визитку
              </button>
              <a href="#pricing" className={classes.buttonSecondary}>
                К тарифам
              </a>
            </div>
            <p className={classes.textGraySmall}>
              Freemium — начните бесплатно, платите только за премиум-функции.
            </p>
          </div>
        </section>
      </main>

      <footer className={classes.footer}>
        <div className={classes.footerInner}>
          <div className={classes.footerLinks}>
            <div>© {new Date().getFullYear()} ConnectCard — Все права защищены</div>
            <a href="#">Политика конфиденциальности</a>
            <a href="#">Условия использования</a>
            <a href="#">Контакты</a>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default Home;
