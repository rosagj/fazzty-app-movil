//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

Future<Product> fetchProduct() async {
  final response = await http.get(
    Uri.parse(
        'http://faztty-back.herokuapp.com/faztty-ms/productosByNegocio/3'),
  );

  if (response.statusCode == 200) {
    return Product.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}

Future<Product> createProduct(String nombre, String marca, double precio,
    int puntuacion, String categoria, int catid) async {
  final response = await http.post(
    Uri.parse('http://faztty-back.herokuapp.com/faztty-ms/nuevoProducto/3'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      "nombre": nombre,
      "marca": marca,
      "precio": precio,
      "puntuacion": puntuacion,
      "categoria": categoria,
      "catid": catid
    }),
  );
  if (response.statusCode == 201) {
    print("Se guardo el producto");
    return Product.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create album.');
  }
}

Future<Product> deleteProduct(int id) async {
  final http.Response response = await http.delete(
    Uri.parse(
        'http://faztty-back.herokuapp.com/faztty-ms/eliminarProducto/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  if (response.statusCode == 200) {
    return Product.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to delete album.');
  }
}

Future<Product> updateProduct(int id, String nombre, String marca,
    double precio, int puntuacion, String categoria, int catid) async {
  final response = await http.put(
    Uri.parse(
        'http://faztty-back.herokuapp.com/faztty-ms/modificarProducto/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'id': id,
      "nombre": nombre,
      "marca": marca,
      "precio": precio,
      "puntuacion": puntuacion,
      "categoria": categoria,
      "catid": catid
    }),
  );
  if (response.statusCode == 200) {
    return Product.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to update album.');
  }
}

class Product {
  final int id;
  final String nombre;
  final String marca;
  final double precio;
  final int puntuacion;
  final String imagen;
  final String categoria;
  final int catid;

  Product(
      {required this.id,
      required this.nombre,
      required this.marca,
      required this.precio,
      required this.puntuacion,
      required this.imagen,
      required this.categoria,
      required this.catid});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nombre: json['nombre'],
      marca: json['marca'],
      precio: json['precio'],
      puntuacion: json['puntuacion'],
      imagen: json['imagen'],
      categoria: json['categoria'],
      catid: json['catid'],
    );
  }
}

final TextEditingController _id = TextEditingController();
final TextEditingController _nombre = TextEditingController();
final TextEditingController _marca = TextEditingController();
final TextEditingController _precio = TextEditingController();
final TextEditingController _puntuacion = TextEditingController();
final TextEditingController _imagen = TextEditingController();
final TextEditingController _categoria = TextEditingController();
final TextEditingController _catid = TextEditingController();

void main() => runApp(HomePage());

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "P'acha",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WidgetOrigen(),
    );
  }
}

class WidgetOrigen extends StatefulWidget {
  @override
  _WidgetOrigenState createState() => _WidgetOrigenState();
}

class _WidgetOrigenState extends State<WidgetOrigen> {
  List data = [];
  List productosData = [];
  Future<Product>? _futureProduct;

  getProductos() async {
    http.Response response = await http.get(Uri.parse(
        'http://faztty-back.herokuapp.com/faztty-ms/productosByNegocio/3'));
    //debugPrint(response.body);
    data = json.decode(response.body);
    setState(() {
      productosData = data;
    });
  }

  @override
  void initState() {
    super.initState();
    getProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("P'acha"), backgroundColor: Colors.pink[900]),
      body: ListView.builder(
          itemCount: productosData == null ? 0 : productosData.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.arrow_drop_down_circle),
                    title: Text("${productosData[index]["nombre"]}"),
                    subtitle: Text(
                      "S./ ${productosData[index]["precio"]} \n${productosData[index]["marca"]} ",
                      style: TextStyle(color: Colors.black, fontSize: 20.0),
                    ),
                  ),
                  Image.network(
                      'https://i.pinimg.com/originals/9e/ff/4e/9eff4e78a8ff0a9c7fa1881b2d2fc7c7.png',
                      width: 300,
                      height: 150,
                      fit: BoxFit.fill),
                  ButtonBar(
                    alignment: MainAxisAlignment.start,
                    children: [
                      // ignore: deprecated_member_use
                      FlatButton(
                        textColor: const Color.fromRGBO(199, 21, 133, 0.6),
                        onPressed: () {
                          setState(() {
                            _futureProduct = deleteProduct(int.parse(
                                productosData[index]["id"].toString()));
                            Route route = MaterialPageRoute(
                                builder: (bc) => WidgetOrigen());
                            Navigator.of(context).push(route);
                          });
                          // Perform some action
                        },
                        child: const Text('Eliminar',
                            style: TextStyle(fontSize: 20.0)),
                      ),
                      // ignore: deprecated_member_use
                      FlatButton(
                        textColor: const Color.fromRGBO(199, 21, 133, 0.6),
                        onPressed: () {
                          Route route = MaterialPageRoute(
                              builder: (bc) => WidgetModificar(
                                  pass_id: int.parse(
                                      productosData[index]['id'].toString()),
                                  pass_nombre:
                                      productosData[index]['nombre'].toString(),
                                  pass_marca:
                                      productosData[index]['marca'].toString(),
                                  pass_precio: double.parse(productosData[index]
                                          ['precio']
                                      .toString()),
                                  pass_puntuacion: int.parse(
                                      productosData[index]['puntuacion']
                                          .toString()),
                                  pass_imagen:
                                      productosData[index]['imagen'].toString(),
                                  pass_categoria:
                                      productosData[index]['categoria'].toString(),
                                  pass_catid: productosData[index]['catid'] != null ? int.parse(productosData[index]['catid'].toString()) : 1));
                          Navigator.of(context).push(route);
                        },
                        child: const Text('Editar',
                            style: TextStyle(fontSize: 20.0)),
                      )
                    ],
                  ),
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Route route = MaterialPageRoute(builder: (bc) => WidgetDestino());
          Navigator.of(context).push(route);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class WidgetDestino extends StatefulWidget {
  @override
  _WidgetDestinoState createState() => _WidgetDestinoState();
}

class _WidgetDestinoState extends State<WidgetDestino> {
  Future<Product>? _futureProduct;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("P'acha: Agregar Producto"),
          backgroundColor: Colors.pink[900]),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(20),
          child:
              (_futureProduct == null) ? buildColumn() : buildFutureBuilder(),
        ),
      ),
    );
  }

  Widget _addNewProduct() {
    return ElevatedButton.icon(
        onPressed: () {
          print("sending data");
          setState(() {
            _futureProduct = createProduct(
                _nombre.text,
                _marca.text,
                double.parse(_precio.text),
                int.parse(_puntuacion.text),
                _categoria.text,
                int.parse(_catid.text));
          });
          Route route = MaterialPageRoute(builder: (bc) => WidgetOrigen());
          Navigator.of(context).push(route);
          print(_futureProduct);
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.pink[900])),
        icon: Icon(Icons.shop),
        label: Text('Agregar Producto'));
  }

  Column buildColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _textFormNombre(),
        SizedBox(
          height: 15,
        ),
        _textFormMarca(),
        SizedBox(
          height: 15,
        ),
        _textFormPrecio(),
        SizedBox(
          height: 15,
        ),
        _textFormPuntuacion(),
        SizedBox(
          height: 15,
        ),
        _textFormCategoria(),
        SizedBox(
          height: 15,
        ),
        _textFormCatid(),
        SizedBox(
          height: 15,
        ),
        Image.network(
            'https://i.pinimg.com/originals/9e/ff/4e/9eff4e78a8ff0a9c7fa1881b2d2fc7c7.png',
            width: 150,
            height: 150,
            fit: BoxFit.fill),
        SizedBox(
          height: 15,
        ),
        _addNewProduct()
      ],
    );
  }

  FutureBuilder<Product> buildFutureBuilder() {
    return FutureBuilder<Product>(
      future: _futureProduct,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!.nombre);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}

class WidgetModificar extends StatefulWidget {
  const WidgetModificar(
      {Key? key,
      required this.pass_id,
      required this.pass_nombre,
      required this.pass_marca,
      required this.pass_precio,
      required this.pass_puntuacion,
      required this.pass_imagen,
      required this.pass_categoria,
      required this.pass_catid})
      : super(key: key);

  final int pass_id;
  final String pass_nombre;
  final String pass_marca;
  final double pass_precio;
  final int pass_puntuacion;
  final String pass_imagen;
  final String pass_categoria;
  final int pass_catid;

  @override
  _WidgetModificarState createState() => _WidgetModificarState();
}

class _WidgetModificarState extends State<WidgetModificar> {
  Future<Product>? _futureProduct;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("P'acha: Editar Producto"),
          backgroundColor: Colors.pink[900]),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(20),
          child: (_futureProduct == null)
              ? buildColumnMod()
              : buildFutureBuilderMod(),
        ),
      ),
    );
  }

  Column buildColumnMod() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Nombre del producto"),
          TextField(
            controller: _nombre,
            decoration: new InputDecoration(
              hintText: widget.pass_nombre,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text("Marca del Producto"),
          TextField(
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.text,
            controller: _marca,
            decoration: new InputDecoration(
              hintText: widget.pass_marca,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text("Precio del Producto"),
          TextField(
            keyboardType: TextInputType.number,
            controller: _precio,
            decoration: new InputDecoration(
              hintText: widget.pass_precio.toString(),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text("Puntuacion del producto"),
          TextField(
            keyboardType: TextInputType.number,
            controller: _puntuacion,
            decoration: new InputDecoration(
              hintText: widget.pass_puntuacion.toString(),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text("Categoria del Producto"),
          TextField(
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.text,
            controller: _categoria,
            decoration: new InputDecoration(
              hintText: widget.pass_categoria,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text("Categorizacion"),
          TextField(
            keyboardType: TextInputType.number,
            controller: _catid,
            decoration: new InputDecoration(
              hintText: widget.pass_catid.toString(),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          _editProduct(),
        ]);
  }

  Widget _editProduct() {
    return ElevatedButton.icon(
        onPressed: () {
          print("sending data");
          setState(() {
            _futureProduct = updateProduct(
                int.parse(_id.text),
                _nombre.text,
                _marca.text,
                double.parse(_precio.text),
                int.parse(_puntuacion.text),
                _categoria.text,
                int.parse(_catid.text));
          });
          Route route = MaterialPageRoute(builder: (bc) => WidgetOrigen());
          Navigator.of(context).push(route);
          print(_futureProduct);
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.pink[900])),
        icon: Icon(Icons.shop),
        label: Text('Guardar Producto'));
  }

  FutureBuilder<Product> buildFutureBuilderMod() {
    return FutureBuilder<Product>(
      future: _futureProduct,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!.nombre);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}

//Formularios
Widget _textFormId() {
  return TextFormField(
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    controller: _id,
    decoration: InputDecoration(
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        labelStyle: TextStyle(color: Colors.pink[400], fontSize: 15),
        labelText: "Identificador"),
  );
}

Widget _textFormNombre() {
  return TextFormField(
    textCapitalization: TextCapitalization.words,
    keyboardType: TextInputType.text,
    controller: _nombre,
    decoration: InputDecoration(
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        labelStyle: TextStyle(color: Colors.pink[400], fontSize: 15),
        labelText: "Nombre del Producto"),
  );
}

Widget _textFormMarca() {
  return TextFormField(
    textCapitalization: TextCapitalization.words,
    keyboardType: TextInputType.text,
    controller: _marca,
    //controller: _controller,
    decoration: InputDecoration(
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        labelStyle: TextStyle(color: Colors.pink[400], fontSize: 15),
        labelText: "Marca del Producto"),
  );
}

Widget _textFormPrecio() {
  return TextFormField(
    keyboardType: TextInputType.number,
    controller: _precio,
    //controller: _controller,
    decoration: InputDecoration(
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        labelStyle: TextStyle(color: Colors.pink[400], fontSize: 15),
        labelText: "Precio del Producto"),
  );
}

Widget _textFormPuntuacion() {
  return TextFormField(
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    controller: _puntuacion,
    //controller: _controller,
    decoration: InputDecoration(
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        labelStyle: TextStyle(color: Colors.pink[400], fontSize: 15),
        labelText: "Puntuación del Producto"),
  );
}

Widget _textFormImagen() {
  return TextFormField(
    textCapitalization: TextCapitalization.words,
    keyboardType: TextInputType.text,
    controller: _imagen,
    //controller: _controller,
    decoration: InputDecoration(
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        labelStyle: TextStyle(color: Colors.pink[400], fontSize: 15),
        labelText: "Imagen"),
  );
}

Widget _textFormCategoria() {
  return TextFormField(
    textCapitalization: TextCapitalization.words,
    keyboardType: TextInputType.text,
    controller: _categoria,
    //controller: _controller,
    decoration: InputDecoration(
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        labelStyle: TextStyle(color: Colors.pink[400], fontSize: 15),
        labelText: "Categoría del Producto"),
  );
}

Widget _textFormCatid() {
  return TextFormField(
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    controller: _catid,
    //controller: _controller,
    decoration: InputDecoration(
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
            borderRadius: BorderRadius.circular(
              7.0,
            )),
        labelStyle: TextStyle(color: Colors.pink[400], fontSize: 15),
        labelText: "Categorización"),
  );
}
