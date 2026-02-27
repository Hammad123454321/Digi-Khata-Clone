"""PDF generation service."""
import os
import io
from typing import Optional
from decimal import Decimal
from beanie import PydanticObjectId
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import inch
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_RIGHT, TA_LEFT
from reportlab.graphics.barcode import qr
from reportlab.graphics.shapes import Drawing
from reportlab.platypus import (
    SimpleDocTemplate,
    Table,
    TableStyle,
    Paragraph,
    Spacer,
    Image,
)

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

    _OUTER_BORDER = 1.1
    _INNER_BORDER = 0.6

    @staticmethod
    def _safe_text(value: Optional[str], fallback: str = "-") -> str:
        text = (value or "").strip()
        return text if text else fallback

    @staticmethod
    def _format_amount(value: Decimal) -> str:
        return f"{value:,.2f}"

    @staticmethod
    def _build_qr_drawing(data: str, size: float = 0.9 * inch) -> Drawing:
        qr_widget = qr.QrCodeWidget(data)
        min_x, min_y, max_x, max_y = qr_widget.getBounds()
        qr_width = max_x - min_x
        qr_height = max_y - min_y
        drawing = Drawing(
            size,
            size,
            transform=[
                size / qr_width,
                0,
                0,
                size / qr_height,
                0,
                0,
            ],
        )
        drawing.add(qr_widget)
        return drawing

    @staticmethod
    def _build_logo_flowable() -> Optional[Image]:
        current_dir = os.path.dirname(os.path.abspath(__file__))
        candidate_paths = [
            os.path.join(current_dir, "..", "..", "flutter_app", "app-logo.jpeg"),
            os.path.join(current_dir, "..", "..", "app-logo.jpeg"),
            os.path.join(os.getcwd(), "flutter_app", "app-logo.jpeg"),
            os.path.join(os.getcwd(), "app-logo.jpeg"),
        ]
        for raw_path in candidate_paths:
            path = os.path.normpath(raw_path)
            if os.path.exists(path):
                logo = Image(path, width=1.0 * inch, height=0.75 * inch)
                logo.hAlign = "CENTER"
                return logo
        return None

    @staticmethod
    def _build_key_value_table(
        rows: list[tuple[str, str]],
        label_style: ParagraphStyle,
        value_style: ParagraphStyle,
    ) -> Table:
        data = [
            [Paragraph(label, label_style), Paragraph(value, value_style)]
            for label, value in rows
        ]
        table = Table(data, colWidths=[1.25 * inch, 2.1 * inch])
        table.setStyle(
            TableStyle(
                [
                    ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                    ("ALIGN", (0, 0), (0, -1), "RIGHT"),
                    ("ALIGN", (1, 0), (1, -1), "LEFT"),
                    ("LEFTPADDING", (0, 0), (-1, -1), 2),
                    ("RIGHTPADDING", (0, 0), (-1, -1), 2),
                    ("TOPPADDING", (0, 0), (-1, -1), 2),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
                    ("LINEBELOW", (1, 0), (1, -1), PDFService._INNER_BORDER, colors.black),
                ]
            )
        )
        return table

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

        buffer = io.BytesIO()
        doc = SimpleDocTemplate(
            buffer,
            pagesize=A4,
            rightMargin=0.35 * inch,
            leftMargin=0.35 * inch,
            topMargin=0.35 * inch,
            bottomMargin=0.35 * inch,
        )
        story = []
        styles = getSampleStyleSheet()

        title_style = ParagraphStyle(
            "PdfTitle",
            parent=styles["Heading1"],
            fontSize=12,
            alignment=TA_CENTER,
            textColor=colors.HexColor("#111111"),
            leading=14,
        )
        header_style = ParagraphStyle(
            "PdfHeader",
            parent=styles["Normal"],
            fontSize=10,
            leading=12,
            alignment=TA_RIGHT,
            textColor=colors.HexColor("#111111"),
        )
        info_label_style = ParagraphStyle(
            "InfoLabel",
            parent=styles["Normal"],
            fontSize=8.3,
            leading=10,
            alignment=TA_RIGHT,
            textColor=colors.HexColor("#111111"),
        )
        normal_style = ParagraphStyle(
            "PdfNormal",
            parent=styles["Normal"],
            fontSize=8.8,
            leading=10,
            alignment=TA_LEFT,
            textColor=colors.HexColor("#111111"),
        )
        small_muted_style = ParagraphStyle(
            "PdfMuted",
            parent=styles["Normal"],
            fontSize=7.5,
            leading=9,
            alignment=TA_CENTER,
            textColor=colors.HexColor("#555555"),
        )

        if not business:
            raise NotFoundError("Business not found for invoice")
        business_phone = business.phone
        customer_phone = customer.get_phone() if customer and hasattr(customer, "get_phone") else (
            customer.phone if customer else None
        )

        logo = PDFService._build_logo_flowable()
        qr_cell = PDFService._build_qr_drawing(
            data=invoice.invoice_number or str(invoice.id),
            size=0.82 * inch,
        )

        center_block = []
        if logo:
            center_block.append(logo)
        center_block.extend(
            [
                Paragraph(f"<b>{PDFService._safe_text(business.name)}</b>", title_style),
                Paragraph("Invoice", small_muted_style),
            ]
        )

        right_block = [
            Paragraph(f"<b>{PDFService._safe_text(business.name)}</b>", header_style),
            Paragraph(PDFService._safe_text(business.address), header_style),
            Paragraph(f"Phone: {PDFService._safe_text(business_phone)}", header_style),
            Paragraph(f"Invoice #: {invoice.invoice_number}", header_style),
        ]

        header_table = Table(
            [[qr_cell, center_block, right_block]],
            colWidths=[1.1 * inch, 3.55 * inch, 2.45 * inch],
            hAlign="LEFT",
        )
        header_table.setStyle(
            TableStyle(
                [
                    ("BOX", (0, 0), (-1, -1), PDFService._OUTER_BORDER, colors.black),
                    ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                    ("ALIGN", (0, 0), (0, 0), "CENTER"),
                    ("ALIGN", (1, 0), (1, 0), "CENTER"),
                    ("ALIGN", (2, 0), (2, 0), "RIGHT"),
                    ("LEFTPADDING", (0, 0), (-1, -1), 6),
                    ("RIGHTPADDING", (0, 0), (-1, -1), 6),
                    ("TOPPADDING", (0, 0), (-1, -1), 6),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
                ]
            )
        )
        story.append(header_table)
        story.append(Spacer(1, 0.15 * inch))

        left_rows = [
            ("Invoice No", invoice.invoice_number),
            ("Invoice Date", invoice.date.strftime("%Y/%m/%d")),
            ("Customer", PDFService._safe_text(customer.name if customer else None)),
            ("Customer Phone", PDFService._safe_text(customer_phone)),
        ]
        right_rows = [
            ("Invoice Type", invoice.invoice_type.value.upper()),
            ("Customer Address", PDFService._safe_text(customer.address if customer else None)),
            ("Business Phone", PDFService._safe_text(business_phone)),
            ("Business Address", PDFService._safe_text(business.address)),
        ]

        left_info_table = PDFService._build_key_value_table(
            rows=left_rows,
            label_style=info_label_style,
            value_style=normal_style,
        )
        right_info_table = PDFService._build_key_value_table(
            rows=right_rows,
            label_style=info_label_style,
            value_style=normal_style,
        )

        info_wrapper = Table(
            [[left_info_table, Paragraph("<b>Tax Invoice</b>", title_style), right_info_table]],
            colWidths=[2.8 * inch, 1.1 * inch, 3.2 * inch],
            hAlign="LEFT",
        )
        info_wrapper.setStyle(
            TableStyle(
                [
                    ("VALIGN", (0, 0), (-1, -1), "TOP"),
                    ("ALIGN", (1, 0), (1, 0), "CENTER"),
                ]
            )
        )
        story.append(info_wrapper)
        story.append(Spacer(1, 0.12 * inch))

        tax_percent = Decimal("0")
        discount_percent = Decimal("0")
        if invoice.subtotal and invoice.subtotal > 0:
            tax_percent = (invoice.tax_amount / invoice.subtotal) * Decimal("100")
            discount_percent = (invoice.discount_amount / invoice.subtotal) * Decimal("100")

        items_data = [["No", "Item Description", "Unit", "Qty", "Unit Price", "Disc%", "Tax%", "Amount"]]

        for index, item in enumerate(invoice_items, start=1):
            items_data.append([
                str(index),
                Paragraph(PDFService._safe_text(item.item_name), normal_style),
                "-",
                str(item.quantity),
                PDFService._format_amount(item.unit_price),
                f"{discount_percent:,.2f}",
                f"{tax_percent:,.2f}",
                PDFService._format_amount(item.total_price),
            ])

        min_item_rows = 8
        if len(items_data) - 1 < min_item_rows:
            missing_rows = min_item_rows - (len(items_data) - 1)
            for _ in range(missing_rows):
                items_data.append(["", "", "", "", "", "", "", ""])

        items_table = Table(
            items_data,
            colWidths=[
                0.40 * inch,
                2.70 * inch,
                0.55 * inch,
                0.48 * inch,
                0.85 * inch,
                0.62 * inch,
                0.62 * inch,
                0.95 * inch,
            ],
            repeatRows=1,
        )
        items_table.setStyle(
            TableStyle(
                [
                    ("BOX", (0, 0), (-1, -1), PDFService._OUTER_BORDER, colors.black),
                    ("GRID", (0, 0), (-1, -1), PDFService._INNER_BORDER, colors.black),
                    ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#e6e6e6")),
                    ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                    ("FONTNAME", (0, 1), (-1, -1), "Helvetica"),
                    ("FONTSIZE", (0, 0), (-1, -1), 8),
                    ("ALIGN", (0, 0), (0, -1), "CENTER"),
                    ("ALIGN", (1, 0), (1, -1), "LEFT"),
                    ("ALIGN", (2, 0), (-1, -1), "RIGHT"),
                    ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                    ("LEFTPADDING", (0, 0), (-1, -1), 4),
                    ("RIGHTPADDING", (0, 0), (-1, -1), 4),
                    ("TOPPADDING", (0, 0), (-1, -1), 5),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
                ]
            )
        )
        story.append(items_table)
        story.append(Spacer(1, 0.08 * inch))

        balance = invoice.total_amount - invoice.paid_amount
        totals_table = Table(
            [
                ["Gross Total", PDFService._format_amount(invoice.subtotal)],
                ["Tax", PDFService._format_amount(invoice.tax_amount)],
                ["Discount", PDFService._format_amount(invoice.discount_amount)],
                ["Net Total", PDFService._format_amount(invoice.total_amount)],
                ["Paid", PDFService._format_amount(invoice.paid_amount)],
                ["Balance", PDFService._format_amount(balance)],
            ],
            colWidths=[1.6 * inch, 1.2 * inch],
            hAlign="RIGHT",
        )
        totals_table.setStyle(
            TableStyle(
                [
                    ("BOX", (0, 0), (-1, -1), PDFService._OUTER_BORDER, colors.black),
                    ("GRID", (0, 0), (-1, -1), PDFService._INNER_BORDER, colors.black),
                    ("FONTNAME", (0, 0), (-1, -2), "Helvetica"),
                    ("FONTNAME", (0, -1), (-1, -1), "Helvetica-Bold"),
                    ("ALIGN", (0, 0), (0, -1), "RIGHT"),
                    ("ALIGN", (1, 0), (1, -1), "RIGHT"),
                    ("FONTSIZE", (0, 0), (-1, -1), 8.5),
                    ("LEFTPADDING", (0, 0), (-1, -1), 4),
                    ("RIGHTPADDING", (0, 0), (-1, -1), 4),
                    ("TOPPADDING", (0, 0), (-1, -1), 3),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
                ]
            )
        )

        quantity_total = sum(item.quantity for item in invoice_items) if invoice_items else Decimal("0")
        summary_row = Table(
            [
                [
                    Paragraph(f"Total Items Qty: {quantity_total}", normal_style),
                    totals_table,
                ]
            ],
            colWidths=[4.2 * inch, 2.8 * inch],
            hAlign="LEFT",
        )
        summary_row.setStyle(
            TableStyle(
                [
                    ("VALIGN", (0, 0), (-1, -1), "BOTTOM"),
                    ("ALIGN", (0, 0), (0, 0), "LEFT"),
                ]
            )
        )
        story.append(summary_row)
        story.append(Spacer(1, 0.10 * inch))

        if invoice.remarks:
            story.append(Paragraph(f"Notes: {invoice.remarks}", normal_style))
            story.append(Spacer(1, 0.06 * inch))

        footer_table = Table(
            [
                [
                    Paragraph(
                        f"Printed by system on {invoice.created_at.strftime('%d/%m/%Y %I:%M %p')}",
                        small_muted_style,
                    )
                ]
            ],
            colWidths=[7.0 * inch],
        )
        footer_table.setStyle(
            TableStyle(
                [
                    ("LINEABOVE", (0, 0), (-1, 0), PDFService._OUTER_BORDER, colors.black),
                    ("TOPPADDING", (0, 0), (-1, -1), 6),
                    ("ALIGN", (0, 0), (-1, -1), "LEFT"),
                ]
            )
        )
        story.append(footer_table)

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
