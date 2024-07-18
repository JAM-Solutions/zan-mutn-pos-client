import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';
import 'package:zanmutm_pos_client/src/providers/revenue_collection_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/screens/dashboard/dashboard_screen.dart';
import 'package:zanmutm_pos_client/src/screens/revenue_collection/add_revenue_item_dialog.dart';
import 'package:zanmutm_pos_client/src/screens/revenue_collection/add_revenue_item_screen.dart';
import 'package:zanmutm_pos_client/src/screens/revenue_collection/collect_cash_screen.dart';
import 'package:zanmutm_pos_client/src/utils/helpers.dart';

class RevenueItems extends StatelessWidget {
  final bool gridView;
  final TextEditingController controller = TextEditingController();

  RevenueItems({Key? key, this.gridView = true}) : super(key: key);

  openAddItemPage(RevenueSource source) async {
    final result = await appRoute.openDialogPage(AddRevenueItemScreen(source: source));
    if(result != false && result is RevenueItem) {
      final saved = await appRoute.openDialogPage(CollectCashScreen(items: [result]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RevenueCollectionProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildSearchInput(context),
            Expanded(
                child: gridView
                    ? _buildGridView(context, provider.revenueSources)
                    : _buildListView(context, provider.revenueSources)),
          ],
        );
      },
    );
  }

  _buildSearchInput(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
        child: TextFormField(
          controller: controller,
          onChanged: (val) =>
              context.read<RevenueCollectionProvider>().searchVal = val,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      BorderSide(color: Theme.of(context).primaryColor)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(36),
                  borderSide:
                      BorderSide(color: Theme.of(context).primaryColor)),
              suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    context.read<RevenueCollectionProvider>().searchVal = null;
                  })),
        ),
      );

  _buildAvatar(item) => CircleAvatar(
        backgroundColor: Colors.blueGrey,
        child: Text(
          item.name.substring(0, 1),
          style: const TextStyle(
              fontWeight: FontWeight.normal, color: Colors.white, fontSize: 18),
        ),
      );

  _buildTitle(RevenueSource item) => Text(
        item.name,
        softWrap: true,
        textAlign: gridView ? TextAlign.center : TextAlign.left,
        style: const TextStyle(
            fontSize: 15, color: Colors.blueGrey, fontWeight: FontWeight.bold),
      );

  _buildSubTitle(RevenueSource item) => Text(
        '${currency.format(item.unitCost ?? 0)}/${item.unitName ?? ''}',
        style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
      );

  _buildListView(
          BuildContext context, final List<RevenueSource> revenueSources) =>
      ListView.separated(
        itemCount: revenueSources.length,
        itemBuilder: (BuildContext _, int index) {
          var item = revenueSources[index];
          return ListTile(
            leading: _buildAvatar(item),
            title: _buildTitle(item),
            subtitle: _buildSubTitle(item),
            // onTap: () => AddRevenueItemDialog(context).addItem(item),
            onTap: () => openAddItemPage(item),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
      );

  _buildGridView(
          BuildContext context, final List<RevenueSource> revenueSources) =>
      GridView(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 4, mainAxisSpacing: 4),
        children: revenueSources
            .map((item) => InkWell(
                  // onTap: () => AddRevenueItemDialog(context).addItem(item),
                  onTap: () => openAddItemPage(item),
                  child: Row(children: [
                    Expanded(
                      child: Card(
                          elevation: 2,
                          child: Container(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildAvatar(item),
                                const SizedBox(
                                  height: 4,
                                ),
                                _buildTitle(item),
                                const SizedBox(
                                  height: 4,
                                ),
                                _buildSubTitle(item)
                              ],
                            ),
                          )),
                    ) ],)
                ))
            .toList(),
      );
}
