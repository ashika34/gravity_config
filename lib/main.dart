import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/api_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/design_provider.dart';
import 'screens/login/login_screen.dart';
import 'screens/design_list/design_list_screen.dart';
import 'screens/configurator/configurator_screen.dart';

void main() {
  runApp(const ConfiguratorApp());
}

class ConfiguratorApp extends StatefulWidget {
  const ConfiguratorApp({super.key});

  @override
  State<ConfiguratorApp> createState() => _ConfiguratorAppState();
}

class _ConfiguratorAppState extends State<ConfiguratorApp> {
  late final ApiService _apiService;
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _authProvider = AuthProvider(_apiService);
    _authProvider.init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => DesignListProvider(_apiService)),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Gravity Configurator',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  if (auth.status == AuthStatus.authenticated) {
                    return MaterialPageRoute(
                      builder: (_) => const DesignListScreen(),
                    );
                  }
                  return MaterialPageRoute(builder: (_) => const LoginScreen());

                case '/designs':
                  return MaterialPageRoute(
                    builder: (_) => const DesignListScreen(),
                  );

                case '/get-started':
                  return MaterialPageRoute(builder: (_) => const LoginScreen());

                case '/configurator':
                  final id = settings.arguments as int;
                  return MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => DesignDetailProvider(_apiService),
                      child: ConfiguratorScreen(designId: id),
                    ),
                  );

                default:
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
              }
            },
          );
        },
      ),
    );
  }
}
