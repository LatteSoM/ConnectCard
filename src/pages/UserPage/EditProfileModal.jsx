import { useEffect, useState } from 'react';
import { Modal, Input, Form, message, Button } from 'antd';
import axios from 'axios';
import classes from './User.module.css';

const EditProfileModal = ({ visible, onClose, userData, accessToken, onUpdate }) => {
    const [form] = Form.useForm();
    const [phoneInput, setPhoneInput] = useState('');
    const [messageApi, contextHolder] = message.useMessage();
    const [isFormValid, setIsFormValid] = useState(true);


    const validateMessages = {
        required: 'Это поле обязательно!',
        types: {
            email: 'Введите корректную почту!',
            number: 'Введите корректное число!',
        },
        number: {
            range: '${label} должно быть от ${min} до ${max}',
        },
    };

    const formatPhone = (value) => {
        const hasPlus = value.startsWith('+');
        let digits = value.replace(/\D/g, '');

        if (hasPlus && digits.startsWith('7')) {
            digits = '+7' + digits.slice(1);
        } else if (digits.startsWith('8')) {
            digits = '8' + digits.slice(1);
        } else if (digits.startsWith('7')) {
            digits = '+7' + digits.slice(1);
        } else if (digits.startsWith('9')) {
            digits = '8' + digits;
        }

        if (digits.length <= 3) return digits;

        const onlyDigits = digits.replace(/\D/g, '');
        const prefix = digits.startsWith('+7') ? '+7' : '8';
        const part1 = onlyDigits.slice(prefix === '+7' ? 1 : 1, 4);
        const part2 = onlyDigits.slice(4, 7);
        const part3 = onlyDigits.slice(7, 9);
        const part4 = onlyDigits.slice(9, 11);

        let formatted = prefix;
        if (part1) formatted += `(${part1})`;
        if (part2) formatted += `-${part2}`;
        if (part3) formatted += `-${part3}`;
        if (part4) formatted += `-${part4}`;

        return formatted;
    };

    const handlePhoneChange = async (e) => {
        const rawValue = e.target.value;
        const isDeleting = phoneInput.length > rawValue.length;

        if (isDeleting && rawValue.length <= 3) {
            setPhoneInput(rawValue);
            form.setFieldsValue({ phone: rawValue });
            await form.validateFields(['phone']);
            onFormChange();
            return;
        }

        const formatted = formatPhone(rawValue);
        setPhoneInput(formatted);
        form.setFieldsValue({ phone: formatted });
        await form.validateFields(['phone']);
        onFormChange();
    };


    const successMsg = () => {
        messageApi.open({
            type: 'success',
            content: 'Профиль обновлен',
        });
    };

    const errorMsg = () => {
        messageApi.open({
            type: 'error',
            content: 'Произошла ошибка при обновлении профиля',
        });
    };

    const onFormChange = () => {
        const hasErrors = form.getFieldsError().some(({ errors }) => errors.length > 0);
        // console.log(hasErrors);
        setIsFormValid(!hasErrors);
    };


    useEffect(() => {
        if (visible && userData) {
            form.setFieldsValue({
                name: userData.name ?? '',
                email: userData.email ?? '',
                phone: userData.phone ?? '',
            });
        }
    }, [visible, userData, form]);

    const handleSave = async () => {
        try {
            const values = await form.validateFields();
            const payload = {
                name: values.name?.trim() || '',
                email: values.email?.trim() || '',
                phone: values.phone?.trim() || '',
            };

            await axios.put(`http://127.0.0.1:8000/users/${userData.id}`, payload, {
                headers: {
                    Authorization: `Bearer ${accessToken}`,
                    'Content-Type': 'application/json',
                },
            });

            successMsg();
            onUpdate();
            onClose();
        } catch (error) {
            if (error.response && error.response.status === 400) {
                const detail = error.response.data.detail;
                if (detail === 'Email уже зарегистрирован') {
                    messageApi.open({
                        type: 'error',
                        content: 'Этот email уже занят, пожалуйста, используйте другой.',
                    });
                    return;
                }
                if (detail === 'Логин уже занят') {
                    messageApi.open({
                        type: 'error',
                        content: 'Этот логин уже занят, пожалуйста, выберите другой.',
                    });
                    return;
                }
            }
            errorMsg();
        }
    };


    return (
        <>
            {contextHolder}
            <Modal
                open={visible}
                title="Редактировать профиль"
                okText="Сохранить"
                cancelText="Отмена"
                onCancel={onClose}
                onOk={handleSave}
                onFieldsChange={onFormChange}
                footer={[
                    <Button className={classes.modalBtn} key="back" onClick={onClose}>
                        Отмена
                    </Button>,
                    <Button
                        className={classes.modalBtn}
                        key="submit"
                        type="primary"
                        onClick={handleSave}
                        disabled={!isFormValid}
                    >
                        Сохранить
                    </Button>
                ]}
            >
                <Form
                    layout="vertical"
                    form={form}
                    validateMessages={validateMessages}
                    validateTrigger="onChange"
                    onFieldsChange={onFormChange}
                >

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


                    <Form.Item name="email" label="Email"
                        rules={[
                            { required: true, type: 'email', message: 'Введите корректную почту!' },
                            {
                                pattern: /^[\x00-\x7F]+$/,
                                message: 'Почта должна содержать только латинские буквы и символы!',
                            },
                        ]}>
                        <Input maxLength={255} placeholder="Введите почту" />
                    </Form.Item>
                    <Form.Item
                        name="phone"
                        label="Телефон"
                        rules={[
                            {
                                required: false,
                                pattern: /^\+?[78][-\(]?\d{3}\)?-?\d{3}-?\d{2}-?\d{2}$/,
                                message: 'Введите корректный номер телефона (например: +7(800)555-35-35)',
                            },
                        ]}
                    >
                        <Input value={phoneInput} onChange={handlePhoneChange} maxLength={18} placeholder="Введите номер телефона" />
                    </Form.Item>
                </Form>
            </Modal>
        </>
    );
};

export default EditProfileModal;
