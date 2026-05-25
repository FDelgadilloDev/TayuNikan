"""
TayuNikan — Descarga imagenes usando Wikipedia pageimages API (fuente primaria)
y MET Open Access API como fallback para las 60 palabras de las 12 lecciones.

Wikipedia pageimages devuelve la imagen principal del articulo, que siempre
es directamente representativa del concepto — ideal para vocabulario educativo.

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

WIKI_API  = 'https://en.wikipedia.org/w/api.php'
MET_SEARCH = 'https://collectionapi.metmuseum.org/public/collection/v1/search'
MET_OBJECT = 'https://collectionapi.metmuseum.org/public/collection/v1/objects/{}'

HEADERS = {'User-Agent': 'TayuNikanApp/2.0 (educational; contact@tayunikan.mx)'}

# ─── Mapeo: (filename, wiki_title, met_query_fallback) ────────────────────────
# wiki_title: titulo exacto del articulo en Wikipedia en ingles
# met_query:  busqueda en MET si Wikipedia falla
IMAGES = [
    # ── Leccion 1: Saludos ────────────────────────────────────────────────────
    # deo=saludo, jian=bien/bueno, jaro=bonito, chee=alegre, juajna=mensaje
    ('saludo_deo.jpg',    'Handshake',           'greeting handshake'),
    ('saludo_jian.jpg',   'Smiley',              'smiley happy face'),
    ('saludo_jaro.jpg',   'Rose',                'rose flower beautiful'),
    ('saludo_chee.jpg',   'Smile',               'smile laughing happy'),
    ('saludo_juajna.jpg', 'Postcard',            'postcard letter greeting'),

    # ── Leccion 2: Numeros ────────────────────────────────────────────────────
    # numeros 1-5; usar objetos concretos (un sol, bicicleta, semaforo, trebol, estrella)
    ('numero_jngo.jpg', 'Sun',              'sun one'),
    ('numero_yoo.jpg',  'Bicycle',          'bicycle two wheels'),
    ('numero_nii.jpg',  'Traffic light',    'traffic light three colors'),
    ('numero_noo.jpg',  'Four-leaf clover', 'clover four leaves'),
    ('numero_nao.jpg',  'Starfish',         'starfish five arms'),

    # ── Leccion 3: Colores ────────────────────────────────────────────────────
    # colores: articulos Wikipedia de color tienen swatches claros
    ('color_jatse.jpg', 'Red',         'red color paint'),
    ('color_yua.jpg',   'Green',       'green color plant'),
    ('color_rua.jpg',   'White',       'white color fabric'),
    ('color_sine.jpg',  'Yellow',      'yellow color flower'),
    ('color_thie.jpg',  'Black',       'black color night'),

    # ── Leccion 4: Animales ───────────────────────────────────────────────────
    ('animal_perro.jpg',    'Dog',              'dog canine'),
    ('animal_gato.jpg',     'Cat',              'cat feline'),
    ('animal_venado.jpg',   'White-tailed deer','deer venado'),
    ('animal_pajaro.jpg',   'Bird',             'bird flying'),
    ('animal_mariposa.jpg', 'Butterfly',        'butterfly insect'),

    # ── Leccion 5: Familia ────────────────────────────────────────────────────
    # padre, madre, hermano/a, familia, abuelo/a
    ('familia_ndudaa.jpg',   'Father',      'father parent man'),
    ('familia_jannaa.jpg',   'Mother',      'mother parent woman'),
    ('familia_choo.jpg',     'Brother',     'brother sister children'),
    ('familia_nichoo.jpg',   'Nuclear family', 'family parents children'),
    ('familia_junchjan.jpg', 'Grandparent', 'grandparent elder older'),

    # ── Leccion 6: Cuerpo ─────────────────────────────────────────────────────
    # partes del cuerpo: articulos de anatomia tienen fotos claras
    ('cuerpo_jaa.jpg',       'Human head',    'head face portrait'),
    ('cuerpo_jmakon.jpg',    'Human eye',     'eye vision face'),
    ('cuerpo_chinthjon.jpg', 'Human nose',    'nose face anatomy'),
    ('cuerpo_rua.jpg',       'Mouth',         'mouth lips face'),
    ('cuerpo_raa.jpg',       'Hand',          'hand fingers palm'),
    ('cuerpo_ruthea.jpg',    'Foot',          'foot barefoot sole'),
    ('cuerpo_neje.jpg',      'Tongue',        'tongue mouth taste'),
    ('cuerpo_thusin.jpg',    'Neck',          'neck throat portrait'),

    # ── Leccion 7: Alimentos ──────────────────────────────────────────────────
    ('alimento_nio.jpg',       'Corn tortilla',  'tortilla flatbread'),
    ('alimento_nua.jpg',       'Maize',          'corn maize plant'),
    ('alimento_niunthaon.jpg', 'Tamale',         'tamale food wrapped'),
    ('alimento_thukma.jpg',    'Potato',         'potato vegetable'),
    ('alimento_thuchmoin.jpg', 'Tropical fruit', 'fruit tropical colorful'),
    ('alimento_ndaxra.jpg',    'Mole sauce',     'mole sauce food bowl'),
    ('alimento_tumi.jpg',      'Coin',           'coins currency metal'),

    # ── Leccion 8: Verbos ─────────────────────────────────────────────────────
    # verbos: usar imagenes concretas (objeto/accion clara) en lugar de conceptos abstractos
    # nichma=hablar, thji=caminar, thii=llegar, tsjee=ver, thjen=lavar manos
    # tsmjan=reir, tsmjang=llorar, ruchrin=saltar
    ('verbo_nichma.jpg',  'Public speaking',  'person speaking microphone talk'),
    ('verbo_thji.jpg',    'Hiking',           'hiking trail person walking'),
    ('verbo_thii.jpg',    'Door',             'door entrance house arrive'),
    ('verbo_tsjee.jpg',   'Human eye',        'eye looking vision see'),
    ('verbo_thjen.jpg',   'Hand washing',     'washing hands water soap'),
    ('verbo_tsmjan.jpg',  'Smile',            'smile laughing happy face'),
    ('verbo_tsmjang.jpg', 'Crying',           'crying tears sadness'),
    ('verbo_ruchrin.jpg', 'Long jump',        'long jump athletics jumping'),

    # ── Leccion 9: Casa ───────────────────────────────────────────────────────
    # nchian=casa, nuxra=cobija, xrui=fuego, nthaa=arbol, xro=piedra
    # xroon=papel, nunthe=tierra, xra=trabajo/labor
    ('casa_nchian.jpg',  'House',         'house rural cottage'),
    ('casa_nuxra.jpg',   'Blanket',       'blanket textile woven'),
    ('casa_xrui.jpg',    'Fire',          'fire flame campfire'),
    ('casa_nthaa.jpg',   'Tree',          'tree forest wood'),
    ('casa_xro.jpg',     'Rock (geology)','stone rocks pebble'),
    ('casa_xroon.jpg',   'Paper',         'paper sheet white'),
    ('casa_nunthe.jpg',  'Soil',          'soil earth ground'),
    ('casa_xra.jpg',     'Artisan',       'artisan craftsman work hands'),

    # ── Leccion 10: Ropa ──────────────────────────────────────────────────────
    # ropa tradicional mexicana/ngigua
    ('ropa_ruthe.jpg',        'Rebozo',          'woman shawl rebozo'),
    ('ropa_xranchritmja.jpg', 'Sombrero',        'sombrero wide hat straw'),
    ('ropa_ruthe_jatse.jpg',  'Rebozo',          'red textile shawl'),
    ('ropa_ruthe_thie.jpg',   'Huipil',          'black textile cloth'),
    ('ropa_nuxra_rua.jpg',    'Linen',           'white linen fabric'),
    ('ropa_raa_ruthe.jpg',    'Sash (clothing)', 'belt sash woven'),
    ('ropa_ruthea_nuxra.jpg', 'Sandal',          'sandal leather footwear'),

    # ── Leccion 11: Tiempo ────────────────────────────────────────────────────
    # nchaon=sol, chrin=lluvia, nunthe=tierra, nthaa=bosque/arbol
    # xro=piedra, rajna=pueblo/lugar, nua=milpa/maiz, xrui=fogata
    ('tiempo_nchaon.jpg', 'Sun',           'sun rays sunrise'),
    ('tiempo_chrin.jpg',  'Rain',          'rain drops storm'),
    ('tiempo_nunthe.jpg', 'Agriculture',   'farmland earth field'),
    ('tiempo_nthaa.jpg',  'Forest',        'forest trees mountain'),
    ('tiempo_xro.jpg',    'Rock (geology)','stone boulders'),
    ('tiempo_rajna.jpg',  'Village',       'village rural settlement'),
    ('tiempo_nua.jpg',    'Milpa',         'corn field agriculture'),
    ('tiempo_xrui.jpg',   'Campfire',      'campfire fire warmth'),

    # ── Leccion 12: Frases ────────────────────────────────────────────────────
    ('frase_deo.jpg',           'Handshake',         'greeting hello handshake'),
    ('frase_jian.jpg',          'Smiley',            'smiley happy joy face'),
    ('frase_thji.jpg',          'Hiking',            'trail path walking person'),
    ('frase_nthii.jpg',         'Map',               'map location place'),
    ('frase_nthia.jpg',         'Horizon',           'horizon landscape far'),
    ('frase_jian_nchaon.jpg',   'Sunrise',           'sunrise morning dawn'),
    ('frase_nichma_ngigua.jpg', 'Mixtec languages',  'indigenous language book'),
]


# ─── Wikipedia pageimages ─────────────────────────────────────────────────────

def wiki_image_url(title: str) -> str | None:
    """Devuelve la URL de la imagen principal del articulo de Wikipedia."""
    params = {
        'action': 'query',
        'prop': 'pageimages',
        'titles': title,
        'pithumbsize': 400,
        'format': 'json',
        'redirects': 1,
    }
    try:
        r = requests.get(WIKI_API, params=params, headers=HEADERS, timeout=10)
        r.raise_for_status()
        pages = r.json().get('query', {}).get('pages', {})
        for page in pages.values():
            if 'missing' in page:
                return None
            thumb = page.get('thumbnail', {})
            if thumb.get('source'):
                return thumb['source']
    except Exception as e:
        print(f'    Wiki error "{title}": {e}')
    return None


# ─── MET fallback ─────────────────────────────────────────────────────────────

def met_image_url(query: str, skip: set[int]) -> tuple[str | None, int | None]:
    """Busca en el MET y devuelve (url, objectId)."""
    params = {'q': query, 'hasImages': 'true'}
    try:
        r = requests.get(MET_SEARCH, params=params, timeout=10)
        r.raise_for_status()
        ids = r.json().get('objectIDs') or []
        random.shuffle(ids)
        for oid in ids[:30]:
            if oid in skip:
                continue
            obj_r = requests.get(MET_OBJECT.format(oid), timeout=10)
            if obj_r.status_code != 200:
                continue
            obj = obj_r.json()
            url = obj.get('primaryImageSmall') or obj.get('primaryImage')
            if url:
                return url, oid
    except Exception as e:
        print(f'    MET error "{query}": {e}')
    return None, None


# ─── Descarga ─────────────────────────────────────────────────────────────────

def download_url(url: str, dest: str) -> bool:
    try:
        r = requests.get(url, headers=HEADERS, timeout=20)
        r.raise_for_status()
        with open(dest, 'wb') as f:
            f.write(r.content)
        return True
    except Exception as e:
        print(f'    Download error: {e}')
        return False


def write_placeholder(path: str):
    """JPEG 1x1 gris minimo como placeholder."""
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
        0x09,0x0A,0x0B,0xFF,0xDA,0x00,0x08,0x01,0x01,
        0x00,0x00,0x3F,0x00,0xFB,0xD4,0xFF,0xD9,
    ])
    with open(path, 'wb') as f:
        f.write(minimal_jpg)


# ─── Main ─────────────────────────────────────────────────────────────────────

def main():
    force = '--force' in sys.argv
    if force:
        print('Modo --force: eliminando todas las imagenes existentes...\n')
        for entry in IMAGES:
            dest = os.path.join(BASE_DIR, entry[0])
            if os.path.exists(dest):
                os.remove(dest)

    os.makedirs(BASE_DIR, exist_ok=True)
    met_used: set[int] = set()
    ok_wiki = 0
    ok_met  = 0
    fail    = 0

    for filename, wiki_title, met_query in IMAGES:
        dest = os.path.join(BASE_DIR, filename)

        if os.path.exists(dest):
            print(f'[skip] {filename}')
            ok_wiki += 1
            continue

        print(f'[DL]  {filename}', end='  ')

        # 1. Intentar Wikipedia
        url = wiki_image_url(wiki_title)
        if url and download_url(url, dest):
            print(f'[Wiki] "{wiki_title}"')
            ok_wiki += 1
            time.sleep(0.2)
            continue

        # 2. Fallback: MET
        time.sleep(0.2)
        url, oid = met_image_url(met_query, met_used)
        if url and oid and download_url(url, dest):
            met_used.add(oid)
            print(f'[MET]  "{met_query}" (id={oid})')
            ok_met += 1
            time.sleep(0.3)
            continue

        # 3. Placeholder
        write_placeholder(dest)
        print('[FALLO] placeholder')
        fail += 1
        time.sleep(0.2)

    total = len(IMAGES)
    print(f'\nResultado: {ok_wiki} Wikipedia + {ok_met} MET + {fail} placeholders / {total} total')


if __name__ == '__main__':
    main()
