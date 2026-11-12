FROM cgr.dev/chainguard/python:latest-dev AS build
WORKDIR /app
RUN python -m venv --without-pip /app/venv
COPY requirements.txt .
RUN pip --python /app/venv/bin/python install --no-cache-dir -r requirements.txt

FROM cgr.dev/chainguard/python:latest
LABEL org.opencontainers.image.source=https://github.com/luizbrito7/gs02-devops.fiap
WORKDIR /app
ENV PATH="/app/venv/bin:$PATH"
COPY --from=build /app/venv /app/venv
COPY app/ app/
EXPOSE 8000
ENTRYPOINT ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
