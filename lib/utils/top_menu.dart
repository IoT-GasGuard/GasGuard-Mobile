import 'package:flutter/material.dart';
import 'package:gasguard_mobile/utils/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared/helpers/storage_helper.dart';

class TopMenu extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback? onAnalytics; 

  const TopMenu({
    Key? key,
    required this.onLogout,
    this.onAnalytics, 
  }) : super(key: key);

  static void showMenu(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => TopMenu(
        onLogout: () async {
          await StorageHelper.removeCredentials();
          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.auth,
                (route) => false,
          );
        },
        onAnalytics: () {
          Navigator.pop(context);
          if (currentRoute != AppRouter.analytics) {
            Navigator.pushNamed(context, AppRouter.analytics);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    
    // Envuelve todo el contenido con Material
    return Material(
      type: MaterialType.transparency,
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 60.0, left: 16.0, right: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2B3D),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/logo_gasguard.png',
                              width: 30,
                              height: 30,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'GasGuard',
                              style: TextStyle(
                                color: Color(0xFF4ECDC4),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF4ECDC4)),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF2A3B4D), height: 1),
                  _buildMenuItem(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      if (currentRoute != AppRouter.dashboard) {
                        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
                      }
                    },
                    isActive: currentRoute == AppRouter.dashboard,
                  ),
                  _buildMenuItem(
                    icon: Icons.device_hub,
                    title: 'Devices',
                    onTap: () {
                      Navigator.pop(context);
                      if (currentRoute != AppRouter.devices) {
                        Navigator.pushNamed(context, AppRouter.devices);
                      }
                    },
                    isActive: currentRoute == AppRouter.devices,
                  ),
                  _buildMenuItem(
                    icon: Icons.analytics,
                    title: 'Analytics & Reports',
                    onTap: () {
                      Navigator.pop(context);
                      if (currentRoute != AppRouter.analytics) {
                        Navigator.pushNamed(context, AppRouter.analytics);
                      }
                    },
                    isActive: currentRoute == AppRouter.analytics,
                  ),
                  _buildMenuItem(
                    icon: Icons.lightbulb_outline,
                    title: 'Lighting Control',
                    onTap: () {
                      Navigator.pop(context);
                      if (currentRoute != AppRouter.lighting) {
                        Navigator.pushNamed(context, AppRouter.lighting);
                      }
                    },
                    isActive: currentRoute == AppRouter.lighting,
                  ),
                  _buildMenuItem(
                    icon: Icons.people,
                    title: 'Household Members',
                    onTap: () {
                      Navigator.pop(context);
                      if (currentRoute != AppRouter.household) {
                        Navigator.pushNamed(context, AppRouter.household);
                      }
                    },
                    isActive: currentRoute == AppRouter.household,
                  ),
                  const Divider(color: Color(0xFF2A3B4D), height: 1),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: onLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,  
  }) {
    return ListTile(
      leading: Icon(
        icon, 
        color: isActive ? Colors.white : const Color(0xFF4ECDC4),
      ),
      title: Text(
        title, 
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF4ECDC4),
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isActive ? const Color(0xFF0F1B2A) : null,
      onTap: onTap,
    );
  }
}