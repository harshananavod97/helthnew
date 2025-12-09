import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:health_fit_strong/Screens/BokkingConfirmScreen.dart';
import 'package:health_fit_strong/Screens/BookingScreen.dart';
import 'package:health_fit_strong/Screens/CalenderScreen.dart';
import 'package:health_fit_strong/Screens/EditProfileScreen.dart';
import 'package:health_fit_strong/Screens/HomeScreen.dart';
import 'package:health_fit_strong/Screens/RegisterScreen.dart' show RegisterScreen;
import 'package:health_fit_strong/Screens/ReviewScreen.dart';
import 'package:health_fit_strong/Screens/ServiceDetailScreen.dart';
import 'package:health_fit_strong/Screens/loginScreen.dart';
import 'package:health_fit_strong/Screens/profileScreen.dart';
import 'package:health_fit_strong/Screens/serviceList.dart';
import 'package:health_fit_strong/Screens/splashscreen.dart';
import 'package:health_fit_strong/config/apptheme.dart';
import 'package:health_fit_strong/config/firebaseoptions.dart';
import 'package:health_fit_strong/provider/Bookingprovider.dart';
import 'package:health_fit_strong/provider/ReviewProvider.dart';
import 'package:health_fit_strong/provider/User%20provider.dart';
import 'package:health_fit_strong/provider/authprovider.dart';
import 'package:health_fit_strong/provider/serviceProvider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const HealthFitStrongApp());
}

class HealthFitStrongApp extends StatelessWidget {
  const HealthFitStrongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'Health Fit Strong',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            routerConfig: _router(authProvider),
          );
        },
      ),
    );
  }

  GoRouter _router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';
        final isSplash = state.matchedLocation == '/splash';

        if (isSplash) return null;
        if (!isLoggedIn && !isLoggingIn) return '/login';
        if (isLoggedIn && isLoggingIn) return '/';
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/services',
          builder: (context, state) => const ServicesListScreen(),
        ),
        GoRoute(
          path: '/service/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ServiceDetailScreen(serviceId: id);
          },
        ),
        GoRoute(
          path: '/booking/:serviceId',
          builder: (context, state) {
            final serviceId = state.pathParameters['serviceId']!;
            return BookingScreen(serviceId: serviceId);
          },
        ),
        GoRoute(
          path: '/booking-confirmation/:bookingId',
          builder: (context, state) {
            final bookingId = state.pathParameters['bookingId']!;
            return BookingConfirmationScreen(bookingId: bookingId);
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/edit-profile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/reviews/:serviceId',
          builder: (context, state) {
            final serviceId = state.pathParameters['serviceId']!;
            return ReviewsScreen(serviceId: serviceId);
          },
        ),
      ],
    );
  }
}