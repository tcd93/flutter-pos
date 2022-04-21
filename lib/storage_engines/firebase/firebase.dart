import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' as lib;

import '../../provider/src.dart';
import 'firebase_options.dart';
import '../connection_interface.dart';

/// Cloud storage (for demo purpose)
///
/// Note that the `ID` key in data objects will be of type String (documentID of firestore)
class Firestore implements DatabaseConnectionInterface {
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
  }

  @override
  Future<void> truncate() {
    throw UnimplementedError('Can not destroy a Firebase storage');
  }
}

class OrderFB extends RIDRepository<Order>
    implements Readable<Order>, Insertable<Order>, Deletable<Order> {
  final CollectionReference<Order> ref;

  OrderFB()
      : ref = FirebaseFirestore.instance.collection('orders').withConverter<Order>(
              fromFirestore: (snapshot, _) {
                // override checkoutTime as String (in local time) to use in fromJson
                Timestamp checkoutTime = snapshot.data()!['checkoutTime'];
                return Order.fromJson({
                  ...snapshot.data()!,
                  'checkoutTime': checkoutTime.toDate().toLocal().toString(),
                });
              },
              // override checkoutTime to store as Timestamp (in UTC time) on firestore
              toFirestore: (order, _) =>
                  {...order.toJson(), 'checkoutTime': order.checkoutTime.toUtc()},
            );

  @override
  Future<List<Order>> get([QueryKey? from, QueryKey? to]) async {
    assert(from is DateTime);
    assert(() {
      if (to != null) return to is DateTime;
      return true;
    }());

    final orders = await ref
        .where('checkoutTime', isGreaterThanOrEqualTo: from as DateTime)
        .where('checkoutTime', isLessThan: ((to ?? from) as DateTime).add(const Duration(days: 1)))
        .get();

    return orders.docs.map((d) => d.data()).toList();
  }

  @override
  Future<Order> insert(Order value) async {
    final doc = ref.doc();
    final newValueWithID = Order.fromJson({
      ...value.toJson(),
      'ID': doc.id,
    });
    await doc.set(newValueWithID);
    return newValueWithID;
  }

  @override
  Future<void> delete(Order value) async {
    final order = await ref.where('ID', isEqualTo: value.id).get();
    if (order.size == 0) {
      throw '''Can not find any document with ID ${value.id}''';
    }
    return order.docs.first.reference.update({'isDeleted': true});
  }
}

class MenuFB extends RIUDRepository<Dish>
    with Readable<Dish>, Updatable<Dish>, Insertable<Dish>, Deletable<Dish> {
  final CollectionReference<Dish> ref;

  /// Dish name will be used as document id
  MenuFB()
      : ref = FirebaseFirestore.instance.collection('menu').withConverter<Dish>(
              fromFirestore: (snapshot, _) => Dish.fromJson(snapshot.data()!),
              toFirestore: (dish, _) =>
                  // avoid storing image data on Firestore
                  dish.toJson()..remove('imageBytes'),
            );

  @override
  Future<void> delete(Dish value) async {
    assert(value.dish.isNotEmpty);

    return ref.doc(value.id as String).delete();
  }

  @override
  Future<List<Dish>> get([QueryKey? from, QueryKey? to]) async {
    if (from != null || to != null) {
      throw 'Firebase: MenuFB.get(from, to) is not yet supported, use MenuFB.get()';
    }

    final menu = await ref.get();
    return menu.docs.map((d) => d.data()).toList();
  }

  @override
  Future<Dish> insert(Dish value) async {
    assert(value.dish.isNotEmpty);

    final doc = ref.doc();
    final newValueWithID = Dish.fromJson({
      ...value.toJson(),
      'ID': doc.id,
    });
    await doc.set(newValueWithID);
    return newValueWithID;
  }

  @override
  Future<void> update(Dish value) async {
    assert(value.dish.isNotEmpty);

    return ref.doc(value.id as String).set(value);
  }
}

class NodeFB extends RIUDRepository<Node>
    with Readable<Node>, Updatable<Node>, Insertable<Node>, Deletable<Node> {
  final CollectionReference<Node> ref;

  NodeFB()
      : ref = FirebaseFirestore.instance.collection('nodes').withConverter<Node>(
              fromFirestore: (snapshot, _) => Node.fromJson(snapshot.data()!),
              toFirestore: (node, _) => node.toJson(),
            );

  @override
  Future<void> delete(Node value) async {
    return ref.doc(value.id as String).delete();
  }

  @override
  Future<List<Node>> get([QueryKey? from, QueryKey? to]) async {
    if (from != null || to != null) {
      throw 'Firebase: NodeFB.get(from, to) is not yet supported, use NodeFB.get()';
    }

    return (await ref.get()).docs.map((d) => d.data()).toList();
  }

  @override
  Future<Node> insert(Node value) async {
    final doc = ref.doc();
    final newValueWithID = Node.fromJson({
      ...value.toJson(),
      'ID': doc.id,
    });
    await doc.set(newValueWithID);
    return newValueWithID;
  }

  @override
  Future<void> update(Node value) async {
    final node = await ref.where('ID', isEqualTo: value.id).get();
    return node.docs.first.reference.set(value);
  }
}
