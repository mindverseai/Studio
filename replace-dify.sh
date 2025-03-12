#!/bin/bash

# Skript zum Ersetzen aller Vorkommen von 'Dify' durch 'Mindverse' in den Übersetzungsdateien

# Verzeichnis, in dem die Übersetzungsdateien liegen
I18N_DIR="web/i18n"

# Durchsuche alle .ts-Dateien im Übersetzungsverzeichnis
# Ersetze nur eigenständige Vorkommen von 'Dify' (mit Wortgrenzen)
find "$I18N_DIR" -type f -name "*.ts" -exec sed -i '' 's/\bDify\b/Mindverse/g' {} \;
find "$I18N_DIR" -type f -name "*.ts" -exec sed -i '' 's/\bdify\b/mindverse/g' {} \;

# Ersetze externe Links
find "$I18N_DIR" -type f -name "*.ts" -exec sed -i '' 's|https://docs.dify.ai|https://mindverse.studio/docs|g' {} \;
find "$I18N_DIR" -type f -name "*.ts" -exec sed -i '' 's|https://dify.ai|https://mindverse.studio|g' {} \;

# Ersetze auch die URL in der Installationsformular-Datei
sed -i '' 's|https://docs.dify.ai/user-agreement/open-source|https://mindverse.studio/license|g' web/app/install/installForm.tsx

# Ersetze GitHub-Links
find "web" -type f -name "*.tsx" -exec sed -i '' 's|https://github.com/langgenius/dify|https://github.com/mind-verse/studio|g' {} \;

# Ersetze Discord-Links
find "web" -type f -name "*.tsx" -exec sed -i '' 's|https://discord.gg/FngNHpbcY7|https://mindverse.studio/community|g' {} \;

echo "Ersetzung abgeschlossen. Alle Vorkommen von 'Dify' wurden durch 'Mindverse' ersetzt und externe Links wurden aktualisiert." 