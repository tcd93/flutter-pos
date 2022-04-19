import 'package:firebase_core/firebase_core.dart' as lib;

import 'firebase_options.dart';
import '../connection_interface.dart';

class Firebase implements DatabaseConnectionInterface {
  late lib.FirebaseApp app;

  @override
  Future<void> close() async {
    await app.delete();
  }

  @override
  Future<void> destroy() {
    throw UnimplementedError('Can not destroy a Firebase storage');
  }

  @override
  Future open() async {
    app = await lib.Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // CollectionReference nodes = FirebaseFirestore.instance.collection('nodes');
    // print((await nodes.get()).docs.first.data());
  }

  @override
  Future<void> truncate() {
    throw UnimplementedError('Can not destroy a Firebase storage');
  }
}
