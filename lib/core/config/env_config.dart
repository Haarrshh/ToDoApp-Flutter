enum AppFlavor { dev, staging, qa, prod }

class EnvConfig {
  EnvConfig._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.appTitle,
  });

  final AppFlavor flavor;
  final String apiBaseUrl;
  final String appTitle;

  static AppFlavor _flavorFromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'dev':
        return AppFlavor.dev;
      case 'staging':
        return AppFlavor.staging;
      case 'qa':
        return AppFlavor.qa;
      case 'prod':
        return AppFlavor.prod;
      default:
        return AppFlavor.dev;
    }
  }

  static EnvConfig get instance {
    const flavor = String.fromEnvironment(
      'FLAVOR',
      defaultValue: 'dev',
    );
    return fromFlavor(_flavorFromString(flavor));
  }

  static EnvConfig fromFlavor(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.dev:
        return EnvConfig._(
          flavor: AppFlavor.dev,
          apiBaseUrl: 'https://jsonplaceholder.typicode.com',
          appTitle: 'To-Do (Dev)',
        );
      case AppFlavor.staging:
        return EnvConfig._(
          flavor: AppFlavor.staging,
          apiBaseUrl: 'https://jsonplaceholder.typicode.com',
          appTitle: 'To-Do (Staging)',
        );
      case AppFlavor.qa:
        return EnvConfig._(
          flavor: AppFlavor.qa,
          apiBaseUrl: 'https://jsonplaceholder.typicode.com',
          appTitle: 'To-Do (QA)',
        );
      case AppFlavor.prod:
        return EnvConfig._(
          flavor: AppFlavor.prod,
          apiBaseUrl: 'https://jsonplaceholder.typicode.com',
          appTitle: 'To-Do',
        );
    }
  }

  bool get isProduction => flavor == AppFlavor.prod;
}
