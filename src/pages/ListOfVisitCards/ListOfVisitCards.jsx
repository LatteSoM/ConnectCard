// // // ListOfVisitCards.jsx
// import React, { useState, useEffect, useRef } from 'react';
// import { useNavigate } from 'react-router-dom';
// import { Box, Typography, IconButton, Divider, CircularProgress, List, ListItem, Menu, MenuItem, Dialog, DialogTitle, DialogContent, DialogActions, Button } from '@mui/material';
// import { Add, Delete, Share } from '@mui/icons-material';
// import { toast } from 'react-toastify';
// import VisitCard from './VisitCard';
// import VisitCardPreview from './VisitCardPreview.jsx';
// import { useAuth } from '../../context/AuthContext';

// const ListOfVisitCards = () => {
//   const { userLogin, accessToken } = useAuth();
//   const [cards, setCards] = useState([]);
//   const [isLoading, setIsLoading] = useState(true);
//   const [selectedCardId, setSelectedCardId] = useState(null);
//   const [anchorEl, setAnchorEl] = useState(null);
//   const [showDeleteDialog, setShowDeleteDialog] = useState(false);
//   const baseUrl = import.meta.env.VITE_BASE_URL;
//   const navigate = useNavigate();

//   const loadCards = async () => {
//     if (!userLogin || !accessToken) {
//       toast.error('Пользователь не авторизован');
//       setIsLoading(false);
//       return;
//     }

//     const userId = userLogin.id; // Адаптируйте под структуру userLogin
//     try {
//       const response = await fetch(`${baseUrl}/cards/user/${userId}`, {
//         headers: {
//           'Authorization': `Bearer ${accessToken}`,
//         },
//       });
//       if (response.ok) {
//         const data = await response.json();
//         setCards(data);
//       } else if (response.status === 404) {
//         setCards([]);
//       } else {
//         throw new Error('Ошибка загрузки визиток');
//       }
//     } catch (error) {
//       toast.error('Ошибка: ' + error.message);
//       setIsLoading(false);
//     } finally {
//       setIsLoading(false);
//     }
//   };

//   useEffect(() => {
//     loadCards();
//   }, [userLogin, accessToken]);

//   const handleLongPressStart = (e, cardId) => {
//     setSelectedCardId(cardId);
//     setAnchorEl(e.currentTarget);
//   };

//   const handleLongPressEnd = () => {
//     setAnchorEl(null);
//   };

//   const handleMenuClose = () => {
//     setAnchorEl(null);
//   };

//   const handleShare = () => {
//     handleMenuClose();
//     navigate(`/share/${selectedCardId}`);
//   };

//   const handleDeleteClick = () => {
//     handleMenuClose();
//     setShowDeleteDialog(true);
//   };

//   const confirmDelete = async () => {
//     try {
//       const response = await fetch(`${baseUrl}/cards/${selectedCardId}`, {
//         method: 'DELETE',
//         headers: {
//           'Authorization': `Bearer ${accessToken}`,
//         },
//       });
//       if (response.ok) {
//         toast.success('Визитка успешно удалена');
//         loadCards();
//       } else {
//         toast.error('Ошибка при удалении');
//       }
//     } catch (error) {
//       toast.error('Ошибка');
//     }
//     setShowDeleteDialog(false);
//     setSelectedCardId(null);
//   };

//   const isCardsEmpty = cards.length === 0;

//   return (
//     <Box sx={{ backgroundColor: '#141218', color: 'white', minHeight: '100vh', p: 2 }}>
//       <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
//         <Typography sx={{ fontWeight: 'bold', fontSize: 18 }}>Ваши Визитки</Typography>
//         <IconButton onClick={() => navigate('/designer')} sx={{ color: 'white' }}>
//           <Add />
//         </IconButton>
//       </Box>
//       <Divider sx={{ bgcolor: 'white', my: 1 }} />
//       {isLoading ? (
//         <CircularProgress sx={{ color: 'white', mt: 4 }} />
//       ) : isCardsEmpty ? (
//         <Box sx={{ textAlign: 'center', mt: 4 }}>
//           <Typography sx={{ fontSize: 25, fontWeight: 'bold' }}>Создай свою визитку</Typography>
//           <Typography sx={{ fontSize: 16, opacity: 0.7 }}>Нажми на кнопку "+" выше</Typography>
//         </Box>
//       ) : (
//         <List>
//           {cards.map((card) => (
//             <ListItem
//               key={card.id}
//               onTouchStart={(e) => handleLongPressStart(e, card.id)}
//               onTouchEnd={handleLongPressEnd}
//               onContextMenu={(e) => {
//                 e.preventDefault();
//                 handleLongPressStart(e, card.id);
//               }}
//               sx={{ opacity: selectedCardId === null || selectedCardId === card.id ? 1 : 0.5, mb: 3 }}
//             >
//               {card.elements && card.elements.length > 0 ? (
//                 <VisitCardPreview elements={card.elements} />
//               ) : (
//                 <VisitCard
//                   fullName={card.fullname}
//                   position={card.position || ''}
//                   company={card.company || ''}
//                   socialLinks={card.linkWidgets || []}
//                   avatar={card.avatar}
//                   isSelected={selectedCardId === card.id}
//                 />
//               )}
//             </ListItem>
//           ))}
//         </List>
//       )}
//       <Menu
//         anchorEl={anchorEl}
//         open={Boolean(anchorEl)}
//         onClose={handleMenuClose}
//       >
//         <MenuItem onClick={handleShare}>
//           <Share sx={{ mr: 1 }} /> Поделиться
//         </MenuItem>
//         <MenuItem onClick={handleDeleteClick}>
//           <Delete sx={{ mr: 1 }} /> Удалить
//         </MenuItem>
//       </Menu>
//       <Dialog open={showDeleteDialog} onClose={() => setShowDeleteDialog(false)}>
//         <DialogTitle sx={{ color: 'white', bgcolor: '#1E1E1E' }}>Вы действительно хотите удалить визитку?</DialogTitle>
//         <DialogContent sx={{ bgcolor: '#1E1E1E' }} />
//         <DialogActions sx={{ bgcolor: '#1E1E1E' }}>
//           <Button onClick={() => setShowDeleteDialog(false)} sx={{ color: 'grey.300' }}>Нет</Button>
//           <Button onClick={confirmDelete} sx={{ color: 'purpleAccent.main', bgcolor: 'rgba(156, 39, 176, 0.2)' }}>Удалить</Button>
//         </DialogActions>
//       </Dialog>
//     </Box>
//   );
// };

// export default ListOfVisitCards;


// ListOfVisitCards.jsx
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Box, Typography, IconButton, Divider, CircularProgress, List, ListItem, Menu, MenuItem, Dialog, DialogTitle, DialogContent, DialogActions, Button } from '@mui/material';

import { Add, Delete, Share } from '@mui/icons-material';
import { toast } from 'react-toastify';
import VisitCard from './VisitCard';
import VisitCardPreview from './VisitCardPreview';
import { useAuth } from '../../context/AuthContext';

const ListOfVisitCards = () => {
  const { userLogin, accessToken } = useAuth();
  const [cards, setCards] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedCardId, setSelectedCardId] = useState(null);
  const [anchorEl, setAnchorEl] = useState(null);
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  const baseUrl = import.meta.env.VITE_BASE_URL;
  const navigate = useNavigate();
  let longPressTimer;

  const loadCards = async () => {
    if (!userLogin || !accessToken) {
      toast.error('Пользователь не авторизован');
      setIsLoading(false);
      return;
    }

    const userId = userLogin.id; // Адаптируйте под структуру userLogin
    try {
      const response = await fetch(`${baseUrl}/cards/user/${userId}`, {
        headers: {
          'Authorization': `Bearer ${accessToken}`,
        },
      });
      if (response.ok) {
        const data = await response.json();
        setCards(data);
      } else if (response.status === 404) {
        setCards([]);
      } else {
        throw new Error('Ошибка загрузки визиток');
      }
    } catch (error) {
      toast.error('Ошибка: ' + error.message);
      setIsLoading(false);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadCards();
  }, [userLogin, accessToken]);

  const handleLongPressStart = (e, cardId) => {
    e.persist(); // Чтобы сохранить событие для setTimeout
    longPressTimer = setTimeout(() => {
      setSelectedCardId(cardId);
      setAnchorEl(e.currentTarget);
    }, 500); // 500ms для long press
  };

  const handleLongPressEnd = () => {
    if (longPressTimer) {
      clearTimeout(longPressTimer);
    }
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
  };

  const handleShare = () => {
    handleMenuClose();
    navigate(`/share/${selectedCardId}`);
  };

  const handleDeleteClick = () => {
    handleMenuClose();
    setShowDeleteDialog(true);
  };

  const confirmDelete = async () => {
    try {
      const response = await fetch(`${baseUrl}/cards/${selectedCardId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
        },
      });
      if (response.ok) {
        toast.success('Визитка успешно удалена');
        loadCards();
      } else {
        toast.error('Ошибка при удалении');
      }
    } catch (error) {
      toast.error('Ошибка');
    }
    setShowDeleteDialog(false);
    setSelectedCardId(null);
  };

  const handleEditClick = (cardId) => {
    navigate(`/designer/${cardId}`);
  };

  const isCardsEmpty = cards.length === 0;

  return (
    <Box sx={{ backgroundColor: '#141218', color: 'white', minHeight: '100vh', p: 2 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Typography sx={{ fontWeight: 'bold', fontSize: 18 }}>Ваши Визитки</Typography>
        <IconButton onClick={() => navigate('/designer')} sx={{ color: 'white' }}>
          <Add />
        </IconButton>
      </Box>
      <Divider sx={{ bgcolor: 'white', my: 1 }} />
      {isLoading ? (
        <CircularProgress sx={{ color: 'white', mt: 4 }} />
      ) : isCardsEmpty ? (
        <Box sx={{ textAlign: 'center', mt: 4 }}>
          <Typography sx={{ fontSize: 25, fontWeight: 'bold' }}>Создай свою визитку</Typography>
          <Typography sx={{ fontSize: 16, opacity: 0.7 }}>Нажми на кнопку "+" выше</Typography>
        </Box>
      ) : (
        <List>
          {cards.map((card) => (
            <ListItem
              key={card.id}
              onTouchStart={(e) => handleLongPressStart(e, card.id)}
              onTouchEnd={handleLongPressEnd}
              onTouchMove={handleLongPressEnd} // Отмена при движении
              onContextMenu={(e) => {
                e.preventDefault();
                setSelectedCardId(card.id);
                setAnchorEl(e.currentTarget);
              }}
              onClick={() => handleEditClick(card.id)} // Переход на редактирование при клике
              sx={{ opacity: selectedCardId === null || selectedCardId === card.id ? 1 : 0.5, mb: 3 }}
            >
              {card.elements && card.elements.length > 0 ? (
                <VisitCardPreview elements={card.elements} />
              ) : (
                <VisitCard
                  fullName={card.fullname}
                  position={card.position || ''}
                  company={card.company || ''}
                  socialLinks={card.linkWidgets || []}
                  avatar={card.avatar}
                  isSelected={selectedCardId === card.id}
                />
              )}
            </ListItem>
          ))}
        </List>
      )}
      <Menu
        anchorEl={anchorEl}
        open={Boolean(anchorEl)}
        onClose={handleMenuClose}
      >
        <MenuItem onClick={handleShare}>
          <Share sx={{ mr: 1 }} /> Поделиться
        </MenuItem>
        <MenuItem onClick={handleDeleteClick}>
          <Delete sx={{ mr: 1 }} /> Удалить
        </MenuItem>
      </Menu>
      <Dialog open={showDeleteDialog} onClose={() => setShowDeleteDialog(false)}>
        <DialogTitle sx={{ color: 'white', bgcolor: '#1E1E1E' }}>Вы действительно хотите удалить визитку?</DialogTitle>
        <DialogContent sx={{ bgcolor: '#1E1E1E' }} />
        <DialogActions sx={{ bgcolor: '#1E1E1E' }}>
          <Button onClick={() => setShowDeleteDialog(false)} sx={{ color: 'grey.300' }}>Нет</Button>
          <Button onClick={confirmDelete} sx={{ color: 'purpleAccent.main', bgcolor: 'rgba(156, 39, 176, 0.2)' }}>Удалить</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default ListOfVisitCards;