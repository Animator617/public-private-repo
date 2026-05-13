# Script speichern
nano axios-scan.sh

# Ausführbar machen
chmod +x axios-scan.sh

# Als root ausführen (für Systemzugriff)
sudo ./axios-scan.sh

# Oder direkt mit Output in Datei speichern
sudo ./axios-scan.sh | tee axios-report.txt
