import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../models/weather_model.dart';
import '../models/location_model.dart';
import '../utils/weather_utils.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WeatherViewModel>(
        builder: (context, viewModel, child) {
          return _buildBody(context, viewModel);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel viewModel) {
    switch (viewModel.state) {
      case LoadingState.initial:
      case LoadingState.loading:
        return _buildLoading(context);
      case LoadingState.loaded:
        return _buildWeatherContent(context, viewModel);
      case LoadingState.error:
        return _buildError(context, viewModel);
      case LoadingState.empty:
        return _buildEmpty(context);
    }
  }

  BoxDecoration _defaultBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0099F7),
          Color(0xFF29B6F6),
          Color(0xFF56CCF2),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Container(
      decoration: _defaultBackground(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Memuat cuaca terbaru...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WeatherViewModel viewModel) {
    return Container(
      decoration: _defaultBackground(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _GlassContainer(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 72,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  viewModel.errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => viewModel.refreshWeather(),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0099F7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'Coba Lagi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Container(
      decoration: _defaultBackground(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _GlassContainer(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  size: 72,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada data cuaca.\nPilih lokasi terlebih dahulu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => _navigateToSearch(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0099F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Cari Kota'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent(
      BuildContext context, WeatherViewModel viewModel) {
    final weather = viewModel.weather!;
    final location = viewModel.currentLocation!;
    final weatherCode = weather.current.weatherCode;
    final gradientColors = WeatherUtils.getWeatherGradient(weatherCode);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.14),
              ),
            ),
          ),
          Positioned(
            top: 180,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: gradientColors.first,
              backgroundColor: Colors.white,
              onRefresh: () => viewModel.refreshWeather(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildTopBar(context, viewModel, location),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildHeroWeather(weather, weatherCode),
                          const SizedBox(height: 28),
                          _buildBentoInfoGrid(weather),
                          const SizedBox(height: 24),
                          _buildForecastSection(context, weather.daily),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    WeatherViewModel viewModel,
    LocationModel location,
  ) {
    final subtitle = [location.admin1, location.country]
        .where((e) => e != null && e.isNotEmpty)
        .join(', ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToSearch(context),
              child: _GlassContainer(
                borderRadius: 30,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            location.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle.isNotEmpty)
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white.withValues(alpha: 0.85),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => viewModel.toggleFavorite(),
            child: _GlassContainer(
              borderRadius: 50,
              padding: const EdgeInsets.all(12),
              child: Icon(
                viewModel.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: viewModel.isFavorite
                    ? const Color(0xFFFF5252)
                    : Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _navigateToSearch(context),
            child: const _GlassContainer(
              borderRadius: 50,
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroWeather(WeatherModel weather, int weatherCode) {
    final todayMax = weather.daily.temperatureMax.isNotEmpty
        ? weather.daily.temperatureMax.first.round()
        : weather.current.temperature.round();
    final todayMin = weather.daily.temperatureMin.isNotEmpty
        ? weather.daily.temperatureMin.first.round()
        : weather.current.temperature.round();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.16),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.15),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(
            WeatherUtils.getWeatherIcon(weatherCode),
            size: 84,
            color: WeatherUtils.getWeatherIconAccent(weatherCode),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${weather.current.temperature.round()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 84,
                fontWeight: FontWeight.w700,
                height: 1.0,
                letterSpacing: -3,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                '°C',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Text(
            WeatherUtils.getWeatherDescription(weatherCode),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tertinggi $todayMax°  •  Terendah $todayMin°  •  Terasa ${weather.current.apparentTemperature.round()}°',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBentoInfoGrid(WeatherModel weather) {
    final items = [
      _InfoItem(
        icon: Icons.water_drop_rounded,
        label: 'Kelembapan',
        value: '${weather.current.relativeHumidity}%',
        accentColor: const Color(0xFF81D4FA),
      ),
      _InfoItem(
        icon: Icons.air_rounded,
        label: 'Kec. Angin',
        value: '${weather.current.windSpeed} km/h',
        accentColor: const Color(0xFFA5D6A7),
      ),
      _InfoItem(
        icon: Icons.umbrella_rounded,
        label: 'Curah Hujan',
        value: '${weather.current.precipitation} mm',
        accentColor: const Color(0xFF90CAF9),
      ),
      _InfoItem(
        icon: Icons.thermostat_rounded,
        label: 'Terasa Seperti',
        value: '${weather.current.apparentTemperature.round()}°C',
        accentColor: const Color(0xFFFFCC80),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.65,
      children: items.map((item) => _buildBentoCard(item)).toList(),
    );
  }

  Widget _buildBentoCard(_InfoItem item) {
    return _GlassContainer(
      borderRadius: 22,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  size: 16,
                  color: item.accentColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            item.value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildForecastSection(BuildContext context, DailyForecast daily) {
    double globalMin = double.infinity;
    double globalMax = double.negativeInfinity;
    for (int i = 0; i < daily.length; i++) {
      if (daily.temperatureMin[i] < globalMin) {
        globalMin = daily.temperatureMin[i];
      }
      if (daily.temperatureMax[i] > globalMax) {
        globalMax = daily.temperatureMax[i];
      }
    }

    return _GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              Text(
                'PRAKIRAAN 7 HARI',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daily.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            itemBuilder: (context, index) {
              return _buildDailyRow(daily, index, globalMin, globalMax);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRow(
    DailyForecast daily,
    int index,
    double globalMin,
    double globalMax,
  ) {
    final minTemp = daily.temperatureMin[index];
    final maxTemp = daily.temperatureMax[index];
    final range = (globalMax - globalMin).clamp(1.0, 100.0);
    final startFrac = ((minTemp - globalMin) / range).clamp(0.0, 1.0);
    final endFrac = ((maxTemp - globalMin) / range).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WeatherUtils.getDayName(daily.time[index]),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  WeatherUtils.formatDate(daily.time[index]),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  WeatherUtils.getWeatherIcon(daily.weatherCode[index]),
                  size: 20,
                  color: WeatherUtils.getWeatherIconAccent(
                      daily.weatherCode[index]),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${daily.precipitationProbabilityMax[index]}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    '${minTemp.round()}°',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final totalW = constraints.maxWidth;
                      final leftOffset = totalW * startFrac;
                      final barW =
                          (totalW * (endFrac - startFrac)).clamp(6.0, totalW);
                      return Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: leftOffset.clamp(0.0, totalW - barW),
                              width: barW,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF81D4FA),
                                      Color(0xFFFFD54F),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 30,
                  child: Text(
                    '${maxTemp.round()}°',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToSearch(BuildContext context) async {
    final viewModel = context.read<WeatherViewModel>();
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );

    if (result == true) {
      viewModel.refreshWeather();
    }
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const _GlassContainer({
    required this.child,
    this.borderRadius = 20,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });
}
