import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// App Localizations for Urdu and English
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('ur', ''),
    Locale('ar', ''),
  ];

  // Translations map
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Enshaal Khata',
      'login': 'Login',
      'phone': 'Phone',
      'enter_mobile_number': 'Enter Mobile Number',
      'please_wait': 'Please Wait',
      'language_not_available': 'Language not available',
      'select_your_language': 'Select Your Language',
      'language_policy_notice': 'Language policy notice',
      'send_otp': 'Send OTP',
      'verify_otp': 'Verify OTP',
      'verifying': 'Verifying',
      'enter_login_pin': 'Enter Login PIN',
      'forgot_pin': 'Forgot PIN?',
      'reset_pin_from_settings': 'Reset PIN from Settings',
      'use_biometric': 'Use Biometric',
      'dashboard': 'Dashboard',
      'cash_feature': 'Cash',
      'stock': 'Stock',
      'invoices': 'Invoices',
      'customers': 'Customers',
      'suppliers': 'Suppliers',
      'expenses': 'Expenses',
      'staff': 'Staff',
      'banks': 'Banks',
      'reports': 'Reports',
      'report': 'Report',
      'set_date': 'Set Date',
      'sms': 'SMS',
      'entries': 'Entries',
      'entry_detail': 'Entry Detail',
      'running_balance': 'Running Balance',
      'search': 'Search',
      'filter_all': 'All',
      'filter_today': 'Today',
      'filter_this_month': 'This month',
      'filter_last_two_months': 'Last 2 months',
      'filter_this_year': 'This year',
      'filter_custom_range': 'Custom range',
      'search_customers': 'Search customers',
      'you_gave': 'You Gave',
      'you_got': 'You Got',
      'you_will_get': 'You will get',
      'you_will_give': 'You will give',
      'view_settings_hint': 'Click here to view settings',
      'delete_customer': 'Delete Customer',
      'delete_customer_confirm':
          'Are you sure you want to delete {name}? This action cannot be undone.',
      'deleting_customer': 'Deleting customer...',
      'customer_deleted_successfully': 'Customer deleted successfully',
      'failed_to_delete_customer': 'Failed to delete customer',
      'customer_name_exists': 'Customer name already exists',
      'feature_coming_soon': 'Feature coming soon',
      'add': 'Add',
      'create': 'Create',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'name': 'Name',
      'amount': 'Amount',
      'date': 'Date',
      'description': 'Description',
      'total': 'Total',
      'balance': 'Balance',
      'hide_balance': 'Hide Balance',
      'show_balance': 'Show Balance',
      'no_data': 'No data available',
      'loading': 'Loading...',
      'error': 'Error',
      'request_timed_out': 'Request timed out. Please try again.',
      'something_went_wrong': 'Something went wrong',
      'success': 'Success',
      'share': 'Share',
      'whatsapp': 'WhatsApp',
      'invoice': 'Invoice',
      'invoice_number': 'Invoice Number',
      'invoice_type': 'Invoice Type',
      'cash': 'Cash',
      'credit': 'Credit',
      'paid': 'Paid',
      'due': 'Due',
      'reminders': 'Reminders',
      'devices': 'Devices',
      'settings': 'Settings',
      'logout': 'Logout',
      'welcome_back': 'Welcome Back!',
      'welcome_to_enshaal_khata': 'Welcome to Enshaal Khata',
      'manage_business': 'Manage your business accounts efficiently',
      'manage_business_easily': 'Manage your business accounts easily',
      'get_started': 'Get Started',
      'otp_info': 'We will send you a 6-digit OTP to verify your phone number',
      'otp_sent_successfully': 'OTP sent successfully',
      'resend_otp': 'Resend OTP',
      'resend_in': 'Resend in',
      'seconds': 'seconds',
      'enter_verification_code': 'Enter Verification Code',
      'we_sent_code_to': 'We sent a 6-digit code to',
      'verification_code': 'Verification Code',
      'didnt_receive_code': 'Didn\'t receive the code?',
      'todays_summary': 'Today\'s Summary',
      'cash_balance': 'Cash Balance',
      'todays_sales': 'Today\'s Sales',
      'quick_actions': 'Quick Actions',
      'home': 'Home',
      'more': 'More',
      'overview': 'Overview',
      'total_sales': 'Total Sales',
      'cash_in': 'Cash In',
      'cash_out': 'Cash Out',
      'in_label': 'In',
      'out_label': 'Out',
      'synced': 'Synced',
      'pending': 'Pending',
      'failed': 'Failed',
      'offline': 'Offline',
      'sync_status': 'Sync Status',
      'sync_now': 'Sync Now',
      'retry_failed': 'Retry Failed',
      'offline_data_may_be_incomplete': 'Offline data may be incomplete.',
      'online_required': 'Internet connection required.',
      'management': 'Management',
      'item': 'Item',
      'transaction': 'Transaction',
      'type': 'Type',
      'optional': 'Optional',
      'source': 'Source',
      'remarks': 'Remarks',
      'failed_to_load_data': 'Failed to load data',
      'retry': 'Retry',
      'todays_balance': "Today's Balance",
      'start_by_adding_cash_transaction':
          'Start by adding your first cash transaction',
      'transaction_type': 'Transaction Type',
      'transaction_created_successfully': 'Transaction created successfully',
      'additional_notes': 'Additional notes',
      'example_sales_purchase': 'e.g., Sales, Purchase',
      'add_first_customer': 'Add your first customer to get started',
      'switch_business': 'Switch Business',
      'create_new_business': 'Create New Business',
      'select_business': 'Select Business',
      'date_range': 'Date Range',
      'sales_report': 'Sales Report',
      'cash_flow_report': 'Cash Flow Report',
      'expense_report': 'Expense Report',
      'stock_report': 'Stock Report',
      'profit_loss_report': 'Profit & Loss Report',
      'refresh': 'Refresh',
      'filter': 'Filter',
      'add_transaction': 'Add Transaction',
      'add_customer': 'Add Customer',
      'add_customers': 'Add Customers',
      'add_entries_maintain_khata': 'Add entries, maintain khata',
      'send_payment_reminders': 'Send payment reminders',
      'create_invoice': 'Create Invoice',
      'no_invoices': 'No Invoices',
      'no_customers': 'No Customers',
      'no_transactions': 'No Transactions',
      'mark_resolved': 'Mark Resolved',
      'resolved': 'Resolved',
      'overdue': 'Overdue',
      'khata': 'Khata',
      'business': 'Business',
      'create_business': 'Create Business',
      'business_label': 'business',
      'set_up_digi_khata': 'Set Up DigiKhata',
      'finish': 'Finish',
      'next': 'Next',
      'start': 'Start',
      'owner_name': 'Owner Name',
      'owner_name_hint': 'Enter owner name',
      'business_name_hint': 'Enter business name',
      'business_category_question':
          'What category does your business fall under?',
      'enter_business_category': 'Enter business category',
      'select_business_category': 'Please select a business category',
      'business_type_question': 'What type of business is this?',
      'enter_business_type': 'Enter business type',
      'enter_business_type_error': 'Please enter business type',
      'business_address': 'Business Address',
      'google_location': 'Google Location',
      'location_not_available': 'Location not available',
      'address_line_hint': 'Enter address line',
      'area_hint': 'Enter area',
      'city_hint': 'Enter city',
      'congratulations': 'Congratulations!',
      'business_ready': 'Your {business} is ready!',
      'language': 'Language',
      'language_settings': 'Language Settings',
      'select_language': 'Select Language',
      'english': 'English',
      'urdu': 'Urdu',
      'arabic': 'Arabic',
      'business_name': 'Business Name',
      'email_optional': 'Email (optional)',
      'address_optional': 'Address (optional)',
      'business_type': 'Business Type',
      'custom_business_type': 'Custom Business Type',
      'language_preference': 'Language Preference',
      'max_devices': 'Max Devices',
      'creating': 'Creating...',
      'please_enter_custom_business_type': 'Please enter custom business type',
      'retail_shop': 'Retail Shop',
      'wholesale': 'Wholesale',
      'services': 'Services',
      'manufacturing': 'Manufacturing',
      'restaurant_food': 'Restaurant/Food',
      'other': 'Other',
      'stock_management': 'Stock Management',
      'add_stock_item': 'Add Stock Item',
      'stock_item_created_successfully': 'Stock item created successfully',
      'item_name': 'Item Name',
      'enter_item_name': 'Enter item name',
      'sku_optional': 'SKU (Optional)',
      'sku_code': 'SKU code',
      'barcode_optional': 'Barcode (Optional)',
      'barcode': 'Barcode',
      'purchase_price': 'Purchase Price',
      'sale_price': 'Sale Price',
      'unit': 'Unit',
      'pieces': 'Pieces (pcs)',
      'kilogram': 'Kilogram (kg)',
      'liter': 'Liter',
      'meter': 'Meter',
      'box': 'Box',
      'pack': 'Pack',
      'opening_stock': 'Opening Stock',
      'min_stock_threshold_optional': 'Min Stock Threshold (Optional)',
      'alert_when_stock_below': 'Alert when stock is below this',
      'description_optional': 'Description (Optional)',
      'item_description': 'Item description',
      'create_item': 'Create Item',
      'no_stock_items': 'No Stock Items',
      'start_by_adding_stock_item': 'Start by adding your first stock item',
      'low_stock': 'Low Stock',
      'stock_value': 'Stock Value',
      'stock_in': 'Stock In',
      'stock_out': 'Stock Out',
      'stock_in_success': 'Stock added successfully',
      'stock_out_success': 'Stock removed successfully',
      'confirm_stock_removal': 'Confirm Stock Removal',
      'remove': 'Remove',
      'remove_stock': 'Remove Stock',
      'add_stock': 'Add Stock',
      'unit_price': 'Unit Price',
      'purchase_price_per_unit': 'Purchase price per unit',
      'sale_price_per_unit': 'Sale price per unit',
      'quantity': 'Quantity',
      'enter_quantity': 'Enter quantity',
      'remarks_optional': 'Remarks (Optional)',
      'required': 'is required',
      'enter_amount': 'Enter amount',
      'create_first_invoice': 'Create your first invoice to get started',
      'share_invoice': 'Share Invoice',
      'other_apps': 'Other Apps',
      'total_amount': 'Total Amount',
      'filter_invoices': 'Filter Invoices',
      'start_date': 'Start Date',
      'end_date': 'End Date',
      'select_date': 'Select date',
      'all': 'All',
      'apply': 'Apply',
      'error_sharing_invoice': 'Error sharing invoice',
      'whatsapp_opened_attach_pdf':
          'WhatsApp opened. Please attach the PDF file manually.',
      'customer': 'Customer',
      'customer_name': 'Customer Name',
      'customer_created_successfully': 'Customer created successfully',
      'save_customer': 'Save Customer',
      'customer_required': 'Customer is required for all invoices',
      'select_customer': 'Select Customer',
      'search_customer': 'Search customer...',
      'no_customers_found': 'No customers found',
      'no_results_found': 'No results found',
      'select_from_stock': 'Select from Stock',
      'select_stock_item': 'Select Stock Item',
      'no_stock_items_available':
          'No stock items available. Enter item details manually.',
      'or': 'OR',
      'price': 'Price',
      'supplier': 'Supplier',
      'supplier_name': 'Supplier Name',
      'add_supplier': 'Add Supplier',
      'add_suppliers': 'Add Suppliers',
      'add_first_supplier': 'Add your first supplier to get started',
      'supplier_created_successfully': 'Supplier created successfully',
      'save_supplier': 'Save Supplier',
      'no_suppliers': 'No Suppliers',
      'tax_amount': 'Tax Amount',
      'discount_amount': 'Discount Amount',
      'manual_amount': 'Manual Amount',
      'manual_amount_required': 'Please enter a manual amount',
      'manual_mode_items_ignored':
          'Items added will be ignored in manual amount mode.',
      'items': 'Items',
      'add_item': 'Add Item',
      'no_items_added': 'No items added. Click "Add Item" to add items.',
      'please_add_item': 'Please add at least one item to the invoice',
      'please_fill_required_fields':
          'Please fill in all required fields correctly',
      'item_name_required': 'Item name is required',
      'valid_quantity_required': 'Valid quantity required',
      'valid_price_required': 'Valid price required',
      'select_from_stock_optional': 'Select from Stock (Optional)',
      'or_enter_manually_below': 'Or enter manually below',
      'enter_manually': 'Enter manually',
      'insufficient_stock': 'Insufficient stock. Available',
      'cannot_add_item_insufficient_stock':
          'Cannot add item: Insufficient stock available',
      'failed_to_add_item': 'Failed to add item',
      'remove_item_confirm':
          'Are you sure you want to remove "{item}" from this invoice?',
      'subtotal': 'Subtotal',
      'error_loading_pdf': 'Error loading PDF',
      'failed_to_load_transactions': 'Failed to load transactions',
      'payment_recorded_successfully': 'Payment recorded successfully',
      'failed_to_record_payment': 'Failed to record payment',
      'current_balance': 'Current Balance',
      'outstanding_dues': 'Outstanding Dues',
      'no_transactions_yet': 'No transactions yet',
      'credit_invoice': 'Credit Invoice',
      'payment_received': 'Payment Received',
      'record_payment': 'Record Payment',
      'link_to_invoice_optional': 'Link to Invoice (Optional)',
      'select_invoice_or_general': 'Select invoice or leave as general payment',
      'select_invoice_helper':
          'Select an invoice to link this payment, or leave empty for general payment',
      'general_payment': 'General Payment (Not linked to invoice)',
      'unpaid': 'Unpaid',
      'enter_payment_amount': 'Enter payment amount',
      'please_enter_payment_amount': 'Please enter a payment amount',
      'please_enter_valid_amount': 'Please enter a valid amount greater than 0',
      'record': 'Record',
      'no_route_for': 'No route for {route}',
      'phone_hint': '923001234567',
      'otp': 'OTP',
      'otp_hint': '123456',
      'bank_accounts': 'Bank Accounts',
      'add_bank_account': 'Add Bank Account',
      'total_bank_balance': 'Total Bank Balance',
      'transfer': 'Transfer',
      'cash_to_bank': 'Cash to Bank',
      'bank_to_cash': 'Bank to Cash',
      'select_bank_account': 'Select bank account',
      'transfer_completed': 'Transfer completed successfully',
      'add_bank': 'Add Bank',
      'add_banks': 'Add Banks',
      'manage_bank_balance': 'Manage bank balance',
      'bank_account_created_successfully': 'Bank account created successfully',
      'bank_name': 'Bank Name',
      'bank_name_hint': 'ABC Bank',
      'account_number': 'Account Number',
      'account_number_hint': '1234567890',
      'account_holder_name_optional': 'Account Holder Name (optional)',
      'account_holder_name_hint': 'John Doe',
      'branch_optional': 'Branch (optional)',
      'branch_hint': 'Main Branch',
      'ifsc_code_optional': 'IFSC Code (optional)',
      'ifsc_code_hint': 'ABCD0123456',
      'account_type': 'Account Type',
      'savings': 'Savings',
      'current': 'Current',
      'opening_balance': 'Opening Balance',
      'add_account': 'Add Account',
      'revoke_device': 'Revoke Device',
      'revoke_device_confirmation':
          'Are you sure you want to revoke this device? It will no longer be able to access this business account.',
      'revoke': 'Revoke',
      'device_revoked_successfully': 'Device revoked successfully',
      'failed_to_revoke_device': 'Failed to revoke device: {error}',
      'paired_devices': 'Paired Devices',
      'pair_device': 'Pair Device',
      'device_pairing': 'Device Pairing',
      'failed_to_generate_pairing_token':
          'Failed to generate pairing token: {error}',
      'device_paired_successfully': 'Device paired successfully!',
      'failed_to_pair_device': 'Failed to pair device: {error}',
      'qr_scanner_not_available_on_web':
          'QR Scanner not available on web platform',
      'add_expense': 'Add Expense',
      'expense_created_successfully': 'Expense created successfully',
      'create_category': 'Create Category',
      'expense_category': 'Expense Category',
      'payment_mode': 'Payment Mode',
      'bank': 'Bank',
      'create_expense_category': 'Create Expense Category',
      'category_name': 'Category Name',
      'category_name_hint': 'e.g., Office Supplies, Travel, Utilities',
      'category_description_hint': 'Additional details about this category',
      'category_created_successfully': 'Category created successfully',
      'security': 'Security',
      'appearance': 'Appearance',
      'data_management': 'Data Management',
      'about': 'About',
      'legal': 'Legal',
      'app_lock': 'App Lock',
      'require_pin_to_unlock': 'Require PIN to unlock app',
      'biometric_authentication': 'Biometric Authentication',
      'use_fingerprint_or_face_id': 'Use fingerprint or face ID',
      'theme': 'Theme',
      'system': 'System',
      'light': 'Light',
      'dark': 'Dark',
      'currency': 'Currency',
      'clear_cache': 'Clear Cache',
      'clear_cached_data_and_images': 'Clear cached data and images',
      'export_data': 'Export Data',
      'export_business_data': 'Export your business data',
      'app_version': 'App Version',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'logout_confirm_message': 'Are you sure you want to logout?',
      'app_lock_enabled': 'App lock enabled',
      'app_lock_disabled': 'App lock disabled',
      'enter_pin_to_disable_app_lock': 'Enter PIN to disable app lock',
      'biometric_not_available':
          'Biometric authentication not available on this device',
      'enable_biometric_authentication': 'Enable biometric authentication',
      'set_pin': 'Set PIN',
      'enter_pin': 'Enter 4-digit PIN',
      'pin_hint': '0000',
      'set': 'Set',
      'verify': 'Verify',
      'language_updated': 'Language updated',
      'theme_updated': 'Theme updated',
      'currency_updated': 'Currency updated. App logo will reflect the change.',
      'clear_cache_message':
          'This will clear all cached data. You will need to sync again. Continue?',
      'cache_cleared_successfully': 'Cache cleared successfully',
      'data_export_coming_soon': 'Data export feature coming soon',
      'clear': 'Clear',
      'add_staff': 'Add Staff',
      'staff_member_created_successfully': 'Staff member created successfully',
      'role': 'Role',
      'record_salary': 'Record Salary',
      'salary_recorded_successfully': 'Salary recorded successfully',
      'select_staff': 'Select staff member',
      'purchase_recorded_successfully': 'Purchase recorded successfully',
      'record_purchase': 'Record Purchase',
      'record_purchase_for': 'Record Purchase - {supplier}',
      'purchase_amount': 'Purchase Amount',
      'manage_purchases': 'Manage purchases',
      'resolve_sync_conflicts': 'Resolve Sync Conflicts',
      'all_conflicts_resolved_successfully':
          'All conflicts resolved successfully',
      'this_field': 'This field',
      'field_is_required': '{field} is required',
      'invalid_phone_number_format': 'Invalid phone number format',
      'phone_digits_only': 'Phone number must contain only digits',
      'otp_required': 'OTP is required',
      'otp_must_be_6_digits': 'OTP must be 6 digits',
      'otp_digits_only': 'OTP must contain only digits',
      'pin_required': 'PIN is required',
      'pin_must_be_4_digits': 'PIN must be 4 digits',
      'pin_digits_only': 'PIN must contain only digits',
      'email_required': 'Email is required',
      'invalid_email_address': 'Please enter a valid email address',
      'amount_required': 'Amount is required',
      'invalid_amount': 'Please enter a valid amount',
      'amount_must_be_greater_than_zero': 'Amount must be greater than 0',
      'quantity_required': 'Quantity is required',
      'invalid_quantity': 'Please enter a valid quantity',
      'quantity_must_be_greater_than_zero': 'Quantity must be greater than 0',
      'field_must_be_at_least': '{field} must be at least {min} characters',
      'field_must_be_at_most': '{field} must be at most {max} characters',
      'field_cannot_be_negative': '{field} cannot be negative',
      'no_bank_accounts': 'No Bank Accounts',
      'add_first_bank_account': 'Add your first bank account',
      'no_devices': 'No Devices',
      'pair_device_to_get_started': 'Pair a device to get started',
      'unknown_device': 'Unknown Device',
      'active': 'Active',
      'inactive': 'Inactive',
      'last_sync': 'Last sync',
      'generate_qr': 'Generate QR',
      'scan_qr': 'Scan QR',
      'generate_pairing_qr_code': 'Generate Pairing QR Code',
      'generate_qr_description':
          'Generate a QR code that other devices can scan to pair with this business account.',
      'pairing_token': 'Pairing Token',
      'generate_qr_code': 'Generate QR Code',
      'use_mobile_app_to_scan': 'Please use the mobile app to scan QR codes',
      'scan_qr_from_another_device': 'Scan the QR code from another device',
      'point_camera_at_qr':
          'Point your camera at the QR code displayed on the other device',
      'no_categories_available': 'No categories available.',
      'no_expenses': 'No Expenses',
      'start_tracking_expenses': 'Start tracking your business expenses',
      'expense': 'Expense',
      'items_optional': 'Items (Optional)',
      'no_items_added_for_purchase':
          'No items added. You can add items or just record the total amount.',
      'failed_to_record_purchase': 'Failed to record purchase',
      'current_stock': 'Current Stock',
      'from': 'from',
      'purchase': 'Purchase',
      'payment_made': 'Payment Made',
      'no_staff_members': 'No Staff Members',
      'add_first_staff_member': 'Add your first staff member',
      'staff_name': 'Staff Name',
      'name_hint': 'John Doe',
      'role_optional': 'Role (optional)',
      'role_hint': 'Manager, Salesperson, etc.',
      'phone_optional': 'Phone (optional)',
      'email_hint': 'staff@example.com',
      'address_hint': 'House #123, Street, City',
      'supplier_name_hint': 'ABC Suppliers',
      'customer_name_hint': 'Ali Traders',
      'sync_conflicts_detected': 'Sync Conflicts Detected',
      'sync_conflicts_description':
          'The server has newer versions of these items. Choose which version to keep for each conflict.',
      'no_conflicts_to_resolve': 'No conflicts to resolve',
      'resolve_all_conflicts': 'Resolve All Conflicts',
      'failed_to_resolve_conflicts': 'Failed to resolve conflicts: {error}',
      'id_label': 'ID: {id}',
      'server_version': 'Server Version',
      'your_version': 'Your Version',
      'updated': 'Updated',
      'closing_balance': 'Closing Balance',
      'total_inflow': 'Total Inflow',
      'total_outflow': 'Total Outflow',
      'net_cash_flow': 'Net Cash Flow',
      'transactions': 'Transactions',
      'no_transactions_found': 'No transactions found',
      'total_expenses': 'Total Expenses',
      'by_category': 'By Category',
      'uncategorized': 'Uncategorized',
      'percent_of_total': '{percent}% of total',
      'daily_breakdown': 'Daily Breakdown',
      'total_items': 'Total Items',
      'total_value': 'Total Value',
      'out_of_stock': 'Out of Stock',
      'low_stock_items_title': 'Low Stock Items',
      'all_items': 'All Items',
      'current_label': 'Current',
      'min_label': 'Min',
      'stock_label': 'Stock',
      'total_revenue': 'Total Revenue',
      'net_profit_loss': 'Net Profit / Loss',
      'profit_margin_label': 'Profit Margin: {percent}%',
      'revenue_breakdown': 'Revenue Breakdown',
      'expense_breakdown': 'Expense Breakdown',
      'average_order_value': 'Average Order Value',
      'period_breakdown': '{period} Breakdown',
      'cash_label': 'Cash',
      'credit_label': 'Credit',
      'invoice_count': '{count} invoice(s)',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'week_of': 'Week of',
      'reminder_resolved': 'Reminder resolved',
      'failed_to_resolve_reminder': 'Failed to resolve reminder: {error}',
      'no_reminders': 'No Reminders',
      'all_reminders_resolved': 'All reminders are resolved',
      'unknown': 'Unknown',
      'customer_credit': 'Customer Credit',
      'supplier_payment': 'Supplier Payment',
      'due_date': 'Due Date',
    },
    'ur': {
      'app_name': 'انشال کھاتا',
      'login': 'لاگ ان',
      'phone': 'فون',
      'send_otp': 'OTP بھیجیں',
      'verify_otp': 'OTP کی تصدیق کریں',
      'dashboard': 'ڈیش بورڈ',
      'cash_feature': 'نقد',
      'stock': 'اسٹاک',
      'invoices': 'انوائس',
      'customers': 'گاہک',
      'suppliers': 'سپلائرز',
      'expenses': 'اخراجات',
      'staff': 'عملہ',
      'banks': 'بینک',
      'reports': 'رپورٹس',
      'report': 'رپورٹ',
      'set_date': 'تاریخ مقرر کریں',
      'sms': 'ایس ایم ایس',
      'entries': 'اندراجات',
      'entry_detail': 'انٹری تفصیل',
      'running_balance': 'جاری بیلنس',
      'search': 'تلاش کریں',
      'filter_all': '??',
      'filter_today': '??',
      'filter_this_month': '?? ?????',
      'filter_last_two_months': '????? 2 ?????',
      'filter_this_year': '?? ???',
      'filter_custom_range': '???? ????? ????? ????',
      'search_customers': '???? ???? ????',
      'you_gave': 'آپ نے دیا',
      'you_got': 'آپ نے لیا',
      'you_will_get': 'آپ کو ملے گا',
      'you_will_give': 'آپ دیں گے',
      'view_settings_hint': 'سیٹنگز دیکھنے کے لیے یہاں کلک کریں',
      'delete_customer': 'گاہک حذف کریں',
      'delete_customer_confirm':
          'کیا آپ واقعی {name} کو حذف کرنا چاہتے ہیں؟ یہ عمل واپس نہیں ہو سکتا۔',
      'deleting_customer': 'گاہک حذف کیا جا رہا ہے...',
      'customer_deleted_successfully': 'گاہک کامیابی سے حذف ہو گیا',
      'failed_to_delete_customer': 'گاہک کو حذف کرنے میں ناکامی',
      'customer_name_exists': '???? ?? ??? ???? ?? ????? ??',
      'feature_coming_soon': 'فیچر جلد آ رہا ہے',
      'add': 'شامل کریں',
      'create': 'بنائیں',
      'save': 'محفوظ کریں',
      'cancel': 'منسوخ',
      'delete': 'حذف کریں',
      'edit': 'ترمیم',
      'name': 'نام',
      'amount': 'رقم',
      'date': 'تاریخ',
      'description': 'تفصیل',
      'total': 'کل',
      'balance': 'بیلنس',
      'hide_balance': 'بیلنس چھپائیں',
      'show_balance': 'بیلنس دکھائیں',
      'no_data': 'کوئی ڈیٹا دستیاب نہیں',
      'loading': 'لوڈ ہو رہا ہے...',
      'error': 'خرابی',
      'request_timed_out': '??????? ?? ??? ??? ?? ???? ?????? ???? ?????',
      'something_went_wrong': '??? ??? ?? ???',
      'success': 'کامیابی',
      'share': 'شیئر کریں',
      'whatsapp': 'واٹس ایپ',
      'invoice': 'انوائس',
      'invoice_number': 'انوائس نمبر',
      'invoice_type': 'انوائس کی قسم',
      'cash': 'نقد',
      'credit': 'کریڈٹ',
      'paid': 'ادا شدہ',
      'due': 'واجب الادا',
      'reminders': 'یاد دہانیاں',
      'devices': 'آلات',
      'settings': 'ترتیبات',
      'logout': 'لاگ آؤٹ',
      'welcome_back': 'خوش آمدید!',
      'welcome_to_enshaal_khata': 'انشال کھاتا میں خوش آمدید',
      'manage_business': 'اپنے کاروباری اکاؤنٹس کو موثر طریقے سے منظم کریں',
      'manage_business_easily': 'اپنے کاروباری اکاؤنٹس کو آسانی سے منظم کریں',
      'get_started': 'شروع کریں',
      'otp_info': 'ہم آپ کے فون نمبر کی تصدیق کے لیے 6 ہندسوں کا OTP بھیجیں گے',
      'otp_sent_successfully': 'OTP کامیابی سے بھیج دیا گیا',
      'resend_otp': 'OTP دوبارہ بھیجیں',
      'resend_in': 'دوبارہ بھیجیں',
      'seconds': 'سیکنڈ',
      'enter_verification_code': 'تصدیقی کوڈ درج کریں',
      'we_sent_code_to': 'ہم نے 6 ہندسوں کا کوڈ بھیجا',
      'verification_code': 'تصدیقی کوڈ',
      'didnt_receive_code': 'کوڈ موصول نہیں ہوا؟',
      'todays_summary': 'آج کا خلاصہ',
      'cash_balance': 'نقد بیلنس',
      'todays_sales': 'آج کی فروخت',
      'quick_actions': 'فوری اعمال',
      'home': 'ہوم',
      'more': 'مزید',
      'overview': 'جائزہ',
      'total_sales': 'کل فروخت',
      'cash_in': 'نقد آمد',
      'cash_out': 'نقد خرچ',
      'in_label': 'ان',
      'out_label': 'آؤٹ',
      'synced': 'ہم آہنگ',
      'pending': 'زیر التواء',
      'failed': 'Failed',
      'sync_status': 'Sync Status',
      'sync_now': 'Sync Now',
      'retry_failed': 'Retry Failed',
      'offline': 'آف لائن',
      'offline_data_may_be_incomplete': '?? ???? ???? ???? ???? ?? ?????',
      'online_required': '??????? ????? ????? ???',
      'management': 'انتظام',
      'item': 'آئٹم',
      'transaction': 'لین دین',
      'type': 'قسم',
      'optional': 'اختیاری',
      'source': 'ماخذ',
      'remarks': 'نوٹس',
      'failed_to_load_data': 'ڈیٹا لوڈ نہیں ہو سکا',
      'retry': 'دوبارہ کوشش',
      'todays_balance': 'آج کا بیلنس',
      'start_by_adding_cash_transaction': 'اپنا پہلا نقد لین دین شامل کریں',
      'transaction_type': 'لین دین کی قسم',
      'transaction_created_successfully': 'لین دین کامیابی سے بن گیا',
      'additional_notes': 'اضافی نوٹس',
      'example_sales_purchase': 'مثلاً، فروخت، خرید',
      'add_first_customer': 'اپنا پہلا گاہک شامل کریں',
      'switch_business': 'کاروبار تبدیل کریں',
      'create_new_business': 'نیا کاروبار بنائیں',
      'select_business': 'کاروبار منتخب کریں',
      'date_range': 'تاریخ کی حد',
      'sales_report': 'سیلز رپورٹ',
      'cash_flow_report': 'کیش فلو رپورٹ',
      'expense_report': 'اخراجات رپورٹ',
      'stock_report': 'اسٹاک رپورٹ',
      'profit_loss_report': 'نفع و نقصان رپورٹ',
      'refresh': 'تازہ کریں',
      'filter': 'فلٹر',
      'add_transaction': 'لین دین شامل کریں',
      'add_customer': 'گاہک شامل کریں',
      'add_customers': 'گاہک شامل کریں',
      'add_entries_maintain_khata': 'انٹریز شامل کریں، کھاتا برقرار رکھیں',
      'send_payment_reminders': 'ادائیگی کی یاد دہانیاں بھیجیں',
      'create_invoice': 'انوائس بنائیں',
      'no_invoices': 'کوئی انوائس نہیں',
      'no_customers': 'کوئی گاہک نہیں',
      'no_transactions': 'کوئی لین دین نہیں',
      'mark_resolved': 'حل شدہ نشان زد کریں',
      'resolved': 'حل شدہ',
      'overdue': 'زائد المیعاد',
      'khata': 'کھاتا',
      'business': 'کاروبار',
      'create_business': 'نیا کاروبار بنائیں',
      'language': 'زبان',
      'language_settings': 'زبان کی ترتیبات',
      'select_language': 'زبان منتخب کریں',
      'english': 'انگریزی',
      'urdu': 'اردو',
      'arabic': 'عربی',
      'business_name': 'کاروبار کا نام',
      'email_optional': 'ای میل (اختیاری)',
      'address_optional': 'پتہ (اختیاری)',
      'business_type': 'کاروبار کی قسم',
      'custom_business_type': 'مخصوص کاروبار کی قسم',
      'language_preference': 'زبان کی ترجیح',
      'max_devices': 'زیادہ سے زیادہ آلات',
      'creating': 'بنایا جا رہا ہے...',
      'please_enter_custom_business_type':
          'براہ کرم مخصوص کاروبار کی قسم درج کریں',
      'retail_shop': 'ریٹیل شاپ',
      'wholesale': 'ہول سیل',
      'services': 'خدمات',
      'manufacturing': 'مینوفیکچرنگ',
      'restaurant_food': 'ریسٹورانٹ/کھانا',
      'other': 'دیگر',
      'stock_management': 'اسٹاک مینجمنٹ',
      'add_stock_item': 'اسٹاک آئٹم شامل کریں',
      'stock_item_created_successfully': 'اسٹاک آئٹم کامیابی سے بن گیا',
      'item_name': 'آئٹم کا نام',
      'enter_item_name': 'آئٹم کا نام درج کریں',
      'sku_optional': 'SKU (اختیاری)',
      'sku_code': 'SKU کوڈ',
      'barcode_optional': 'بارکوڈ (اختیاری)',
      'barcode': 'بارکوڈ',
      'purchase_price': 'خریداری قیمت',
      'sale_price': 'فروخت قیمت',
      'unit': 'یونٹ',
      'pieces': 'عدد (pcs)',
      'kilogram': 'کلوگرام (kg)',
      'liter': 'لیٹر',
      'meter': 'میٹر',
      'box': 'باکس',
      'pack': 'پیک',
      'opening_stock': 'ابتدائی اسٹاک',
      'min_stock_threshold_optional': 'کم از کم اسٹاک حد (اختیاری)',
      'alert_when_stock_below': 'جب اسٹاک اس سے کم ہو تو الرٹ کریں',
      'description_optional': 'تفصیل (اختیاری)',
      'item_description': 'آئٹم کی تفصیل',
      'create_item': 'آئٹم بنائیں',
      'no_stock_items': 'کوئی اسٹاک آئٹم نہیں',
      'start_by_adding_stock_item': 'اپنا پہلا اسٹاک آئٹم شامل کریں',
      'low_stock': 'کم اسٹاک',
      'stock_value': 'اسٹاک ویلیو',
      'stock_in': 'اسٹاک اِن',
      'stock_out': 'اسٹاک آؤٹ',
      'stock_in_success': 'اسٹاک کامیابی سے شامل ہوا',
      'stock_out_success': 'اسٹاک کامیابی سے نکالا گیا',
      'confirm_stock_removal': 'اسٹاک نکالنے کی تصدیق',
      'remove': 'ہٹائیں',
      'remove_stock': 'اسٹاک ہٹائیں',
      'add_stock': 'اسٹاک شامل کریں',
      'unit_price': 'یونٹ قیمت',
      'purchase_price_per_unit': 'فی یونٹ خریداری قیمت',
      'sale_price_per_unit': 'فی یونٹ فروخت قیمت',
      'quantity': 'مقدار',
      'enter_quantity': 'مقدار درج کریں',
      'remarks_optional': 'نوٹس (اختیاری)',
      'required': 'ضروری ہے',
      'enter_amount': 'رقم درج کریں',
      'create_first_invoice': 'اپنا پہلا انوائس بنائیں',
      'share_invoice': 'انوائس شیئر کریں',
      'other_apps': 'دیگر ایپس',
      'total_amount': 'کل رقم',
      'filter_invoices': 'انوائس فلٹر کریں',
      'start_date': 'شروع کی تاریخ',
      'end_date': 'اختتام کی تاریخ',
      'select_date': 'تاریخ منتخب کریں',
      'all': 'سب',
      'apply': 'لاگو کریں',
      'error_sharing_invoice': 'انوائس شیئر کرنے میں خرابی',
      'whatsapp_opened_attach_pdf':
          'واٹس ایپ کھل گیا۔ براہ کرم پی ڈی ایف فائل دستی طور پر منسلک کریں۔',
      'customer': 'گاہک',
      'customer_name': 'گاہک کا نام',
      'customer_created_successfully': 'گاہک کامیابی سے بن گیا',
      'save_customer': 'گاہک محفوظ کریں',
      'customer_required': 'تمام انوائسز کے لیے گاہک ضروری ہے',
      'select_customer': 'گاہک منتخب کریں',
      'search_customer': 'گاہک تلاش کریں...',
      'no_customers_found': 'کوئی گاہک نہیں ملا',
      'no_results_found': 'کوئی نتیجہ نہیں ملا',
      'select_from_stock': 'اسٹاک سے منتخب کریں',
      'select_stock_item': 'اسٹاک آئٹم منتخب کریں',
      'no_stock_items_available':
          'کوئی اسٹاک آئٹم دستیاب نہیں۔ دستی طور پر آئٹم کی تفصیلات درج کریں۔',
      'or': 'یا',
      'price': 'قیمت',
      'supplier': 'سپلائر',
      'supplier_name': 'سپلائر کا نام',
      'add_supplier': 'سپلائر شامل کریں',
      'add_suppliers': 'سپلائر شامل کریں',
      'add_first_supplier': 'اپنا پہلا سپلائر شامل کریں',
      'supplier_created_successfully': 'سپلائر کامیابی سے بن گیا',
      'save_supplier': 'سپلائر محفوظ کریں',
      'no_suppliers': 'کوئی سپلائر نہیں',
      'tax_amount': 'ٹیکس رقم',
      'discount_amount': 'ڈسکاؤنٹ رقم',
      'manual_amount': 'دستی رقم',
      'manual_amount_required': 'براہ کرم دستی رقم درج کریں',
      'manual_mode_items_ignored':
          'دستی رقم موڈ میں شامل آئٹمز نظر انداز کیے جائیں گے۔',
      'items': 'آئٹمز',
      'add_item': 'آئٹم شامل کریں',
      'no_items_added': 'کوئی آئٹم شامل نہیں۔ "آئٹم شامل کریں" پر کلک کریں۔',
      'please_add_item': 'براہ کرم انوائس میں کم از کم ایک آئٹم شامل کریں',
      'please_fill_required_fields': 'براہ کرم تمام ضروری فیلڈز صحیح بھرें',
      'item_name_required': 'آئٹم کا نام ضروری ہے',
      'valid_quantity_required': 'درست مقدار ضروری ہے',
      'valid_price_required': 'درست قیمت ضروری ہے',
      'select_from_stock_optional': 'اسٹاک سے منتخب کریں (اختیاری)',
      'or_enter_manually_below': 'یا نیچے دستی طور پر درج کریں',
      'enter_manually': 'دستی طور پر درج کریں',
      'insufficient_stock': 'ناکافی اسٹاک۔ دستیاب',
      'cannot_add_item_insufficient_stock':
          'آئٹم شامل نہیں ہو سکتا: اسٹاک ناکافی ہے',
      'failed_to_add_item': 'آئٹم شامل نہیں ہو سکا',
      'remove_item_confirm': 'کیا آپ "{item}" کو اس انوائس سے ہٹانا چاہتے ہیں؟',
      'subtotal': 'جزوی مجموعہ',
      'error_loading_pdf': 'پی ڈی ایف لوڈ کرنے میں خرابی',
      'failed_to_load_transactions': 'لین دین لوڈ نہیں ہو سکا',
      'payment_recorded_successfully': 'ادائیگی کامیابی سے ریکارڈ ہو گئی',
      'failed_to_record_payment': 'ادائیگی ریکارڈ نہیں ہو سکی',
      'current_balance': 'موجودہ بیلنس',
      'outstanding_dues': 'بقایا جات',
      'no_transactions_yet': 'ابھی تک کوئی لین دین نہیں',
      'credit_invoice': 'کریڈٹ انوائس',
      'payment_received': 'ادائیگی موصول',
      'record_payment': 'ادائیگی ریکارڈ کریں',
      'link_to_invoice_optional': 'انوائس سے لنک کریں (اختیاری)',
      'select_invoice_or_general': 'انوائس منتخب کریں یا عمومی ادائیگی رکھیں',
      'select_invoice_helper':
          'اس ادائیگی کو انوائس سے لنک کریں یا خالی چھوڑ دیں',
      'general_payment': 'عمومی ادائیگی (انوائس سے لنک نہیں)',
      'unpaid': 'غیر ادا شدہ',
      'enter_payment_amount': 'ادائیگی کی رقم درج کریں',
      'please_enter_payment_amount': 'براہ کرم ادائیگی کی رقم درج کریں',
      'please_enter_valid_amount': 'براہ کرم 0 سے زیادہ درست رقم درج کریں',
      'record': 'ریکارڈ کریں',
      'no_route_for': 'کوئی روٹ نہیں: {route}',
      'phone_hint': '923001234567',
      'otp': 'OTP',
      'otp_hint': '123456',
      'bank_accounts': 'بینک اکاؤنٹس',
      'add_bank_account': 'بینک اکاؤنٹ شامل کریں',
      'total_bank_balance': 'کل بینک بیلنس',
      'transfer': 'ٹرانسفر',
      'cash_to_bank': 'کیش سے بینک',
      'bank_to_cash': 'بینک سے کیش',
      'select_bank_account': 'بینک اکاؤنٹ منتخب کریں',
      'transfer_completed': 'ٹرانسفر کامیابی سے مکمل ہوگیا',
      'add_bank': 'بینک شامل کریں',
      'add_banks': 'بینک شامل کریں',
      'manage_bank_balance': 'بینک بیلنس منظم کریں',
      'bank_account_created_successfully': 'بینک اکاؤنٹ کامیابی سے بن گیا',
      'bank_name': 'بینک کا نام',
      'bank_name_hint': 'ABC بینک',
      'account_number': 'اکاؤنٹ نمبر',
      'account_number_hint': '1234567890',
      'account_holder_name_optional': 'اکاؤنٹ ہولڈر کا نام (اختیاری)',
      'account_holder_name_hint': 'جان ڈو',
      'branch_optional': 'برانچ (اختیاری)',
      'branch_hint': 'مین برانچ',
      'ifsc_code_optional': 'IFSC کوڈ (اختیاری)',
      'ifsc_code_hint': 'ABCD0123456',
      'account_type': 'اکاؤنٹ کی قسم',
      'savings': 'سیونگ',
      'current': 'کرنٹ',
      'opening_balance': 'ابتدائی بیلنس',
      'add_account': 'اکاؤنٹ شامل کریں',
      'revoke_device': 'ڈیوائس منسوخ کریں',
      'revoke_device_confirmation':
          'کیا آپ واقعی اس ڈیوائس کو منسوخ کرنا چاہتے ہیں؟ یہ اس کاروباری اکاؤنٹ تک رسائی نہیں رکھ سکے گی۔',
      'revoke': 'منسوخ کریں',
      'device_revoked_successfully': 'ڈیوائس کامیابی سے منسوخ ہو گئی',
      'failed_to_revoke_device': 'ڈیوائس منسوخ کرنے میں ناکامی: {error}',
      'paired_devices': 'منسلک ڈیوائسز',
      'pair_device': 'ڈیوائس جوڑیں',
      'device_pairing': 'ڈیوائس جوڑنا',
      'failed_to_generate_pairing_token':
          'پیئرنگ ٹوکن بنانے میں ناکامی: {error}',
      'device_paired_successfully': 'ڈیوائس کامیابی سے جوڑ دی گئی!',
      'failed_to_pair_device': 'ڈیوائس جوڑنے میں ناکامی: {error}',
      'qr_scanner_not_available_on_web':
          'ویب پلیٹ فارم پر QR اسکینر دستیاب نہیں',
      'add_expense': 'خرچ شامل کریں',
      'expense_created_successfully': 'خرچ کامیابی سے بن گیا',
      'create_category': 'کیٹیگری بنائیں',
      'expense_category': 'خرچ کی کیٹیگری',
      'payment_mode': 'ادائیگی کا طریقہ',
      'bank': 'بینک',
      'create_expense_category': 'خرچ کی کیٹیگری بنائیں',
      'category_name': 'کیٹیگری کا نام',
      'category_name_hint': 'مثلاً، آفس سپلائیز، سفر، یوٹیلیٹیز',
      'category_description_hint': 'اس کیٹیگری کی اضافی تفصیل',
      'category_created_successfully': 'کیٹیگری کامیابی سے بن گئی',
      'security': 'سیکیورٹی',
      'appearance': 'ظاہری شکل',
      'data_management': 'ڈیٹا مینجمنٹ',
      'about': 'متعلق',
      'legal': 'قانونی',
      'app_lock': 'ایپ لاک',
      'require_pin_to_unlock': 'ایپ کھولنے کے لیے PIN لازمی',
      'biometric_authentication': 'بایومیٹرک توثیق',
      'use_fingerprint_or_face_id': 'فنگر پرنٹ یا فیس آئی ڈی استعمال کریں',
      'theme': 'تھیم',
      'system': 'سسٹم',
      'light': 'لائٹ',
      'dark': 'ڈارک',
      'currency': 'کرنسی',
      'clear_cache': 'کیچ صاف کریں',
      'clear_cached_data_and_images': 'کیچ شدہ ڈیٹا اور تصاویر صاف کریں',
      'export_data': 'ڈیٹا ایکسپورٹ کریں',
      'export_business_data': 'اپنے کاروبار کا ڈیٹا ایکسپورٹ کریں',
      'app_version': 'ایپ ورژن',
      'privacy_policy': 'رازداری پالیسی',
      'terms_of_service': 'سروس کی شرائط',
      'logout_confirm_message': 'کیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟',
      'app_lock_enabled': 'ایپ لاک فعال ہو گیا',
      'app_lock_disabled': 'ایپ لاک غیر فعال ہو گیا',
      'enter_pin_to_disable_app_lock': 'ایپ لاک بند کرنے کے لیے PIN درج کریں',
      'biometric_not_available': 'اس ڈیوائس پر بایومیٹرک دستیاب نہیں',
      'enable_biometric_authentication': 'بایومیٹرک توثیق فعال کریں',
      'set_pin': 'PIN سیٹ کریں',
      'enter_pin': '4 ہندسوں کا PIN درج کریں',
      'pin_hint': '0000',
      'set': 'سیٹ کریں',
      'verify': 'تصدیق کریں',
      'language_updated': 'زبان اپ ڈیٹ ہو گئی',
      'theme_updated': 'تھیم اپ ڈیٹ ہو گئی',
      'currency_updated': 'کرنسی اپ ڈیٹ ہو گئی۔ ایپ لوگو تبدیلی ظاہر کرے گا۔',
      'clear_cache_message':
          'یہ تمام کیچ شدہ ڈیٹا صاف کر دے گا۔ آپ کو دوبارہ سنک کرنا ہوگا۔ جاری رکھیں؟',
      'cache_cleared_successfully': 'کیچ کامیابی سے صاف ہو گیا',
      'data_export_coming_soon': 'ڈیٹا ایکسپورٹ فیچر جلد آ رہا ہے',
      'clear': 'صاف کریں',
      'add_staff': 'عملہ شامل کریں',
      'staff_member_created_successfully': 'عملہ رکن کامیابی سے بن گیا',
      'role': 'عہدہ',
      'record_salary': 'تنخواہ درج کریں',
      'salary_recorded_successfully': 'تنخواہ کامیابی سے درج ہوگئی',
      'select_staff': 'عملہ منتخب کریں',
      'purchase_recorded_successfully': 'خریداری کامیابی سے ریکارڈ ہو گئی',
      'record_purchase': 'خریداری ریکارڈ کریں',
      'record_purchase_for': 'خریداری ریکارڈ کریں - {supplier}',
      'purchase_amount': 'خریداری کی رقم',
      'manage_purchases': 'خریداریاں منظم کریں',
      'resolve_sync_conflicts': 'سنک تنازعات حل کریں',
      'all_conflicts_resolved_successfully':
          'تمام تنازعات کامیابی سے حل ہو گئے',
      'this_field': 'یہ فیلڈ',
      'field_is_required': '{field} درکار ہے',
      'invalid_phone_number_format': 'فون نمبر کا فارمیٹ غلط ہے',
      'phone_digits_only': 'فون نمبر میں صرف ہندسے ہوں',
      'otp_required': 'OTP درکار ہے',
      'otp_must_be_6_digits': 'OTP 6 ہندسوں کا ہونا چاہیے',
      'otp_digits_only': 'OTP میں صرف ہندسے ہوں',
      'pin_required': 'PIN درکار ہے',
      'pin_must_be_4_digits': 'PIN 4 ہندسوں کا ہونا چاہیے',
      'pin_digits_only': 'PIN میں صرف ہندسے ہوں',
      'email_required': 'ای میل درکار ہے',
      'invalid_email_address': 'درست ای میل ایڈریس درج کریں',
      'amount_required': 'رقم درکار ہے',
      'invalid_amount': 'درست رقم درج کریں',
      'amount_must_be_greater_than_zero': 'رقم 0 سے زیادہ ہونی چاہیے',
      'quantity_required': 'مقدار درکار ہے',
      'invalid_quantity': 'درست مقدار درج کریں',
      'quantity_must_be_greater_than_zero': 'مقدار 0 سے زیادہ ہونی چاہیے',
      'field_must_be_at_least': '{field} کم از کم {min} حروف پر مشتمل ہو',
      'field_must_be_at_most': '{field} زیادہ سے زیادہ {max} حروف پر مشتمل ہو',
      'field_cannot_be_negative': '{field} منفی نہیں ہو سکتا',
      'no_bank_accounts': 'کوئی بینک اکاؤنٹ نہیں',
      'add_first_bank_account': 'اپنا پہلا بینک اکاؤنٹ شامل کریں',
      'no_devices': 'کوئی ڈیوائس نہیں',
      'pair_device_to_get_started': 'شروع کرنے کے لیے ڈیوائس جوڑیں',
      'unknown_device': 'نامعلوم ڈیوائس',
      'active': 'فعال',
      'inactive': 'غیر فعال',
      'last_sync': 'آخری سنک',
      'generate_qr': 'QR بنائیں',
      'scan_qr': 'QR اسکین کریں',
      'generate_pairing_qr_code': 'پیئرنگ QR کوڈ بنائیں',
      'generate_qr_description':
          'ایسا QR کوڈ بنائیں جسے دیگر ڈیوائسز اسکین کر کے اس کاروباری اکاؤنٹ کے ساتھ جوڑ سکیں۔',
      'pairing_token': 'پیئرنگ ٹوکن',
      'generate_qr_code': 'QR کوڈ بنائیں',
      'use_mobile_app_to_scan':
          'QR کوڈ اسکین کرنے کے لیے موبائل ایپ استعمال کریں',
      'scan_qr_from_another_device': 'دوسری ڈیوائس سے QR کوڈ اسکین کریں',
      'point_camera_at_qr':
          'اپنا کیمرہ دوسری ڈیوائس پر دکھائے گئے QR کوڈ پر رکھیں',
      'no_categories_available': 'کوئی کیٹیگری دستیاب نہیں۔',
      'no_expenses': 'کوئی اخراجات نہیں',
      'start_tracking_expenses': 'اپنے کاروباری اخراجات کو ٹریک کرنا شروع کریں',
      'expense': 'خرچ',
      'items_optional': 'آئٹمز (اختیاری)',
      'no_items_added_for_purchase':
          'کوئی آئٹم شامل نہیں۔ آپ آئٹمز شامل کر سکتے ہیں یا صرف کل رقم درج کریں۔',
      'failed_to_record_purchase': 'خریداری ریکارڈ کرنے میں ناکامی',
      'current_stock': 'موجودہ اسٹاک',
      'from': 'سے',
      'purchase': 'خریداری',
      'payment_made': 'ادائیگی کی گئی',
      'no_staff_members': 'کوئی عملہ نہیں',
      'add_first_staff_member': 'اپنا پہلا عملہ رکن شامل کریں',
      'staff_name': 'عملہ کا نام',
      'name_hint': 'جان ڈو',
      'role_optional': 'عہدہ (اختیاری)',
      'role_hint': 'منیجر، سیلز پرسن وغیرہ',
      'phone_optional': 'فون (اختیاری)',
      'email_hint': 'staff@example.com',
      'address_hint': 'گھر نمبر 123، گلی، شہر',
      'supplier_name_hint': 'ABC سپلائرز',
      'customer_name_hint': 'علی ٹریڈرز',
      'sync_conflicts_detected': 'سنک تنازعات کی نشاندہی',
      'sync_conflicts_description':
          'سرور پر ان آئٹمز کے نئے ورژن ہیں۔ ہر تنازع کے لیے کون سا ورژن رکھنا ہے منتخب کریں۔',
      'no_conflicts_to_resolve': 'حل کرنے کے لیے کوئی تنازع نہیں',
      'resolve_all_conflicts': 'تمام تنازعات حل کریں',
      'failed_to_resolve_conflicts': 'تنازعات حل کرنے میں ناکامی: {error}',
      'id_label': 'آئی ڈی: {id}',
      'server_version': 'سرور ورژن',
      'your_version': 'آپ کا ورژن',
      'updated': 'اپ ڈیٹ',
      'closing_balance': 'اختتامی بیلنس',
      'total_inflow': 'کل آمد',
      'total_outflow': 'کل اخراج',
      'net_cash_flow': 'خالص کیش فلو',
      'transactions': 'لین دین',
      'no_transactions_found': 'کوئی لین دین نہیں ملا',
      'total_expenses': 'کل اخراجات',
      'by_category': 'قسم کے لحاظ سے',
      'uncategorized': 'بغیر قسم',
      'percent_of_total': 'کل کا {percent}%',
      'daily_breakdown': 'روزانہ تفصیل',
      'total_items': 'کل آئٹمز',
      'total_value': 'کل قدر',
      'out_of_stock': 'اسٹاک ختم',
      'low_stock_items_title': 'کم اسٹاک آئٹمز',
      'all_items': 'تمام آئٹمز',
      'current_label': 'موجودہ',
      'min_label': 'کم از کم',
      'stock_label': 'اسٹاک',
      'total_revenue': 'کل آمدنی',
      'net_profit_loss': 'خالص نفع / نقصان',
      'profit_margin_label': 'نفع کا مارجن: {percent}%',
      'revenue_breakdown': 'آمدنی کی تفصیل',
      'expense_breakdown': 'اخراجات کی تفصیل',
      'average_order_value': 'اوسط آرڈر ویلیو',
      'period_breakdown': '{period} تفصیل',
      'cash_label': 'نقد',
      'credit_label': 'ادھار',
      'invoice_count': '{count} انوائس',
      'daily': 'روزانہ',
      'weekly': 'ہفتہ وار',
      'monthly': 'ماہانہ',
      'week_of': 'ہفتہ از',
      'reminder_resolved': 'یاددہانی حل ہو گئی',
      'failed_to_resolve_reminder': 'یاددہانی حل کرنے میں ناکامی: {error}',
      'no_reminders': 'کوئی یاددہانی نہیں',
      'all_reminders_resolved': 'تمام یاددہانیاں حل ہو چکی ہیں',
      'unknown': 'نامعلوم',
      'customer_credit': 'گاہک کریڈٹ',
      'supplier_payment': 'سپلائر ادائیگی',
      'due_date': 'آخری تاریخ',
    },
    'ar': {
      'app_name': 'إنشال خاطة',
      'login': 'تسجيل الدخول',
      'phone': 'رقم الهاتف',
      'enter_mobile_number': 'أدخل رقم الهاتف المحمول',
      'please_wait': 'يرجى الانتظار',
      'language_not_available': 'اللغة غير متاحة',
      'select_your_language': 'اختر لغتك',
      'language_policy_notice': 'إشعار سياسة اللغة',
      'verifying': 'جارٍ التحقق',
      'enter_login_pin': 'أدخل رمز PIN لتسجيل الدخول',
      'forgot_pin': 'نسيت رمز PIN؟',
      'reset_pin_from_settings': 'إعادة تعيين PIN من الإعدادات',
      'use_biometric': 'استخدم القياسات الحيوية',
      'send_otp': 'إرسال رمز التحقق',
      'verify_otp': 'تأكيد رمز التحقق',
      'dashboard': 'لوحة التحكم',
      'cash_feature': 'نقدي',
      'stock': 'المخزون',
      'invoices': 'الفواتير',
      'customers': 'العملاء',
      'suppliers': 'الموردون',
      'expenses': 'المصروفات',
      'staff': 'الموظفون',
      'banks': 'البنوك',
      'reports': 'التقارير',
      'report': 'تقرير',
      'set_date': 'تحديد التاريخ',
      'sms': 'رسالة نصية',
      'entries': 'الإدخالات',
      'entry_detail': 'تفاصيل الإدخال',
      'running_balance': 'الرصيد الجاري',
      'search': 'بحث',
      'filter_all': '????',
      'filter_today': '?????',
      'filter_this_month': '??? ?????',
      'filter_last_two_months': '??? ?????',
      'filter_this_year': '??? ?????',
      'filter_custom_range': '???? ????',
      'search_customers': '???? ?? ???????',
      'you_gave': 'أنت أعطيت',
      'you_got': 'أنت استلمت',
      'you_will_get': 'سوف تستلم',
      'you_will_give': 'سوف تعطي',
      'view_settings_hint': 'انقر هنا لعرض الإعدادات',
      'delete_customer': 'حذف العميل',
      'delete_customer_confirm':
          'هل أنت متأكد أنك تريد حذف {name}؟ لا يمكن التراجع عن هذا الإجراء.',
      'deleting_customer': 'جارٍ حذف العميل...',
      'customer_deleted_successfully': 'تم حذف العميل بنجاح',
      'failed_to_delete_customer': 'فشل حذف العميل',
      'customer_name_exists': '??? ?????? ????? ??????',
      'feature_coming_soon': 'الميزة قريباً',
      'add': 'إضافة',
      'create': 'إنشاء',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'edit': 'تعديل',
      'name': 'الاسم',
      'amount': 'المبلغ',
      'date': 'التاريخ',
      'description': 'الوصف',
      'total': 'الإجمالي',
      'balance': 'الرصيد',
      'hide_balance': 'إخفاء الرصيد',
      'show_balance': 'إظهار الرصيد',
      'no_data': 'لا توجد بيانات',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'request_timed_out': '????? ???? ?????. ???? ??? ????.',
      'something_went_wrong': '??? ??? ??',
      'success': 'نجاح',
      'share': 'مشاركة',
      'whatsapp': 'واتساب',
      'invoice': 'فاتورة',
      'invoice_number': 'رقم الفاتورة',
      'invoice_type': 'نوع الفاتورة',
      'cash': 'نقدي',
      'credit': 'آجل',
      'paid': 'مدفوع',
      'due': 'مستحق',
      'reminders': 'التذكيرات',
      'devices': 'الأجهزة',
      'settings': 'الإعدادات',
      'logout': 'تسجيل الخروج',
      'welcome_back': 'مرحباً بعودتك!',
      'welcome_to_enshaal_khata': 'مرحباً بك في إنشال خاطة',
      'manage_business': 'إدارة حسابات عملك بسهولة',
      'manage_business_easily': 'إدارة حسابات عملك بسهولة',
      'get_started': 'ابدأ',
      'otp_info': 'سنرسل لك رمز التحقق المكون من 6 أرقام للتحقق من رقم هاتفك',
      'otp_sent_successfully': 'تم إرسال رمز التحقق بنجاح',
      'resend_otp': 'إعادة إرسال رمز التحقق',
      'resend_in': 'إعادة الإرسال خلال',
      'seconds': 'ثواني',
      'enter_verification_code': 'أدخل رمز التحقق',
      'we_sent_code_to': 'أرسلنا رمزاً مكوناً من 6 أرقام إلى',
      'verification_code': 'رمز التحقق',
      'didnt_receive_code': 'لم تستلم الرمز؟',
      'todays_summary': 'ملخص اليوم',
      'cash_balance': 'رصيد النقدية',
      'todays_sales': 'مبيعات اليوم',
      'quick_actions': 'إجراءات سريعة',
      'home': 'الرئيسية',
      'more': 'المزيد',
      'overview': 'نظرة عامة',
      'total_sales': 'إجمالي المبيعات',
      'cash_in': 'نقد داخل',
      'cash_out': 'نقد خارج',
      'in_label': 'داخل',
      'out_label': 'خارج',
      'synced': 'تمت المزامنة',
      'pending': 'معلّق',
      'failed': 'Failed',
      'sync_status': 'Sync Status',
      'sync_now': 'Sync Now',
      'retry_failed': 'Retry Failed',
      'offline': 'غير متصل',
      'offline_data_may_be_incomplete':
          '?? ???? ?????? ??? ??????? ??? ??????.',
      'online_required': '????? ??????? ?????????.',
      'management': 'إدارة',
      'item': 'عنصر',
      'transaction': 'معاملة',
      'type': 'نوع',
      'optional': 'اختياري',
      'source': 'المصدر',
      'remarks': 'ملاحظات',
      'failed_to_load_data': 'فشل تحميل البيانات',
      'retry': 'إعادة المحاولة',
      'todays_balance': 'رصيد اليوم',
      'start_by_adding_cash_transaction': 'ابدأ بإضافة أول معاملة نقدية',
      'transaction_type': 'نوع المعاملة',
      'transaction_created_successfully': 'تم إنشاء المعاملة بنجاح',
      'additional_notes': 'ملاحظات إضافية',
      'example_sales_purchase': 'مثال: المبيعات، الشراء',
      'add_first_customer': 'أضف أول عميل للبدء',
      'switch_business': 'تبديل النشاط',
      'create_new_business': 'إنشاء نشاط جديد',
      'select_business': 'اختر النشاط',
      'date_range': 'نطاق التاريخ',
      'sales_report': 'تقرير المبيعات',
      'cash_flow_report': 'تقرير التدفق النقدي',
      'expense_report': 'تقرير المصروفات',
      'stock_report': 'تقرير المخزون',
      'profit_loss_report': 'تقرير الربح والخسارة',
      'refresh': 'تحديث',
      'filter': 'تصفية',
      'add_transaction': 'إضافة معاملة',
      'add_customer': 'إضافة عميل',
      'add_customers': 'إضافة عملاء',
      'add_entries_maintain_khata': 'إضافة إدخالات، الحفاظ على الخاتا',
      'send_payment_reminders': 'إرسال تذكيرات الدفع',
      'create_invoice': 'إنشاء فاتورة',
      'no_invoices': 'لا توجد فواتير',
      'no_customers': 'لا يوجد عملاء',
      'no_transactions': 'لا توجد معاملات',
      'mark_resolved': 'وضع علامة تم الحل',
      'resolved': 'تم الحل',
      'overdue': 'متأخر',
      'khata': 'خاطة',
      'business': 'عمل',
      'create_business': 'إنشاء عمل جديد',
      'language': 'اللغة',
      'language_settings': 'إعدادات اللغة',
      'select_language': 'اختر اللغة',
      'english': 'الإنجليزية',
      'urdu': 'الأردية',
      'arabic': 'العربية',
      'business_name': 'اسم العمل',
      'email_optional': 'البريد الإلكتروني (اختياري)',
      'address_optional': 'العنوان (اختياري)',
      'business_type': 'نوع العمل',
      'custom_business_type': 'نوع عمل مخصص',
      'language_preference': 'تفضيل اللغة',
      'max_devices': 'الحد الأقصى للأجهزة',
      'creating': 'جاري الإنشاء...',
      'please_enter_custom_business_type': 'الرجاء إدخال نوع العمل المخصص',
      'retail_shop': 'متجر تجزئة',
      'wholesale': 'بيع بالجملة',
      'services': 'خدمات',
      'manufacturing': 'تصنيع',
      'restaurant_food': 'مطعم/طعام',
      'other': 'أخرى',
      'stock_management': 'إدارة المخزون',
      'add_stock_item': 'إضافة عنصر مخزون',
      'stock_item_created_successfully': 'تم إنشاء عنصر المخزون بنجاح',
      'item_name': 'اسم العنصر',
      'enter_item_name': 'أدخل اسم العنصر',
      'sku_optional': 'SKU (اختياري)',
      'sku_code': 'رمز SKU',
      'barcode_optional': 'باركود (اختياري)',
      'barcode': 'الباركود',
      'purchase_price': 'سعر الشراء',
      'sale_price': 'سعر البيع',
      'unit': 'الوحدة',
      'pieces': 'قطعة (pcs)',
      'kilogram': 'كيلوغرام (kg)',
      'liter': 'لتر',
      'meter': 'متر',
      'box': 'صندوق',
      'pack': 'عبوة',
      'opening_stock': 'المخزون الافتتاحي',
      'min_stock_threshold_optional': 'حد المخزون الأدنى (اختياري)',
      'alert_when_stock_below': 'تنبيه عندما يكون المخزون أقل من ذلك',
      'description_optional': 'الوصف (اختياري)',
      'item_description': 'وصف العنصر',
      'create_item': 'إنشاء عنصر',
      'no_stock_items': 'لا توجد عناصر مخزون',
      'start_by_adding_stock_item': 'ابدأ بإضافة أول عنصر مخزون',
      'low_stock': 'مخزون منخفض',
      'stock_value': 'قيمة المخزون',
      'stock_in': 'إدخال مخزون',
      'stock_out': 'إخراج مخزون',
      'stock_in_success': 'تمت إضافة المخزون بنجاح',
      'stock_out_success': 'تمت إزالة المخزون بنجاح',
      'confirm_stock_removal': 'تأكيد إزالة المخزون',
      'remove': 'إزالة',
      'remove_stock': 'إزالة مخزون',
      'add_stock': 'إضافة مخزون',
      'unit_price': 'سعر الوحدة',
      'purchase_price_per_unit': 'سعر الشراء للوحدة',
      'sale_price_per_unit': 'سعر البيع للوحدة',
      'quantity': 'الكمية',
      'enter_quantity': 'أدخل الكمية',
      'remarks_optional': 'ملاحظات (اختياري)',
      'required': 'مطلوب',
      'enter_amount': 'أدخل المبلغ',
      'create_first_invoice': 'أنشئ أول فاتورة للبدء',
      'share_invoice': 'مشاركة الفاتورة',
      'other_apps': 'تطبيقات أخرى',
      'total_amount': 'إجمالي المبلغ',
      'filter_invoices': 'تصفية الفواتير',
      'start_date': 'تاريخ البدء',
      'end_date': 'تاريخ الانتهاء',
      'select_date': 'اختر التاريخ',
      'all': 'الكل',
      'apply': 'تطبيق',
      'error_sharing_invoice': 'خطأ في مشاركة الفاتورة',
      'whatsapp_opened_attach_pdf': 'تم فتح واتساب. يرجى إرفاق ملف PDF يدوياً.',
      'customer': 'عميل',
      'customer_name': 'اسم العميل',
      'customer_created_successfully': 'تم إنشاء العميل بنجاح',
      'save_customer': 'حفظ العميل',
      'customer_required': 'العميل مطلوب لجميع الفواتير',
      'select_customer': 'اختر العميل',
      'search_customer': 'البحث عن عميل...',
      'no_customers_found': 'لم يتم العثور على عملاء',
      'no_results_found': 'لم يتم العثور على نتائج',
      'select_from_stock': 'اختر من المخزون',
      'select_stock_item': 'اختر عنصر المخزون',
      'no_stock_items_available':
          'لا توجد عناصر مخزون متاحة. أدخل تفاصيل العنصر يدوياً.',
      'or': 'أو',
      'price': 'السعر',
      'supplier': 'مورد',
      'supplier_name': 'اسم المورد',
      'add_supplier': 'إضافة مورد',
      'add_suppliers': 'إضافة موردين',
      'add_first_supplier': 'أضف أول مورد للبدء',
      'supplier_created_successfully': 'تم إنشاء المورد بنجاح',
      'save_supplier': 'حفظ المورد',
      'no_suppliers': 'لا يوجد موردون',
      'tax_amount': 'مبلغ الضريبة',
      'discount_amount': 'مبلغ الخصم',
      'manual_amount': 'المبلغ اليدوي',
      'manual_amount_required': 'يرجى إدخال مبلغ يدوي',
      'manual_mode_items_ignored':
          'سيتم تجاهل العناصر المضافة في وضع المبلغ اليدوي.',
      'items': 'العناصر',
      'add_item': 'إضافة عنصر',
      'no_items_added': 'لم تتم إضافة عناصر. انقر "إضافة عنصر" لإضافة عناصر.',
      'please_add_item': 'يرجى إضافة عنصر واحد على الأقل إلى الفاتورة',
      'please_fill_required_fields':
          'يرجى تعبئة جميع الحقول المطلوبة بشكل صحيح',
      'item_name_required': 'اسم العنصر مطلوب',
      'valid_quantity_required': 'الكمية الصحيحة مطلوبة',
      'valid_price_required': 'السعر الصحيح مطلوب',
      'select_from_stock_optional': 'اختر من المخزون (اختياري)',
      'or_enter_manually_below': 'أو أدخل يدويًا أدناه',
      'enter_manually': 'أدخل يدويًا',
      'insufficient_stock': 'المخزون غير كافٍ. المتاح',
      'cannot_add_item_insufficient_stock':
          'لا يمكن إضافة العنصر: المخزون غير كافٍ',
      'failed_to_add_item': 'فشل إضافة العنصر',
      'remove_item_confirm':
          'هل أنت متأكد أنك تريد إزالة "{item}" من هذه الفاتورة؟',
      'subtotal': 'المجموع الفرعي',
      'error_loading_pdf': 'خطأ في تحميل PDF',
      'failed_to_load_transactions': 'فشل تحميل المعاملات',
      'payment_recorded_successfully': 'تم تسجيل الدفع بنجاح',
      'failed_to_record_payment': 'فشل تسجيل الدفع',
      'current_balance': 'الرصيد الحالي',
      'outstanding_dues': 'المستحقات',
      'no_transactions_yet': 'لا توجد معاملات بعد',
      'credit_invoice': 'فاتورة آجل',
      'payment_received': 'تم استلام الدفع',
      'record_payment': 'تسجيل الدفع',
      'link_to_invoice_optional': 'ربط بالفاتورة (اختياري)',
      'select_invoice_or_general': 'اختر الفاتورة أو اتركها كدفعة عامة',
      'select_invoice_helper':
          'اختر فاتورة لربط هذه الدفعة أو اتركها فارغة كدفعة عامة',
      'general_payment': 'دفعة عامة (غير مرتبطة بفاتورة)',
      'unpaid': 'غير مدفوع',
      'enter_payment_amount': 'أدخل مبلغ الدفع',
      'please_enter_payment_amount': 'يرجى إدخال مبلغ الدفع',
      'please_enter_valid_amount': 'يرجى إدخال مبلغ صالح أكبر من 0',
      'record': 'تسجيل',
      'no_route_for': 'لا يوجد مسار لـ {route}',
      'phone_hint': '923001234567',
      'otp': 'OTP',
      'otp_hint': '123456',
      'bank_accounts': 'حسابات بنكية',
      'add_bank_account': 'إضافة حساب بنكي',
      'total_bank_balance': 'إجمالي رصيد البنك',
      'transfer': 'تحويل',
      'cash_to_bank': 'نقد إلى بنك',
      'bank_to_cash': 'بنك إلى نقد',
      'select_bank_account': 'اختر الحساب البنكي',
      'transfer_completed': 'تم التحويل بنجاح',
      'add_bank': 'إضافة بنك',
      'add_banks': 'إضافة بنوك',
      'manage_bank_balance': 'إدارة رصيد البنك',
      'bank_account_created_successfully': 'تم إنشاء الحساب البنكي بنجاح',
      'bank_name': 'اسم البنك',
      'bank_name_hint': 'بنك ABC',
      'account_number': 'رقم الحساب',
      'account_number_hint': '1234567890',
      'account_holder_name_optional': 'اسم صاحب الحساب (اختياري)',
      'account_holder_name_hint': 'جون دو',
      'branch_optional': 'الفرع (اختياري)',
      'branch_hint': 'الفرع الرئيسي',
      'ifsc_code_optional': 'رمز IFSC (اختياري)',
      'ifsc_code_hint': 'ABCD0123456',
      'account_type': 'نوع الحساب',
      'savings': 'توفير',
      'current': 'جاري',
      'opening_balance': 'الرصيد الافتتاحي',
      'add_account': 'إضافة حساب',
      'revoke_device': 'إلغاء الجهاز',
      'revoke_device_confirmation':
          'هل أنت متأكد من إلغاء هذا الجهاز؟ لن يتمكن بعد الآن من الوصول إلى حساب العمل هذا.',
      'revoke': 'إلغاء',
      'device_revoked_successfully': 'تم إلغاء الجهاز بنجاح',
      'failed_to_revoke_device': 'فشل إلغاء الجهاز: {error}',
      'paired_devices': 'الأجهزة المقترنة',
      'pair_device': 'إقران جهاز',
      'device_pairing': 'إقران الجهاز',
      'failed_to_generate_pairing_token': 'فشل إنشاء رمز الإقران: {error}',
      'device_paired_successfully': 'تم إقران الجهاز بنجاح!',
      'failed_to_pair_device': 'فشل إقران الجهاز: {error}',
      'qr_scanner_not_available_on_web': 'ماسح QR غير متاح على منصة الويب',
      'add_expense': 'إضافة مصروف',
      'expense_created_successfully': 'تم إنشاء المصروف بنجاح',
      'create_category': 'إنشاء فئة',
      'expense_category': 'فئة المصروف',
      'payment_mode': 'طريقة الدفع',
      'bank': 'بنك',
      'create_expense_category': 'إنشاء فئة مصروف',
      'category_name': 'اسم الفئة',
      'category_name_hint': 'مثال: لوازم مكتبية، سفر، خدمات',
      'category_description_hint': 'تفاصيل إضافية عن هذه الفئة',
      'category_created_successfully': 'تم إنشاء الفئة بنجاح',
      'security': 'الأمان',
      'appearance': 'المظهر',
      'data_management': 'إدارة البيانات',
      'about': 'حول',
      'legal': 'قانوني',
      'app_lock': 'قفل التطبيق',
      'require_pin_to_unlock': 'يتطلب رقم PIN لفتح التطبيق',
      'biometric_authentication': 'المصادقة البيومترية',
      'use_fingerprint_or_face_id': 'استخدم البصمة أو التعرف على الوجه',
      'theme': 'السمة',
      'system': 'النظام',
      'light': 'فاتح',
      'dark': 'داكن',
      'currency': 'العملة',
      'clear_cache': 'مسح ذاكرة التخزين المؤقت',
      'clear_cached_data_and_images': 'مسح البيانات والصور المخزنة مؤقتًا',
      'export_data': 'تصدير البيانات',
      'export_business_data': 'تصدير بيانات عملك',
      'app_version': 'إصدار التطبيق',
      'privacy_policy': 'سياسة الخصوصية',
      'terms_of_service': 'شروط الخدمة',
      'logout_confirm_message': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'app_lock_enabled': 'تم تفعيل قفل التطبيق',
      'app_lock_disabled': 'تم تعطيل قفل التطبيق',
      'enter_pin_to_disable_app_lock': 'أدخل PIN لتعطيل قفل التطبيق',
      'biometric_not_available': 'المصادقة البيومترية غير متاحة على هذا الجهاز',
      'enable_biometric_authentication': 'تفعيل المصادقة البيومترية',
      'set_pin': 'تعيين PIN',
      'enter_pin': 'أدخل PIN من 4 أرقام',
      'pin_hint': '0000',
      'set': 'تعيين',
      'verify': 'تحقق',
      'language_updated': 'تم تحديث اللغة',
      'theme_updated': 'تم تحديث المظهر',
      'currency_updated': 'تم تحديث العملة. سيعكس شعار التطبيق التغيير.',
      'clear_cache_message':
          'سيؤدي هذا إلى مسح كل البيانات المخزنة مؤقتًا. ستحتاج إلى المزامنة مرة أخرى. هل تريد المتابعة؟',
      'cache_cleared_successfully': 'تم مسح ذاكرة التخزين المؤقت بنجاح',
      'data_export_coming_soon': 'ميزة تصدير البيانات قادمة قريبًا',
      'clear': 'مسح',
      'add_staff': 'إضافة موظف',
      'staff_member_created_successfully': 'تم إنشاء الموظف بنجاح',
      'role': 'المنصب',
      'record_salary': 'تسجيل الراتب',
      'salary_recorded_successfully': 'تم تسجيل الراتب بنجاح',
      'select_staff': 'اختر الموظف',
      'purchase_recorded_successfully': 'تم تسجيل الشراء بنجاح',
      'record_purchase': 'تسجيل شراء',
      'record_purchase_for': 'تسجيل شراء - {supplier}',
      'purchase_amount': 'مبلغ الشراء',
      'manage_purchases': 'إدارة المشتريات',
      'resolve_sync_conflicts': 'حل تعارضات المزامنة',
      'all_conflicts_resolved_successfully': 'تم حل جميع التعارضات بنجاح',
      'this_field': 'هذا الحقل',
      'field_is_required': '{field} مطلوب',
      'invalid_phone_number_format': 'تنسيق رقم الهاتف غير صالح',
      'phone_digits_only': 'يجب أن يحتوي رقم الهاتف على أرقام فقط',
      'otp_required': 'رمز OTP مطلوب',
      'otp_must_be_6_digits': 'يجب أن يتكون رمز OTP من 6 أرقام',
      'otp_digits_only': 'يجب أن يحتوي رمز OTP على أرقام فقط',
      'pin_required': 'رقم PIN مطلوب',
      'pin_must_be_4_digits': 'يجب أن يتكون رقم PIN من 4 أرقام',
      'pin_digits_only': 'يجب أن يحتوي رقم PIN على أرقام فقط',
      'email_required': 'البريد الإلكتروني مطلوب',
      'invalid_email_address': 'يرجى إدخال بريد إلكتروني صالح',
      'amount_required': 'المبلغ مطلوب',
      'invalid_amount': 'يرجى إدخال مبلغ صالح',
      'amount_must_be_greater_than_zero': 'يجب أن يكون المبلغ أكبر من 0',
      'quantity_required': 'الكمية مطلوبة',
      'invalid_quantity': 'يرجى إدخال كمية صالحة',
      'quantity_must_be_greater_than_zero': 'يجب أن تكون الكمية أكبر من 0',
      'field_must_be_at_least': 'يجب أن يكون {field} على الأقل {min} أحرف',
      'field_must_be_at_most': 'يجب أن يكون {field} على الأكثر {max} أحرف',
      'field_cannot_be_negative': 'لا يمكن أن يكون {field} سالبًا',
      'no_bank_accounts': 'لا توجد حسابات بنكية',
      'add_first_bank_account': 'أضف أول حساب بنكي لك',
      'no_devices': 'لا توجد أجهزة',
      'pair_device_to_get_started': 'قم بإقران جهاز للبدء',
      'unknown_device': 'جهاز غير معروف',
      'active': 'نشط',
      'inactive': 'غير نشط',
      'last_sync': 'آخر مزامنة',
      'generate_qr': 'إنشاء QR',
      'scan_qr': 'مسح QR',
      'generate_pairing_qr_code': 'إنشاء رمز QR للإقران',
      'generate_qr_description':
          'قم بإنشاء رمز QR يمكن للأجهزة الأخرى مسحه لإقران هذا الحساب التجاري.',
      'pairing_token': 'رمز الإقران',
      'generate_qr_code': 'إنشاء رمز QR',
      'use_mobile_app_to_scan': 'يرجى استخدام تطبيق الهاتف لمسح رموز QR',
      'scan_qr_from_another_device': 'امسح رمز QR من جهاز آخر',
      'point_camera_at_qr': 'وجّه الكاميرا إلى رمز QR المعروض على الجهاز الآخر',
      'no_categories_available': 'لا توجد فئات متاحة.',
      'no_expenses': 'لا توجد مصروفات',
      'start_tracking_expenses': 'ابدأ بتتبع مصروفات عملك',
      'expense': 'مصروف',
      'items_optional': 'العناصر (اختياري)',
      'no_items_added_for_purchase':
          'لم تتم إضافة عناصر. يمكنك إضافة عناصر أو تسجيل المبلغ الإجمالي فقط.',
      'failed_to_record_purchase': 'فشل تسجيل الشراء',
      'current_stock': 'المخزون الحالي',
      'from': 'من',
      'purchase': 'شراء',
      'payment_made': 'تم الدفع',
      'no_staff_members': 'لا يوجد موظفون',
      'add_first_staff_member': 'أضف أول موظف لك',
      'staff_name': 'اسم الموظف',
      'name_hint': 'جون دو',
      'role_optional': 'الدور (اختياري)',
      'role_hint': 'مدير، مندوب مبيعات، إلخ.',
      'phone_optional': 'الهاتف (اختياري)',
      'email_hint': 'staff@example.com',
      'address_hint': 'منزل رقم 123، شارع، مدينة',
      'supplier_name_hint': 'موردو ABC',
      'customer_name_hint': 'علي للتجارة',
      'sync_conflicts_detected': 'تم اكتشاف تعارضات المزامنة',
      'sync_conflicts_description':
          'يحتوي الخادم على إصدارات أحدث من هذه العناصر. اختر النسخة التي تريد الاحتفاظ بها لكل تعارض.',
      'no_conflicts_to_resolve': 'لا توجد تعارضات للحل',
      'resolve_all_conflicts': 'حل جميع التعارضات',
      'failed_to_resolve_conflicts': 'فشل حل التعارضات: {error}',
      'id_label': 'المعرّف: {id}',
      'server_version': 'إصدار الخادم',
      'your_version': 'إصدارك',
      'updated': 'تم التحديث',
      'closing_balance': 'الرصيد الختامي',
      'total_inflow': 'إجمالي التدفق الداخل',
      'total_outflow': 'إجمالي التدفق الخارج',
      'net_cash_flow': 'صافي التدفق النقدي',
      'transactions': 'المعاملات',
      'no_transactions_found': 'لم يتم العثور على معاملات',
      'total_expenses': 'إجمالي المصروفات',
      'by_category': 'حسب الفئة',
      'uncategorized': 'غير مصنف',
      'percent_of_total': '{percent}% من الإجمالي',
      'daily_breakdown': 'تفصيل يومي',
      'total_items': 'إجمالي العناصر',
      'total_value': 'القيمة الإجمالية',
      'out_of_stock': 'نفاد المخزون',
      'low_stock_items_title': 'عناصر مخزون منخفض',
      'all_items': 'جميع العناصر',
      'current_label': 'حالي',
      'min_label': 'الحد الأدنى',
      'stock_label': 'المخزون',
      'total_revenue': 'إجمالي الإيرادات',
      'net_profit_loss': 'صافي الربح / الخسارة',
      'profit_margin_label': 'هامش الربح: {percent}%',
      'revenue_breakdown': 'تفصيل الإيرادات',
      'expense_breakdown': 'تفصيل المصروفات',
      'average_order_value': 'متوسط قيمة الطلب',
      'period_breakdown': 'تفصيل {period}',
      'cash_label': 'نقد',
      'credit_label': 'آجل',
      'invoice_count': '{count} فاتورة',
      'daily': 'يومي',
      'weekly': 'أسبوعي',
      'monthly': 'شهري',
      'week_of': 'أسبوع',
      'reminder_resolved': 'تم حل التذكير',
      'failed_to_resolve_reminder': 'فشل حل التذكير: {error}',
      'no_reminders': 'لا توجد تذكيرات',
      'all_reminders_resolved': 'تم حل جميع التذكيرات',
      'unknown': 'غير معروف',
      'customer_credit': 'ائتمان العميل',
      'supplier_payment': 'دفعة المورد',
      'due_date': 'تاريخ الاستحقاق',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Getters for common translations
  String get appName => translate('app_name');
  String get login => translate('login');
  String get phone => translate('phone');
  String get sendOtp => translate('send_otp');
  String get verifyOtp => translate('verify_otp');
  String get dashboard => translate('dashboard');
  String get cash => translate('cash_feature');
  String get stock => translate('stock');
  String get invoices => translate('invoices');
  String get customers => translate('customers');
  String get suppliers => translate('suppliers');
  String get expenses => translate('expenses');
  String get staff => translate('staff');
  String get banks => translate('banks');
  String get reports => translate('reports');
  String get report => translate('report');
  String get setDate => translate('set_date');
  String get sms => translate('sms');
  String get entries => translate('entries');
  String get entryDetail => translate('entry_detail');
  String get runningBalance => translate('running_balance');
  String get search => translate('search');
  String get filterCustomRange => translate('filter_custom_range');
  String get filterThisYear => translate('filter_this_year');
  String get filterLastTwoMonths => translate('filter_last_two_months');
  String get filterThisMonth => translate('filter_this_month');
  String get filterToday => translate('filter_today');
  String get filterAll => translate('filter_all');
  String get searchCustomers => translate('search_customers');
  String get youGave => translate('you_gave');
  String get youGot => translate('you_got');
  String get youWillGet => translate('you_will_get');
  String get youWillGive => translate('you_will_give');
  String get viewSettingsHint => translate('view_settings_hint');
  String get deleteCustomer => translate('delete_customer');
  String get deleteCustomerConfirm => translate('delete_customer_confirm');
  String get deletingCustomer => translate('deleting_customer');
  String get customerDeletedSuccessfully =>
      translate('customer_deleted_successfully');
  String get failedToDeleteCustomer => translate('failed_to_delete_customer');
  String get customerNameAlreadyExists => translate('customer_name_exists');
  String get featureComingSoon => translate('feature_coming_soon');
  String get add => translate('add');
  String get create => translate('create');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get name => translate('name');
  String get amount => translate('amount');
  String get date => translate('date');
  String get description => translate('description');
  String get total => translate('total');
  String get balance => translate('balance');
  String get hideBalance => translate('hide_balance');
  String get showBalance => translate('show_balance');
  String get noData => translate('no_data');
  String get loading => translate('loading');
  String get error => translate('error');
  String get somethingWentWrong => translate('something_went_wrong');
  String get requestTimedOut => translate('request_timed_out');
  String get success => translate('success');
  String get reminders => translate('reminders');
  String get devices => translate('devices');
  String get settings => translate('settings');
  String get logout => translate('logout');
  String get welcomeBack => translate('welcome_back');
  String get manageBusiness => translate('manage_business');
  String get cashBalance => translate('cash_balance');
  String get totalSales => translate('total_sales');
  String get quickActions => translate('quick_actions');
  String get addTransaction => translate('add_transaction');
  String get noTransactions => translate('no_transactions');
  String get todaysBalance => translate('todays_balance');
  String get startByAddingCashTransaction =>
      translate('start_by_adding_cash_transaction');
  String get addCustomer => translate('add_customer');
  String get addFirstCustomer => translate('add_first_customer');
  String get transactionType => translate('transaction_type');
  String get transactionCreatedSuccessfully =>
      translate('transaction_created_successfully');
  String get additionalNotes => translate('additional_notes');
  String get exampleSalesPurchase => translate('example_sales_purchase');
  String get switchBusiness => translate('switch_business');
  String get createNewBusiness => translate('create_new_business');
  String get selectBusiness => translate('select_business');
  String get dateRange => translate('date_range');
  String get salesReport => translate('sales_report');
  String get cashFlowReport => translate('cash_flow_report');
  String get expenseReport => translate('expense_report');
  String get stockReport => translate('stock_report');
  String get profitLossReport => translate('profit_loss_report');
  String get stockManagement => translate('stock_management');
  String get addStockItem => translate('add_stock_item');
  String get stockItemCreatedSuccessfully =>
      translate('stock_item_created_successfully');
  String get itemName => translate('item_name');
  String get enterItemName => translate('enter_item_name');
  String get skuOptional => translate('sku_optional');
  String get skuCode => translate('sku_code');
  String get barcodeOptional => translate('barcode_optional');
  String get barcode => translate('barcode');
  String get purchasePrice => translate('purchase_price');
  String get salePrice => translate('sale_price');
  String get unit => translate('unit');
  String get pieces => translate('pieces');
  String get kilogram => translate('kilogram');
  String get liter => translate('liter');
  String get meter => translate('meter');
  String get box => translate('box');
  String get pack => translate('pack');
  String get openingStock => translate('opening_stock');
  String get minStockThresholdOptional =>
      translate('min_stock_threshold_optional');
  String get alertWhenStockBelow => translate('alert_when_stock_below');
  String get descriptionOptional => translate('description_optional');
  String get itemDescription => translate('item_description');
  String get createItem => translate('create_item');
  String get noStockItems => translate('no_stock_items');
  String get startByAddingStockItem => translate('start_by_adding_stock_item');
  String get lowStock => translate('low_stock');
  String get stockValue => translate('stock_value');
  String get stockIn => translate('stock_in');
  String get stockOut => translate('stock_out');
  String get stockInSuccess => translate('stock_in_success');
  String get stockOutSuccess => translate('stock_out_success');
  String get confirmStockRemoval => translate('confirm_stock_removal');
  String get remove => translate('remove');
  String get removeStock => translate('remove_stock');
  String get addStock => translate('add_stock');
  String get unitPrice => translate('unit_price');
  String get purchasePricePerUnit => translate('purchase_price_per_unit');
  String get salePricePerUnit => translate('sale_price_per_unit');
  String get quantity => translate('quantity');
  String get enterQuantity => translate('enter_quantity');
  String get remarksOptional => translate('remarks_optional');
  String get required => translate('required');
  String get enterAmount => translate('enter_amount');
  String get createFirstInvoice => translate('create_first_invoice');
  String get shareInvoice => translate('share_invoice');
  String get otherApps => translate('other_apps');
  String get totalAmount => translate('total_amount');
  String get filterInvoices => translate('filter_invoices');
  String get startDate => translate('start_date');
  String get endDate => translate('end_date');
  String get selectDate => translate('select_date');
  String get all => translate('all');
  String get apply => translate('apply');
  String get errorSharingInvoice => translate('error_sharing_invoice');
  String get whatsappOpenedAttachPdf => translate('whatsapp_opened_attach_pdf');
  String get customer => translate('customer');
  String get customerName => translate('customer_name');
  String get customerCreatedSuccessfully =>
      translate('customer_created_successfully');
  String get saveCustomer => translate('save_customer');
  String get customerRequired => translate('customer_required');
  String get selectCustomer => translate('select_customer');
  String get searchCustomer => translate('search_customer');
  String get noCustomersFound => translate('no_customers_found');
  String get noResultsFound => translate('no_results_found');
  String get supplier => translate('supplier');
  String get supplierName => translate('supplier_name');
  String get addSupplier => translate('add_supplier');
  String get addFirstSupplier => translate('add_first_supplier');
  String get supplierCreatedSuccessfully =>
      translate('supplier_created_successfully');
  String get saveSupplier => translate('save_supplier');
  String get noSuppliers => translate('no_suppliers');
  String get taxAmount => translate('tax_amount');
  String get discountAmount => translate('discount_amount');
  String get manualAmount => translate('manual_amount');
  String get manualAmountRequired => translate('manual_amount_required');
  String get manualModeItemsIgnored => translate('manual_mode_items_ignored');
  String get items => translate('items');
  String get addItem => translate('add_item');
  String get noItemsAdded => translate('no_items_added');
  String get pleaseAddItem => translate('please_add_item');
  String get pleaseFillRequiredFields =>
      translate('please_fill_required_fields');
  String get itemNameRequired => translate('item_name_required');
  String get validQuantityRequired => translate('valid_quantity_required');
  String get validPriceRequired => translate('valid_price_required');
  String get selectFromStockOptional => translate('select_from_stock_optional');
  String get selectFromStock => translate('select_from_stock');
  String get selectStockItem => translate('select_stock_item');
  String get noStockItemsAvailable => translate('no_stock_items_available');
  String get or => translate('or');
  String get price => translate('price');
  String get orEnterManuallyBelow => translate('or_enter_manually_below');
  String get enterManually => translate('enter_manually');
  String get insufficientStock => translate('insufficient_stock');
  String get cannotAddItemInsufficientStock =>
      translate('cannot_add_item_insufficient_stock');
  String get failedToAddItem => translate('failed_to_add_item');
  String get removeItemConfirm => translate('remove_item_confirm');
  String get subtotal => translate('subtotal');
  String get errorLoadingPdf => translate('error_loading_pdf');
  String get languageSettings => translate('language_settings');
  String get selectLanguage => translate('select_language');
  String get english => translate('english');
  String get urdu => translate('urdu');
  String get arabic => translate('arabic');
  String get businessName => translate('business_name');
  String get emailOptional => translate('email_optional');
  String get addressOptional => translate('address_optional');
  String get businessType => translate('business_type');
  String get customBusinessType => translate('custom_business_type');
  String get languagePreference => translate('language_preference');
  String get maxDevices => translate('max_devices');
  String get creating => translate('creating');
  String get createBusiness => translate('create_business');
  String get pleaseEnterCustomBusinessType =>
      translate('please_enter_custom_business_type');
  String get retailShop => translate('retail_shop');
  String get wholesale => translate('wholesale');
  String get services => translate('services');
  String get manufacturing => translate('manufacturing');
  String get restaurantFood => translate('restaurant_food');
  String get other => translate('other');
  String get welcomeToEnshaalKhata => translate('welcome_to_enshaal_khata');
  String get manageBusinessEasily => translate('manage_business_easily');
  String get getStarted => translate('get_started');
  String get otpInfo => translate('otp_info');
  String get otpSentSuccessfully => translate('otp_sent_successfully');
  String get resendOtp => translate('resend_otp');
  String get resendIn => translate('resend_in');
  String get seconds => translate('seconds');
  String get enterVerificationCode => translate('enter_verification_code');
  String get weSentCodeTo => translate('we_sent_code_to');
  String get verificationCode => translate('verification_code');
  String get didntReceiveCode => translate('didnt_receive_code');
  String get home => translate('home');
  String get more => translate('more');
  String get overview => translate('overview');
  String get cashIn => translate('cash_in');
  String get cashOut => translate('cash_out');
  String get inLabel => translate('in_label');
  String get outLabel => translate('out_label');
  String get synced => translate('synced');
  String get pending => translate('pending');
  String get failed => translate('failed');
  String get offline => translate('offline');
  String get syncStatus => translate('sync_status');
  String get syncNow => translate('sync_now');
  String get retryFailed => translate('retry_failed');
  String get offlineDataMayBeIncomplete =>
      translate('offline_data_may_be_incomplete');
  String get onlineRequired => translate('online_required');
  String get management => translate('management');
  String get item => translate('item');
  String get transaction => translate('transaction');
  String get type => translate('type');
  String get optional => translate('optional');
  String get source => translate('source');
  String get remarks => translate('remarks');
  String get failedToLoadData => translate('failed_to_load_data');
  String get retry => translate('retry');
  String get failedToLoadTransactions =>
      translate('failed_to_load_transactions');
  String get paymentRecordedSuccessfully =>
      translate('payment_recorded_successfully');
  String get failedToRecordPayment => translate('failed_to_record_payment');
  String get currentBalance => translate('current_balance');
  String get outstandingDues => translate('outstanding_dues');
  String get noTransactionsYet => translate('no_transactions_yet');
  String get creditInvoice => translate('credit_invoice');
  String get paymentReceived => translate('payment_received');
  String get recordPayment => translate('record_payment');
  String get linkToInvoiceOptional => translate('link_to_invoice_optional');
  String get selectInvoiceOrGeneral => translate('select_invoice_or_general');
  String get selectInvoiceHelper => translate('select_invoice_helper');
  String get generalPayment => translate('general_payment');
  String get unpaid => translate('unpaid');
  String get enterPaymentAmount => translate('enter_payment_amount');
  String get pleaseEnterPaymentAmount =>
      translate('please_enter_payment_amount');
  String get pleaseEnterValidAmount => translate('please_enter_valid_amount');
  String get record => translate('record');
  String get noRouteFor => translate('no_route_for');
  String get phoneHint => translate('phone_hint');
  String get otp => translate('otp');
  String get otpHint => translate('otp_hint');
  String get bankAccounts => translate('bank_accounts');
  String get addBankAccount => translate('add_bank_account');
  String get totalBankBalance => translate('total_bank_balance');
  String get transfer => translate('transfer');
  String get cashToBank => translate('cash_to_bank');
  String get bankToCash => translate('bank_to_cash');
  String get selectBankAccount => translate('select_bank_account');
  String get transferCompleted => translate('transfer_completed');
  String get bankAccountCreatedSuccessfully =>
      translate('bank_account_created_successfully');
  String get bankName => translate('bank_name');
  String get bankNameHint => translate('bank_name_hint');
  String get accountNumber => translate('account_number');
  String get accountNumberHint => translate('account_number_hint');
  String get accountHolderNameOptional =>
      translate('account_holder_name_optional');
  String get accountHolderNameHint => translate('account_holder_name_hint');
  String get branchOptional => translate('branch_optional');
  String get branchHint => translate('branch_hint');
  String get ifscCodeOptional => translate('ifsc_code_optional');
  String get ifscCodeHint => translate('ifsc_code_hint');
  String get accountType => translate('account_type');
  String get savings => translate('savings');
  String get current => translate('current');
  String get openingBalance => translate('opening_balance');
  String get addAccount => translate('add_account');
  String get revokeDevice => translate('revoke_device');
  String get revokeDeviceConfirmation =>
      translate('revoke_device_confirmation');
  String get revoke => translate('revoke');
  String get deviceRevokedSuccessfully =>
      translate('device_revoked_successfully');
  String get failedToRevokeDevice => translate('failed_to_revoke_device');
  String get pairedDevices => translate('paired_devices');
  String get pairDevice => translate('pair_device');
  String get devicePairing => translate('device_pairing');
  String get failedToGeneratePairingToken =>
      translate('failed_to_generate_pairing_token');
  String get devicePairedSuccessfully =>
      translate('device_paired_successfully');
  String get failedToPairDevice => translate('failed_to_pair_device');
  String get qrScannerNotAvailableOnWeb =>
      translate('qr_scanner_not_available_on_web');
  String get addExpense => translate('add_expense');
  String get expenseCreatedSuccessfully =>
      translate('expense_created_successfully');
  String get createCategory => translate('create_category');
  String get expenseCategory => translate('expense_category');
  String get paymentMode => translate('payment_mode');
  String get bank => translate('bank');
  String get createExpenseCategory => translate('create_expense_category');
  String get categoryName => translate('category_name');
  String get categoryNameHint => translate('category_name_hint');
  String get categoryDescriptionHint => translate('category_description_hint');
  String get categoryCreatedSuccessfully =>
      translate('category_created_successfully');
  String get security => translate('security');
  String get appearance => translate('appearance');
  String get dataManagement => translate('data_management');
  String get about => translate('about');
  String get legal => translate('legal');
  String get appLock => translate('app_lock');
  String get requirePinToUnlock => translate('require_pin_to_unlock');
  String get biometricAuthentication => translate('biometric_authentication');
  String get useFingerprintOrFaceId => translate('use_fingerprint_or_face_id');
  String get theme => translate('theme');
  String get system => translate('system');
  String get light => translate('light');
  String get dark => translate('dark');
  String get currency => translate('currency');
  String get clearCache => translate('clear_cache');
  String get clearCachedDataAndImages =>
      translate('clear_cached_data_and_images');
  String get exportData => translate('export_data');
  String get exportBusinessData => translate('export_business_data');
  String get appVersion => translate('app_version');
  String get privacyPolicy => translate('privacy_policy');
  String get termsOfService => translate('terms_of_service');
  String get logoutConfirmMessage => translate('logout_confirm_message');
  String get appLockEnabled => translate('app_lock_enabled');
  String get appLockDisabled => translate('app_lock_disabled');
  String get enterPinToDisableAppLock =>
      translate('enter_pin_to_disable_app_lock');
  String get biometricNotAvailable => translate('biometric_not_available');
  String get enableBiometricAuthentication =>
      translate('enable_biometric_authentication');
  String get setPin => translate('set_pin');
  String get enterPin => translate('enter_pin');
  String get pinHint => translate('pin_hint');
  String get set => translate('set');
  String get verify => translate('verify');
  String get languageUpdated => translate('language_updated');
  String get themeUpdated => translate('theme_updated');
  String get currencyUpdated => translate('currency_updated');
  String get clearCacheMessage => translate('clear_cache_message');
  String get cacheClearedSuccessfully =>
      translate('cache_cleared_successfully');
  String get dataExportComingSoon => translate('data_export_coming_soon');
  String get clear => translate('clear');
  String get addStaff => translate('add_staff');
  String get role => translate('role');
  String get recordSalary => translate('record_salary');
  String get salaryRecordedSuccessfully =>
      translate('salary_recorded_successfully');
  String get selectStaff => translate('select_staff');
  String get staffMemberCreatedSuccessfully =>
      translate('staff_member_created_successfully');
  String get purchaseRecordedSuccessfully =>
      translate('purchase_recorded_successfully');
  String get recordPurchase => translate('record_purchase');
  String get recordPurchaseFor => translate('record_purchase_for');
  String get purchaseAmount => translate('purchase_amount');
  String get resolveSyncConflicts => translate('resolve_sync_conflicts');
  String get allConflictsResolvedSuccessfully =>
      translate('all_conflicts_resolved_successfully');
  String get thisField => translate('this_field');
  String get fieldIsRequired => translate('field_is_required');
  String get invalidPhoneNumberFormat =>
      translate('invalid_phone_number_format');
  String get phoneDigitsOnly => translate('phone_digits_only');
  String get otpRequired => translate('otp_required');
  String get otpMustBe6Digits => translate('otp_must_be_6_digits');
  String get otpDigitsOnly => translate('otp_digits_only');
  String get pinRequired => translate('pin_required');
  String get pinMustBe4Digits => translate('pin_must_be_4_digits');
  String get pinDigitsOnly => translate('pin_digits_only');
  String get emailRequired => translate('email_required');
  String get invalidEmailAddress => translate('invalid_email_address');
  String get amountRequired => translate('amount_required');
  String get invalidAmount => translate('invalid_amount');
  String get amountMustBeGreaterThanZero =>
      translate('amount_must_be_greater_than_zero');
  String get quantityRequired => translate('quantity_required');
  String get invalidQuantity => translate('invalid_quantity');
  String get quantityMustBeGreaterThanZero =>
      translate('quantity_must_be_greater_than_zero');
  String get fieldMustBeAtLeast => translate('field_must_be_at_least');
  String get fieldMustBeAtMost => translate('field_must_be_at_most');
  String get fieldCannotBeNegative => translate('field_cannot_be_negative');
  String get noBankAccounts => translate('no_bank_accounts');
  String get addFirstBankAccount => translate('add_first_bank_account');
  String get noDevices => translate('no_devices');
  String get pairDeviceToGetStarted => translate('pair_device_to_get_started');
  String get unknownDevice => translate('unknown_device');
  String get active => translate('active');
  String get inactive => translate('inactive');
  String get lastSync => translate('last_sync');
  String get generateQr => translate('generate_qr');
  String get scanQr => translate('scan_qr');
  String get generatePairingQrCode => translate('generate_pairing_qr_code');
  String get generateQrDescription => translate('generate_qr_description');
  String get pairingToken => translate('pairing_token');
  String get generateQrCode => translate('generate_qr_code');
  String get useMobileAppToScan => translate('use_mobile_app_to_scan');
  String get scanQrFromAnotherDevice =>
      translate('scan_qr_from_another_device');
  String get pointCameraAtQr => translate('point_camera_at_qr');
  String get noCategoriesAvailable => translate('no_categories_available');
  String get noExpenses => translate('no_expenses');
  String get startTrackingExpenses => translate('start_tracking_expenses');
  String get expense => translate('expense');
  String get itemsOptional => translate('items_optional');
  String get noItemsAddedForPurchase =>
      translate('no_items_added_for_purchase');
  String get failedToRecordPurchase => translate('failed_to_record_purchase');
  String get currentStock => translate('current_stock');
  String get from => translate('from');
  String get purchase => translate('purchase');
  String get paymentMade => translate('payment_made');
  String get noStaffMembers => translate('no_staff_members');
  String get addFirstStaffMember => translate('add_first_staff_member');
  String get staffName => translate('staff_name');
  String get nameHint => translate('name_hint');
  String get roleOptional => translate('role_optional');
  String get roleHint => translate('role_hint');
  String get phoneOptional => translate('phone_optional');
  String get emailHint => translate('email_hint');
  String get addressHint => translate('address_hint');
  String get supplierNameHint => translate('supplier_name_hint');
  String get customerNameHint => translate('customer_name_hint');
  String get syncConflictsDetected => translate('sync_conflicts_detected');
  String get syncConflictsDescription =>
      translate('sync_conflicts_description');
  String get noConflictsToResolve => translate('no_conflicts_to_resolve');
  String get resolveAllConflicts => translate('resolve_all_conflicts');
  String get failedToResolveConflicts =>
      translate('failed_to_resolve_conflicts');
  String get idLabel => translate('id_label');
  String get serverVersion => translate('server_version');
  String get yourVersion => translate('your_version');
  String get updated => translate('updated');
  String get closingBalance => translate('closing_balance');
  String get totalInflow => translate('total_inflow');
  String get totalOutflow => translate('total_outflow');
  String get netCashFlow => translate('net_cash_flow');
  String get transactions => translate('transactions');
  String get noTransactionsFound => translate('no_transactions_found');
  String get totalExpenses => translate('total_expenses');
  String get byCategory => translate('by_category');
  String get uncategorized => translate('uncategorized');
  String get percentOfTotal => translate('percent_of_total');
  String get dailyBreakdown => translate('daily_breakdown');
  String get totalItems => translate('total_items');
  String get totalValue => translate('total_value');
  String get outOfStock => translate('out_of_stock');
  String get lowStockItemsTitle => translate('low_stock_items_title');
  String get allItems => translate('all_items');
  String get currentLabel => translate('current_label');
  String get minLabel => translate('min_label');
  String get stockLabel => translate('stock_label');
  String get totalRevenue => translate('total_revenue');
  String get netProfitLoss => translate('net_profit_loss');
  String get profitMarginLabel => translate('profit_margin_label');
  String get revenueBreakdown => translate('revenue_breakdown');
  String get expenseBreakdown => translate('expense_breakdown');
  String get averageOrderValue => translate('average_order_value');
  String get periodBreakdown => translate('period_breakdown');
  String get cashLabel => translate('cash_label');
  String get creditLabel => translate('credit_label');
  String get invoiceCount => translate('invoice_count');
  String get daily => translate('daily');
  String get weekly => translate('weekly');
  String get monthly => translate('monthly');
  String get weekOf => translate('week_of');
  String get reminderResolved => translate('reminder_resolved');
  String get failedToResolveReminder => translate('failed_to_resolve_reminder');
  String get noReminders => translate('no_reminders');
  String get allRemindersResolved => translate('all_reminders_resolved');
  String get unknown => translate('unknown');
  String get customerCredit => translate('customer_credit');
  String get supplierPayment => translate('supplier_payment');
  String get dueDate => translate('due_date');
  String get share => translate('share');
  String get whatsapp => translate('whatsapp');
  String get invoice => translate('invoice');
  String get invoiceNumber => translate('invoice_number');
  String get invoiceType => translate('invoice_type');
  String get credit => translate('credit');
  String get paid => translate('paid');
  String get refresh => translate('refresh');
  String get filter => translate('filter');
  String get resolved => translate('resolved');
  String get overdue => translate('overdue');
  String get markResolved => translate('mark_resolved');
  String get noCustomers => translate('no_customers');
  String get noInvoices => translate('no_invoices');
  String get enterMobileNumber => translate('enter_mobile_number');
  String get pleaseWait => translate('please_wait');
  String get languageNotAvailable => translate('language_not_available');
  String get selectYourLanguage => translate('select_your_language');
  String get languagePolicyNotice => translate('language_policy_notice');
  String get verifying => translate('verifying');
  String get enterLoginPin => translate('enter_login_pin');
  String get forgotPin => translate('forgot_pin');
  String get resetPinFromSettings => translate('reset_pin_from_settings');
  String get useBiometric => translate('use_biometric');
  String get setUpDigiKhata => translate('set_up_digi_khata');
  String get finish => translate('finish');
  String get next => translate('next');
  String get start => translate('start');
  String get ownerName => translate('owner_name');
  String get ownerNameHint => translate('owner_name_hint');
  String get businessNameHint => translate('business_name_hint');
  String get businessCategoryQuestion =>
      translate('business_category_question');
  String get enterBusinessCategory => translate('enter_business_category');
  String get selectBusinessCategory => translate('select_business_category');
  String get businessTypeQuestion => translate('business_type_question');
  String get enterBusinessType => translate('enter_business_type');
  String get businessAddress => translate('business_address');
  String get googleLocation => translate('google_location');
  String get locationNotAvailable => translate('location_not_available');
  String get addressLineHint => translate('address_line_hint');
  String get areaHint => translate('area_hint');
  String get cityHint => translate('city_hint');
  String get congratulations => translate('congratulations');
  String get businessReady => translate('business_ready');
  String get collection => translate('collection');
  String get addBank => translate('add_bank');
  String get addBanks => translate('add_banks');
  String get addEntriesMaintainKhata => translate('add_entries_maintain_khata');
  String get manageBankBalance => translate('manage_bank_balance');
  String get bill => translate('bill');
  String get addCustomers => translate('add_customers');
  String get sendPaymentReminders => translate('send_payment_reminders');
  String get addSuppliers => translate('add_suppliers');
  String get managePurchases => translate('manage_purchases');
  String get sale => translate('sale');
  String get digiPos => translate('digi_pos');
  String get money => translate('money');
  String get business => translate('business');
  String get createInvoice => translate('create_invoice');
  String get khata => translate('khata');
  String get language => translate('language');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ur', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
