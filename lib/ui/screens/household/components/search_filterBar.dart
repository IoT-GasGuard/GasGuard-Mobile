import 'package:flutter/material.dart';

class SearchFilterBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function(bool) onToggleEmergencyOnly;

  const SearchFilterBar({
    Key? key,
    required this.onSearch,
    required this.onToggleEmergencyOnly,
  }) : super(key: key);

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _showEmergencyOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        children: [
          // Barra de búsqueda
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF0F2133),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2D4055), width: 1),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search members...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearch('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: widget.onSearch,
            ),
          ),
          
          // Filtro de contactos de emergencia
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.filter_list,
                  color: Color(0xFF4ECDC4),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Filters:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                FilterChip(
                  label: const Text('Emergency Contacts'),
                  selected: _showEmergencyOnly,
                  selectedColor: const Color(0xFF4ECDC4).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF4ECDC4),
                  labelStyle: TextStyle(
                    color: _showEmergencyOnly ? const Color(0xFF4ECDC4) : Colors.white70,
                  ),
                  backgroundColor: const Color(0xFF0F2133),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: _showEmergencyOnly 
                          ? const Color(0xFF4ECDC4) 
                          : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      _showEmergencyOnly = selected;
                    });
                    widget.onToggleEmergencyOnly(selected);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}