import 'package:flutter/material.dart';
import 'package:prova_p2_mobile/api/imdb.api.dart';
import 'package:prova_p2_mobile/components/item_detail_header.dart';
import 'package:prova_p2_mobile/components/technical_sheet_movie.dart';
import 'package:prova_p2_mobile/components/technical_sheet_tv_show.dart';
import 'package:prova_p2_mobile/model/item_detail.abstract.model.dart';
import 'package:prova_p2_mobile/model/movie_detail.model.dart';
import 'package:prova_p2_mobile/model/tv_show_detail.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailedView extends StatefulWidget {
  final int itemId;
  final String type;
  DetailedView({Key? key, required this.itemId, required this.type})
      : super(key: key);

  @override
  _DetailedViewState createState() => _DetailedViewState();
}

class _DetailedViewState extends State<DetailedView>
    with SingleTickerProviderStateMixin {
  late ItemDetail item;
  late TabController _tabController;
  bool isAdded = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchItem();
    _tabController = TabController(length: 2, vsync: this);
    checkIfFavorite(); // Verifica se o item já está nos favoritos
  }

  /// Carrega os dados do item com base no tipo
  Future<void> fetchItem() async {
    setState(() {
      isLoading = true;
    });
    switch (widget.type) {
      case "Filmes":
        item = await fetchSingleMovie(widget.itemId);
        break;
      case "Séries":
        item = await fetchSingleTvShow(widget.itemId);
        break;
      default:
        print('Erro ao carregar dados.');
    }
    setState(() {
      isLoading = false;
    }); // Atualizar a interface após carregar o item
  }

  /// Verifica se o item está na lista de favoritos
  Future<void> checkIfFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteMovies = prefs.getStringList('favorites') ?? [];
    setState(() {
      isAdded = favoriteMovies.contains(widget.itemId.toString());
    });
  }

  /// Adiciona ou remove o item dos favoritos
  void toggleButton() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteMovies = prefs.getStringList('favorites') ?? [];

    setState(() {
      if (isAdded) {
        // Remove o ID do filme da lista de favoritos
        favoriteMovies.remove(widget.itemId.toString());
      } else {
        // Adiciona o ID do filme à lista de favoritos
        favoriteMovies.add(widget.itemId.toString());
      }
      isAdded = !isAdded;
    });

    await prefs.setStringList('favorites', favoriteMovies);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                ItemDetailHeader(
                  description: item.overview,
                  imageUrl: item.imageUrl,
                  title: item.title ?? item.name!,
                  type: widget.type,
                ),
                // Botões "Assista" e "Minha Lista"
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => print('clicou'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow,
                                color: Color.fromRGBO(35, 35, 35, 1),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Assista',
                                style: TextStyle(
                                  color: Color.fromRGBO(35, 35, 35, 1),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                              ),
                            ),
                            fixedSize:
                                MaterialStateProperty.all(Size.fromHeight(60)),
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(16)),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: toggleButton,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: isAdded
                                    ? Colors.yellow
                                    : Color.fromARGB(255, 177, 169, 169),
                              ),
                              SizedBox(width: 8),
                              Text(
                                isAdded ? 'Adicionado' : 'Minha Lista',
                                style: TextStyle(
                                  color: isAdded
                                      ? Colors.yellow
                                      : Color.fromARGB(255, 177, 169, 169),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(
                                  color: Color.fromARGB(255, 177, 169, 169),
                                  width: 1,
                                ),
                              ),
                            ),
                            fixedSize:
                                MaterialStateProperty.all(Size.fromHeight(60)),
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.black,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(
                          child: Text(
                        'Assista Também',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      )),
                      Tab(
                        child: Text(
                          'Detalhes',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Aba de "Assista Também"
                      Text('Filmes relacionados',
                          style: TextStyle(color: Colors.black)),
                      // Aba "Detalhes"
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            if (widget.type == 'Filmes')
                              TechnicalSheetMovie(
                                  movie: item as MovieDetailModel)
                            else 
                                if (widget.type == 'Séries')
                              TechnicalSheetTvShow(
                                  movie: item as TvShowDetailModel),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
