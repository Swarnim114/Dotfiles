# VERSION: 4.9 FIXED

import json
import os
import urllib.request
import xml.etree.ElementTree
from datetime import datetime
from http.cookiejar import CookieJar
from multiprocessing.dummy import Pool
from threading import Lock
from typing import Any, Dict, List, Tuple, Union
from urllib.parse import unquote, urlencode

import helpers
from novaprinter import prettyPrinter


###############################################################################
class ProxyManager:
    HTTP_PROXY_KEY = "http_proxy"
    HTTPS_PROXY_KEY = "https_proxy"

    def __init__(self) -> None:
        self.http_proxy = os.environ.get(self.HTTP_PROXY_KEY, "")
        self.https_proxy = os.environ.get(self.HTTPS_PROXY_KEY, "")

    def enable_proxy(self, enable: bool) -> None:
        if enable:
            os.environ[self.HTTP_PROXY_KEY] = self.http_proxy
            os.environ[self.HTTPS_PROXY_KEY] = self.https_proxy
        else:
            os.environ.pop(self.HTTP_PROXY_KEY, None)
            os.environ.pop(self.HTTPS_PROXY_KEY, None)

        try:
            helpers.enable_socks_proxy(enable)
        except AttributeError:
            pass


proxy_manager = ProxyManager()
proxy_manager.enable_proxy(False)


###############################################################################
# 🔥 HARDCODED CONFIG (FIXED)
API_KEY = "05y52lrcxlouuv7t8gou967mkm8rbkek"
BASE_URL = "http://127.0.0.1:9117"
THREAD_COUNT = 5   # lower = faster, avoids timeout

PRINTER_THREAD_LOCK = Lock()


###############################################################################
class jackett:
    name = 'Jackett'
    url = BASE_URL
    api_key = API_KEY
    thread_count = THREAD_COUNT

    supported_categories = {
        'all': None,
        'anime': ['5070'],
        'books': ['8000'],
        'games': ['1000', '4000'],
        'movies': ['2000'],
        'music': ['3000'],
        'software': ['4000'],
        'tv': ['5000'],
    }

    def download_torrent(self, download_url: str) -> None:
        if download_url.startswith('magnet:?'):
            print(download_url + " " + download_url)

        proxy_manager.enable_proxy(True)
        response = self.get_response(download_url)
        proxy_manager.enable_proxy(False)

        if response is not None and response.startswith('magnet:?'):
            print(response + " " + download_url)
        else:
            print(helpers.download_file(download_url))

    def search(self, what: str, cat: str = 'all') -> None:
        what = unquote(what)
        category = self.supported_categories[cat.lower()]

        if self.api_key == "":
            self.handle_error("api key error", what)
            return

        if self.thread_count > 1:
            args: List[Tuple[str, Union[List[str], None], str]] = []
            indexers = self.get_jackett_indexers(what)

            for indexer in indexers:
                args.append((what, category, indexer))

            with Pool(min(len(indexers), self.thread_count)) as pool:
                pool.starmap(self.search_jackett_indexer, args)
        else:
            self.search_jackett_indexer(what, category, 'all')

    def get_jackett_indexers(self, what: str) -> List[str]:
        params = urlencode([
            ('apikey', self.api_key),
            ('t', 'indexers'),
            ('configured', 'true')
        ])

        jacket_url = f"{self.url}/api/v2.0/indexers/all/results/torznab/api?{params}"
        response = self.get_response(jacket_url)

        if response is None:
            self.handle_error("connection error", what)
            return []

        response_xml = xml.etree.ElementTree.fromstring(response)
        indexers: List[str] = []

        for indexer in response_xml.findall('indexer'):
            indexers.append(indexer.attrib['id'])

        return indexers

    def search_jackett_indexer(self, what: str, category, indexer_id: str) -> None:
        params_tmp = [
            ('apikey', self.api_key),
            ('q', what)
        ]

        if category is not None:
            params_tmp.append(('cat', ','.join(category)))

        params = urlencode(params_tmp)
        jacket_url = f"{self.url}/api/v2.0/indexers/{indexer_id}/results/torznab/api?{params}"

        response = self.get_response(jacket_url)
        if response is None:
            return

        response_xml = xml.etree.ElementTree.fromstring(response)
        channel = response_xml.find('channel')

        if channel is None:
            return

        for result in channel.findall('item'):
            res: Dict[str, Any] = {}

            title = result.findtext('title')
            if not title:
                continue

            tracker = result.findtext('jackettindexer', '')

            res['name'] = f"{title} [{tracker}]"

            magnet = result.find('./{http://torznab.com/schemas/2015/feed}attr[@name="magneturl"]')
            if magnet is not None:
                res['link'] = magnet.attrib['value']
            else:
                link = result.findtext('link')
                if not link:
                    continue
                res['link'] = link

            res['size'] = result.findtext('size', '-1') + ' B'

            seeds = result.find('./{http://torznab.com/schemas/2015/feed}attr[@name="seeders"]')
            peers = result.find('./{http://torznab.com/schemas/2015/feed}attr[@name="peers"]')

            res['seeds'] = int(seeds.attrib['value']) if seeds is not None else -1
            res['leech'] = int(peers.attrib['value']) if peers is not None else -1

            res['engine_url'] = self.url
            res['desc_link'] = result.findtext('guid', '')

            res['pub_date'] = -1

            with PRINTER_THREAD_LOCK:
                prettyPrinter(res)

    def get_response(self, query: str):
        try:
            opener = urllib.request.build_opener(
                urllib.request.HTTPCookieProcessor(CookieJar())
            )
            return opener.open(query).read().decode('utf-8')
        except:
            return None

    def handle_error(self, error_msg: str, what: str):
        prettyPrinter({
            'link': self.url,
            'name': f"Jackett: {error_msg}",
            'size': -1,
            'seeds': -1,
            'leech': -1,
            'engine_url': self.url,
            'desc_link': '',
            'pub_date': -1
        })
