import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/core/error/excepions.dart';
import 'package:number_trivia/core/error/failure.dart';
import 'package:number_trivia/core/platform/network_info.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_loal_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDatasource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocaDatasource extends Mock implements NumberTriviaLocalDatasource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepositoryImpl repository;
  MockRemoteDatasource mockRemoteDatasource;
  MockLocaDatasource mockLocaDatasource;
  MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockNetworkInfo = MockNetworkInfo();
    mockLocaDatasource = MockLocaDatasource();
    mockRemoteDatasource = MockRemoteDatasource();

    repository = NumberTriviaRepositoryImpl(
      remoteDatasource: mockRemoteDatasource,
      localDatasource: mockLocaDatasource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel(number: tNumber, text: "Test Text");
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;
    test('should check if the device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // act
      repository.getConcreteNumberTrivia(tNumber);
      // answewr
      verify(mockNetworkInfo.isConnected);
    });
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      test(
          'should return remote data when the call to remote data source is succesful ',
          () async {
        //arrange
        when(mockRemoteDatasource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(mockRemoteDatasource.getConcreteNumberTrivia(tNumber));
        expect(result, equals(Right(tNumberTrivia)));
      });
      test(
          'should cache the returned numberTrivia locally when the call to remote data source is succesful ',
          () async {
        //arrange
        when(mockRemoteDatasource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(mockRemoteDatasource.getConcreteNumberTrivia(tNumber));
        verify(mockLocaDatasource.cacheNumberTrivia(tNumberTriviaModel));
      });
      test(
          'should return a failure when the call to remote data source is unsuccesful ',
          () async {
        //arrange
        when(mockRemoteDatasource.getConcreteNumberTrivia(any))
            .thenThrow(ServerException());
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(mockRemoteDatasource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockLocaDatasource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      test(
          'should return last locally cached data when the cached data is present',
          () async {
        //arrange
        when(mockLocaDatasource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verifyZeroInteractions(mockRemoteDatasource);
        verify(mockLocaDatasource.getLastNumberTrivia());

        expect(result, equals(Right(tNumberTrivia)));
      });

      test(
          'should return CacheFailure when the cached data is not present',
          () async {
        //arrange
        when(mockLocaDatasource.getLastNumberTrivia())
            .thenThrow(CacheException());
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verifyZeroInteractions(mockRemoteDatasource);
        verify(mockLocaDatasource.getLastNumberTrivia());

        expect(result, equals(Left(CacheFailure())));
      });
    });
  });
}
