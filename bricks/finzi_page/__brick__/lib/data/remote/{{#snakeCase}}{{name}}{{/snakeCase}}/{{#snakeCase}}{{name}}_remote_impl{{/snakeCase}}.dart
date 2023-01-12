import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:finzi/domain/models/global/failure_model.dart';
import 'package:finzi/domain/models/global/success_model.dart';
import 'package:finzi/domain/repository/{{#snakeCase}}{{name}}_repository{{/snakeCase}}.dart';
import 'package:finzi/presentation/utils/constants/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';

/// It's a class that implements the {{#pascalCase}}{{name}} Repository {{/pascalCase}} interface and it's methods
class {{#pascalCase}}{{name}} remote impl {{/pascalCase}} extends {{#pascalCase}}{{name}} Repository {{/pascalCase}} {
  @override
  Future<Either<Failure, Success>> getData() async {
    late Either<Failure, Success> result;

    final url = Uri.parse(
      '${dotenv.env['API_URL']}/endpoint',
    );
    final _accessToken =
        await const FlutterSecureStorage().read(key: FZConstants.accessToken);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'authorization': 'Bearer $_accessToken'
    };

    try {
      final res = await http.get(url, headers: headers);

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 || res.statusCode == 201) {
        result =
            const Right(Success(statusCode: 200, message: 'Everything good'));
      } else {
        result = Left(
          Failure(
            message: jsonDecode(res.body)['message'] as String,
            statusCode: res.statusCode,
          ),
        );
      }
    } on http.Response catch (e) {
      result = Left(
        Failure(
          message: FZConstants.httpErrorMsg,
          statusCode: e.statusCode,
        ),
      );
    } on SocketException catch (_) {
      result = const Left(
        Failure(
          message: 'Servicio no disponible temporalmente.',
          statusCode: 400,
        ),
      );
    } catch (e) {
      await Sentry.captureMessage(e.toString());
      result = const Left(
        Failure(
          message: 'Servicio no disponible temporalmente.',
          statusCode: 400,
        ),
      );
    }

    return result;
  }
}

