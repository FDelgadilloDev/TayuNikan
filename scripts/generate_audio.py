"""
generate_audio.py — Genera MP3 de pronunciacion aproximada para palabras Ngigua
usando Google TTS (gTTS) con transcripcion fonetica en español.

El Ngigua no tiene TTS nativo. Se usa una transcripcion fonetica en español
que aproxima la pronunciacion real de cada palabra.

Reglas fonologicas aplicadas:
  j  → h   (como "jarro" en español, suena /h/)
  th → t   (oclusiva dental aspirada → t simple)
  x  → ch  (fricativa postalveolar /ʃ/ → ch española)
  ts, tsj → ch  (africada → ch)
  jn, jm al inicio → silenciar j  (consonante implosiva)
  aa, ee, oo (vocales largas) → vocal simple

Uso:
    pip install gTTS
    python scripts/generate_audio.py          # genera faltantes
    python scripts/generate_audio.py --force  # regenera todo
"""

import os
import sys
import time

try:
    from gtts import gTTS
except ImportError:
    print("ERROR: gTTS no instalado. Ejecuta: pip install gTTS")
    sys.exit(1)

AUDIO_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "assets", "audio")
os.makedirs(AUDIO_DIR, exist_ok=True)

# ─── Transcripcion fonetica: palabra Ngigua → texto que leerá el TTS ─────────
# La clave es exactamente la palabra que va en la base de datos.
# El valor es la transcripcion en español que suena similar a la pronunciacion
# real en Ngigua segun su sistema fonologico documentado.
PHONETICS = {
    # ── L1 Saludos ──────────────────────────────────────────────────────────
    'deo':    'déo',
    'jian':   'hian',
    'jaro':   'haro',
    'chee':   'che',
    'juajna': 'juajna',

    # ── L2 Numeros ──────────────────────────────────────────────────────────
    # j antes de consonante es implosiva glotal, se silencia
    'jngo': 'ngo',
    'yoo':  'yo',
    'nii':  'ni',
    'noo':  'no',
    'nao':  'nao',

    # ── L3 Colores ──────────────────────────────────────────────────────────
    'jatse': 'hatse',
    'yua':   'yua',
    'rua':   'rua',
    'sine':  'sine',
    'thie':  'tie',       # th → t

    # ── L4 Animales ─────────────────────────────────────────────────────────
    'kunia':    'kunia',
    'kumichin': 'kumichin',
    'kuxijna':  'kuchina',  # x→ch, j→silent antes de n
    'kunthua':  'kuntua',   # th→t
    'kukapio':  'kukapio',

    # ── L5 Familia ──────────────────────────────────────────────────────────
    'ndudaa':   'nduda',
    'jannaa':   'hanna',
    'choo':     'cho',
    'nichoo':   'nicho',
    'junchjan': 'hunchan',  # j→h, th→silent, j→ch

    # ── L6 Cuerpo ───────────────────────────────────────────────────────────
    'jaa':       'ha',        # j→h, aa→a
    'jmakón':    'makón',     # jm→m (j implosiva antes de m)
    'chinthjón': 'chintón',   # th→t
    'rua':       'rua',
    'raa':       'ra',        # aa→a
    'ruthea':    'rutéa',     # th→t
    'neje':      'nehe',      # j→h intervocálica
    'thusin':    'tusin',     # th→t

    # ── L7 Alimentos ────────────────────────────────────────────────────────
    'nio':       'nio',
    'nua':       'nua',
    'niunthaon': 'niuntaon',  # th→t
    'thukma':    'tukma',     # th→t
    'thuchmoin': 'tuchmoin',  # th→t
    'ndaxra':    'ndara',     # x→r (fricativa en posición intervocálica)
    'tumi':      'tumi',

    # ── L8 Verbos ───────────────────────────────────────────────────────────
    'nichma':  'nichma',
    'thji':    'chi',      # thj→ch (africada palatal)
    'thii':    'ti',       # th→t, ii→i
    'tsjee':   'che',      # tsj→ch, ee→e
    'thjen':   'chen',     # thj→ch
    'tsmjan':  'chman',    # tsm→chm
    'tsmjang': 'chmang',   # tsm→chm
    'ruchrin': 'ruchrin',

    # ── L9 Casa ─────────────────────────────────────────────────────────────
    'nchian': 'nchian',
    'nuxra':  'nuchra',   # x→ch
    'xrui':   'chrui',    # x→ch
    'nthaa':  'nta',      # nth→nt, aa→a
    'xro':    'chro',     # x→ch
    'xroon':  'chron',    # x→ch, oo→o
    'nunthe': 'nunte',    # th→t
    'xra':    'chra',     # x→ch

    # ── L10 Ropa ────────────────────────────────────────────────────────────
    'ruthe':        'rute',          # th→t
    'xranchritmja': 'ranchritmja',   # x al inicio → silenciar (o usar r)
    'ruthe jatse':  'rute hatse',
    'ruthe thie':   'rute tie',
    'nuxra rua':    'nuchra rua',
    'raa ruthe':    'ra rute',
    'ruthea nuxra': 'rutéa nuchra',

    # ── L11 Tiempo ──────────────────────────────────────────────────────────
    'nchaon': 'nchaon',
    'chrin':  'chrin',
    'nunthe': 'nunte',   # th→t
    'nthaa':  'nta',     # nth→nt
    'xro':    'chro',
    'rajna':  'rahna',   # j→h
    'nua':    'nua',
    'xrui':   'chrui',

    # ── L12 Frases ──────────────────────────────────────────────────────────
    'deo':            'déo',
    'jian':           'hian',
    'thji':           'chi',
    'nthii':          'nti',        # nth→nt
    'nthia':          'ntia',
    'jian nchaon':    'hian nchaon',
    'nichma Ngigua':  'nichma Ngigua',
}

# ─── Lista de palabras a generar ─────────────────────────────────────────────
# (palabra_ngigua, categoria, numero)
WORDS = [
    # L1 Saludos
    ('deo',    'saludo', 1),
    ('jian',   'saludo', 2),
    ('jaro',   'saludo', 3),
    ('chee',   'saludo', 4),
    ('juajna', 'saludo', 5),
    # L2 Numeros
    ('jngo', 'numero', 1),
    ('yoo',  'numero', 2),
    ('nii',  'numero', 3),
    ('noo',  'numero', 4),
    ('nao',  'numero', 5),
    # L3 Colores
    ('jatse', 'color', 1),
    ('yua',   'color', 2),
    ('rua',   'color', 3),
    ('sine',  'color', 4),
    ('thie',  'color', 5),
    # L4 Animales
    ('kunia',    'animal', 1),
    ('kumichin', 'animal', 2),
    ('kuxijna',  'animal', 3),
    ('kunthua',  'animal', 4),
    ('kukapio',  'animal', 5),
    # L5 Familia
    ('ndudaa',   'familia', 1),
    ('jannaa',   'familia', 2),
    ('choo',     'familia', 3),
    ('nichoo',   'familia', 4),
    ('junchjan', 'familia', 5),
    # L6 Cuerpo
    ('jaa',       'cuerpo', 1),
    ('jmakón',    'cuerpo', 2),
    ('chinthjón', 'cuerpo', 3),
    ('rua',       'cuerpo', 4),
    ('raa',       'cuerpo', 5),
    ('ruthea',    'cuerpo', 6),
    ('neje',      'cuerpo', 7),
    ('thusin',    'cuerpo', 8),
    # L7 Alimentos
    ('nio',       'alimento', 1),
    ('nua',       'alimento', 2),
    ('niunthaon', 'alimento', 3),
    ('thukma',    'alimento', 4),
    ('thuchmoin', 'alimento', 5),
    ('ndaxra',    'alimento', 6),
    ('tumi',      'alimento', 7),
    # L8 Verbos
    ('nichma',  'verbo', 1),
    ('thji',    'verbo', 2),
    ('thii',    'verbo', 3),
    ('tsjee',   'verbo', 4),
    ('thjen',   'verbo', 5),
    ('tsmjan',  'verbo', 6),
    ('tsmjang', 'verbo', 7),
    ('ruchrin', 'verbo', 8),
    # L9 Casa
    ('nchian', 'casa', 1),
    ('nuxra',  'casa', 2),
    ('xrui',   'casa', 3),
    ('nthaa',  'casa', 4),
    ('xro',    'casa', 5),
    ('xroon',  'casa', 6),
    ('nunthe', 'casa', 7),
    ('xra',    'casa', 8),
    # L10 Ropa
    ('ruthe',        'ropa', 1),
    ('xranchritmja', 'ropa', 2),
    ('ruthe jatse',  'ropa', 3),
    ('ruthe thie',   'ropa', 4),
    ('nuxra rua',    'ropa', 5),
    ('raa ruthe',    'ropa', 6),
    ('ruthea nuxra', 'ropa', 7),
    # L11 Tiempo
    ('nchaon', 'tiempo', 1),
    ('chrin',  'tiempo', 2),
    ('nunthe', 'tiempo', 3),
    ('nthaa',  'tiempo', 4),
    ('xro',    'tiempo', 5),
    ('rajna',  'tiempo', 6),
    ('nua',    'tiempo', 7),
    ('xrui',   'tiempo', 8),
    # L12 Frases
    ('deo',           'frase', 1),
    ('jian',          'frase', 2),
    ('thji',          'frase', 3),
    ('nthii',         'frase', 4),
    ('nthia',         'frase', 5),
    ('jian nchaon',   'frase', 6),
    ('nichma Ngigua', 'frase', 7),
]


def generate(word: str, categoria: str, n: int, force: bool = False) -> None:
    filename = f"{categoria}_{n}.mp3"
    filepath = os.path.join(AUDIO_DIR, filename)

    if os.path.exists(filepath) and not force:
        print(f"  [skip] {filename}")
        return

    # Obtener transcripcion fonetica; si no hay mapeo usar la palabra tal cual
    phonetic = PHONETICS.get(word, word)

    try:
        tts = gTTS(text=phonetic, lang='es', slow=True)
        tts.save(filepath)
        marker = '' if phonetic == word else f' -> [{phonetic}]'
        print(f"  [OK]   {filename}  '{word}'{marker}")
        time.sleep(0.3)
    except Exception as e:
        print(f"  [ERR]  {filename}  '{word}': {e}")


def main():
    force = "--force" in sys.argv
    if force:
        print("Modo --force: regenerando todos los archivos de audio\n")

    print(f"Generando {len(WORDS)} archivos en {AUDIO_DIR}\n")
    for word, cat, n in WORDS:
        generate(word, cat, n, force=force)

    print(f"\nListo. Archivos en: {AUDIO_DIR}")


if __name__ == "__main__":
    main()
