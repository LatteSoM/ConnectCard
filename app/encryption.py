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

logger = logging.getLogger(__name__)

def is_fernet_token(data: str) -> bool:
    """Проверяет, похожи ли данные на Fernet-токен"""
    if not data:
        return False
    try:
        # Fernet токен должен иметь определённую структуру
        Fernet.decrypt(data.encode())
        return True
    except:
        return False

def encrypt_data(data: str) -> Optional[str]:
    """Шифрует только если данные ещё не зашифрованы"""
    if not data:
        return None
    if is_fernet_token(data):
        return data  # Уже зашифровано
    try:
        return Fernet.encrypt(data.encode()).decode()
    except Exception as e:
        logger.error(f"Encryption error: {str(e)}")
        return None

def decrypt_data(encrypted_data: str) -> Optional[str]:
    """Безопасная дешифровка с проверкой формата"""
    if not encrypted_data:
        return None
        
    if not is_fernet_token(encrypted_data):
        return encrypted_data  # Возвращаем как есть, если не зашифровано
        
    try:
        return Fernet.decrypt(encrypted_data.encode()).decode()
    except InvalidToken:
        logger.error("Invalid Fernet token - possible key mismatch")
        return None
    except Exception as e:
        logger.error(f"Decryption error: {str(e)}")
        return None