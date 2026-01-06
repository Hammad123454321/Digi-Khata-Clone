# DigiKhata Clone - Backend API

Production-ready FastAPI backend for a digital khata (accounting) application for small and medium businesses.

## Features

- **Multi-tenant Architecture**: Support for multiple businesses with data isolation
- **OTP Authentication**: SendPK SMS gateway integration for secure login
- **Cash Management**: Track cash in/out, daily balances, and summaries
- **Stock Management**: Items, inventory transactions, low-stock alerts
- **Invoicing**: Create invoices with items, tax, discounts, cash/credit sales
- **Customer & Supplier Management**: Ledger-style tracking with balances
- **Expense Management**: Categories, entries, payment modes
- **Staff Management**: Profiles and salary tracking
- **Bank Management**: Accounts, transactions, cash-bank transfers
- **Multi-Device Support**: QR code pairing, device management, sync
- **Reports & Analytics**: Sales, cash flow, expenses, stock, profit/loss
- **Reminders**: Credit payment reminders for customers/suppliers
- **Backup & Restore**: Cloud backup functionality
- **Audit Logging**: Track critical actions
- **Rate Limiting**: API rate limiting with Redis
- **Structured Logging**: JSON logging with structured logs
- **Metrics**: Prometheus metrics endpoint

## Tech Stack

- **Framework**: FastAPI
- **Database**: PostgreSQL (async with SQLAlchemy)
- **Cache/Queue**: Redis
- **Object Storage**: S3-compatible (for backups and PDFs)
- **SMS Gateway**: SendPK (sendpk.com)
- **PDF Generation**: ReportLab/WeasyPrint
- **Authentication**: JWT tokens (access + refresh)
- **Monitoring**: Prometheus metrics, structured logging

## Project Structure

```
.
├── app/
│   ├── api/              # API endpoints
│   │   ├── v1/           # API v1 routes
│   │   └── dependencies.py
│   ├── core/             # Core functionality
│   │   ├── config.py     # Configuration
│   │   ├── database.py   # Database setup
│   │   ├── security.py   # Auth & encryption
│   │   └── ...
│   ├── models/           # SQLAlchemy models
│   ├── schemas/          # Pydantic schemas
│   ├── services/         # Business logic
│   └── main.py           # FastAPI app
├── alembic/              # Database migrations
├── tests/                # Test suite
├── requirements.txt      # Python dependencies
├── .env.example         # Environment variables template
└── README.md
```

## Setup

### Prerequisites

- Python 3.11+
- Docker and Docker Compose (for database and Redis)
- SendPK API account

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Digi-Khata-Clone
```

2. Start PostgreSQL and Redis using Docker:
```bash
docker-compose up -d
```

This will start:
- PostgreSQL database container named `digi-khata-db` on port 5434 (mapped from container port 5432)
- Redis container named `digi-khata-redis` on port 6379

3. Create virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

4. Install dependencies:
```bash
pip install -r requirements.txt
```

5. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

The default database connection string for Docker setup:
```
DATABASE_URL=postgresql+asyncpg://digikhata:digikhata_password@localhost:5434/digikhata
REDIS_URL=redis://localhost:6379/0
```

6. Run database migrations:
```bash
alembic upgrade head
```

7. Start the server:
```bash
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`

API documentation: `http://localhost:8000/docs`

### Docker Commands

Start services:
```bash
docker-compose up -d
```

Stop services:
```bash
docker-compose down
```

View logs:
```bash
docker-compose logs -f digi-khata-db
docker-compose logs -f digi-khata-redis
```

Stop and remove volumes (⚠️ deletes all data):
```bash
docker-compose down -v
```

## Environment Variables

See `.env.example` for all required environment variables. Key variables:

- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection string
- `SENDPK_API_KEY`: SendPK SMS gateway API key
- `SENDPK_SENDER_ID`: SendPK sender ID
- `SECRET_KEY`: JWT secret key (min 32 characters)
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`: S3 credentials for backups

## API Endpoints

### Authentication
- `POST /api/v1/auth/request-otp` - Request OTP
- `POST /api/v1/auth/verify-otp` - Verify OTP and get tokens
- `POST /api/v1/auth/refresh` - Refresh access token
- `POST /api/v1/auth/set-pin` - Set PIN
- `POST /api/v1/auth/verify-pin` - Verify PIN

### Business
- `POST /api/v1/businesses` - Create business
- `GET /api/v1/businesses` - List businesses
- `GET /api/v1/businesses/{id}` - Get business
- `PATCH /api/v1/businesses/{id}` - Update business

### Cash Management
- `POST /api/v1/cash/transactions` - Create transaction
- `GET /api/v1/cash/transactions` - List transactions
- `GET /api/v1/cash/balance/{date}` - Get daily balance
- `POST /api/v1/cash/summary` - Get summary

### Stock Management
- `POST /api/v1/stock/items` - Create item
- `GET /api/v1/stock/items` - List items
- `POST /api/v1/stock/transactions` - Create inventory transaction
- `GET /api/v1/stock/alerts` - List low stock alerts

### Invoices
- `POST /api/v1/invoices` - Create invoice
- `GET /api/v1/invoices` - List invoices
- `GET /api/v1/invoices/{id}` - Get invoice

### Customers
- `POST /api/v1/customers` - Create customer
- `GET /api/v1/customers` - List customers
- `POST /api/v1/customers/{id}/payments` - Record payment

### Suppliers
- `POST /api/v1/suppliers` - Create supplier
- `GET /api/v1/suppliers` - List suppliers
- `POST /api/v1/suppliers/{id}/payments` - Record payment

### Expenses
- `POST /api/v1/expenses/categories` - Create category
- `POST /api/v1/expenses` - Create expense
- `GET /api/v1/expenses` - List expenses

### Staff
- `POST /api/v1/staff` - Create staff
- `GET /api/v1/staff` - List staff
- `POST /api/v1/staff/{id}/salaries` - Record salary

### Banks
- `POST /api/v1/banks/accounts` - Create account
- `POST /api/v1/banks/transactions` - Create transaction
- `POST /api/v1/banks/transfers` - Cash-bank transfer

### Devices
- `GET /api/v1/devices/pairing-token` - Generate pairing token
- `POST /api/v1/devices/pair` - Pair device
- `GET /api/v1/devices` - List devices
- `POST /api/v1/devices/{id}/revoke` - Revoke device

### Reports
- `GET /api/v1/reports/sales` - Sales report
- `GET /api/v1/reports/cash-flow` - Cash flow report
- `GET /api/v1/reports/expenses` - Expense report
- `GET /api/v1/reports/stock` - Stock report
- `GET /api/v1/reports/profit-loss` - Profit & loss

### Reminders
- `GET /api/v1/reminders` - List reminders
- `POST /api/v1/reminders/{id}/resolve` - Resolve reminder

### Backups
- `POST /api/v1/backups` - Create backup
- `GET /api/v1/backups` - List backups
- `POST /api/v1/backups/{id}/restore` - Restore backup

## Authentication

All endpoints (except auth endpoints) require authentication:

1. Request OTP: `POST /api/v1/auth/request-otp` with phone number
2. Verify OTP: `POST /api/v1/auth/verify-otp` with phone, OTP, and optional device_id
3. Use access token: Include `Authorization: Bearer <token>` header
4. Include business context: Include `X-Business-Id: <business_id>` header

## Testing

Run tests:
```bash
pytest
```

With coverage:
```bash
pytest --cov=app --cov-report=html
```

## Database Migrations

Create a new migration:
```bash
alembic revision --autogenerate -m "Description"
```

Apply migrations:
```bash
alembic upgrade head
```

## Deployment

### Production Checklist

- [ ] Set `ENVIRONMENT=production`
- [ ] Set `DEBUG=false`
- [ ] Configure strong `SECRET_KEY`
- [ ] Set up PostgreSQL with proper credentials
- [ ] Configure Redis
- [ ] Set up S3/object storage
- [ ] Configure SendPK API credentials
- [ ] Set up Nginx reverse proxy
- [ ] Configure TLS/SSL certificates
- [ ] Set up monitoring and logging
- [ ] Configure backups
- [ ] Set up CI/CD pipeline

### Docker (Optional)

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## License

[Your License Here]

## Support

For issues and questions, please contact [your contact information]

