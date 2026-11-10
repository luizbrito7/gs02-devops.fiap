import json
from pathlib import Path

from fastapi import FastAPI

DADOS = json.loads((Path(__file__).parent / "data" / "bioma_mes.json").read_text(encoding="utf-8"))

app = FastAPI(title="Queimadas API", description="Focos de queimadas por bioma e mês (INPE, 2024-2025)")


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/queimadas")
def queimadas(bioma: str | None = None):
    if bioma is None:
        return DADOS
    return [item for item in DADOS if item["bioma"].lower() == bioma.lower()]
