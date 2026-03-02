import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ptt_provider.dart';
import '../models/ptt_profile.dart';

class ProfileEditorScreen extends StatefulWidget {
  final PTTProfile? profile;
  const ProfileEditorScreen({super.key, this.profile});

  @override
  State<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<ProfileEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _startAction;
  late String _stopAction;

  @override
  void initState() {
    super.initState();
    _name = widget.profile?.name ?? '';
    _startAction = widget.profile?.startAction ?? '';
    _stopAction = widget.profile?.stopAction ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile == null ? 'Nuevo Perfil' : 'Editar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nombre del Perfil (ej: Zello, App X)'),
                validator: (v) => v!.isEmpty ? 'Falta el nombre' : null,
                onSaved: (v) => _name = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _startAction,
                decoration: const InputDecoration(labelText: 'Intent Action: Empezar a hablar'),
                validator: (v) => v!.isEmpty ? 'Falta el action' : null,
                onSaved: (v) => _startAction = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _stopAction,
                decoration: const InputDecoration(labelText: 'Intent Action: Dejar de hablar'),
                validator: (v) => v!.isEmpty ? 'Falta el action' : null,
                onSaved: (v) => _stopAction = v!,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final provider = Provider.of<PTTProvider>(context, listen: false);
                      if (widget.profile == null) {
                        provider.addProfile(PTTProfile(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: _name,
                          startAction: _startAction,
                          stopAction: _stopAction,
                        ));
                      } else {
                        provider.updateProfile(widget.profile!.copyWith(
                          name: _name,
                          startAction: _startAction,
                          stopAction: _stopAction,
                        ));
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('GUARDAR CONFIGURACIÓN'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
