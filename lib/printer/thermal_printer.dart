import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/common.dart';
import '../provider/src.dart';

class Printer {
  Printer._();

  static List<BluetoothDevice>? _bondedDevices;

  static late BluetoothDevice _device;

  static BlueThermalPrinter get instance => BlueThermalPrinter.instance;

  static Future<void> print(BuildContext context, StateObject o,
      [double? customerPayAmount]) async {
    final scaffoldState = ScaffoldMessenger.of(context);
    if (_bondedDevices == null || _bondedDevices!.isEmpty) {
      try {
        _bondedDevices = await instance.getBondedDevices();
        if (_bondedDevices!.isEmpty) {
          const snackbar = SnackBar(content: Text('No bluetooth devices!'));
          scaffoldState.showSnackBar(snackbar);
          return;
        }
      } on PlatformException catch (e) {
        final snackbar = SnackBar(content: Text(e.toString()));
        scaffoldState.showSnackBar(snackbar);
        return;
      }
    }

    var isConnected = await instance.isConnected;
    if (isConnected != null && !isConnected) {
      _device = _bondedDevices![0];
      try {
        await instance.connect(_device);
      } on PlatformException catch (e) {
        final snackbar = SnackBar(content: Text(e.toString()));
        scaffoldState.showSnackBar(snackbar);
        return;
      }
    }
    var list = o.activeLines;
    if (list.isEmpty) {
      debugPrint('print error: empty order');
      return;
    }

    //SIZE
    // 0- normal size text
    // 1- only bold text
    // 2- bold with medium text
    // 3- bold with large text
    //ALIGN
    // 0- ESC_ALIGN_LEFT
    // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT
    await instance.printCustom('RECEIPT', 3, 1);
    await instance.printCustom(formatDate(o.checkoutTime.toLocal()), 0, 1);
    await instance.printCustom('---------', 1, 1);
    for (final i in list) {
      await instance.printLeftRight(
        '${i.dishName}(${i.quantity})',
        Money.format(i.quantity * i.price),
        0,
      );
    }
    await instance.printLeftRight('', '---------', 0);
    if (o.discountRate < 1.0) {
      await instance.printLeftRight('', Money.format(o.totalPrice), 1);
      await instance.printLeftRight('Discount:', '${((1.0 - o.discountRate) * 100).round()} %', 0);
    }
    final total = (o.totalPrice * o.discountRate).round();
    await instance.printLeftRight('Total', Money.format(total), 2);
    if (customerPayAmount != null && customerPayAmount >= total) {
      await instance.printLeftRight('Paid', Money.format(customerPayAmount), 0);
      if (customerPayAmount > total) {
        await instance.printLeftRight('Change', Money.format(customerPayAmount - total), 1);
      }
    }
    await instance.printCustom('Thank you', 2, 1);
    await instance.printNewLine();
    await instance.printNewLine();
    await instance.printNewLine();
    await instance.paperCut();
  }
}

// yyyy-mm-dd H:i:s
String formatDate(DateTime date) {
  return date.toString().substring(0, 19);
}
