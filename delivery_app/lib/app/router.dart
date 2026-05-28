import 'package:delivery_app/features/auth/presentation/create_pin_screen.dart';
import 'package:delivery_app/features/profile/presentation/edit_profile_screen.dart';
import 'package:delivery_app/features/profile/presentation/payment_screen.dart';
import 'package:delivery_app/features/welcom/presentation/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:delivery_app/features/home/presentation/home_screen.dart';

import '../features/addresses/addres_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/pin_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/cart/presentation/cart_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/order/presentation/order_history_screen.dart';
import '../features/order/presentation/order_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/home/presentation/search_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/main':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/pin':
        return MaterialPageRoute(builder: (_) => const PinScreen());
      case '/create_pin':
        return MaterialPageRoute(builder: (_) => const CreatePinScreen());
      case '/order_history':
        return MaterialPageRoute(builder: (_) => const OrderHistoryScreen());
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case '/search':
        return MaterialPageRoute(builder: (_) => const SearchScreen());
        
      case '/edit-profile':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EditProfileScreen(profile: args),
        );

      case '/addresses':
        return MaterialPageRoute(builder: (_) => const AddressesScreen());
      case '/cart':
        return MaterialPageRoute(builder: (_) => const CartScreen());

      case '/payments':
        return MaterialPageRoute(builder: (_) => const PaymentScreen());
      // пример для будущих экранов:
      // case '/login':
      //   return MaterialPageRoute(builder: (_) => const LoginScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
