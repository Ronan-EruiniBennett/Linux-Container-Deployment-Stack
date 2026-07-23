FROM python:3.14-slim-bookworm
WORKDIR /server

COPY requirements.txt .
COPY server.py .

RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "server.py"]