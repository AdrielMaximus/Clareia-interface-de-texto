FROM node:20-alpine AS frontend-build
WORKDIR /app/artifacts/clareia

COPY artifacts/clareia/package*.json ./
RUN npm ci

COPY artifacts/clareia/ ./
RUN npm run build

FROM python:3.12-slim AS runtime
WORKDIR /app/artifacts/clareia

COPY artifacts/clareia/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY artifacts/clareia/ ./
COPY --from=frontend-build /app/artifacts/clareia/dist/ ./dist/

EXPOSE 8000
CMD ["python", "-m", "uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]