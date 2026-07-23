FROM python:3.14-slim-bookworm
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

COPY flask-app/requirements.txt .
COPY flask-app/app.py .

RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]