import 'package:flutter/material.dart';
import 'package:gasguard_mobile/models/gas_incident.dart';
import 'package:gasguard_mobile/ui/screens/Analytics/components/filter_chip.dart';
import 'package:gasguard_mobile/ui/screens/Analytics/components/incident_card.dart';

class GasIncidentsTab extends StatefulWidget {
  final List<GasIncident> incidents;
  final Function(bool) onGenerateReport;

  const GasIncidentsTab({
    Key? key,
    required this.incidents,
    required this.onGenerateReport,
  }) : super(key: key);

  @override
  State<GasIncidentsTab> createState() => _GasIncidentsTabState();
}

class _GasIncidentsTabState extends State<GasIncidentsTab> {
  bool _showResolvedOnly = true;

  @override
  Widget build(BuildContext context) {
    // Filtrar incidentes según el estado seleccionado
    final filteredIncidents = _showResolvedOnly
        ? widget.incidents.where((incident) => incident.isResolved).toList()
        : widget.incidents;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Gas Leak Incident Reports',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                CustomFilterChip(
                  label: 'Resolved',
                  isSelected: _showResolvedOnly,
                  onTap: () {
                    setState(() {
                      _showResolvedOnly = !_showResolvedOnly;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...filteredIncidents.map((incident) => IncidentCard(incident: incident)),
            const SizedBox(height: 20),
            _buildGenerateReportButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateReportButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => widget.onGenerateReport(true),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(Icons.file_download),
        label: Text(
          'Generate Gas Leak Report',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}