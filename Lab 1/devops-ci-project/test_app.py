import pytest
from app import app

@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client

def test_home_status_code(client):
    """Test if home endpoint returns HTTP 200 OK"""
    response = client.get("/")
    assert response.status_code == 200

def test_home_json_content(client):
    """Test if home endpoint returns expected JSON payload"""
    response = client.get("/")
    data = response.get_json()
    assert data["status"] == "success"
    assert "Anurag Pandey" in data["developer"]

def test_health_check(client):
    """Test if health check endpoint returns status healthy"""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "healthy"
