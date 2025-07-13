from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import base64
import os

# Генерация ключа нужно будет положить в переменную окружения
key = Fernet.generate_key()  # нужно будет заменить на постоянный ключ в проде
fernet = Fernet(key)

def encrypt_data(data: str) -> str:
    if not data:
        return data
    return fernet.encrypt(data.encode()).decode()

def decrypt_data(encrypted_data: str) -> str:
    if not encrypted_data:
        return encrypted_data
    return fernet.decrypt(encrypted_data.encode()).decode()