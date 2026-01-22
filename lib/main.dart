import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_colors.dart';
import 'data/datasources/local_datasource.dart';
import 'data/repositories/selfcare_repository_impl.dart';
import 'presentation/providers/selfcare_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/journey/journey_screen.dart';
import 'presentation/screens/prefs/prefs_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Indonesian locale for date formatting
  await initializeDateFormatting('id_ID', null);
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Create datasource and repository
  final datasource = LocalDatasource(prefs);
  final repository = SelfCareRepositoryImpl(datasource);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SelfCareProvider(repository),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const MainScreen(),
        );
      },
    );
  }
}

class _AppBackground extends StatelessWidget {

  const _AppBackground();



  @override

  Widget build(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(

      decoration: BoxDecoration(

        gradient: LinearGradient(

          colors: isDark

              ? [AppColors.primaryDark, AppColors.backgroundDark]

              : [AppColors.primaryLight, AppColors.surface],

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

        ),

      ),

    );

  }

}



class MainScreen extends StatefulWidget {

  const MainScreen({super.key});



  @override

  State<MainScreen> createState() => _MainScreenState();

}



class _MainScreenState extends State<MainScreen> {

  int _currentIndex = 0;



  final List<Widget> _screens = const [

    HomeScreen(),

    JourneyScreen(),

    PrefsScreen(),

  ];



  @override

  Widget build(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(

      children: [

        const _AppBackground(),

        Scaffold(

          body: IndexedStack(

            index: _currentIndex,

            children: _screens,

          ),

          bottomNavigationBar: BottomNavigationBar(

            currentIndex: _currentIndex,

            onTap: (index) => setState(() => _currentIndex = index),

            type: BottomNavigationBarType.fixed,

            backgroundColor: isDark ? Colors.black.withAlpha(77) : Colors.white.withAlpha(77),

            selectedItemColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,

            unselectedItemColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,

            elevation: 0,

            items: const [

              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: AppStrings.navHome),

              BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: AppStrings.navJourney),

              BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: AppStrings.navPrefs),

            ],

          ),

        ),

      ],

    );

  }

}
