"""Translation service for multi-language support."""
from typing import Dict, Optional

# Translation dictionaries
TRANSLATIONS: Dict[str, Dict[str, str]] = {
    "en": {
        # Common errors
        "resource_not_found": "Resource not found",
        "validation_error": "Validation error",
        "authentication_failed": "Authentication failed",
        "access_denied": "Access denied",
        "business_logic_error": "Business logic error",
        "rate_limit_exceeded": "Rate limit exceeded",
        "service_unavailable": "Service unavailable",
        "resource_conflict": "Resource conflict",
        "internal_server_error": "Internal server error",
        
        # Authentication
        "authorization_header_missing": "Authorization header missing",
        "invalid_authorization_scheme": "Invalid authorization scheme",
        "invalid_authorization_header": "Invalid authorization header format",
        "invalid_or_expired_token": "Invalid or expired token",
        "invalid_token_payload": "Invalid token payload",
        "invalid_user_id_format": "Invalid user ID format",
        "user_not_found_or_inactive": "User not found or inactive",
        "invalid_language": "Invalid language. Allowed values: en, ur, ar",
        "invalid_pin": "Invalid PIN",
        
        # Business
        "business_id_header_required": "X-Business-Id header required",
        "invalid_business_id_format": "Invalid business ID format",
        "user_no_business_access": "User does not have access to this business",
        "business_not_found_or_inactive": "Business not found or inactive",
        "required_role": "Required role: {role}",
        
        # Validation
        "invalid_business_id": "Invalid business ID format",
        "invalid_supplier_id": "Invalid supplier ID format",
        "invalid_customer_id": "Invalid customer ID format",
        "invalid_item_id": "Invalid item ID format",
        "positive_amount_required": "Amount must be positive",
        "invalid_object_id": "'{value}' is not a valid ObjectId",
        
        # Common resource messages
        "supplier_not_found": "Supplier not found",
        "customer_not_found": "Customer not found",
        "item_not_found": "Item not found",
        "business_not_found": "Business not found",
        "user_not_found": "User not found",
        "device_not_found": "Device not found or inactive",
        "expense_category_not_found": "Expense category not found",
        
        # Business logic errors
        "item_sku_exists": "Item with this SKU already exists",
        "item_barcode_exists": "Item with this barcode already exists",
        "business_phone_exists": "Business with this phone number already exists",
        "max_otp_attempts": "Maximum OTP attempts reached. Please try again after {minutes} minutes.",
        "invalid_or_expired_otp": "Invalid or expired OTP",
        "invalid_or_expired_refresh_token": "Invalid or expired refresh token",
        "invalid_refresh_token": "Invalid refresh token",
        "max_devices_reached": "Maximum device limit ({limit}) reached for this business",
        "otp_sent_successfully": "OTP sent successfully",
        "purchase_item_validation_failed": "Purchase item validation failed",
        "item_not_found_with_id": "Item {idx}: Item with ID {item_id} not found",
        "item_validation_error": "Item {idx}: Error validating item {item_id}: {error}",
        "inventory_transaction_failed": "Failed to create inventory transactions",
        "unknown_entity_type": "Unknown entity type: {entity_type}",
        "invalid_id_format": "Invalid ID format for {entity_type}",
    },
    "ar": {
        # Common errors
        "resource_not_found": "المورد غير موجود",
        "validation_error": "خطأ في التحقق",
        "authentication_failed": "فشل المصادقة",
        "access_denied": "تم رفض الوصول",
        "business_logic_error": "خطأ في منطق العمل",
        "rate_limit_exceeded": "تم تجاوز حد المعدل",
        "service_unavailable": "الخدمة غير متاحة",
        "resource_conflict": "تعارض الموارد",
        "internal_server_error": "خطأ في الخادم الداخلي",
        
        # Authentication
        "authorization_header_missing": "رأس التفويض مفقود",
        "invalid_authorization_scheme": "مخطط التفويض غير صالح",
        "invalid_authorization_header": "تنسيق رأس التفويض غير صالح",
        "invalid_or_expired_token": "رمز غير صالح أو منتهي الصلاحية",
        "invalid_token_payload": "حمولة الرمز غير صالحة",
        "invalid_user_id_format": "تنسيق معرف المستخدم غير صالح",
        "user_not_found_or_inactive": "المستخدم غير موجود أو غير نشط",
        "invalid_language": "لغة غير صالحة. القيم المسموحة: en, ur, ar",
        "invalid_pin": "رمز PIN غير صالح",
        
        # Business
        "business_id_header_required": "رأس X-Business-Id مطلوب",
        "invalid_business_id_format": "تنسيق معرف العمل غير صالح",
        "user_no_business_access": "المستخدم ليس لديه وصول إلى هذا العمل",
        "business_not_found_or_inactive": "العمل غير موجود أو غير نشط",
        "required_role": "الدور المطلوب: {role}",
        
        # Validation
        "invalid_business_id": "تنسيق معرف العمل غير صالح",
        "invalid_supplier_id": "تنسيق معرف المورد غير صالح",
        "invalid_customer_id": "تنسيق معرف العميل غير صالح",
        "invalid_item_id": "تنسيق معرف العنصر غير صالح",
        "positive_amount_required": "يجب أن يكون المبلغ موجبًا",
        "invalid_object_id": "'{value}' ليس معرف ObjectId صالحًا",
        
        # Common resource messages
        "supplier_not_found": "المورد غير موجود",
        "customer_not_found": "العميل غير موجود",
        "item_not_found": "العنصر غير موجود",
        "business_not_found": "العمل غير موجود",
        "user_not_found": "المستخدم غير موجود",
        "device_not_found": "الجهاز غير موجود أو غير نشط",
        "expense_category_not_found": "فئة المصروف غير موجودة",
        
        # Business logic errors
        "item_sku_exists": "عنصر بهذا الرمز موجود بالفعل",
        "item_barcode_exists": "عنصر بهذا الباركود موجود بالفعل",
        "business_phone_exists": "عمل بهذا الرقم موجود بالفعل",
        "max_otp_attempts": "تم الوصول إلى الحد الأقصى لمحاولات OTP. يرجى المحاولة مرة أخرى بعد {minutes} دقيقة.",
        "invalid_or_expired_otp": "OTP غير صالح أو منتهي الصلاحية",
        "invalid_or_expired_refresh_token": "رمز التحديث غير صالح أو منتهي الصلاحية",
        "invalid_refresh_token": "رمز التحديث غير صالح",
        "max_devices_reached": "تم الوصول إلى الحد الأقصى للأجهزة ({limit}) لهذا العمل",
        "otp_sent_successfully": "تم إرسال OTP بنجاح",
        "purchase_item_validation_failed": "فشل التحقق من عنصر الشراء",
        "item_not_found_with_id": "العنصر {idx}: العنصر بالمعرف {item_id} غير موجود",
        "item_validation_error": "العنصر {idx}: خطأ في التحقق من العنصر {item_id}: {error}",
        "inventory_transaction_failed": "فشل إنشاء معاملات المخزون",
        "unknown_entity_type": "نوع الكيان غير معروف: {entity_type}",
        "invalid_id_format": "تنسيق المعرف غير صالح لـ {entity_type}",
    },
    "ur": {
        # Common errors
        "resource_not_found": "وسیلہ نہیں ملا",
        "validation_error": "تصدیق کی خرابی",
        "authentication_failed": "تصدیق ناکام",
        "access_denied": "رسائی مسترد",
        "business_logic_error": "کاروباری منطق کی خرابی",
        "rate_limit_exceeded": "حد سے تجاوز",
        "service_unavailable": "سروس دستیاب نہیں",
        "resource_conflict": "وسیلہ تنازع",
        "internal_server_error": "اندرونی سرور خرابی",
        
        # Authentication
        "authorization_header_missing": "اجازت ہیڈر غائب",
        "invalid_authorization_scheme": "غیر درست اجازت سکیم",
        "invalid_authorization_header": "غیر درست اجازت ہیڈر فارمیٹ",
        "invalid_or_expired_token": "غیر درست یا ختم شدہ ٹوکن",
        "invalid_token_payload": "غیر درست ٹوکن پے لوڈ",
        "invalid_user_id_format": "غیر درست صارف ID فارمیٹ",
        "user_not_found_or_inactive": "صارف نہیں ملا یا غیر فعال",
        "invalid_language": "غیر درست زبان۔ اجازت شدہ اقدار: en, ur, ar",
        "invalid_pin": "غیر درست PIN",
        
        # Business
        "business_id_header_required": "X-Business-Id ہیڈر درکار",
        "invalid_business_id_format": "غیر درست کاروبار ID فارمیٹ",
        "user_no_business_access": "صارف کو اس کاروبار تک رسائی نہیں ہے",
        "business_not_found_or_inactive": "کاروبار نہیں ملا یا غیر فعال",
        "required_role": "مطلوب کردار: {role}",
        
        # Validation
        "invalid_business_id": "غیر درست کاروبار ID فارمیٹ",
        "invalid_supplier_id": "غیر درست سپلائر ID فارمیٹ",
        "invalid_customer_id": "غیر درست کسٹمر ID فارمیٹ",
        "invalid_item_id": "غیر درست آئٹم ID فارمیٹ",
        "positive_amount_required": "رقم مثبت ہونی چاہیے",
        "invalid_object_id": "'{value}' درست ObjectId نہیں ہے",
        
        # Common resource messages
        "supplier_not_found": "سپلائر نہیں ملا",
        "customer_not_found": "کسٹمر نہیں ملا",
        "item_not_found": "آئٹم نہیں ملا",
        "business_not_found": "کاروبار نہیں ملا",
        "user_not_found": "صارف نہیں ملا",
        "device_not_found": "ڈیوائس نہیں ملی یا غیر فعال",
        "expense_category_not_found": "خرچ کیٹیگری نہیں ملی",
        
        # Business logic errors
        "item_sku_exists": "یہ SKU والا آئٹم پہلے سے موجود ہے",
        "item_barcode_exists": "یہ بارکوڈ والا آئٹم پہلے سے موجود ہے",
        "business_phone_exists": "یہ فون نمبر والا کاروبار پہلے سے موجود ہے",
        "max_otp_attempts": "زیادہ سے زیادہ OTP کوششیں پوری ہو گئیں۔ براہ کرم {minutes} منٹ بعد دوبارہ کوشش کریں۔",
        "invalid_or_expired_otp": "غیر درست یا ختم شدہ OTP",
        "invalid_or_expired_refresh_token": "غیر درست یا ختم شدہ ریفریش ٹوکن",
        "invalid_refresh_token": "غیر درست ریفریش ٹوکن",
        "max_devices_reached": "اس کاروبار کے لیے زیادہ سے زیادہ ڈیوائس کی حد ({limit}) پوری ہو گئی",
        "otp_sent_successfully": "OTP کامیابی سے بھیج دیا گیا",
        "purchase_item_validation_failed": "خریداری آئٹم کی تصدیق ناکام",
        "item_not_found_with_id": "آئٹم {idx}: ID {item_id} والا آئٹم نہیں ملا",
        "item_validation_error": "آئٹم {idx}: آئٹم {item_id} کی تصدیق میں خرابی: {error}",
        "inventory_transaction_failed": "انوینٹری لین دین بنانے میں ناکامی",
        "unknown_entity_type": "نامعلوم انٹیٹی قسم: {entity_type}",
        "invalid_id_format": "{entity_type} کے لیے غیر درست ID فارمیٹ",
    },
}


def translate(key: str, language: str = "en", **kwargs) -> str:
    """
    Translate a key to the specified language.
    
    Args:
        key: Translation key
        language: Language code (en, ur, ar)
        **kwargs: Format arguments for the translation string
        
    Returns:
        Translated string, or the key if translation not found
    """
    if language not in TRANSLATIONS:
        language = "en"
    
    translations = TRANSLATIONS.get(language, TRANSLATIONS["en"])
    translation = translations.get(key, key)
    
    # Format the translation with kwargs if provided
    if kwargs:
        try:
            translation = translation.format(**kwargs)
        except KeyError:
            # If formatting fails, return as is
            pass
    
    return translation


def get_user_language(user: Optional[object] = None, request: Optional[object] = None) -> str:
    """
    Get user's language preference from user object or request headers.
    
    Args:
        user: User object with language_preference attribute
        request: FastAPI Request object with Accept-Language header
        
    Returns:
        Language code (en, ur, ar), defaults to 'en'
    """
    # Priority 1: User's language preference
    if user and hasattr(user, "language_preference"):
        lang = getattr(user, "language_preference", "en")
        if lang in ("en", "ur", "ar"):
            return lang
    
    # Priority 2: Accept-Language header
    if request:
        accept_language = request.headers.get("Accept-Language", "")
        # Parse Accept-Language header (e.g., "ar-SA,ar;q=0.9,en;q=0.8")
        if accept_language:
            # Extract first language code
            lang_code = accept_language.split(",")[0].split(";")[0].strip().lower()
            # Check if it's Arabic (ar, ar-*)
            if lang_code.startswith("ar"):
                return "ar"
            # Check if it's Urdu (ur, ur-*)
            elif lang_code.startswith("ur"):
                return "ur"
            # Default to English
            elif lang_code.startswith("en"):
                return "en"
    
    # Default to English
    return "en"

