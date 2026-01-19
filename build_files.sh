
# Vercel precisa saber o que instalar...

echo "BUILD START"
pip install -r requirements.txt
mkdir -p staticfiles # Garante que a pasta sempre vai existir 
python3.12 manage.py collectstatic --noinput --clear
echo "BUILD END"

