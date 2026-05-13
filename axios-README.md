# Script speichern
nano axios-scan.sh

# Ausführbar machen
chmod +x axios-scan.sh

# Als root ausführen (für Systemzugriff)
sudo ./axios-scan.sh

# Oder direkt mit Output in Datei speichern
sudo ./axios-scan.sh | tee axios-report.txt


```bash
# get the repository
git clone https://github.com/Animator617/public-private-repo.git
# go to the directory
cd public-private-repo/
# makc ethe script executable
chmod +x axios-scan.sh 
# and run the script
sudo ./axios-scan.sh 
# then check the dependencys against the curroped one
echo "Check the shown dependecy versions of axios against the version that is compromised is the on under it you are fucked then you need to re doo alllll you lokin tokens and credentials and basically everythin"
```
# Flags:
--show-all sogt dafür das alle gefundenen dateien ezeigt werden und denn auch angezeigt wird wenn da kein axioy gefunden wurde

# Am ende noch mal ausführen das zeigt welche versionen im system gerade isntalliert sind
```bash
# Findet tatsächlich installierte axios Pakete
find / -path "*/node_modules/axios/package.json" 2>/dev/null \
  | xargs grep '"version"' 2>/dev/null \
  | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'| sort -u
```
