import 'package:dartz/dartz.dart';
import 'package:finzi/domain/models/global/failure_model.dart';
import 'package:finzi/domain/models/global/success_model.dart';

/// This class is responsible for all the business logic related to the {{#pascalCase}}{{name}} Repository {{/pascalCase}}
abstract class {{#pascalCase}}{{name}} Repository {{/pascalCase}} {
  /// Get all sons of the current user
  Future<Either<Failure, Success>> getData();
}
