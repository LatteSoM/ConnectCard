import React from "react";
import classes from "./Home.module.css";

const Home = () => (
  <div className={classes.container}>
    <header className={classes.header}>
      <div className={classes.headerInner}>
        <div className={classes.headerLeft}>
          <div className={classes.logoBox}>CC</div>
          <div>
            <h1 className={classes.logoTitle}>ConnectCard</h1>
            <p className={classes.logoSubtitle}>
              Цифровые визитки для профессионального нетворкинга
            </p>
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
              <span>Статистика просмотров и интеграции с CRM</span>
            </li>
          </ul>

          <div className={classes.heroButtons}>
            <a href="#signup" className={classes.buttonPrimary}>
              Попробовать бесплатно
            </a>
            <a href="#pricing" className={classes.buttonSecondary}>
              Смотреть <br /> тарифы
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
                <img src="https://via.placeholder.com/64" alt="avatar" />
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

            <div className={classes.cardFooter}>
              <div>QR для обмена</div>
              <div className={classes.qrBox}>QR</div>
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
              <li>Генерация QR и обмен</li>
              <li>Сканер QR в приложении</li>
              <li>Простая статистика просмотров</li>
            </ul>
          </div>
          <div className={classes.card}>
            <h4 className={classes.textPurple}>Технологии</h4>
            <ul className={classes.textGray}>
              <li>Backend: FastAPI + Django (авторизация)</li>
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
              Да. В MVP мы храним минимальные данные, используем шифрование на
              уровне хранилища и защиту доступа через OAuth2.
            </p>
          </details>
          <details className={classes.card}>
            <summary className={classes.textPurple}>
              Можно ли интегрироваться с CRM?
            </summary>
            <p className={classes.textGray}>
              Да — через API можно экспортировать контакты и события в любую CRM
              систему.
            </p>
          </details>
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
            <a id="signup" className={classes.buttonPrimary}>
              Создать <br /> визитку
            </a>
            <a href="#pricing" className={classes.buttonSecondary}>
              Посмотреть тарифы
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
        <div>© {new Date().getFullYear()} ConnectCard — Все права защищены</div>
        <div className={classes.footerLinks}>
          <a href="#">Политика конфиденциальности</a>
          <a href="#">Условия использования</a>
          <a href="#">Контакты</a>
        </div>
      </div>
    </footer>
  </div>
);

export default Home;
