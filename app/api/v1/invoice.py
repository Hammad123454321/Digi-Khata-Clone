"""Invoice endpoints."""
from typing import List, Optional
from datetime import datetime
from fastapi import APIRouter, Depends, Query, Response
from fastapi.responses import StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession
import io

from app.core.database import get_db
from app.api.dependencies import get_current_user, get_current_business
from app.models.user import User
from app.models.business import Business
from app.schemas.invoice import InvoiceCreate, InvoiceResponse, InvoiceListResponse
from app.services.invoice import invoice_service
from app.services.pdf import PDFService
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from app.models.invoice import Invoice

router = APIRouter(prefix="/invoices", tags=["Invoices"])


@router.post("", response_model=InvoiceResponse, status_code=201)
async def create_invoice(
    data: InvoiceCreate,
    current_business: Business = Depends(get_current_business),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a new invoice."""
    invoice = await invoice_service.create_invoice(
        business_id=current_business.id,
        customer_id=data.customer_id,
        invoice_type=data.invoice_type,
        date=data.date,
        items=[item.dict() for item in data.items],
        tax_amount=data.tax_amount,
        discount_amount=data.discount_amount,
        remarks=data.remarks,
        user_id=current_user.id,
        db=db,
    )
    await db.commit()
    
    # Generate PDF asynchronously (don't block response)
    try:
        await PDFService.generate_invoice_pdf_and_save(
            invoice.id,
            db,
            upload_to_s3=True
        )
    except Exception as e:
        # Log error but don't fail invoice creation
        from app.core.logging import get_logger
        logger = get_logger(__name__)
        logger.error("pdf_generation_failed", invoice_id=invoice.id, error=str(e))
    
    # Reload with items
    from sqlalchemy.orm import selectinload
    from app.models.invoice import Invoice
    result = await db.execute(
        select(Invoice)
        .where(Invoice.id == invoice.id)
        .options(selectinload(Invoice.items))
    )
    invoice = result.scalar_one()
    
    return invoice


@router.get("", response_model=List[InvoiceListResponse])
async def list_invoices(
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    customer_id: Optional[int] = Query(None),
    invoice_type: Optional[str] = Query(None, pattern="^(cash|credit)$"),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """List invoices."""
    invoices = await invoice_service.list_invoices(
        business_id=current_business.id,
        start_date=start_date,
        end_date=end_date,
        customer_id=customer_id,
        invoice_type=invoice_type,
        limit=limit,
        offset=offset,
        db=db,
    )
    return invoices


@router.get("/{invoice_id}", response_model=InvoiceResponse)
async def get_invoice(
    invoice_id: int,
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """Get invoice details."""
    return await invoice_service.get_invoice(invoice_id, current_business.id, db)


@router.get("/{invoice_id}/pdf")
async def get_invoice_pdf(
    invoice_id: int,
    current_business: Business = Depends(get_current_business),
    db: AsyncSession = Depends(get_db),
):
    """Download invoice PDF."""
    # Verify invoice belongs to business
    invoice = await invoice_service.get_invoice(invoice_id, current_business.id, db)
    
    # Generate PDF
    pdf_bytes = await PDFService.generate_invoice_pdf(invoice_id, db)
    
    # Return as streaming response
    return StreamingResponse(
        io.BytesIO(pdf_bytes),
        media_type="application/pdf",
        headers={
            "Content-Disposition": f'attachment; filename="invoice_{invoice.invoice_number}.pdf"'
        }
    )

