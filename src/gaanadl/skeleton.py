import os
import platform
import re
import string
import subprocess
import sys

import requests

from .gaana_argparser import parse_song
from .gaana_cipher import GaanaCipher


def get_song_cipher(song):
    return requests.get(
        url=f'https://gaana.com/apiv2?seokey={song}&type=songdetails&isChrome=1', headers={
            'User-Agent': 'Mozilla/5.0 (Linux; Android 10;TXY567) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/8399.0.9993.96 Mobile Safari/599.36'}).json()[
        'tracks'][0]['urls']['auto']['message']


def extract_song_id(song_link):
    return song_link.split("/")[-1]


def decipher_link(cipher_link):
    return GaanaCipher().decrypt(cipher_link)


def get_downloadable_url(deciphered_link):
    grubbers_regex = r'\b(([\w-]+://?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^%s\s]|/)))' % re.escape(
        string.punctuation)
    pattern = re.compile(grubbers_regex)
    matched_items = pattern.findall(deciphered_link)
    if len(matched_items) == 0:
        raise Exception('Decrypted Song URl is invalid!')

    return matched_items[1][0]


def get_contents(deciphered_link):
    response = requests.get(deciphered_link)
    return response.content.decode('utf-8')


def is_tool(name):
    cmd = "where" if platform.system() == "Windows" else "which"
    rc = subprocess.call([cmd, name])
    if rc == 0:
        return True
    else:
        return False


def download_file(final_down_url, song_id):
    if not is_tool('ffmpeg'):
        raise Exception('FFMpeg not found, please install it before continuing.'
                        ' If it is installed, please check if ffmpeg is in $PATH or not')

    os.system(f'ffmpeg -i "{final_down_url}" -y -vn -codec copy "{song_id}.aac"'
              f'&& ffmpeg -i {song_id}.aac -y -acodec libmp3lame {song_id}.mp3')
    os.remove(f"{song_id}.aac")


def main(args):
    song_link = parse_song(args)
    song_id = extract_song_id(song_link)
    deciphered_link = decipher_link(get_song_cipher(song_id))
    final_down_url = get_downloadable_url(get_contents(deciphered_link))
    download_file(final_down_url, song_id)


def run():
    main(sys.argv[1:])


if __name__ == "__main__":
    run()
