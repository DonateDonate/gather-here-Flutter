import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_here/common/model/response/member_info_model.dart';
import 'package:gather_here/common/repository/member_repository.dart';

final myPageProvider = AutoDisposeStateNotifierProvider<MyPageProvider, AsyncValue<MemberInfoModel>>((ref) {
  final myPageRepo = ref.watch(memberRepositoryProvider);
  return MyPageProvider(memberRepository: myPageRepo);
});

class MyPageProvider extends StateNotifier<AsyncValue<MemberInfoModel>> {
  final MemberRepository memberRepository;

  MyPageProvider({
    required this.memberRepository,
  }) : super(const AsyncValue.loading()); // 초기 상태를 로딩 상태로 설정

  Future<void> getMemberInfo() async {
    try {
      final memberInfo = await memberRepository.getMemberInfo();
      state = AsyncValue.data(memberInfo); // 데이터가 성공적으로 로드되었을 때
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace); // 에러가 발생했을 때
    }
  }
}
