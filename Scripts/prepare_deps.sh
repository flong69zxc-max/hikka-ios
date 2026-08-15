#!/bin/bash
# Скрипт для подготовки зависимостей ЛОКАЛЬНО (на вашем Mac)

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SITE_PACKAGES="$PROJECT_DIR/HikkaWrapper/HikkaWrapper/Resources/pythonlib/python310/site-packages"
HIKKA_DIR="$SITE_PACKAGES/hikka"

echo "📂 Project directory: $PROJECT_DIR"
echo "📂 Site-packages: $SITE_PACKAGES"

# Создаем директории
mkdir -p "$SITE_PACKAGES"

# Клонируем Hikka если нет
if [ ! -d "$HIKKA_DIR" ]; then
    echo "⬇️ Cloning Hikka repository..."
    git clone https://github.com/hikariatama/hikka.git "$HIKKA_DIR"
else
    echo "✅ Hikka already exists, updating..."
    cd "$HIKKA_DIR"
    git pull
fi

# Устанавливаем зависимости
echo "📦 Installing Python dependencies..."
cd "$HIKKA_DIR"

# Используем Python 3.10
python3.10 -m pip install --upgrade pip
python3.10 -m pip install -r requirements.txt -t "$SITE_PACKAGES" --no-deps

# Устанавливаем зависимости вручную (если requirements.txt не полный)
python3.10 -m pip install telethon yarl aiohttp cryptography pillow -t "$SITE_PACKAGES"

echo "✅ All dependencies prepared!"
echo "📁 Site-packages size: $(du -sh "$SITE_PACKAGES" | cut -f1)"
