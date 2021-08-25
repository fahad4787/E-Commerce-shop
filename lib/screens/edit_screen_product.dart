import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/product.dart';
import 'package:flutter_complete_guide/providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );
  var _isInit = true;
  var _isLoading = false;

  var _inItValue = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final prodcutId = ModalRoute.of(context).settings.arguments as String;
      if (prodcutId != null) {
        final product =
            Provider.of<Products>(context, listen: false).findById(prodcutId);
        _editProduct = product;
        _inItValue = {
          'title': _editProduct.title,
          'description': _editProduct.description,
          'price': _editProduct.price.toString(),
          // 'imageUrl': _editProduct.imageUrl,
          'imageUrl': '',
        };
        _imageUrlController.text = _editProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    super.dispose();
  }

  void _updateImageUrl() {
    if (_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveform() async {
    final _isValid = _form.currentState.validate();
    if (!_isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editProduct.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editProduct.id, _editProduct);
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editProduct);
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occured!'),
            content: Text('Something Went Wrong.'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('Okay'),
              )
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              _saveform();
            },
            icon: Icon(Icons.save),
          ),
        ],
        title: Text('Edit Product'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Title'),
                      initialValue: _inItValue['title'],
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Provide Some value';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                            id: _editProduct.id,
                            isFavorite: _editProduct.isFavorite,
                            title: value,
                            description: _editProduct.description,
                            price: _editProduct.price,
                            imageUrl: _editProduct.imageUrl);
                      },
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Price'),
                      initialValue: _inItValue['price'],
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Enter a Price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter a Valid Number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please Enter the Number greater then zero';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                            id: _editProduct.id,
                            isFavorite: _editProduct.isFavorite,
                            title: _editProduct.title,
                            description: _editProduct.description,
                            price: double.parse(value),
                            imageUrl: _editProduct.imageUrl);
                      },
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Description'),
                      initialValue: _inItValue['description'],
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a value';
                        }
                        if (value.length < 10) {
                          return 'Should be atleast 10 character long';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                            id: _editProduct.id,
                            isFavorite: _editProduct.isFavorite,
                            title: _editProduct.title,
                            description: value,
                            price: _editProduct.price,
                            imageUrl: _editProduct.imageUrl);
                      },
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter the a Image URL';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _editProduct = Product(
                                  id: _editProduct.id,
                                  isFavorite: _editProduct.isFavorite,
                                  title: _editProduct.title,
                                  description: _editProduct.description,
                                  price: _editProduct.price,
                                  imageUrl: value);
                            },
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveform();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
