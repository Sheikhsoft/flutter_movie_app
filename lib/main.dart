import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'movieDetails.dart';

import 'package:movie_app/models/movie_model.dart';
import 'package:movie_app/tmdp.dart';

const baseUrl = Tmdb.baseUrl;
const baseImageUrl = Tmdb.baseImageUrl;
const apiKey = Tmdb.apiKey;

const nowPlayingUrl = "${baseUrl}now_playing?api_key=$apiKey";
const upComingUrl = "${baseUrl}upcoming?api_key=$apiKey";
const popularUrl = "${baseUrl}popular?api_key=$apiKey";
const topRatedUrl = "${baseUrl}top_rated?api_key=$apiKey";

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: new MyMovieApp(title: 'Movie App'),
    );
  }
}

class MyMovieApp extends StatefulWidget {
  MyMovieApp({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyMovieAppState createState() => new _MyMovieAppState();
}

class _MyMovieAppState extends State<MyMovieApp> {
  Movie nowPlayingMovies;
  Movie upComingMovies;
  Movie popularMovies;
  Movie topRatedMovies;
  int heroTag =0;
  int _currentIndex =0;

  //pagination
  int _pageNumber = 1;
  int _totalItems= 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fatchNowPlayingMovies();
    _fatchUpComingMovies();
    _fatchPopularMovies();
    _fatchTopRatedMovies();
  }

  void _fatchNowPlayingMovies() async {
    var response = await http.get(nowPlayingUrl);
    var decordJson = jsonDecode(response.body);
    setState(() {
      nowPlayingMovies = Movie.fromJson(decordJson);
    });
  }

  void _fatchUpComingMovies() async {
    var response = await http.get("${upComingUrl}&language=en-US&page=$_pageNumber");
    var decordJson = jsonDecode(response.body);
    upComingMovies==null
        ? upComingMovies = Movie.fromJson(decordJson)
    :upComingMovies.results.addAll(Movie.fromJson(decordJson).results);
    setState(() {
     _totalItems = upComingMovies.results.length;
    });
  }

  void _fatchPopularMovies() async {
    var response = await http.get(popularUrl);
    var decordJson = jsonDecode(response.body);
    setState(() {
      popularMovies = Movie.fromJson(decordJson);
    });
  }

  void _fatchTopRatedMovies() async {
    var response = await http.get(topRatedUrl);
    var decordJson = jsonDecode(response.body);
    setState(() {
      topRatedMovies = Movie.fromJson(decordJson);
    });
  }

  Widget _buildCarouserSlider() => CarouselSlider(
        items: nowPlayingMovies == null
            ? <Widget>[
                Center(
                  child: CircularProgressIndicator(),
                )
              ]
            : nowPlayingMovies.results
                .map((movieItem) =>
                    _buildMovieImage(movieItem))
                .toList(),
        autoPlay: false,
        height: 240.0,
        viewportFraction: 0.5,
      );

  Widget _buildMovieImage(Results movieItem) {
    heroTag +=1;
    movieItem.heroTag = heroTag;
    return Material(
      elevation: 15.0,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>MovieDetail(movie: movieItem,)));
        },
        child: Hero(
            tag: heroTag,
            child: movieItem.posterPath != null
                ?Image.network(
              "${baseImageUrl}w342${movieItem.posterPath}",
              fit: BoxFit.cover,
            )
                :Image.asset("images/emptyfilmposter.jpg",fit: BoxFit.cover,)
        ),
      ),
    );
  }

  Widget _buildMovieItemList(Results movieItem) => Material(
        child: Container(
          width: 128.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(6.0),
                child: _buildMovieImage(movieItem),
              ),
              Padding(
                padding: EdgeInsets.only(left: 6.0, top: 2.0),
                child: Text(
                  movieItem.title,
                  style: TextStyle(
                    fontSize: 8.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 6.0, top: 2.0),
                child: Text(
                  DateFormat('yyyy').format(DateTime.parse(movieItem.releaseDate))
                  ,
                  style: TextStyle(
                    fontSize: 8.0,
                  ),
                ),
              )
            ],
          ),
        ),
      );

  Widget _buildMovieListView(Movie movie, String movieListTitle) => Container(
        height: 258.0,
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 7.0, bottom: 7.0),
              child: Text(
                movieListTitle,
                style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400]),
              ),
            ),
            Flexible(
//              child: ListView(
//                scrollDirection: Axis.horizontal,
//                children: movie == null
//                    ? <Widget>[
//                        Center(
//                          child: CircularProgressIndicator(),
//                        )
//                      ]
//                    : movie.results.map((movieItem) => Padding(
//                          padding: EdgeInsets.only(left: 6.0, right: 2.0),
//                          child: _buildMovieItemList(movieItem),
//                        )
//                ).toList(),
//              ),
            child: _createListView(movie)
            )
          ],
        ),
      );

  Widget _createListView(Movie movie){
    return ListView.builder(

      scrollDirection: Axis.horizontal,
      itemCount: _totalItems,
      itemBuilder: (BuildContext context,int index){
        if(index >= movie.results.length - 1){
          _pageNumber ++;
          _fatchUpComingMovies();
        }
        return Padding(
          padding: EdgeInsets.only(left: 6.0,right: 2.0),
          child: _buildMovieItemList(movie.results[index]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        elevation: 0.0,
        title: new Text(
          widget.title,
        ),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.menu), onPressed: () {}),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: () {})
        ],
      ),
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext contex, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Now Playing',
                      style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                expandedHeight: 290.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: <Widget>[
                      Container(
                        child: Image.network(
                          "${baseImageUrl}w500/2uNW4WbgBXL25BAbXGLnLqX71Sw.jpg",
                          fit: BoxFit.cover,
                          width: 1000.0,
                          colorBlendMode: BlendMode.dstATop,
                          color: Colors.blue.withOpacity(0.5),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 35.0),
                          child: _buildCarouserSlider())
                    ],
                  ),
                ),
              )
            ];
          },
          body: ListView(
            children: <Widget>[
              _buildMovieListView(upComingMovies, "COMING SOON ($_pageNumber)"),
             // _buildMovieListView(popularMovies, "POPULAR M0IES"),
              //_buildMovieListView(topRatedMovies, "TOP RATED MOVIES")
            ],
          )
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.lightBlue,
        currentIndex: _currentIndex,
        onTap: (int index){
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_movies),
            title: Text('All MOVIES')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.tag_faces),
              title: Text('Tickets')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Account')
          ),
        ],
      ),
    );
  }
}
