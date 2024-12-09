import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myfinance_client_flutter/config/theme/app_colors.dart';
import 'package:myfinance_client_flutter/config/theme/app_typography.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text('About',
            style: AppTypography.textTheme.headlineMedium!
                .copyWith(color: AppColors.primaryDark)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SvgPicture.asset(
            'assets/logo.svg',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 16),
          Text(
            'MyFinance (alpha)',
            style: AppTypography.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            'Version 0.0.1',
            style: AppTypography.textTheme.bodyMedium!.copyWith(
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
            content: 'Email (1): support@sisyphuslab.com\n'
                'Email (2): sonnguyen9800@gmail.com\n'
                'Website: www.sisyphuslab.com',
          ),
          const SizedBox(height: 32),
          _buildExtraInfoCard(title: "More"),
          Text(
            '© 2024 MyFinance. All rights reserved.',
            style: AppTypography.textTheme.bodyMedium!.copyWith(
              color: AppColors.primary,
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
              style: AppTypography.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: AppTypography.textTheme.bodyMedium!.copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtraInfoCard({required String title}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    launchUrl(
                      Uri.parse('https://github.com/sisyphuslab/myfinance'),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/github-mark.svg',
                    width: 45,
                    height: 45,
                    colorFilter: ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    launchUrl(
                      Uri.parse('https://github.com/sisyphuslab/myfinance'),
                    );
                  },
                  child: Icon(
                    Icons.home,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
