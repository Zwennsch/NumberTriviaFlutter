import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final List properties;
  Failure([this.properties]);
}

// General Failures:
class ServerFailure extends Failure {
  @override
  List<Object> get props => super.properties;
}

class CacheFailure extends Failure {
  @override
  List<Object> get props => super.properties;
}
