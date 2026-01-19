from django.shortcuts import render

# Create your views here.

from datetime import datetime
from django.http import HttpResponse

def index(request):
    now = datetime.now()
    html = f'''
    <html>
        <link rel="stylesheet" href="/static/style.css">
        <body>
            <h1>Hello from Vercel!</h1>
            <p><span class="colortext">The current time is { now }.</span></p>
        </body>
    </html>
    '''
    return HttpResponse(html)
