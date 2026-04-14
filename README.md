# Boxing Stats Data Warehouse

A containerized PostgreSQL data warehouse designed for boxing statistics. This project demonstrates database orchestration using Docker Compose and the implementation of a dimensional data model (Star Schema) for analytical querying.

## Project Overview
The system automates the creation of a robust data warehouse. Upon initialization, it generates a transactional database (OLTP) simulating raw application data (fighters, events, bouts), and automatically transforms it into an analytical representation (OLAP) containing Fact and Dimension tables.

## Tech Stack & Architecture
* **Database:** PostgreSQL 15
* **Management UI:** pgAdmin 4
* **Infrastructure:** Docker & Docker Compose
* **Data Modeling:** Star Schema (Fact and Dimensions)
* **Automation:** Automated SQL seeding via `docker-entrypoint-initdb.d`

## Getting Started

### Prerequisites
Make sure you have [Docker](https://www.docker.com/) and Docker Compose installed.

### Spin up the infrastructure
1. Clone the repository and navigate to the directory:
   ```bash
   git clone https://github.com/ChadThunderhub/boxing-stats-warehouse.git
   cd boxing-stats-warehouse
   ```

2. Create your environment variables file:
    ```bash
    cp .env.example .env
    ```
    Remember to open the .env file and update the placeholders with your actual values

3. Build and start the container in detached mode:
    ```bash
    docker-compose up -d
    ```

4. Access the data at: 
* **PostgreSQL Database:** `localhost:5432` (Use the `DB_USER`, `DB_PASS`, and `DB_NAME` you set in your `.env` file)
* **pgAdmin Web Interface:** `http://localhost:8080` (Use the `PGADMIN_MAIL` and `PGADMIN_PASS` from your `.env` file)

To stop the application, run:
    ```bash
    docker-compose down
    ```