"""
generate_audio.py — Genera MP3 de pronunciacion para las palabras Ngigua
usando Google TTS (gTTS) con voz espanola, velocidad lenta para mayor claridad.

Uso:
    pip install gTTS
    python scripts/generate_audio.py

Los archivos se guardan en assets/audio/<categoria>_<n>.mp3
"""

import os
import sys
import time

try:
    from gtts import gTTS
except ImportError:
    print("ERROR: gTTS no instalado. Ejecuta: pip install gTTS")
    sys.exit(1)

# Directorio de salida
AUDIO_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "assets", "audio")
os.makedirs(AUDIO_DIR, exist_ok=True)

# Lista de palabras por categoria: (palabra_ngigua, categoria, numero)
# Nomenclatura: assets/audio/<categoria>_<n>.mp3
WORDS = [
    # Leccion 1: Saludos (saludo_1..5)
    ("deo",    "saludo", 1),
    ("jian",   "saludo", 2),
    ("jaro",   "saludo", 3),
    ("chee",   "saludo", 4),
    ("juajna", "saludo", 5),

    # Leccion 2: Numeros (numero_1..5)
    ("jngo", "numero", 1),
    ("yoo",  "numero", 2),
    ("nii",  "numero", 3),
    ("noo",  "numero", 4),
    ("nao",  "numero", 5),

    # Leccion 3: Colores (color_1..5)
    ("jatse", "color", 1),
    ("yua",   "color", 2),
    ("rua",   "color", 3),
    ("sine",  "color", 4),
    ("thie",  "color", 5),

    # Leccion 4: Animales (animal_1..5)
    ("kunia",    "animal", 1),
    ("kumichin", "animal", 2),
    ("kuxijna",  "animal", 3),
    ("kunthua",  "animal", 4),
    ("kukapio",  "animal", 5),

    # Leccion 5: Familia (familia_1..5)
    ("ndudaa",   "familia", 1),
    ("jannaa",   "familia", 2),
    ("choo",     "familia", 3),
    ("nichoo",   "familia", 4),
    ("junchjan", "familia", 5),

    # Leccion 6: Cuerpo (cuerpo_1..8)
    ("jaa",       "cuerpo", 1),
    ("jmakon",    "cuerpo", 2),
    ("chinthjon", "cuerpo", 3),
    ("rua",       "cuerpo", 4),
    ("raa",       "cuerpo", 5),
    ("ruthea",    "cuerpo", 6),
    ("neje",      "cuerpo", 7),
    ("thusin",    "cuerpo", 8),

    # Leccion 7: Alimentos (alimento_1..7)
    ("nio",       "alimento", 1),
    ("nua",       "alimento", 2),
    ("niunthaon", "alimento", 3),
    ("thukma",    "alimento", 4),
    ("thuchmoin", "alimento", 5),
    ("ndaxra",    "alimento", 6),
    ("tumi",      "alimento", 7),

    # Leccion 8: Verbos (verbo_1..8)
    ("nichma",  "verbo", 1),
    ("thji",    "verbo", 2),
    ("thii",    "verbo", 3),
    ("tsjee",   "verbo", 4),
    ("thjen",   "verbo", 5),
    ("tsmjan",  "verbo", 6),
    ("tsmjang", "verbo", 7),
    ("ruchrin", "verbo", 8),

    # Leccion 9: Casa (casa_1..8)
    ("nchian", "casa", 1),
    ("nuxra",  "casa", 2),
    ("xrui",   "casa", 3),
    ("nthaa",  "casa", 4),
    ("xro",    "casa", 5),
    ("xroon",  "casa", 6),
    ("nunthe", "casa", 7),
    ("xra",    "casa", 8),

    # Leccion 10: Ropa (ropa_1..7)
    ("ruthe",        "ropa", 1),
    ("xranchritmja", "ropa", 2),
    ("ruthe jatse",  "ropa", 3),
    ("ruthe thie",   "ropa", 4),
    ("nuxra rua",    "ropa", 5),
    ("raa ruthe",    "ropa", 6),
    ("ruthea nuxra", "ropa", 7),

    # Leccion 11: Tiempo (tiempo_1..8)
    ("nchaon", "tiempo", 1),
    ("chrin",  "tiempo", 2),
    ("nunthe", "tiempo", 3),
    ("nthaa",  "tiempo", 4),
    ("xro",    "tiempo", 5),
    ("rajna",  "tiempo", 6),
    ("nua",    "tiempo", 7),
    ("xrui",   "tiempo", 8),

    # Leccion 12: Frases (frase_1..7)
    ("deo",           "frase", 1),
    ("jian",          "frase", 2),
    ("thji",          "frase", 3),
    ("nthii",         "frase", 4),
    ("nthia",         "frase", 5),
    ("jian nchaon",   "frase", 6),
    ("nichma Ngigua", "frase", 7),
]


def generate(word: str, categoria: str, n: int, force: bool = False) -> str:
    filename = f"{categoria}_{n}.mp3"
    filepath = os.path.join(AUDIO_DIR, filename)

    if os.path.exists(filepath) and not force:
        print(f"  [skip] {filename} ya existe")
        return filepath

    try:
        tts = gTTS(text=word, lang='es', slow=True)
        tts.save(filepath)
        print(f"  [OK]   {filename}  <- '{word}'")
        time.sleep(0.3)  # Pausa breve para no saturar la API
    except Exception as e:
        print(f"  [ERR]  {filename}  <- '{word}': {e}")

    return filepath


def main():
    force = "--force" in sys.argv
    if force:
        print("Modo --force: sobreescribira archivos existentes\n")

    print(f"Generando {len(WORDS)} archivos de audio en {AUDIO_DIR}\n")
    ok = 0
    for word, cat, n in WORDS:
        generate(word, cat, n, force=force)
        ok += 1

    print(f"\nListo. {ok}/{len(WORDS)} archivos procesados.")
    print(f"Directorio: {AUDIO_DIR}")


if __name__ == "__main__":
    main()
