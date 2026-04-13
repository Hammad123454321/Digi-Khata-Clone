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
