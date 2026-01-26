# Backend Deployment Guide

This guide covers deploying the DigiKhata backend to a fresh VPS.

## Prerequisites

- Fresh Ubuntu/Debian VPS
- Root or sudo access
- Domain name: `qazitraders.com` (configured to point to your VPS IP)

## Step 0: DNS Configuration

Before starting, ensure your domain DNS is configured:

1. Point `qazitraders.com` A record to your VPS IP address
2. Point `www.qazitraders.com` A record to your VPS IP address (or use CNAME)

You can verify DNS propagation:
```bash
dig qazitraders.com
nslookup qazitraders.com
```

## Step 1: Configure MongoDB Atlas

Since you're using MongoDB Atlas (cloud), configure network access:

1. Go to [MongoDB Atlas Dashboard](https://cloud.mongodb.com/)
2. Navigate to **Network Access**
3. Click **Add IP Address**
4. Add your VPS IP address (or use `0.0.0.0/0` temporarily for testing - **not recommended for production**)
5. Save the changes

**Important**: For production, whitelist only your VPS IP address for better security.

## Step 2: Initial VPS Setup

### Update system
```bash
sudo apt update && sudo apt upgrade -y
```

### Install Docker and Docker Compose
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout and login again for docker group to take effect
```

### Install Git
```bash
sudo apt install git -y
```

### Install Nginx
```bash
sudo apt install nginx -y
```

### Configure MongoDB Atlas Network Access

Since you're using MongoDB Atlas (cloud), you need to whitelist your VPS IP:

1. Go to MongoDB Atlas Dashboard
2. Navigate to **Network Access**
3. Click **Add IP Address**
4. Add your VPS IP address (or use `0.0.0.0/0` for all IPs - less secure)
5. Save the changes

## Step 3: Clone Repository

```bash
# Create app directory
sudo mkdir -p /var/www/digikhata
sudo chown $USER:$USER /var/www/digikhata

# Clone repository
cd /var/www/digikhata
git clone <your-repo-url> .

# Or if you already have the repo, just pull
git pull
```

## Step 4: Configure Environment

```bash
cd /var/www/digikhata

# Create .env file
nano .env
```

Add the following variables:

```env
# Environment
ENVIRONMENT=production
DEBUG=False

# Application
APP_NAME=DigiKhata Backend
SECRET_KEY=your-secret-key-min-32-chars-change-this-in-production

# Database (MongoDB Atlas Cloud)
MONGODB_URL=mongodb+srv://hammad:Mlm098)(*@chatbot.s5n6iw2.mongodb.net/?retryWrites=true&w=majority&appName=Test-DB
MONGODB_DATABASE=DIGI-KHATA

# Redis
REDIS_URL=redis://redis:6379/0

# SendPK SMS (if using)
SENDPK_API_KEY=your-api-key
SENDPK_SENDER_ID=your-sender-id

# S3 Storage (if using)
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=us-east-1
S3_BUCKET_NAME=your-bucket-name

# Encryption
ENCRYPTION_KEY=your-base64-encoded-32-byte-key
ENCRYPTION_ENABLED=True

# Sentry (optional)
SENTRY_DSN=your-sentry-dsn
SENTRY_ENVIRONMENT=production

# CORS (update with your frontend domain)
CORS_ORIGINS=["https://qazitraders.com","https://www.qazitraders.com"]
```

**Important**: Generate a secure SECRET_KEY:
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

## Step 5: Configure Nginx

```bash
# Copy nginx configuration
sudo cp nginx.conf /etc/nginx/sites-available/digikhata
sudo ln -s /etc/nginx/sites-available/digikhata /etc/nginx/sites-enabled/

# Remove default site (optional)
sudo rm /etc/nginx/sites-enabled/default

# Test nginx configuration
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx
```

### For Production with SSL

Install Certbot for SSL (required for production):
```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d qazitraders.com -d www.qazitraders.com
```

This will:
- Automatically obtain SSL certificates from Let's Encrypt
- Configure HTTPS redirect
- Update nginx configuration with SSL settings
- Set up auto-renewal

**Note**: Make sure DNS is properly configured before running Certbot, otherwise it will fail.

## Step 6: Build and Start Services

```bash
cd /var/www/digikhata

# Build and start containers
docker compose build
docker compose up -d

# Wait a few seconds for services to start
sleep 5

# Check logs
docker compose logs -f backend

# Verify services are running
docker compose ps
```

## Step 7: Configure GitHub Actions

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add the following secrets:
   - `VPS_HOST`: Your VPS IP address or domain (e.g., `123.45.67.89` or `qazitraders.com`)
   - `VPS_USER`: SSH username (usually `root` or your user)
   - `VPS_PASSWORD`: SSH password
   - `VPS_PORT`: SSH port (optional, default: `22`)
   - `VPS_APP_PATH`: Path to your app (optional, default: `/var/www/digikhata`)

**Note**: After pushing to `main` or `master` branch, the workflow will automatically deploy.

## Step 8: Verify Deployment

```bash
# Check if containers are running
docker compose ps

# Check backend logs
docker compose logs backend

# Test API endpoint (direct)
curl http://localhost:8000/health

# Test API endpoint (via nginx)
curl http://localhost/health

# Test API endpoint (from external IP or domain)
curl http://qazitraders.com/health
curl https://qazitraders.com/health
```

## Useful Commands

### View logs
```bash
docker compose logs -f backend
docker compose logs -f mongodb
docker compose logs -f redis
```

### Restart services
```bash
docker compose restart backend
docker compose restart
```

### Stop services
```bash
docker compose down
```

### Update and redeploy
```bash
cd /var/www/digikhata
git pull
docker compose build
docker compose up -d
```

### Backup MongoDB (MongoDB Atlas)
Since you're using MongoDB Atlas, you have two options:

**Option 1: Use MongoDB Atlas built-in backups** (Recommended)
- Go to MongoDB Atlas Dashboard → Clusters → Backup
- Configure automated backups (available in M10+ clusters)

**Option 2: Manual backup using mongodump**
```bash
# Install MongoDB Database Tools on your local machine or VPS
# Ubuntu/Debian:
wget https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian11-x86_64-100.9.4.deb
sudo dpkg -i mongodb-database-tools-debian11-x86_64-100.9.4.deb

# Then backup from Atlas
mongodump --uri="mongodb+srv://hammad:Mlm098)(*@chatbot.s5n6iw2.mongodb.net/?retryWrites=true&w=majority&appName=Test-DB" --out=./backup
```

### Restore MongoDB (MongoDB Atlas)
```bash
mongorestore --uri="mongodb+srv://hammad:Mlm098)(*@chatbot.s5n6iw2.mongodb.net/?retryWrites=true&w=majority&appName=Test-DB" ./backup
```

## Troubleshooting

### Backend not starting
```bash
# Check logs
docker compose logs backend

# Check environment variables
docker compose exec backend env | grep MONGODB
```

### MongoDB connection issues
```bash
# Test MongoDB connection from backend container
docker compose exec backend python3 -c "from motor.motor_asyncio import AsyncIOMotorClient; import asyncio; client = AsyncIOMotorClient('mongodb+srv://hammad:Mlm098)(*@chatbot.s5n6iw2.mongodb.net/?retryWrites=true&w=majority&appName=Test-DB'); asyncio.run(client.admin.command('ping'))"

# Check MongoDB URL and environment variables
docker compose exec backend env | grep MONGODB

# Check backend logs for MongoDB connection errors
docker compose logs backend | grep -i mongo
```

**Note**: Since you're using MongoDB Atlas (cloud), ensure:
- Your VPS IP is whitelisted in MongoDB Atlas Network Access (go to Atlas Dashboard → Network Access)
- MongoDB credentials in `.env` file are correct
- Database name (`MONGODB_DATABASE`) is set to `DIGI-KHATA` or matches your Atlas database
- Connection string format is correct (mongodb+srv://...)

### Nginx not proxying
```bash
# Check nginx error logs
sudo tail -f /var/log/nginx/error.log

# Test nginx configuration
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx
```

### Port already in use
```bash
# Check what's using port 8000
sudo lsof -i :8000

# Or change port in docker-compose.yml
```

## Security Notes

1. **Change default passwords**: Update all default credentials
2. **Firewall**: Configure UFW to allow only necessary ports
   ```bash
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```
3. **SSL**: SSL is configured via Certbot (Step 4). Certificates auto-renew every 90 days.
4. **Secrets**: Never commit `.env` file to git
5. **Backups**: Set up regular MongoDB backups

## Monitoring

### Check container status
```bash
docker compose ps
```

### Check resource usage
```bash
docker stats
```

### Check disk space
```bash
df -h
docker system df
```

