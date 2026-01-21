
#!/bin/bash
# Vercel precisa saber o que instalar...

echo "# -- BUILD START"

echo "# ---- ambiente virtual"
python3.12 -m venv venv
source venv/bin/activate

echo "# ---- dependencias"
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

echo "# --- comandos django"
mkdir -p staticfiles # Garante que a pasta sempre vai existir 
python -c "from django.conf import settings; print('ENGINE:', settings.DATABASES['default']['ENGINE'])"
python manage.py migrate --noinput
python manage.py collectstatic --noinput --clear
python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.filter(username='admin').exists() or User.objects.create_superuser('admin', 'admin@admin.com', 'admin')"


echo "# --- estrutura gerada"
ls -al .
find staticfiles -maxdepth 2

echo "# -- BUILD END"

