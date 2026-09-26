import 'package:flutter/material.dart';

import 'watch_demo_controller.dart';

void main() {
  runApp(WatchKitDemoApp(controller: WatchDemoController()));
}

class WatchKitDemoApp extends StatelessWidget {
  const WatchKitDemoApp({super.key, required this.controller});

  final WatchDemoController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WatchKit Demo',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: WatchDemoHomePage(controller: controller),
    );
  }
}

class WatchDemoHomePage extends StatelessWidget {
  const WatchDemoHomePage({super.key, required this.controller});

  final WatchDemoController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WatchKit Demo')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatusCard(controller: controller),
            const SizedBox(height: 16),
            _ActionPanel(controller: controller),
            const SizedBox(height: 16),
            _CommandCard(lastCommand: controller.lastCommand),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.controller});

  final WatchDemoController controller;

  @override
  Widget build(BuildContext context) {
    final status = controller.coordinator.status;
    return Card(
      child: ListTile(
        leading: Icon(
          status.connected ? Icons.watch : Icons.watch_off,
          color: status.connected ? Colors.green : Colors.grey,
        ),
        title: Text('Status: ${status.kind.name}'),
        subtitle: Text('Activation: ${controller.activationState}'),
        trailing: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: controller.refresh,
        ),
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({required this.controller});

  final WatchDemoController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          icon: const Icon(Icons.send),
          label: const Text('Push context'),
          onPressed: controller.pushDemoContext,
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.bolt),
          label: const Text('Send message'),
          onPressed: controller.sendDemoMessage,
        ),
      ],
    );
  }
}

class _CommandCard extends StatelessWidget {
  const _CommandCard({required this.lastCommand});

  final Map<String, Object?>? lastCommand;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.watch),
        title: const Text('Last watch command'),
        subtitle: Text(lastCommand?.toString() ?? 'None yet'),
      ),
    );
  }
}
