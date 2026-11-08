import 'package:flutter/material.dart';

class WidgetShowcaseScreen extends StatefulWidget {
  const WidgetShowcaseScreen({super.key});

  @override
  State<WidgetShowcaseScreen> createState() => _WidgetShowcaseScreenState();
}

class _WidgetShowcaseScreenState extends State<WidgetShowcaseScreen> {
  final TextEditingController _nameController = TextEditingController();

  bool _isEnabled = true;
  String _message = 'Welcome to Flutter!';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top 10 Flutter Widgets'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Widget Showcase Screen',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Explore 10 commonly used Flutter widgets.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // 1. Text
                _section(
                  '1. Text',
                  const Text('Hello! This is a Text widget.'),
                ),

                // 2. ElevatedButton
                _section(
                  '2. ElevatedButton',
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _message = 'Button clicked successfully!';
                      });
                    },
                    child: const Text('Click Me'),
                  ),
                ),

                // 3. Icon
                _section(
                  '3. Icon',
                  const Icon(
                    Icons.flutter_dash,
                    size: 40,
                    color: Colors.indigo,
                  ),
                ),

                // 4. Container
                _section(
                  '4. Container',
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('A decorated Container'),
                  ),
                ),

                // 5. Row
                _section(
                  '5. Row',
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.home),
                      Icon(Icons.search),
                      Icon(Icons.settings),
                    ],
                  ),
                ),

                // 6. Column
                _section(
                  '6. Column',
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('First item'),
                      Text('Second item'),
                      Text('Third item'),
                    ],
                  ),
                ),

                // 7. Card
                _section(
                  '7. Card',
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.school),
                      title: Text('Flutter Learning'),
                      subtitle: Text('Example of a Card widget'),
                    ),
                  ),
                ),

                // 8. Image
                _section(
                  '8. Image',
                  Image.network(
                    'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported, size: 60);
                    },
                  ),
                ),

                // 9. TextField
                _section(
                  '9. TextField',
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Enter your name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                ),

                // 10. Switch
                _section(
                  '10. Switch',
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable setting'),
                    value: _isEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isEnabled = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),
                Card(
                  color: Colors.indigo.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        _nameController.text.isEmpty
                            ? _message
                            : 'Hello, ${_nameController.text}!',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
