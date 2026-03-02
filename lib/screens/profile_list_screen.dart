import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ptt_provider.dart';
import '../models/ptt_profile.dart';
import 'profile_editor_screen.dart';

class ProfileListScreen extends StatelessWidget {
  const ProfileListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PTTProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Perfiles'),
      ),
      body: ListView.builder(
        itemCount: provider.profiles.length,
        itemBuilder: (context, index) {
          final profile = provider.profiles[index];
          return ListTile(
            leading: const Icon(Icons.settings_input_component),
            title: Text(profile.name),
            subtitle: Text('Start: ${profile.startAction}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileEditorScreen(profile: profile),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Borrar Perfil'),
                        content: Text('¿Estás seguro de que quieres borrar el perfil "${profile.name}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                          TextButton(
                            onPressed: () {
                              provider.deleteProfile(profile.id);
                              Navigator.pop(context);
                            },
                            child: const Text('Borrar', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileEditorScreen()),
        ),
        label: const Text('Nuevo Perfil'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
