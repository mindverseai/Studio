FROM langgenius/dify-web:1.0.0

# Kopiere das benutzerdefinierte Logo
COPY logo.png /app/web/public/logo/logo.png
COPY favicon.ico /app/web/public/favicon.ico

# Ersetze alle Vorkommen von "Dify" durch "Mindverse" in den Übersetzungsdateien
RUN find /app/web/i18n -type f -name '*.ts' -exec sed -i 's/Dify/Mindverse/g' {} \;

# Ersetze alle Vorkommen von "Dify" durch "Mindverse" in den kompilierten JavaScript-Dateien
RUN find /app/web/.next -type f -name "*.js" -exec sed -i 's/Dify/Mindverse/g' {} \;

# Ersetze alle Vorkommen von "dify" (kleingeschrieben) durch "mindverse" in den kompilierten JavaScript-Dateien
RUN find /app/web/.next -type f -name "*.js" -exec sed -i 's/dify/mindverse/g' {} \;

# Ersetze alle Vorkommen von "DIFY" (großgeschrieben) durch "MINDVERSE" in den kompilierten JavaScript-Dateien
RUN find /app/web/.next -type f -name "*.js" -exec sed -i 's/DIFY/MINDVERSE/g' {} \;

# Ersetze alle Vorkommen von "langGeniusAccount" durch "mindverseAccount" in den Übersetzungsdateien
RUN find /app/web/i18n -type f -name '*.ts' -exec sed -i 's/langGeniusAccount/mindverseAccount/g' {} \;

# Ersetze alle Vorkommen von "LangGenius" durch "Mindverse" in allen Dateien
RUN find /app/web -type f -exec sed -i 's/LangGenius/Mindverse/g' {} \;

# Ersetze alle Vorkommen von "langgenius" durch "mindverse" in allen Dateien
RUN find /app/web -type f -exec sed -i 's/langgenius/mindverse/g' {} \; 