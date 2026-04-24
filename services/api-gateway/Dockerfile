# =============================================
# API Gateway Dockerfile
# Author: Surya
# =============================================

# Use small Python base image — industry best practice
FROM python:3.11-slim

# Set working directory inside container
WORKDIR /app

# Copy requirements first (for Docker layer caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Expose port 5000
EXPOSE 5000

# Run as non-root user (security best practice!)
RUN useradd --create-home appuser
USER appuser

# Start the Flask app
CMD ["python", "app.py"]