// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a vi_VN locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'vi_VN';

  static m0(total, discountPct) => "Tổng: ${total}, giảm: ${discountPct}%";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "details_customerPay" : MessageLookupByLibrary.simpleMessage("Khách trả"),
    "details_discount" : MessageLookupByLibrary.simpleMessage("Khuyến mãi"),
    "details_discountTxt" : m0,
    "details_liDeleted" : MessageLookupByLibrary.simpleMessage("(đã xóa)"),
    "details_notEnough" : MessageLookupByLibrary.simpleMessage("Không đủ"),
    "edit_menu_filterHint" : MessageLookupByLibrary.simpleMessage("Lọc bằng tên món.."),
    "edit_menu_formLabel" : MessageLookupByLibrary.simpleMessage("Tên món"),
    "edit_menu_formPrice" : MessageLookupByLibrary.simpleMessage("Giá"),
    "generic_cancel" : MessageLookupByLibrary.simpleMessage("Hủy"),
    "generic_confirm" : MessageLookupByLibrary.simpleMessage("Xác nhận"),
    "generic_deleteQuestion" : MessageLookupByLibrary.simpleMessage("Xóa?"),
    "generic_no" : MessageLookupByLibrary.simpleMessage("Không"),
    "generic_yes" : MessageLookupByLibrary.simpleMessage("Có"),
    "history_delPopUpTitle" : MessageLookupByLibrary.simpleMessage("Bỏ qua đơn này?"),
    "history_rangePickerHelpTxt" : MessageLookupByLibrary.simpleMessage("Chọn khoản ngày"),
    "lobby" : MessageLookupByLibrary.simpleMessage("Sảnh"),
    "lobby_drawerHeader" : MessageLookupByLibrary.simpleMessage("POS"),
    "lobby_menuEdit" : MessageLookupByLibrary.simpleMessage("Chỉnh sửa thực đơn"),
    "lobby_report" : MessageLookupByLibrary.simpleMessage("Báo cáo"),
    "lobby_tooltip" : MessageLookupByLibrary.simpleMessage("Nhấn & giữ để thêm bàn"),
    "main_title" : MessageLookupByLibrary.simpleMessage("Chương trình POS"),
    "menu_confirm" : MessageLookupByLibrary.simpleMessage("Xác nhận đơn")
  };
}
