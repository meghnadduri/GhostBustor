# 🎣 GhostBustor

**AI-powered prediction of ghost fishing net accumulation zones — so cleanup crews know where to look before more marine life is harmed.**

> Built as a team project for **TartanHacks 2026** by **Nyshita Chalasani, Kayona Verma, Asha Boyapati, and Meghna Adduri**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Python 3.10+](https://img.shields.io/badge/python-3.10%2B-blue.svg)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/backend-FastAPI-009688.svg)](https://fastapi.tiangolo.com/)
[![scikit-learn](https://img.shields.io/badge/ML-scikit--learn-F7931E.svg)](https://scikit-learn.org/)

---

## The Problem

"Ghost nets" — fishing gear lost or abandoned at sea — drift with ocean currents and continue killing marine life for years, entangling fish, seals, and seabirds long after fishermen lose track of them. Cleanup organizations have limited vessel time and no reliable way to know *where* to look. GhostBustor turns oceanographic and fishing-activity data into a ranked map of likely accumulation zones, so recovery missions can be targeted instead of random.

## What It Does

GhostBustor combines real oceanographic data sources with a trained regression model to predict where abandoned fishing nets are likely to accumulate, then visualizes the results on an interactive map with confidence scores, risk levels, and recommended actions.

- **Predicts accumulation zones** across a region using live ocean conditions, historical sighting density, fishing ground proximity, and known gyre/current convergence patterns
- **Scores every zone** with a 0–100 confidence rating and a risk tier (low → critical), plus a plain-language explanation of *why* the model flagged it
- **Recommends next steps** per zone — from "monitor via satellite" to "deploy vessels within 48 hours"
- **Visualizes everything** on a live, dark-themed Leaflet map with filterable zone cards and a mission-planning detail panel
- **Learns from new reports** — verified sightings can be submitted back through the API to improve future training runs

## Demo

| Interactive map with live risk zones | Zone detail & mission recommendation |
|---|---|
| Dark-themed Leaflet map centered on the California coast, colored by risk level (critical/high/medium/low) with pulsing markers on critical zones | Sidebar cards and a detail panel showing confidence score, predicted net count, and recommended cleanup action per zone |

Run it locally with the quick start below to see it live.

## How It Works

1. **Data ingestion** — pulls live marine weather (wind, waves, sea surface temperature) from the Open-Meteo Marine API, combines it with curated NOAA Fisheries fishing-ground data and known oceanic gyre zones (including the Great Pacific Garbage Patch)
2. **Feature engineering** — for every point on a prediction grid, computes historical sighting density, fishing-ground proximity, current convergence, and gyre proximity
3. **ML prediction** — a `GradientBoostingRegressor` (scikit-learn) trained on historical sighting data scores each location's accumulation likelihood; falls back to a tuned heuristic when the model hasn't been trained yet
4. **Zone synthesis** — nearby high-confidence points are clustered into ranked zones with a risk tier, predicted net count, and recommended action
5. **Serving** — FastAPI exposes predictions over REST; a vanilla JS + Leaflet frontend renders them on a live map

## Tech Stack

| Layer | Technology |
|---|---|
| Backend API | Python, FastAPI, Uvicorn |
| Machine Learning | scikit-learn (Gradient Boosting Regressor), NumPy |
| Database | PostgreSQL + PostGIS, SQLAlchemy, GeoAlchemy2 |
| Frontend | Vanilla JS, Leaflet.js, HTML/CSS |
| Data Sources | Open-Meteo Marine Weather API, NOAA Fisheries, oceanographic gyre research |
| Infra | Docker Compose |

## Project Structure

```
GhostBustor/
├── backend/
│   ├── main.py              # FastAPI app & prediction endpoints
│   ├── ml_model.py          # GhostNetMLModel: training, persistence, inference
│   ├── data_fetchers.py     # Open-Meteo / NOAA / gyre zone data sources
│   ├── database.py          # SQLAlchemy + PostGIS models & queries
│   ├── init_database.py     # Seeds fishing grounds & gyre zones into Postgres
│   ├── requirements.txt
│   ├── env.example          # Copy to .env and configure
│   └── models/               # Trained model artifacts (git-ignored)
├── frontend/
│   ├── index.html           # Map UI shell
│   └── app.js                # Leaflet map, zone rendering, API calls
├── assets/
│   └── ghostbusterslogo.pdf
├── docker-compose.yml        # PostgreSQL + PostGIS
├── start.sh                   # One-command local dev launcher
└── LICENSE
```

## Getting Started

### Prerequisites
- Python 3.10+
- Docker (for PostgreSQL + PostGIS) — optional; the API runs without a database using in-memory sample data

### Quick Start

```bash
git clone https://github.com/<your-org>/GhostBustor.git
cd GhostBustor
./start.sh
```

This installs backend dependencies, starts the FastAPI server on **http://localhost:8000**, and serves the frontend on **http://localhost:8080**.

### Manual Setup (with database)

```bash
# 1. Start PostgreSQL + PostGIS
docker-compose up -d

# 2. Set up the backend
cd backend
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt

# 3. Configure environment
cp env.example .env
# edit .env if your DATABASE_URL differs from the default

# 4. Seed reference data (fishing grounds, gyre zones)
python init_database.py

# 5. Run the API
uvicorn main:app --reload --port 8000
```

Then open **http://localhost:8000/ui** for the map, or **http://localhost:8000/docs** for interactive API docs (Swagger UI).

> The `DATABASE_URL` follows `postgresql://[user]:[password]@[host]:[port]/[database]`. The default in `env.example` matches the Docker Compose setup out of the box — no changes needed for local development.

## API Overview

| Endpoint | Method | Description |
|---|---|---|
| `/predict` | POST | Predict accumulation zones for a custom region |
| `/predict/region` | GET | Quick prediction for a lat/lon bounding box |
| `/zones/active` | GET | Currently active high-confidence zones |
| `/sightings` | GET/POST | List or report historical ghost net sightings |
| `/ocean-conditions` | GET | Live marine weather for a coordinate |
| `/train` | POST | Retrain the ML model on current data |
| `/stats` | GET | Aggregate dashboard statistics |
| `/health` | GET | Service health check |

Full interactive documentation is available at `/docs` once the server is running.

## Known Limitations & Next Steps

Built in a hackathon sprint — a few things we'd tackle with more time:

- **Region coverage** — the ocean/land boundary check and fishing-ground data currently cover the California coast; expanding to global coverage needs a real coastline dataset (e.g. Natural Earth) and broader NOAA/GFW data
- **Persistence** — historical sightings default to an in-memory cache when no database is configured; wiring the API fully to PostGIS would make reports durable
- **Global Fishing Watch integration** — currently stubbed with representative data; a live GFW API key would give real-time vessel activity
- **Auth** — no authentication on write endpoints (`/sightings`, `/train`) yet; needed before any public deployment
- **Testing** — no automated test suite yet; would add pytest coverage for the prediction pipeline and API contracts

## License

MIT — see [LICENSE](LICENSE).
