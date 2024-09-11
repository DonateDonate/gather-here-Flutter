import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:gather_here/common/model/request/room_create_model.dart';
import 'package:gather_here/common/model/request/room_exit_model.dart';
import 'package:retrofit/http.dart';

import 'package:gather_here/common/const/const.dart';
import 'package:gather_here/common/dio/dio.dart';
import 'package:gather_here/common/model/request/room_join_model.dart';
import 'package:gather_here/common/model/response/room_response_model.dart';

part 'room_repository.g.dart';

final roomRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return RoomRepository(dio, baseUrl: Const.baseUrl + '/rooms');
});

// http://ec2-13-124-216-179.ap-northeast-2.compute.amazonaws.com:8080/rooms
@RestApi()
abstract class RoomRepository {
  factory RoomRepository(Dio dio, {String baseUrl}) = _RoomRepository;

  @Headers({
    'accessToken': 'true',
  })
  @POST('/join')
  Future<RoomResponseModel> postJoinRoom({
    @Body() required RoomJoinModel body,
  });

  @Headers({
    'accessToken': 'true',
  })
  @POST('')
  Future<RoomResponseModel> postCreateRoom({
    @Body() required RoomCreateModel body,
  });

  @Headers({
    'accessToken': 'true',
  })
  @POST('/exit')
  Future<void> postExitRoom({
    @Body() required RoomExitModel body,
  });
}
