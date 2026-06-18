import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:colorcraft_paints/providers/auth_provider.dart';
import 'package:colorcraft_paints/core/routing/app_router.dart';
import 'package:colorcraft_paints/data/repositories/auth_repository.dart';
import 'package:colorcraft_paints/data/models/user_model.dart';
import 'package:colorcraft_paints/data/mock/mock_data.dart';

class FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => FakeHttpClient();
}

class FakeHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => FakeHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => FakeHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// 1x1 transparent PNG
final transparentImage = const <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

class FakeFirebaseAuth implements fb_auth.FirebaseAuth {
  @override
  fb_auth.User? get currentUser => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthRepository extends AuthRepository {
  UserModel? _fakeUser;
  bool shouldFail = false;

  FakeAuthRepository() : super(firebaseAuth: FakeFirebaseAuth());

  @override
  UserModel? get currentUser => _fakeUser;

  @override
  Future<UserModel> login(String emailOrPhone, String password) async {
    if (shouldFail) {
      throw Exception('Mock authentication failed');
    }
    if (emailOrPhone == 'vasavitraders2004@gmail.com') {
      _fakeUser = MockData.dealerUser;
      return _fakeUser!;
    }
    _fakeUser = MockData.customerUser;
    return _fakeUser!;
  }

  @override
  Future<void> logout() async {
    _fakeUser = null;
  }
}

void main() {
  testWidgets('Dealer login routing test', (WidgetTester tester) async {
    HttpOverrides.global = FakeHttpOverrides();
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      HttpOverrides.global = null;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakeAuthRepo = FakeAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepo),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            final router = ref.watch(routerProvider);
            return MaterialApp.router(
              routerConfig: router,
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial route is /home (customer home)
    final container = ProviderScope.containerOf(tester.element(find.byType(Consumer)));
    expect(container.read(routerProvider).routeInformationProvider.value.uri.path, '/home');
    
    // Simulate dealer login
    final success = await container.read(authStateProvider.notifier).login(
      'vasavitraders2004@gmail.com',
      'Ankith@2006',
    );

    expect(success, true);
    expect(container.read(authStateProvider).user?.role, 'dealer');

    // Pump widget tree to allow the router and redirect to process
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify current route
    expect(container.read(routerProvider).routeInformationProvider.value.uri.path, '/dealer');
  });
}
