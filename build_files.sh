
# Vercel precisa saber o que instalar...

echo "BUILD START"
python3.12 -m pip install -r requirements.txt
mkdir -p staticfiles # Garante que a pasta sempre vai existir 
python3.12 manage.py collectstatic --noinput --clear
echo "------estrutura gerada--------"
find staticfiles -maxdepth 2
ls -al .
echo "BUILD END"

