# Guía de Seguridad 🔒

## Protección de Credenciales

Este proyecto utiliza variables de entorno para proteger las credenciales de Supabase.

### Archivos protegidos:

1. **`.env`** - Contiene las credenciales reales (NO SE SUBE AL REPOSITORIO)
2. **`lib/config/supabase_config.dart`** - Puede contener credenciales hardcoded (NO SE SUBE AL REPOSITORIO)

### Configuración para desarrollo:

1. Copia `.env.example` a `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edita `.env` con tus credenciales:
   ```env
   SUPABASE_URL=https://tu-proyecto.supabase.co
   SUPABASE_ANON_KEY=tu_clave_anon_aqui
   ```

3. Nunca compartas el archivo `.env` ni lo subas a Git

### ¿Qué está protegido por .gitignore?

```
.env                           # Archivo principal con credenciales
.env.local                     # Archivo local alternativo
.env.*.local                   # Cualquier variante local
lib/config/supabase_config.dart # Configuración con posibles credenciales
```

### Para colaboradores:

1. Solicita las credenciales al administrador del proyecto
2. Crea tu propio archivo `.env` basado en `.env.example`
3. NUNCA hagas commit del archivo `.env`
4. Si accidentalmente haces commit de credenciales:
   - Revoca inmediatamente las claves en Supabase
   - Genera nuevas claves
   - Fuerza la eliminación del historial de Git

### Verificar antes de hacer commit:

```bash
# Asegúrate de que .env no esté rastreado
git status

# Si aparece .env, agrégalo a .gitignore inmediatamente
echo ".env" >> .gitignore
git add .gitignore
git commit -m "Add .env to gitignore"
```

### Rotar credenciales:

Si sospechas que tus credenciales fueron expuestas:

1. Ve a Supabase Dashboard → Settings → API
2. Haz clic en "Reset anon key" o "Reset service_role key"
3. Actualiza tu archivo `.env` local
4. Notifica al equipo para que actualicen sus archivos

## Mejores prácticas:

✅ Usar `.env` para todas las credenciales  
✅ Mantener `.env.example` actualizado (sin credenciales reales)  
✅ Revisar `.gitignore` antes de cada commit  
✅ No hacer screenshots con credenciales visibles  
✅ Usar diferentes credenciales para desarrollo y producción  

❌ NO hacer hardcode de credenciales en el código  
❌ NO subir `.env` a repositorios públicos o privados  
❌ NO compartir credenciales por Slack, email, etc.  
❌ NO reutilizar credenciales entre proyectos  

---

**Recuerda:** La seguridad es responsabilidad de todos. Si ves credenciales expuestas, repórtalo inmediatamente. 🔐
