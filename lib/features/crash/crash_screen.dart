import 'package:flutter/material.dart';

import '../../global_components/widgets/app_button.dart';

class CrashScreen extends StatelessWidget {
  static const String routeName = '/crash';

  const CrashScreen({
    super.key,
    this.message,
    this.onRefresh,
  });

  final String? message;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.refresh_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              if (message != null && message!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  message!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              AppButton(
                label: 'Refresh',
                onPressed: onRefresh ?? () => _defaultRefresh(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _defaultRefresh(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }
}
