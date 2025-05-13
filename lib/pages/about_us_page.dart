import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  void _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'v${info.version} (${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset('assets/creator.png', width: 120, height: 120),
            ),
            const SizedBox(height: 16),
            const Text('Founder BrainWaveTech', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Mechatronics Engineer'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('+94 72 853 4197'),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('dhanushka.fiver.lk@gmail.com'),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('GitHub'),
              onTap: () => _launchUrl('https://github.com/dhanushka47'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Support / Donations',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: const [
                    Text('Bank: Bank Of Ceylon - Sri Lanka'),
                    Text('Branch: Dankotuwa'),
                    Text('Account No: 71509738'),
                    Text('Account Holder: dhanushka udaya kumara'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            Text(
              'App Version $_version',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
