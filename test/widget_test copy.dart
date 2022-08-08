// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medium_mate/preferences/preferences_repository.dart';
import 'package:medium_mate/services/medium_service.dart';
import 'package:medium_mate/services/medium_service_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements http.Client {}

class MockPreferences extends Mock implements PreferencesRepository {}

void main() {
  MediumService sut;
  WidgetsFlutterBinding.ensureInitialized();
  MockClient mockClient;
  MockPreferences mockPreferences;

  setUp(() async {
    mockClient = MockClient();
    mockPreferences = MockPreferences();
    logInvocations([mockClient, mockPreferences]);
    // locator.registerSingleton<http.Client>(mockClient);
    // locator.registerSingleton<PreferencesService>(mockPreferences);
    sut = MediumServiceImpl();
  });

  tearDown(() {
    sut = null;
  });

  test('returns a userId if initUser is called with valid token', () async {
    when(mockClient.get('https://api.medium.com/v1/me',
        headers: {'authorization': 'Bearer 123123'})).thenAnswer((_) async {
      return http.Response('{"userId": "alf147"}', 200);
    });
    when(mockPreferences.setToken('123123')).thenAnswer((_) async => true);
    when(mockPreferences.setUserId('alf147')).thenAnswer((_) async => true);

    expect(await sut.initUser("123123"), 'alf147');
    verify(mockPreferences.setToken('123123')).called(1);
    verify(mockPreferences.setUserId('alf147')).called(1);
  });

  test('returns a userId if initUser is called with invalid token', () async {
    when(mockClient.get('https://api.medium.com/v1/me',
        headers: {'authorization': 'Bearer 123123'})).thenAnswer((_) async {
      return http.Response(
          '{"errors":[{"message":"Token was invalid.","code":6003}]}', 401);
    });

    expect(await sut.initUser("123123"), '');
    verifyNever(mockPreferences.setToken(any));
    verifyNever(mockPreferences.setUserId(any));
  });

  test('returns a postUrl if postArticle is called with valid arguments',
      () async {
    when(mockClient.post('https://api.medium.com/v1/users/alf147/posts',
            headers: {'authorization': 'Bearer 123123'},
            body: anyNamed('body')))
        .thenAnswer((parameters) async {
      print("matched! with parameters: ${parameters.namedArguments}");
      return http.Response('{"data": {"url": "thePostUrl"}}', 200);
    });
    when(mockPreferences.getToken()).thenAnswer((_) async => '123123');
    when(mockPreferences.getUserId()).thenAnswer((_) async => 'alf147');

    expect(await sut.postArticle(PostModel('title', 'content', 'tag1')),
        'thePostUrl');
  });

  test('returns a postUrl if postArticle is called with invalid arguments',
      () async {
    when(mockClient.post('https://api.medium.com/v1/users/alf147/posts',
            headers: {'authorization': 'Bearer 123123'},
            body: anyNamed('body')))
        .thenAnswer((parameters) async {
      print("matched! with parameters: ${parameters.namedArguments}");
      return http.Response('{"data": {"url": "thePostUrl"}}', 200);
    });
    when(mockPreferences.getToken()).thenAnswer((_) async => '123123');
    when(mockPreferences.getUserId()).thenAnswer((_) async => 'alf147');

    expect(await sut.postArticle(PostModel('title', 'content', 'tag1')),
        'thePostUrl');
  });
}
