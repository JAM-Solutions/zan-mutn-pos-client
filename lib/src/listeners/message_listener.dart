import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:zanmutm_pos_client/src/mixin/message_notifier_mixin.dart';
import 'package:zanmutm_pos_client/src/widgets/app_messages.dart';

class MessageListener<T extends MessageNotifierMixin> extends StatelessWidget {
  final Widget child;

  const MessageListener({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<T, Tuple2<String?, String?>>(
      selector: (context, model) => Tuple2(model.error, model.info),
      shouldRebuild: (before, after) =>
          before.item1 != after.item1 || before.item2 != after.item2,
      builder: (context, tuple, child) {
        if (tuple.item1 != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleError(context, tuple.item1!);
          });
        }
        if (tuple.item2 != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleInfo(context, tuple.item2!);
          });
        }
        return child!;
      },
      child: child,
    );
  }

  void _handleError(BuildContext context, String error) {
    if (ModalRoute.of(context)!.isCurrent) {
      AppMessages.showError(context, error);
      Provider.of<T>(context, listen: false).clearError();
    }
  }

  void _handleInfo(BuildContext context, String info) {
    if (ModalRoute.of(context)!.isCurrent) {
      Provider.of<T>(context, listen: false).clearInfo();
    }
  }
}
