import 'package:codingtalk_crud_firebase/model/databrg.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  final String keyBrg, namaBrg, price, stock, desc;
  final bool favorite;
  const DetailPage({Key? key, required this.keyBrg, required this.namaBrg,
    required this.price, required this.stock, required this.desc, required this.favorite}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<Barang> _brgList= [];
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  DatabaseReference? _brgRef;

  final _namaBrgEditController = TextEditingController();
  final  _priceEditController = TextEditingController();
  final  _stockEditController = TextEditingController();
  final  _descEditController = TextEditingController();

  bool _favoriteEditController = false;
  int _value = -1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _brgRef = _database.reference().child('brg');
    _brgRef!.keepSynced(true);

    _namaBrgEditController.text = widget.namaBrg;
    _value = widget.favorite? 1:0;
    _favoriteEditController = widget.favorite;
    _priceEditController.text = widget.price;
    _stockEditController.text = widget.stock;
    _descEditController.text = widget.desc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Barang"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Column(
          children: [
            TextField(
              controller: _namaBrgEditController,
              decoration: InputDecoration(
                labelText: "Nama Barang",
              ),
            ),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top:17, bottom: 5),
                  alignment: Alignment.centerLeft,
                  child: Text("Favorite : ", style: TextStyle(
                    fontSize: 16
                  )),
                ),
                ListTile(
                  title: Align(
                    child: Text("Favorite", style: TextStyle(
                        fontSize: 15
                    )),
                    alignment: Alignment(-1.2, 0),
                  ),
                  dense:true,
                  contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                  visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                  leading: Radio(
                    value: 1,
                    groupValue: _value,
                    activeColor: Colors.blue,
                    onChanged: (value){
                      setState(() {
                        if(value==1) {
                          _value = 1;
                          _favoriteEditController = true;
                        }
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Align(
                    child: Text("Not Favorite", style: TextStyle(
                        fontSize: 15
                    )),
                    alignment: Alignment(-1.2, 0),
                  ),
                  dense:true,
                  contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                  visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                  leading: Radio(
                    value: 0,
                    groupValue: _value,
                    onChanged: (value){
                      setState(() {
                        if(value==0) {
                          _favoriteEditController = false;
                          _value = 0;
                        }
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ),
              ],
            ),
            TextField(
              controller: _priceEditController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Harga",
              ),
            ),
            TextField(
              controller: _stockEditController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Stock",
              ),
            ),
            TextField(
              maxLines: 3,
              controller: _descEditController,
              decoration: InputDecoration(
                labelText: "Keterangan",
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                TextButton(
                    onPressed: (){
                      _updateBrg(_namaBrgEditController.text,
                          _favoriteEditController, _priceEditController.text,
                          _stockEditController.text, _descEditController.text);
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
                        Text(" Update Data ", style: TextStyle(
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
      )
    );
  }
  Future<void> _updateBrg( String _namaBrg, bool _favorite, String _price, String _stock, String  _desc) async{
    var dictBrg = {
      "namaBrg": _namaBrg,
      "favorite": _favorite,
      "price": _price,
      "stock": _stock,
      "desc": _desc
    };

    print(dictBrg);
    await _brgRef!.child(widget.keyBrg).update(dictBrg);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue[700],
        content: Text('Data Berhasil Terupdate', style: TextStyle(color: Colors.white)),
      ),
    );
    // Navigator.pop(context);
  }

}
