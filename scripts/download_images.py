"""
TayuNikan — Descarga de imagenes del MET Open Access API.
Descarga ~53 imagenes para las lecciones 6-12 con terminos mejorados.

Uso:
    python scripts/download_images.py          # solo descarga faltantes
    python scripts/download_images.py --force  # fuerza re-descarga de todo

Requisitos:
    pip install requests
"""

import os
import sys
import time
import random
import requests

BASE_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'images')
MET_SEARCH = 'https://collectionapi.metmuseum.org/public/collection/v1/search'
MET_OBJECT = 'https://collectionapi.metmuseum.org/public/collection/v1/objects/{}'

# IDs ya usados (evitar duplicados entre imagenes)
SKIP_IDS: set[int] = set()

# (filename, query_principal, fallback1, fallback2, ...)
# Sin filtro 'medium' para maximizar candidatos con imagenes reales
IMAGES = [
    # ── Leccion 6: Cuerpo ──────────────────────────────────────────────────
    ('cuerpo_jaa.jpg',        'head study figure',       'portrait face study',    'human head anatomy'),
    ('cuerpo_jmakon.jpg',     'eye study botanical',     'eye detail portrait',    'eyes face drawing'),
    ('cuerpo_chinthjon.jpg',  'nose anatomy figure',     'face portrait study',    'nose face sketch'),
    ('cuerpo_rua.jpg',        'mouth lips study',        'lips face portrait',     'mouth open face'),
    ('cuerpo_raa.jpg',        'hand study fingers',      'hands drawing sketch',   'hand gesture figure'),
    ('cuerpo_ruthea.jpg',     'foot study anatomy',      'feet barefoot figure',   'feet walking study'),
    ('cuerpo_neje.jpg',       'tongue mouth anatomy',    'mouth open tongue',      'speech figure'),
    ('cuerpo_thusin.jpg',     'neck figure portrait',    'neck collar portrait',   'throat neck study'),

    # ── Leccion 7: Alimentos ───────────────────────────────────────────────
    ('alimento_nio.jpg',        'flat bread cooking',           'flatbread food',          'bread loaf'),
    ('alimento_nua.jpg',        'corn maize plant botanical',   'corn cob botanical',      'maize ear'),
    ('alimento_niunthaon.jpg',  'food wrapped corn husk',       'wrapped leaves food',     'corn food wrapped'),
    ('alimento_thukma.jpg',     'potato tuber botanical',       'root vegetables soil',    'potato plant'),
    ('alimento_thuchmoin.jpg',  'fruit still life',             'fruit basket painting',   'fruit bowl'),
    ('alimento_ndaxra.jpg',     'meal bowl food serving',       'food bowl table',         'soup stew bowl'),
    ('alimento_tumi.jpg',       'coin currency',                'coins pile silver',       'money coins metal'),

    # ── Leccion 8: Verbos ─────────────────────────────────────────────────
    ('verbo_nichma.jpg',    'conversation figure talking',   'people talking speech',   'speaker talking'),
    ('verbo_thji.jpg',      'figure walking path',           'walking person road',     'journey travel walk'),
    ('verbo_thii.jpg',      'figure arrival welcome',        'welcome greeting arrive', 'arrival greeting'),
    ('verbo_tsjee.jpg',     'figure observation gazing',     'person looking watching', 'gaze observation'),
    ('verbo_thjen.jpg',     'washing water hands',           'laundry washing river',   'hands washing water'),
    ('verbo_tsmjan.jpg',    'laughing smile happy',          'smiling joyful figure',   'happy laughter'),
    ('verbo_tsmjang.jpg',   'crying tears sadness',          'weeping figure tears',    'sad crying sorrow'),
    ('verbo_ruchrin.jpg',   'figure jumping leaping',        'jumping dance figure',    'leap jump athlete'),

    # ── Leccion 9: Casa ───────────────────────────────────────────────────
    ('casa_nchian.jpg',   'house cottage rural',       'small house building',    'home dwelling rural'),
    ('casa_nuxra.jpg',    'blanket textile woven',     'woven blanket fabric',    'textile weaving cloth'),
    ('casa_xrui.jpg',     'fire flame torch',          'campfire flame burning',  'fire hearth flame'),
    ('casa_nthaa.jpg',    'tree trunk wood',           'tree forest lumber',      'wood timber trees'),
    ('casa_xro.jpg',      'stone rocks pebble',        'stone wall rocks',        'rock boulder'),
    ('casa_xroon.jpg',    'paper manuscript writing',  'scroll manuscript paper', 'writing paper document'),
    ('casa_nunthe.jpg',   'soil earth ground',         'earth field landscape',   'soil dirt ground'),
    ('casa_xra.jpg',      'labor craft artisan',       'craftsman working tools', 'worker artisan craft'),

    # ── Leccion 10: Ropa ──────────────────────────────────────────────────
    ('ropa_ruthe.jpg',         'woman shawl wrap',         'shawl textile woman',     'wrap rebozo cloth'),
    ('ropa_xranchritmja.jpg',  'wide brim hat straw',      'sombrero straw hat',      'wide hat brim'),
    ('ropa_ruthe_jatse.jpg',   'red textile fabric',       'red cloth textile',       'red shawl fabric'),
    ('ropa_ruthe_thie.jpg',    'black cloth textile',      'dark black fabric',       'black textile cloth'),
    ('ropa_nuxra_rua.jpg',     'white linen fabric',       'white cloth textile',     'white fabric linen'),
    ('ropa_raa_ruthe.jpg',     'belt sash textile band',   'woven belt sash',         'sash belt fabric'),
    ('ropa_ruthea_nuxra.jpg',  'sandal shoe leather',      'leather sandal shoe',     'footwear sandal'),

    # ── Leccion 11: Tiempo / campo ────────────────────────────────────────
    ('tiempo_nchaon.jpg',  'sun rays landscape',      'sunrise sunlight sky',   'sunny landscape'),
    ('tiempo_chrin.jpg',   'rain drops storm',        'rainstorm rainfall',     'rain water storm'),
    ('tiempo_nunthe.jpg',  'earth soil field',        'soil ground earth',      'field plowed earth'),
    ('tiempo_nthaa.jpg',   'mountain forest trees',   'forest hillside trees',  'mountain landscape'),
    ('tiempo_xro.jpg',     'stone rock boulders',     'rocks boulders landscape','stone path rocks'),
    ('tiempo_rajna.jpg',   'village settlement houses','small town village',    'rural village houses'),
    ('tiempo_nua.jpg',     'corn field agriculture',  'cornfield maize crop',   'maize field rows'),
    ('tiempo_xrui.jpg',    'fire warmth campfire',    'campfire night flame',   'fire warmth glow'),

    # ── Leccion 12: Frases ────────────────────────────────────────────────
    ('frase_deo.jpg',            'greeting handshake meeting',   'people greeting hello',   'handshake welcome'),
    ('frase_jian.jpg',           'happiness joy figure',         'happy joyful person',     'contentment smile'),
    ('frase_thji.jpg',           'walking group journey',        'people walking path',     'journey walk road'),
    ('frase_nthii.jpg',          'here place location',          'place map location',      'location marker'),
    ('frase_nthia.jpg',          'distance horizon far',         'horizon landscape far',   'faraway distance'),
    ('frase_jian_nchaon.jpg',    'morning sunrise dawn',         'dawn sunrise morning',    'good morning sun'),
    ('frase_nichma_ngigua.jpg',  'indigenous language book',     'books language learning', 'speech book text'),
]


def search_met(query: str, skip: set[int]) -> int | None:
    """Busca en el MET y devuelve un objectID con imagen disponible."""
    # Sin filtro medium para maximizar candidatos con imagenes reales
    params = {'q': query, 'hasImages': 'true'}
    try:
        r = requests.get(MET_SEARCH, params=params, timeout=10)
        r.raise_for_status()
        ids = r.json().get('objectIDs') or []
        random.shuffle(ids)
        for oid in ids[:40]:
            if oid in skip:
                continue
            obj_r = requests.get(MET_OBJECT.format(oid), timeout=10)
            if obj_r.status_code != 200:
                continue
            obj = obj_r.json()
            url = obj.get('primaryImageSmall') or obj.get('primaryImage')
            if url:
                return oid
    except Exception as e:
        print(f'  Error buscando "{query}": {e}')
    return None


def download_image(oid: int, dest: str) -> bool:
    """Descarga primaryImageSmall de un objeto del MET."""
    try:
        obj_r = requests.get(MET_OBJECT.format(oid), timeout=10)
        obj_r.raise_for_status()
        obj = obj_r.json()
        url = obj.get('primaryImageSmall') or obj.get('primaryImage')
        if not url:
            return False
        img_r = requests.get(url, timeout=20)
        img_r.raise_for_status()
        with open(dest, 'wb') as f:
            f.write(img_r.content)
        return True
    except Exception as e:
        print(f'  Error descargando {oid}: {e}')
        return False


def main():
    force = '--force' in sys.argv
    if force:
        print('Modo --force: eliminando imagenes existentes de L6-12...\n')
        for entry in IMAGES:
            dest = os.path.join(BASE_DIR, entry[0])
            if os.path.exists(dest):
                os.remove(dest)

    os.makedirs(BASE_DIR, exist_ok=True)
    used: set[int] = set(SKIP_IDS)
    ok = 0
    fail = 0

    for entry in IMAGES:
        filename = entry[0]
        queries = entry[1:]
        dest = os.path.join(BASE_DIR, filename)

        if os.path.exists(dest):
            print(f'[skip] Ya existe: {filename}')
            ok += 1
            continue

        print(f'[DL] {filename}', end='  ')
        found = False
        for query in queries:
            oid = search_met(query, used)
            if oid:
                if download_image(oid, dest):
                    used.add(oid)
                    print(f'OK (id={oid}, query="{query}")')
                    ok += 1
                    found = True
                    break
            time.sleep(0.2)

        if not found:
            print('FALLO — usando placeholder')
            # Crear placeholder JPEG mínimo (1×1 gris) para no romper la app
            _write_placeholder(dest)
            fail += 1

        time.sleep(0.3)

    print(f'\nResumen: {ok} descargadas, {fail} placeholders')


def _write_placeholder(path: str):
    """Escribe un JPEG de 1×1 píxel gris como placeholder."""
    # Mínimo JPEG válido (1×1 px gris)
    minimal_jpg = bytes([
        0xFF,0xD8,0xFF,0xE0,0x00,0x10,0x4A,0x46,0x49,0x46,0x00,0x01,
        0x01,0x00,0x00,0x01,0x00,0x01,0x00,0x00,0xFF,0xDB,0x00,0x43,
        0x00,0x08,0x06,0x06,0x07,0x06,0x05,0x08,0x07,0x07,0x07,0x09,
        0x09,0x08,0x0A,0x0C,0x14,0x0D,0x0C,0x0B,0x0B,0x0C,0x19,0x12,
        0x13,0x0F,0x14,0x1D,0x1A,0x1F,0x1E,0x1D,0x1A,0x1C,0x1C,0x20,
        0x24,0x2E,0x27,0x20,0x22,0x2C,0x23,0x1C,0x1C,0x28,0x37,0x29,
        0x2C,0x30,0x31,0x34,0x34,0x34,0x1F,0x27,0x39,0x3D,0x38,0x32,
        0x3C,0x2E,0x33,0x34,0x32,0xFF,0xC0,0x00,0x0B,0x08,0x00,0x01,
        0x00,0x01,0x01,0x01,0x11,0x00,0xFF,0xC4,0x00,0x1F,0x00,0x00,
        0x01,0x05,0x01,0x01,0x01,0x01,0x01,0x01,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,
        0x09,0x0A,0x0B,0xFF,0xC4,0x00,0xB5,0x10,0x00,0x02,0x01,0x03,
        0x03,0x02,0x04,0x03,0x05,0x05,0x04,0x04,0x00,0x00,0x01,0x7D,
        0x01,0x02,0x03,0x00,0x04,0x11,0x05,0x12,0x21,0x31,0x41,0x06,
        0x13,0x51,0x61,0x07,0x22,0x71,0x14,0x32,0x81,0x91,0xA1,0x08,
        0x23,0x42,0xB1,0xC1,0x15,0x52,0xD1,0xF0,0x24,0x33,0x62,0x72,
        0x82,0x09,0x0A,0x16,0x17,0x18,0x19,0x1A,0x25,0x26,0x27,0x28,
        0x29,0x2A,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x43,0x44,0x45,
        0x46,0x47,0x48,0x49,0x4A,0x53,0x54,0x55,0x56,0x57,0x58,0x59,
        0x5A,0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x6A,0x73,0x74,0x75,
        0x76,0x77,0x78,0x79,0x7A,0x83,0x84,0x85,0x86,0x87,0x88,0x89,
        0x8A,0x92,0x93,0x94,0x95,0x96,0x97,0x98,0x99,0x9A,0xA2,0xA3,
        0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xAA,0xB2,0xB3,0xB4,0xB5,0xB6,
        0xB7,0xB8,0xB9,0xBA,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,
        0xCA,0xD2,0xD3,0xD4,0xD5,0xD6,0xD7,0xD8,0xD9,0xDA,0xE1,0xE2,
        0xE3,0xE4,0xE5,0xE6,0xE7,0xE8,0xE9,0xEA,0xF1,0xF2,0xF3,0xF4,
        0xF5,0xF6,0xF7,0xF8,0xF9,0xFA,0xFF,0xDA,0x00,0x08,0x01,0x01,
        0x00,0x00,0x3F,0x00,0xFB,0xD4,0xFF,0xD9,
    ])
    with open(path, 'wb') as f:
        f.write(minimal_jpg)


if __name__ == '__main__':
    main()
