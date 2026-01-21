# Personal Finance Control - Django / Supabase / Vercel


Vamos criar um projeto para gestão financeira pessoal, utilizando o Django como front-end, hospedado na Vercel, o PostgreSQL como banco de dados, e o Supabase como back-end.

Vamos começar criando a estrutura básica do projeto:
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

*.gitignore*
```
# Virtual Environment
venv/
env/

# config & secrets
.env*
!.env.exemplo

# Django-specific files
*.pot
*.py[cod]
__pycache__/
**/__pycache__/

db.sqlite3

# Pasta de arquivos estáticos gerada pelo collectstatic
staticfiles/

# PyCharm-specific files
.idea/

# Other files
.DS_Store
Thumbs.db
.coverage
.tox/
.eggs/
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

Para executá-lo, no digitar ```python manage.py runserver``` no terminal e abrir no navegador ```http://127.0.0.1:8000/admin```.


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


8. Deploy no Vercel

É necessário fazer alguns ajustes para que o Django possa trabalhar em modo Serverless, para publicá-lo no Vercel. A Vercel não mantém arquivos estáticos (CSS/JS) automaticamente como um servidor comum, então temos que usar um middleware como o ```whitenoise``` para isso.

- Criar arquivo .gitkeep para manter a pasta ```/static_local``` existente, mesmo sem arquivos.

- Forçar a criação da pasta ```/staticfiles``` na execução do script *build_files.sh*.

- Flexibilizar no whitenoise as diretivas de validação do manifesto

- Em ```vercel.json```, na entrada ```@vercel/static-build```, quando você define ```distDir: "staticfiles"```, a Vercel coloca o conteúdo dessa pasta na raiz da CDN dela. O Django coloca os arquivos em ```staticfiles/static/...``` ou a rota está tentando acessar um nível de pasta que não existe mais após o deploy.

- Testar o conteudo da pasta com ```find staticfiles -maxdepth 2```. Se mostrar ```staticfiles/admin``` e ```staticfiles/static_local``` -> ajustar dest para ```"/$1"```. Se mostrar ```staticfiles/static/admin``` -> ajustar dest para ```"/static/$1"```.

*core/settings.py*
```py
# deploy -> vercel
ALLOWED_HOSTS = ALLOWED_HOSTS + ['.vercel.app']
# desativa o modo estrito, evita o travamento se não encontrar algum arquivo específico no manifesto
WHITENOISE_MANIFEST_STRICT = False
```

*vercel.json*
```py
{
  "version": 2,
  "builds": [
    {
      "src": "core/wsgi.py",
      "use": "@vercel/python",
      "config": { "maxLambdaSize": "15mb", "runtime": "python3.12" }
    },
    {
      "src": "build_files.sh",
      "use": "@vercel/static-build",
      "config": { "distDir": "staticfiles" }
    }
  ],
  "routes": [
    {
      "src": "/static/(.*)",
      "dest": "/$1",
      "continue": true
    },
    {
      "src": "/(.*)",
      "dest": "core/wsgi.py"
    }
  ]
}
```

Aqui temos uma configuração extra, um ```continue``` nas configurasções de rota. No Vercel, cada requisição é avaliada contra as rotas, na ordem definida em ```routes```. Normalmente, quando uma rota é atingida, o roteamento para ali e não continua verificando as próximas rotas. Quando definimos ```"continue": true```, estamos passando a instrução: "Depois de aplicar esta rota, continue avaliando as próximas regras.”. No nosso caso específico, sem isso, a regra ```/static``` seria validada e o fluxo seria interromipido sem deixar a instrução chegar ao middleware whitenoise, impedindo que os arquivos estáticos fossem servidos corretamente.

*buildfiles.sh*
```sh
pip install -r requirements.txt
python3.12 manage.py collectstatic --noinput
```

Para publicar, a forma mais fácil é:
- Suba seu código para um repositório no GitHub.
- Acesse o painel da Vercel e conecte seu repositório.
- Importante: Nas configurações de Environment Variables (Variáveis de Ambiente) da Vercel, adicione:
    - PYTHON_VERSION: 3.12

Obs: o SQLite no Vercel é volátil, é recriado a cada sessão, então neste momento o módulo **Admin** nativo do Django só funcionará até a tela de login porque nào existirá nenhum usuário cadastrado. Para efeitos de teste, podemos criar um superusuário em uma linha de comando usando a API do Django. Insira a linha abixo em *build_files.sh* após as migrations:
```bash
python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.filter(username='admin').exists() or User.objects.create_superuser('admin', 'admin@exemplo.com', 'sua_senha_segura')"
```




9. Arquivo de configuração

Seguindo as boas práticas de configuração ([12-Factor App](https://12factor.net/)), vamos criar um arquivo ```.env``` para separar as informações críticas (senhas, tokens e outras credenciais) e as específicas de cada ambiente, e evitar que esses dados fiquem expostos em reservatórios públicos. Certifique-se que existe uma entrada ```.env```no *.gitignore*.

```sh
pip install python-dotenv
```

*.env*
```
DEBUG=True
SECRET_KEY=sua-chave-secreta-aqui
DATABASE_URL=postgres://usuario:senha@host:porta/banco
```

*settings.py*
```py
import os
from pathlib import Path
from dotenv import load_dotenv

# Carrega as variáveis do arquivo .env
load_dotenv()

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = os.getenv('SECRET_KEY')
DEBUG = os.getenv('DEBUG', 'False') == 'True'

# ... resto das configurações ...

```

Lembre-se que no Vercel as variáveis de ambiente devem ser preenchidas no painel **Environment Variables**.
























--------------------------------



## Para executar este projeto

Clonar o projeto publicado no github, instalar as dependências e configurar a base de dados
```sh
git clone https://github.com/gtnasser/pfin.app.django.git .
cd pfin.app.django
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
```
*** configurar db
*** executar

