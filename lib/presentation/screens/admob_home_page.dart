// 📁 lib/presentation/screens/admob_home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../model/admob_report_model.dart';
import '../providers/admob_provider.dart';

class AdmobHomePage extends ConsumerStatefulWidget {
  const AdmobHomePage({super.key});

  @override
  ConsumerState<AdmobHomePage> createState() => _AdmobHomePageState();
}

class _AdmobHomePageState extends ConsumerState<AdmobHomePage> {
  bool _isLoading = false;
  String? _userEmail;
  GoogleSignIn? _googleSignIn;

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn(
      scopes: ['https://www.googleapis.com/auth/admob.readonly'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(admobProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AdMob 수익 대시보드'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (_userEmail != null) ...[
            // 사용자 정보 표시
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  _userEmail!.split('@')[0], // 이메일 앞부분만 표시
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            // 로그아웃 버튼
            IconButton(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              tooltip: '로그아웃',
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 상태 정보 카드
              _buildStatusCard(),

              const SizedBox(height: 16),

              // 로그인 버튼 (로그인되지 않은 경우에만)
              if (_userEmail == null) ...[
                _buildLoginButton(),
                const SizedBox(height: 16),
              ],

              // 수익 요약 카드 (데이터가 있는 경우)
              if (report.hasValue && report.value!.isNotEmpty) ...[
                _buildSummaryCard(report.value!),
                const SizedBox(height: 16),
              ],

              // 결과 표시 영역
              Expanded(
                child: _buildResultSection(report),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _userEmail != null
          ? FloatingActionButton(
              onPressed: _isLoading ? null : _refreshData,
              backgroundColor: Colors.blue,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _userEmail != null ? Icons.check_circle : Icons.info,
              color: _userEmail != null ? Colors.green : Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userEmail != null ? '로그인됨' : '로그인 필요',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _userEmail != null ? '토큰은 약 1시간 동안 유효합니다' : 'Google 계정으로 로그인하여 AdMob 데이터를 확인하세요',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.login),
        label: Text(
          _isLoading ? '로그인 중...' : 'Google로 로그인',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(List<AdmobReportModel> data) {
    final totalEarnings = data.fold<double>(0, (sum, item) => sum + item.earnings);
    final totalClicks = data.fold<int>(0, (sum, item) => sum + item.clicks);
    final totalImpressions = data.fold<int>(0, (sum, item) => sum + item.impressions);
    final avgCtr = totalImpressions > 0 ? (totalClicks / totalImpressions) * 100 : 0.0;

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 지난 7일 요약',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('총 수익', '\$${totalEarnings.toStringAsFixed(2)}', Colors.green),
                _buildSummaryItem('총 클릭', totalClicks.toString(), Colors.blue),
                _buildSummaryItem('총 노출', totalImpressions.toString(), Colors.orange),
                _buildSummaryItem('평균 CTR', '${avgCtr.toStringAsFixed(2)}%', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection(AsyncValue<List<AdmobReportModel>> report) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: report.when(
        data: (data) => _buildDataView(data),
        loading: () => _buildLoadingView(),
        error: (error, stackTrace) => _buildErrorView(error),
      ),
    );
  }

  Widget _buildDataView(List<AdmobReportModel> data) {
    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                '데이터가 없습니다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '지난 7일간 AdMob 수익 데이터가 없거나\n아직 로그인하지 않았습니다',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // 날짜순으로 정렬 (최신 날짜가 위로)
    final sortedData = List<AdmobReportModel>.from(data);
    sortedData.sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        // 헤더
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '일별 수익 현황 (${data.length}일)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
            ],
          ),
        ),
        // 데이터 리스트
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: sortedData.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildDataCard(sortedData[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDataCard(AdmobReportModel item, int index) {
    // 날짜 포맷팅 (YYYYMMDD -> MM/DD)
    String formattedDate = item.date;
    if (item.date.length == 8) {
      final month = item.date.substring(4, 6);
      final day = item.date.substring(6, 8);
      formattedDate = '$month/$day';
    }

    final ctrText = item.impressions > 0 ? ((item.clicks / item.impressions) * 100).toStringAsFixed(2) : '0.00';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Text(
          formattedDate,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '\$${item.earnings.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            'CTR: $ctrText%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      subtitle: Text(
        '클릭: ${item.clicks}회 • 노출: ${item.impressions}회',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        item.earnings > 0.5 ? Icons.trending_up : Icons.trending_flat,
        color: item.earnings > 0.5 ? Colors.green : Colors.grey,
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AdMob 데이터를 불러오는 중...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              '오류가 발생했습니다',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(admobProvider.notifier).reset();
                _refreshData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      if (_googleSignIn == null) return;

      await _googleSignIn!.signOut(); // 기존 세션 정리

      final account = await _googleSignIn!.signIn().timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('로그인 시간이 초과되었습니다'),
          );

      if (account == null) return;

      setState(() => _userEmail = account.email);

      final auth = await account.authentication;
      final accessToken = auth.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('액세스 토큰을 받을 수 없습니다');
      }

      final publisherId = dotenv.env['ADMOB_PUBLISHER_ID'];
      if (publisherId == null || publisherId.isEmpty) {
        throw Exception('Publisher ID가 설정되지 않았습니다\n.env 파일을 확인해주세요');
      }

      // 데이터 로드
      await ref.read(admobProvider.notifier).loadReport(accessToken, publisherId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 로그인 성공! 데이터를 불러왔습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 로그인 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _googleSignIn?.signOut();
      ref.read(admobProvider.notifier).reset();

      setState(() => _userEmail = null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 로그아웃되었습니다'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 중 오류: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    if (_userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('먼저 로그인해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final account = await _googleSignIn?.signInSilently();
      if (account == null) {
        throw Exception('자동 로그인 실패. 다시 로그인해주세요');
      }

      final auth = await account.authentication;
      final accessToken = auth.accessToken;

      if (accessToken == null) {
        throw Exception('토큰이 만료되었습니다. 다시 로그인해주세요');
      }

      final publisherId = dotenv.env['ADMOB_PUBLISHER_ID'];
      if (publisherId == null) {
        throw Exception('Publisher ID가 없습니다');
      }

      await ref.read(admobProvider.notifier).loadReport(accessToken, publisherId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 데이터를 새로고침했습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('새로고침 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
