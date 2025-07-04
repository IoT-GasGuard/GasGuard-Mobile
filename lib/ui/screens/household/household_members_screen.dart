import 'package:flutter/material.dart';
import 'package:gasguard_mobile/models/household_member.dart';
import 'package:gasguard_mobile/service/household_service.dart';
import 'package:gasguard_mobile/shared/helpers/storage_helper.dart';
import 'package:gasguard_mobile/utils/top_menu.dart';
import '../../common/app_header.dart';
import 'components/add_edit_member_dialog.dart';
import 'components/member_card.dart';
import 'components/search_filterBar.dart';

class HouseholdMembersScreen extends StatefulWidget {
  const HouseholdMembersScreen({Key? key}) : super(key: key);

  @override
  State<HouseholdMembersScreen> createState() => _HouseholdMembersScreenState();
}

class _HouseholdMembersScreenState extends State<HouseholdMembersScreen> with SingleTickerProviderStateMixin {
  List<HouseholdMember> _allMembers = [];
  late List<HouseholdMember> _filteredMembers;
  String _searchQuery = '';
  bool _showEmergencyOnly = false;
  late TabController _tabController;
  
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _filteredMembers = [];
    _tabController = TabController(length: 2, vsync: this);
    _loadHouseholdMembers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Cargar miembros del hogar desde el backend
  Future<void> _loadHouseholdMembers() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final user = await StorageHelper.getUser();
      if (user == null || user.profileId.isEmpty) {
        setState(() {
          error = 'No se pudo obtener información del usuario';
          isLoading = false;
        });
        return;
      }

      final response = await HouseholdService.getHouseholdMembersByProfile(user.profileId);

      if (response.statusCode == 200) {
        final List<dynamic> membersJson = response.data;
        final List<HouseholdMember> loadedMembers = membersJson
            .map((json) => HouseholdMember.fromJson(json))
            .toList();

        setState(() {
          _allMembers = loadedMembers;
          _filteredMembers = loadedMembers;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error al cargar miembros del hogar';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error de conexión: $e';
        isLoading = false;
      });
    }
  }

  void _filterMembers() {
    setState(() {
      _filteredMembers = _allMembers
          .where((member) =>
      member.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          (!_showEmergencyOnly || member.isEmergencyContact))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2A),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: "Household Members",
              onBackPressed: () => Navigator.pop(context),
              onMenuPressed: () => TopMenu.showMenu(context),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2B3D),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: isLoading
                    ? _buildLoadingState()
                    : error != null
                      ? _buildErrorState()
                      : Column(
                          children: [
                            // Barra de búsqueda y filtro
                            SearchFilterBar(
                              onSearch: (query) {
                                _searchQuery = query;
                                _filterMembers();
                              },
                              onToggleEmergencyOnly: (value) {
                                _showEmergencyOnly = value;
                                _filterMembers();
                              },
                            ),

                            // Pestañas (All Members / Emergency Contacts)
                            TabBar(
                              controller: _tabController,
                              indicatorColor: const Color(0xFF4ECDC4),
                              indicatorWeight: 3,
                              labelColor: const Color(0xFF4ECDC4),
                              unselectedLabelColor: Colors.grey,
                              tabs: const [
                                Tab(text: "All Members"),
                                Tab(text: "Emergency Contacts"),
                              ],
                            ),

                            // Contenido principal
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  // Tab 1: All Members
                                  _buildMembersList(_filteredMembers),

                                  // Tab 2: Emergency Contacts
                                  _buildMembersList(_filteredMembers.where((m) => m.isEmergencyContact).toList()),
                                ],
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: _showAddMemberDialog,
              backgroundColor: const Color(0xFF4ECDC4),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Member'),
              elevation: 4,
            ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF4ECDC4),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando miembros del hogar...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            error ?? 'Error desconocido',
            style: TextStyle(
              color: Colors.red.withOpacity(0.7),
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadHouseholdMembers,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(List<HouseholdMember> members) {
    if (members.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: members.length + 1,
      itemBuilder: (context, index) {
        if (index < members.length) {
          return AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
            child: MemberCard(
              member: members[index],
              onEdit: () => _showEditMemberDialog(members[index]),
              onDelete: () => _showDeleteConfirmation(members[index]),
            ),
          );
        } else {
          return _buildNotificationSettings();
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_disabled,
            color: Colors.grey[600],
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay miembros registrados aún',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toca el botón "Add Member" para registrar un nuevo miembro',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // Mostrar diálogo para añadir miembro
  void _showAddMemberDialog() async {
    final user = await StorageHelper.getUser();
    if (user == null) {
      _showErrorSnackBar('No se pudo obtener información del usuario');
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AddEditMemberDialog(
        title: 'Añadir Miembro',
        onSave: (member) async {
          try {
            final response = await HouseholdService.createHouseholdMember(
              profileId: user.profileId,
              name: member.fullName,
              email: member.email,
              phone: member.phoneNumber,
              emergencyContact: member.isEmergencyContact,
              gasAlerts: member.gasLeakAlerts,
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
              Navigator.pop(context);
              _showSuccessSnackBar('Miembro añadido exitosamente');
              _loadHouseholdMembers(); // Recargar la lista
            } else {
              throw Exception('Error al crear miembro');
            }
          } catch (e) {
            _showErrorSnackBar('Error al añadir miembro: $e');
          }
        },
      ),
    );
  }

  // Mostrar diálogo para editar miembro
  void _showEditMemberDialog(HouseholdMember member) {
    showDialog(
      context: context,
      builder: (context) => AddEditMemberDialog(
        title: 'Editar Miembro',
        member: member,
        onSave: (updatedMember) async {
          try {
            final response = await HouseholdService.updateHouseholdMember(
              member.id,
              name: updatedMember.fullName,
              email: updatedMember.email,
              phone: updatedMember.phoneNumber,
              emergencyContact: updatedMember.isEmergencyContact,
              gasAlerts: updatedMember.gasLeakAlerts,
            );

            if (response.statusCode == 200) {
              Navigator.pop(context);
              _showSuccessSnackBar('Miembro actualizado exitosamente');
              _loadHouseholdMembers(); // Recargar la lista
            } else {
              throw Exception('Error al actualizar miembro');
            }
          } catch (e) {
            _showErrorSnackBar('Error al actualizar miembro: $e');
          }
        },
      ),
    );
  }

  // Confirmar eliminación de miembro
  void _showDeleteConfirmation(HouseholdMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2B3D),
        title: const Text(
          'Eliminar Miembro',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar a ${member.fullName} de los miembros del hogar?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                final response = await HouseholdService.deleteHouseholdMember(member.id);

                if (response.statusCode == 200) {
                  Navigator.pop(context);
                  _showSuccessSnackBar('Miembro eliminado exitosamente');
                  _loadHouseholdMembers(); // Recargar la lista
                } else {
                  throw Exception('Error al eliminar miembro');
                }
              } catch (e) {
                Navigator.pop(context);
                _showErrorSnackBar('Error al eliminar miembro: $e');
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ...resto del código para _buildNotificationSettings() y _buildNotificationItem() igual...
  Widget _buildNotificationSettings() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF142D40), Color(0xFF0F1E2E)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF2D4055),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF4ECDC4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Alertas de Fuga de Gas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Medidas de seguridad durante una fuga de gas:',
            style: TextStyle(
              color: Color(0xFF4ECDC4),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Cuando GasGuard detecta una fuga de gas, se toman las siguientes acciones automáticamente:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            title: 'Los contactos de emergencia reciben alertas inmediatas por SMS y email',
          ),
          const SizedBox(height: 10),
          _buildNotificationItem(
            title: 'Se notifica a servicios de emergencia como bomberos y 911',
          ),
          const SizedBox(height: 10),
          _buildNotificationItem(
            title: 'Apertura de puertas y ventanas para ventilación',
          ),
          const SizedBox(height: 10),
          _buildNotificationItem(
            title: 'Corte del suministro eléctrico para niveles altos de gas',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({required String title}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF4ECDC4),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ECDC4).withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}