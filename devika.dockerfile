# ─────────────── Base Image ────────────────
FROM python:3.11-bookworm

# ───────── Create nonroot User ──────────────
RUN groupadd -r nonroot \
 && useradd -r -g nonroot -d /home/nonroot/devika -s /bin/bash nonroot

WORKDIR /home/nonroot/devika

# ───── Install System Dependencies ──────────
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential \
      curl \
      git \
      python3-venv \
      python3-pip \
      libnss3 \
      libatk1.0-0 \
      libatk-bridge2.0-0 \
      libcups2 \
      libdrm2 \
      libxkbcommon0 \
      libxcomposite1 \
      libxrandr2 \
      libgbm1 \
      libasound2 \
      libpangocairo-1.0-0 \
      libpango-1.0-0 \
      libgtk-3-0 \
      libxshmfence1 \
      libxcb1 \
 && rm -rf /var/lib/apt/lists/*

# ─────────── Create & Activate venv ─────────
RUN python3 -m venv .venv
ENV PATH="/home/nonroot/devika/.venv/bin:${PATH}"

# ─────────── Copy & Prepare Config ──────────
COPY sample.config.toml .
RUN cp -n sample.config.toml config.toml

# ────────── Copy App & Install Deps ─────────
COPY requirements.txt .
RUN pip install --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt

# ──────────── Install Playwright ────────────
RUN pip install --no-cache-dir playwright \
 && playwright install-deps chromium \
 && playwright install chromium

# ─────────── Copy App Code ──────────────────
COPY src ./src
COPY devika.py .

# ────────── Fix Permissions & Switch ────────
RUN chown -R nonroot:nonroot /home/nonroot/devika
USER nonroot

# ───────────── Expose & Entrypoint ──────────
EXPOSE 1337
ENTRYPOINT ["python3", "-m", "devika"]
