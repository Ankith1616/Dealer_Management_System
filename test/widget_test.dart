import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:colorcraft_paints/app.dart';
import 'package:colorcraft_paints/providers/auth_provider.dart';
import 'package:colorcraft_paints/data/repositories/auth_repository.dart';
import 'package:colorcraft_paints/data/models/user_model.dart';

class FakeFirebaseAuth implements fb_auth.FirebaseAuth {
  @override
  fb_auth.User? get currentUser => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthRepository extends AuthRepository {
  UserModel? _fakeUser;

  FakeAuthRepository() : super(firebaseAuth: FakeFirebaseAuth());

  @override
  UserModel? get currentUser => _fakeUser;
}

// Standard mock for NetworkImage requests in widget tests
class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  String? userAgent;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => MockHttpClientRequest();
}

class MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  bool persistentConnection = true;

  bool autoUncompress = true;

  @override
  final HttpHeaders headers = MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => MockHttpClientResponse();
}

class MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
  
  @override
  List<String>? operator [](String name) => null;
}

class MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  String get reasonPhrase => 'OK';

  @override
  int get contentLength => -1;

  bool get autoUncompress => true;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  final HttpHeaders headers = MockHttpHeaders();

  @override
  final List<RedirectInfo> redirects = const [];

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => true;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    // 1x1 transparent PNG bytes
    final bytes = [
      137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0,
      1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 204, 89, 0, 0, 0, 13, 73, 68, 65,
      84, 120, 156, 99, 96, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0,
      73, 69, 78, 68, 174, 66, 96, 130
    ];
    return Stream<List<int>>.fromIterable([bytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    final fakeAuthRepo = FakeAuthRepository();

    // Build our app under ProviderScope and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepo),
        ],
        child: const ColorCraftApp(),
      ),
    );

    // Let GoRouter initialize and start navigating
    await tester.pump();

    // Advance the virtual clock by 1 second to resolve the mock repository network delays (max 500ms)
    await tester.pump(const Duration(seconds: 1));

    // Wait for all route transitions and animations to finish settling
    await tester.pumpAndSettle();

    // Verify that the app starts up without crash
    expect(tester.takeException(), isNull);
  });
}

