// // VisitCardPreview.jsx
// import React from 'react';
// import { Stage, Layer, Rect, Text, Ellipse, Path, Image as KonvaImage, Group } from 'react-konva';
// import useImage from 'use-image';
// import { Box } from '@mui/material';


// const VisitCardPreview = ({ elements }) => {
//   const width = window.innerWidth * 0.9;
//   const height = 200;

//   const renderElement = (el) => {
//     switch (el.type) {
//       case 'text':
//         return <Text text={el.text} fontSize={el.baseFontSize} fill={el.textColor} fontFamily={el.fontFamily} fontStyle={el.fontWeight === 'bold' ? 'bold' : 'normal'} />;
//       case 'shape':
//         switch (el.shapeType) {
//           case 'square':
//             return <Rect width={el.baseWidth} height={el.baseHeight} fill={el.color} />;
//           case 'circle':
//             return <Ellipse radiusX={el.baseWidth / 2} radiusY={el.baseHeight / 2} fill={el.color} />;
//           case 'triangle':
//             return <Path data={`M${el.baseWidth / 2} 0 L0 ${el.baseHeight} L${el.baseWidth} ${el.baseHeight} Z`} fill={el.color} />;
//           default:
//             return null;
//         }
//       case 'image':
//         const [image] = useImage(el.imageSrc);
//         if (!image) return <Rect width={el.baseWidth} height={el.baseHeight} fill="grey" />;
//         return <KonvaImage image={image} width={el.baseWidth} height={el.baseHeight} opacity={el.opacity} />;
//       default:
//         return null;
//     }
//   };

//   return (
//     <Box sx={{ width: '90%', height: 200, borderRadius: 3, overflow: 'hidden', boxShadow: '0 4px 10px rgba(0,0,0,0.3)' }}>
//       <Stage width={width} height={height}>
//         <Layer>
//           <Rect width={width} height={height} fillLinearGradientStartPoint={{ x: 0, y: 0 }} fillLinearGradientEndPoint={{ x: width, y: height }} fillLinearGradientColorStops={[0, '#2196F3', 1, '#E040FB']} />
//           {elements.map((el, i) => (
//             <Group key={i} x={el.x} y={el.y} scaleX={el.scaleX} scaleY={el.scaleY} rotation={el.rotation}>
//               {renderElement(el)}
//             </Group>
//           ))}
//         </Layer>
//       </Stage>
//     </Box>
//   );
// };

// export default VisitCardPreview;


// VisitCardPreview.jsx
import React from 'react';
import { Stage, Layer, Rect, Text, Ellipse, Path, Image as KonvaImage, Group } from 'react-konva';
import useImage from 'use-image';
import { Box } from '@mui/material'; // Добавлен импорт Box

const VisitCardPreview = ({ elements }) => {
  const width = window.innerWidth * 0.9;
  const height = 200;

  const renderElement = (el) => {
    switch (el.type) {
      case 'text':
        return <Text text={el.text} fontSize={el.baseFontSize} fill={el.textColor} fontFamily={el.fontFamily} fontStyle={el.fontWeight === 'bold' ? 'bold' : 'normal'} />;
      case 'shape':
        switch (el.shapeType) {
          case 'square':
            return <Rect width={el.baseWidth} height={el.baseHeight} fill={el.color} />;
          case 'circle':
            return <Ellipse radiusX={el.baseWidth / 2} radiusY={el.baseHeight / 2} fill={el.color} />;
          case 'triangle':
            return <Path data={`M${el.baseWidth / 2} 0 L0 ${el.baseHeight} L${el.baseWidth} ${el.baseHeight} Z`} fill={el.color} />;
          default:
            return null;
        }
      case 'image':
        const [image] = useImage(el.imageSrc);
        if (!image) return <Rect width={el.baseWidth} height={el.baseHeight} fill="grey" />;
        return <KonvaImage image={image} width={el.baseWidth} height={el.baseHeight} opacity={el.opacity} />;
      default:
        return null;
    }
  };

  return (
    <Box sx={{ width: '90%', height: 200, borderRadius: 3, overflow: 'hidden', boxShadow: '0 4px 10px rgba(0,0,0,0.3)' }}>
      <Stage width={width} height={height}>
        <Layer>
          <Rect width={width} height={height} fillLinearGradientStartPoint={{ x: 0, y: 0 }} fillLinearGradientEndPoint={{ x: width, y: height }} fillLinearGradientColorStops={[0, '#2196F3', 1, '#E040FB']} />
          {elements.map((el, i) => (
            <Group key={i} x={el.x} y={el.y} scaleX={el.scaleX} scaleY={el.scaleY} rotation={el.rotation}>
              {renderElement(el)}
            </Group>
          ))}
        </Layer>
      </Stage>
    </Box>
  );
};


export default VisitCardPreview;