# Queimadas API: GS 2026 DevSecOps (CitizenTech)

API com focos de queimadas por bioma e mês (INPE, 2024-2025), usada como aplicação da pipeline DevSecOps (Jenkins, SonarQube, Trivy, Docker Hub, Docker Compose).

**Participante:** Luiz Brito

## Endpoints

| Método | Rota | Descrição |
|---|---|---|
| GET | `/health` | status da aplicação |
| GET | `/queimadas?bioma=Pantanal` | focos por bioma e mês (filtro opcional) |

## Rodar local

```bash
docker compose up -d --build
curl localhost:8000/health
```

## Testes

```bash
python3 -m venv .venv && .venv/bin/pip install -r requirements-dev.txt
.venv/bin/python -m pytest -q
```
