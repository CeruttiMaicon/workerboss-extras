#!/usr/bin/env bash

set -e

SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
CUSTOM_DIR="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

# Função para verificar se um comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Função para formatar o binding em formato legível
format_binding() {
    local binding="$1"
    local parts=()
    
    # Extrai os modificadores e a tecla final
    # Exemplo: <Primary><Alt>p -> ["Ctrl", "Alt", "P"]
    
    # Substitui os modificadores e remove os colchetes
    local temp="$binding"
    
    # Extrai Primary
    if echo "$temp" | grep -q "<Primary>"; then
        parts+=("Ctrl")
        temp=$(echo "$temp" | sed 's/<Primary>//')
    fi
    
    # Extrai Shift
    if echo "$temp" | grep -q "<Shift>"; then
        parts+=("Shift")
        temp=$(echo "$temp" | sed 's/<Shift>//')
    fi
    
    # Extrai Alt
    if echo "$temp" | grep -q "<Alt>"; then
        parts+=("Alt")
        temp=$(echo "$temp" | sed 's/<Alt>//')
    fi
    
    # Extrai Super
    if echo "$temp" | grep -q "<Super>"; then
        parts+=("Super")
        temp=$(echo "$temp" | sed 's/<Super>//')
    fi
    
    # O que sobrar é a tecla final (pode ser uma letra, número, etc.)
    if [ -n "$temp" ]; then
        # Converte para maiúscula
        local key=$(echo "$temp" | tr '[:lower:]' '[:upper:]')
        parts+=("$key")
    fi
    
    # Junta tudo com " + "
    local formatted=""
    local first=true
    for part in "${parts[@]}"; do
        if [ "$first" = true ]; then
            formatted="$part"
            first=false
        else
            formatted="$formatted + $part"
        fi
    done
    
    # Adiciona < > ao redor
    echo "<$formatted>"
}

# Função para verificar se um atalho já existe
shortcut_exists() {
    local name="$1"
    local command="$2"
    local binding="$3"
    
    # Obtém a lista atual de custom keybindings
    local raw_bindings=$(gsettings get "$SCHEMA" custom-keybindings 2>/dev/null || echo "[]")
    
    # Extrai apenas o conteúdo dentro dos colchetes
    if [[ ! "$raw_bindings" =~ \[(.*)\] ]]; then
        return 1
    fi
    
    local content="${BASH_REMATCH[1]}"
    if [ -z "$content" ] || [ -z "${content// /}" ]; then
        return 1
    fi
    
    # Itera sobre índices possíveis (0 a 99) para verificar keybindings existentes
    local index=0
    while [ $index -lt 100 ]; do
        local path="$CUSTOM_DIR/custom$index/"
        
        # Verifica se este path está na lista de bindings
        if echo "$raw_bindings" | grep -q "$path"; then
            # Obtém as propriedades deste keybinding
            local existing_name=$(gsettings get "$SCHEMA.custom-keybinding:$path" name 2>/dev/null || echo "")
            local existing_command=$(gsettings get "$SCHEMA.custom-keybinding:$path" command 2>/dev/null || echo "")
            local existing_binding=$(gsettings get "$SCHEMA.custom-keybinding:$path" binding 2>/dev/null || echo "")
            
            # Remove aspas se existirem
            existing_name=$(echo "$existing_name" | sed "s/^'//; s/'$//")
            existing_command=$(echo "$existing_command" | sed "s/^'//; s/'$//")
            existing_binding=$(echo "$existing_binding" | sed "s/^'//; s/'$//")
            
            # Verifica se o nome, comando ou binding já existe
            if [ "$existing_name" = "$name" ] || [ "$existing_command" = "$command" ] || [ "$existing_binding" = "$binding" ]; then
                return 0
            fi
        fi
        
        index=$((index + 1))
    done
    
    return 1
}

# Função para obter o binding de um atalho existente
get_existing_binding() {
    local name="$1"
    local command="$2"
    local binding="$3"
    
    # Obtém a lista atual de custom keybindings
    local raw_bindings=$(gsettings get "$SCHEMA" custom-keybindings 2>/dev/null || echo "[]")
    
    # Extrai apenas o conteúdo dentro dos colchetes
    if [[ ! "$raw_bindings" =~ \[(.*)\] ]]; then
        echo ""
        return
    fi
    
    local content="${BASH_REMATCH[1]}"
    if [ -z "$content" ] || [ -z "${content// /}" ]; then
        echo ""
        return
    fi
    
    # Itera sobre índices possíveis (0 a 99) para verificar keybindings existentes
    local index=0
    while [ $index -lt 100 ]; do
        local path="$CUSTOM_DIR/custom$index/"
        
        # Verifica se este path está na lista de bindings
        if echo "$raw_bindings" | grep -q "$path"; then
            # Obtém as propriedades deste keybinding
            local existing_name=$(gsettings get "$SCHEMA.custom-keybinding:$path" name 2>/dev/null || echo "")
            local existing_command=$(gsettings get "$SCHEMA.custom-keybinding:$path" command 2>/dev/null || echo "")
            local existing_binding=$(gsettings get "$SCHEMA.custom-keybinding:$path" binding 2>/dev/null || echo "")
            
            # Remove aspas se existirem
            existing_name=$(echo "$existing_name" | sed "s/^'//; s/'$//")
            existing_command=$(echo "$existing_command" | sed "s/^'//; s/'$//")
            existing_binding=$(echo "$existing_binding" | sed "s/^'//; s/'$//")
            
            # Verifica se o nome, comando ou binding já existe
            if [ "$existing_name" = "$name" ] || [ "$existing_command" = "$command" ] || [ "$existing_binding" = "$binding" ]; then
                echo "$existing_binding"
                return
            fi
        fi
        
        index=$((index + 1))
    done
    
    echo ""
}

# Função para obter o próximo índice disponível para custom keybindings
get_next_key_index() {
    local current_bindings=$(gsettings get "$SCHEMA" custom-keybindings 2>/dev/null || echo "[]")
    local index=0
    
    # Encontra o próximo índice disponível
    while echo "$current_bindings" | grep -q "$CUSTOM_DIR/custom$index/"; do
        index=$((index + 1))
    done
    
    echo "$index"
}

# Função para adicionar um atalho personalizado
add_custom_shortcut() {
    local key_name="$1"
    local name="$2"
    local command="$3"
    local binding="$4"
    local check_command="$5"
    
    # Verifica se o comando necessário está instalado
    if [ -n "$check_command" ] && ! command_exists "$check_command"; then
        echo "⚠️  Pulando '$name': $check_command não está instalado."
        return 1
    fi
    
    # Verifica se o atalho já existe (por nome, comando ou binding)
    if shortcut_exists "$name" "$command" "$binding"; then
        local existing_binding=$(get_existing_binding "$name" "$command" "$binding")
        if [ -n "$existing_binding" ]; then
            local formatted_binding=$(format_binding "$existing_binding")
            echo "ℹ️  Atalho '$name' já está configurado com: $formatted_binding. Pulando..."
        else
            echo "ℹ️  Atalho '$name' já está configurado. Pulando..."
        fi
        return 0
    fi
    
    # Obtém o próximo índice disponível
    local index=$(get_next_key_index)
    local full_path="$CUSTOM_DIR/custom$index/"
    
    # Obtém a lista atual de custom keybindings
    local raw_bindings=$(gsettings get "$SCHEMA" custom-keybindings 2>/dev/null || echo "[]")
    
    # Extrai apenas o conteúdo dentro dos colchetes (remove @as se existir)
    local current_bindings
    if [[ "$raw_bindings" =~ \[(.*)\] ]]; then
        local content="${BASH_REMATCH[1]}"
        if [ -z "$content" ] || [ -z "${content// /}" ]; then
            # Lista vazia
            current_bindings="['$full_path']"
        else
            # Adiciona o novo item à lista existente
            current_bindings="[$content, '$full_path']"
        fi
    else
        # Se não conseguir extrair, assume lista vazia
        current_bindings="['$full_path']"
    fi
    
    gsettings set "$SCHEMA" custom-keybindings "$current_bindings"
    
    # Define as propriedades do atalho
    gsettings set "$SCHEMA.custom-keybinding:$full_path" name "$name"
    gsettings set "$SCHEMA.custom-keybinding:$full_path" command "$command"
    gsettings set "$SCHEMA.custom-keybinding:$full_path" binding "$binding"
    
    local formatted_binding=$(format_binding "$binding")
    echo "✅ Atalho '$name' configurado com sucesso: $formatted_binding"
    return 0
}

echo "🔧 Configurando atalhos personalizados no GNOME..."
echo ""

# ============================================================================
# DEFINIÇÃO DE ATALHOS PERSONALIZADOS
# ============================================================================
# Para adicionar novos atalhos, adicione uma nova chamada add_custom_shortcut
# com os seguintes parâmetros:
#   1. key_name: Nome único interno do atalho (ex: "flameshot", "warp-terminal")
#   2. name: Nome exibido no GNOME Settings
#   3. command: Comando a ser executado
#   4. binding: Atalho de teclado
#      - <Primary> = Ctrl
#      - <Shift> = Shift
#      - <Alt> = Alt
#      - <Super> = Super/Windows
#   5. check_command: Comando para verificar se está instalado (opcional, use "" se não precisar)
# ============================================================================

# Atalho: Flameshot GUI (Ctrl+Alt+P)
add_custom_shortcut \
    "flameshot" \
    "Flameshot GUI" \
    "sh -c 'flameshot gui'" \
    "<Primary><Alt>p" \
    "flameshot"

# Atalho: WarpTerminal (Ctrl+Alt+T)
add_custom_shortcut \
    "warp-terminal" \
    "WarpTerminal" \
    "warp-terminal" \
    "<Primary><Alt>t" \
    "warp-terminal"

echo ""
echo "✨ Configuração de atalhos concluída!"
