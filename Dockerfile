# ---- Stage 1: Build React Frontend ----
FROM node:18-alpine AS frontend-builder
WORKDIR /app
# Install frontend dependencies
COPY frontend/package*.json ./
RUN npm install
# Copy all React source files and build the app
COPY frontend/ ./
RUN npm run build

# ---- Stage 2: Build Python Backend ----
FROM python:3.10-slim AS backend
# Prevent Python from writing .pyc files and enable unbuffered logging
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the common working directory
WORKDIR /app

# Install Python dependencies
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the backend source code
COPY backend/ ./backend/

# Copy the React build output from Stage 1 into our backend image
COPY --from=frontend-builder /app/build ./frontend_build

# Set a default environment variable (override as needed with your .env)
ENV GROQ_CLOUD_API_KEY=changeme

# Expose the application port and define the startup command
EXPOSE 8000
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]

