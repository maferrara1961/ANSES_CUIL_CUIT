FROM mcr.microsoft.com/playwright/python:v1.40.0-jammy

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install browsers
RUN playwright install chromium
RUN playwright install-deps chromium

COPY app /app

EXPOSE 5000

CMD ["python", "main.py"]
