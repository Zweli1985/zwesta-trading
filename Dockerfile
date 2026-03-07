# Multi-stage build for Zwesta Trading System Production Deployment

# Stage 1: Python backend builder
FROM python:3.11-slim as backend-builder

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY trading_backend_requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r trading_backend_requirements.txt
RUN pip install --no-cache-dir gunicorn

# Copy backend code
COPY multi_broker_backend_updated.py .
COPY wsgi.py .

# Stage 2: Flutter web builder (if building web)
FROM node:18-slim as web-builder

WORKDIR /app

# Copy Flutter web build
COPY build/web ./web

# Stage 3: Production runtime
FROM python:3.11-slim

WORKDIR /app

# Install runtime dependencies  
RUN apt-get update && apt-get install -y \
    curl \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Copy Python dependencies from builder
COPY --from=backend-builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=backend-builder /usr/local/bin /usr/local/bin

# Copy application code
COPY multi_broker_backend_updated.py .
COPY wsgi.py .
COPY *.py .

# Copy web files if available
COPY --from=web-builder /app/web ./web 2>/dev/null || true

# Create non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app

USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:9000/api/health || exit 1

# Expose ports
EXPOSE 9000

# Run Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:9000", "--workers", "4", "--timeout", "120", "--access-logfile", "-", "--error-logfile", "-", "wsgi:app"]
