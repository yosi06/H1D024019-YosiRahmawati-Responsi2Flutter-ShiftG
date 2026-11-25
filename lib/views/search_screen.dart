import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../models/location_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<SearchViewModel>().searchLocation(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Pilih Lokasi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: Consumer<SearchViewModel>(
              builder: (context, viewModel, child) {
                return _buildContent(context, viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Cari nama kota (mis. Bandung, Tokyo)...',
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.45),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF0EA5E9),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      context.read<SearchViewModel>().clearSearch();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          onChanged: (value) {
            setState(() {});
            _onSearchChanged(value);
          },
          onSubmitted: (value) {
            context.read<SearchViewModel>().searchLocation(value);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SearchViewModel viewModel) {
    if (viewModel.state == SearchState.initial) {
      return _buildInitialContent(context, viewModel);
    }

    if (viewModel.state == SearchState.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
      );
    }

    if (viewModel.state == SearchState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded,
                  size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(
                viewModel.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.state == SearchState.empty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off_rounded,
                size: 64,
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Kota "${viewModel.query}" tidak ditemukan.\nCoba kata kunci lain ya!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.65),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildSearchResults(context, viewModel);
  }

  Widget _buildInitialContent(
      BuildContext context, SearchViewModel viewModel) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (viewModel.favorites.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            icon: Icons.favorite_rounded,
            title: 'Lokasi Favorit',
            iconColor: const Color(0xFFFF5252),
          ),
          const SizedBox(height: 10),
          ...viewModel.favorites.map(
            (loc) => _buildLocationCard(
              context,
              location: loc,
              trailing: IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
                onPressed: () => viewModel.removeFavorite(loc),
                tooltip: 'Hapus dari favorit',
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (viewModel.searchHistory.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            icon: Icons.history_rounded,
            title: 'Pencarian Terakhir',
            iconColor: const Color(0xFF0EA5E9),
            trailing: TextButton(
              onPressed: () => viewModel.clearHistory(),
              child: const Text(
                'Hapus',
                style: TextStyle(
                  color: Color(0xFF0EA5E9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: viewModel.searchHistory.map((query) {
              return ActionChip(
                avatar: const Icon(
                  Icons.history_rounded,
                  size: 16,
                  color: Color(0xFF0EA5E9),
                ),
                label: Text(
                  query,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.25),
                ),
                onPressed: () {
                  _searchController.text = query;
                  setState(() {});
                  context.read<SearchViewModel>().searchLocation(query);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
        if (viewModel.favorites.isEmpty && viewModel.searchHistory.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 72),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.explore_rounded,
                    size: 56,
                    color: Color(0xFF0EA5E9),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Mau cek cuaca di mana?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ketik nama kota di kolom pencarian atas\nuntuk melihat cuaca terkini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSearchResults(
      BuildContext context, SearchViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: viewModel.searchResults.length,
      itemBuilder: (context, index) {
        final location = viewModel.searchResults[index];
        return _buildLocationCard(context, location: location);
      },
    );
  }

  Widget _buildLocationCard(
    BuildContext context, {
    required LocationModel location,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitle = [location.admin1, location.country]
        .where((e) => e != null && e.isNotEmpty)
        .join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0099F7), Color(0xFF56CCF2)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.location_on_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          location.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              )
            : null,
        trailing: trailing ??
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.35),
            ),
        onTap: () => _selectLocation(context, location),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? iconColor,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
        ),
        const Spacer(),
        ?trailing,
      ],
    );
  }

  void _selectLocation(BuildContext context, LocationModel location) {
    context.read<WeatherViewModel>().loadWeather(location);
    Navigator.pop(context, true);
  }
}
