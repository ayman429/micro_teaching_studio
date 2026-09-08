abstract class Either<L, R> {
  Either();

  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn);
}

class Left<L, R> extends Either<L, R> {
  final L value;

  Left(this.value);

  @override
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) {
    return leftFn(value);
  }
}

class Right<L, R> extends Either<L, R> {
  final R value;

  Right(this.value);

  @override
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) {
    return rightFn(value);
  }
}

extension EitherExtensions<L, R> on Either<L, R> {
  bool get isError => this is Left<L, R>;

  bool get isSuccess => this is Right<L, R>;

  R getOrThrow() {
    if (this is Right<L, R>) {
      return (this as Right<L, R>).value;
    } else {
      throw Exception("No value to return, this is a Left instance.");
    }
  }

  L throwError() {
    if (this is Left<L, R>) {
      return (this as Left<L, R>).value;
    } else {
      throw Exception("No error to throw, this is a Right instance.");
    }
  }
}
