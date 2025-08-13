// import { useState, useEffect, useRef } from 'react';
// import { useNavigate } from 'react-router-dom';
// import { Box, TextField, Button, Grid, Typography, IconButton, Avatar, FormControl, InputLabel, Select, MenuItem } from '@mui/material';
// import { ArrowBack, Edit, Close, CameraAlt, Check, EmailOutlined, Phone, Language } from '@mui/icons-material';
// import { UserOutlined, QrcodeOutlined, TeamOutlined } from '@ant-design/icons';
// import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
// import { faTelegram, faLinkedin, faGithub, faTwitter } from '@fortawesome/free-brands-svg-icons';
// import { faBuilding } from '@fortawesome/free-solid-svg-icons';
// import { toast } from 'react-toastify';
// import InputMask from 'react-input-mask';
// import classes from './VisitCardProfile.module.css';

// const ContactInfo = {
//   email: null,
//   phone: null,
//   website: null,
//   isEmpty: () => !ContactInfo.email && !ContactInfo.phone && !ContactInfo.website,
//   toContactList: () => {
//     const contacts = [];
//     const addContact = (body, platform) => {
//       if (body) contacts.push({ icon: platform.toLowerCase(), name: platform, description: body });
//     };
//     addContact(ContactInfo.email, 'email');
//     addContact(ContactInfo.phone, 'phone');
//     addContact(ContactInfo.website, 'website');
//     return contacts;
//   },
// };

// const SocialMedia = {
//   telegram: null,
//   linkedin: null,
//   github: null,
//   twitter: null,
//   isEmpty: () => !SocialMedia.telegram && !SocialMedia.linkedin && !SocialMedia.github && !SocialMedia.twitter,
//   toWidgetsList: () => {
//     const widgets = [];
//     const addWidget = (url, platform) => {
//       if (url) widgets.push({ link: url, icon: platform.toLowerCase(), description: `${platform} профиль`, name: platform });
//     };
//     addWidget(SocialMedia.telegram, 'Telegram');
//     addWidget(SocialMedia.linkedin, 'LinkedIn');
//     addWidget(SocialMedia.github, 'GitHub');
//     addWidget(SocialMedia.twitter, 'Twitter');
//     return widgets;
//   },
// };

// const VisitCardProfile = () => {
//   const [isEditing, setIsEditing] = useState(false);
//   const [showQrCode, setShowQrCode] = useState(false);
//   const [showAddMainInfo, setShowAddMainInfo] = useState(false);
//   const [showAddSocialMedia, setShowAddSocialMedia] = useState(false);
//   const [selectedInfoType, setSelectedInfoType] = useState(null);
//   const [selectedSocialMediaType, setSelectedSocialMediaType] = useState(null);
//   const [name, setName] = useState('');
//   const [position, setPosition] = useState('Старший кассир');
//   const [company, setCompany] = useState('ООО "KFC"');
//   const [about, setAbout] = useState('Просто чиловый парень');
//   const [contactInfo, setContactInfo] = useState(ContactInfo);
//   const [socialMedia, setSocialMedia] = useState(SocialMedia);
//   const [mainInfoInput, setMainInfoInput] = useState('');
//   const [socialMediaInput, setSocialMediaInput] = useState('');
//   const [errors, setErrors] = useState({});
//   const socialFormRef = useRef(null);
//   const navigate = useNavigate();

//   const baseUrl = 'http://127.0.0.1:8002';

//   useEffect(() => {
//     const loadInfo = async () => {
//       const id = localStorage.getItem('id');
//       const token = localStorage.getItem('token');
//       try {
//         const response = await fetch(`${baseUrl}/users/${id}`, {
//           headers: { 'Authorization': `Bearer ${token}` },
//         });
//         if (response.ok) {
//           const data = await response.json();
//           setName(data.name);
//           setContactInfo({ ...contactInfo, email: data.email, phone: data.phone });
//         } else {
//           toast.error('Извините, произошла ошибка');
//         }
//       } catch {
//         toast.error('Извините, произошла ошибка');
//       }
//     };
//     loadInfo();
//   }, []);

//   const saveData = async () => {
//     const token = localStorage.getItem('token');
//     const headers = {
//       'Authorization': `Bearer ${token}`,
//       'Content-Type': 'application/json',
//     };

//     try {
//       const contactsResponse = await fetch(`${baseUrl}/contact-info/bulk`, {
//         method: 'POST',
//         headers,
//         body: JSON.stringify({ contacts: contactInfo.toContactList() }),
//       });
//       const widgetsResponse = await fetch(`${baseUrl}/link-widgets/bulk`, {
//         method: 'POST',
//         headers,
//         body: JSON.stringify({ widgets: socialMedia.toWidgetsList() }),
//       });
//       const cardResponse = await fetch(`${baseUrl}/cards/`, {
//         method: 'POST',
//         headers,
//         body: JSON.stringify({
//           fullname: name.trim(),
//           company: company.trim(),
//           position: position.trim(),
//           about: about.trim(),
//           contact_info_ids: (await contactsResponse.json()).map(c => c.id),
//           link_widget_ids: (await widgetsResponse.json()).map(w => w.id),
//         }),
//       });

//       if (cardResponse.ok) {
//         toast.success('Визитка создана', {
//           action: { label: 'К списку', onClick: () => navigate('/') },
//         });
//         setIsEditing(false);
//       } else {
//         toast.error('Ошибка при сохранении');
//       }
//     } catch (e) {
//       toast.error('Ошибка сети');
//     }
//   };

//   const validateMainInput = (value) => {
//     if (!value) return 'Введите информацию';
//     if (selectedInfoType === 'email') {
//       if (!/^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+$/.test(value)) {
//         return 'Введите корректный email';
//       }
//     }
//     if (selectedInfoType === 'phone') {
//       if (!/^\+7\s\(\d{3}\)\s\d{3}-\d{2}-\d{2}$/.test(value)) {
//         return 'Введите корректный номер телефона';
//       }
//     }
//     if (selectedInfoType === 'website') {
//       try {
//         new URL(value);
//       } catch {
//         return 'Введите корректный URL';
//       }
//     }
//     return null;
//   };

//   const handleMainInfoChange = (e) => {
//     const value = e.target.value;
//     setMainInfoInput(value);
//     setErrors({ ...errors, mainInfo: validateMainInput(value) });
//     if (selectedInfoType === 'phone' && !value.startsWith('+7')) {
//       setMainInfoInput('+7');
//     } else if (selectedInfoType === 'website' && !value.startsWith('https://')) {
//       setMainInfoInput('https://');
//     }
//   };

//   const handleSocialMediaChange = (e) => {
//     const value = e.target.value;
//     setSocialMediaInput(value);
//     setErrors({ ...errors, socialMedia: value ? null : 'Введите ссылку' });
//     if (selectedSocialMediaType === 'telegram' && !value.startsWith('@')) {
//       setSocialMediaInput('@');
//     } else if (selectedSocialMediaType === 'github' && !value.startsWith('https://github.com/')) {
//       setSocialMediaInput('https://github.com/');
//     }
//   };

//   const addMainInfo = () => {
//     if (!mainInfoInput || errors.mainInfo) return;
//     setContactInfo({
//       ...contactInfo,
//       [selectedInfoType]: mainInfoInput,
//     });
//     setMainInfoInput('');
//     setShowAddMainInfo(false);
//     setSelectedInfoType(null);
//   };

//   const addSocialMedia = () => {
//     if (!socialMediaInput || errors.socialMedia) return;
//     setSocialMedia({
//       ...socialMedia,
//       [selectedSocialMediaType]: socialMediaInput,
//     });
//     setSocialMediaInput('');
//     setShowAddSocialMedia(false);
//     setSelectedSocialMediaType(null);
//     if (socialFormRef.current) {
//       socialFormRef.current.scrollIntoView({ behavior: 'smooth' });
//     }
//   };

//   const removeMainInfo = (type) => {
//     setContactInfo({ ...contactInfo, [type]: null });
//   };

//   const removeSocialMedia = (type) => {
//     setSocialMedia({ ...socialMedia, [type]: null });
//   };

//   const availableMainInfoTypes = [
//     ...(contactInfo.email ? [] : ['email']),
//     ...(contactInfo.phone ? [] : ['phone']),
//     ...(contactInfo.website ? [] : ['website']),
//   ];

//   const availableSocialMediaTypes = [
//     ...(socialMedia.telegram ? [] : ['telegram']),
//     ...(socialMedia.linkedin ? [] : ['linkedin']),
//     ...(socialMedia.github ? [] : ['github']),
//     ...(socialMedia.twitter ? [] : ['twitter']),
//   ];

//   const InfoCard = ({ icon, title, subtitle, fullWidth, onDelete }) => (
//     <div className={`${classes.card} ${fullWidth ? classes.cardFullWidth : classes.cardHalfWidth}`}>
//       {icon}
//       <Box sx={{ ml: 2, flex: 1 }}>
//         <Typography sx={{ fontSize: 12, fontWeight: 'bold', color: '#fff' }}>{title}</Typography>
//         <Typography sx={{ fontSize: 10, color: '#989898' }}>{subtitle}</Typography>
//       </Box>
//       {isEditing && onDelete && (
//         <IconButton className={classes.deleteButton} onClick={onDelete}>
//           <Close fontSize="small" sx={{ color: '#fff' }} />
//         </IconButton>
//       )}
//     </div>
//   );


// const AddInfoForm = ({ types, onTypeSelected, onAddPressed, onCancel, value, setValue, isSocial }) => {
//     return (
//       <>
//         <Select
//           onChange={(e) => {
//             onTypeSelected(e.target.value);
//             setValue(''); // очищаем поле при смене типа
//           }}
//         >
//           {types.map((type) => (
//             <MenuItem key={type} value={type}>{type}</MenuItem>
//           ))}
//         </Select>
  
//         <TextField
//           fullWidth
//           value={value}
//           onChange={(e) => {
//             setValue(e.target.value);
//             if (isSocial) {
//               handleSocialMediaChange(e);
//             } else {
//               handleMainInfoChange(e);
//             }
//           }}
//         />
  
//         <Button onClick={onAddPressed}>Добавить</Button>
//         <Button onClick={onCancel}>Отмена</Button>
//       </>
//     );
//   };


//   return (
//     <div className={classes.wrapper}>
//       <div className={classes.header}>
//         <IconButton className={classes.backButton} onClick={() => navigate(-1)}>
//           <ArrowBack sx={{ color: '#9C27B0' }} />
//         </IconButton>
//         <Box>
//           {isEditing && (
//             <IconButton onClick={() => setIsEditing(false)} sx={{ mr: 1 }}>
//               <Close sx={{ color: 'red' }} />
//             </IconButton>
//           )}
//           <IconButton onClick={() => {
//             if (isEditing) saveData();
//             setIsEditing(!isEditing);
//           }}>
//             {isEditing ? <Check /> : <Edit />}
//           </IconButton>
//         </Box>
//       </div>

//       <div className={classes.avatarContainer}>
//         <Avatar src="https://example.com/your-avatar.jpg" sx={{ width: 96, height: 96 }} />
//         {isEditing && (
//           <div className={classes.avatarOverlay}>
//             <CameraAlt sx={{ color: '#fff', fontSize: 28 }} />
//           </div>
//         )}
//       </div>

//       <TextField
//         fullWidth
//         value={name}
//         onChange={(e) => setName(e.target.value)}
//         disabled={!isEditing}
//         sx={{
//           '.MuiInputBase-input': { color: '#fff', fontSize: 18, fontWeight: 'bold', textAlign: 'center' },
//           '.MuiInputBase-root': { '& fieldset': { border: 'none' } },
//         }}
//       />

//       <TextField
//         fullWidth
//         value={position}
//         onChange={(e) => setPosition(e.target.value)}
//         disabled={!isEditing}
//         sx={{
//           '.MuiInputBase-input': { color: '#fff', fontSize: 14, fontWeight: 200, textAlign: 'center' },
//           '.MuiInputBase-root': { '& fieldset': { border: 'none' } },
//         }}
//       />

//       <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', mt: 1 }}>
//         <FontAwesomeIcon icon={faBuilding} style={{ color: '#fff', fontSize: 24, marginRight: 5 }} />
//         <TextField
//           value={company}
//           onChange={(e) => setCompany(e.target.value)}
//           disabled={!isEditing}
//           sx={{
//             '.MuiInputBase-input': { color: '#fff', fontSize: 14, fontWeight: 200 },
//             '.MuiInputBase-root': { '& fieldset': { border: 'none' } },
//           }}
//         />
//       </Box>

//       <TextField
//         fullWidth
//         value={about}
//         onChange={(e) => setAbout(e.target.value)}
//         disabled={!isEditing}
//         sx={{
//           '.MuiInputBase-input': { color: '#fff', fontSize: 14, fontWeight: 200, textAlign: 'center', mt: 2 },
//           '.MuiInputBase-root': { '& fieldset': { border: 'none' } },
//         }}
//       />

//       <Typography className={classes.sectionTitle}>Связаться со мной</Typography>
//       <Box className={classes.cardContainer}>
//         {contactInfo.email && (
//           <InfoCard
//             icon={<EmailOutlined sx={{ color: '#fff', fontSize: 32 }} />}
//             title="Email"
//             subtitle={contactInfo.email}
//             fullWidth
//             onDelete={() => removeMainInfo('email')}
//           />
//         )}
//         {contactInfo.phone && (
//           <InfoCard
//             icon={<Phone sx={{ color: '#fff', fontSize: 32 }} />}
//             title="Телефон"
//             subtitle={contactInfo.phone}
//             fullWidth
//             onDelete={() => removeMainInfo('phone')}
//           />
//         )}
//         {contactInfo.website && (
//           <InfoCard
//             icon={<Language sx={{ color: '#fff', fontSize: 32 }} />}
//             title="Сайт"
//             subtitle={contactInfo.website}
//             fullWidth
//             onDelete={() => removeMainInfo('website')}
//           />
//         )}
//         {isEditing && availableMainInfoTypes.length > 0 && (
//           <Button
//             fullWidth
//             className={classes.addButton}
//             onClick={() => setShowAddMainInfo(true)}
//           >
//             Добавить основную информацию
//           </Button>
//         )}
//         {showAddMainInfo && (
//             <AddInfoForm
//                 types={availableMainInfoTypes}
//                 onTypeSelected={setSelectedInfoType}
//                 onAddPressed={addMainInfo}
//                 onCancel={() => setShowAddMainInfo(false)}
//                 value={mainInfoInput}
//                 setValue={setMainInfoInput}
//             />
//         )}
//       </Box>

//       <Typography className={classes.sectionTitle}>Социальные сети</Typography>
//       <Box className={classes.cardContainer}>
//         {socialMedia.telegram && (
//           <InfoCard
//             icon={<FontAwesomeIcon icon={faTelegram} className={classes.icon} />}
//             title="Telegram"
//             subtitle={socialMedia.telegram}
//             onDelete={() => removeSocialMedia('telegram')}
//           />
//         )}
//         {socialMedia.linkedin && (
//           <InfoCard
//             icon={<FontAwesomeIcon icon={faLinkedin} className={classes.icon} />}
//             title="LinkedIn"
//             subtitle={socialMedia.linkedin}
//             onDelete={() => removeSocialMedia('linkedin')}
//           />
//         )}
//         {socialMedia.github && (
//           <InfoCard
//             icon={<FontAwesomeIcon icon={faGithub} className={classes.icon} />}
//             title="GitHub"
//             subtitle={socialMedia.github}
//             onDelete={() => removeSocialMedia('github')}
//           />
//         )}
//         {socialMedia.twitter && (
//           <InfoCard
//             icon={<FontAwesomeIcon icon={faTwitter} className={classes.icon} />}
//             title="Twitter"
//             subtitle={socialMedia.twitter}
//             onDelete={() => removeSocialMedia('twitter')}
//           />
//         )}
//         {isEditing && availableSocialMediaTypes.length > 0 && (
//           <Button
//             fullWidth
//             className={classes.addButton}
//             onClick={() => {
//               setShowAddSocialMedia(true);
//               setTimeout(() => socialFormRef.current?.scrollIntoView({ behavior: 'smooth' }), 0);
//             }}
//           >
//             Добавить социальную сеть
//           </Button>
//         )}
//         {showAddSocialMedia && (
//             <AddInfoForm
//                 types={availableSocialMediaTypes}
//                 onTypeSelected={setSelectedSocialMediaType}
//                 onAddPressed={addSocialMedia}
//                 onCancel={() => setShowAddSocialMedia(false)}
//                 value={socialMediaInput}
//                 setValue={setSocialMediaInput}
//                 isSocial
//             />
//         )}
//       </Box>

//       <IconButton className={classes.qrButton} onClick={() => setShowQrCode(!showQrCode)}>
//         <QrcodeOutlined style={{ color: '#fff', fontSize: 24 }} />
//       </IconButton>
//       {showQrCode && (
//         <Box className={classes.qrCode}>
//           <Typography sx={{ color: '#fff' }}>QR-код (заглушка)</Typography>
//         </Box>
//       )}
//     </div>
//   );
// };

// export default VisitCardProfile;

// import { useState, useEffect, useRef } from 'react';
// import { useNavigate } from 'react-router-dom';
// import { Box, TextField, Button, Typography, IconButton, Avatar, Select, MenuItem } from '@mui/material';
// import { ArrowBack, Edit, Close, CameraAlt, Check, EmailOutlined, Phone, Language } from '@mui/icons-material';
// import { QrcodeOutlined } from '@ant-design/icons';
// import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
// import { faTelegram, faLinkedin, faGithub, faTwitter} from '@fortawesome/free-brands-svg-icons';
// import { faBuilding as faBuildingSolid } from '@fortawesome/free-solid-svg-icons';
// import { toast } from 'react-toastify';
// import InputMask from 'react-input-mask';
// import classes from './VisitCardProfile.module.css';

// const ContactInfo = {
//   email: null,
//   phone: null,
//   website: null,
//   isEmpty: () => !ContactInfo.email && !ContactInfo.phone && !ContactInfo.website,
//   toContactList: () => {
//     const contacts = [];
//     const addContact = (body, platform) => {
//       if (body) contacts.push({ icon: platform.toLowerCase(), name: platform, description: body });
//     };
//     addContact(ContactInfo.email, 'email');
//     addContact(ContactInfo.phone, 'phone');
//     addContact(ContactInfo.website, 'website');
//     return contacts;
//   },
// };

// const SocialMedia = {
//   telegram: null,
//   linkedin: null,
//   github: null,
//   twitter: null,
//   isEmpty: () => !SocialMedia.telegram && !SocialMedia.linkedin && !SocialMedia.github && !SocialMedia.twitter,
//   toWidgetsList: () => {
//     const widgets = [];
//     const addWidget = (url, platform) => {
//       if (url) widgets.push({ link: url, icon: platform.toLowerCase(), description: `${platform} профиль`, name: platform });
//     };
//     addWidget(SocialMedia.telegram, 'Telegram');
//     addWidget(SocialMedia.linkedin, 'LinkedIn');
//     addWidget(SocialMedia.github, 'GitHub');
//     addWidget(SocialMedia.twitter, 'Twitter');
//     return widgets;
//   },
// };

// const getIconForType = (type, isSocial = false) => {
//   const iconStyle = { color: '#fff', fontSize: 24, marginRight: 8 };
//   if (!isSocial) {
//     switch (type) {
//       case 'email': return <EmailOutlined sx={iconStyle} />;
//       case 'phone': return <Phone sx={iconStyle} />;
//       case 'website': return <Language sx={iconStyle} />;
//       default: return null;
//     }
//   } else {
//     switch (type) {
//       case 'telegram': return <FontAwesomeIcon icon={faTelegram} style={iconStyle} />;
//       case 'linkedin': return <FontAwesomeIcon icon={faLinkedin} style={iconStyle} />;
//       case 'github': return <FontAwesomeIcon icon={faGithub} style={iconStyle} />;
//       case 'twitter': return <FontAwesomeIcon icon={faTwitter} style={iconStyle} />;
//       default: return null;
//     }
//   }
// };

// const VisitCardProfile = () => {
//   const [isEditing, setIsEditing] = useState(false);
//   const [showQrCode, setShowQrCode] = useState(false);
//   const [showAddMainInfo, setShowAddMainInfo] = useState(false);
//   const [showAddSocialMedia, setShowAddSocialMedia] = useState(false);
//   const [selectedInfoType, setSelectedInfoType] = useState(null);
//   const [selectedSocialMediaType, setSelectedSocialMediaType] = useState(null);
//   const [name, setName] = useState('');
//   const [position, setPosition] = useState('Старший кассир');
//   const [company, setCompany] = useState('ООО "KFC"');
//   const [about, setAbout] = useState('Просто чиловый парень');
//   const [contactInfo, setContactInfo] = useState(ContactInfo);
//   const [socialMedia, setSocialMedia] = useState(SocialMedia);
//   const [mainInfoInput, setMainInfoInput] = useState('');
//   const [socialMediaInput, setSocialMediaInput] = useState('');
//   const [errors, setErrors] = useState({});
//   const socialFormRef = useRef(null);
//   const navigate = useNavigate();

//   const baseUrl = 'http://127.0.0.1:8002';

//   useEffect(() => {
//     const loadInfo = async () => {
//       const id = localStorage.getItem('id');
//       const token = localStorage.getItem('token');
//       try {
//         const response = await fetch(`${baseUrl}/users/${id}`, {
//           headers: { 'Authorization': `Bearer ${token}` },
//         });
//         if (response.ok) {
//           const data = await response.json();
//           setName(data.name);
//           setContactInfo({ ...contactInfo, email: data.email, phone: data.phone });
//         } else {
//           toast.error('Извините, произошла ошибка');
//         }
//       } catch {
//         toast.error('Извините, произошла ошибка');
//       }
//     };
//     loadInfo();
//   }, []);

//   const saveData = async () => {
//     const token = localStorage.getItem('token');
//     const headers = {
//       'Authorization': `Bearer ${token}`,
//       'Content-Type': 'application/json',
//     };

//     try {
//       const contactsResponse = await fetch(`${baseUrl}/contact-info/bulk`, {
//         method: 'POST',
//         headers,
//         body: JSON.stringify({ contacts: contactInfo.toContactList() }),
//       });
//       const widgetsResponse = await fetch(`${baseUrl}/link-widgets/bulk`, {
//         method: 'POST',
//         headers,
//         body: JSON.stringify({ widgets: socialMedia.toWidgetsList() }),
//       });
//       const cardResponse = await fetch(`${baseUrl}/cards/`, {
//         method: 'POST',
//         headers,
//         body: JSON.stringify({
//           fullname: name.trim(),
//           company: company.trim(),
//           position: position.trim(),
//           about: about.trim(),
//           contact_info_ids: (await contactsResponse.json()).map(c => c.id),
//           link_widget_ids: (await widgetsResponse.json()).map(w => w.id),
//         }),
//       });

//       if (cardResponse.ok) {
//         toast.success('Визитка создана', {
//           action: { label: 'К списку', onClick: () => navigate('/') },
//         });
//         setIsEditing(false);
//       } else {
//         toast.error('Ошибка при сохранении');
//       }
//     } catch (e) {
//       toast.error('Ошибка сети');
//     }
//   };

//   const validateMainInput = (value) => {
//     if (!value) return 'Введите информацию';
//     if (selectedInfoType === 'email') {
//       if (!/^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+$/.test(value)) {
//         return 'Введите корректный email';
//       }
//     }
//     if (selectedInfoType === 'phone') {
//       if (!/^\+7\s\(\d{3}\)\s\d{3}-\d{2}-\d{2}$/.test(value)) {
//         return 'Введите корректный номер телефона';
//       }
//     }
//     if (selectedInfoType === 'website') {
//       try {
//         new URL(value);
//       } catch {
//         return 'Введите корректный URL';
//       }
//     }
//     return null;
//   };

//   const validateSocialInput = (value) => {
//     if (!value) return 'Введите ссылку';
//     // Базовая валидация для соцсетей
//     if (selectedSocialMediaType === 'telegram' && !value.startsWith('@')) {
//       return 'Telegram должен начинаться с @';
//     }
//     if (['linkedin', 'github', 'twitter'].includes(selectedSocialMediaType)) {
//       try {
//         new URL(value);
//       } catch {
//         return 'Введите корректный URL';
//       }
//     }
//     return null;
//   };

//   const handleMainInfoChange = (e) => {
//     const value = e.target.value;
//     setMainInfoInput(value);
//     setErrors({ ...errors, mainInfo: validateMainInput(value) });
//   };

//   const handleSocialMediaChange = (e) => {
//     const value = e.target.value;
//     setSocialMediaInput(value);
//     setErrors({ ...errors, socialMedia: validateSocialInput(value) });
//   };

//   const addMainInfo = () => {
//     if (!mainInfoInput || errors.mainInfo) return;
//     setContactInfo({
//       ...contactInfo,
//       [selectedInfoType]: mainInfoInput,
//     });
//     setMainInfoInput('');
//     setShowAddMainInfo(false);
//     setSelectedInfoType(null);
//   };

//   const addSocialMedia = () => {
//     if (!socialMediaInput || errors.socialMedia) return;
//     setSocialMedia({
//       ...socialMedia,
//       [selectedSocialMediaType]: socialMediaInput,
//     });
//     setSocialMediaInput('');
//     setShowAddSocialMedia(false);
//     setSelectedSocialMediaType(null);
//     if (socialFormRef.current) {
//       socialFormRef.current.scrollIntoView({ behavior: 'smooth' });
//     }
//   };

//   const removeMainInfo = (type) => {
//     setContactInfo({ ...contactInfo, [type]: null });
//   };

//   const removeSocialMedia = (type) => {
//     setSocialMedia({ ...socialMedia, [type]: null });
//   };

//   const availableMainInfoTypes = [
//     ...(contactInfo.email ? [] : ['email']),
//     ...(contactInfo.phone ? [] : ['phone']),
//     ...(contactInfo.website ? [] : ['website']),
//   ];

//   const availableSocialMediaTypes = [
//     ...(socialMedia.telegram ? [] : ['telegram']),
//     ...(socialMedia.linkedin ? [] : ['linkedin']),
//     ...(socialMedia.github ? [] : ['github']),
//     ...(socialMedia.twitter ? [] : ['twitter']),
//   ];

//   const handleTypeChange = (e, isSocial, setValue, setSelected) => {
//     const type = e.target.value;
//     setSelected(type);
//     let initialValue = '';
//     if (!isSocial) {
//       if (type === 'phone') initialValue = '+7 ';
//       if (type === 'website') initialValue = 'https://';
//     } else {
//       if (type === 'telegram') initialValue = '@';
//       if (type === 'github') initialValue = 'https://github.com/';
//       if (type === 'linkedin') initialValue = 'https://www.linkedin.com/in/';
//       if (type === 'twitter') initialValue = 'https://twitter.com/';
//     }
//     setValue(initialValue);
//   };

//   const toggleEditing = () => {
//     if (isEditing) {
//       saveData();
//       setShowAddMainInfo(false);
//       setShowAddSocialMedia(false);
//     }
//     setIsEditing(!isEditing);
//   };

//   const InfoCard = ({ icon, title, subtitle, fullWidth, onDelete }) => (
//     <div className={`${classes.card} ${fullWidth ? classes.cardFullWidth : classes.cardHalfWidth}`}>
//       {icon}
//       <Box sx={{ ml: 2, flex: 1 }}>
//         <Typography sx={{ fontSize: 12, fontWeight: 'bold', color: '#fff' }}>{title}</Typography>
//         <Typography sx={{ fontSize: 10, color: '#989898' }}>{subtitle}</Typography>
//       </Box>
//       {isEditing && onDelete && (
//         <IconButton className={classes.deleteButton} onClick={onDelete}>
//           <Close fontSize="small" sx={{ color: '#fff' }} />
//         </IconButton>
//       )}
//     </div>
//   );

//   const AddInfoForm = ({ types, selected, onTypeSelected, onAddPressed, onCancel, value, setValue, isSocial }) => {
//     const isPhone = !isSocial && selected === 'phone';
//     return (
//       <Box className={classes.formContainer}>
//         <Select
//           value={selected || ''}
//           onChange={(e) => handleTypeChange(e, isSocial, setValue, onTypeSelected)}
//           fullWidth
//           sx={{ mb: 2 }}
//         >
//           {types.map((type) => (
//             <MenuItem key={type} value={type}>
//               {getIconForType(type, isSocial)}
//               {type.charAt(0).toUpperCase() + type.slice(1)}
//             </MenuItem>
//           ))}
//         </Select>
//         <Box className={classes.formRow}>
//           {/* {selected && <div className={classes.iconPreview}>{getIconForType(selected, isSocial)}</div>} */}
//           {isPhone ? (
//             <InputMask
//               mask="+7 (999) 999-99-99"
//               value={value}
//               onChange={(e) => {
//                 handleMainInfoChange(e);
//               }}
//             >
//               {() => <TextField fullWidth error={!!errors.mainInfo} helperText={errors.mainInfo} />}
//             </InputMask>
//           ) : (
//             <TextField
//               fullWidth
//               value={value}
//               onChange={(e) => {
//                 if (isSocial) {
//                   handleSocialMediaChange(e);
//                 } else {
//                   handleMainInfoChange(e);
//                 }
//               }}
//               error={isSocial ? !!errors.socialMedia : !!errors.mainInfo}
//               helperText={isSocial ? errors.socialMedia : errors.mainInfo}
//             />
//           )}
//         </Box>
//         <Box className={classes.formRow} sx={{ mt: 1 }}>
//           <Button variant="contained" onClick={onAddPressed} fullWidth>Добавить</Button>
//           <Button variant="outlined" onClick={onCancel} fullWidth>Отмена</Button>
//         </Box>
//       </Box>
//     );
//   };

//   return (
//     <div className={classes.wrapper}>
//       <div className={classes.header}>
//         <IconButton className={classes.backButton} onClick={() => navigate(-1)}>
//           <ArrowBack sx={{ color: '#9C27B0' }} />
//         </IconButton>
//         <Box>
//           {isEditing && (
//             <IconButton onClick={() => setIsEditing(false)} sx={{ mr: 1 }}>
//               <Close sx={{ color: 'red' }} />
//             </IconButton>
//           )}
//           <IconButton onClick={toggleEditing}>
//             {isEditing ? <Check /> : <Edit />}
//           </IconButton>
//         </Box>
//       </div>

//       <div className={classes.avatarContainer}>
//         <Avatar src="https://example.com/your-avatar.jpg" sx={{ width: 96, height: 96 }} />
//         {isEditing && (
//           <div className={classes.avatarOverlay}>
//             <CameraAlt sx={{ color: '#fff', fontSize: 28 }} />
//           </div>
//         )}
//       </div>

//       <TextField
//         fullWidth
//         value={name}
//         onChange={(e) => setName(e.target.value)}
//         disabled={!isEditing}
//         sx={{
//           '.MuiInputBase-input': { color: '#fff', fontSize: 18, fontWeight: 'bold', textAlign: 'center' },
//           '.MuiInputBase-root': { '& fieldset': { border: 'none' } },
//         }}
//       />

//       <TextField
//         fullWidth
//         value={position}
//         onChange={(e) => setPosition(e.target.value)}
//         disabled={!isEditing}
//         sx={{
//           '.MuiInputBase-input': { color: '#fff', fontSize: 14, fontWeight: 200, textAlign: 'center' },
//           '.MuiInputBase-root': { '& fieldset': { border: 'none' } },
//         }}
//       />

//       <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', mt: 1 }}>
//         <FontAwesomeIcon icon={faBuildingSolid} style={{ color: '#fff', fontSize: 24, marginRight: 5 }} />
//         <TextField
//           value={company}
//           onChange={(e) => setCompany(e.target.value)}
//           disabled={!isEditing}
//           sx={{
//             '.MuiInputBase-input': { color: '#fff', fontSize: 14, fontWeight: 200 },
//             '.MuiInputBase-root': { '& fieldset': { border: 'none' } },
//           }}
//         />
//       </Box>

//       <TextField
//         fullWidth
//         value={about}
//         onChange={(e) => setAbout(e.target.value)}
//         disabled={!isEditing}
//         sx={{
//           '.MuiInputBase-input': { color: '#fff', fontSize: 14, fontWeight: 200, textAlign: 'center', mt: 2 },
//           '.MuiInputBase-root': { '& fieldset': { border: 'none' } },
//         }}
//       />

//       <Typography className={classes.sectionTitle}>Связаться со мной</Typography>
//       <Box className={classes.cardContainer}>
//         {contactInfo.email && (
//           <InfoCard
//             icon={<EmailOutlined sx={{ color: '#fff', fontSize: 32 }} />}
//             title="Email"
//             subtitle={contactInfo.email}
//             fullWidth
//             onDelete={() => removeMainInfo('email')}
//           />
//         )}
//         {contactInfo.phone && (
//           <InfoCard
//             icon={<Phone sx={{ color: '#fff', fontSize: 32 }} />}
//             title="Телефон"
//             subtitle={contactInfo.phone}
//             fullWidth
//             onDelete={() => removeMainInfo('phone')}
//           />
//         )}
//         {contactInfo.website && (
//           <InfoCard
//             icon={<Language sx={{ color: '#fff', fontSize: 32 }} />}
//             title="Сайт"
//             subtitle={contactInfo.website}
//             fullWidth
//             onDelete={() => removeMainInfo('website')}
//           />
//         )}
//         {isEditing && availableMainInfoTypes.length > 0 && (
//           <Button
//             fullWidth
//             className={classes.addButton}
//             onClick={() => setShowAddMainInfo(true)}
//           >
//             Добавить основную информацию
//           </Button>
//         )}
//         {showAddMainInfo && (
//           <AddInfoForm
//             types={availableMainInfoTypes}
//             selected={selectedInfoType}
//             onTypeSelected={setSelectedInfoType}
//             onAddPressed={addMainInfo}
//             onCancel={() => {
//               setShowAddMainInfo(false);
//               setSelectedInfoType(null);
//               setMainInfoInput('');
//             }}
//             value={mainInfoInput}
//             setValue={setMainInfoInput}
//           />
//         )}
//       </Box>

//       <Typography className={classes.sectionTitle}>Социальные сети</Typography>
//       <Box className={classes.cardContainer}>
//         {socialMedia.telegram && (
//           <InfoCard
//             icon={<FontAwesomeIcon icon={faTelegram} className={classes.icon} />}
//             title="Telegram"
//             subtitle={socialMedia.telegram}
//             onDelete={() => removeSocialMedia('telegram')}
//           />
//         )}
//         {socialMedia.linkedin && (
//           <InfoCard
//             icon={<FontAwesomeIcon icon={faLinkedin} className={classes.icon} />}
//             title="LinkedIn"
//             subtitle={socialMedia.linkedin}
//             onDelete={() => removeSocialMedia('linkedin')}
//           />
//         )}
//         {socialMedia.github && (
//           <InfoCard
//             icon={<FontAwesomeIcon icon={faGithub} className={classes.icon} />}
//             title="GitHub"
//             subtitle={socialMedia.github}
//             onDelete={() => removeSocialMedia('github')}
//           />
//         )}
//         {socialMedia.twitter && (
//           <InfoCard
//             icon={<FontAwesomeIcon icon={faTwitter} className={classes.icon} />}
//             title="Twitter"
//             subtitle={socialMedia.twitter}
//             onDelete={() => removeSocialMedia('twitter')}
//           />
//         )}
//         {isEditing && availableSocialMediaTypes.length > 0 && (
//           <Button
//             fullWidth
//             className={classes.addButton}
//             onClick={() => {
//               setShowAddSocialMedia(true);
//               setTimeout(() => socialFormRef.current?.scrollIntoView({ behavior: 'smooth' }), 0);
//             }}
//           >
//             Добавить социальную сеть
//           </Button>
//         )}
//         {showAddSocialMedia && (
//           <AddInfoForm
//             types={availableSocialMediaTypes}
//             selected={selectedSocialMediaType}
//             onTypeSelected={setSelectedSocialMediaType}
//             onAddPressed={addSocialMedia}
//             onCancel={() => {
//               setShowAddSocialMedia(false);
//               setSelectedSocialMediaType(null);
//               setSocialMediaInput('');
//             }}
//             value={socialMediaInput}
//             setValue={setSocialMediaInput}
//             isSocial
//           />
//         )}
//       </Box>

//       <IconButton className={classes.qrButton} onClick={() => setShowQrCode(!showQrCode)}>
//         <QrcodeOutlined style={{ color: '#fff', fontSize: 24 }} />
//       </IconButton>
//       {showQrCode && (
//         <Box className={classes.qrCode}>
//           <Typography sx={{ color: '#fff' }}>QR-код (заглушка)</Typography>
//         </Box>
//       )}
//     </div>
//   );
// };

// export default VisitCardProfile;

// VisitCardProfile.jsx
import { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { Box, TextField, Button, Typography, IconButton, Avatar, Select, MenuItem } from '@mui/material';
import { ArrowBack, Edit, Close, CameraAlt, Check, EmailOutlined, Phone, Language } from '@mui/icons-material';
import { QrcodeOutlined } from '@ant-design/icons';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTelegram, faLinkedin, faGithub, faTwitter } from '@fortawesome/free-brands-svg-icons';
import { faBuilding as faBuildingSolid } from '@fortawesome/free-solid-svg-icons';
import { toast } from 'react-toastify';
import InputMask from 'react-input-mask';
import classes from './VisitCardProfile.module.css';

function VisitCardProfile() {
  const navigate = useNavigate();
  const socialFormRef = useRef(null);
  const [isEditing, setIsEditing] = useState(false);
  const [showQrCode, setShowQrCode] = useState(false);
  const [showAddMainInfo, setShowAddMainInfo] = useState(false);
  const [showAddSocialMedia, setShowAddSocialMedia] = useState(false);
  const [selectedInfoType, setSelectedInfoType] = useState(null);
  const [selectedSocialMediaType, setSelectedSocialMediaType] = useState(null);
  const [mainInfoValue, setMainInfoValue] = useState('');
  const [socialMediaValue, setSocialMediaValue] = useState('');
  const [name, setName] = useState('');
  const [position, setPosition] = useState('');
  const [company, setCompany] = useState('');
  const [about, setAbout] = useState('');
  const [contactInfo, setContactInfo] = useState({
    email: null,
    phone: null,
    website: null,
  });
  const [socialMedia, setSocialMedia] = useState({
    telegram: null,
    linkedin: null,
    github: null,
    twitter: null,
  });

  const [avatarUrl, setAvatarUrl] = useState(null);

  const handleAvatarChange = (e) => {
  const file = e.target.files[0];
  if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setAvatarUrl(reader.result);
      };
      reader.readAsDataURL(file);
    }
  };

  useEffect(() => {
    // Mock loading data as in Flutter initState
    setName('Барак Обама');
    setPosition('Старший кассир');
    setCompany('ООО "KFC"');
    setAbout('Просто чиловый парень');
    // For demonstration, set some initial contacts and socials to match screenshots
    setContactInfo({
      email: 'obemekfc@mpt.ru',
      phone: '+7 (800) 555 35-35',
      website: 'https://goyda.com',
    });
    setSocialMedia({
      telegram: '@InQvd',
      linkedin: 'Профиль LinkedIn',
      github: 'https://github.com/LatteSoM',
      twitter: 'Профиль X',
    });
  }, []);

  const saveData = () => {
    // Mock save, show toast as in Flutter
    toast.success('Визитка создана');
    setIsEditing(false);
  };

  const removeMainInfo = (type) => {
    setContactInfo((prev) => ({ ...prev, [type]: null }));
  };

  const removeSocialMedia = (type) => {
    setSocialMedia((prev) => ({ ...prev, [type]: null }));
  };

  const addMainInfo = () => {
    const error = validateMainInput(mainInfoValue, selectedInfoType);
    if (!error && mainInfoValue && selectedInfoType) {
      setContactInfo((prev) => ({ ...prev, [selectedInfoType]: mainInfoValue }));
      setMainInfoValue('');
      setShowAddMainInfo(false);
      setSelectedInfoType(null);
    } else {
      toast.error(error || 'Введите информацию');
    }
  };

  const addSocialMedia = () => {
    if (socialMediaValue && selectedSocialMediaType) {
      setSocialMedia((prev) => ({ ...prev, [selectedSocialMediaType]: socialMediaValue }));
      setSocialMediaValue('');
      setShowAddSocialMedia(false);
      setSelectedSocialMediaType(null);
      if (socialFormRef.current) {
        socialFormRef.current.scrollIntoView({ behavior: 'smooth' });
      }
    }
  };

  const validateMainInput = (value, type) => {
    if (!value) return 'Введите информацию';
    if (type === 'email') {
      if (!/^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$/.test(value)) {
        return 'Введите корректный email';
      }
    }
    if (type === 'phone') {
      if (!/^(\+?7|8)[\s\-]?\(?[0-9]{3}\)?[\s\-]?[0-9]{3}[\s\-]?[0-9]{2}[\s\-]?[0-9]{2}$/.test(value)) {
        return 'Введите корректный номер телефона';
      }
    }
    if (type === 'website') {
      try {
        new URL(value);
      } catch {
        return 'Введите корректный URL';
      }
    }
    return null;
  };

  const handleMainInfoChange = (e) => {
    let val = e.target.value;
    if (selectedInfoType === 'phone' && !val.startsWith('+7')) {
      val = '+7';
    } else if (selectedInfoType === 'website' && !val.startsWith('https://')) {
      val = 'https://';
    }
    setMainInfoValue(val);
  };

  const handleSocialChange = (e) => {
    let val = e.target.value;
    if (selectedSocialMediaType === 'telegram' && !val.startsWith('@')) {
      val = '@';
    } else if (selectedSocialMediaType === 'github' && !val.startsWith('https://github.com/')) {
      val = 'https://github.com/';
    }
    setSocialMediaValue(val);
  };

  const availableMainInfoTypes = ['email', 'phone', 'website'].filter((t) => !contactInfo[t]);
  const availableSocialMediaTypes = ['telegram', 'linkedin', 'github', 'twitter'].filter((t) => !socialMedia[t]);

  const getDisplayType = (type) => {
    switch (type) {
      case 'email': return 'Email';
      case 'phone': return 'Телефон';
      case 'website': return 'Сайт';
      case 'telegram': return 'Telegram';
      case 'linkedin': return 'LinkedIn';
      case 'github': return 'GitHub';
      case 'twitter': return 'Twitter';
      default: return type;
    }
  };

  return (
    <Box className={classes.container}>
      <Box className={classes.header}>
        <IconButton className={classes.backButton} onClick={() => navigate(-1)}>
          <ArrowBack />
        </IconButton>
        <Box className={classes.headerActions}>
          {isEditing && (
            <IconButton onClick={() => setIsEditing(false)}>
              <Close className={classes.closeIcon} />
            </IconButton>
          )}
          <IconButton
            onClick={() => {
              if (isEditing) {
                saveData();
              } else {
                setIsEditing(true);
              }
            }}
          >
            {isEditing ? <Check /> : <Edit />}
          </IconButton>
        </Box>
      </Box>
      {/* <Box className={classes.avatarWrapper}>
        <Avatar src="" className={classes.avatar} />
        {isEditing && (
          <Box className={classes.avatarOverlay}>
            <CameraAlt className={classes.cameraIcon} />
          </Box>
        )}
      </Box> */}
      <Box className={classes.avatarWrapper}>
        <input
            accept="image/*"
            style={{ display: 'none' }}
            id="avatar-upload"
            type="file"
            onChange={handleAvatarChange}
        />
        
        <label htmlFor="avatar-upload" style={{ cursor: 'pointer' }}>
            <Avatar
            src={avatarUrl || ''}
            className={classes.avatar}
            />
            {isEditing && (
            <Box className={classes.avatarOverlay}>
                <CameraAlt className={classes.cameraIcon} />
            </Box>
            )}
        </label>
      </Box>

        {/* <Box className={classes.avatarWrapper}>
            <input
                accept="image/*"
                style={{ display: 'none' }}
                id="avatar-upload"
                type="file"
                onChange={handleAvatarChange}
            />
            
            <label htmlFor="avatar-upload">
                <Avatar src={avatarUrl || ''} className={classes.avatar} />
                {isEditing && (
                <Box className={classes.avatarOverlay}>
                    <CameraAlt className={classes.cameraIcon} />
                </Box>
                )}
            </label>
        </Box> */}


      <Box className={classes.textCenter}>
        {isEditing ? (
          <TextField
            value={name}
            onChange={(e) => setName(e.target.value)}
            className={classes.editableName}
            InputProps={{ className: classes.inputProps }}
          />
        ) : (
          <Typography className={classes.name}>{name || 'Имя'}</Typography>
        )}
      </Box>
      <Box className={classes.textCenter}>
        {isEditing ? (
          <TextField
            value={position}
            onChange={(e) => setPosition(e.target.value)}
            className={classes.editablePosition}
            InputProps={{ className: classes.inputProps }}
          />
        ) : (
          <Typography className={classes.position}>{position || 'Должность'}</Typography>
        )}
      </Box>
      <Box className={classes.companyRow}>
        <FontAwesomeIcon icon={faBuildingSolid} className={classes.companyIcon} />
        {isEditing ? (
          <TextField
            value={company}
            onChange={(e) => setCompany(e.target.value)}
            className={classes.editableCompany}
            InputProps={{ className: classes.inputProps }}
          />
        ) : (
          <Typography className={classes.company}>{company || 'Компания'}</Typography>
        )}
      </Box>
      <Box className={classes.textCenter}>
        {isEditing ? (
          <TextField
            value={about}
            onChange={(e) => setAbout(e.target.value)}
            className={classes.editableAbout}
            InputProps={{ className: classes.inputProps }}
          />
        ) : (
          <Typography className={classes.about}>{about || 'О себе'}</Typography>
        )}
      </Box>
      <Typography className={classes.sectionTitle}>Связаться со мной:</Typography>
      {contactInfo.email && (
        <Box className={classes.infoCardFull}>
          <EmailOutlined className={classes.infoIcon} />
          <Box className={classes.infoContent}>
            <Typography className={classes.infoTitle}>Email</Typography>
            <Typography className={classes.infoSubtitle}>{contactInfo.email}</Typography>
          </Box>
          {isEditing && (
            <IconButton className={classes.deleteButton} onClick={() => removeMainInfo('email')}>
              <Close />
            </IconButton>
          )}
        </Box>
      )}
      {contactInfo.phone && (
        <Box className={classes.infoCardFull}>
          <Phone className={classes.infoIcon} />
          <Box className={classes.infoContent}>
            <Typography className={classes.infoTitle}>Телефон</Typography>
            <Typography className={classes.infoSubtitle}>{contactInfo.phone}</Typography>
          </Box>
          {isEditing && (
            <IconButton className={classes.deleteButton} onClick={() => removeMainInfo('phone')}>
              <Close />
            </IconButton>
          )}
        </Box>
      )}
      {contactInfo.website && (
        <Box className={classes.infoCardFull}>
          <Language className={classes.infoIcon} />
          <Box className={classes.infoContent}>
            <Typography className={classes.infoTitle}>Сайт</Typography>
            <Typography className={classes.infoSubtitle}>{contactInfo.website}</Typography>
          </Box>
          {isEditing && (
            <IconButton className={classes.deleteButton} onClick={() => removeMainInfo('website')}>
              <Close />
            </IconButton>
          )}
        </Box>
      )}
      {isEditing && availableMainInfoTypes.length > 0 && (
        <Button className={classes.addButton} onClick={() => setShowAddMainInfo(true)}>
          + Добавить основную информацию
        </Button>
      )}
      {showAddMainInfo && isEditing && (
        <Box className={classes.addForm}>
          <Select
            value={selectedInfoType || ''}
            onChange={(e) => {
              setSelectedInfoType(e.target.value);
              setMainInfoValue('');
            }}
            className={classes.select}
            displayEmpty
          >
            <MenuItem value="" disabled>Тип информации</MenuItem>
            {availableMainInfoTypes.map((type) => (
              <MenuItem key={type} value={type}>
                {getDisplayType(type)}
              </MenuItem>
            ))}
          </Select>
          {selectedInfoType === 'phone' ? (
            <InputMask mask="+7 (999) 999-99-99" value={mainInfoValue} onChange={handleMainInfoChange}>
              {() => <TextField className={classes.textField} label="Данные" />}
            </InputMask>
          ) : (
            <TextField
              className={classes.textField}
              label="Данные"
              value={mainInfoValue}
              onChange={handleMainInfoChange}
              error={!!validateMainInput(mainInfoValue, selectedInfoType)}
              helperText={validateMainInput(mainInfoValue, selectedInfoType)}
            />
          )}
          <Box className={classes.formButtons}>
            <Button className={classes.cancelButton} onClick={() => setShowAddMainInfo(false)}>
              Отмена
            </Button>
            <Button className={classes.addFormButton} onClick={addMainInfo}>
              Добавить
            </Button>
          </Box>
        </Box>
      )}
      <Typography className={classes.sectionTitle}>Социальные сети</Typography>
      <Box className={classes.socialWrap}>
        {socialMedia.telegram && (
          <Box className={classes.socialCard}>
            <FontAwesomeIcon icon={faTelegram} className={classes.socialIcon} />
            <Box className={classes.infoContent}>
              <Typography className={classes.infoTitle}>Телеграм</Typography>
              <Typography className={classes.infoSubtitle}>{socialMedia.telegram}</Typography>
            </Box>
            {isEditing && (
              <IconButton className={classes.deleteButton} onClick={() => removeSocialMedia('telegram')}>
                <Close />
              </IconButton>
            )}
          </Box>
        )}
        {socialMedia.linkedin && (
          <Box className={classes.socialCard}>
            <FontAwesomeIcon icon={faLinkedin} className={classes.socialIcon} />
            <Box className={classes.infoContent}>
              <Typography className={classes.infoTitle}>LinkedIn</Typography>
              <Typography className={classes.infoSubtitle}>{socialMedia.linkedin}</Typography>
            </Box>
            {isEditing && (
              <IconButton className={classes.deleteButton} onClick={() => removeSocialMedia('linkedin')}>
                <Close />
              </IconButton>
            )}
          </Box>
        )}
        {socialMedia.github && (
          <Box className={classes.socialCard}>
            <FontAwesomeIcon icon={faGithub} className={classes.socialIcon} />
            <Box className={classes.infoContent}>
              <Typography className={classes.infoTitle}>GitHub</Typography>
              <Typography className={classes.infoSubtitle}>{socialMedia.github}</Typography>
            </Box>
            {isEditing && (
              <IconButton className={classes.deleteButton} onClick={() => removeSocialMedia('github')}>
                <Close />
              </IconButton>
            )}
          </Box>
        )}
        {socialMedia.twitter && (
          <Box className={classes.socialCard}>
            <FontAwesomeIcon icon={faTwitter} className={classes.socialIcon} />
            <Box className={classes.infoContent}>
              <Typography className={classes.infoTitle}>X</Typography>
              <Typography className={classes.infoSubtitle}>{socialMedia.twitter}</Typography>
            </Box>
            {isEditing && (
              <IconButton className={classes.deleteButton} onClick={() => removeSocialMedia('twitter')}>
                <Close />
              </IconButton>
            )}
          </Box>
        )}
      </Box>
      {isEditing && availableSocialMediaTypes.length > 0 && (
        <Button className={classes.addButton} onClick={() => setShowAddSocialMedia(true)}>
          + Добавить социальную сеть
        </Button>
      )}
      {showAddSocialMedia && isEditing && (
        <Box ref={socialFormRef} className={classes.addForm}>
          <Select
            value={selectedSocialMediaType || ''}
            onChange={(e) => {
              setSelectedSocialMediaType(e.target.value);
              setSocialMediaValue('');
            }}
            className={classes.select}
            displayEmpty
          >
            <MenuItem value="" disabled>Социальная сеть</MenuItem>
            {availableSocialMediaTypes.map((type) => (
              <MenuItem key={type} value={type}>
                {getDisplayType(type)}
              </MenuItem>
            ))}
          </Select>
          <TextField
            className={classes.textField}
            label="Ссылка на профиль"
            value={socialMediaValue}
            onChange={handleSocialChange}
          />
          <Box className={classes.formButtons}>
            <Button className={classes.cancelButton} onClick={() => setShowAddSocialMedia(false)}>
              Отмена
            </Button>
            <Button className={classes.addFormButton} onClick={addSocialMedia}>
              Добавить
            </Button>
          </Box>
        </Box>
      )}
      <IconButton className={classes.fab} onClick={() => setShowQrCode(!showQrCode)}>
        <QrcodeOutlined />
      </IconButton>
    </Box>
  );
}

export default VisitCardProfile;
