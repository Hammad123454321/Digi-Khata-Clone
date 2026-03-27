import 'package:flutter/material.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final tabIndex = initialTabIndex.clamp(0, 1);

    return DefaultTabController(
      length: 2,
      initialIndex: tabIndex,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          iconTheme: const IconThemeData(color: Colors.white),
          titleSpacing: 0,
          title: Text(
            loc.legal,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: loc.privacyPolicy),
              Tab(text: loc.termsOfService),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _LegalContent(
              sections: _privacySections(loc),
            ),
            _LegalContent(
              sections: _termsSections(loc),
            ),
          ],
        ),
      ),
    );
  }

  List<_LegalSection> _privacySections(AppLocalizations loc) {
    final appName = loc.appName;
    return [
      _LegalSection(
        title: loc.privacyPolicy,
        lines: [
          '$appName helps you manage customers, suppliers, invoices, stock, and cash flow.',
          'This policy explains what data we handle and how we use it.',
        ],
      ),
      _LegalSection(
        title: 'Data We Collect',
        lines: [
          'Account details like name, phone number, and email address.',
          'Business, customer, supplier, invoice, stock, and transaction data you enter.',
          'Device and usage information used for security and analytics.',
          'Optional notes or attachments you add to records.',
        ],
      ),
      _LegalSection(
        title: 'How We Use Data',
        lines: [
          'Provide core app features, sync, and reports.',
          'Send reminders or messages only when you request them.',
          'Protect your data, prevent misuse, and improve reliability.',
        ],
      ),
      _LegalSection(
        title: 'Sharing',
        lines: [
          'We share data only with service providers needed to run the app (hosting, messaging).',
          'We do not sell your personal or business data.',
        ],
      ),
      _LegalSection(
        title: 'Your Choices',
        lines: [
          'You can update or delete your business data inside the app.',
          'If you need account deletion, contact the business owner or administrator.',
        ],
      ),
    ];
  }

  List<_LegalSection> _termsSections(AppLocalizations loc) {
    final appName = loc.appName;
    return [
      _LegalSection(
        title: loc.termsOfService,
        lines: [
          'By using $appName, you agree to these terms.',
          'If you do not agree, please stop using the app.',
        ],
      ),
      _LegalSection(
        title: 'Your Responsibilities',
        lines: [
          'Provide accurate information and keep your credentials secure.',
          'Ensure you have the right to store customer and supplier data.',
        ],
      ),
      _LegalSection(
        title: 'Acceptable Use',
        lines: [
          'Do not use the app for illegal activity or to send unauthorized messages.',
          'Do not attempt to disrupt or access systems you do not own.',
        ],
      ),
      _LegalSection(
        title: 'Availability',
        lines: [
          'We work to keep the service reliable, but availability can vary.',
          'Features may change or be updated over time.',
        ],
      ),
      _LegalSection(
        title: 'Limitation of Liability',
        lines: [
          'Use the app at your own risk and keep independent backups of critical data.',
          'We are not liable for indirect or incidental damages.',
        ],
      ),
    ];
  }
}

class _LegalContent extends StatelessWidget {
  const _LegalContent({required this.sections});

  final List<_LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...section.lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '- $line',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LegalSection {
  const _LegalSection({required this.title, required this.lines});

  final String title;
  final List<String> lines;
}
