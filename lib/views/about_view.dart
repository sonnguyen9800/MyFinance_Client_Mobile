import 'package:flutter/material.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(
              Icons.account_balance_wallet,
              size: 50,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'MyFinance (alpha)',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Text(
            'Version 0.0.1',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildInfoCard(
            title: 'About MyFinance (alpha)',
            content:
                'MyFinance is a self-host, personal expense tracking app designed for families. '
                'It helps you manage your expenses, track spending patterns, and '
                'maintain financial transparency within your family group.\n',
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
              title: 'Disclaimer',
              content:
                  'The app is ongoing development, and it is still in alpha stage. So don\'t use it for serious financial matters yet.'
                  ' We are working hard to make it stable and secure. Please be patient and report any bugs or issues you find. We appreciate your feedback and suggestions.'),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Features',
            content: '''
• Multi-user support for family members
• Expense tracking with categories
• Detailed expense analytics
• Multiple currency support
• Customizable settings
• Secure data storage''',
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Privacy Policy',
            content:
                'We take your privacy seriously. All your financial data is encrypted '
                'and stored securely. We never share your personal information with '
                'third parties without your explicit consent.',
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Contact Us',
            content: '''
Email: sonnguyen9800@gmail.com
Website: www.sonnguyen9800.com''',
          ),
          const SizedBox(height: 32),
          const Text(
            '© 2024 MyFinance. All rights reserved.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
