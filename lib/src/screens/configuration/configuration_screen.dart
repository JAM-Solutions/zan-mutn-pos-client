import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({Key? key}) : super(key: key);

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(builder: (context, appState, child)  {
     return AppBaseScreen(
       appBar: AppBar(
         title: Text('Configurations'),
         leading: IconButton(icon: const Icon(Icons.arrow_back),
           onPressed:() => context.go(AppRoutes.dashboard),),
       ),
        child: ListView(
          children:  [
            ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text('Financial Year Configuration'),
              subtitle: Text('Last update'),
              onTap: () => context.push('${AppRoutes.config}/${AppRoutes.configFinancialYear}'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.point_of_sale_outlined),
              title: Text('Pos Configuration'),
              subtitle: Text('Last update'),
              onTap: () => context.push('${AppRoutes.config}/${AppRoutes.configPos}'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.monetization_on_outlined),
              title: Text('Revenue Configuration'),
              subtitle: Text('Last update'),
              onTap: () => context.push('${AppRoutes.config}/${AppRoutes.configRevenue}'),

            )
          ],
        ),
      );
    });
  }
}
