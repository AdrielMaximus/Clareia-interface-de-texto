FROM node:22-bookworm-slim AS frontend-build

WORKDIR /app

RUN corepack enable

COPY . .

RUN pnpm install --frozen-lockfile
RUN PORT=3000 BASE_PATH=/ pnpm --filter @workspace/clareia run build


FROM python:3.12-slim AS runtime

ENV PYTHONUNBUFFERED=1 \
    PORT=8080

WORKDIR /app/artifacts/clareia

COPY artifacts/clareia/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY artifacts/clareia/backend ./backend
COPY --from=frontend-build /app/artifacts/clareia/dist/public ./dist/public

EXPOSE 8080

CMD ["sh", "-c", "uvicorn backend.main:app --host 0.0.0.0 --port ${PORT:-8080}"]