import 'package:flutter/widgets.dart';
import 'package:zanmutm_pos_client/src/api/api.dart';

class AppFetcher extends StatefulWidget {
  final String api;
  final Widget Function(List<Map<String, dynamic>>, bool) builder;
  const AppFetcher({Key? key, required this.api, required this.builder})
      : super(key: key);

  @override
  State<AppFetcher> createState() => _AppFetcherState();
}

class _AppFetcherState extends State<AppFetcher> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _items = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  loadItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var resp = await Api().dio.get(widget.api);
      List<Map<String, dynamic>> result = (resp.data['data'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      setState(() {
        _isLoading = false;
        _items = result;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_items, _isLoading);
  }
}
