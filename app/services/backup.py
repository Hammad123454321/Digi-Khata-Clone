"""Backup service."""
from __future__ import annotations

import json
from datetime import datetime, timezone
from decimal import Decimal
from pathlib import Path
from typing import Any

from beanie import PydanticObjectId

from app.core.config import get_settings
from app.core.exceptions import NotFoundError, ValidationError
from app.core.logging import get_logger
from app.models.backup import Backup
from app.models.bank import BankAccount, BankTransaction, CashBankTransfer
from app.models.business import Business
from app.models.cash import CashBalance, CashTransaction
from app.models.customer import Customer, CustomerBalance, CustomerTransaction
from app.models.device import Device
from app.models.expense import Expense, ExpenseCategory
from app.models.invoice import Invoice, InvoiceItem
from app.models.item import InventoryTransaction, Item, LowStockAlert
from app.models.reminder import Reminder
from app.models.staff import Staff, StaffSalary
from app.models.supplier import Supplier, SupplierBalance, SupplierTransaction

settings = get_settings()
logger = get_logger(__name__)


class BackupService:
    """Backup service for business data."""

    _BACKUP_VERSION = 1
    _VALID_BACKUP_TYPES = {"manual", "auto"}

    # Restore order keeps dependencies safe (e.g. invoices before invoice_items)
    _RESTORE_MODEL_ORDER: tuple[tuple[str, Any], ...] = (
        ("customers", Customer),
        ("customer_balances", CustomerBalance),
        ("customer_transactions", CustomerTransaction),
        ("suppliers", Supplier),
        ("supplier_balances", SupplierBalance),
        ("supplier_transactions", SupplierTransaction),
        ("staff", Staff),
        ("staff_salaries", StaffSalary),
        ("cash_transactions", CashTransaction),
        ("cash_balances", CashBalance),
        ("expense_categories", ExpenseCategory),
        ("expenses", Expense),
        ("bank_accounts", BankAccount),
        ("bank_transactions", BankTransaction),
        ("cash_bank_transfers", CashBankTransfer),
        ("items", Item),
        ("inventory_transactions", InventoryTransaction),
        ("low_stock_alerts", LowStockAlert),
        ("invoices", Invoice),
        ("invoice_items", InvoiceItem),
        ("reminders", Reminder),
        ("devices", Device),
    )

    _BUSINESS_SCOPED_MODELS: tuple[Any, ...] = (
        Customer,
        CustomerBalance,
        CustomerTransaction,
        Supplier,
        SupplierBalance,
        SupplierTransaction,
        Staff,
        StaffSalary,
        CashTransaction,
        CashBalance,
        ExpenseCategory,
        Expense,
        BankAccount,
        BankTransaction,
        CashBankTransfer,
        Item,
        InventoryTransaction,
        LowStockAlert,
        Invoice,
        Reminder,
        Device,
    )

    @staticmethod
    async def create_backup(
        business_id: str,
        backup_type: str = "manual",
    ) -> Backup:
        """Create a business backup snapshot on local storage."""
        if backup_type not in BackupService._VALID_BACKUP_TYPES:
            raise ValidationError(
                "Invalid backup type",
                {"backup_type": [f"Allowed values: {sorted(BackupService._VALID_BACKUP_TYPES)}"]},
            )

        business_obj_id = BackupService._parse_business_id(business_id)
        now = datetime.now(timezone.utc)

        backup = Backup(
            business_id=business_obj_id,
            backup_type=backup_type,
            file_path="",
            status="in_progress",
            backup_date=now,
        )
        await backup.insert()

        try:
            snapshot = await BackupService._build_snapshot_payload(business_obj_id)
            backup_path = BackupService._build_backup_path(
                business_id=business_id,
                backup_id=str(backup.id),
                backup_type=backup_type,
                when=now,
            )
            backup_path.parent.mkdir(parents=True, exist_ok=True)
            backup_path.write_text(
                json.dumps(snapshot, ensure_ascii=False, indent=2),
                encoding="utf-8",
            )

            file_size_mb = backup_path.stat().st_size / (1024 * 1024)
            backup.file_path = str(backup_path).replace("\\", "/")
            backup.file_size = Decimal(f"{file_size_mb:.6f}")
            backup.status = "completed"
            backup.error_message = None
            backup.backup_date = now
            await backup.save()

            logger.info(
                "backup_created",
                business_id=business_id,
                backup_id=str(backup.id),
                file_path=backup.file_path,
                file_size_mb=str(backup.file_size),
            )
            return backup
        except Exception as exc:  # noqa: BLE001 - persist failure details
            backup.status = "failed"
            backup.error_message = str(exc)[:1000]
            await backup.save()
            logger.error(
                "backup_creation_failed",
                business_id=business_id,
                backup_id=str(backup.id),
                error=str(exc),
            )
            raise

    @staticmethod
    async def list_backups(
        business_id: str,
        limit: int = 50,
    ) -> list[Backup]:
        """List backups for a business."""
        business_obj_id = BackupService._parse_business_id(business_id)
        backups = (
            await Backup.find(Backup.business_id == business_obj_id)
            .sort("-backup_date")
            .limit(limit)
            .to_list()
        )
        return backups

    @staticmethod
    async def restore_backup(
        backup_id: str,
        business_id: str,
    ) -> dict:
        """Restore business data from a backup file."""
        business_obj_id = BackupService._parse_business_id(business_id)
        backup = await BackupService.get_backup_for_business(backup_id, business_id)
        if backup.status != "completed":
            raise ValidationError("Backup is not ready for restore")
        if not backup.file_path:
            raise ValidationError("Backup file path is missing")

        backup_path = Path(backup.file_path)
        if not backup_path.exists():
            raise NotFoundError("Backup file does not exist")

        try:
            payload = json.loads(backup_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            raise ValidationError("Backup file is corrupted") from exc

        if payload.get("business_id") != business_id:
            raise ValidationError("Backup does not belong to this business")
        if payload.get("version") != BackupService._BACKUP_VERSION:
            raise ValidationError("Unsupported backup version")

        restored_counts = await BackupService._restore_snapshot(
            business_obj_id=business_obj_id,
            payload=payload,
        )

        logger.info(
            "backup_restored",
            business_id=business_id,
            backup_id=backup_id,
            restored_counts=restored_counts,
        )
        return {
            "message": "Backup restored successfully",
            "backup_id": backup_id,
            "restored_counts": restored_counts,
        }

    @staticmethod
    async def get_backup_for_business(
        backup_id: str,
        business_id: str,
    ) -> Backup:
        """Return a backup record scoped to a business."""
        try:
            backup_obj_id = PydanticObjectId(backup_id)
        except (ValueError, TypeError):
            raise NotFoundError("Backup not found")

        business_obj_id = BackupService._parse_business_id(business_id)
        backup = await Backup.find_one(
            Backup.id == backup_obj_id,
            Backup.business_id == business_obj_id,
        )
        if not backup:
            raise NotFoundError("Backup not found")
        return backup

    @staticmethod
    async def _build_snapshot_payload(
        business_obj_id: PydanticObjectId,
    ) -> dict[str, Any]:
        business = await Business.get(business_obj_id)
        if not business:
            raise NotFoundError("Business not found")

        invoices = await Invoice.find(Invoice.business_id == business_obj_id).to_list()
        invoice_ids = [invoice.id for invoice in invoices if invoice.id is not None]
        invoice_items: list[InvoiceItem] = []
        if invoice_ids:
            invoice_items = await InvoiceItem.find({"invoice_id": {"$in": invoice_ids}}).to_list()

        collections: dict[str, list[dict[str, Any]]] = {
            "business": [business.model_dump(mode="json")],
            "customers": await BackupService._dump_model(Customer, business_obj_id),
            "customer_balances": await BackupService._dump_model(CustomerBalance, business_obj_id),
            "customer_transactions": await BackupService._dump_model(
                CustomerTransaction,
                business_obj_id,
            ),
            "suppliers": await BackupService._dump_model(Supplier, business_obj_id),
            "supplier_balances": await BackupService._dump_model(SupplierBalance, business_obj_id),
            "supplier_transactions": await BackupService._dump_model(
                SupplierTransaction,
                business_obj_id,
            ),
            "staff": await BackupService._dump_model(Staff, business_obj_id),
            "staff_salaries": await BackupService._dump_model(StaffSalary, business_obj_id),
            "cash_transactions": await BackupService._dump_model(CashTransaction, business_obj_id),
            "cash_balances": await BackupService._dump_model(CashBalance, business_obj_id),
            "expense_categories": await BackupService._dump_model(
                ExpenseCategory,
                business_obj_id,
            ),
            "expenses": await BackupService._dump_model(Expense, business_obj_id),
            "bank_accounts": await BackupService._dump_model(BankAccount, business_obj_id),
            "bank_transactions": await BackupService._dump_model(BankTransaction, business_obj_id),
            "cash_bank_transfers": await BackupService._dump_model(
                CashBankTransfer,
                business_obj_id,
            ),
            "items": await BackupService._dump_model(Item, business_obj_id),
            "inventory_transactions": await BackupService._dump_model(
                InventoryTransaction,
                business_obj_id,
            ),
            "low_stock_alerts": await BackupService._dump_model(
                LowStockAlert,
                business_obj_id,
            ),
            "invoices": [invoice.model_dump(mode="json") for invoice in invoices],
            "invoice_items": [item.model_dump(mode="json") for item in invoice_items],
            "reminders": await BackupService._dump_model(Reminder, business_obj_id),
            "devices": await BackupService._dump_model(Device, business_obj_id),
        }

        return {
            "version": BackupService._BACKUP_VERSION,
            "business_id": str(business_obj_id),
            "created_at": datetime.now(timezone.utc).isoformat(),
            "collections": collections,
            "counts": {key: len(value) for key, value in collections.items()},
        }

    @staticmethod
    async def _restore_snapshot(
        business_obj_id: PydanticObjectId,
        payload: dict[str, Any],
    ) -> dict[str, int]:
        collections = payload.get("collections")
        if not isinstance(collections, dict):
            raise ValidationError("Invalid backup format")

        existing_invoice_ids = await BackupService._fetch_business_invoice_ids(
            business_obj_id,
        )
        if existing_invoice_ids:
            await InvoiceItem.find({"invoice_id": {"$in": existing_invoice_ids}}).delete()

        for model in BackupService._BUSINESS_SCOPED_MODELS:
            await model.find(model.business_id == business_obj_id).delete()

        business_records = collections.get("business")
        if not isinstance(business_records, list) or not business_records:
            raise ValidationError("Backup is missing business data")

        restored_counts: dict[str, int] = {}

        business_model = Business.model_validate(business_records[0])
        business_model.id = business_obj_id
        existing_business = await Business.get(business_obj_id)
        if existing_business:
            await business_model.replace()
        else:
            await business_model.insert()
        restored_counts["business"] = 1

        for key, model in BackupService._RESTORE_MODEL_ORDER:
            raw_records = collections.get(key, [])
            if not isinstance(raw_records, list):
                raise ValidationError(
                    "Invalid collection data",
                    {"collection": [key]},
                )
            if not raw_records:
                restored_counts[key] = 0
                continue

            docs = [model.model_validate(record) for record in raw_records]
            await model.insert_many(docs)
            restored_counts[key] = len(docs)

        return restored_counts

    @staticmethod
    async def _dump_model(
        model: Any,
        business_obj_id: PydanticObjectId,
    ) -> list[dict[str, Any]]:
        docs = await model.find(model.business_id == business_obj_id).to_list()
        return [doc.model_dump(mode="json") for doc in docs]

    @staticmethod
    async def _fetch_business_invoice_ids(
        business_obj_id: PydanticObjectId,
    ) -> list[PydanticObjectId]:
        invoices = await Invoice.find(Invoice.business_id == business_obj_id).to_list()
        return [invoice.id for invoice in invoices if invoice.id is not None]

    @staticmethod
    def _build_backup_path(
        business_id: str,
        backup_id: str,
        backup_type: str,
        when: datetime,
    ) -> Path:
        base_dir = Path(settings.BACKUP_LOCAL_DIR)
        timestamp = when.strftime("%Y%m%dT%H%M%SZ")
        filename = f"{timestamp}_{backup_type}_{backup_id}.json"
        return base_dir / business_id / filename

    @staticmethod
    def _parse_business_id(business_id: str) -> PydanticObjectId:
        try:
            return PydanticObjectId(business_id)
        except (ValueError, TypeError):
            raise ValidationError(
                "Invalid business ID format",
                {"business_id": [f"'{business_id}' is not a valid ObjectId"]},
            )


# Singleton instance
backup_service = BackupService()
