import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languages = [
      {"name": "English", "flag": "🇬🇧"},
      {"name": "Kiswahili", "flag": "🇹🇿"},
      {"name": "Luganda", "flag": "🇺🇬"},
      {"name": "Acholi", "flag": ""},
      {"name": "Lango", "flag": ""},
      {"name": "Runyankole", "flag": ""},
      {"name": "Ateso", "flag": ""},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Choose Language")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: languages.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    return ListTile(
                      leading: Text(lang["flag"]!, style: const TextStyle(fontSize: 24)),
                      title: Text(lang["name"]!, 
                        style: Theme.of(context).textTheme.bodyLarge),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Logic to save language
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // context.push('/login');
                  },
                  child: const Text("CONTINUE"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}