from base64 import b64encode, b64decode

from Crypto.Cipher import AES


class GaanaCipher:
    def __init__(self):
        self.key = 'g@1n!(f1#r.0$)&%'.encode('utf-8')
        self.iv = 'asd!@#!@#@!12312'.encode('utf-8')
        self.cipher = AES.new(self.key, AES.MODE_CBC, self.iv)

    @staticmethod
    def __pad(s):
        return s + (AES.block_size - len(s) % AES.block_size) * chr(
            AES.block_size - len(s) % AES.block_size)

    @staticmethod
    def __unpad(s):
        return s[0:-ord(s[-1])]

    def encrypt(self, raw):
        raw = self.__pad(raw)
        return b64encode(self.cipher.encrypt(raw))

    def decrypt(self, enc):
        enc = b64decode(enc)
        return self.__unpad(self.cipher.decrypt(enc).decode("utf-8"))
