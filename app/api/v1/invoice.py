"""Invoice endpoints."""
from typing import List, Optional
from datetime import datetime
from fastapi import APIRouter, Depends, Query, Request
from fastapi.responses import StreamingResponse, JSONResponse
import io

from app.api.dependencies import get_current_user, get_current_business
from app.models.user import User
from app.models.business import Business
from app.schemas.invoice import InvoiceCreate, InvoiceResponse, InvoiceListResponse, InvoiceItemResponse
from app.services.invoice import invoice_service
from app.services.pdf import PDFService

router = APIRouter(prefix="/invoices", tags=["Invoices"])


@router.post("", response_model=InvoiceResponse, status_code=201)
async def create_invoice(
    data: InvoiceCreate,
    current_business: Business = Depends(get_current_business),
    current_user: User = Depends(get_current_user),
):
    """Create a new invoice."""
    invoice = await invoice_service.create_invoice(
        business_id=str(current_business.id),
        customer_id=str(data.customer_id) if data.customer_id else None,
        invoice_type=data.invoice_type,
        date=data.date,
        items=[item.model_dump() for item in data.items],
        tax_amount=data.tax_amount,
        discount_amount=data.discount_amount,
        remarks=data.remarks,
        user_id=str(current_user.id),
    )
    
    # Generate PDF asynchronously (don't block response)
    try:
        await PDFService.generate_invoice_pdf_and_save(
            str(invoice.id),
            upload_to_s3=True
        )
    except Exception as e:
        # Log error but don't fail invoice creation
        from app.core.logging import get_logger
        logger = get_logger(__name__)
        logger.error("pdf_generation_failed", invoice_id=str(invoice.id), error=str(e))
    
    # Convert ObjectIds to strings for response
    items = [
        InvoiceItemResponse(
            id=str(item.id),
            item_id=str(item.item_id) if item.item_id else None,
            item_name=item.item_name,
            quantity=item.quantity,
            unit_price=item.unit_price,
            total_price=item.total_price,
        )
        for item in invoice.items
    ] if invoice.items else []
    
    return InvoiceResponse(
        id=str(invoice.id),
        invoice_number=invoice.invoice_number,
        customer_id=str(invoice.customer_id) if invoice.customer_id else None,
        invoice_type=invoice.invoice_type.value,
        date=invoice.date,
        subtotal=invoice.subtotal,
        tax_amount=invoice.tax_amount,
        discount_amount=invoice.discount_amount,
        total_amount=invoice.total_amount,
        paid_amount=invoice.paid_amount,
        remarks=invoice.remarks,
        pdf_path=invoice.pdf_path,
        items=items,
        created_at=invoice.created_at,
    )


@router.get("", response_model=List[InvoiceListResponse])
async def list_invoices(
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    customer_id: Optional[str] = Query(None),
    invoice_type: Optional[str] = Query(None, pattern="^(cash|credit)$"),
    is_paid: Optional[bool] = Query(None, description="Filter by payment status (true=paid, false=unpaid)"),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    current_business: Business = Depends(get_current_business),
):
    """List invoices."""
    invoices = await invoice_service.list_invoices(
        business_id=str(current_business.id),
        start_date=start_date,
        end_date=end_date,
        customer_id=customer_id,
        invoice_type=invoice_type,
        is_paid=is_paid,
        limit=limit,
        offset=offset,
    )
    # Convert ObjectIds to strings for response
    return [
        InvoiceListResponse(
            id=str(inv.id),
            invoice_number=inv.invoice_number,
            customer_id=str(inv.customer_id) if inv.customer_id else None,
            invoice_type=inv.invoice_type.value,
            date=inv.date,
            total_amount=inv.total_amount,
            paid_amount=inv.paid_amount,
            created_at=inv.created_at,
        )
        for inv in invoices
    ]


@router.get("/{invoice_id}", response_model=InvoiceResponse)
async def get_invoice(
    invoice_id: str,
    current_business: Business = Depends(get_current_business),
):
    """Get invoice details."""
    invoice = await invoice_service.get_invoice(invoice_id, str(current_business.id))
    
    # Convert ObjectIds to strings for response
    items = [
        InvoiceItemResponse(
            id=str(item.id),
            item_id=str(item.item_id) if item.item_id else None,
            item_name=item.item_name,
            quantity=item.quantity,
            unit_price=item.unit_price,
            total_price=item.total_price,
        )
        for item in invoice.items
    ] if invoice.items else []
    
    return InvoiceResponse(
        id=str(invoice.id),
        invoice_number=invoice.invoice_number,
        customer_id=str(invoice.customer_id) if invoice.customer_id else None,
        invoice_type=invoice.invoice_type.value,
        date=invoice.date,
        subtotal=invoice.subtotal,
        tax_amount=invoice.tax_amount,
        discount_amount=invoice.discount_amount,
        total_amount=invoice.total_amount,
        paid_amount=invoice.paid_amount,
        remarks=invoice.remarks,
        pdf_path=invoice.pdf_path,
        items=items,
        created_at=invoice.created_at,
    )


@router.get("/{invoice_id}/pdf")
async def get_invoice_pdf(
    invoice_id: str,
    request: Request,
    current_business: Business = Depends(get_current_business),
):
    """Download invoice PDF."""
    from app.core.logging import get_logger
    
    logger = get_logger(__name__)
    
    try:
        # Verify invoice belongs to business
        invoice = await invoice_service.get_invoice(invoice_id, str(current_business.id))
        
        # Generate PDF
        pdf_bytes = await PDFService.generate_invoice_pdf(invoice_id)
        
        # Get origin for CORS
        origin = request.headers.get("origin", "*")
        
        # Return as streaming response with CORS headers
        headers = {
            "Content-Disposition": f'attachment; filename="invoice_{invoice.invoice_number}.pdf"',
            "Access-Control-Allow-Origin": origin if origin != "*" else "*",
            "Access-Control-Allow-Credentials": "false",
            "Access-Control-Expose-Headers": "*",
        }
        
        return StreamingResponse(
            io.BytesIO(pdf_bytes),
            media_type="application/pdf",
            headers=headers
        )
    except Exception as e:
        # Handle errors with CORS headers
        logger.error(f"Error generating PDF: {e}", exc_info=True)
        
        origin = request.headers.get("origin", "*")
        return JSONResponse(
            status_code=500,
            content={"detail": f"Error generating PDF: {str(e)}"},
            headers={
                "Access-Control-Allow-Origin": origin if origin != "*" else "*",
                "Access-Control-Allow-Credentials": "false",
            }
        )

