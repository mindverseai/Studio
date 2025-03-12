#!/bin/bash

# Skript zum Ersetzen aller Vorkommen von 'Dify' durch 'Mindverse' in den Übersetzungsdateien

# Verzeichnis, in dem die Übersetzungsdateien liegen
I18N_DIR="web/i18n"

# Durchsuche alle .ts-Dateien im Übersetzungsverzeichnis
find "$I18N_DIR" -type f -name "*.ts" -exec sed -i '' 's/Dify/Mindverse/g' {} \;

# Ersetze auch die URL in der Installationsformular-Datei
sed -i '' 's|https://docs.dify.ai/user-agreement/open-source|https://mindverse.studio/license|g' web/app/install/installForm.tsx

echo "Ersetzung abgeschlossen. Alle Vorkommen von 'Dify' wurden durch 'Mindverse' ersetzt." 