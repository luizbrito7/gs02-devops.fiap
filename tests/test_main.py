from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}


def test_queimadas_lista_tudo():
    r = client.get("/queimadas")
    assert r.status_code == 200
    assert len(r.json()) == 144


def test_queimadas_filtra_bioma():
    r = client.get("/queimadas", params={"bioma": "Pantanal"})
    assert r.status_code == 200
    assert len(r.json()) == 24
    assert all(item["bioma"] == "Pantanal" for item in r.json())
