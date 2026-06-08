import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../features/profile/profile_screen.dart';
import '../../features/profile/settings_screen.dart';

// Shell Wrappers
import '../widgets/main_shell.dart';
import '../widgets/dealer_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/home', // default to customer home
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoginRoute = state.uri.path == '/login';
      final isRegisterRoute = state.uri.path == '/register';

      // If user is not authenticated, let them browse guest screens or redirect to login for profile
      if (!isAuth) {
        if (state.uri.path == '/profile' || 
            state.uri.path == '/my-reviews' || 
            state.uri.path.startsWith('/dealer')) {
          return '/login';
        }
      }

      // If authenticated and on login/register, send them to their dashboard
      if (isAuth && (isLoginRoute || isRegisterRoute)) {
        if (authState.user?.role == 'dealer') {
          return '/dealer';
        }
        return '/home';
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
        builder: (context, state) => const RegisterScreen(),
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
