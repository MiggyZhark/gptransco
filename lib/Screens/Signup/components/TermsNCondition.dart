import 'package:flutter/material.dart';
import '../../../constants.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions',style: headerTitle,),
        backgroundColor: gpSecondaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle('Acceptance of Terms'),
            _buildSectionContent(
              'By creating an account, making a booking, or otherwise accessing the Service, you agree to abide by these Terms. You are responsible for compliance with any applicable local laws.',
            ),
            _buildSectionTitle('Account Registration'),
            _buildSectionContent(
              'To make a booking, you may be required to create an account. You agree to provide accurate, current, and complete information during registration and to update your information as necessary. You are responsible for keeping your account password confidential and are liable for all activities that occur under your account.',
            ),
            _buildSectionTitle('Use of the Service'),
            _buildSectionContent(
              'You may use the Service only for lawful purposes and in accordance with these Terms. You agree not to:\n'
                  '• Violate any laws, rules, or regulations applicable to you,\n'
                  '• Impersonate or misrepresent your affiliation with any person or entity,\n'
                  '• Engage in any fraudulent, abusive, or harmful activity.',
            ),
            _buildSectionTitle('Booking and Payments'),
            _buildSectionContent(
              'When you make a booking through the Service:\n'
                  '• You agree to pay all applicable fees, taxes, and charges,\n'
                  '• You are responsible for ensuring that your payment information is accurate and up to date.',
            ),
            _buildSectionTitle('User Generated Content'),
            _buildSectionContent(
              'You may post reviews, feedback, or other content on the Service. By doing so, you grant us a worldwide, royalty-free, irrevocable license to use, reproduce, and display such content.',
            ),
            _buildSectionTitle('Modification and Cancellations by Us'),
            _buildSectionContent(
              'We reserve the right to modify, suspend, or terminate any part of the Service at our sole discretion. We may also cancel bookings if they violate these Terms.',
            ),
            _buildSectionTitle('Intellectual Property'),
            _buildSectionContent(
              'The Service and its original content are the property of GPTRANSCO and are protected by copyright, trademark, and other laws.',
            ),
            _buildSectionTitle('Limitation of Liability'),
            _buildSectionContent(
              'To the maximum extent permitted by law, GPTRANSCO shall not be liable for any indirect, incidental, special, or consequential damages.',
            ),
            _buildSectionTitle('Changes to Terms'),
            _buildSectionContent(
              'We reserve the right to update these Terms at any time. Continued use of the Service following any changes constitutes your acceptance of the revised Terms.',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget to build section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Widget to build section content
  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        content,
        style: const TextStyle(fontSize: 16, height: 1.5),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
