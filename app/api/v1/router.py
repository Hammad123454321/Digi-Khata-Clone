"""Main API router."""
from fastapi import APIRouter

from app.api.v1 import auth, business, cash, stock, invoice, customer, supplier, expense, staff, bank, device, reports, reminder, backup, sync

api_router = APIRouter()

api_router.include_router(auth.router)
api_router.include_router(business.router)
api_router.include_router(cash.router)
api_router.include_router(stock.router)
api_router.include_router(invoice.router)
api_router.include_router(customer.router)
api_router.include_router(supplier.router)
api_router.include_router(expense.router)
api_router.include_router(staff.router)
api_router.include_router(bank.router)
api_router.include_router(device.router)
api_router.include_router(reports.router)
api_router.include_router(reminder.router)
api_router.include_router(backup.router)
api_router.include_router(sync.router)

