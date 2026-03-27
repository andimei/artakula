import 'package:flutter/material.dart';

// class AccountFormController extends ChangeNotifier {
//   VoidCallback? _submit;
//   VoidCallback? _delete;

//   void bind({
//     required VoidCallback onSubmit,
//     VoidCallback? onDelete,
//   }) {
//     _submit = onSubmit;
//     _delete = onDelete;
//   }

//   void submit() => _submit?.call();
//   void delete() => _delete?.call();
// }

class AccountFormController {
  VoidCallback? _submit;
  VoidCallback? _delete;

  void bind({
    required VoidCallback onSubmit,
    required VoidCallback onDelete,
  }) {
    _submit = onSubmit;
    _delete = onDelete;
  }

  void submit() {
    _submit?.call();
  }

  void delete() {
    _delete?.call();
  }
}