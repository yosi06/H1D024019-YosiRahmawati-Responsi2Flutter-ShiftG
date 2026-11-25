import 'package:flutter/material.dart';

class WeatherUtils {
  static String getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
        return 'Sebagian Cerah';
      case 2:
        return 'Berawan Sebagian';
      case 3:
        return 'Mendung';
      case 45:
      case 48:
        return 'Berkabut';
      case 51:
        return 'Gerimis Ringan';
      case 53:
        return 'Gerimis Sedang';
      case 55:
        return 'Gerimis Lebat';
      case 56:
      case 57:
        return 'Gerimis Beku';
      case 61:
        return 'Hujan Ringan';
      case 63:
        return 'Hujan Sedang';
      case 65:
        return 'Hujan Lebat';
      case 66:
      case 67:
        return 'Hujan Beku';
      case 71:
        return 'Salju Ringan';
      case 73:
        return 'Salju Sedang';
      case 75:
        return 'Salju Lebat';
      case 77:
        return 'Butiran Salju';
      case 80:
        return 'Hujan Singkat Ringan';
      case 81:
        return 'Hujan Singkat Sedang';
      case 82:
        return 'Hujan Singkat Lebat';
      case 85:
      case 86:
        return 'Hujan Salju';
      case 95:
        return 'Badai Petir';
      case 96:
      case 99:
        return 'Badai Petir & Hujan Es';
      default:
        return 'Tidak Diketahui';
    }
  }

  static IconData getWeatherIcon(int code) {
    switch (code) {
      case 0:
        return Icons.wb_sunny_rounded;
      case 1:
      case 2:
        return Icons.wb_cloudy_rounded;
      case 3:
        return Icons.cloud_rounded;
      case 45:
      case 48:
        return Icons.foggy;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return Icons.grain_rounded;
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
        return Icons.water_drop_rounded;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return Icons.ac_unit_rounded;
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  static List<Color> getWeatherGradient(int code) {
    switch (code) {
      case 0:
        return const [
          Color(0xFF0099F7),
          Color(0xFF29B6F6),
          Color(0xFF56CCF2),
        ];
      case 1:
      case 2:
        return const [
          Color(0xFF2196F3),
          Color(0xFF4FC3F7),
          Color(0xFF81D4FA),
        ];
      case 3:
        return const [
          Color(0xFF5C6BC0),
          Color(0xFF7986CB),
          Color(0xFF9FA8DA),
        ];
      case 45:
      case 48:
        return const [
          Color(0xFF4DB6AC),
          Color(0xFF80CBC4),
          Color(0xFFB2DFDB),
        ];
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return const [
          Color(0xFF00B4D8),
          Color(0xFF48CAE4),
          Color(0xFF90E0EF),
        ];
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
        return const [
          Color(0xFF2962FF),
          Color(0xFF448AFF),
          Color(0xFF64B5F6),
        ];
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return const [
          Color(0xFF4DD0E1),
          Color(0xFF80DEEA),
          Color(0xFFB2EBF2),
        ];
      case 95:
      case 96:
      case 99:
        return const [
          Color(0xFF4A148C),
          Color(0xFF6A1B9A),
          Color(0xFF7E57C2),
        ];
      default:
        return const [
          Color(0xFF0099F7),
          Color(0xFF29B6F6),
          Color(0xFF56CCF2),
        ];
    }
  }

  static Color getWeatherColor(int code) {
    return getWeatherGradient(code).first;
  }

  static Color getWeatherIconAccent(int code) {
    switch (code) {
      case 0:
        return const Color(0xFFFFD54F);
      case 1:
      case 2:
        return const Color(0xFFFFE082);
      case 3:
        return const Color(0xFFE8EAF6);
      case 45:
      case 48:
        return const Color(0xFFE0F2F1);
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
        return const Color(0xFFB3E5FC);
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return Colors.white;
      case 95:
      case 96:
      case 99:
        return const Color(0xFFFFD54F);
      default:
        return const Color(0xFFFFD54F);
    }
  }

  static String getDayName(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final parsedDate = DateTime(date.year, date.month, date.day);

    if (parsedDate == today) return 'Hari Ini';
    if (parsedDate == tomorrow) return 'Besok';

    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    return days[date.weekday - 1];
  }

  static String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
