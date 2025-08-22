// // VisitCardDesigner.jsx
// import React, { useState, useRef, useEffect } from 'react';
// import { useNavigate } from 'react-router-dom';
// import { Stage, Layer, Text, Rect, Ellipse, Path, Image as KonvaImage, Transformer, Group } from 'react-konva';
// import useImage from 'use-image';
// import { HexColorPicker } from 'react-colorful';
// import { Box, Typography, IconButton, TextField, Select, MenuItem, Slider, Button, Divider, Dialog, DialogTitle, DialogContent, DialogActions } from '@mui/material';
// import { ArrowBack, Check, TextFields as TextFieldsIcon, CropSquare, Image as ImageIcon, FormatPaint, Lock, LockOpen, Delete, ArrowUpward, ArrowDownward } from '@mui/icons-material';
// import { toast } from 'react-toastify';
// import classes from './VisitCardDesigner.module.css';

// const ElementType = {
//   text: 'text',
//   shape: 'shape',
//   image: 'image',
//   background: 'background'
// };

// const ShapeType = {
//   square: 'square',
//   circle: 'circle',
//   triangle: 'triangle'
// };

// const shapeLabels = {
//   square: "Квадрат",
//   circle: "Круг",
//   triangle: "Треугольник"
// };

// const VisitCardDesigner = () => {
//   const baseUrl = import.meta.env.VITE_BASE_URL;
//   const navigate = useNavigate();

//   const [elements, setElements] = useState([
//     {
//       type: ElementType.shape,
//       x: 100,
//       y: 50,
//       scaleX: 1,
//       scaleY: 1,
//       rotation: 0,
//       shapeType: ShapeType.circle,
//       color: '#FF0000',
//       baseWidth: 100,
//       baseHeight: 100
//     },
//     {
//       type: ElementType.text,
//       x: 150,
//       y: 80,
//       scaleX: 1,
//       scaleY: 1,
//       rotation: 0,
//       text: "Name",
//       baseFontSize: 18,
//       fontFamily: 'Roboto',
//       fontWeight: 'normal',
//       textColor: '#FFFFFF'
//     },
//     {
//       type: ElementType.text,
//       x: 150,
//       y: 110,
//       scaleX: 1,
//       scaleY: 1,
//       rotation: 0,
//       text: "Info",
//       baseFontSize: 18,
//       fontFamily: 'Roboto',
//       fontWeight: 'normal',
//       textColor: '#FFFFFF'
//     }
//   ]);

//   const [selectedIndex, setSelectedIndex] = useState(null);
//   const [selectedElementType, setSelectedElementType] = useState(null);
//   const [lockAspectRatio, setLockAspectRatio] = useState(false);
//   const [showColorPicker, setShowColorPicker] = useState(false);
//   const [colorPickerType, setColorPickerType] = useState(null); // 'textColor', 'color', 'backgroundStart', 'backgroundEnd'
//   const [backgroundGradient, setBackgroundGradient] = useState(['#2196F3', '#E040FB']);
//   const [stageWidth, setStageWidth] = useState(0);
//   const [stageHeight, setStageHeight] = useState(200);

//   const stageRef = useRef(null);
//   const transformerRef = useRef(null);
//   const nodeRefs = useRef([]);
//   const containerRef = useRef(null);
//   const fileInputRef = useRef(null);

//   useEffect(() => {
//     const updateDimensions = () => {
//       if (containerRef.current) {
//         setStageWidth(containerRef.current.clientWidth);
//         setStageHeight(containerRef.current.clientHeight);
//       }
//     };
//     updateDimensions();
//     window.addEventListener('resize', updateDimensions);
//     return () => window.removeEventListener('resize', updateDimensions);
//   }, []);

//   useEffect(() => {
//     if (selectedIndex !== null) {
//       const node = nodeRefs.current[selectedIndex];
//       if (node) {
//         transformerRef.current.nodes([node]);
//         transformerRef.current.getLayer().batchDraw();
//       }
//     } else {
//       transformerRef.current.nodes([]);
//     }
//   }, [selectedIndex]);

//   const handleSelect = (index) => {
//     setSelectedIndex(index);
//     setSelectedElementType(elements[index].type);
//   };

//   const handleDeselect = (e) => {
//     if (e.target === stageRef.current) {
//       setSelectedIndex(null);
//     }
//   };

//   const handleDragEnd = (index) => (e) => {
//     const newElements = [...elements];
//     newElements[index].x = e.target.x();
//     newElements[index].y = e.target.y();
//     setElements(newElements);
//   };

//   const handleTransformEnd = (index) => (e) => {
//     const node = e.target;
//     const newElements = [...elements];
//     newElements[index].x = node.x();
//     newElements[index].y = node.y();
//     newElements[index].scaleX = node.scaleX();
//     newElements[index].scaleY = node.scaleY();
//     newElements[index].rotation = node.rotation();
//     setElements(newElements);
//   };

//   const handleAddElement = () => {
//     if (!selectedElementType) return;

//     const centerX = stageWidth / 2;
//     const centerY = stageHeight / 2;

//     let newElement;
//     switch (selectedElementType) {
//       case ElementType.text:
//         newElement = {
//           type: ElementType.text,
//           x: centerX,
//           y: centerY,
//           scaleX: 1,
//           scaleY: 1,
//           rotation: 0,
//           text: "Example",
//           baseFontSize: 18,
//           fontFamily: 'Roboto',
//           fontWeight: 'normal',
//           textColor: '#FFFFFF'
//         };
//         break;
//       case ElementType.shape:
//         newElement = {
//           type: ElementType.shape,
//           x: centerX,
//           y: centerY,
//           scaleX: 1,
//           scaleY: 1,
//           rotation: 0,
//           shapeType: ShapeType.circle,
//           color: '#FF0000',
//           baseWidth: 100,
//           baseHeight: 100
//         };
//         break;
//       case ElementType.image:
//         fileInputRef.current.click();
//         return;
//       case ElementType.background:
//         // Handled in settings
//         return;
//       default:
//         return;
//     }
//     setElements([...elements, newElement]);
//     setSelectedIndex(elements.length);
//   };

//   const handleImageChange = (e) => {
//     const file = e.target.files[0];
//     if (file) {
//       const reader = new FileReader();
//       reader.onload = (ev) => {
//         const centerX = stageWidth / 2;
//         const centerY = stageHeight / 2;
//         const newElement = {
//           type: ElementType.image,
//           x: centerX,
//           y: centerY,
//           scaleX: 1,
//           scaleY: 1,
//           rotation: 0,
//           imageSrc: ev.target.result,
//           baseWidth: 100,
//           baseHeight: 100,
//           opacity: 1.0
//         };
//         setElements([...elements, newElement]);
//         setSelectedIndex(elements.length);
//       };
//       reader.readAsDataURL(file);
//     }
//   };

//   const handleRemove = () => {
//     if (selectedIndex !== null) {
//       const newElements = elements.filter((_, i) => i !== selectedIndex);
//       setElements(newElements);
//       setSelectedIndex(null);
//       setSelectedElementType(null);
//     }
//   };

//   const moveLayerUp = () => {
//     if (selectedIndex !== null && selectedIndex < elements.length - 1) {
//       const newElements = [...elements];
//       const temp = newElements[selectedIndex + 1];
//       newElements[selectedIndex + 1] = newElements[selectedIndex];
//       newElements[selectedIndex] = temp;
//       setElements(newElements);
//       setSelectedIndex(selectedIndex + 1);
//     }
//   };

//   const moveLayerDown = () => {
//     if (selectedIndex !== null && selectedIndex > 0) {
//       const newElements = [...elements];
//       const temp = newElements[selectedIndex - 1];
//       newElements[selectedIndex - 1] = newElements[selectedIndex];
//       newElements[selectedIndex] = temp;
//       setElements(newElements);
//       setSelectedIndex(selectedIndex - 1);
//     }
//   };

//   const updateElement = (key, value) => {
//     if (selectedIndex === null) return;
//     const newElements = [...elements];
//     newElements[selectedIndex][key] = value;
//     setElements(newElements);
//   };

//   const getEffectiveFontSize = () => {
//     if (selectedIndex === null) return 18;
//     return elements[selectedIndex].baseFontSize * elements[selectedIndex].scaleX;
//   };

//   const setEffectiveFontSize = (value) => {
//     if (selectedIndex === null) return;
//     updateElement('baseFontSize', value / elements[selectedIndex].scaleX);
//   };

//   const getEffectiveWidth = () => {
//     if (selectedIndex === null) return 100;
//     return elements[selectedIndex].baseWidth * elements[selectedIndex].scaleX;
//   };

//   const setEffectiveWidth = (value) => {
//     if (selectedIndex === null) return;
//     updateElement('baseWidth', value / elements[selectedIndex].scaleX);
//     if (lockAspectRatio) {
//       updateElement('baseHeight', value / elements[selectedIndex].scaleX);
//     }
//   };

//   const getEffectiveHeight = () => {
//     if (selectedIndex === null) return 100;
//     return elements[selectedIndex].baseHeight * elements[selectedIndex].scaleY;
//   };

//   const setEffectiveHeight = (value) => {
//     if (selectedIndex === null) return;
//     updateElement('baseHeight', value / elements[selectedIndex].scaleY);
//     if (lockAspectRatio) {
//       updateElement('baseWidth', value / elements[selectedIndex].scaleY);
//     }
//   };

//   const handleSave = async () => {
//     const token = localStorage.getItem('token');
//     const body = {
//       fullname: "AlexTest",
//       elements: elements.map(el => toJson(el)),
//     };
//     try {
//       const response = await fetch(`${baseUrl}/cards/`, {
//         method: 'POST',
//         headers: {
//           'Authorization': `Bearer ${token}`,
//           'Content-Type': 'application/json',
//         },
//         body: JSON.stringify(body),
//       });
//       if (response.ok) {
//         toast.success('Успешно');
//         navigate('/list');
//       } else {
//         toast.error('Ошибка');
//       }
//     } catch (error) {
//       toast.error('Ошибка');
//     }
//   };

//   const handleBack = () => {
//     navigate('/list');
//   };

//   const toJson = (el) => {
//     const matrix = computeMatrix(el);
//     const colorHex = (el.color || '#FFFFFF').replace('#', '');
//     const textColorHex = (el.textColor || '#FFFFFF').replace('#', '');
//     return {
//       type: el.type,
//       matrix: '[' + matrix.join(',') + ']',
//       rotation_angle: el.rotation,
//       scale_factor: (el.scaleX + el.scaleY) / 2,
//       width: el.baseWidth || 100,
//       height: el.baseHeight || 100,
//       color: '#FF' + colorHex.toUpperCase().padStart(6, '0'),
//       text: el.text,
//       font_size: el.baseFontSize,
//       base_font_size: el.baseFontSize,
//       font_family: el.fontFamily,
//       font_weight: el.fontWeight === 'bold' ? 'bold' : 'normal',
//       text_color: '#FF' + textColorHex.toUpperCase().padStart(6, '0'),
//       shape_type: el.shapeType,
//       image_url: null,
//       image_opacity: el.opacity || 1.0,
//     };
//   };

//   const computeMatrix = (el) => {
//     const angle = el.rotation * Math.PI / 180;
//     const c = Math.cos(angle);
//     const s = Math.sin(angle);
//     const sx = el.scaleX;
//     const sy = el.scaleY;
//     const tx = el.x;
//     const ty = el.y;
//     return [
//       sx * c,
//       sy * (-s),
//       0,
//       0,
//       sx * s,
//       sy * c,
//       0,
//       0,
//       0,
//       0,
//       1,
//       0,
//       tx,
//       ty,
//       0,
//       1
//     ];
//   };

//   const getCreateButtonText = () => {
//     switch (selectedElementType) {
//       case ElementType.text:
//         return 'Добавить текст';
//       case ElementType.shape:
//         return 'Добавить фигуру';
//       case ElementType.image:
//         return 'Добавить изображение';
//       case ElementType.background:
//         return 'Изменить задний фон';
//       default:
//         return 'Выберите элемент';
//     }
//   };

//   const renderElement = (el) => {
//     switch (el.type) {
//       case ElementType.text:
//         return <Text text={el.text} fontSize={el.baseFontSize} fill={el.textColor} fontFamily={el.fontFamily} fontStyle={el.fontWeight === 'bold' ? 'bold' : 'normal'} />;
//       case ElementType.shape:
//         switch (el.shapeType) {
//           case ShapeType.square:
//             return <Rect width={el.baseWidth} height={el.baseHeight} fill={el.color} />;
//           case ShapeType.circle:
//             return <Ellipse radiusX={el.baseWidth / 2} radiusY={el.baseHeight / 2} fill={el.color} />;
//           case ShapeType.triangle:
//             return <Path data={`M${el.baseWidth / 2} 0 L0 ${el.baseHeight} L${el.baseWidth} ${el.baseHeight} Z`} fill={el.color} />;
//           default:
//             return null;
//         }
//       case ElementType.image:
//         const [image] = useImage(el.imageSrc);
//         if (!image) {
//           return <Rect width={el.baseWidth} height={el.baseHeight} fill="grey" />;
//         }
//         return <KonvaImage image={image} width={el.baseWidth} height={el.baseHeight} opacity={el.opacity} />;
//       default:
//         return null;
//     }
//   };

//   const getLabelAndIcon = (item) => {
//     let label, icon;
//     if (item.type === ElementType.text) {
//       label = item.text || "Текст";
//       icon = <TextFieldsIcon sx={{ fontSize: 18, color: 'white' }} />;
//     } else if (item.type === ElementType.shape) {
//       label = shapeLabels[item.shapeType] || item.shapeType;
//       let shapeIcon;
//       switch (item.shapeType) {
//         case ShapeType.circle:
//           shapeIcon = <CropSquare sx={{ transform: 'rotate(45deg)', color: 'white', fontSize: 18 }} />;
//           break;
//         case ShapeType.square:
//           shapeIcon = <CropSquare sx={{ color: 'white', fontSize: 18 }} />;
//           break;
//         case ShapeType.triangle:
//           shapeIcon = <ArrowUpward sx={{ transform: 'rotate(180deg)', color: 'white', fontSize: 18 }} />;
//           break;
//         default:
//           shapeIcon = <CropSquare sx={{ color: 'white', fontSize: 18 }} />;
//       }
//       icon = shapeIcon;
//     } else if (item.type === ElementType.image) {
//       label = 'Изображение';
//       icon = <ImageIcon sx={{ fontSize: 18, color: 'white' }} />;
//     } else {
//       label = "Элемент";
//       icon = <FormatPaint sx={{ fontSize: 18, color: 'white' }} />;
//     }
//     return { label, icon };
//   };

//   const renderSettings = () => {
//     if (selectedIndex === null && selectedElementType !== ElementType.background) {
//       return (
//         <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>
//           <Button onClick={handleAddElement} sx={{ padding: '16px 32px', backgroundColor: 'grey.900', borderRadius: 3, color: 'white' }}>
//             {getCreateButtonText()}
//           </Button>
//         </Box>
//       );
//     }

//     if (selectedElementType === ElementType.background && selectedIndex === null) {
//       return (
//         <Box sx={{ p: 2 }}>
//           <Typography sx={{ color: 'white', mb: 2 }}>Изменить задний фон</Typography>
//           <Box sx={{ display: 'flex', gap: 2, mb: 2 }}>
//             <Box>
//               <Typography sx={{ color: 'white' }}>Начальный цвет</Typography>
//               <HexColorPicker color={backgroundGradient[0]} onChange={(color) => setBackgroundGradient([color, backgroundGradient[1]])} />
//             </Box>
//             <Box>
//               <Typography sx={{ color: 'white' }}>Конечный цвет</Typography>
//               <HexColorPicker color={backgroundGradient[1]} onChange={(color) => setBackgroundGradient([backgroundGradient[0], color])} />
//             </Box>
//           </Box>
//         </Box>
//       );
//     }

//     if (selectedIndex === null) return null;

//     const el = elements[selectedIndex];

//     const renderLayerButtons = () => (
//       <Box sx={{ display: 'flex', gap: 1, mb: 2 }}>
//         <Button variant="outlined" onClick={moveLayerUp} sx={{ flex: 1, color: 'white', borderColor: 'white', backgroundColor: 'grey.900' }}>
//           На передний план
//         </Button>
//         <Button variant="outlined" onClick={moveLayerDown} sx={{ flex: 1, color: 'white', borderColor: 'white', backgroundColor: 'grey.900' }}>
//           На задний план
//         </Button>
//       </Box>
//     );

//     const renderCustomSlider = (label, value, min, max, onChange) => (
//       <Box sx={{ mb: 2 }}>
//         <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
//           <Typography sx={{ color: 'white' }}>{label}</Typography>
//           <TextField value={value.toFixed(1)} onChange={(e) => onChange(parseFloat(e.target.value) || value)} sx={{ ml: 2, width: 70, input: { color: 'white' } }} />
//         </Box>
//         <Slider value={value} min={min} max={max} step={0.1} onChange={(_, v) => onChange(v)} sx={{ color: 'white' }} />
//       </Box>
//     );

//     const renderColorPickerButton = (colorKey, label) => (
//       <Button onClick={() => { setShowColorPicker(true); setColorPickerType(colorKey); }} sx={{ display: 'flex', alignItems: 'center', backgroundColor: 'grey.800', border: 1, borderColor: 'grey.500', borderRadius: 1, p: 1, mb: 2 }}>
//         <Box sx={{ width: 24, height: 24, bgcolor: el[colorKey], borderRadius: 1, border: 1, borderColor: 'white', mr: 1 }} />
//         <Typography sx={{ color: 'white' }}>{label}</Typography>
//       </Button>
//     );

//     if (el.type === ElementType.text) {
//       return (
//         <Box sx={{ p: 2 }}>
//           {renderLayerButtons()}
//           <Box sx={{ display: 'flex', gap: 1, mb: 2 }}>
//             <TextField label="Текст" value={el.text} onChange={(e) => updateElement('text', e.target.value)} sx={{ flex: 3, '& .MuiInputBase-input': { color: 'white' }, '& .MuiFormLabel-root': { color: 'white' }, bgcolor: 'grey.800' }} />
//             <Select value={el.fontWeight} onChange={(e) => updateElement('fontWeight', e.target.value)} sx={{ flex: 2, color: 'white', bgcolor: 'grey.800' }}>
//               <MenuItem value="normal">Обычный</MenuItem>
//               <MenuItem value="bold">Жирный</MenuItem>
//               <MenuItem value="300">Легкий</MenuItem>
//             </Select>
//           </Box>
//           <Box sx={{ display: 'flex', gap: 1, mb: 2 }}>
//             <Select value={el.fontFamily} onChange={(e) => updateElement('fontFamily', e.target.value)} sx={{ flex: 2, color: 'white', bgcolor: 'grey.800' }}>
//               <MenuItem value="Roboto">Roboto</MenuItem>
//               <MenuItem value="Arial">Arial</MenuItem>
//               <MenuItem value="Times New Roman">Times New Roman</MenuItem>
//               <MenuItem value="Courier New">Courier New</MenuItem>
//             </Select>
//             {renderColorPickerButton('textColor', 'Цвет текста')}
//           </Box>
//           {renderCustomSlider('Размер шрифта', getEffectiveFontSize(), 8, 36, setEffectiveFontSize)}
//           {renderCustomSlider('Поворот (°)', el.rotation, -180, 180, (v) => updateElement('rotation', v))}
//         </Box>
//       );
//     } else if (el.type === ElementType.shape) {
//       return (
//         <Box sx={{ p: 2 }}>
//           {renderLayerButtons()}
//           {renderCustomSlider('Высота', getEffectiveHeight(), 20, 500, setEffectiveHeight)}
//           <IconButton onClick={() => setLockAspectRatio(!lockAspectRatio)} sx={{ color: 'white' }}>
//             {lockAspectRatio ? <Lock /> : <LockOpen />}
//           </IconButton>
//           {renderCustomSlider('Ширина', getEffectiveWidth(), 20, 500, setEffectiveWidth)}
//           <Box sx={{ display: 'flex', gap: 1, mb: 2 }}>
//             <Select value={el.shapeType} onChange={(e) => updateElement('shapeType', e.target.value)} sx={{ flex: 1, color: 'white', bgcolor: 'grey.800' }}>
//               {Object.keys(ShapeType).map((key) => (
//                 <MenuItem key={key} value={key}>{shapeLabels[key]}</MenuItem>
//               ))}
//             </Select>
//             {renderColorPickerButton('color', 'Цвет фигуры')}
//           </Box>
//           {renderCustomSlider('Поворот (°)', el.rotation, -180, 180, (v) => updateElement('rotation', v))}
//         </Box>
//       );
//     } else if (el.type === ElementType.image) {
//       return (
//         <Box sx={{ p: 2 }}>
//           {renderLayerButtons()}
//           {renderCustomSlider('Высота', getEffectiveHeight(), 20, 500, setEffectiveHeight)}
//           <IconButton onClick={() => setLockAspectRatio(!lockAspectRatio)} sx={{ color: 'white' }}>
//             {lockAspectRatio ? <Lock /> : <LockOpen />}
//           </IconButton>
//           {renderCustomSlider('Ширина', getEffectiveWidth(), 20, 500, setEffectiveWidth)}
//           {renderCustomSlider('Прозрачность', el.opacity, 0.1, 1.0, (v) => updateElement('opacity', v))}
//           {renderCustomSlider('Поворот (°)', el.rotation, -180, 180, (v) => updateElement('rotation', v))}
//         </Box>
//       );
//     }
//   };

//   const handleColorChange = (color) => {
//     if (colorPickerType === 'backgroundStart') {
//       setBackgroundGradient([color, backgroundGradient[1]]);
//     } else if (colorPickerType === 'backgroundEnd') {
//       setBackgroundGradient([backgroundGradient[0], color]);
//     } else if (selectedIndex !== null) {
//       updateElement(colorPickerType, color);
//     }
//   };

//   const handleBottomClick = (type) => {
//     setSelectedElementType(type);
//     setSelectedIndex(null);
//     if (type === ElementType.background) {
//       setColorPickerType('backgroundStart'); // Optional, or handle in settings
//     }
//   };

//   return (
//     <Box className={classes.container}>
//       <Box className={classes.header}>
//         <IconButton onClick={handleBack}>
//           <ArrowBack sx={{ color: 'purpleAccent.main' }} />
//         </IconButton>
//         <Typography sx={{ fontWeight: 'bold', fontSize: 18, color: 'white' }}>Конструктор визитки</Typography>
//         <IconButton onClick={handleSave}>
//           <Check sx={{ color: 'white' }} />
//         </IconButton>
//       </Box>
//       <Divider sx={{ bgcolor: 'white', height: 1 }} />
//       <Box sx={{ overflowX: 'auto', whiteSpace: 'nowrap', p: 1 }}>
//         <Box sx={{ display: 'inline-flex', gap: 1 }}>
//           {elements.map((item, index) => {
//             const { label, icon } = getLabelAndIcon(item);
//             return (
//               <Button key={index} onClick={() => handleSelect(index)} sx={{ bgcolor: selectedIndex === index ? 'rgba(156, 39, 176, 0.3)' : '#141218', border: selectedIndex === index ? '2px solid purpleAccent.main' : '1px solid grey.700', color: 'white', gap: 1, textTransform: 'none' }}>
//                 {icon}
//                 {label}
//               </Button>
//             );
//           })}
//         </Box>
//       </Box>
//       <Box ref={containerRef} className={classes.cardWrapper}>
//         <Stage width={stageWidth} height={stageHeight} ref={stageRef} onTap={handleDeselect} onClick={handleDeselect}>
//           <Layer>
//             <Rect 
//               width={stageWidth} 
//               height={stageHeight} 
//               fillLinearGradientStartPoint={{ x: 0, y: 0 }} 
//               fillLinearGradientEndPoint={{ x: stageWidth, y: stageHeight }} 
//               fillLinearGradientColorStops={[0, backgroundGradient[0], 1, backgroundGradient[1]]} 
//             />
//             {elements.map((el, i) => (
//               <Group
//                 key={i}
//                 x={el.x}
//                 y={el.y}
//                 scaleX={el.scaleX}
//                 scaleY={el.scaleY}
//                 rotation={el.rotation}
//                 draggable
//                 onDragEnd={handleDragEnd(i)}
//                 onTransformEnd={handleTransformEnd(i)}
//                 onTap={() => handleSelect(i)}
//                 onClick={() => handleSelect(i)}
//                 ref={(ref) => (nodeRefs.current[i] = ref)}
//               >
//                 {renderElement(el)}
//               </Group>
//             ))}
//             <Transformer ref={transformerRef} keepRatio={lockAspectRatio} />
//           </Layer>
//         </Stage>
//       </Box>
//       {selectedIndex !== null && (
//         <Box sx={{ textAlign: 'right', pr: 2 }}>
//           <IconButton onClick={handleRemove} sx={{ bgcolor: 'grey.800', color: 'white' }}>
//             <Delete />
//           </IconButton>
//         </Box>
//       )}
//       <Box className={classes.settings}>
//         {renderSettings()}
//       </Box>
//       <Box className={classes.bottomBar}>
//         <IconButton onClick={() => handleBottomClick(ElementType.text)} sx={{ color: selectedElementType === ElementType.text ? 'purpleAccent.main' : 'grey.main', display: 'flex', flexDirection: 'column' }}>
//           <TextFieldsIcon />
//           <Typography sx={{ fontSize: 12 }}>Текст</Typography>
//         </IconButton>
//         <IconButton onClick={() => handleBottomClick(ElementType.shape)} sx={{ color: selectedElementType === ElementType.shape ? 'purpleAccent.main' : 'grey.main', display: 'flex', flexDirection: 'column' }}>
//           <CropSquare />
//           <Typography sx={{ fontSize: 12 }}>Фигура</Typography>
//         </IconButton>
//         <IconButton onClick={() => handleBottomClick(ElementType.image)} sx={{ color: selectedElementType === ElementType.image ? 'purpleAccent.main' : 'grey.main', display: 'flex', flexDirection: 'column' }}>
//           <ImageIcon />
//           <Typography sx={{ fontSize: 12 }}>Изображение</Typography>
//         </IconButton>
//         <IconButton onClick={() => handleBottomClick(ElementType.background)} sx={{ color: selectedElementType === ElementType.background ? 'purpleAccent.main' : 'grey.main', display: 'flex', flexDirection: 'column' }}>
//           <FormatPaint />
//           <Typography sx={{ fontSize: 12 }}>Фон</Typography>
//         </IconButton>
//       </Box>
//       <input type="file" accept="image/*" ref={fileInputRef} style={{ display: 'none' }} onChange={handleImageChange} />
//       <Dialog open={showColorPicker} onClose={() => setShowColorPicker(false)}>
//         <DialogTitle>Выберите цвет</DialogTitle>
//         <DialogContent>
//           <HexColorPicker color={colorPickerType === 'backgroundStart' ? backgroundGradient[0] : colorPickerType === 'backgroundEnd' ? backgroundGradient[1] : elements[selectedIndex]?.[colorPickerType] || '#FFFFFF'} onChange={handleColorChange} />
//         </DialogContent>
//         <DialogActions>
//           <Button onClick={() => setShowColorPicker(false)}>OK</Button>
//         </DialogActions>
//       </Dialog>
//     </Box>
//   );
// };

// export default VisitCardDesigner;

// VisitCardDesigner.jsx
import React, { useState, useRef, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { Stage, Layer, Text, Rect, Ellipse, Path, Image as KonvaImage, Transformer, Group } from 'react-konva';
import useImage from 'use-image';
import { HexColorPicker } from 'react-colorful';
import { Box, Typography, IconButton, TextField, Select, MenuItem, Slider, Button, Divider, Dialog, DialogTitle, DialogContent, DialogActions } from '@mui/material';
import { ArrowBack, Check, TextFields as TextFieldsIcon, CropSquare, Image as ImageIcon, FormatPaint, Lock, LockOpen, Delete, ArrowUpward, ArrowDownward } from '@mui/icons-material';
import { toast } from 'react-toastify';
import classes from './VisitCardDesigner.module.css';

const ElementType = {
  text: 'text',
  shape: 'shape',
  image: 'image',
  background: 'background'
};

const ShapeType = {
  square: 'square',
  circle: 'circle',
  triangle: 'triangle'
};

const shapeLabels = {
  square: "Квадрат",
  circle: "Круг",
  triangle: "Треугольник"
};

const VisitCardDesigner = () => {
  const baseUrl = import.meta.env.VITE_BASE_URL;
  const navigate = useNavigate();
  const { id } = useParams();

  const [elements, setElements] = useState([]);
  const [selectedIndex, setSelectedIndex] = useState(null);
  const [selectedElementType, setSelectedElementType] = useState(null);
  const [lockAspectRatio, setLockAspectRatio] = useState(false);
  const [showColorPicker, setShowColorPicker] = useState(false);
  const [colorPickerType, setColorPickerType] = useState(null);
  const [backgroundGradient, setBackgroundGradient] = useState(['#2196F3', '#E040FB']);
  const [stageWidth, setStageWidth] = useState(0);
  const [stageHeight, setStageHeight] = useState(200);
  const [cardData, setCardData] = useState({ fullname: 'AlexTest' }); // Для хранения fullname и других данных визитки

  const stageRef = useRef(null);
  const transformerRef = useRef(null);
  const nodeRefs = useRef([]);
  const containerRef = useRef(null);
  const fileInputRef = useRef(null);

  useEffect(() => {
    const updateDimensions = () => {
      if (containerRef.current) {
        setStageWidth(containerRef.current.clientWidth);
        setStageHeight(containerRef.current.clientHeight);
      }
    };
    updateDimensions();
    window.addEventListener('resize', updateDimensions);
    return () => window.removeEventListener('resize', updateDimensions);
  }, []);

  useEffect(() => {
    if (id) {
      loadCard(id);
    } else {
      // Default elements for new card
      setElements([
        {
          type: ElementType.shape,
          x: 100,
          y: 50,
          scaleX: 1,
          scaleY: 1,
          rotation: 0,
          shapeType: ShapeType.circle,
          color: '#FF0000',
          baseWidth: 100,
          baseHeight: 100
        },
        {
          type: ElementType.text,
          x: 150,
          y: 80,
          scaleX: 1,
          scaleY: 1,
          rotation: 0,
          text: "Name",
          baseFontSize: 18,
          fontFamily: 'Roboto',
          fontWeight: 'normal',
          textColor: '#FFFFFF'
        },
        {
          type: ElementType.text,
          x: 150,
          y: 110,
          scaleX: 1,
          scaleY: 1,
          rotation: 0,
          text: "Info",
          baseFontSize: 18,
          fontFamily: 'Roboto',
          fontWeight: 'normal',
          textColor: '#FFFFFF'
        }
      ]);
    }
  }, [id]);

  const loadCard = async (cardId) => {
    const token = localStorage.getItem('token');
    try {
      const response = await fetch(`${baseUrl}/cards/${cardId}`, {
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      });
      if (response.ok) {
        const data = await response.json();
        setCardData({ fullname: data.fullname }); // Можно добавить другие поля
        const parsedElements = data.elements.map(parseElement);
        setElements(parsedElements);
      } else {
        toast.error('Ошибка загрузки визитки');
      }
    } catch (error) {
      toast.error('Ошибка');
    }
  };

  const parseElement = (el) => {
    const parsed = parseMatrix(el.matrix);
    return {
      type: el.type,
      x: parsed.x,
      y: parsed.y,
      scaleX: parsed.scaleX,
      scaleY: parsed.scaleY,
      rotation: parsed.rotation,
      text: el.text,
      baseFontSize: el.base_font_size || el.font_size,
      fontFamily: el.font_family,
      fontWeight: el.font_weight,
      textColor: el.text_color,
      shapeType: el.shape_type,
      color: el.color,
      baseWidth: el.width,
      baseHeight: el.height,
      imageSrc: el.image_url,
      opacity: el.image_opacity
    };
  };

  const parseMatrix = (matrixStr) => {
    const matrix = JSON.parse(matrixStr);
    const scaleX = Math.sqrt(matrix[0]**2 + matrix[1]**2);
    const scaleY = Math.sqrt(matrix[4]**2 + matrix[5]**2);
    const rotation = Math.atan2(matrix[4], matrix[0]) * 180 / Math.PI;
    const x = matrix[12];
    const y = matrix[13];
    return { x, y, scaleX, scaleY, rotation };
  };

  useEffect(() => {
    if (selectedIndex !== null) {
      const node = nodeRefs.current[selectedIndex];
      if (node) {
        transformerRef.current.nodes([node]);
        transformerRef.current.getLayer().batchDraw();
      }
    } else {
      transformerRef.current.nodes([]);
    }
  }, [selectedIndex]);

  const handleSelect = (index) => {
    setSelectedIndex(index);
    setSelectedElementType(elements[index].type);
  };

  const handleDeselect = (e) => {
    if (e.target === stageRef.current) {
      setSelectedIndex(null);
    }
  };

  const handleDragEnd = (index) => (e) => {
    const newElements = [...elements];
    newElements[index].x = e.target.x();
    newElements[index].y = e.target.y();
    setElements(newElements);
  };

  const handleTransformEnd = (index) => (e) => {
    const node = e.target;
    const newElements = [...elements];
    newElements[index].x = node.x();
    newElements[index].y = node.y();
    newElements[index].scaleX = node.scaleX();
    newElements[index].scaleY = node.scaleY();
    newElements[index].rotation = node.rotation();
    setElements(newElements);
  };

  const handleAddElement = () => {
    if (!selectedElementType) return;

    const centerX = stageWidth / 2;
    const centerY = stageHeight / 2;

    let newElement;
    switch (selectedElementType) {
      case ElementType.text:
        newElement = {
          type: ElementType.text,
          x: centerX,
          y: centerY,
          scaleX: 1,
          scaleY: 1,
          rotation: 0,
          text: "Example",
          baseFontSize: 18,
          fontFamily: 'Roboto',
          fontWeight: 'normal',
          textColor: '#FFFFFF'
        };
        break;
      case ElementType.shape:
        newElement = {
          type: ElementType.shape,
          x: centerX,
          y: centerY,
          scaleX: 1,
          scaleY: 1,
          rotation: 0,
          shapeType: ShapeType.circle,
          color: '#FF0000',
          baseWidth: 100,
          baseHeight: 100
        };
        break;
      case ElementType.image:
        fileInputRef.current.click();
        return;
      case ElementType.background:
        // Handled in settings
        return;
      default:
        return;
    }
    setElements([...elements, newElement]);
    setSelectedIndex(elements.length);
  };

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (ev) => {
        const centerX = stageWidth / 2;
        const centerY = stageHeight / 2;
        const newElement = {
          type: ElementType.image,
          x: centerX,
          y: centerY,
          scaleX: 1,
          scaleY: 1,
          rotation: 0,
          imageSrc: ev.target.result,
          baseWidth: 100,
          baseHeight: 100,
          opacity: 1.0
        };
        setElements([...elements, newElement]);
        setSelectedIndex(elements.length);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleRemove = () => {
    if (selectedIndex !== null) {
      const newElements = elements.filter((_, i) => i !== selectedIndex);
      setElements(newElements);
      setSelectedIndex(null);
      setSelectedElementType(null);
    }
  };

  const moveLayerUp = () => {
    if (selectedIndex !== null && selectedIndex < elements.length - 1) {
      const newElements = [...elements];
      const temp = newElements[selectedIndex + 1];
      newElements[selectedIndex + 1] = newElements[selectedIndex];
      newElements[selectedIndex] = temp;
      setElements(newElements);
      setSelectedIndex(selectedIndex + 1);
    }
  };

  const moveLayerDown = () => {
    if (selectedIndex !== null && selectedIndex > 0) {
      const newElements = [...elements];
      const temp = newElements[selectedIndex - 1];
      newElements[selectedIndex - 1] = newElements[selectedIndex];
      newElements[selectedIndex] = temp;
      setElements(newElements);
      setSelectedIndex(selectedIndex - 1);
    }
  };

  const updateElement = (key, value) => {
    if (selectedIndex === null) return;
    const newElements = [...elements];
    newElements[selectedIndex][key] = value;
    setElements(newElements);
  };

  const getEffectiveFontSize = () => {
    if (selectedIndex === null) return 18;
    return elements[selectedIndex].baseFontSize * elements[selectedIndex].scaleX;
  };

  const setEffectiveFontSize = (value) => {
    if (selectedIndex === null) return;
    updateElement('baseFontSize', value / elements[selectedIndex].scaleX);
  };

  const getEffectiveWidth = () => {
    if (selectedIndex === null) return 100;
    return elements[selectedIndex].baseWidth * elements[selectedIndex].scaleX;
  };

  const setEffectiveWidth = (value) => {
    if (selectedIndex === null) return;
    updateElement('baseWidth', value / elements[selectedIndex].scaleX);
    if (lockAspectRatio) {
      updateElement('baseHeight', value / elements[selectedIndex].scaleX);
    }
  };

  const getEffectiveHeight = () => {
    if (selectedIndex === null) return 100;
    return elements[selectedIndex].baseHeight * elements[selectedIndex].scaleY;
  };

  const setEffectiveHeight = (value) => {
    if (selectedIndex === null) return;
    updateElement('baseHeight', value / elements[selectedIndex].scaleY);
    if (lockAspectRatio) {
      updateElement('baseWidth', value / elements[selectedIndex].scaleY);
    }
  };

  const handleSave = async () => {
    const token = localStorage.getItem('token');
    const body = {
      fullname: cardData.fullname,
      elements: elements.map(el => toJson(el)),
    };
    const url = id ? `${baseUrl}/cards/${id}` : `${baseUrl}/cards/`;
    const method = id ? 'PUT' : 'POST';
    try {
      const response = await fetch(url, {
        method: method,
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
      });
      if (response.ok) {
        toast.success('Успешно');
        navigate('/list');
      } else {
        toast.error('Ошибка');
      }
    } catch (error) {
      toast.error('Ошибка');
    }
  };

  const handleBack = () => {
    navigate('/list');
  };

//   const toJson = (el) => {
//     const matrix = computeMatrix(el);
//     const colorHex = (el.color || '#FFFFFF').replace('#', '');
//     const textColorHex = (el.textColor || '#FFFFFF').replace('#', '');
//     return {
//       type: el.type,
//       matrix: '[' + matrix.join(',') + ']',
//       rotation_angle: el.rotation,
//       scale_factor: (el.scaleX + el.scaleY) / 2,
//       width: el.baseWidth || 100,
//       height: el.baseHeight || 100,
//       color: '#FF' + colorHex.toUpperCase().padStart(6, '0'),
//       text: el.text,
//       font_size: el.baseFontSize,
//       base_font_size: el.baseFontSize,
//       font_family: el.fontFamily,
//       font_weight: el.fontWeight === 'bold' ? 'bold' : 'normal',
//       text_color: '#FF' + textColorHex.toUpperCase().padStart(6, '0'),
//       shape_type: el.shapeType,
//       image_url: null,
//       image_opacity: el.opacity || 1.0,
//     };
//   };

const toJson = (el) => {
    const matrix = computeMatrix(el);
    const colorHex = (el.color || '#FFFFFF').replace('#', '');
    const textColorHex = (el.textColor || '#FFFFFF').replace('#', '');
    return {
      type: el.type,
      matrix: '[' + matrix.join(',') + ']',  // Соответствует str
      rotation_angle: el.rotation || 0.0,    // Соответствует float
      scale_factor: (el.scaleX + el.scaleY) / 2 || 1.0,  // Соответствует float
      width: el.baseWidth || 100.0,          // Соответствует float
      height: el.baseHeight || 100.0,        // Соответствует float
      color: '#FF' + colorHex.toUpperCase().padStart(6, '0'),  // Соответствует str
      text: el.text,                         // Optional[str]
      base_font_size: el.baseFontSize || null,  // Optional[float], используем null вместо undefined
      font_family: el.fontFamily || null,    // Optional[str]
      font_weight: el.fontWeight === 'bold' ? 'bold' : 'normal' || null,  // Optional[str]
      text_color: '#FF' + textColorHex.toUpperCase().padStart(6, '0') || null,  // Optional[str]
      shape_type: el.shapeType || null,      // Optional[str]
      image_url: null,                       // Optional[str], не используется
      image_opacity: el.opacity || 1.0,      // Соответствует float
    };
  };

  const computeMatrix = (el) => {
    const angle = el.rotation * Math.PI / 180;
    const c = Math.cos(angle);
    const s = Math.sin(angle);
    const sx = el.scaleX;
    const sy = el.scaleY;
    const tx = el.x;
    const ty = el.y;
    return [
      sx * c,
      sy * (-s),
      0,
      0,
      sx * s,
      sy * c,
      0,
      0,
      0,
      0,
      1,
      0,
      tx,
      ty,
      0,
      1
    ];
  };

  const getCreateButtonText = () => {
    switch (selectedElementType) {
      case ElementType.text:
        return 'Добавить текст';
      case ElementType.shape:
        return 'Добавить фигуру';
      case ElementType.image:
        return 'Добавить изображение';
      case ElementType.background:
        return 'Изменить задний фон';
      default:
        return 'Выберите элемент';
    }
  };

  const renderElement = (el) => {
    switch (el.type) {
      case ElementType.text:
        return <Text text={el.text} fontSize={el.baseFontSize} fill={el.textColor} fontFamily={el.fontFamily} fontStyle={el.fontWeight === 'bold' ? 'bold' : 'normal'} />;
      case ElementType.shape:
        switch (el.shapeType) {
          case ShapeType.square:
            return <Rect width={el.baseWidth} height={el.baseHeight} fill={el.color} />;
          case ShapeType.circle:
            return <Ellipse radiusX={el.baseWidth / 2} radiusY={el.baseHeight / 2} fill={el.color} />;
          case ShapeType.triangle:
            return <Path data={`M${el.baseWidth / 2} 0 L0 ${el.baseHeight} L${el.baseWidth} ${el.baseHeight} Z`} fill={el.color} />;
          default:
            return null;
        }
      case ElementType.image:
        const [image] = useImage(el.imageSrc);
        if (!image) {
          return <Rect width={el.baseWidth} height={el.baseHeight} fill="grey" />;
        }
        return <KonvaImage image={image} width={el.baseWidth} height={el.baseHeight} opacity={el.opacity} />;
      default:
        return null;
    }
  };

  const getLabelAndIcon = (item) => {
    let label, icon;
    if (item.type === ElementType.text) {
      label = item.text || "Текст";
      icon = <TextFieldsIcon sx={{ fontSize: 18, color: 'white' }} />;
    } else if (item.type === ElementType.shape) {
      label = shapeLabels[item.shapeType] || item.shapeType;
      let shapeIcon;
      switch (item.shapeType) {
        case ShapeType.circle:
          shapeIcon = <CropSquare sx={{ transform: 'rotate(45deg)', color: 'white', fontSize: 18 }} />;
          break;
        case ShapeType.square:
          shapeIcon = <CropSquare sx={{ color: 'white', fontSize: 18 }} />;
          break;
        case ShapeType.triangle:
          shapeIcon = <ArrowUpward sx={{ transform: 'rotate(180deg)', color: 'white', fontSize: 18 }} />;
          break;
        default:
          shapeIcon = <CropSquare sx={{ color: 'white', fontSize: 18 }} />;
      }
      icon = shapeIcon;
    } else if (item.type === ElementType.image) {
      label = 'Изображение';
      icon = <ImageIcon sx={{ fontSize: 18, color: 'white' }} />;
    } else {
      label = "Элемент";
      icon = <FormatPaint sx={{ fontSize: 18, color: 'white' }} />;
    }
    return { label, icon };
  };

  const renderSettings = () => {
    if (selectedIndex === null && selectedElementType !== ElementType.background) {
      return (
        <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>
          <Button onClick={handleAddElement} sx={{ padding: '16px 32px', backgroundColor: 'grey.900', borderRadius: 3, color: 'white' }}>
            {getCreateButtonText()}
          </Button>
        </Box>
      );
    }

    if (selectedElementType === ElementType.background && selectedIndex === null) {
      return (
        <Box sx={{ p: 2 }}>
          <Typography sx={{ color: 'white', mb: 2 }}>Изменить задний фон</Typography>
          <Box sx={{ display: 'flex', gap: 2, mb: 2 }}>
            <Box>
              <Typography sx={{ color: 'white' }}>Начальный цвет</Typography>
              <HexColorPicker color={backgroundGradient[0]} onChange={(color) => setBackgroundGradient([color, backgroundGradient[1]])} />
            </Box>
            <Box>
              <Typography sx={{ color: 'white' }}>Конечный цвет</Typography>
              <HexColorPicker color={backgroundGradient[1]} onChange={(color) => setBackgroundGradient([backgroundGradient[0], color])} />
            </Box>
          </Box>
        </Box>
      );
    }

    if (selectedIndex === null) return null;

    const el = elements[selectedIndex];

    const renderLayerButtons = () => (
      <Box sx={{ display: 'flex', gap: 1, mb: 2 }}>
        <Button variant="outlined" onClick={moveLayerUp} sx={{ flex: 1, color: 'white', borderColor: 'white', backgroundColor: 'grey.900' }}>
          На передний план
        </Button>
        <Button variant="outlined" onClick={moveLayerDown} sx={{ flex: 1, color: 'white', borderColor: 'white', backgroundColor: 'grey.900' }}>
          На задний план
        </Button>
      </Box>
    );

    const renderCustomSlider = (label, value, min, max, onChange) => (
      <Box sx={{ mb: 2 }}>
        <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
          <Typography sx={{ color: 'white' }}>{label}</Typography>
          <TextField value={value.toFixed(1)} onChange={(e) => onChange(parseFloat(e.target.value) || value)} sx={{ ml: 2, width: 70, input: { color: 'white' } }} />
        </Box>
        <Slider value={value} min={min} max={max} step={0.1} onChange={(_, v) => onChange(v)} sx={{ color: 'white' }} />
      </Box>
    );

    const renderColorPickerButton = (colorKey, label) => (
      <Button onClick={() => { setShowColorPicker(true); setColorPickerType(colorKey); }} sx={{ display: 'flex', alignItems: 'center', backgroundColor: 'grey.800', border: 1, borderColor: 'grey.500', borderRadius: 1, p: 1, mb: 2 }}>
        <Box sx={{ width: 24, height: 24, bgcolor: el[colorKey], borderRadius: 1, border: 1, borderColor: 'white', mr: 1 }} />
        <Typography sx={{ color: 'white' }}>{label}</Typography>
      </Button>
    );

    if (el.type === ElementType.text) {
      return (
        <Box sx={{ p: 2 }}>
          {renderLayerButtons()}
          <Box sx={{ display: 'flex', gap: 1, mb: 2 }}>
            <TextField label="Текст" value={el.text} onChange={(e) => updateElement('text', e.target.value)} sx={{ flex: 3, '& .MuiInputBase-input': { color: 'white' }, '& .MuiFormLabel-root': { color: 'white' }, bgcolor: 'grey.800' }} />
            <Select value={el.fontWeight} onChange={(e) => updateElement('fontWeight', e.target.value)} sx={{ flex: 2, color: 'white', bgcolor: 'grey.800' }}>
              <MenuItem value="normal">Обычный</MenuItem>
              <MenuItem value="bold">Жирный</MenuItem>
              <MenuItem value="300">Легкий</MenuItem>
            </Select>
          </Box>
          <Box sx={{ display: 'flex', gap: 1, mb: 2 }}>
            <Select value={el.fontFamily} onChange={(e) => updateElement('fontFamily', e.target.value)} sx={{ flex: 2, color: 'white', bgcolor: 'grey.800' }}>
              <MenuItem value="Roboto">Roboto</MenuItem>
              <MenuItem value="Arial">Arial</MenuItem>
              <MenuItem value="Times New Roman">Times New Roman</MenuItem>
              <MenuItem value="Courier New">Courier New</MenuItem>
            </Select>
            {renderColorPickerButton('textColor', 'Цвет текста')}
          </Box>
          {renderCustomSlider('Размер шрифта', getEffectiveFontSize(), 8, 36, setEffectiveFontSize)}
          {renderCustomSlider('Поворот (°)', el.rotation, -180, 180, (v) => updateElement('rotation', v))}
        </Box>
      );
    } else if (el.type === ElementType.shape) {
      return (
        <Box sx={{ p: 2 }}>
          {renderLayerButtons()}
          {renderCustomSlider('Высота', getEffectiveHeight(), 20, 500, setEffectiveHeight)}
          <IconButton onClick={() => setLockAspectRatio(!lockAspectRatio)} sx={{ color: 'white' }}>
            {lockAspectRatio ? <Lock /> : <LockOpen />}
          </IconButton>
          {renderCustomSlider('Ширина', getEffectiveWidth(), 20, 500, setEffectiveWidth)}
          <Box sx={{ display: 'flex', gap: 1, mb: 2 }}>
            <Select value={el.shapeType} onChange={(e) => updateElement('shapeType', e.target.value)} sx={{ flex: 1, color: 'white', bgcolor: 'grey.800' }}>
              {Object.keys(ShapeType).map((key) => (
                <MenuItem key={key} value={key}>{shapeLabels[key]}</MenuItem>
              ))}
            </Select>
            {renderColorPickerButton('color', 'Цвет фигуры')}
          </Box>
          {renderCustomSlider('Поворот (°)', el.rotation, -180, 180, (v) => updateElement('rotation', v))}
        </Box>
      );
    } else if (el.type === ElementType.image) {
      return (
        <Box sx={{ p: 2 }}>
          {renderLayerButtons()}
          {renderCustomSlider('Высота', getEffectiveHeight(), 20, 500, setEffectiveHeight)}
          <IconButton onClick={() => setLockAspectRatio(!lockAspectRatio)} sx={{ color: 'white' }}>
            {lockAspectRatio ? <Lock /> : <LockOpen />}
          </IconButton>
          {renderCustomSlider('Ширина', getEffectiveWidth(), 20, 500, setEffectiveWidth)}
          {renderCustomSlider('Прозрачность', el.opacity, 0.1, 1.0, (v) => updateElement('opacity', v))}
          {renderCustomSlider('Поворот (°)', el.rotation, -180, 180, (v) => updateElement('rotation', v))}
        </Box>
      );
    }
  };

  const handleColorChange = (color) => {
    if (colorPickerType === 'backgroundStart') {
      setBackgroundGradient([color, backgroundGradient[1]]);
    } else if (colorPickerType === 'backgroundEnd') {
      setBackgroundGradient([backgroundGradient[0], color]);
    } else if (selectedIndex !== null) {
      updateElement(colorPickerType, color);
    }
  };

  const handleBottomClick = (type) => {
    setSelectedElementType(type);
    setSelectedIndex(null);
    if (type === ElementType.background) {
      setColorPickerType('backgroundStart'); // Optional, or handle in settings
    }
  };

  return (
    <Box className={classes.container}>
      <Box className={classes.header}>
        <IconButton onClick={handleBack}>
          <ArrowBack sx={{ color: 'purpleAccent.main' }} />
        </IconButton>
        <Typography sx={{ fontWeight: 'bold', fontSize: 18, color: 'white' }}>Конструктор визитки</Typography>
        <IconButton onClick={handleSave}>
          <Check sx={{ color: 'white' }} />
        </IconButton>
      </Box>
      <Divider sx={{ bgcolor: 'white', height: 1 }} />
      <Box sx={{ overflowX: 'auto', whiteSpace: 'nowrap', p: 1 }}>
        <Box sx={{ display: 'inline-flex', gap: 1 }}>
          {elements.map((item, index) => {
            const { label, icon } = getLabelAndIcon(item);
            return (
              <Button key={index} onClick={() => handleSelect(index)} sx={{ bgcolor: selectedIndex === index ? 'rgba(156, 39, 176, 0.3)' : '#141218', border: selectedIndex === index ? '2px solid purpleAccent.main' : '1px solid grey.700', color: 'white', gap: 1, textTransform: 'none' }}>
                {icon}
                {label}
              </Button>
            );
          })}
        </Box>
      </Box>
      <Box ref={containerRef} className={classes.cardWrapper}>
        <Stage width={stageWidth} height={stageHeight} ref={stageRef} onTap={handleDeselect} onClick={handleDeselect}>
          <Layer>
            <Rect 
              width={stageWidth} 
              height={stageHeight} 
              fillLinearGradientStartPoint={{ x: 0, y: 0 }} 
              fillLinearGradientEndPoint={{ x: stageWidth, y: stageHeight }} 
              fillLinearGradientColorStops={[0, backgroundGradient[0], 1, backgroundGradient[1]]} 
            />
            {elements.map((el, i) => (
              <Group
                key={i}
                x={el.x}
                y={el.y}
                scaleX={el.scaleX}
                scaleY={el.scaleY}
                rotation={el.rotation}
                draggable
                onDragEnd={handleDragEnd(i)}
                onTransformEnd={handleTransformEnd(i)}
                onTap={() => handleSelect(i)}
                onClick={() => handleSelect(i)}
                ref={(ref) => (nodeRefs.current[i] = ref)}
              >
                {renderElement(el)}
              </Group>
            ))}
            <Transformer ref={transformerRef} keepRatio={lockAspectRatio} />
          </Layer>
        </Stage>
      </Box>
      {selectedIndex !== null && (
        <Box sx={{ textAlign: 'right', pr: 2 }}>
          <IconButton onClick={handleRemove} sx={{ bgcolor: 'grey.800', color: 'white' }}>
            <Delete />
          </IconButton>
        </Box>
      )}
      <Box className={classes.settings}>
        {renderSettings()}
      </Box>
      <Box className={classes.bottomBar}>
        <IconButton onClick={() => handleBottomClick(ElementType.text)} sx={{ color: selectedElementType === ElementType.text ? 'purpleAccent.main' : 'grey.main', display: 'flex', flexDirection: 'column' }}>
          <TextFieldsIcon />
          <Typography sx={{ fontSize: 12 }}>Текст</Typography>
        </IconButton>
        <IconButton onClick={() => handleBottomClick(ElementType.shape)} sx={{ color: selectedElementType === ElementType.shape ? 'purpleAccent.main' : 'grey.main', display: 'flex', flexDirection: 'column' }}>
          <CropSquare />
          <Typography sx={{ fontSize: 12 }}>Фигура</Typography>
        </IconButton>
        <IconButton onClick={() => handleBottomClick(ElementType.image)} sx={{ color: selectedElementType === ElementType.image ? 'purpleAccent.main' : 'grey.main', display: 'flex', flexDirection: 'column' }}>
          <ImageIcon />
          <Typography sx={{ fontSize: 12 }}>Изображение</Typography>
        </IconButton>
        <IconButton onClick={() => handleBottomClick(ElementType.background)} sx={{ color: selectedElementType === ElementType.background ? 'purpleAccent.main' : 'grey.main', display: 'flex', flexDirection: 'column' }}>
          <FormatPaint />
          <Typography sx={{ fontSize: 12 }}>Фон</Typography>
        </IconButton>
      </Box>
      <input type="file" accept="image/*" ref={fileInputRef} style={{ display: 'none' }} onChange={handleImageChange} />
      <Dialog open={showColorPicker} onClose={() => setShowColorPicker(false)}>
        <DialogTitle>Выберите цвет</DialogTitle>
        <DialogContent>
          <HexColorPicker color={colorPickerType === 'backgroundStart' ? backgroundGradient[0] : colorPickerType === 'backgroundEnd' ? backgroundGradient[1] : elements[selectedIndex]?.[colorPickerType] || '#FFFFFF'} onChange={handleColorChange} />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setShowColorPicker(false)}>OK</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default VisitCardDesigner;

