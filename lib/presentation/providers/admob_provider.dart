// ✅ PRESENTATION LAYER
// 📁 lib/presentation/providers/admob_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/admob_report_model.dart';
import '../../repository/admob_repository.dart';

// Repository Provider
final admobRepositoryProvider = Provider<AdmobRepository>((ref) {
  return AdmobRepository();
});

// State Provider
final admobProvider = StateNotifierProvider<AdmobNotifier, AsyncValue<List<AdmobReportModel>>>(
  (ref) {
    final repository = ref.watch(admobRepositoryProvider);
    return AdmobNotifier(repository);
  },
);

class AdmobNotifier extends StateNotifier<AsyncValue<List<AdmobReportModel>>> {
  final AdmobRepository _repository;

  AdmobNotifier(this._repository) : super(const AsyncValue.data([]));

  Future<void> loadReport(String accessToken, String publisherId) async {
    // 로딩 상태 시작
    state = const AsyncValue.loading();

    try {
      final result = await _repository.fetchAdmobReport(
        accessToken: accessToken,
        publisherId: publisherId,
      );

      // 성공 시 데이터 설정
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      // 오류 발생 시 에러 상태 설정
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // 상태 초기화 메서드
  void reset() {
    state = const AsyncValue.data([]);
  }
}
