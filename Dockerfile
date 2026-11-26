# ---------- Zing It: Django music playlist app ----------
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    DJANGO_DEBUG=False \
    DJANGO_ALLOWED_HOSTS=* \
    PORT=8000

WORKDIR /app

# Install dependencies first so Docker can cache this layer
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the project
COPY . .

# Collect static files (served by WhiteNoise) and run the test suite at build time
RUN python manage.py collectstatic --noinput \
    && python manage.py test

# Run as a non-root user
RUN useradd --create-home zing && chown -R zing:zing /app
USER zing

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import os, urllib.request; urllib.request.urlopen(f'http://127.0.0.1:{os.environ.get(\"PORT\", \"8000\")}/')" || exit 1

CMD ["sh", "-c", "gunicorn django_project.wsgi:application --bind 0.0.0.0:${PORT} --workers 2 --access-logfile -"]
