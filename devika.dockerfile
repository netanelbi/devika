# ──────────────── Base Image ────────────────
FROM python:3.11-bookworm

# ─────────── Create App Directory ────────────
WORKDIR /home/nonroot/devika

# ─────── Install System Dependencies ────────
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      curl \
      git && \
    rm -rf /var/lib/apt/lists/*

# ───────── Install Astral’s uv Tool ─────────
RUN curl -fsSL https://astral.sh/uv/install.sh | sh

# ───────── Create Python venv via uv ─────────
# now that 'uv' is present, this will succeed
RUN /root/.cargo/bin/uv venv

# ─── Update PATH to include both venv & uv ────
ENV PATH="/home/nonroot/devika/.venv/bin:/root/.cargo/bin:${PATH}"

# ─────── Copy Source & Generate Config ───────
COPY . .
# Copy sample → config so we never hit a missing-file error
RUN cp -n sample.config.toml config.toml

# ─────────── Install Python Deps ────────────
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# ─────────── Install Playwright ─────────────
RUN pip install --no-cache-dir playwright && \
    playwright install-deps chromium && \
    playwright install chromium

# ─────────────── Expose & Run ───────────────
EXPOSE 1337
ENTRYPOINT ["python3", "-m", "devika"]
