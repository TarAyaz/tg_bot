# 🟠 Первый этап: сборщик (builder)
FROM python:3.10.11-slim AS builder

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# Устанавливаем gcc для компиляции C-расширений (если требуются)
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

# Копируем зависимости и собираем .whl-файлы
COPY ./requirements.txt .
RUN pip install --upgrade --no-cache-dir pip && \
    pip wheel --no-cache-dir --no-deps --wheel-dir=/app/wheels -r requirements.txt


# 🟢 Второй этап: финальный образ (минимальный)
FROM python:3.10.11-slim

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# Копируем собранные колёса и requirements.txt из этапа builder
COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .

# Устанавливаем зависимости из .whl-файлов (быстро, без компиляторов)
RUN pip install --no-cache-dir /wheels/*

# Копируем исходный код бота (папка src должна быть в корне проекта)
COPY src ./src

# Указываем Python искать модули в /app/src
ENV PYTHONPATH=/app

# Запускаем бота как модуль Python
CMD ["python", "-m", "src"]