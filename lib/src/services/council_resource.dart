import 'package:zanmutm_pos_client/src/api/api.dart';
import 'package:zanmutm_pos_client/src/models/council.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';

class CouncilService {
  final String api = '/councils';
  Future<Council?> getcouncil(String uuid) async {
    AppStateProvider? adminHierarchyId;
    var id = AppStateProvider().user!.adminHierarchyId;
    // adminHierarchyId = context.read<AppStateProvider>().user!.adminHierarchyId!;
    var resp = await Api().dio.get('$api/$id');
    var councils = resp.data['data'];

    return councils != null ? Council.fromJson(councils) : null;
  }
}
