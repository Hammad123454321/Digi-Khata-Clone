# Frontend Integration Guide - DigiKhata Clone Backend

**Version:** 1.0.0  
**Last Updated:** 2024-01-05  
**Target Platform:** Flutter (Android & iOS)

---

## Quick Start Summary

### Base Configuration
- **Base URL:** `http://localhost:8000` (dev) / `https://api.digikhata.com` (prod)
- **API Prefix:** `/api/v1`
- **Authentication:** JWT Bearer tokens
- **Required Headers:** `Authorization`, `X-Business-Id` (for business operations), `X-Device-Id` (for sync)

### Essential Endpoints
1. **Authentication:** `/api/v1/auth/request-otp`, `/api/v1/auth/verify-otp`
2. **Sync:** `/api/v1/sync/pull`, `/api/v1/sync/push`, `/api/v1/sync/status`
3. **Business Operations:** All endpoints require `X-Business-Id` header

### Key Features
- ✅ 58+ API endpoints across 15 modules
- ✅ Multi-tenant architecture (business isolation)
- ✅ Offline-first sync (pull/push with conflict resolution)
- ✅ PDF generation for invoices
- ✅ Real-time balance calculations
- ✅ Multi-device support (3 devices per business default)

---

## Table of Contents

1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Base Configuration](#base-configuration)
4. [Authentication Flow](#authentication-flow)
5. [API Endpoints Reference](#api-endpoints-reference)
6. [Multi-Device Sync Flow](#multi-device-sync-flow)
7. [Error Handling](#error-handling)
8. [Data Models](#data-models)
9. [Integration Best Practices](#integration-best-practices)
10. [Testing & Debugging](#testing--debugging)

---

## Overview

This document provides complete integration guidelines for Flutter developers to integrate with the DigiKhata Clone Backend API. The backend is built with FastAPI and provides a RESTful API for managing business accounting operations.

### Key Features
- **Multi-tenant Architecture**: Each business has isolated data
- **OTP-based Authentication**: SendPK SMS gateway integration
- **Multi-device Support**: Device pairing and offline sync
- **Comprehensive Business Management**: Cash, Stock, Invoices, Customers, Suppliers, Expenses, Staff, Banks
- **Reports & Analytics**: Sales, cash flow, expenses, stock, profit/loss
- **PDF Generation**: Invoice PDFs for WhatsApp sharing

### Base URL
```
Production: https://api.digikhata.com
Development: http://localhost:8000
```

### API Version
All endpoints are prefixed with `/api/v1`

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   UI Layer   │  │  State Mgmt  │  │  Local DB    │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                 │                 │              │
│         └─────────────────┼─────────────────┘              │
│                           │                                 │
│                  ┌────────▼────────┐                        │
│                  │  API Service    │                        │
│                  │  (HTTP Client)  │                        │
│                  └────────┬────────┘                        │
└───────────────────────────┼─────────────────────────────────┘
                            │ HTTPS
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                    FastAPI Backend                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Auth Layer  │  │  API Routes  │  │  Services    │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                 │                 │              │
│         └─────────────────┼─────────────────┘              │
│                           │                                 │
│                  ┌────────▼────────┐                        │
│                  │   Database      │                        │
│                  │  (PostgreSQL)   │                        │
│                  └─────────────────┘                        │
│                           │                                 │
│                  ┌────────▼────────┐                        │
│                  │     Redis       │                        │
│                  │  (Cache/Queue)  │                        │
│                  └─────────────────┘                        │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Action → Flutter App → API Request → Backend Processing
                ↓                              ↓
         Local Storage ← API Response ← Database/Redis
```

---

## Base Configuration

### Required Headers

All authenticated requests must include:

```dart
{
  'Authorization': 'Bearer <access_token>',
  'X-Business-Id': '<business_id>',  // Required for all business operations
  'Content-Type': 'application/json',
  'Accept': 'application/json'
}
```

### Sync Endpoints Headers

Sync endpoints require additional header:

```dart
{
  'Authorization': 'Bearer <access_token>',
  'X-Business-Id': '<business_id>',
  'X-Device-Id': '<device_id>',  // Required for sync operations
  'Content-Type': 'application/json'
}
```

### Flutter HTTP Client Setup

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {
  final String baseUrl;
  String? accessToken;
  int? businessId;
  String? deviceId;

  ApiClient({required this.baseUrl});

  Map<String, String> get headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    
    if (businessId != null) {
      headers['X-Business-Id'] = businessId.toString();
    }
    
    if (deviceId != null) {
      headers['X-Device-Id'] = deviceId!;
    }
    
    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> patch(String endpoint, Map<String, dynamic> body) async {
    return await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }
}
```

---

## Authentication Flow

### Authentication Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    User Authentication Flow                 │
└─────────────────────────────────────────────────────────────┘

Step 1: Request OTP
┌─────────┐
│  User   │
└────┬────┘
     │ Enter Phone Number
     ▼
┌─────────────────────────────────┐
│ POST /api/v1/auth/request-otp   │
│ { "phone": "923001234567" }    │
└────┬────────────────────────────┘
     │
     ▼
┌─────────────────────────────────┐
│ Backend sends OTP via SendPK    │
│ SMS Gateway                     │
└────┬────────────────────────────┘
     │
     ▼
┌─────────────────────────────────┐
│ User receives OTP on phone      │
└────┬────────────────────────────┘
     │
     │ Step 2: Verify OTP
     ▼
┌─────────────────────────────────┐
│ POST /api/v1/auth/verify-otp   │
│ {                               │
│   "phone": "923001234567",      │
│   "otp": "123456",              │
│   "device_id": "device-123",     │
│   "device_name": "Samsung S21"  │
│ }                               │
└────┬────────────────────────────┘
     │
     ▼
┌─────────────────────────────────┐
│ Response:                       │
│ {                               │
│   "access_token": "jwt...",     │
│   "refresh_token": "jwt...",    │
│   "user": {...},                │
│   "businesses": [...],          │
│   "device": {...}                │
│ }                               │
└────┬────────────────────────────┘
     │
     ▼
┌─────────────────────────────────┐
│ Store tokens securely            │
│ Set business context             │
│ Ready to make API calls          │
└─────────────────────────────────┘
```

### 1. Request OTP

**Endpoint:** `POST /api/v1/auth/request-otp`

**Request:**
```json
{
  "phone": "923001234567"
}
```

**Response (200):**
```json
{
  "message": "OTP sent successfully"
}
```

**Flutter Example:**
```dart
Future<void> requestOTP(String phone) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/auth/request-otp'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'phone': phone}),
  );
  
  if (response.statusCode == 200) {
    // OTP sent successfully
  }
}
```

### 2. Verify OTP

**Endpoint:** `POST /api/v1/auth/verify-otp`

**Request:**
```json
{
  "phone": "923001234567",
  "otp": "123456",
  "device_id": "unique-device-id-12345",
  "device_name": "Samsung Galaxy S21"
}
```

**Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": 1,
    "phone": "923001234567",
    "name": "John Doe",
    "email": "john@example.com"
  },
  "businesses": [
    {
      "id": 1,
      "name": "My Shop",
      "phone": "923001234567"
    }
  ],
  "device": {
    "id": 1,
    "device_id": "unique-device-id-12345",
    "device_name": "Samsung Galaxy S21",
    "is_active": true
  }
}
```

**Flutter Example:**
```dart
Future<TokenResponse?> verifyOTP({
  required String phone,
  required String otp,
  required String deviceId,
  String? deviceName,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/auth/verify-otp'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'phone': phone,
      'otp': otp,
      'device_id': deviceId,
      'device_name': deviceName ?? 'Mobile Device',
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // Store tokens securely
    await storage.write('access_token', data['access_token']);
    await storage.write('refresh_token', data['refresh_token']);
    await storage.write('device_id', deviceId);
    
    // Set business context (use first business or let user select)
    if (data['businesses'] != null && data['businesses'].isNotEmpty) {
      await storage.write('business_id', data['businesses'][0]['id']);
    }
    
    return TokenResponse.fromJson(data);
  }
  
  return null;
}
```

### 3. Refresh Token

**Endpoint:** `POST /api/v1/auth/refresh`

**Request:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

**Flutter Example:**
```dart
Future<bool> refreshAccessToken() async {
  final refreshToken = await storage.read('refresh_token');
  if (refreshToken == null) return false;
  
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/auth/refresh'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'refresh_token': refreshToken}),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    await storage.write('access_token', data['access_token']);
    return true;
  }
  
  return false;
}
```

### 4. Set PIN (Optional)

**Endpoint:** `POST /api/v1/auth/set-pin`

**Headers:** `Authorization: Bearer <token>`

**Request:**
```json
{
  "pin": "1234"
}
```

**Response (200):**
```json
{
  "message": "PIN set successfully"
}
```

### 5. Verify PIN (Optional)

**Endpoint:** `POST /api/v1/auth/verify-pin`

**Headers:** `Authorization: Bearer <token>`

**Request:**
```json
{
  "pin": "1234"
}
```

**Response (200):**
```json
{
  "valid": true
}
```

---

## API Endpoints Reference

### Business Management

#### Create Business
**Endpoint:** `POST /api/v1/businesses`  
**Headers:** `Authorization: Bearer <token>`

**Request:**
```json
{
  "name": "My Shop",
  "phone": "923001234567",
  "email": "shop@example.com",
  "address": "123 Main Street",
  "language_preference": "en",
  "max_devices": 3
}
```

**Response (201):**
```json
{
  "id": 1,
  "name": "My Shop",
  "phone": "923001234567",
  "email": "shop@example.com",
  "address": "123 Main Street",
  "is_active": true,
  "language_preference": "en",
  "max_devices": 3,
  "created_at": "2024-01-05T10:00:00Z",
  "updated_at": "2024-01-05T10:00:00Z"
}
```

#### List Businesses
**Endpoint:** `GET /api/v1/businesses`  
**Headers:** `Authorization: Bearer <token>`

**Response (200):**
```json
[
  {
    "id": 1,
    "name": "My Shop",
    "phone": "923001234567",
    "is_active": true
  }
]
```

#### Get Business
**Endpoint:** `GET /api/v1/businesses/{business_id}`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

#### Update Business
**Endpoint:** `PATCH /api/v1/businesses/{business_id}`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Request:**
```json
{
  "name": "Updated Shop Name",
  "language_preference": "ur"
}
```

---

### Cash Management

#### Create Cash Transaction
**Endpoint:** `POST /api/v1/cash/transactions`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Request:**
```json
{
  "transaction_type": "cash_in",
  "amount": "1000.00",
  "date": "2024-01-05T10:00:00Z",
  "source": "Sales",
  "remarks": "Daily sales collection"
}
```

**Response (201):**
```json
{
  "id": 1,
  "transaction_type": "cash_in",
  "amount": "1000.00",
  "date": "2024-01-05T10:00:00Z",
  "source": "Sales",
  "remarks": "Daily sales collection",
  "created_at": "2024-01-05T10:00:00Z"
}
```

#### List Cash Transactions
**Endpoint:** `GET /api/v1/cash/transactions?start_date=2024-01-01&end_date=2024-01-31&limit=100&offset=0`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Response (200):**
```json
[
  {
    "id": 1,
    "transaction_type": "cash_in",
    "amount": "1000.00",
    "date": "2024-01-05T10:00:00Z",
    "source": "Sales",
    "remarks": "Daily sales collection",
    "created_at": "2024-01-05T10:00:00Z"
  }
]
```

#### Get Daily Balance
**Endpoint:** `GET /api/v1/cash/balance/{date}`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Example:** `GET /api/v1/cash/balance/2024-01-05`

**Response (200):**
```json
{
  "date": "2024-01-05T00:00:00Z",
  "opening_balance": "5000.00",
  "total_cash_in": "1000.00",
  "total_cash_out": "500.00",
  "closing_balance": "5500.00"
}
```

#### Get Cash Summary
**Endpoint:** `POST /api/v1/cash/summary`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Request:**
```json
{
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-01-31T23:59:59Z"
}
```

**Response (200):**
```json
{
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-01-31T23:59:59Z",
  "opening_balance": "5000.00",
  "total_cash_in": "50000.00",
  "total_cash_out": "30000.00",
  "closing_balance": "25000.00",
  "transactions": [...]
}
```

---

### Stock Management

#### Create Item
**Endpoint:** `POST /api/v1/stock/items`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Request:**
```json
{
  "name": "Product A",
  "sku": "PROD-A-001",
  "barcode": "1234567890123",
  "purchase_price": "100.00",
  "sale_price": "150.00",
  "unit": "pcs",
  "opening_stock": "100.000",
  "min_stock_threshold": "10.000",
  "description": "Product description"
}
```

**Response (201):**
```json
{
  "id": 1,
  "name": "Product A",
  "sku": "PROD-A-001",
  "barcode": "1234567890123",
  "purchase_price": "100.00",
  "sale_price": "150.00",
  "unit": "pcs",
  "opening_stock": "100.000",
  "current_stock": "100.000",
  "min_stock_threshold": "10.000",
  "is_active": true,
  "description": "Product description"
}
```

#### List Items
**Endpoint:** `GET /api/v1/stock/items?is_active=true&search=product&limit=100&offset=0`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

#### Create Inventory Transaction
**Endpoint:** `POST /api/v1/stock/transactions`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Request:**
```json
{
  "item_id": 1,
  "transaction_type": "stock_in",
  "quantity": "50.000",
  "unit_price": "100.00",
  "date": "2024-01-05T10:00:00Z",
  "remarks": "New stock received"
}
```

**Transaction Types:** `stock_in`, `stock_out`, `wastage`, `adjustment`

#### Get Low Stock Alerts
**Endpoint:** `GET /api/v1/stock/alerts`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Response (200):**
```json
[
  {
    "id": 1,
    "item_id": 1,
    "item_name": "Product A",
    "current_stock": "5.000",
    "threshold": "10.000",
    "is_resolved": false,
    "created_at": "2024-01-05T10:00:00Z"
  }
]
```

---

### Invoice Management

#### Create Invoice
**Endpoint:** `POST /api/v1/invoices`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Request:**
```json
{
  "customer_id": 1,
  "invoice_type": "cash",
  "date": "2024-01-05T10:00:00Z",
  "items": [
    {
      "item_id": 1,
      "item_name": "Product A",
      "quantity": "2.000",
      "unit_price": "150.00"
    }
  ],
  "tax_amount": "30.00",
  "discount_amount": "10.00",
  "remarks": "Customer invoice"
}
```

**Response (201):**
```json
{
  "id": 1,
  "invoice_number": "INV-1-000001",
  "customer_id": 1,
  "invoice_type": "cash",
  "date": "2024-01-05T10:00:00Z",
  "subtotal": "300.00",
  "tax_amount": "30.00",
  "discount_amount": "10.00",
  "total_amount": "320.00",
  "paid_amount": "320.00",
  "remarks": "Customer invoice",
  "pdf_path": "invoices/1/INV-1-000001.pdf",
  "items": [
    {
      "id": 1,
      "item_id": 1,
      "item_name": "Product A",
      "quantity": "2.000",
      "unit_price": "150.00",
      "total_price": "300.00"
    }
  ],
  "created_at": "2024-01-05T10:00:00Z"
}
```

#### List Invoices
**Endpoint:** `GET /api/v1/invoices?start_date=2024-01-01&end_date=2024-01-31&customer_id=1&invoice_type=cash&limit=100&offset=0`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

#### Get Invoice PDF
**Endpoint:** `GET /api/v1/invoices/{invoice_id}/pdf`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Response:** PDF file (binary)

**Flutter Example:**
```dart
Future<Uint8List?> downloadInvoicePDF(int invoiceId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/v1/invoices/$invoiceId/pdf'),
    headers: headers,
  );
  
  if (response.statusCode == 200) {
    return response.bodyBytes;
  }
  
  return null;
}
```

---

### Customer Management

#### Create Customer
**Endpoint:** `POST /api/v1/customers`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Request:**
```json
{
  "name": "Customer Name",
  "phone": "923001234568",
  "email": "customer@example.com",
  "address": "Customer Address"
}
```

**Response (201):**
```json
{
  "id": 1,
  "name": "Customer Name",
  "phone": "923001234568",
  "email": "customer@example.com",
  "address": "Customer Address",
  "is_active": true,
  "balance": "0.00"
}
```

#### Record Customer Payment
**Endpoint:** `POST /api/v1/customers/{customer_id}/payments`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Request:**
```json
{
  "amount": "500.00",
  "date": "2024-01-05T10:00:00Z",
  "remarks": "Payment received"
}
```

#### Get Customer Transactions
**Endpoint:** `GET /api/v1/customers/{customer_id}/transactions`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

---

### Supplier Management

#### Create Supplier
**Endpoint:** `POST /api/v1/suppliers`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Request:**
```json
{
  "name": "Supplier Name",
  "phone": "923001234569",
  "email": "supplier@example.com",
  "address": "Supplier Address"
}
```

#### Record Supplier Payment
**Endpoint:** `POST /api/v1/suppliers/{supplier_id}/payments`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Request:**
```json
{
  "amount": "1000.00",
  "date": "2024-01-05T10:00:00Z",
  "remarks": "Payment made"
}
```

---

### Expense Management

#### Create Expense Category
**Endpoint:** `POST /api/v1/expenses/categories`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Request:**
```json
{
  "name": "Rent",
  "description": "Monthly rent"
}
```

#### Create Expense
**Endpoint:** `POST /api/v1/expenses`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Request:**
```json
{
  "category_id": 1,
  "amount": "5000.00",
  "date": "2024-01-05T10:00:00Z",
  "payment_mode": "cash",
  "description": "Monthly rent payment"
}
```

**Payment Modes:** `cash`, `bank`

---

### Staff Management

#### Create Staff
**Endpoint:** `POST /api/v1/staff`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Request:**
```json
{
  "name": "Staff Name",
  "phone": "923001234570",
  "email": "staff@example.com",
  "role": "employee",
  "address": "Staff Address"
}
```

#### Record Salary
**Endpoint:** `POST /api/v1/staff/{staff_id}/salaries`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Request:**
```json
{
  "amount": "15000.00",
  "date": "2024-01-05T10:00:00Z",
  "remarks": "January salary"
}
```

---

### Bank Management

#### Create Bank Account
**Endpoint:** `POST /api/v1/banks/accounts`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Request:**
```json
{
  "bank_name": "ABC Bank",
  "account_number": "1234567890",
  "account_type": "current",
  "opening_balance": "10000.00"
}
```

#### Create Bank Transaction
**Endpoint:** `POST /api/v1/banks/transactions`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Request:**
```json
{
  "account_id": 1,
  "transaction_type": "deposit",
  "amount": "5000.00",
  "date": "2024-01-05T10:00:00Z",
  "remarks": "Deposit"
}
```

**Transaction Types:** `deposit`, `withdrawal`, `transfer`

#### Cash-Bank Transfer
**Endpoint:** `POST /api/v1/banks/transfers`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Request:**
```json
{
  "account_id": 1,
  "transfer_type": "cash_to_bank",
  "amount": "5000.00",
  "date": "2024-01-05T10:00:00Z",
  "remarks": "Transfer to bank"
}
```

**Transfer Types:** `cash_to_bank`, `bank_to_cash`

---

### Reports

#### Sales Report
**Endpoint:** `GET /api/v1/reports/sales?start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Response (200):**
```json
{
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-01-31T23:59:59Z",
  "total_sales": "100000.00",
  "cash_sales": "60000.00",
  "credit_sales": "40000.00",
  "total_profit": "30000.00",
  "invoice_count": 150
}
```

#### Cash Flow Report
**Endpoint:** `GET /api/v1/reports/cash-flow?start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

#### Expense Report
**Endpoint:** `GET /api/v1/reports/expenses?start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

#### Stock Report
**Endpoint:** `GET /api/v1/reports/stock`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

#### Profit & Loss Report
**Endpoint:** `GET /api/v1/reports/profit-loss?start_date=2024-01-01T00:00:00Z&end_date=2024-01-31T23:59:59Z`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

---

### Reminders

#### List Reminders
**Endpoint:** `GET /api/v1/reminders?entity_type=customer&is_resolved=false`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Response (200):**
```json
[
  {
    "id": 1,
    "entity_type": "customer",
    "entity_id": 1,
    "entity_name": "Customer Name",
    "amount": "5000.00",
    "due_date": "2024-01-10T00:00:00Z",
    "is_resolved": false,
    "created_at": "2024-01-05T10:00:00Z"
  }
]
```

#### Resolve Reminder
**Endpoint:** `POST /api/v1/reminders/{reminder_id}/resolve`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

---

### Backups

#### Create Backup
**Endpoint:** `POST /api/v1/backups`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Response (201):**
```json
{
  "id": 1,
  "backup_type": "manual",
  "file_path": "backups/1/backup_20240105.json",
  "status": "completed",
  "backup_date": "2024-01-05T10:00:00Z"
}
```

#### List Backups
**Endpoint:** `GET /api/v1/backups`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

#### Restore Backup
**Endpoint:** `POST /api/v1/backups/{backup_id}/restore`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

---

## Multi-Device Sync Flow

### Sync Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Device A (Online)                        │
│  ┌──────────────┐                                           │
│  │  Local DB    │──┐                                        │
│  │  (SQLite)    │  │                                        │
│  └──────────────┘  │                                        │
│                    │ 1. User makes changes                  │
│                    │    (creates/updates/deletes)           │
│                    ▼                                        │
│            ┌───────────────┐                                │
│            │  Sync Service │                                │
│            │  (Queue)      │                                │
│            └───────┬───────┘                                │
│                    │ 2. Push Changes                        │
└────────────────────┼────────────────────────────────────────┘
                     │
                     │ POST /api/v1/sync/push
                     │ Headers: X-Device-Id, X-Business-Id
                     │
┌────────────────────▼────────────────────────────────────────┐
│                    Backend Server                            │
│  ┌──────────────────────────────────────┐                   │
│  │     Sync Change Log Table             │                   │
│  │  - Tracks all entity changes          │                   │
│  │  - Timestamp-based versioning          │                   │
│  │  - Device isolation                   │                   │
│  └──────────────────────────────────────┘                   │
│                    │                                         │
│                    │ Stores changes with:                   │
│                    │ - entity_type, entity_id                │
│                    │ - action (create/update/delete)        │
│                    │ - data snapshot                        │
│                    │ - sync_timestamp                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ POST /api/v1/sync/pull
                     │ Query: cursor, entity_types, limit
                     │
┌────────────────────▼────────────────────────────────────────┐
│                    Device B (Offline → Online)              │
│            ┌───────────────┐                                │
│            │  Sync Service │                                │
│            │  (Pull)       │                                │
│            └───────┬───────┘                                │
│                    │ 3. Receive Changes                     │
│                    │    (since last cursor)                 │
│                    ▼                                        │
│  ┌──────────────┐                                           │
│  │  Local DB    │◄──┐                                       │
│  │  (SQLite)    │   │                                        │
│  └──────────────┘   │                                        │
│                     │ 4. Apply Changes                      │
│                     │    - Create new entities              │
│                     │    - Update existing                  │
│                     │    - Delete removed                   │
│                     │                                       │
│                     │ 5. Handle Conflicts                    │
│                     │    (if server version newer)          │
│                     │                                       │
│                     │ 6. Update Sync Cursor                  │
└─────────────────────┴───────────────────────────────────────┘
```

### Sync Flow Diagram

```
┌─────────────┐
│ App Start   │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ Check Sync      │ GET /api/v1/sync/status
│ Status          │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Pull Changes    │ POST /api/v1/sync/pull
│ from Server    │ (with cursor)
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Apply Changes   │ Update local DB
│ to Local DB    │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Push Local      │ POST /api/v1/sync/push
│ Changes         │ (queued offline changes)
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Handle          │ Resolve conflicts
│ Conflicts       │ (if any)
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Update Cursor   │ Store next_cursor
└─────────────────┘
```

### 1. Pull Changes

**Endpoint:** `POST /api/v1/sync/pull`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`, `X-Device-Id: <device_id>`

**Request:**
```json
{
  "cursor": "2024-01-05T10:00:00Z",
  "entity_types": ["cash_transaction", "item", "invoice"],
  "limit": 100
}
```

**Response (200):**
```json
{
  "changes": [
    {
      "entity_type": "cash_transaction",
      "entity_id": 1,
      "action": "create",
      "data": {
        "id": 1,
        "transaction_type": "cash_in",
        "amount": "1000.00",
        "date": "2024-01-05T10:00:00Z"
      },
      "sync_timestamp": "2024-01-05T10:05:00Z",
      "change_id": 1
    }
  ],
  "next_cursor": "2024-01-05T10:05:00Z",
  "has_more": false,
  "total_count": 1
}
```

**Flutter Example:**
```dart
Future<SyncPullResponse> pullChanges({
  String? cursor,
  List<String>? entityTypes,
  int limit = 100,
}) async {
  final response = await apiClient.post(
    '/api/v1/sync/pull',
    {
      if (cursor != null) 'cursor': cursor,
      if (entityTypes != null) 'entity_types': entityTypes,
      'limit': limit,
    },
  );
  
  return SyncPullResponse.fromJson(jsonDecode(response.body));
}
```

### 2. Push Changes

**Endpoint:** `POST /api/v1/sync/push`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`, `X-Device-Id: <device_id>`

**Request:**
```json
{
  "changes": [
    {
      "entity_type": "cash_transaction",
      "entity_id": 100,
      "action": "create",
      "data": {
        "transaction_type": "cash_in",
        "amount": "500.00",
        "date": "2024-01-05T11:00:00Z"
      },
      "updated_at": "2024-01-05T11:00:00Z"
    }
  ]
}
```

**Response (200):**
```json
{
  "accepted": [1, 2],
  "conflicts": [],
  "rejected": [],
  "next_cursor": "2024-01-05T11:05:00Z"
}
```

**Flutter Example:**
```dart
Future<SyncPushResponse> pushChanges(List<SyncChange> changes) async {
  final response = await apiClient.post(
    '/api/v1/sync/push',
    {
      'changes': changes.map((c) => c.toJson()).toList(),
    },
  );
  
  final data = jsonDecode(response.body);
  
  // Handle conflicts
  if (data['conflicts'] != null && data['conflicts'].isNotEmpty) {
    await handleConflicts(data['conflicts']);
  }
  
  // Handle rejected
  if (data['rejected'] != null && data['rejected'].isNotEmpty) {
    await handleRejected(data['rejected']);
  }
  
  return SyncPushResponse.fromJson(data);
}
```

### 3. Get Sync Status

**Endpoint:** `GET /api/v1/sync/status`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`, `X-Device-Id: <device_id>`

**Response (200):**
```json
{
  "last_sync_at": "2024-01-05T10:00:00Z",
  "sync_cursor": "2024-01-05T10:00:00Z",
  "pending_changes_count": 5,
  "device_id": "unique-device-id-12345",
  "is_active": true
}
```

---

### Device Management

#### Generate Pairing Token
**Endpoint:** `GET /api/v1/devices/pairing-token`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Response (200):**
```json
{
  "pairing_token": "abc123xyz789",
  "expires_at": "2024-01-05T10:10:00Z"
}
```

**Use Case:** Generate QR code with pairing_token for device pairing

#### Pair Device
**Endpoint:** `POST /api/v1/devices/pair`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

**Request:**
```json
{
  "device_id": "unique-device-id-12345",
  "device_name": "Samsung Galaxy S21",
  "device_type": "android",
  "pairing_token": "abc123xyz789"
}
```

**Response (201):**
```json
{
  "id": 1,
  "device_id": "unique-device-id-12345",
  "device_name": "Samsung Galaxy S21",
  "device_type": "android",
  "is_active": true,
  "last_sync_at": null,
  "created_at": "2024-01-05T10:00:00Z"
}
```

#### List Devices
**Endpoint:** `GET /api/v1/devices`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

#### Revoke Device
**Endpoint:** `POST /api/v1/devices/{device_id}/revoke`  
**Headers:** `Authorization: Bearer <token>`, `X-Business-Id: <business_id>`

---

## Error Handling

### Error Response Format

All errors follow this structure:

```json
{
  "detail": "Error message",
  "details": {
    "field": "additional error details"
  }
}
```

### HTTP Status Codes

- **200 OK**: Request successful
- **201 Created**: Resource created successfully
- **400 Bad Request**: Invalid request data
- **401 Unauthorized**: Authentication required or invalid token
- **403 Forbidden**: Access denied (authorization error)
- **404 Not Found**: Resource not found
- **409 Conflict**: Resource conflict (e.g., duplicate)
- **422 Unprocessable Entity**: Validation error
- **429 Too Many Requests**: Rate limit exceeded
- **500 Internal Server Error**: Server error

### Error Types

#### AuthenticationError (401)
```json
{
  "detail": "Invalid or expired token"
}
```

**Handling:** Refresh token or redirect to login

#### AuthorizationError (403)
```json
{
  "detail": "User does not have access to this business"
}
```

**Handling:** Show error message, allow business selection

#### NotFoundError (404)
```json
{
  "detail": "Resource not found"
}
```

**Handling:** Show "Not found" message

#### ValidationError (422)
```json
{
  "detail": "Validation error",
  "details": {
    "amount": "Amount must be greater than 0"
  }
}
```

**Handling:** Display field-specific validation errors

#### BusinessLogicError (400)
```json
{
  "detail": "Maximum device limit (3) reached"
}
```

**Handling:** Show business logic error message

#### RateLimitError (429)
```json
{
  "detail": "Rate limit exceeded",
  "details": {
    "retry_after": 60
  }
}
```

**Handling:** Show rate limit message, retry after specified seconds

### Flutter Error Handling Example

```dart
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? details;

  ApiException(this.statusCode, this.message, [this.details]);

  factory ApiException.fromResponse(http.Response response) {
    final data = jsonDecode(response.body);
    return ApiException(
      response.statusCode,
      data['detail'] ?? 'Unknown error',
      data['details'],
    );
  }
}

Future<T> handleApiCall<T>(Future<http.Response> Function() call) async {
  try {
    final response = await call();
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as T;
    } else if (response.statusCode == 401) {
      // Try to refresh token
      if (await refreshAccessToken()) {
        // Retry the call
        return await call().then((r) => jsonDecode(r.body) as T);
      } else {
        // Redirect to login
        throw AuthenticationException('Please login again');
      }
    } else {
      throw ApiException.fromResponse(response);
    }
  } on http.ClientException {
    throw NetworkException('Network error. Please check your connection.');
  }
}
```

---

## Data Models

### Common Fields

All entities include:
- `id`: Integer (primary key)
- `created_at`: DateTime (ISO 8601 format)
- `updated_at`: DateTime (ISO 8601 format)

### Entity Types for Sync

When using sync endpoints, use these entity type strings:

- `cash_transaction`
- `item`
- `invoice`
- `customer`
- `supplier`
- `expense`
- `expense_category`
- `staff`
- `bank_account`
- `bank_transaction`
- `customer_transaction`
- `supplier_transaction`
- `inventory_transaction`

### Flutter Model Example

```dart
class CashTransaction {
  final int id;
  final String transactionType; // "cash_in" or "cash_out"
  final double amount;
  final DateTime date;
  final String? source;
  final String? remarks;
  final DateTime createdAt;

  CashTransaction({
    required this.id,
    required this.transactionType,
    required this.amount,
    required this.date,
    this.source,
    this.remarks,
    required this.createdAt,
  });

  factory CashTransaction.fromJson(Map<String, dynamic> json) {
    return CashTransaction(
      id: json['id'],
      transactionType: json['transaction_type'],
      amount: double.parse(json['amount'].toString()),
      date: DateTime.parse(json['date']),
      source: json['source'],
      remarks: json['remarks'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_type': transactionType,
      'amount': amount.toStringAsFixed(2),
      'date': date.toIso8601String(),
      'source': source,
      'remarks': remarks,
    };
  }
}
```

---

## Integration Best Practices

### 1. Token Management

- Store tokens securely using `flutter_secure_storage`
- Implement automatic token refresh before expiry
- Handle token expiration gracefully

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  final _storage = FlutterSecureStorage();
  
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }
  
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }
  
  Future<bool> refreshTokenIfNeeded() async {
    // Check token expiry and refresh if needed
    // Implementation depends on JWT parsing
  }
}
```

### 2. Offline-First Architecture

- Store all data locally (SQLite/Hive)
- Queue API calls when offline
- Sync when connection is restored

```dart
class OfflineQueue {
  final List<QueuedRequest> _queue = [];
  
  Future<void> queueRequest(QueuedRequest request) async {
    _queue.add(request);
    await _saveQueue();
    
    // Try to process if online
    if (await isOnline()) {
      await processQueue();
    }
  }
  
  Future<void> processQueue() async {
    while (_queue.isNotEmpty) {
      final request = _queue.removeAt(0);
      try {
        await _executeRequest(request);
      } catch (e) {
        // Re-queue if failed
        _queue.insert(0, request);
        break;
      }
    }
  }
}
```

### 3. Sync Strategy

- Pull changes on app start
- Push local changes periodically
- Handle conflicts with user intervention if needed
- Store sync cursor for incremental sync

```dart
class SyncManager {
  Future<void> performSync() async {
    // 1. Pull changes
    final pullResponse = await pullChanges(cursor: lastSyncCursor);
    
    // 2. Apply changes to local DB
    for (final change in pullResponse.changes) {
      await applyChangeToLocalDB(change);
    }
    
    // 3. Push local changes
    final localChanges = await getLocalChangesSince(lastSyncCursor);
    if (localChanges.isNotEmpty) {
      final pushResponse = await pushChanges(localChanges);
      
      // Handle conflicts
      if (pushResponse.conflicts.isNotEmpty) {
        await handleConflicts(pushResponse.conflicts);
      }
    }
    
    // 4. Update cursor
    lastSyncCursor = pullResponse.nextCursor ?? pushResponse.nextCursor;
    await saveSyncCursor(lastSyncCursor);
  }
}
```

### 4. Business Context Management

- Store selected business ID
- Include `X-Business-Id` header in all requests
- Allow switching between businesses

### 5. Device ID Management

- Generate unique device ID on first app launch
- Store device ID securely
- Include `X-Device-Id` header for sync operations

```dart
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getOrCreateDeviceId() async {
  final prefs = await SharedPreferences.getInstance();
  String? deviceId = prefs.getString('device_id');
  
  if (deviceId == null) {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;
    } else {
      deviceId = Uuid().v4();
    }
    
    await prefs.setString('device_id', deviceId);
  }
  
  return deviceId;
}
```

### 6. Error Recovery

- Implement retry logic for network failures
- Show user-friendly error messages
- Log errors for debugging

### 7. Rate Limiting

- Respect rate limits (60 requests/minute default)
- Implement exponential backoff for retries
- Show appropriate messages to users

---

## Testing & Debugging

### API Testing

Use the OpenAPI documentation:
- **Swagger UI:** `http://localhost:8000/docs`
- **ReDoc:** `http://localhost:8000/redoc`
- **OpenAPI JSON:** `http://localhost:8000/openapi.json`

### Common Issues

1. **401 Unauthorized**
   - Check if token is included in headers
   - Verify token hasn't expired
   - Try refreshing token

2. **400 Bad Request - X-Business-Id header required**
   - Ensure `X-Business-Id` header is included
   - Verify business ID is valid

3. **404 Not Found**
   - Check endpoint URL
   - Verify resource ID exists
   - Ensure business context is correct

4. **Sync Conflicts**
   - Implement conflict resolution UI
   - Allow user to choose which version to keep
   - Or implement automatic resolution (last-write-wins)

### Debugging Tips

1. Enable API logging in Flutter:
```dart
class ApiClient {
  bool debugMode = true;
  
  Future<http.Response> get(String endpoint) async {
    if (debugMode) {
      print('GET $endpoint');
      print('Headers: $headers');
    }
    
    final response = await http.get(...);
    
    if (debugMode) {
      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');
    }
    
    return response;
  }
}
```

2. Use Postman/Insomnia for API testing
3. Check backend logs for server-side errors
4. Verify network connectivity
5. Test with different business contexts

---

## Complete Endpoint Reference

### Authentication Endpoints

| Method | Endpoint | Auth Required | Headers |
|--------|----------|---------------|---------|
| POST | `/api/v1/auth/request-otp` | No | - |
| POST | `/api/v1/auth/verify-otp` | No | - |
| POST | `/api/v1/auth/refresh` | No | - |
| POST | `/api/v1/auth/set-pin` | Yes | `Authorization` |
| POST | `/api/v1/auth/verify-pin` | Yes | `Authorization` |

### Business Endpoints

| Method | Endpoint | Auth Required | Headers |
|--------|----------|---------------|---------|
| POST | `/api/v1/businesses` | Yes | `Authorization` |
| GET | `/api/v1/businesses` | Yes | `Authorization` |
| GET | `/api/v1/businesses/{id}` | Yes | `Authorization`, `X-Business-Id` |
| PATCH | `/api/v1/businesses/{id}` | Yes | `Authorization`, `X-Business-Id` |

### Cash Management Endpoints

| Method | Endpoint | Auth Required | Headers |
|--------|----------|---------------|---------|
| POST | `/api/v1/cash/transactions` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/cash/transactions` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/cash/balance/{date}` | Yes | `Authorization`, `X-Business-Id` |
| POST | `/api/v1/cash/summary` | Yes | `Authorization`, `X-Business-Id` |

### Stock Management Endpoints

| Method | Endpoint | Auth Required | Headers |
|--------|----------|---------------|---------|
| POST | `/api/v1/stock/items` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/stock/items` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/stock/items/{id}` | Yes | `Authorization`, `X-Business-Id` |
| PATCH | `/api/v1/stock/items/{id}` | Yes | `Authorization`, `X-Business-Id` |
| POST | `/api/v1/stock/transactions` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/stock/alerts` | Yes | `Authorization`, `X-Business-Id` |
| POST | `/api/v1/stock/alerts/{id}/resolve` | Yes | `Authorization`, `X-Business-Id` |

### Invoice Endpoints

| Method | Endpoint | Auth Required | Headers |
|--------|----------|---------------|---------|
| POST | `/api/v1/invoices` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/invoices` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/invoices/{id}` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/invoices/{id}/pdf` | Yes | `Authorization`, `X-Business-Id` |

### Customer Endpoints

| Method | Endpoint | Auth Required | Headers |
|--------|----------|---------------|---------|
| POST | `/api/v1/customers` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/customers` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/customers/{id}` | Yes | `Authorization`, `X-Business-Id` |
| POST | `/api/v1/customers/{id}/payments` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/customers/{id}/transactions` | Yes | `Authorization`, `X-Business-Id` |

### Supplier Endpoints

| Method | Endpoint | Auth Required | Headers |
|--------|----------|---------------|---------|
| POST | `/api/v1/suppliers` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/suppliers` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/suppliers/{id}` | Yes | `Authorization`, `X-Business-Id` |
| POST | `/api/v1/suppliers/{id}/payments` | Yes | `Authorization`, `X-Business-Id` |

### Expense Endpoints

| Method | Endpoint | Auth Required | Headers |
|--------|----------|---------------|---------|
| POST | `/api/v1/expenses/categories` | Yes | `Authorization`, `X-Business-Id` |
| POST | `/api/v1/expenses` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/expenses` | Yes | `Authorization`, `X-Business-Id` |
| POST | `/api/v1/expenses/summary` | Yes | `Authorization`, `X-Business-Id` |

### Staff Endpoints

| Method | Endpoint | Auth Required | Headers |
|--------|----------|---------------|---------|
| POST | `/api/v1/staff` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/staff` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/staff/{id}` | Yes | `Authorization`, `X-Business-Id` |
| POST | `/api/v1/staff/{id}/salaries` | Yes | `Authorization`, `X-Business-Id` |

### Bank Endpoints

| Method | Endpoint | Auth Required | Headers |
|--------|----------|---------------|---------|
| POST | `/api/v1/banks/accounts` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/banks/accounts` | Yes | `Authorization`, `X-Business-Id` |
| POST | `/api/v1/banks/transactions` | Yes | `Authorization`, `X-Business-Id` |
| POST | `/api/v1/banks/transfers` | Yes | `Authorization`, `X-Business-Id` |

### Device Endpoints

| Method | Endpoint | Auth Required | Headers |
|--------|----------|---------------|---------|
| GET | `/api/v1/devices/pairing-token` | Yes | `Authorization`, `X-Business-Id` |
| POST | `/api/v1/devices/pair` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/devices` | Yes | `Authorization`, `X-Business-Id` |
| POST | `/api/v1/devices/{id}/revoke` | Yes | `Authorization`, `X-Business-Id` |

### Sync Endpoints

| Method | Endpoint | Auth Required | Headers |
|--------|----------|---------------|---------|
| POST | `/api/v1/sync/pull` | Yes | `Authorization`, `X-Business-Id`, `X-Device-Id` |
| POST | `/api/v1/sync/push` | Yes | `Authorization`, `X-Business-Id`, `X-Device-Id` |
| GET | `/api/v1/sync/status` | Yes | `Authorization`, `X-Business-Id`, `X-Device-Id` |

### Reports Endpoints

| Method | Endpoint | Auth Required | Headers |
|--------|----------|---------------|---------|
| GET | `/api/v1/reports/sales` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/reports/cash-flow` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/reports/expenses` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/reports/stock` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/reports/profit-loss` | Yes | `Authorization`, `X-Business-Id` |

### Reminder Endpoints

| Method | Endpoint | Auth Required | Headers |
|--------|----------|---------------|---------|
| GET | `/api/v1/reminders` | Yes | `Authorization`, `X-Business-Id` |
| POST | `/api/v1/reminders/{id}/resolve` | Yes | `Authorization`, `X-Business-Id` |

### Backup Endpoints

| Method | Endpoint | Auth Required | Headers |
|--------|----------|---------------|---------|
| POST | `/api/v1/backups` | Yes | `Authorization`, `X-Business-Id` |
| GET | `/api/v1/backups` | Yes | `Authorization`, `X-Business-Id` |
| POST | `/api/v1/backups/{id}/restore` | Yes | `Authorization`, `X-Business-Id` |

---

## Request/Response Payloads - Complete Reference

### Expense Category

**Create Category Request:**
```json
{
  "name": "Rent",
  "description": "Monthly rent payment"
}
```

**Response:**
```json
{
  "id": 1,
  "name": "Rent",
  "description": "Monthly rent payment",
  "is_active": true
}
```

### Expense

**Create Expense Request:**
```json
{
  "category_id": 1,
  "amount": "5000.00",
  "date": "2024-01-05T10:00:00Z",
  "payment_mode": "cash",
  "description": "Monthly rent"
}
```

**Get Expense Summary Request:**
```json
{
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-01-31T23:59:59Z"
}
```

**Response:**
```json
{
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-01-31T23:59:59Z",
  "total_expenses": "50000.00",
  "by_category": [
    {
      "category_id": 1,
      "category_name": "Rent",
      "total": "15000.00"
    }
  ],
  "by_payment_mode": {
    "cash": "30000.00",
    "bank": "20000.00"
  }
}
```

### Staff

**Create Staff Request:**
```json
{
  "name": "John Doe",
  "phone": "923001234570",
  "email": "john@example.com",
  "role": "employee",
  "address": "Staff Address"
}
```

**Record Salary Request:**
```json
{
  "amount": "15000.00",
  "date": "2024-01-05T10:00:00Z",
  "payment_mode": "cash",
  "remarks": "January salary"
}
```

### Bank Account

**Create Bank Account Request:**
```json
{
  "bank_name": "ABC Bank",
  "account_number": "1234567890",
  "account_holder_name": "My Shop",
  "branch": "Main Branch",
  "ifsc_code": "ABC1234567",
  "opening_balance": "10000.00"
}
```

**Response:**
```json
{
  "id": 1,
  "bank_name": "ABC Bank",
  "account_number": "1234567890",
  "account_holder_name": "My Shop",
  "branch": "Main Branch",
  "ifsc_code": "ABC1234567",
  "opening_balance": "10000.00",
  "current_balance": "10000.00",
  "is_active": true
}
```

### Bank Transaction

**Create Bank Transaction Request:**
```json
{
  "bank_account_id": 1,
  "transaction_type": "deposit",
  "amount": "5000.00",
  "date": "2024-01-05T10:00:00Z",
  "reference_number": "TXN123456",
  "remarks": "Deposit"
}
```

**Cash-Bank Transfer Request:**
```json
{
  "transfer_type": "cash_to_bank",
  "amount": "5000.00",
  "date": "2024-01-05T10:00:00Z",
  "bank_account_id": 1,
  "remarks": "Transfer to bank"
}
```

### Reports Response Examples

**Sales Report Response:**
```json
{
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-01-31T23:59:59Z",
  "total_sales": "100000.00",
  "cash_sales": "60000.00",
  "credit_sales": "40000.00",
  "total_profit": "30000.00",
  "invoice_count": 150,
  "paid_amount": "95000.00",
  "pending_amount": "5000.00"
}
```

**Cash Flow Report Response:**
```json
{
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-01-31T23:59:59Z",
  "opening_balance": "5000.00",
  "total_cash_in": "100000.00",
  "total_cash_out": "80000.00",
  "closing_balance": "25000.00",
  "daily_breakdown": [
    {
      "date": "2024-01-01",
      "cash_in": "5000.00",
      "cash_out": "2000.00",
      "balance": "8000.00"
    }
  ]
}
```

**Stock Report Response:**
```json
{
  "total_items": 50,
  "total_stock_value": "500000.00",
  "low_stock_items": 5,
  "out_of_stock_items": 2,
  "items": [
    {
      "id": 1,
      "name": "Product A",
      "current_stock": "100.000",
      "stock_value": "10000.00",
      "is_low_stock": false
    }
  ]
}
```

**Profit & Loss Report Response:**
```json
{
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-01-31T23:59:59Z",
  "total_revenue": "100000.00",
  "total_expenses": "50000.00",
  "gross_profit": "50000.00",
  "net_profit": "30000.00",
  "expense_breakdown": {
    "rent": "15000.00",
    "salary": "20000.00",
    "other": "15000.00"
  }
}
```

---

## Additional Resources

### API Documentation
- Swagger UI: Available at `/docs` endpoint
- OpenAPI Schema: Available at `/openapi.json`

### Support
- Backend Repository: [Your repo URL]
- API Base URL: Configure in app settings
- Environment: Development/Staging/Production

---

## Quick Reference

### Essential Headers
```
Authorization: Bearer <token>
X-Business-Id: <business_id>
X-Device-Id: <device_id>  (for sync endpoints)
Content-Type: application/json
```

### Base URL
```
Development: http://localhost:8000
Production: https://api.digikhata.com
```

### Key Endpoints
- Auth: `/api/v1/auth/*`
- Sync: `/api/v1/sync/*`
- Business: `/api/v1/businesses/*`
- Cash: `/api/v1/cash/*`
- Stock: `/api/v1/stock/*`
- Invoices: `/api/v1/invoices/*`
- Customers: `/api/v1/customers/*`
- Reports: `/api/v1/reports/*`

---

**End of Integration Guide**

For questions or clarifications, refer to the OpenAPI documentation at `/docs` or contact the backend development team.

