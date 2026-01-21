
#!/bin/bash
# Vercel precisa saber o que instalar...

echo "----- BUILD START -----"

echo "--- ambiente virtual ---"
python3.12 -m venv venv
source venv/bin/activate

echo "--- dependencias ---"
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

echo "--- comandos django ---"
mkdir -p staticfiles # Garante que a pasta sempre vai existir 
python manage.py migrate --noinput
python manage.py collectstatic --noinput --clear

echo "-- estrutura gerada --"
ls -al .
find staticfiles -maxdepth 2

echo "----- BUILD END -----"

