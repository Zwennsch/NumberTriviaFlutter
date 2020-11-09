// import 'dart:html';

import 'package:number_trivia/core/error/excepions.dart';
import 'package:number_trivia/core/platform/network_info.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_loal_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/core/error/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:number_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:meta/meta.dart';

typedef Future<NumberTrivia> _ConcreteOrRandomChooser();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaLocalDatasource localDatasource;
  final NumberTriviaRemoteDataSource remoteDatasource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl(
      {@required this.localDatasource,
      @required this.networkInfo,
      @required this.remoteDatasource});

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
      int number) async {
    return await _getTrivia(() => remoteDatasource.getConcreteNumberTrivia(number));
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    return await _getTrivia(() => remoteDatasource.getRandomNumberTrivia());
  }

  Future<Either<Failure, NumberTrivia>> _getTrivia(
      _ConcreteOrRandomChooser getConcreteOrRandom) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteNumberTrivia = await getConcreteOrRandom();
        localDatasource.cacheNumberTrivia(remoteNumberTrivia);
        return Right(remoteNumberTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localNumberTriva = await localDatasource.getLastNumberTrivia();
        return Right(localNumberTriva);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
