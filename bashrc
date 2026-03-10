#!/bin/bash
# ===============================================================
# BASHRC PORTABLE - UBUNTU/GNOME BASE
# ===============================================================
# Versión: 2.4
# Objetivo: Configuración altamente portable para distros basadas
#           en Ubuntu/Gnome. Sin dependencias externas.
# Principios:
#   - Prioriza seguridad del usuario
#   - Solo herramientas preinstaladas
#   - Detección dinámica de comandos opcionales
#   - Cero errores de ejecución
# ===============================================================

# Si no es interactivo, salir
# Esto evita que el script se ejecute en shells no interactivos
# como cuando se ejecutan scripts o comandos remotos
[ -z "$PS1" ] && return

# ===============================================================
# 1. CONFIGURACIÓN DE HISTORIAL
# ===============================================================
# ignoreboth: ignora comandos duplicados y los que empiezan con espacio
HISTCONTROL=ignoreboth

# histappend: añade al historial en lugar de sobrescribirlo
# Útil cuando tienes múltiples terminales abiertas
shopt -s histappend

# Tamaño del historial en memoria (comandos recordados en la sesión actual)
HISTSIZE=10000

# Tamaño del archivo de historial en disco (~/.bash_history)
HISTFILESIZE=20000

# Formato de timestamp para cada comando: día/mes/año hora:minuto:segundo
HISTTIMEFORMAT="%d/%m/%y %T "

# ===============================================================
# 2. OPTIMIZACIONES DE BASH
# ===============================================================
# Habilitar corrección ortográfica menor en 'cd'
# Si escribes 'cd Documnetos' te sugerirá 'cd Documentos'
shopt -s cdspell

# Verificar el tamaño de la ventana después de cada comando
# Actualiza LINES y COLUMNS si cambia el tamaño del terminal
shopt -s checkwinsize

# ===============================================================
# 3. COLORES Y ESTÉTICA (PROMPT)
# ===============================================================
# Definición de colores para usar en el prompt y aliases
RESET='\[\033[0m\]'      # Resetear todos los atributos
VERDE='\[\033[01;32m\]'  # Verde brillante
AZUL='\[\033[01;34m\]'   # Azul brillante
BLANCO='\[\033[01;37m\]' # Blanco brillante
ROJO='\[\033[01;31m\]'   # Rojo brillante

# Prompt semáforo (Verde si el comando anterior tuvo éxito, Rojo si falló)
# Formato: ┌──(usuario@host)──[/ruta/actual]
#          └─❯
# FIX: $? debe capturarse con PROMPT_COMMAND antes de que PS1 lo evalúe,
# de lo contrario siempre devuelve 0 (el código de la propia expansión).
_set_prompt_color() {
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        _PROMPT_COLOR='\[\033[01;32m\]'
    else
        _PROMPT_COLOR='\[\033[01;31m\]'
    fi
}
PROMPT_COMMAND='_set_prompt_color'
PS1="${VERDE}┌──(${AZUL}\u@\h${VERDE})──[${BLANCO}\w${VERDE}]\n${VERDE}└─\${_PROMPT_COLOR}❯ ${RESET}"

# Si es una terminal xterm, cambiar el título a usuario@host:directorio
# Esto hace que el título de la ventana del terminal muestre información útil
case "$TERM" in
xterm*|rxvt*)
    # \e]0; establece el título de la ventana
    # ${debian_chroot:+($debian_chroot)} muestra el chroot si existe
    # \u@\h: \w muestra usuario@host: directorio
    # \a es el carácter de campana que cierra la secuencia de escape
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Detección segura de colores (dircolors)
# dircolors configura los colores para ls y otros comandos
if command -v dircolors >/dev/null 2>&1; then
    # Si existe ~/.dircolors personalizado, usarlo; sino usar el predeterminado
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    
    # Habilitar colores en comandos comunes
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Limpiar variables temporales
unset color_prompt force_color_prompt

# ===============================================================
# 4. MEJORAS EN LESS
# ===============================================================
# Hacer que 'less' sea más amigable con archivos no textuales
# lesspipe permite ver contenido de archivos comprimidos, PDFs, etc.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ===============================================================
# 5. AUTOCOMPLETADO INTELIGENTE
# ===============================================================
# Habilitar autocompletado programable (bash-completion)
# Esto mejora el autocompletado con Tab para comandos como git, apt, ssh, etc.
if ! shopt -oq posix; then
    # Intentar cargar desde las ubicaciones estándar
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        # Ubicación en sistemas modernos (Ubuntu 16.04+)
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        # Ubicación en sistemas más antiguos
        . /etc/bash_completion
    fi
fi

# ===============================================================
# 6. NAVEGACIÓN Y ARCHIVOS
# ===============================================================
# Navegación rápida hacia arriba en el árbol de directorios
alias ..='cd ..'         # Subir un nivel
alias ...='cd ../..'     # Subir dos niveles
alias ....='cd ../../..' # Subir tres niveles

# Crear directorios con subdirectorios automáticamente
alias md='mkdir -p'

# ---------------------------------------------------------------
# Listados de archivos
# ---------------------------------------------------------------
alias l='ls -CF'    # Listado en columnas con indicadores de tipo (/, *, @)
alias ll='ls -lh'   # Listado largo con tamaños legibles (K, M, G)
alias la='ls -A'    # Mostrar archivos ocultos (excepto . y ..)

# ---------------------------------------------------------------
# Seguridad interactiva (confirmación antes de acciones destructivas)
# ---------------------------------------------------------------
alias rm='rm -i'  # Preguntar antes de eliminar
alias cp='cp -i'  # Preguntar antes de sobrescribir al copiar
alias mv='mv -i'  # Preguntar antes de sobrescribir al mover

# ---------------------------------------------------------------
# Gestión del archivo de configuración
# ---------------------------------------------------------------
alias bashrc='nano ~/.bashrc'  # Editar este archivo rápidamente
alias reload='source ~/.bashrc' # Recargar configuración sin cerrar terminal
alias cls='clear'               # Limpiar pantalla (más corto que 'clear')

# ===============================================================
# 7. MANTENIMIENTO Y SISTEMA
# ===============================================================
# Actualización completa del sistema (update + upgrade)
alias actualizar='sudo apt update && sudo apt upgrade -y'
alias up='actualizar'  # Alias corto para compatibilidad

# Limpieza de paquetes huérfanos y caché
alias limpiar='sudo apt autoremove -y && sudo apt autoclean'

# Ver uso de disco del directorio actual, ordenado por tamaño
alias disco='du -sh * | sort -hr'

# ===============================================================
# 8. REDES E IP
# ===============================================================
# Obtener IP pública usando servicio externo
# FIX: verificar curl antes de definir el alias (principio del script: detección dinámica)
if command -v curl >/dev/null 2>&1; then
    alias miip='curl -s https://ifconfig.me; echo'
elif command -v wget >/dev/null 2>&1; then
    alias miip='wget -qO- https://ifconfig.me; echo'
else
    miip() { echo '❌ curl/wget no disponibles'; }
fi

# Listar todas las IPs locales (excepto localhost)
# Usa awk en lugar de Perl regex para mayor compatibilidad
alias iplocal="ip -4 addr show | awk '/inet/ && !/127.0.0.1/ {gsub(/\/.*/, \"\", \$2); print \$2}'"

# ===============================================================
# 9. GIT BÁSICO
# ===============================================================
# Aliases cortos para comandos git más comunes
alias gs='git status'                        # Ver estado del repositorio
alias ga='git add'                          # Añadir archivos al stage
alias gc='git commit -m'                    # Commit con mensaje
alias gp='git push'                         # Push a remoto
alias gl='git log --oneline --graph --all' # Log gráfico compacto

# ===============================================================
# 10. FUNCIONES ÚTILES
# ===============================================================

# ---------------------------------------------------------------
# mkcd - Crear directorio y entrar en él en un solo comando
# ---------------------------------------------------------------
# Uso: mkcd nombre_directorio
# Ejemplo: mkcd proyecto/nuevo/subdirectorio
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# ---------------------------------------------------------------
# como - Consulta rápida de comandos usando cheat.sh
# ---------------------------------------------------------------
# Uso: como comando
# Ejemplo: como tar
# Ejemplo: como git/checkout
como() {
    curl -s "https://cheat.sh/$1"
}

# ---------------------------------------------------------------
# extract - Extractor universal de archivos comprimidos
# ---------------------------------------------------------------
# Detecta automáticamente el formato y usa el descompresor apropiado
# Uso: extract archivo.tar.gz
# Soporta: tar.gz, tar.bz2, zip, rar, 7z, gz, bz2, etc.
extract() {
    # Verificar que se proporcionó un argumento
    if [ -z "$1" ]; then
        echo "Uso: extract archivo_comprimido"
        return 1
    fi
    
    # Verificar que el archivo existe
    if [ -f "$1" ]; then
        # Detectar formato por extensión y extraer
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;  # tar comprimido con bzip2
            *.tar.gz)    tar xzf "$1"     ;;  # tar comprimido con gzip
            *.bz2)       bunzip2 "$1"     ;;  # bzip2
            *.rar)       
                # rar requiere unrar (no viene preinstalado)
                if command -v unrar >/dev/null 2>&1; then
                    unrar x "$1"
                else
                    echo "❌ unrar no instalado. Instala con: sudo apt install unrar"
                    return 1
                fi
                ;;
            *.gz)        gunzip "$1"      ;;  # gzip
            *.tar)       tar xf "$1"      ;;  # tar sin comprimir
            *.tbz2)      tar xjf "$1"     ;;  # tar.bz2 (nombre alternativo)
            *.tgz)       tar xzf "$1"     ;;  # tar.gz (nombre alternativo)
            *.zip)       unzip "$1"       ;;  # zip
            *.Z)         uncompress "$1"  ;;  # compress (Unix antiguo)
            *.7z)        
                # 7z requiere p7zip (no viene preinstalado)
                if command -v 7z >/dev/null 2>&1; then
                    7z x "$1"
                else
                    echo "❌ 7z no instalado. Instala con: sudo apt install p7zip-full"
                    return 1
                fi
                ;;
            *)           echo "'$1' -> Formato desconocido." ;;
        esac
    else
        echo "'$1' no es un archivo válido"
        return 1
    fi
}

# ---------------------------------------------------------------
# genpass - Generar contraseña aleatoria segura
# ---------------------------------------------------------------
# Usa /dev/urandom (fuente de aleatoriedad del sistema)
# Uso: genpass [longitud]
# Ejemplo: genpass 20
# Por defecto genera contraseñas de 16 caracteres
genpass() {
    local length=${1:-16}  # Si no se especifica, usar 16
    # tr -dc: eliminar todos los caracteres excepto A-Z, a-z, 0-9
    # head -c: tomar solo los primeros N caracteres
    tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$length"
    echo  # Nueva línea al final
}

# ---------------------------------------------------------------
# buscar - Buscar archivos por nombre (case insensitive)
# ---------------------------------------------------------------
# Uso: buscar nombre
# Ejemplo: buscar documento
# Busca en el directorio actual y subdirectorios
buscar() {
    if [ -z "$1" ]; then
        echo "Uso: buscar nombre_archivo"
        return 1
    fi
    # -iname: insensitive case (ignora mayúsculas/minúsculas)
    # 2>/dev/null: ocultar errores de permisos
    find . -iname "*$1*" 2>/dev/null
}

# ---------------------------------------------------------------
# buscar_texto - Buscar texto dentro de archivos
# ---------------------------------------------------------------
# Uso: buscar_texto 'texto a buscar'
# Ejemplo: buscar_texto 'TODO'
# Busca recursivamente en todos los archivos
buscar_texto() {
    if [ -z "$1" ]; then
        echo "Uso: buscar_texto 'texto a buscar'"
        return 1
    fi
    # -r: recursivo
    # -i: case insensitive
    # -n: mostrar número de línea
    grep -rin "$1" . 2>/dev/null
}

# ---------------------------------------------------------------
# buscar_grande - Buscar archivos grandes
# ---------------------------------------------------------------
# Uso: buscar_grande [tamaño_mínimo]
# Ejemplo: buscar_grande 100M
# Por defecto busca archivos mayores a 100MB
buscar_grande() {
    local size=${1:-100M}
    echo "Buscando archivos mayores a $size..."
    # -type f: solo archivos (no directorios)
    # -size +100M: mayor a 100 megabytes
    # sort -k5 -hr: ordenar por columna 5 (tamaño) en orden reverso
    find . -type f -size +"$size" -exec ls -lh {} \; 2>/dev/null | sort -k5 -hr
}

# ---------------------------------------------------------------
# mod_hoy - Archivos modificados hoy
# ---------------------------------------------------------------
# Lista todos los archivos modificados en las últimas 24 horas
mod_hoy() {
    echo "Archivos modificados hoy:"
    # -mtime 0: modificados en las últimas 24 horas
    # -ls: formato de listado detallado
    find . -type f -mtime 0 -ls 2>/dev/null
}

# ---------------------------------------------------------------
# mod_recientes - Archivos modificados en la última semana
# ---------------------------------------------------------------
mod_recientes() {
    echo "Archivos modificados en los últimos 7 días:"
    # -mtime -7: modificados en los últimos 7 días
    find . -type f -mtime -7 -ls 2>/dev/null
}

# ---------------------------------------------------------------
# temps - Ver temperatura del CPU
# ---------------------------------------------------------------
# Lee directamente del sistema de archivos del kernel
temps() {
    if [ -r /sys/class/thermal/thermal_zone0/temp ]; then
        local temp=$(cat /sys/class/thermal/thermal_zone0/temp)
        # Convertir de miligrados a grados Celsius
        echo "CPU: $((temp / 1000))°C"
    else
        echo "No se pudo leer la temperatura (requiere /sys/class/thermal/)"
    fi
}

# ---------------------------------------------------------------
# procesos_top - Procesos que más CPU consumen
# ---------------------------------------------------------------
# Muestra los 10 procesos que más recursos usan
procesos_top() {
    echo "Top 10 procesos por uso de CPU:"
    # ps aux: todos los procesos con detalles
    # sort -nrk 3,3: ordenar por columna 3 (% CPU) numéricamente en reverso
    # head -n 11: primeros 11 (1 header + 10 procesos)
    ps aux | head -1  # Mostrar cabecera
    ps aux | sort -nrk 3,3 | head -n 10
}

# ---------------------------------------------------------------
# ram_info - Información rápida de memoria RAM
# ---------------------------------------------------------------
ram_info() {
    echo "Uso de memoria RAM:"
    # free -h: formato human-readable (GB, MB, etc.)
    # grep Mem: solo la línea de memoria (no swap)
    free -h | grep Mem
}

# ---------------------------------------------------------------
# info - Resumen completo del sistema con ASCII art
# ---------------------------------------------------------------
# Muestra un dashboard con toda la información relevante
# Incluye ASCII art de Tux (el pingüino de Linux)
info() {
    # Colores
    local CYAN='\033[0;36m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local RESET='\033[0m'
    
    # ASCII art de Tux
    echo -e "${GREEN}"
    cat << "EOF"
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⠞⢛⣟⢛⠻⣿⣛⣛⣟⣛⠳⣦⣤⣤⣴⠶⠿⠛⢛⣻⣟⣻⣿⣿⣷⣶⣶⣤⣀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⠾⠛⢉⣠⡾⣿⡿⢿⣷⣶⣤⡈⠉⠉⠛⠻⢯⣥⡀⠀⣀⣤⠶⣻⣿⢻⣿⣿⣯⡍⠙⠻⢿⣿⣦⡀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣶⠿⠟⢀⣴⠞⠋⠁⢰⣿⡿⢿⣯⣉⣿⣷⠀⠀⠀⠀⠀⠈⣿⠟⠉⠀⢰⣿⣿⢿⣿⣉⣿⣿⡄⠀⠀⠀⠉⣿
⠀⠀⠀⠀⠀⠀⢀⣤⡾⠋⠃⠀⠀⠻⣧⡀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⣸⡇⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⢀⣴⡟
⠀⠀⠀⠀⢀⣴⠟⠉⠀⠀⠀⠀⠀⠀⠀⠙⠳⢦⣤⣙⣻⠿⠿⠟⠋⣁⣀⣠⣤⣶⠾⠋⠳⠶⣤⣤⣤⣙⣻⣿⣿⣿⣯⣥⣶⡶⣿⡿⠟⠀
⠀⠀⠀⣴⣿⠁⠀⠀⠀⠀⢀⣤⠶⠶⠶⠶⣦⣤⣤⣉⡉⠉⠉⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀
⠀⢠⣾⠋⠀⠀⠀⠀⠀⠀⢿⣧⡀⠀⠰⣤⣀⣀⠀⠉⠙⠛⠛⠷⠶⢶⣦⣤⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣠⣤⣶⠾⠛⣷⡄⠀
⣰⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠷⣦⣄⡀⠉⠛⠒⠶⢤⣄⠀⠀⠀⠀⠀⠈⠉⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠉⠉⠀⠀⣀⣴⣿⠁⠀
⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠳⢶⣤⣄⣀⠀⠀⠈⠉⠉⠛⠓⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡇⢻⡆⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠻⠷⢶⣤⣤⣤⣤⣤⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣴⠿⠁⠈⢿⡀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠉⠙⠛⠉⠉⠁⠀⠀⠀⠘⣧
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⠉⠛⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⡇⠀⢹⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⡇⠀⣼⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡿⠁⢀⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠛⠁⠀⠘⠿⠶⠶⣦⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠋⠀⠀⠀⠀⠀⠀⠀⠀⠈⢉⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢋⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⠟⠁⠀⠀⠀⣀⣤⣤⣀⣀⠀⠀⣀⣴⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⠟⠁⠀⠀⠀⣠⣾⠟⠁⠀⠉⠉⠉⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
EOF
    echo -e "${RESET}"
    
    # Información del sistema con colores
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║${YELLOW}                    SYSTEM INFORMATION                     ${GREEN}║${RESET}"
    echo -e "${GREEN}╠═══════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${GREEN}║${RESET} OS           : $(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || lsb_release -d 2>/dev/null | cut -f2 || echo 'N/A')"
    echo -e "${GREEN}║${RESET} Kernel       : $(uname -r)"
    echo -e "${GREEN}║${RESET} Uptime       : $(uptime -p 2>/dev/null || uptime | awk '{print $3,$4}')"
    echo -e "${GREEN}║${RESET} User         : $USER @ $HOSTNAME"
    echo -e "${GREEN}╠═══════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${GREEN}║${RESET} CPU          : $(lscpu 2>/dev/null | grep 'Model name' | cut -d: -f2 | xargs | cut -c1-45 || echo 'N/A')"
    echo -e "${GREEN}║${RESET} Load Avg     : $(uptime | awk -F'load average:' '{print $2}')"
    # FIX: la división $3/$2 con free -h usa sufijos (Gi, Mi) que awk no puede dividir.
    # Usar free en bytes (sin -h) para el cálculo del porcentaje.
    echo -e "${GREEN}║${RESET} Memory       : $(free -h | awk '/^Mem:/ {print $3 " / " $2}') ($(free | awk '/^Mem:/ {printf "%d%%", $3/$2*100}'))"
    echo -e "${GREEN}║${RESET} Disk (/)     : $(df -h / | tail -1 | awk '{print $3 " / " $2 " (" $5 ")"}')"
    echo -e "${GREEN}╠═══════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${GREEN}║${RESET} IP Local     : $(hostname -I 2>/dev/null | awk '{print $1}' || echo 'N/A')"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

# ===============================================================
# 11. MANUALES A COLOR
# ===============================================================
# Configurar colores para las páginas man (manual)
# Hace que los manuales sean más legibles con sintaxis resaltada
export LESS_TERMCAP_mb=$'\E[01;31m'       # Inicio de parpadeo (rojo)
export LESS_TERMCAP_md=$'\E[01;31m'       # Inicio de negrita (rojo)
export LESS_TERMCAP_me=$'\E[0m'           # Fin de modo
export LESS_TERMCAP_se=$'\E[0m'           # Fin de destacado
export LESS_TERMCAP_so=$'\E[01;44;33m'    # Inicio de destacado (amarillo sobre azul)
export LESS_TERMCAP_ue=$'\E[0m'           # Fin de subrayado
export LESS_TERMCAP_us=$'\E[01;32m'       # Inicio de subrayado (verde)

# ===============================================================
# 12. NOTIFICACIONES
# ===============================================================
# Enviar notificación del escritorio cuando termine un comando largo
# Uso: comando_largo ; alert
# Características:
# - Notificación de escritorio (si notify-send disponible)
# - Beep del sistema (\a)
# - Mensaje en terminal
# Solo se activa si notify-send está disponible (típico en GNOME)
if command -v notify-send >/dev/null 2>&1; then
    # Versión completa con notificación GNOME
    alias alert='notify-send --urgency=critical -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')" && echo "--- Tarea finalizada ---" && echo -e "\a"'
else
    # Versión simple sin notify-send (solo beep + mensaje)
    alias alert='echo "--- Tarea finalizada ---" && echo -e "\a"'
fi

# ===============================================================
# 13. ALIASES Y FUNCIONES AVANZADAS
# ===============================================================

# ---------------------------------------------------------------
# please - Repetir último comando con sudo (SEGURO)
# ---------------------------------------------------------------
# Ejecuta el último comando con sudo, pero con seguridad:
# 1. No funciona si el comando ya tenía sudo
# 2. Muestra el comando en rojo como advertencia
# 3. Pide confirmación (y/N)
# Uso: please
# Ejemplo: apt update [Permission denied]
#          please [muestra comando y pide confirmación]
please() {
    # Obtener el último comando del historial (sin el número)
    # FIX: fc -ln -2 -2 obtiene el penúltimo comando de forma fiable,
    # evitando la desincronización de historial con tail/head.
    local last_cmd=$(fc -ln -2 -2 2>/dev/null | sed 's/^[[:space:]]*//')
    
    # Verificar que hay un comando
    if [ -z "$last_cmd" ]; then
        echo "❌ No hay comando anterior en el historial"
        return 1
    fi
    
    # Verificar si el comando ya empieza con sudo
    if [[ "$last_cmd" =~ ^sudo ]]; then
        echo "❌ El comando anterior ya tiene sudo"
        return 1
    fi
    
    # Mostrar el comando en rojo (advertencia)
    echo -e "\033[1;31m¿Ejecutar con sudo?\033[0m"
    echo -e "\033[1;31m→ sudo $last_cmd\033[0m"
    
    # Pedir confirmación (y/N, por defecto No)
    read -p "Continuar? (y/N): " -n 1 -r
    echo
    
    # Verificar respuesta (solo 'y' o 'Y' acepta)
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Ejecutar con sudo
        eval "sudo $last_cmd"
    else
        echo "✗ Cancelado"
        return 1
    fi
}

# ---------------------------------------------------------------
# top-commands - Ver tus 10 comandos más usados
# ---------------------------------------------------------------
# Analiza tu historial para ver qué comandos usas más
alias top-commands="history | awk '{print \$2}' | sort | uniq -c | sort -rn | head -10"

# ---------------------------------------------------------------
# h - Buscar en el historial
# ---------------------------------------------------------------
# Uso: h texto
# Ejemplo: h docker
# Busca en tu historial de comandos
h() {
    if [ -z "$1" ]; then
        echo "Uso: h término_a_buscar"
        return 1
    fi
    history | grep "$1"
}

# ---------------------------------------------------------------
# cd mejorado - Auto-listing + Navegación por niveles
# ---------------------------------------------------------------
# Sobrescribe el comando cd para añadir funcionalidades:
# 1. cd -N: Sube N niveles (cd -3 = ../../..)
# 2. Auto-listing: Muestra contenido al cambiar de directorio
# Uso: cd /tmp        → cambia y lista
#      cd -3          → sube 3 niveles y lista
#      builtin cd /tmp → cd original sin auto-ls
cd() {
    if [[ $1 =~ ^-[0-9]+$ ]]; then
        # Modo: cd -N (subir N niveles)
        local n=${1#-}
        local path=""
        for(( i=0; i<n; i++ )); do
            path+="../"
        done
        builtin cd "$path" && ls -F
    else
        # Modo normal con auto-listing
        builtin cd "$@" && ls -F
    fi
}

# ---------------------------------------------------------------
# term_rename - Cambiar título del terminal
# ---------------------------------------------------------------
# Cambia el título de la ventana del terminal actual
# Útil para identificar terminales en la barra de tareas
# FIX: renombrado a term_rename para no sobreescribir el comando del sistema "rename"
# (herramienta de renombrado masivo de archivos con regex).
# Uso: term_rename "Servidor Web"
#      term_rename "Compilando Proyecto"
term_rename() {
    local titulo="$*"
    # Enviar secuencia de escape para cambiar título
    echo -en "\033]0;${titulo}\a"
}

# ---------------------------------------------------------------
# bak - Backup rápido de archivo
# ---------------------------------------------------------------
# Crea una copia de seguridad con extensión .bak
# Uso: bak archivo.txt
# Resultado: archivo.txt.bak
bak() {
    if [ -z "$1" ]; then
        echo "Uso: bak archivo"
        return 1
    fi
    
    if [ ! -f "$1" ]; then
        echo "❌ El archivo '$1' no existe"
        return 1
    fi
    
    cp "$1" "$1.bak" && echo "✓ Backup creado: $1.bak"
}

# ---------------------------------------------------------------
# calc - Calculadora rápida de terminal
# ---------------------------------------------------------------
# Evalúa expresiones matemáticas simples (solo enteros)
# Uso: calc 150+300*2
#      calc 10*5
#      calc 100/4
# Nota: Usa aritmética bash, solo números enteros
calc() {
    if [ -z "$1" ]; then
        echo "Uso: calc expresión"
        echo "Ejemplo: calc 150+300*2"
        return 1
    fi
    # FIX: Advertir explícitamente si la expresión contiene punto flotante
    if [[ "$*" =~ \. ]]; then
        echo "❌ calc solo soporta enteros. Para decimales usa: python3 -c \"print($*)\""
        return 1
    fi
    echo "$(( $@ ))"
}

# ---------------------------------------------------------------
# note - Sistema de notas rápidas
# ---------------------------------------------------------------
# Guarda notas con timestamp en ~/.bash_notes
# Uso: note "revisar logs del servidor a las 5"
#      note "llamar a cliente mañana"
# Ver notas: notes
# Limpiar: notes-clear
note() {
    if [ -z "$1" ]; then
        echo "Uso: note \"tu nota aquí\""
        return 1
    fi
    echo "[$(date +'%Y-%m-%d %H:%M')] $*" >> ~/.bash_notes
    echo "✓ Nota guardada"
}

# Ver todas las notas
alias notes='cat ~/.bash_notes 2>/dev/null || echo "📝 No hay notas aún. Usa: note \"tu nota aquí\""'

# Limpiar todas las notas
alias notes-clear='rm ~/.bash_notes 2>/dev/null && echo "✓ Notas borradas"'

# ---------------------------------------------------------------
# yeet - Desinstalar paquetes de forma agresiva
# ---------------------------------------------------------------
# Elimina paquetes, configuraciones y dependencias sin confirmación
# Detecta automáticamente el gestor de paquetes
# Uso: yeet nombre_paquete
yeet() {
    if [ -z "$1" ]; then
        echo "Uso: yeet paquete_a_eliminar"
        return 1
    fi
    
    echo "🗑️  Yeeting $@..."
    
    if command -v apt &> /dev/null; then
        # Debian/Ubuntu - purge + autoremove + autoclean
        sudo apt purge -y "$@"
        sudo apt autoremove -y
        sudo apt autoclean
    elif command -v pacman &> /dev/null; then
        # Arch Linux - Rns elimina paquete + dependencias huérfanas
        sudo pacman -Rns --noconfirm "$@"
        # Limpiar caché de paquetes
        sudo pacman -Sc --noconfirm
    elif command -v dnf &> /dev/null; then
        # Fedora - remove + autoremove
        sudo dnf remove -y "$@"
        sudo dnf autoremove -y
    elif command -v zypper &> /dev/null; then
        # openSUSE - remove con limpieza de dependencias
        sudo zypper remove -y --clean-deps "$@"
    else
        echo "❌ No se detectó un gestor de paquetes compatible."
        echo "Gestores soportados: apt, pacman, dnf, zypper"
        return 1
    fi
    
    echo "✅ Yeet completado!"
}

# ---------------------------------------------------------------
# web - Abrir búsqueda web desde terminal
# ---------------------------------------------------------------
# Usa tu navegador predeterminado para buscar en StartPage
# Uso: web "cómo arreglar grub"
# Nota: Requiere xdg-open (viene preinstalado en Ubuntu/GNOME)
web() {
    if [ -z "$1" ]; then
        echo "Uso: web 'término de búsqueda'"
        return 1
    fi
    
    # Verificar que xdg-open existe
    if ! command -v xdg-open &> /dev/null; then
        echo "❌ xdg-open no disponible. Instala: sudo apt install xdg-utils"
        return 1
    fi
    
    # FIX: codificar todos los caracteres especiales, no solo espacios.
    # python3/perl presentes en Ubuntu; fallback a solo espacios si no hay ninguno.
    local raw="$*"
    local query
    if command -v python3 >/dev/null 2>&1; then
        query=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote_plus(sys.argv[1]))" "$raw")
    else
        query=$(echo "$raw" | sed 's/ /+/g; s/&/%26/g; s/#/%23/g; s/?/%3F/g; s/=/%3D/g')
    fi
    xdg-open "https://www.startpage.com/search?q=$query"
}

# ===============================================================
# 14. SISTEMA MODULAR DE CONFIGURACIÓN
# ===============================================================
# Cargador drop-in para mantener personalizaciones separadas
# Permite extender el bashrc sin modificar este archivo
# 
# ⚠️ IMPORTANTE: El sistema modular NO requiere instalar nada.
#    Solo los módulos específicos pueden requerir herramientas.
#
# Cómo usar:
# 1. El directorio se crea automáticamente: ~/.config/env.d
# 2. Añade scripts ejecutables allí (ejemplo: 01-mis-aliases.sh)
# 3. Dale permisos de ejecución: chmod +x ~/.config/env.d/01-mis-aliases.sh
# 4. Recarga el bashrc: source ~/.bashrc
#
# Los archivos se cargan en orden alfabético (usa prefijos numéricos)
# Solo se ejecutan archivos con permiso de ejecución (+x)
#
# ───────────────────────────────────────────────────────────────
# EJEMPLO 1: Módulo personal básico
# ───────────────────────────────────────────────────────────────
# Archivo: ~/.config/env.d/01-personal.sh
# 
# #!/bin/bash
# # Mis aliases personales
# alias projects='cd ~/Proyectos'
# alias backup='rsync -av ~/ /mnt/backup/'
# export MI_VARIABLE="valor"
#
# ───────────────────────────────────────────────────────────────
# EJEMPLO 2: Módulo condicional (Docker, Python, etc.)
# ───────────────────────────────────────────────────────────────
# Archivo: ~/.config/env.d/02-docker.sh
#
# #!/bin/bash
# # Solo se activa si Docker está instalado
# if command -v docker &> /dev/null; then
#     alias dps='docker ps'
#     alias dlogs='docker logs -f'
#     export DOCKER_BUILDKIT=1
# fi
#
# ───────────────────────────────────────────────────────────────

MY_ENV_DIR="$HOME/.config/env.d"

# Crear directorio si no existe
if [ ! -d "$MY_ENV_DIR" ]; then
    mkdir -p "$MY_ENV_DIR" 2>/dev/null
fi

# Cargar módulos si el directorio existe
if [ -d "$MY_ENV_DIR" ]; then
    # Buscar archivos ejecutables y cargarlos en orden
    for module in $(find "$MY_ENV_DIR" -type f -executable 2>/dev/null | sort); do
        # FIX: set -a eliminado. Exportaba todas las variables del módulo
        # al entorno global, incluyendo variables temporales no deseadas.
        # Los módulos deben exportar explícitamente lo que necesiten.
        source "$module" 2>/dev/null
    done
fi

# ===============================================================
# 15. BYEBYE - LIMPIEZA TOTAL Y RESTAURACIÓN
# ===============================================================

alias ByeBye='
  # --- Refrescar sudo una sola vez al principio ---
  sudo -v;

  USER_HOME=$HOME;
  CURRENT_USER=$(whoami);

  # --- Matar agentes activos ---
  gpgconf --kill gpg-agent 2>/dev/null;
  ssh-agent -k 2>/dev/null;

  # --- Shred de datos sensibles (sobreescribe bits, no recuperable) ---
  find $USER_HOME/.ssh -type f -exec shred -u {} \; 2>/dev/null;
  shred -u $USER_HOME/.bash_history $USER_HOME/.zsh_history $USER_HOME/.sh_history $USER_HOME/.python_history 2>/dev/null;

  # --- Vaciar y triturar la Papelera ---
  find $USER_HOME/.local/share/Trash/files -type f -exec shred -u {} \; 2>/dev/null;
  rm -rf $USER_HOME/.local/share/Trash/* 2>/dev/null;

  # --- Browsers ---
  rm -rf $USER_HOME/.cache/google-chrome $USER_HOME/.config/google-chrome 2>/dev/null;
  rm -rf $USER_HOME/.cache/mozilla $USER_HOME/.mozilla 2>/dev/null;
  rm -rf $USER_HOME/.cache/chromium $USER_HOME/.config/chromium 2>/dev/null;
  rm -rf $USER_HOME/.config/BraveSoftware $USER_HOME/.cache/BraveSoftware 2>/dev/null;

  # --- Shred de propiedad intelectual ---
  find $USER_HOME/Documentos $USER_HOME/Escritorio $USER_HOME/Descargas $USER_HOME/Imágenes $USER_HOME/Documents $USER_HOME/Desktop $USER_HOME/Downloads $USER_HOME/Pictures -type f -exec shred -u {} \; 2>/dev/null;

  # --- Limpiar fragmentos en la memoria Swap ---
  sudo swapoff -a 2>/dev/null && sudo swapon -a 2>/dev/null;

  # --- Historial y recientes ---
  rm -rf $USER_HOME/.cache/thumbnails 2>/dev/null;
  rm -f $USER_HOME/.local/share/recently-used.xbel 2>/dev/null;

  # --- /tmp y /var/tmp ---
  sudo rm -rf /tmp/* /tmp/.* 2>/dev/null;
  sudo rm -rf /var/tmp/* 2>/dev/null;

  # --- Paquetes instalados en la sesión ---
  sudo apt autoremove --purge -y 2>/dev/null;
  sudo apt clean 2>/dev/null;

  # --- Logs de sesión ---
  sudo journalctl --vacuum-time=1s 2>/dev/null;
  sudo rm -f /var/log/wtmp /var/log/btmp 2>/dev/null;
  sudo truncate -s 0 /var/log/lastlog 2>/dev/null;

  # --- Borrar TODO el home ---
  find $USER_HOME -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null;

  # --- Restaurar exactamente lo que tiene /etc/skel ---
  cp /etc/skel/.bash_logout $USER_HOME/;
  cp /etc/skel/.bashrc $USER_HOME/;
  cp /etc/skel/.profile $USER_HOME/;
  cp /etc/skel/.face $USER_HOME/ 2>/dev/null;
  ln -sf $USER_HOME/.face $USER_HOME/.face.icon 2>/dev/null;

  # --- Permisos correctos ---
  chmod 700 $USER_HOME;
  chmod 644 $USER_HOME/.bash_logout $USER_HOME/.bashrc $USER_HOME/.profile;

  # --- Recrear carpetas XDG estándar ---
  xdg-user-dirs-update 2>/dev/null;

  # --- Limpiar caché del sistema ---
  sudo sync;
  sudo sh -c "echo 3 > /proc/sys/vm/drop_caches";

  # --- Limpiar caché de DNS ---
  sudo systemd-resolve --flush-caches 2>/dev/null;
  sudo resolvectl flush-caches 2>/dev/null;

  # --- Limpiar historial en memoria ---
  history -c;
  history -w;
  clear;

  # --- Reiniciar el sistema (la RAM se limpia sola al apagar) ---
  sudo reboot
'

# ===============================================================
# FIN DE CONFIGURACIÓN
# ===============================================================
# 
# PERSONALIZACIÓN:
# - Para añadir tus propios aliases/funciones SIN modificar este archivo,
#   crea scripts en ~/.config/env.d/ (ver sección 14)
# - Para modificaciones directas, añádelas después de esta línea
# - Mantén tus cambios documentados para facilitar actualizaciones
# 
# ===============================================================
