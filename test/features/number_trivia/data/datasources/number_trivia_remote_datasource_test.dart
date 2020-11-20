import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/excepions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:matcher/matcher.dart';
import 'package:http/http.dart' as http;

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  NumberTriviaRemoteDataSourceImpl dataSourceImpl;
  MockHttpClient httpClient;

  setUp(() {
    httpClient = MockHttpClient();
    dataSourceImpl = NumberTriviaRemoteDataSourceImpl(client: httpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(httpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFail404() {
    when(httpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 404));
  }

  group('get concrete number trivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test('''should perfom a GET request on a URL 
            with number being the endpoint and with application/json ''',
        () async {
      //arrange
      setUpMockHttpClientSuccess200();
      //act
      dataSourceImpl.getConcreteNumberTrivia(tNumber);
      //assert
      verify(httpClient.get('http://numbersapi.com/$tNumber',
          headers: {'Content-Type': 'application/json'}));
    });

    test(
        'should return a NumberTrivia when the response code is 200 (success) ',
        () async {
      //arrange
      setUpMockHttpClientSuccess200();
      //act
      final result = await dataSourceImpl.getConcreteNumberTrivia(tNumber);
      //assert
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      //arrange
      setUpMockHttpClientFail404();
      //act
      final call = dataSourceImpl.getConcreteNumberTrivia;
      //assert
      expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
    });
  });

  group('get random number trivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test('''should perfom a GET request on a URL 
            with number being the endpoint and with application/json ''',
        () async {
      //arrange
      setUpMockHttpClientSuccess200();
      //act
      dataSourceImpl.getRandomNumberTrivia();
      //assert
      verify(httpClient.get('http://numbersapi.com/random',
          headers: {'Content-Type': 'application/json'}));
    });

    test(
        'should return a NumberTrivia when the response code is 200 (success) ',
        () async {
      //arrange
      setUpMockHttpClientSuccess200();
      //act
      final result = await dataSourceImpl.getRandomNumberTrivia();
      //assert
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      //arrange
      setUpMockHttpClientFail404();
      //act
      final call = dataSourceImpl.getRandomNumberTrivia;
      //assert
      expect(() => call(), throwsA(TypeMatcher<ServerException>()));
    });
  });
}
