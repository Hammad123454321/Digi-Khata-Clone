"""Bank endpoints."""
from typing import List, Optional
from fastapi import APIRouter, Depends, Query

from app.api.dependencies import get_current_user, get_current_business
from app.models.user import User
from app.models.business import Business
from app.models.bank import BankAccount
from app.schemas.bank import (
    BankAccountCreate,
    BankAccountResponse,
    BankTransactionCreate,
    CashBankTransferCreate,
)
from app.services.bank import bank_service

router = APIRouter(prefix="/banks", tags=["Banks"])


@router.post("/accounts", response_model=BankAccountResponse, status_code=201)
async def create_account(
    data: BankAccountCreate,
    current_business: Business = Depends(get_current_business),
):
    """Create a bank account."""
    account = await bank_service.create_account(
        business_id=str(current_business.id),
        bank_name=data.bank_name,
        account_number=data.account_number,
        account_holder_name=data.account_holder_name,
        branch=data.branch,
        ifsc_code=data.ifsc_code,
        opening_balance=data.opening_balance,
    )
    return account


@router.get("/accounts", response_model=List[BankAccountResponse])
async def list_accounts(
    is_active: Optional[bool] = Query(None),
    current_business: Business = Depends(get_current_business),
):
    """List bank accounts."""
    query = BankAccount.find(BankAccount.business_id == current_business.id)
    if is_active is not None:
        query = query.find(BankAccount.is_active == is_active)

    accounts = await query.to_list()
    return accounts


@router.post("/transactions", status_code=201)
async def create_transaction(
    data: BankTransactionCreate,
    current_business: Business = Depends(get_current_business),
    current_user: User = Depends(get_current_user),
):
    """Create a bank transaction."""
    transaction = await bank_service.create_transaction(
        business_id=str(current_business.id),
        bank_account_id=str(data.bank_account_id),
        transaction_type=data.transaction_type,
        amount=data.amount,
        date=data.date,
        reference_number=data.reference_number,
        remarks=data.remarks,
        user_id=str(current_user.id),
    )
    return transaction


@router.post("/transfers", status_code=201)
async def create_transfer(
    data: CashBankTransferCreate,
    current_business: Business = Depends(get_current_business),
    current_user: User = Depends(get_current_user),
):
    """Create cash-bank transfer."""
    transfer = await bank_service.create_transfer(
        business_id=str(current_business.id),
        transfer_type=data.transfer_type,
        amount=data.amount,
        date=data.date,
        bank_account_id=str(data.bank_account_id) if data.bank_account_id else None,
        remarks=data.remarks,
        user_id=str(current_user.id),
    )
    return transfer
