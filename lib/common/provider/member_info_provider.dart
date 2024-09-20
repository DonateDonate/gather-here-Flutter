import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/model/response/member_info_model.dart';
import 'package:gather_here/common/repository/member_repository.dart';

class MemberInfoState {
  MemberInfoModel? memberInfoModel;

  MemberInfoState({
    this.memberInfoModel,
  });
}

final memberInfoProvider =
    AutoDisposeStateNotifierProvider<MemberInfoProvider, MemberInfoState>(
        (ref) {
  final memberRepository = ref.watch(memberRepositoryProvider);

  return MemberInfoProvider(memberRepository: memberRepository);
});

class MemberInfoProvider extends StateNotifier<MemberInfoState> {
  final MemberRepository memberRepository;

  MemberInfoProvider({
    required this.memberRepository,
  }) : super(MemberInfoState());

  Future<MemberInfoModel?> getMyInfo() async {
    try {
      final memberInfo = await memberRepository.getMemberInfo();
      return memberInfo;
    } catch (e, stackTrace) {
      debugPrint('getMyInfo: $e, $stackTrace');
      return null;
    }
  }
}
