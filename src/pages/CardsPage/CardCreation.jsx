import { useState } from "react";
import { Upload, Modal, Button, Flex, Form, Input } from "antd";
import ImgCrop from "antd-img-crop";
import { PlusOutlined } from "@ant-design/icons";
import classes from './CardCreation.module.css';
import './CardCreation.css';

const CardCreation = () => {

    //  ЧАСТЬ ДЛЯ ФОТОГРАФИИ. ПОКА В АПИ ФОТОК НЕТ - НЕ ВОРКАЕТ

    const [fileList, setFileList] = useState([]);
    //   const [previewVisible, setPreviewVisible] = useState(false);
    //   const [previewImage, setPreviewImage] = useState('');
    //   const [previewTitle, setPreviewTitle] = useState('');

    //   const handleChange = ({ fileList: newFileList }) => {
    //     setFileList(newFileList.slice(-1));
    //   };

    //   const handlePreview = async (file) => {
    //     let src = file.url || file.thumbUrl;
    //     if (!src && file.originFileObj) {
    //       src = await new Promise(resolve => {
    //         const reader = new FileReader();
    //         reader.readAsDataURL(file.originFileObj);
    //         reader.onload = () => resolve(reader.result);
    //       });
    //     }
    //     setPreviewImage(src);
    //     setPreviewVisible(true);
    //     setPreviewTitle(file.name || 'Preview');
    //   };

    //   const handleUpload = async () => {
    //     if (!fileList.length || !fileList[0].originFileObj) {
    //       return alert("Пожалуйста, загрузите фото.");
    //     }

    //     const formData = new FormData();
    //     formData.append("image", fileList[0].originFileObj);

    //     try {
    //       const response = await axios.post("/api/upload", formData, {
    //         headers: {
    //           "Content-Type": "multipart/form-data",
    //         },
    //       });

    //       console.log("Фото успешно загружено:", response.data);

    //     } catch (error) {
    //       console.error("Ошибка при загрузке изображения:", error);
    //       alert("Ошибка загрузки файла.");
    //     }
    //   };

    return (
        <>
            <h2>Создание визитки</h2>
            <div className={classes.container}>
                {/* ЗАГЛУШКА */}
                <Flex gap='large' className={classes.creationContainer}>

                    <Flex vertical className={classes.cardImageContainer}>

                        <Upload name="avatar"
                            fileList={fileList}
                            listType="picture-card" disabled>
                            {fileList.length < 1 && (
                                <div>
                                    <PlusOutlined />
                                    <div style={{ marginTop: 8 }}>Загрузить</div>
                                </div>
                            )}
                        </Upload>

                    </Flex>
                    <Flex vertical className={classes.cardFormContainer} align="center">
                        <Form
                            className={classes.cardForm}
                            name="layout-multiple-vertical"
                            layout="vertical"
                            labelCol={{ span: 4 }}
                            wrapperCol={{ span: 20 }}
                        >
                            {/* <Form.Item label="Имя" name="vertical" rules={[{ required: true }]}>
                                <Input placeholder="Введите Ваше имя" maxLength={255}/>
                            </Form.Item> */}
                            <Form.Item
                                name="name"
                                label="Имя"
                                rules={[
                                    { required: true, message: 'Введите имя' },
                                    {
                                        pattern: /^(?!.* {2,})(?!.*--)(?!.* -)(?!.*- )(?![- ])([A-Za-zА-Яа-яЁё]+(?:[- ]?[A-Za-zА-Яа-яЁё]+)*)$/,
                                        message: 'Имя должно содержать только буквы, пробелы и "-", без двойных пробелов/дефисов и не начинаться или заканчиваться ими',
                                    },
                                ]}
                            >
                                <Input maxLength={255} placeholder="Как Вас зовут?" />
                            </Form.Item>

                            <Form.Item
                                name="company"
                                label="Компания"
                                rules={[
                                    { required: true, message: 'Введите название компании, в которой работаете' },
                                    
                                ]}
                            >
                                <Input maxLength={80} placeholder="Где Вы работаете?" />
                            </Form.Item>

                            <Form.Item
                                name="about"
                                label="О себе"
                                rules={[
                                    { required: false},
                                    
                                ]}
                            >
                                <Input.TextArea maxLength={255} placeholder="Что бы Вы хотели рассказать о себе в этой визитке?" />
                            </Form.Item>
                        </Form>
                    </Flex>
                </Flex>



                {/* <ImgCrop
          rotationSlider
          showReset
          onModalOk={(file) => {
            // заменяем originFileObj на обрезанный
            const newFileList = [...fileList];
            const index = newFileList.findIndex(f => f.uid === file.uid);
            if (index !== -1) {
              newFileList[index] = {
                ...file,
                originFileObj: file,
              };
              setFileList(newFileList.slice(-1));
            }
          }}
        >
          <Upload
            listType="picture-card"
            fileList={fileList}
            onChange={handleChange}
            onPreview={handlePreview}
            beforeUpload={() => false} // не загружаем автоматически
          >
            {fileList.length < 1 && (
              <div>
                <PlusOutlined />
                <div style={{ marginTop: 8 }}>Загрузить</div>
              </div>
            )}
          </Upload>
        </ImgCrop>

        <Modal
          open={previewVisible}
          title={previewTitle}
          footer={null}
          onCancel={() => setPreviewVisible(false)}
        >
          <img alt="preview" style={{ width: '100%' }} src={previewImage} />
        </Modal> */}
            </div>
        </>
    );
};

export default CardCreation;
