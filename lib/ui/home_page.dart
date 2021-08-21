import 'dart:async';

import 'package:codingtalk_crud_firebase/model/databrg.dart';
import 'package:codingtalk_crud_firebase/ui/detail_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Barang> _brgList= [];
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  DatabaseReference? _brgRef;

  //controler
  final  _namaBrgController = TextEditingController();
  final  _priceController = TextEditingController();
  final  _stockController = TextEditingController();
  final  _descController = TextEditingController();
  final formatCurrency = new NumberFormat('#,##0.00', 'ID');

  StreamSubscription<Event>? _onBrgSubcription;
  StreamSubscription<Event>? _onBrgChangeSubcription;

  @override
  void initState() {
    super.initState();

    _brgRef = _database.reference().child('brg');
    _brgRef!.keepSynced(true);
    _onBrgSubcription = _brgRef!.onValue.listen(_onNewBrg);
    _onBrgChangeSubcription = _brgRef!.limitToLast(10).onChildAdded.listen(_onChangeBrg);
  }

  @override
  void dispose() {
    super.dispose();
    _onBrgSubcription!.cancel();
    _onBrgChangeSubcription!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Barang"),
      ),
      body: Container(
        child: _showBrgList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          resetForm();
          showModalBottomSheet(
            isScrollControlled: true,
            elevation: 2,
            context: context,
            builder: (context) => _showDialogBrgForm(),
            backgroundColor: Colors.transparent,
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _showBrgList(){
    return Container(
        child: RefreshIndicator(
          onRefresh: () async{
            _brgRef = _database.reference().child('brg');
          },
          child: FirebaseAnimatedList(
              // reverse: true,
              query: _brgRef!,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return SizeTransition(
                  sizeFactor: animation,
                  child: Column(
                    children: [
                      ListTile(
                        onLongPress: (){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context)=> DetailPage(
                                  keyBrg: snapshot.key.toString(),
                                  namaBrg: snapshot.value["namaBrg"],
                                  favorite: snapshot.value["favorite"],
                                  price: snapshot.value["price"],
                                  stock: snapshot.value["stock"],
                                  desc: snapshot.value["desc"]
                              ))
                          );
                        },
                        trailing: Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 10,
                          children: [
                            IconButton(
                              onPressed: () => _updateBarang(snapshot.key!, snapshot.value["favorite"]),
                              icon: snapshot.value["favorite"] ? Icon(Icons.star, color: Colors.yellow[800]): Icon(Icons.star, color: Colors.grey[500]),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _deleteBarang(snapshot.key!, index),
                              icon: Icon(Icons.delete, color: Colors.red,),
                            )
                          ],
                        ),
                        title: Text(
                          '${snapshot.value["namaBrg"]}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Rp. ${formatCurrency.format(int.parse(snapshot.value["price"]))}',
                        ),
                      ),
                      SizedBox(height: 1, child: Container(color: Colors.grey[400], margin: EdgeInsets.symmetric(horizontal: 10),))
                    ],
                  )
                );
              },
            ),
      ),
    );
  }

  Widget _showDialogBrgForm(){
    return SingleChildScrollView(
        child: Container(
        margin: EdgeInsets.only(left: 20, right: 20, top: 120, bottom: 300),
        padding: EdgeInsets.all(25),
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _namaBrgController,
                autofocus: false,
                decoration: InputDecoration(
                    labelText: "Nama Barang"
                ),
              ),
              TextField(
                controller: _priceController,
                autofocus: false,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Harga"
                ),
              ),
              TextField(
                controller: _stockController,
                autofocus: false,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Stock",
                ),
              ),
              TextField(
                controller: _descController,
                autofocus: false,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Keterangan",
                ),
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  TextButton(
                    onPressed: (){
                      _addBarang(_namaBrgController.text, _priceController.text, _stockController.text, _descController.text);
                    },
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft
                    ),
                    child: Container(
                      color: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.save, color: Colors.white, size: 20),
                          Text(" Simpan ", style: TextStyle(
                              color: Colors.white
                          ))
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Container(
                      color: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 17),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.close_rounded, color: Colors.white, size: 20),
                          Text("Tutup ", style: TextStyle(
                              color: Colors.white
                          ))
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onNewBrg(Event event){
    setState(() {
      _brgList.add(Barang.fromSnapshot(event.snapshot));
    });
  }

  void _onChangeBrg(Event event){
    var oldEntry = _brgList.singleWhere((barang){
      return barang.key == event.snapshot.key;
    });
    setState(() {
      _brgList[_brgList.indexOf(oldEntry)] = Barang.fromSnapshot(event.snapshot);
    });
  }

  Future<void> _addBarang(String namaBrg, String price, String stock, String desc) async{
    if(namaBrg.length > 0){
      Barang barang= Barang(
        namaBrg: namaBrg,
        price: price,
        stock: stock,
        desc: desc,
        favorite: false,
      );
      await _brgRef!.push().set(barang.toJson());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.blue[700],
          content: Text('Data Berhasil Ditambahkan', style: TextStyle(color: Colors.white)),
        ),
      );
      Navigator.pop(context);
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[700],
          content: Text('Data Tidak Boleh Kosong', style: TextStyle(color: Colors.white)),
        ),
      );
    }
  }

  Future<void> _updateBarang(String key, bool fav) async{
    var brgFav = fav ? false : true;
    await _brgRef?.child(key).update({"favorite": brgFav});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue[700],
        content: Text('Data Berhasil Diupdate', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _deleteBarang(String key, int index) async{
    await _brgRef?.child(key).remove();
    setState(() {
      _brgList.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue[700],
        content: Text('Data Berhasil Dihapus', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void resetForm(){
    setState(() {
      _namaBrgController.text = "";
      _priceController.text = "";
      _stockController.text = "";
      _descController.text = "";
    });
  }
}
