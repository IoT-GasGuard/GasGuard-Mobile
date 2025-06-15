import 'package:flutter/material.dart';
import 'package:gasguard_mobile/models/household_member.dart';

class MemberCard extends StatelessWidget {
  final HouseholdMember member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MemberCard({
    Key? key,
    required this.member,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: member.isEmergencyContact
              ? [const Color(0xFF1A2F45), const Color(0xFF162A3E)]
              : [const Color(0xFF0F2133), const Color(0xFF0B1928)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: member.isEmergencyContact
            ? Border.all(color: Colors.red.withOpacity(0.5), width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onEdit,
          splashColor: const Color(0xFF4ECDC4).withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar del miembro
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFF4ECDC4).withOpacity(0.15),
                      child: Text(
                        _getInitials(member.fullName),
                        style: const TextStyle(
                          color: Color(0xFF4ECDC4),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Información principal
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (member.isEmergencyContact)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade700, width: 1),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.emergency,
                                    color: Colors.red,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Emergency Contact',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Menú de acciones
                    PopupMenuButton(
                      color: const Color(0xFF0F2133),
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white70,
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit, color: Color(0xFF4ECDC4), size: 18),
                              const SizedBox(width: 8),
                              const Text('Edit', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete, color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              const Text('Delete', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit();
                        } else if (value == 'delete') {
                          onDelete();
                        }
                      },
                    ),
                  ],
                ),

                // Detalles de contacto
                const SizedBox(height: 16),
                _buildExpandableContactInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableContactInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1A2A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactInfoRow(Icons.email, member.email),
          const SizedBox(height: 10),
          _buildContactInfoRow(Icons.phone, member.phoneNumber),
          const SizedBox(height: 10),

          // Alertas y notificaciones
          Row(
            children: [
              Expanded(
                child: _buildStatusIndicator(
                  'Notifications',
                  member.notificationsEnabled,
                  Icons.notifications,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatusIndicator(
                  'Gas Leak Alerts',
                  member.gasLeakAlerts,
                  Icons.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2B3D),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4ECDC4),
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(String title, bool isActive, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF4ECDC4).withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive
              ? const Color(0xFF4ECDC4).withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF4ECDC4) : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
                Text(
                  isActive ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    color: isActive ? const Color(0xFF4ECDC4) : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String fullName) {
    List<String> names = fullName.split(' ');
    String initials = '';
    if (names.isNotEmpty) {
      initials += names[0][0];
      if (names.length > 1) {
        initials += names[names.length - 1][0];
      }
    }
    return initials.toUpperCase();
  }
}