// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medium_mate/models/post_model.dart';
import 'package:medium_mate/preferences/preferences_repository.dart';
import 'package:medium_mate/services_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements IOClient {
  // @override
  // noSuchMethod(Invocation invocation) {
  //   print('MockClient: namedArguments: ${invocation.namedArguments}');
  //   print('MockClient: positionalArguments: ${invocation.positionalArguments}');
  //   return super.noSuchMethod(invocation);
  // }
}

class MockPreferences extends Mock implements PreferencesRepository {}

void main() {
  ServicesRepository sut;
  WidgetsFlutterBinding.ensureInitialized();
  MockClient mockClient;
  MockPreferences mockPreferences;

  setUp(() async {
//    mockPreferences = MockPreferences();
//    logInvocations([mockClient, mockPreferences]);
    // locator.registerSingleton<http.Client>(mockClient);
    // locator.registerSingleton<PreferencesService>(mockPreferences);
//    sut = ServicesRepository(mockClient, mockPreferences);
  });

  test('returns a userId if getUserId is called with valid token', () async {
    mockClient = MockClient();
    mockPreferences = MockPreferences();
    sut = ServicesRepository(mockClient, mockPreferences);
    when(() => mockClient.get(Uri.parse('https://api.medium.com/v1/me'),
        headers: {'authorization': 'Bearer 123123'})).thenAnswer((_) async {
      return http.Response('''
{
  "data": {
    "id": "5303d74c64f66366f00cb9b2a94f3251bf5",
    "username": "majelbstoat",
    "name": "Jamie Talbot",
    "url": "https://medium.com/@majelbstoat",
    "imageUrl": "https://images.medium.com/0*fkfQiTzT7TlUGGyI.png"
  }
}
''', 200);
    });
    // when(() => mockPreferences.setMediumToken('123123'))
    //     .thenAnswer((_) async => true);
    // when(() => mockPreferences.setMediumUserId('alf147'))
    //     .thenAnswer((_) async => true);

    expect(
        await sut.getUserId("123123"), '5303d74c64f66366f00cb9b2a94f3251bf5');
  });

  test('returns no userId if getUserId is called with invalid token', () async {
    mockClient = MockClient();
    mockPreferences = MockPreferences();
    sut = ServicesRepository(mockClient, mockPreferences);
    when(() => mockClient.get(Uri.parse('https://api.medium.com/v1/me'),
        headers: {'authorization': 'Bearer 123123'})).thenAnswer((_) async {
      return http.Response(
          '{"errors":[{"message":"Token was invalid.","code":6003}]}', 401);
    });

    expect(await sut.getUserId("123123"), '');
  });

  test('returns a postUrl if postArticle is called with valid arguments',
      () async {
    mockClient = MockClient();
    mockPreferences = MockPreferences();
    sut = ServicesRepository(mockClient, mockPreferences);

    when(
      () => mockClient.post(
        Uri.parse('https://api.medium.com/v1/users/the-userId/posts'),
        headers: {
          'authorization': 'Bearer 123123',
          'Content-Type': 'application/json'
        },
        body: any(named: 'body'),
        encoding: any(named: 'encoding'),
      ),
    ).thenAnswer((parameters) async {
//      print("matched! with parameters: ${parameters.namedArguments}");
      return http.Response('{"data": {"url": "thePostUrl"}}', 200);
    });

    final response = await sut.postArticle(
        PostModel(
          'title',
          'content',
          'tag1',
          'the-userId',
        ),
        '123123');
    expect(response, 'thePostUrl');
  });

  test('returns no postUrl if postArticle is called with invalid arguments',
      () async {
    mockClient = MockClient();
    mockPreferences = MockPreferences();
    sut = ServicesRepository(mockClient, mockPreferences);

    when(
      () => mockClient.post(
        Uri.parse('https://api.medium.com/v1/users/the-userId/posts'),
        headers: {'authorization': 'Bearer 123123'},
        body: any(named: 'body'),
      ),
    ).thenAnswer((parameters) async {
      print("matched! with parameters: ${parameters.namedArguments}");
      return http.Response(
          '{"errors":[{"message":"Token was invalid.","code":6003}]}', 401);
    });

    final response = await sut.postArticle(
        PostModel(
          'title',
          'content',
          'tag1',
          'the-userId',
        ),
        '123123');
    expect(response, '');
  });
}
