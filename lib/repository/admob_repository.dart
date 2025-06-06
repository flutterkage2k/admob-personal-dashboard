// 📁 lib/repository/admob_repository.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/admob_report_model.dart';

class AdmobRepository {
  Future<List<AdmobReportModel>> fetchAdmobReport({
    required String accessToken,
    required String publisherId,
  }) async {
    try {
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 7));

      final url = Uri.parse(
        'https://admob.googleapis.com/v1/accounts/$publisherId/mediationReport:generate',
      );

      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      final requestBody = {
        "reportSpec": {
          "dateRange": {
            "startDate": {"year": start.year, "month": start.month, "day": start.day},
            "endDate": {"year": now.year, "month": now.month, "day": now.day}
          },
          "metrics": ["ESTIMATED_EARNINGS", "IMPRESSIONS", "CLICKS"],
          "dimensions": ["DATE"]
        }
      };

      print('🌐 API 요청 URL: $url');
      print('📤 요청 본문: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('📥 응답 상태: ${response.statusCode}');
      print('📥 응답 본문 길이: ${response.body.length}');

      if (response.statusCode != 200) {
        throw Exception('API 호출 실패: ${response.statusCode} - ${response.body}');
      }

      print('🔄 JSON 파싱 시작...');
      final decoded = jsonDecode(response.body);
      print('✅ JSON 파싱 성공');

      // 응답이 List인지 확인
      if (decoded is! List) {
        throw Exception('응답이 예상된 List 형태가 아닙니다: ${decoded.runtimeType}');
      }

      final decodedList = decoded;
      print('📊 응답 리스트 길이: ${decodedList.length}');

      // row 항목들만 추출
      final rowData = <Map<String, dynamic>>[];

      for (var i = 0; i < decodedList.length; i++) {
        final item = decodedList[i];
        print('🔍 항목 $i: ${item.runtimeType}');

        if (item is Map<String, dynamic>) {
          if (item.containsKey('row')) {
            final rowMap = item['row'];
            if (rowMap is Map<String, dynamic>) {
              rowData.add(rowMap);
              print('✅ row 데이터 추가됨: $i');
            }
          } else if (item.containsKey('header')) {
            print('ℹ️  header 항목 건너뜀: $i');
          }
        }
      }

      print('📈 총 row 데이터 개수: ${rowData.length}');

      if (rowData.isEmpty) {
        print('ℹ️  처리할 row 데이터가 없습니다.');
        return [];
      }

      // 각 row 데이터를 AdmobReportModel로 변환
      final results = <AdmobReportModel>[];

      for (var i = 0; i < rowData.length; i++) {
        try {
          print('🔄 Row $i 처리 시작');
          final model = _convertToModel(rowData[i], i);
          results.add(model);
          print('✅ Row $i 완료: ${model.date} - \$${model.earnings.toStringAsFixed(4)}');
        } catch (e) {
          print('❌ Row $i 처리 실패: $e');
          // 개별 row 오류는 건너뛰고 계속 진행
        }
      }

      print('🎉 최종 결과: ${results.length}개 항목 처리 완료');
      return results;
    } catch (e, stackTrace) {
      print('❌ fetchAdmobReport 전체 오류: $e');
      print('📍 스택트레이스: $stackTrace');
      rethrow;
    }
  }

  AdmobReportModel _convertToModel(Map<String, dynamic> row, int index) {
    print('🔍 Row $index 변환 시작');

    // 기본값 설정
    String date = '알 수 없는 날짜';
    double earnings = 0.0;
    int impressions = 0;
    int clicks = 0;

    try {
      // DATE 추출
      final dimensionValues = row['dimensionValues'];
      if (dimensionValues is Map<String, dynamic>) {
        final dateObj = dimensionValues['DATE'];
        if (dateObj is Map<String, dynamic>) {
          final dateValue = dateObj['value'];
          if (dateValue != null) {
            date = dateValue.toString();
          }
        }
      }
      print('📅 날짜 추출: $date');

      // METRICS 추출
      final metricValues = row['metricValues'];
      if (metricValues is Map<String, dynamic>) {
        // ESTIMATED_EARNINGS 추출
        final earningsObj = metricValues['ESTIMATED_EARNINGS'];
        if (earningsObj is Map<String, dynamic>) {
          final microsValue = earningsObj['microsValue'];
          if (microsValue != null) {
            final microsString = microsValue.toString();
            final micros = double.tryParse(microsString) ?? 0.0;
            earnings = micros / 1000000.0; // micros를 달러로 변환
          }
        }
        print('💰 수익 추출: $earnings');

        // IMPRESSIONS 추출
        final impressionsObj = metricValues['IMPRESSIONS'];
        if (impressionsObj is Map<String, dynamic>) {
          final intValue = impressionsObj['integerValue'];
          if (intValue != null) {
            impressions = int.tryParse(intValue.toString()) ?? 0;
          }
        }
        print('👁️  노출 추출: $impressions');

        // CLICKS 추출
        final clicksObj = metricValues['CLICKS'];
        if (clicksObj is Map<String, dynamic>) {
          final intValue = clicksObj['integerValue'];
          if (intValue != null) {
            clicks = int.tryParse(intValue.toString()) ?? 0;
          }
        }
        print('🖱️  클릭 추출: $clicks');
      }

      return AdmobReportModel(
        date: date,
        earnings: earnings,
        impressions: impressions,
        clicks: clicks,
      );
    } catch (e) {
      print('❌ Row $index 변환 중 오류: $e');
      // 오류가 있어도 기본값으로 모델 생성
      return AdmobReportModel(
        date: date,
        earnings: earnings,
        impressions: impressions,
        clicks: clicks,
      );
    }
  }
}
