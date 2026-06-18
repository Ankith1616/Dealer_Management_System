import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/product_model.dart';

// Import all screens directly
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/products/product_catalog_screen.dart';
import '../../features/products/product_detail_screen.dart';
import '../../features/comparison/comparison_screen.dart';
import '../../features/budget/budget_calculator_screen.dart';
import '../../features/feedback/submit_review_screen.dart';
import '../../features/feedback/reviews_list_screen.dart';
import '../../features/feedback/my_reviews_screen.dart';
import '../../features/dealer/dealer_dashboard.dart';
import '../../features/dealer/manage_products_screen.dart';
import '../../features/dealer/add_edit_product_screen.dart';
import '../../features/dealer/review_management_screen.dart';
import '../../features/dealer/new_launch_screen.dart';
import '../../features/dealer/complaint_management_screen.dart';
import '../../features/dealer/dealer_logs_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/settings_screen.dart';

// Shell Wrappers
import '../widgets/main_shell.dart';
import '../widgets/dealer_shell.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated ||
          previous?.isLoading != next.isLoading ||
          previous?.user != next.user) {
        notifyListeners();
      }
    });
  }
}

final routerNotifierProvider = Provider((ref) => RouterNotifier(ref));

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/home', // default to customer home
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isAuth = authState.isAuthenticated;
      final isLoginRoute = state.uri.path == '/login';
      final isRegisterRoute = state.uri.path == '/register';

      // If user is not authenticated, let them browse guest screens or redirect to login for profile/settings/budget/reviews/feedback/dealer
      if (!isAuth) {
        if (state.uri.path == '/profile' || 
            state.uri.path == '/settings' || 
            state.uri.path == '/budget' || 
            state.uri.path == '/my-reviews' || 
            state.uri.path.startsWith('/reviews') || 
            state.uri.path.startsWith('/feedback') || 
            state.uri.path.startsWith('/dealer')) {
          return '/login';
        }
      }

      // If authenticated
      if (isAuth) {
        final isDealer = authState.user?.role == 'dealer';

        // 1. If on login/register, send them to their dashboard
        if (isLoginRoute || isRegisterRoute) {
          if (isDealer) {
            return '/dealer';
          }
          return '/home';
        }

        // 2. If dealer trying to access customer-facing routes, redirect them to the corresponding dealer routes
        if (isDealer) {
          final path = state.uri.path;
          if (path == '/home' || path == '/' || path == '/compare' || path == '/budget') {
            return '/dealer';
          }
          if (path == '/profile') {
            return '/dealer/profile';
          }
          if (path == '/settings') {
            return '/dealer/settings';
          }
          if (path.startsWith('/products')) {
            return '/dealer/products';
          }
        } else {
          // If customer trying to access dealer routes, redirect to customer home
          if (state.uri.path.startsWith('/dealer')) {
            return '/home';
          }
        }
      }
      
      return null;
    },
    routes: [
      // Flat Authentication routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'];
          return RegisterScreen(initialPhone: phone);
        },
      ),

      // Customer Shell Route (Main Shell with persistent navigation)
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(
            currentPath: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) {
              final category = state.uri.queryParameters['category'];
              return ProductCatalogScreen(categoryFilter: category);
            },
          ),
          GoRoute(
            path: '/compare',
            builder: (context, state) => const ComparisonScreen(),
          ),
          GoRoute(
            path: '/budget',
            builder: (context, state) => const BudgetCalculatorScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Dealer Shell Route (Dealer Shell with persistent navigation)
      ShellRoute(
        builder: (context, state, child) {
          return DealerShell(
            currentPath: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dealer',
            builder: (context, state) => const DealerDashboard(),
          ),
          GoRoute(
            path: '/dealer/products',
            builder: (context, state) => const ManageProductsScreen(),
          ),
          GoRoute(
            path: '/dealer/reviews',
            builder: (context, state) => const ReviewManagementScreen(),
          ),
          GoRoute(
            path: '/dealer/new-launch',
            builder: (context, state) => const NewLaunchScreen(),
          ),
          GoRoute(
            path: '/dealer/complaints',
            builder: (context, state) => const ComplaintManagementScreen(),
          ),
          GoRoute(
            path: '/dealer/logs',
            builder: (context, state) => const DealerLogsScreen(),
          ),
          GoRoute(
            path: '/dealer/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/dealer/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // Standalone Detail and Form routes (with custom back buttons)
      GoRoute(
        path: '/products/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/feedback/submit/:productId',
        builder: (context, state) {
          final id = state.pathParameters['productId']!;
          return SubmitReviewScreen(productId: id);
        },
      ),
        GoRoute(
          path: '/feedback/submit',
          builder: (context, state) {
            return const SubmitReviewScreen();
          },
        ),
      GoRoute(
        path: '/reviews',
        builder: (context, state) => const ReviewsListScreen(),
      ),
      GoRoute(
        path: '/my-reviews',
        builder: (context, state) => const MyReviewsScreen(),
      ),
      GoRoute(
        path: '/dealer/products/add',
        builder: (context, state) {
          final productToEdit = state.extra as ProductModel?;
          return AddEditProductScreen(productToEdit: productToEdit);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
