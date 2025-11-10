# Angry Birds - Forge2D Edition 🐦💥

Un juego de Angry Birds desarrollado con Flutter y Flame usando el motor de física Forge2D.

## Características 🎮

- ✅ Física realista con Forge2D
- ✅ 3 niveles de dificultad con estructuras únicas:
  - 🙂 **Normal**: Casa simple estilo templo (3 enemigos, 4 bloques)
  - 😰 **Difícil**: Torres gemelas simétricas (4 enemigos, 10 bloques)
  - 💀 **Big Boss**: Pirámide escalonada + Boss (5 enemigos + Boss, 18 bloques)
- ✅ Estructuras prediseñadas simétricas tipo Angry Birds clásico
- ✅ 40 combinaciones de ladrillos destructibles con diferentes tamaños
- ✅ Boss enemigo especial con sistema de vida:
  - Corona 👑 para identificarlo
  - 3 vidas (requiere 3 golpes para derrotarlo)
  - Indicador visual de vida restante (❤️ x3, x2, x1)
  - 2x tamaño, 5x puntos, 3x densidad
- ✅ Nivel pre-construido instantáneamente (sin animaciones de caída)
- ✅ Estructuras y enemigos ya listos al empezar el nivel
- ✅ Sistema de puntuación y estrellas (1-3 ⭐)
- ✅ Sistema de monedas (10 monedas por enemigo, 50 por boss)
- ✅ Tienda con 3 power-ups:
  - 💣 **Explosivo** (50 monedas): Causa una explosión al impactar
  - ⚡ **Pesado** (30 monedas): Más peso y daño
  - 🎯 **División** (80 monedas): Se divide en 3 pájaros
- ✅ Menú de selección de nivel antes de jugar
- ✅ Leaderboard online con Supabase
- ✅ Persistencia de monedas local
- ✅ Sistema de guardado de puntajes

## Instalación 📦

1. Asegúrate de tener Flutter instalado (versión ^3.9.2)

2. Clona este repositorio:
```bash
git clone <tu-repositorio>
cd forge2d_game
```

3. Instala las dependencias:
```bash
flutter pub get
```

## Configuración de Supabase 🗄️

Para habilitar el leaderboard online y el guardado de puntajes, necesitas configurar Supabase:

### 1. Crear un proyecto en Supabase

1. Ve a [https://supabase.com](https://supabase.com)
2. Crea una cuenta o inicia sesión
3. Crea un nuevo proyecto
4. Espera a que el proyecto se inicialice completamente

### 2. Obtener las credenciales

1. En tu proyecto de Supabase, ve a **Settings** > **API**
2. Copia la **URL del proyecto** (Project URL)
3. Copia la **anon/public key** (anon public)

### 3. Configurar las credenciales en la app

1. Copia el archivo `.env.example` y renómbralo a `.env`:
```bash
cp .env.example .env
```

2. Abre el archivo `.env` y reemplaza las credenciales:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu_clave_anon_aqui
```

**⚠️ IMPORTANTE:** El archivo `.env` está en `.gitignore` y NO se subirá al repositorio para proteger tus credenciales.

### 4. Crear las tablas en Supabase

1. En tu proyecto de Supabase, ve a **SQL Editor**
2. Crea una nueva consulta
3. Copia y pega el siguiente SQL:

```sql
-- Tabla de puntajes de Angry Birds (con prefijo para evitar conflictos)
CREATE TABLE angrybirds_scores (
  id BIGSERIAL PRIMARY KEY,
  username TEXT NOT NULL,
  score INTEGER NOT NULL,
  stars INTEGER DEFAULT 0,
  coins INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice para búsquedas rápidas por puntaje
CREATE INDEX idx_angrybirds_scores_score ON angrybirds_scores(score DESC);

-- Índice para búsquedas por usuario
CREATE INDEX idx_angrybirds_scores_username ON angrybirds_scores(username);

-- Tabla de power-ups por usuario de Angry Birds
CREATE TABLE angrybirds_powerups (
  id BIGSERIAL PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  explosive INTEGER DEFAULT 0,
  heavy INTEGER DEFAULT 0,
  splitter INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice único por usuario
CREATE UNIQUE INDEX idx_angrybirds_powerups_username ON angrybirds_powerups(username);
```

4. Ejecuta la consulta haciendo clic en **Run**

### 5. Configurar políticas de acceso (opcional pero recomendado)

Por defecto, las tablas están protegidas. Para permitir acceso público (sin autenticación), ejecuta:

```sql
-- Permitir lectura y escritura en la tabla angrybirds_scores
ALTER TABLE angrybirds_scores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access" ON angrybirds_scores
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow public insert access" ON angrybirds_scores
  FOR INSERT
  TO public
  WITH CHECK (true);

-- Permitir lectura y escritura en la tabla angrybirds_powerups
ALTER TABLE angrybirds_powerups ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access" ON angrybirds_powerups
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow public insert/update access" ON angrybirds_powerups
  FOR ALL
  TO public
  WITH CHECK (true);
```

## Ejecutar el juego 🚀

### Web (Chrome)
```bash
flutter run -d chrome
```

### Windows
```bash
flutter run -d windows
```

### Android
```bash
flutter run -d <id-dispositivo-android>
```

### iOS
```bash
flutter run -d <id-dispositivo-ios>
```

## Cómo jugar 🎯

1. **Menú Principal**:
   - 🎮 **JUGAR**: Seleccionar nivel y jugar
   - 🛒 **TIENDA**: Comprar power-ups
   - 🏆 **RANKING**: Ver el leaderboard

2. **Selección de Nivel**:
   - Elige entre 3 niveles de dificultad
   - Cada nivel tiene estructuras únicas y diferentes enemigos
   - El nivel Big Boss incluye un jefe final

3. **Jugabilidad**:
   - Arrastra el pájaro hacia atrás para apuntar
   - Suelta para lanzar
   - Destruye todos los cerditos para ganar
   - Ganas 10 monedas por cada cerdito destruido (50 por el boss)
   - Tienes 10 intentos máximo
   - Las estructuras están diseñadas con bloques de diferentes tamaños

4. **Power-ups**:
   - Compra power-ups en la tienda
   - Cada power-up se consume en un disparo
   - Los efectos se activan al impactar

5. **Puntuación**:
   - Al finalizar, ingresa tu nombre de usuario
   - Tu puntaje se guardará en el leaderboard
   - Gana estrellas según tu puntuación:
     - ⭐ 1 estrella: ≤ 200 puntos
     - ⭐⭐ 2 estrellas: 200-299 puntos
     - ⭐⭐⭐ 3 estrellas: ≥ 300 puntos

## Estructura del proyecto 📁

```
lib/
├── components/         # Componentes del juego
│   ├── game.dart      # Lógica principal con estructuras prediseñadas
│   ├── level_selector.dart  # Selector de niveles
│   ├── main_menu.dart # Menú principal
│   ├── player.dart    # Pájaro jugable
│   ├── enemy.dart     # Cerditos enemigos + Boss
│   ├── brick.dart     # Bloques destructibles (8 tamaños diferentes)
│   ├── shop_menu.dart # Tienda de power-ups
│   ├── leaderboard_menu.dart # Ranking
│   └── ...
├── services/          # Servicios
│   ├── supabase_service.dart  # Conexión a Supabase
│   └── user_service.dart      # Almacenamiento local
├── config/
│   └── supabase_config.dart   # Configuración de Supabase
└── main.dart          # Punto de entrada
```

## Tecnologías utilizadas 🛠️

- [Flutter](https://flutter.dev/) - Framework de UI
- [Flame](https://flame-engine.org/) - Motor de juegos 2D
- [Flame Forge2D](https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d) - Motor de física
- [Supabase](https://supabase.com/) - Backend y base de datos
- [SharedPreferences](https://pub.dev/packages/shared_preferences) - Almacenamiento local

## Solución de problemas 🔧

### El juego no conecta a Supabase

1. Verifica que las credenciales en `supabase_config.dart` sean correctas
2. Asegúrate de haber creado las tablas con el SQL proporcionado
3. Verifica las políticas de acceso (Row Level Security)
4. Revisa la consola para ver los errores

### Las monedas no se guardan

1. Asegúrate de que la app tenga permisos de almacenamiento
2. En Android, verifica los permisos en `AndroidManifest.xml`

### El leaderboard está vacío

1. Juega al menos una partida completa
2. Ingresa un nombre de usuario cuando se te solicite
3. Verifica que la tabla `angrybirds_scores` en Supabase tenga datos

## Seguridad 🔒

Este proyecto usa variables de entorno para proteger las credenciales de Supabase:

- ✅ Las credenciales se almacenan en `.env` (NO se sube a Git)
- ✅ El archivo `.env.example` sirve como plantilla
- ✅ Usa `flutter_dotenv` para cargar variables de entorno

**⚠️ NUNCA subas el archivo `.env` al repositorio**

Para más información, consulta [SECURITY.md](SECURITY.md)

## Créditos 🎨

- Sprites: Kenney Assets (spritesheet_aliens.xml, spritesheet_elements.xml, spritesheet_tiles.xml)
- Desarrollo: Tutorial de Flame + Forge2D

## Licencia 📄

Este proyecto es para fines educativos.

---

¡Disfruta el juego! 🎮🐦
