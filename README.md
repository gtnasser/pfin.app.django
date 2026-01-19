# Personal Finance Control - Django / Supabase / Vercel


Estrutura básica do projeto
```
meu-controle-financeiro/
├── core/
│   ├── settings.py
├── financas/
│   ├── migrations/
│   ├── models.py
│   └── __init__.py
├── manage.py
└── venv/
```


## Para executar o projeto

Clonar o projeto publicado no github, instalar as dependências e configurar a base de dados
```sh
git clone https://github.com/gtnasser/pfin.app.django.git .
cd pfin.app.django
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
```
*** configurar db em homologacao
*** executar


-----


## Desenvolvimento

1. preparar o ambiente
```sh
mkdir pfin
cd pfin
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
python -m venv venv
.\venv\Scripts\activate
git init
```

2. instalar dependencias
*requirements.txt*
```txt
django==6.0.1
dj-database-url==3.1.0
psycopg2-binary==2.9.11
whitenoise==6.11.0
```
```sh
pip install -r requirements.txt
```

3. criar o projeto Django e o app
```sh
django-admin startproject core .
python manage.py startapp financas
```

4. Registrar o App ```financas``` adicionando na lista de INSTALLED_APPS:
*core/settings.py*
```py
INSTALLED_APPS = [
    ...
    'financas',
]
```

5. Banco de dados SQLite

O Python, desde a versão 2.5, já vem com o módulo sqlite3 embutido. Esse módulo é um wrapper da biblioteca SQLite C, que é parte da distribuição oficial do Python. Como o Django usa o backend "django.db.backends.sqlite3", ele aproveita esse módulo nativo do Python, ou seja, já consegue usar SQLite sem instalar mais nada. O arquivo padrão db.sqlite3 é criado automaticamente quando você roda ```python manage.py migrate```.

Para iniciar o banco SQLite e definir um usuário administrador, basta executar os comandos:
```sh
python manage.py makemigrations
python manage.py migrate   
python manage.py createsuperuser
```

O Django já vem com uma implementação do módulo **Admin**, ele fornece uma interface administrativa pronta para gerenciar os dados e modelos da sua aplicação sem precisar criar telas manualmente, economizando tempo de desenvolvimento e oferecendo uma interface segura e extensível.

Para executá-lo, no digitar ```python manage.py runserver``` notreminal e abrir no navegador ```http://127.0.0.1:8000/admin```.


6. Configurar o Django para o mode de Produção

*core/settings.py*
```py
# modo PRODUÇÃO
DEBUG = False
# permitir servidor local
ALLOWED_HOSTS = ['localhost', '127.0.0.1']
```

Para configurar o ponto de entrada da aplicação, adicionar a variável ```app = application``` em *core/wsgi.py*

Executar com ```python manage.py runserver```


7. Arquivos estáticos

Como os arquivos estáticos são distribuídos

7a. Quando DEBUG=True (DESENVOLVIMENTO)
- O ```runserver``` é quem serve os arquivos diretamente das pastas listadas em ```STATICFILES_DIRS``` e também da pasta ```static``` de cada app.
- O ```STATIC_ROOT``` não é usado nesse modo, ele só serve como destino dos arquivos quando executado o comando ```collectstatic```.

7b. Quando DEBUG=False (PRODUÇÃO)
- O ```runserver``` neste modo, por definição, não serve nenhum arquivo estático.
- O ```servidor web ou middleware (ex: whitenoise)``` é quem serve os aquivos somente a partir de ```STATIC_ROOT```.
- Espera-se entáo que o ```collectstatic``` já tenha previamente copiado todos os arquivos de ```STATICFILES_DIRS``` e dos apps para dentro de ```STATIC_ROOT```.

7c. Podemos utilizar o ```whitenoise``` para trabalhar em conjunto com o ```runserver``` e os aquivos estáticos em produção, sem ter que instalar um servidor web tipo Nginx ou Apache.
- instalar o middleware: ```pip install whitenoise```.
- em ```settings.py```: ```STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'```, e em MIDDLEWARE, incluir ```'whitenoise.middleware.WhiteNoiseMiddleware'``` imediatamente após ```'django.middleware.security.SecurityMiddleware'```.
- executar ```python manage.py collectstatic``` para copiar os arquivos estáticos para ```STATIC_ROOT```.


*core/settings.py*
```py
STATIC_URL = '/static/'
# arquivos estáticos do projeto servidos em DESENVOLVIMENTO
STATICFILES_DIRS = [BASE_DIR / 'static_local']
# srquivos estáticos servidos em PRODUÇÃO, previamente copiados aqui pelo collectstatic
STATIC_ROOT = BASE_DIR / 'staticfiles'
# Whitenoise storage para compressão e cache busting
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'
```


