import 'package:flutter/material.dart';
import 'package:mobile/screens/shared_widgets/custom_sliver_app_bar.dart';
import 'package:provider/provider.dart';
import '../../view_models/actividad_viewmodel.dart';

import './widgets/creditos_section.dart';
import './widgets/actividades_list_section.dart';

class HistorialActividadesScreen extends StatefulWidget {
  const HistorialActividadesScreen({super.key});

  @override
  _HistorialActividadesScreenState createState() =>
      _HistorialActividadesScreenState();
}

class _HistorialActividadesScreenState
    extends State<HistorialActividadesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActividadViewModel>().cargarActividades();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f2f5),
      body: CustomScrollView(
        slivers: [
          // Usar CustomSliverAppBar en lugar del AppBar tradicional
          const CustomSliverAppBar(
            titulo: 'Historial de Actividades',
            mostrarBotonRetroceso: true,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                const CreditosSection(),
              ],
            ),
          ),
          const ActividadesListSection(),
        ],
      ),
    );
  }
}
