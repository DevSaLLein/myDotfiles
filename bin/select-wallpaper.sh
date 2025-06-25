#!/bin/bash

WALLPAPER_DIR="$HOME/Videos/wallpapers"
THUMBNAIL_DIR="$HOME/.cache/wallpaper-thumbnails"

# Cria diretório de miniaturas se não existir
mkdir -p "$THUMBNAIL_DIR"

# Função para gerar miniatura de um vídeo
generate_thumbnail() {
    local video_file="$1"
    local thumbnail_file="$THUMBNAIL_DIR/$(basename "$video_file" .mp4).jpg"
    
    # Só gera se não existir ou se o vídeo for mais recente
    if [[ ! -f "$thumbnail_file" ]] || [[ "$video_file" -nt "$thumbnail_file" ]]; then
        echo "Gerando miniatura para: $(basename "$video_file")"
        ffmpeg -i "$video_file" -ss 00:00:05 -vframes 1 -vf "scale=640:360" -y "$thumbnail_file" 2>/dev/null
        # Adiciona borda branca
        convert "$thumbnail_file" -bordercolor White -border 8x8 "$thumbnail_file"
    fi
}

# Verifica se o diretório existe
if [[ ! -d "$WALLPAPER_DIR" ]]; then
    echo "Erro: Diretório $WALLPAPER_DIR não encontrado!"
    exit 1
fi

cd "$WALLPAPER_DIR" || exit 1

# Lista arquivos mp4
video_files=(*.mp4)

if [[ ${#video_files[@]} -eq 0 ]] || [[ "${video_files[0]}" == "*.mp4" ]]; then
    echo "Nenhum arquivo .mp4 encontrado em $WALLPAPER_DIR"
    exit 1
fi

# Gera miniaturas para todos os vídeos
echo "Gerando miniaturas..."
for video in "${video_files[@]}"; do
    if [[ -f "$video" ]]; then
        generate_thumbnail "$video"
    fi
done

# Cria lista de vídeos com miniaturas para o rofi
rofi_list=""
for video in "${video_files[@]}"; do
    if [[ -f "$video" ]]; then
        thumbnail="$THUMBNAIL_DIR/$(basename "$video" .mp4).jpg"
        if [[ -f "$thumbnail" ]]; then
            rofi_list+="$video\0icon\x1f$thumbnail\n"
        else
            rofi_list+="$video\n"
        fi
    fi
done

# Mostra menu com miniaturas usando rofi
SELECTED=$(echo -en "$rofi_list" | rofi -dmenu -p "Escolha o wallpaper:" -show-icons -i -theme "$HOME/.config/rofi/wallpaper-icons.rasi")

[ -z "$SELECTED" ] && exit 0

# Verifica se o arquivo selecionado existe
if [[ ! -f "$SELECTED" ]]; then
    echo "Erro: Arquivo $SELECTED não encontrado!"
    exit 1
fi

echo "Aplicando wallpaper: $SELECTED"

# Para qualquer mpvpaper em execução
pkill -f mpvpaper 2>/dev/null

# Aguarda um momento para garantir que o processo anterior foi finalizado
sleep 0.5

# Executa o mpvpaper em todos os monitores, sem áudio e em loop
mpvpaper -o "no-audio --loop" '*' "$WALLPAPER_DIR/$SELECTED" &

echo "Wallpaper aplicado com sucesso!" 