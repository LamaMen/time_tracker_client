import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:time_tracker_client/core/failure/failure.dart';
import 'package:time_tracker_client/data/api/api_provider.dart';
import 'package:time_tracker_client/data/models/progress/progress.dart';

@singleton
class ProgressRepository {
  final ApiProvider _provider;
  final format = DateFormat('yyyy-MM-dd');

  ProgressRepository(this._provider);

  Future<Either<Failure, List<Progress>>> fetchGeneral(
    bool isAdmin,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final range = <String, String>{};
    if (startDate != null) {
      range['start'] = format.format(startDate);
      range['end'] = format.format(endDate!);
    }

    try {
      if (isAdmin) {
        final api = _provider.getAdminService();
        final answer = await api.fetchGeneralProgress(range);
        return Right(answer);
      } else {
        final api = _provider.getUserService();
        final answer = await api.fetchGeneralProgress(range);
        return Right(answer);
      }
    } on DioError catch (e) {
      if (e.error is SocketException || e.error.contains('XMLHttpRequest')) {
        return const Left(NoInternetFailure());
      }

      switch (e.response?.statusCode) {
        case HttpStatus.internalServerError:
        case HttpStatus.badGateway:
          return const Left(ServerFailure());
        case HttpStatus.unauthorized:
          return const Left(WrongCredentialsFailure());
      }

      return const Left(UnknownFailure());
    }
  }
}
