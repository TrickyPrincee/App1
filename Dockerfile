FROM python:3.13.3-slim as base

ENV PYTHONUNBUFFERED 1
ENV DJANGO_SETTINGS_MODULE=hello_world.settings

RUN apt-get update && apt-get install -y \
    libpq-dev \
    build-essential \
    nginx \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy and install dependencies first (for better caching)
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn

# Copy application code
COPY . /app/

# Copy Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Run migrations and collectstatic at container startup, not build time
CMD sh -c "python manage.py migrate --noinput && \
           python manage.py collectstatic --noinput && \
           gunicorn --bind 127.0.0.1:8000 hello_world.wsgi:application & \
           nginx -g 'daemon off;'"