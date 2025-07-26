# from cryptography.fernet import Fernet
# from cryptography.hazmat.primitives import hashes
# from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
# import base64
# import os

# from dotenv import load_dotenv

# # Генерация ключа нужно будет положить в переменную окружения
# # key = Fernet.generate_key()  # нужно будет заменить на постоянный ключ в проде
# # fernet = Fernet(os.getenv('KEY').encode())
# load_dotenv()
# fernet = Fernet(os.getenv("FERNET_KEY"))

# def encrypt_data(data: str) -> str:
#     if not data:
#         return data
#     return fernet.encrypt(data.encode()).decode()

# def decrypt_data(encrypted_data: str) -> str:
#     if not encrypted_data:
#         return encrypted_data
#     return fernet.decrypt(encrypted_data.encode()).decode()

from cryptography.fernet import Fernet, InvalidToken
from typing import Optional
import logging
import base64
import os
from dotenv import load_dotenv

# Загружаем переменные окружения
load_dotenv()

logger = logging.getLogger(__name__)

# Глобальный экземпляр Fernet
_cipher_suite = None

def _get_cipher_suite():
    """Инициализирует Fernet с ключом из .env"""
    global _cipher_suite
    if _cipher_suite is None:
        key = os.getenv('FERNET_KEY')
        if not key:
            raise ValueError("FERNET_KEY not found in .env file")
        
        # Проверяем что ключ валидный
        try:
            _cipher_suite = Fernet(key.encode())
        except ValueError as e:
            logger.error(f"Invalid FERNET_KEY: {str(e)}")
            raise
    return _cipher_suite

def is_fernet_token(data: str) -> bool:
    """Проверяет, похожи ли данные на Fernet-токен"""
    if not data or not isinstance(data, str):
        return False
        
    try:
        # Проверяем структуру без реальной дешифровки
        decoded = base64.urlsafe_b64decode(data)
        return len(decoded) > 0
    except (ValueError, TypeError):
        return False

def encrypt_data(data: str) -> Optional[str]:
    """Шифрует строку в Fernet-токен"""
    if not data or not isinstance(data, str):
        return None
        
    if is_fernet_token(data):
        return data  # Уже зашифровано
        
    try:
        cipher = _get_cipher_suite()
        encrypted = cipher.encrypt(data.encode())
        return encrypted.decode()
    except Exception as e:
        logger.error(f"Encryption error: {str(e)}")
        return None

def decrypt_data(encrypted_data: str) -> Optional[str]:
    """Дешифрует Fernet-токен"""
    if not encrypted_data or not isinstance(encrypted_data, str):
        return None
        
    if not is_fernet_token(encrypted_data):
        return encrypted_data  # Не зашифровано
        
    try:
        cipher = _get_cipher_suite()
        decrypted = cipher.decrypt(encrypted_data.encode())
        return decrypted.decode()
    except InvalidToken:
        logger.error("Invalid token - possible key mismatch")
        return None
    except Exception as e:
        logger.error(f"Decryption error: {str(e)}")
        return None