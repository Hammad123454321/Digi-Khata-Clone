"""Tests for stock-report consistency and movement calculations."""

from datetime import datetime
from decimal import Decimal
from types import SimpleNamespace

import pytest
from beanie import PydanticObjectId

from app.models.item import InventoryTransactionType, ItemUnit
from app.services import reports as reports_module
from app.services.reports import ReportsService


class _FakeQuery:
    def __init__(self, rows):
        self._rows = rows

    def sort(self, *_args, **_kwargs):
        return self

    async def to_list(self):
        return self._rows


@pytest.mark.asyncio
async def test_stock_report_uses_invoice_prices_and_has_consistent_movement_summary(
    monkeypatch,
):
    """Stock sold value should use invoice line prices; movement totals must stay in sync."""
    business_id = "64f0f0f0f0f0f0f0f0f0f0f0"
    item_id = PydanticObjectId("64f1f1f1f1f1f1f1f1f1f1f1")
    invoice_id = PydanticObjectId("64f2f2f2f2f2f2f2f2f2f2f2")
    start_date = datetime(2026, 4, 1, 0, 0, 0)
    end_date = datetime(2026, 4, 30, 23, 59, 59)

    item = SimpleNamespace(
        id=item_id,
        name="Test Item",
        purchase_price=Decimal("10"),
        sale_price=Decimal("20"),
        unit=ItemUnit.PIECE,
        opening_stock=Decimal("10"),
        current_stock=Decimal("12"),
    )
    transactions = [
        SimpleNamespace(
            item_id=item_id,
            transaction_type=InventoryTransactionType.STOCK_IN,
            quantity=Decimal("5"),
            unit_price=Decimal("12"),
            date=datetime(2026, 4, 5, 10, 0, 0),
            reference_type=None,
            reference_id=None,
            remarks=None,
        ),
        SimpleNamespace(
            item_id=item_id,
            transaction_type=InventoryTransactionType.STOCK_OUT,
            quantity=Decimal("2"),
            unit_price=None,
            date=datetime(2026, 4, 7, 9, 0, 0),
            reference_type="invoice",
            reference_id=invoice_id,
            remarks=None,
        ),
        SimpleNamespace(
            item_id=item_id,
            transaction_type=InventoryTransactionType.STOCK_OUT,
            quantity=Decimal("1"),
            unit_price=Decimal("15"),
            date=datetime(2026, 4, 9, 8, 0, 0),
            reference_type="manual",
            reference_id=None,
            remarks="manual out",
        ),
    ]
    invoice_items = [
        SimpleNamespace(
            invoice_id=invoice_id,
            item_id=item_id,
            quantity=Decimal("2"),
            total_price=Decimal("60"),
        ),
    ]
    customer_id = PydanticObjectId("64f4f4f4f4f4f4f4f4f4f4f4")
    invoices = [
        SimpleNamespace(
            id=invoice_id,
            customer_id=customer_id,
        ),
    ]
    customers = [
        SimpleNamespace(
            id=customer_id,
            name="Zahid",
        ),
    ]

    monkeypatch.setattr(
        reports_module.Item,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery([item])),
    )
    monkeypatch.setattr(
        reports_module.InventoryTransaction,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery(transactions)),
    )
    monkeypatch.setattr(
        reports_module.LowStockAlert,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery([])),
    )
    monkeypatch.setattr(
        reports_module.InvoiceItem,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery(invoice_items)),
    )
    monkeypatch.setattr(
        reports_module.Invoice,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery(invoices)),
    )
    monkeypatch.setattr(
        reports_module.Customer,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery(customers)),
    )

    report = await ReportsService.get_stock_report(
        business_id=business_id,
        start_date=start_date,
        end_date=end_date,
    )

    first_item = report["items"][0]
    assert Decimal(first_item["sold_qty"]) == Decimal("2")
    assert Decimal(first_item["sold_value"]) == Decimal("60")
    assert Decimal(first_item["estimated_margin"]) == Decimal("40")

    assert report["movement_summary"]["all"]["entries"] == 3
    assert Decimal(report["movement_summary"]["all"]["qty"]) == Decimal("8")
    assert Decimal(report["movement_summary"]["all"]["amount"]) == Decimal("135")
    assert report["entries"] == report["movement_summary"]["all"]["entries"]
    assert Decimal(report["total_qty"]) == Decimal("8")
    assert Decimal(report["total_amount"]) == Decimal("135")
    assert report["period_summary"]["sold_entries"] == 1
    assert Decimal(report["period_summary"]["sold_qty"]) == Decimal("2")
    assert Decimal(report["period_summary"]["outgoing_qty"]) == Decimal("3")

    sold_items = report["sold_items"]
    assert len(sold_items) == 1
    sold_item = sold_items[0]
    assert sold_item["item_name"] == "Test Item"
    assert Decimal(sold_item["sold_amount"]) == Decimal("60")
    assert Decimal(sold_item["gross_profit"]) == Decimal("40")
    assert len(sold_item["top_customers"]) == 1
    assert sold_item["top_customers"][0]["customer_name"] == "Zahid"
    assert Decimal(sold_item["top_customers"][0]["amount"]) == Decimal("60")

    customer_breakdown = report["sold_items_customer_breakdown"]
    assert len(customer_breakdown) == 1
    assert customer_breakdown[0]["item_name"] == "Test Item"
    assert len(customer_breakdown[0]["customers"]) == 1
    assert customer_breakdown[0]["customers"][0]["customer_name"] == "Zahid"

    assert Decimal(report["profit_loss_summary"]["sales_revenue"]) == Decimal("60")
    assert Decimal(report["profit_loss_summary"]["cogs"]) == Decimal("20")
    assert Decimal(report["profit_loss_summary"]["gross_profit"]) == Decimal("40")
    assert Decimal(report["profit_loss_summary"]["gross_margin_percent"]) == Decimal(
        "66.67"
    )


@pytest.mark.asyncio
async def test_stock_report_adjustment_uses_delta_for_in_out_movement(monkeypatch):
    """Adjustment entries should be classified by delta, not absolute stock value."""
    business_id = "64f0f0f0f0f0f0f0f0f0f0f0"
    item_id = PydanticObjectId("64f3f3f3f3f3f3f3f3f3f3f3")
    start_date = datetime(2026, 4, 1, 0, 0, 0)
    end_date = datetime(2026, 4, 30, 23, 59, 59)

    item = SimpleNamespace(
        id=item_id,
        name="Adjust Item",
        purchase_price=Decimal("10"),
        sale_price=Decimal("20"),
        unit=ItemUnit.PIECE,
        opening_stock=Decimal("10"),
        current_stock=Decimal("7"),
    )
    transactions = [
        SimpleNamespace(
            item_id=item_id,
            transaction_type=InventoryTransactionType.ADJUSTMENT,
            quantity=Decimal("7"),
            unit_price=None,
            date=datetime(2026, 4, 3, 10, 0, 0),
            reference_type="manual",
            reference_id=None,
            remarks="correction",
        ),
    ]

    monkeypatch.setattr(
        reports_module.Item,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery([item])),
    )
    monkeypatch.setattr(
        reports_module.InventoryTransaction,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery(transactions)),
    )
    monkeypatch.setattr(
        reports_module.LowStockAlert,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery([])),
    )
    monkeypatch.setattr(
        reports_module.InvoiceItem,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery([])),
    )

    report = await ReportsService.get_stock_report(
        business_id=business_id,
        start_date=start_date,
        end_date=end_date,
    )

    assert report["movement_summary"]["out"]["entries"] == 1
    assert Decimal(report["movement_summary"]["out"]["qty"]) == Decimal("3")
    assert Decimal(report["movement_summary"]["out"]["amount"]) == Decimal("30")
    assert Decimal(report["items"][0]["opening_stock"]) == Decimal("10")
    assert Decimal(report["items"][0]["closing_stock"]) == Decimal("7")


@pytest.mark.asyncio
async def test_stock_report_empty_sales_period_has_readable_new_blocks(monkeypatch):
    """New stock report blocks should remain valid when no invoice sales exist."""
    business_id = "64f0f0f0f0f0f0f0f0f0f0f0"
    item_id = PydanticObjectId("64f5f5f5f5f5f5f5f5f5f5f5")
    start_date = datetime(2026, 4, 1, 0, 0, 0)
    end_date = datetime(2026, 4, 30, 23, 59, 59)

    item = SimpleNamespace(
        id=item_id,
        name="No Sale Item",
        purchase_price=Decimal("100"),
        sale_price=Decimal("130"),
        unit=ItemUnit.PIECE,
        opening_stock=Decimal("5"),
        current_stock=Decimal("8"),
    )
    transactions = [
        SimpleNamespace(
            item_id=item_id,
            transaction_type=InventoryTransactionType.STOCK_IN,
            quantity=Decimal("3"),
            unit_price=Decimal("100"),
            date=datetime(2026, 4, 2, 10, 0, 0),
            reference_type=None,
            reference_id=None,
            remarks=None,
        ),
    ]

    monkeypatch.setattr(
        reports_module.Item,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery([item])),
    )
    monkeypatch.setattr(
        reports_module.InventoryTransaction,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery(transactions)),
    )
    monkeypatch.setattr(
        reports_module.LowStockAlert,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery([])),
    )
    monkeypatch.setattr(
        reports_module.InvoiceItem,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery([])),
    )

    report = await ReportsService.get_stock_report(
        business_id=business_id,
        start_date=start_date,
        end_date=end_date,
    )

    assert report["sold_items"] == []
    assert report["sold_items_customer_breakdown"] == []
    assert Decimal(report["period_summary"]["sold_qty"]) == Decimal("0")
    assert Decimal(report["period_summary"]["sold_value"]) == Decimal("0")
    assert Decimal(report["period_summary"]["outgoing_qty"]) == Decimal("0")
    assert Decimal(report["period_summary"]["left_qty"]) == Decimal("8")
    assert Decimal(report["period_summary"]["left_value"]) == Decimal("800")
    assert Decimal(report["profit_loss_summary"]["sales_revenue"]) == Decimal("0")
    assert Decimal(report["profit_loss_summary"]["cogs"]) == Decimal("0")
    assert Decimal(report["profit_loss_summary"]["gross_profit"]) == Decimal("0")


@pytest.mark.asyncio
async def test_stock_report_date_filter_only_counts_sales_inside_selected_range(
    monkeypatch,
):
    """Sold quantities/values must only include invoice-linked stock out inside the selected range."""
    business_id = "64f0f0f0f0f0f0f0f0f0f0f0"
    item_id = PydanticObjectId("64f6f6f6f6f6f6f6f6f6f6f6")
    old_invoice_id = PydanticObjectId("64f7f7f7f7f7f7f7f7f7f7f7")
    in_range_invoice_id = PydanticObjectId("64f8f8f8f8f8f8f8f8f8f8f8")
    start_date = datetime(2026, 4, 10, 0, 0, 0)
    end_date = datetime(2026, 4, 30, 23, 59, 59)

    item = SimpleNamespace(
        id=item_id,
        name="Filter Item",
        purchase_price=Decimal("10"),
        sale_price=Decimal("20"),
        unit=ItemUnit.PIECE,
        opening_stock=Decimal("30"),
        current_stock=Decimal("24"),
    )
    transactions = [
        SimpleNamespace(
            item_id=item_id,
            transaction_type=InventoryTransactionType.STOCK_OUT,
            quantity=Decimal("2"),
            unit_price=None,
            date=datetime(2026, 4, 5, 9, 0, 0),  # outside selected range
            reference_type="invoice",
            reference_id=old_invoice_id,
            remarks=None,
        ),
        SimpleNamespace(
            item_id=item_id,
            transaction_type=InventoryTransactionType.STOCK_OUT,
            quantity=Decimal("4"),
            unit_price=None,
            date=datetime(2026, 4, 15, 9, 0, 0),  # inside selected range
            reference_type="invoice",
            reference_id=in_range_invoice_id,
            remarks=None,
        ),
    ]
    invoice_items = [
        SimpleNamespace(
            invoice_id=old_invoice_id,
            item_id=item_id,
            quantity=Decimal("2"),
            total_price=Decimal("40"),
        ),
        SimpleNamespace(
            invoice_id=in_range_invoice_id,
            item_id=item_id,
            quantity=Decimal("4"),
            total_price=Decimal("88"),
        ),
    ]
    invoices = [
        SimpleNamespace(id=old_invoice_id, customer_id=None),
        SimpleNamespace(id=in_range_invoice_id, customer_id=None),
    ]

    monkeypatch.setattr(
        reports_module.Item,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery([item])),
    )
    monkeypatch.setattr(
        reports_module.InventoryTransaction,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery(transactions)),
    )
    monkeypatch.setattr(
        reports_module.LowStockAlert,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery([])),
    )
    monkeypatch.setattr(
        reports_module.InvoiceItem,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery(invoice_items)),
    )
    monkeypatch.setattr(
        reports_module.Invoice,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery(invoices)),
    )
    monkeypatch.setattr(
        reports_module.Customer,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery([])),
    )

    report = await ReportsService.get_stock_report(
        business_id=business_id,
        start_date=start_date,
        end_date=end_date,
    )

    assert Decimal(report["period_summary"]["sold_qty"]) == Decimal("4")
    assert Decimal(report["period_summary"]["sold_value"]) == Decimal("88")
    assert Decimal(report["profit_loss_summary"]["sales_revenue"]) == Decimal("88")
    assert Decimal(report["profit_loss_summary"]["cogs"]) == Decimal("40")

    sold_item = report["sold_items"][0]
    assert Decimal(sold_item["sold_qty"]) == Decimal("4")
    assert Decimal(sold_item["sold_amount"]) == Decimal("88")


@pytest.mark.asyncio
async def test_stock_report_customer_breakdown_uses_unknown_customer_fallback(
    monkeypatch,
):
    """When customer lookup fails/missing, report must use Unknown Customer safely."""
    business_id = "64f0f0f0f0f0f0f0f0f0f0f0"
    item_id = PydanticObjectId("64f9f9f9f9f9f9f9f9f9f9f9")
    invoice_id = PydanticObjectId("64fafafafafafafafafafafa")
    missing_customer_id = PydanticObjectId("64fbfbfbfbfbfbfbfbfbfbfb")
    start_date = datetime(2026, 4, 1, 0, 0, 0)
    end_date = datetime(2026, 4, 30, 23, 59, 59)

    item = SimpleNamespace(
        id=item_id,
        name="Fallback Item",
        purchase_price=Decimal("100"),
        sale_price=Decimal("130"),
        unit=ItemUnit.PIECE,
        opening_stock=Decimal("10"),
        current_stock=Decimal("8"),
    )
    transactions = [
        SimpleNamespace(
            item_id=item_id,
            transaction_type=InventoryTransactionType.STOCK_OUT,
            quantity=Decimal("2"),
            unit_price=None,
            date=datetime(2026, 4, 8, 10, 0, 0),
            reference_type="invoice",
            reference_id=invoice_id,
            remarks=None,
        ),
    ]
    invoice_items = [
        SimpleNamespace(
            invoice_id=invoice_id,
            item_id=item_id,
            quantity=Decimal("2"),
            total_price=Decimal("300"),
        ),
    ]
    invoices = [
        SimpleNamespace(
            id=invoice_id,
            customer_id=missing_customer_id,
        ),
    ]

    monkeypatch.setattr(
        reports_module.Item,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery([item])),
    )
    monkeypatch.setattr(
        reports_module.InventoryTransaction,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery(transactions)),
    )
    monkeypatch.setattr(
        reports_module.LowStockAlert,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery([])),
    )
    monkeypatch.setattr(
        reports_module.InvoiceItem,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery(invoice_items)),
    )
    monkeypatch.setattr(
        reports_module.Invoice,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery(invoices)),
    )
    monkeypatch.setattr(
        reports_module.Customer,
        "find",
        classmethod(lambda _cls, *_a, **_k: _FakeQuery([])),
    )

    report = await ReportsService.get_stock_report(
        business_id=business_id,
        start_date=start_date,
        end_date=end_date,
    )

    sold_item = report["sold_items"][0]
    assert sold_item["top_customers"][0]["customer_name"] == "Unknown Customer"
    assert Decimal(sold_item["top_customers"][0]["amount"]) == Decimal("300")

    breakdown = report["sold_items_customer_breakdown"][0]["customers"][0]
    assert breakdown["customer_name"] == "Unknown Customer"
    assert Decimal(breakdown["qty"]) == Decimal("2")
