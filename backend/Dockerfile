FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y gcc libssl-dev \
    && apt-get purge -y gcc libssl-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY . .

RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "run.py"]
