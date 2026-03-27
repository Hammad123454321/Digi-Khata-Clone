/// Currency model with code, symbol, name, and logo mapping
class CurrencyModel {
  final String code;
  final String symbol;
  final String name;
  final String nameInUrdu;
  final String nameInArabic;
  final String logoAsset; // Asset path for currency-specific logo

  const CurrencyModel({
    required this.code,
    required this.symbol,
    required this.name,
    required this.nameInUrdu,
    required this.nameInArabic,
    required this.logoAsset,
  });

  /// Get currency name based on language
  String getName(String language) {
    switch (language) {
      case 'ur':
        return nameInUrdu;
      case 'ar':
        return nameInArabic;
      default:
        return name;
    }
  }

  /// All supported currencies
  static const List<CurrencyModel> supportedCurrencies = [
    // English regions
    CurrencyModel(
      code: 'USD',
      symbol: '\$',
      name: 'US Dollar',
      nameInUrdu: 'امریکی ڈالر',
      nameInArabic: 'الدولار الأمريكي',
      logoAsset: 'app-logo.jpeg', // Default logo
    ),
    CurrencyModel(
      code: 'GBP',
      symbol: '£',
      name: 'British Pound',
      nameInUrdu: 'برطانوی پاؤنڈ',
      nameInArabic: 'الجنيه الإسترليني',
      logoAsset: 'app-logo.jpeg',
    ),
    CurrencyModel(
      code: 'EUR',
      symbol: '€',
      name: 'Euro',
      nameInUrdu: 'یورو',
      nameInArabic: 'اليورو',
      logoAsset: 'app-logo.jpeg',
    ),
    CurrencyModel(
      code: 'AUD',
      symbol: 'A\$',
      name: 'Australian Dollar',
      nameInUrdu: 'آسٹریلوی ڈالر',
      nameInArabic: 'الدولار الأسترالي',
      logoAsset: 'app-logo.jpeg',
    ),
    CurrencyModel(
      code: 'CAD',
      symbol: 'C\$',
      name: 'Canadian Dollar',
      nameInUrdu: 'کینیڈین ڈالر',
      nameInArabic: 'الدولار الكندي',
      logoAsset: 'app-logo.jpeg',
    ),
    CurrencyModel(
      code: 'NZD',
      symbol: 'NZ\$',
      name: 'New Zealand Dollar',
      nameInUrdu: 'نیوزی لینڈ ڈالر',
      nameInArabic: 'الدولار النيوزيلندي',
      logoAsset: 'app-logo.jpeg',
    ),
    // Urdu regions
    CurrencyModel(
      code: 'PKR',
      symbol: 'Rs ',
      name: 'Pakistani Rupee',
      nameInUrdu: 'پاکستانی روپیہ',
      nameInArabic: 'الروبية الباكستانية',
      logoAsset: 'app-logo.jpeg',
    ),
    CurrencyModel(
      code: 'INR',
      symbol: '₹',
      name: 'Indian Rupee',
      nameInUrdu: 'بھارتی روپیہ',
      nameInArabic: 'الروبية الهندية',
      logoAsset: 'app-logo.jpeg',
    ),
    // Arabic regions
    CurrencyModel(
      code: 'SAR',
      symbol: '﷼',
      name: 'Saudi Riyal',
      nameInUrdu: 'سعودی ریال',
      nameInArabic: 'الريال السعودي',
      logoAsset: 'app-logo.jpeg',
    ),
    CurrencyModel(
      code: 'AED',
      symbol: 'د.إ',
      name: 'UAE Dirham',
      nameInUrdu: 'متحدہ عرب امارات درہم',
      nameInArabic: 'درهم إماراتي',
      logoAsset: 'app-logo.jpeg',
    ),
    CurrencyModel(
      code: 'QAR',
      symbol: '﷼',
      name: 'Qatari Riyal',
      nameInUrdu: 'قطری ریال',
      nameInArabic: 'الريال القطري',
      logoAsset: 'app-logo.jpeg',
    ),
    CurrencyModel(
      code: 'KWD',
      symbol: 'د.ك',
      name: 'Kuwaiti Dinar',
      nameInUrdu: 'کویتی دینار',
      nameInArabic: 'الدينار الكويتي',
      logoAsset: 'app-logo.jpeg',
    ),
    CurrencyModel(
      code: 'OMR',
      symbol: 'ر.ع.',
      name: 'Omani Rial',
      nameInUrdu: 'عمانی ریال',
      nameInArabic: 'الريال العماني',
      logoAsset: 'app-logo.jpeg',
    ),
    CurrencyModel(
      code: 'BHD',
      symbol: '.د.ب',
      name: 'Bahraini Dinar',
      nameInUrdu: 'بحرینی دینار',
      nameInArabic: 'الدينار البحريني',
      logoAsset: 'app-logo.jpeg',
    ),
    CurrencyModel(
      code: 'JOD',
      symbol: 'د.ا',
      name: 'Jordanian Dinar',
      nameInUrdu: 'اردنی دینار',
      nameInArabic: 'الدينار الأردني',
      logoAsset: 'app-logo.jpeg',
    ),
    CurrencyModel(
      code: 'EGP',
      symbol: 'ج.م',
      name: 'Egyptian Pound',
      nameInUrdu: 'مصری پاؤنڈ',
      nameInArabic: 'الجنيه المصري',
      logoAsset: 'app-logo.jpeg',
    ),
  ];

  /// Get currency by code
  static CurrencyModel? getByCode(String code) {
    try {
      return supportedCurrencies.firstWhere(
        (currency) => currency.code == code,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get default currency (PKR)
  static CurrencyModel getDefault() {
    return supportedCurrencies.firstWhere(
      (currency) => currency.code == 'PKR',
    );
  }
}
