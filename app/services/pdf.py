"""PDF generation service."""
import os
import io
from typing import Optional, BinaryIO
from datetime import datetime
from decimal import Decimal
from beanie import PydanticObjectId
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter, A4
from reportlab.lib.units import inch
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, PageBreak
from reportlab.lib.enums import TA_CENTER, TA_RIGHT, TA_LEFT

from app.models.invoice import Invoice, InvoiceItem
from app.models.business import Business
from app.models.customer import Customer
from app.core.config import get_settings
from app.core.exceptions import NotFoundError
from app.core.logging import get_logger

settings = get_settings()
logger = get_logger(__name__)


class PDFService:
    """PDF generation service."""

    @staticmethod
    async def generate_invoice_pdf(invoice_id: str) -> bytes:
        """Generate PDF for invoice and return as bytes."""
        try:
            invoice_obj_id = PydanticObjectId(invoice_id)
        except (ValueError, TypeError):
            raise NotFoundError("Invoice not found")

        # Get invoice
        invoice = await Invoice.get(invoice_obj_id)

        if not invoice:
            raise NotFoundError("Invoice not found")

        # Load related data - store items in a variable instead of assigning to invoice
        invoice_items = await InvoiceItem.find(InvoiceItem.invoice_id == invoice.id).to_list()
        
        business = None
        if invoice.business_id:
            business = await Business.get(invoice.business_id)
        
        customer = None
        if invoice.customer_id:
            customer = await Customer.get(invoice.customer_id)

        # Create PDF in memory
        buffer = io.BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=A4, rightMargin=0.75*inch, leftMargin=0.75*inch)
        story = []
        styles = getSampleStyleSheet()

        # Title style
        title_style = ParagraphStyle(
            'CustomTitle',
            parent=styles['Heading1'],
            fontSize=20,
            textColor=colors.HexColor('#1a1a1a'),
            spaceAfter=30,
            alignment=TA_CENTER
        )

        # Header style
        header_style = ParagraphStyle(
            'CustomHeader',
            parent=styles['Normal'],
            fontSize=12,
            textColor=colors.HexColor('#333333'),
            spaceAfter=12
        )

        # Normal style
        normal_style = ParagraphStyle(
            'CustomNormal',
            parent=styles['Normal'],
            fontSize=10,
            textColor=colors.HexColor('#666666'),
            spaceAfter=6
        )

        # Add title
        story.append(Paragraph("INVOICE", title_style))
        story.append(Spacer(1, 0.2*inch))

        # Business details
        if not business:
            raise NotFoundError("Business not found for invoice")
        business_data = [
            [Paragraph(f"<b>{business.name}</b>", header_style)],
        ]
        if business.address:
            business_data.append([Paragraph(business.address, normal_style)])
        if business.phone:
            business_data.append([Paragraph(f"Phone: {business.phone}", normal_style)])
        if business.email:
            business_email = business.get_email() if hasattr(business, 'get_email') else business.email
            if business_email:
                business_data.append([Paragraph(f"Email: {business_email}", normal_style)])

        business_table = Table(business_data, colWidths=[4*inch])
        business_table.setStyle(TableStyle([
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ('LEFTPADDING', (0, 0), (-1, -1), 0),
            ('RIGHTPADDING', (0, 0), (-1, -1), 0),
            ('TOPPADDING', (0, 0), (-1, -1), 6),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ]))
        story.append(business_table)
        story.append(Spacer(1, 0.3*inch))

        # Invoice details and customer details side by side
        invoice_info = [
            [Paragraph("<b>Invoice Number:</b>", normal_style), Paragraph(invoice.invoice_number, normal_style)],
            [Paragraph("<b>Date:</b>", normal_style), Paragraph(invoice.date.strftime("%d %B %Y"), normal_style)],
            [Paragraph("<b>Type:</b>", normal_style), Paragraph(invoice.invoice_type.value.upper(), normal_style)],
        ]

        customer_info = []
        if customer:
            customer_info = [
                [Paragraph("<b>Bill To:</b>", normal_style)],
                [Paragraph(f"<b>{customer.name}</b>", header_style)],
            ]
            if customer.phone:
                customer_phone = customer.get_phone() if hasattr(customer, 'get_phone') else customer.phone
                if customer_phone:
                    customer_info.append([Paragraph(f"Phone: {customer_phone}", normal_style)])
            if customer.email:
                customer_email = customer.get_email() if hasattr(customer, 'get_email') else customer.email
                if customer_email:
                    customer_info.append([Paragraph(f"Email: {customer_email}", normal_style)])
            if customer.address:
                customer_info.append([Paragraph(customer.address, normal_style)])

        # Create two-column layout
        info_data = []
        invoice_table = Table(invoice_info, colWidths=[1.5*inch, 2.5*inch])
        invoice_table.setStyle(TableStyle([
            ('ALIGN', (0, 0), (0, -1), 'LEFT'),
            ('ALIGN', (1, 0), (1, -1), 'LEFT'),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ('LEFTPADDING', (0, 0), (-1, -1), 0),
            ('RIGHTPADDING', (0, 0), (-1, -1), 0),
            ('TOPPADDING', (0, 0), (-1, -1), 4),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ]))

        if customer_info:
            customer_table = Table(customer_info, colWidths=[2*inch])
            customer_table.setStyle(TableStyle([
                ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
                ('VALIGN', (0, 0), (-1, -1), 'TOP'),
                ('LEFTPADDING', (0, 0), (-1, -1), 0),
                ('RIGHTPADDING', (0, 0), (-1, -1), 0),
                ('TOPPADDING', (0, 0), (-1, -1), 4),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
            ]))
            info_data = [[invoice_table, customer_table]]
        else:
            info_data = [[invoice_table]]

        info_table = Table(info_data, colWidths=[4*inch, 2.5*inch])
        info_table.setStyle(TableStyle([
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ]))
        story.append(info_table)
        story.append(Spacer(1, 0.3*inch))

        # Items table
        items_data = [
            ['Item', 'Quantity', 'Unit Price', 'Total']
        ]

        for item in invoice_items:
            items_data.append([
                Paragraph(item.item_name, normal_style),
                Paragraph(str(item.quantity), normal_style),
                Paragraph(f"{item.unit_price:,.2f}", normal_style),
                Paragraph(f"{item.total_price:,.2f}", normal_style),
            ])

        items_table = Table(items_data, colWidths=[2.5*inch, 1*inch, 1.2*inch, 1.3*inch])
        items_table.setStyle(TableStyle([
            # Header row
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#f0f0f0')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.HexColor('#333333')),
            ('ALIGN', (0, 0), (-1, 0), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 10),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
            ('TOPPADDING', (0, 0), (-1, 0), 12),
            # Data rows
            ('ALIGN', (0, 1), (0, -1), 'LEFT'),
            ('ALIGN', (1, 1), (-1, -1), 'RIGHT'),
            ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
            ('FONTSIZE', (0, 1), (-1, -1), 9),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#cccccc')),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('LEFTPADDING', (0, 0), (-1, -1), 8),
            ('RIGHTPADDING', (0, 0), (-1, -1), 8),
            ('TOPPADDING', (0, 1), (-1, -1), 8),
            ('BOTTOMPADDING', (0, 1), (-1, -1), 8),
        ]))
        story.append(items_table)
        story.append(Spacer(1, 0.3*inch))

        # Totals
        totals_data = [
            ['Subtotal:', f"{invoice.subtotal:,.2f}"],
        ]
        if invoice.discount_amount > 0:
            totals_data.append(['Discount:', f"-{invoice.discount_amount:,.2f}"])
        if invoice.tax_amount > 0:
            totals_data.append(['Tax:', f"{invoice.tax_amount:,.2f}"])
        totals_data.append(['<b>Total Amount:</b>', f"<b>{invoice.total_amount:,.2f}</b>"])

        if invoice.invoice_type.value == "credit":
            totals_data.append(['Paid Amount:', f"{invoice.paid_amount:,.2f}"])
            balance = invoice.total_amount - invoice.paid_amount
            if balance > 0:
                totals_data.append(['<b>Balance Due:</b>', f"<b>{balance:,.2f}</b>"])

        totals_table = Table(totals_data, colWidths=[3*inch, 2*inch])
        totals_table.setStyle(TableStyle([
            ('ALIGN', (0, 0), (0, -1), 'RIGHT'),
            ('ALIGN', (1, 0), (1, -1), 'RIGHT'),
            ('FONTNAME', (0, 0), (-1, -2), 'Helvetica'),
            ('FONTNAME', (0, -1), (-1, -1), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, -1), 10),
            ('TOPPADDING', (0, 0), (-1, -1), 6),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
            ('LEFTPADDING', (0, 0), (-1, -1), 0),
            ('RIGHTPADDING', (0, 0), (-1, -1), 0),
        ]))
        story.append(totals_table)
        story.append(Spacer(1, 0.2*inch))

        # Payment status
        if invoice.invoice_type.value == "cash":
            status_text = "Payment Status: <b>Paid</b>"
        else:
            if invoice.paid_amount >= invoice.total_amount:
                status_text = "Payment Status: <b>Paid</b>"
            elif invoice.paid_amount > 0:
                status_text = f"Payment Status: <b>Partial ({invoice.paid_amount:,.2f} / {invoice.total_amount:,.2f})</b>"
            else:
                status_text = "Payment Status: <b>Pending</b>"

        story.append(Paragraph(status_text, normal_style))

        # Remarks
        if invoice.remarks:
            story.append(Spacer(1, 0.2*inch))
            story.append(Paragraph("<b>Remarks:</b>", normal_style))
            story.append(Paragraph(invoice.remarks, normal_style))

        # Build PDF
        doc.build(story)
        pdf_bytes = buffer.getvalue()
        buffer.close()

        logger.info("pdf_generated", invoice_id=invoice_id, invoice_number=invoice.invoice_number)

        return pdf_bytes

    @staticmethod
    async def generate_invoice_pdf_and_save(
        invoice_id: str,
        upload_to_s3: bool = True
    ) -> str:
        """Generate PDF and optionally save to S3, return path/URL."""
        pdf_bytes = await PDFService.generate_invoice_pdf(invoice_id)

        # Get invoice to update pdf_path
        try:
            invoice_obj_id = PydanticObjectId(invoice_id)
        except (ValueError, TypeError):
            raise NotFoundError("Invoice not found")

        invoice = await Invoice.get(invoice_obj_id)

        if not invoice:
            raise NotFoundError("Invoice not found")

        pdf_filename = f"{invoice.invoice_number}.pdf"
        pdf_path = f"invoices/{invoice.business_id}/{pdf_filename}"

        if upload_to_s3 and settings.S3_BUCKET_NAME:
            try:
                import boto3
                from botocore.exceptions import ClientError

                s3_client = boto3.client(
                    's3',
                    aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
                    aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
                    region_name=settings.AWS_REGION,
                    endpoint_url=settings.S3_ENDPOINT_URL if settings.S3_ENDPOINT_URL else None,
                    use_ssl=settings.S3_USE_SSL,
                )

                s3_client.put_object(
                    Bucket=settings.S3_BUCKET_NAME,
                    Key=pdf_path,
                    Body=pdf_bytes,
                    ContentType='application/pdf',
                )

                logger.info("pdf_uploaded_to_s3", invoice_id=invoice_id, s3_path=pdf_path)
            except Exception as e:
                logger.error("pdf_s3_upload_failed", invoice_id=invoice_id, error=str(e))
                # Continue without S3 upload

        # Update invoice with PDF path
        invoice.pdf_path = pdf_path
        await invoice.save()

        return pdf_path
