import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:movie_app/models/credits_model.dart';
import 'package:movie_app/models/movie_detail_model.dart';
import 'package:movie_app/models/movie_model.dart';
import 'tmdp.dart';

const baseUrl = Tmdb.baseUrl;
const baseImageUrl = Tmdb.baseImageUrl;
const apiKey = Tmdb.apiKey;

class MovieDetail extends StatefulWidget {
  final Results movie;

  const MovieDetail({Key key, this.movie}) : super(key: key);
  @override
  _MovieDetailState createState() => new _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  String movieDetailsUrl;
  String movieCreditsUrl;
  MovieDetailModel movieDetails;
  MovieCredits movieCredits;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    movieDetailsUrl = "$baseUrl${widget.movie.id}?api_key=$apiKey";
    movieCreditsUrl = "$baseUrl${widget.movie.id}/credits?api_key=$apiKey";
    _fatchMovieDetails();
    _fatchMovieCredits();
  }

  void _fatchMovieDetails() async {
    var response = await http.get(movieDetailsUrl);
    var decodeJson = jsonDecode(response.body);
    setState(() {
      movieDetails = MovieDetailModel.fromJson(decodeJson);
    });
  }

  void _fatchMovieCredits() async {
    var response = await http.get(movieCreditsUrl);
    var decodeJson = jsonDecode(response.body);
    setState(() {
      movieCredits = MovieCredits.fromJson(decodeJson);
    });
  }

  String _geMovieDuration(int runtime) {
    if (runtime == null) return "No Data";
    double movieHours = runtime / 60;
    int movieMinites = ((movieHours - movieHours.floor()) * 60).round();
    return "${movieHours.floor()}h ${movieMinites}min";
  }

  @override
  Widget build(BuildContext context) {
    final moviePoster = Container(
      height: 385.0,
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Card(
        elevation: 15.0,
        child: Hero(
          tag: widget.movie.heroTag,
          child: Image.network(
            "${baseImageUrl}w342${widget.movie.posterPath}",
            fit: BoxFit.cover,
          ),
        ),
      ),
    );

    final movieTitle = Center(
      child: Text(
        widget.movie.title,
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
    );

    final movieTickets = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          movieDetails != null ? _geMovieDuration(movieDetails.runtime) : '',
          style: TextStyle(fontSize: 11.0),
        ),
        Container(
          height: 20.0,
          width: 1.0,
          color: Colors.white70,
        ),
        Text(
          "Relese Date: ${DateFormat('yyyy').format(DateTime.parse(widget.movie.releaseDate))}",
          style: TextStyle(fontSize: 11.0),
        ),
        RaisedButton(
          onPressed: () {},
          shape: StadiumBorder(),
          elevation: 15.0,
          color: Colors.red[700],
          child: Text("Ticket"),
        )
      ],
    );

    final genresList = Container(
      height: 25.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
          movieDetails == null
              ? []
              : movieDetails.genres.map(
                  (g) => Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: FilterChip(
                        label: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(g.name),
                        ),
                        onSelected: (b) {},
                      backgroundColor: Colors.grey[600],
                      labelStyle: TextStyle(fontSize: 10.0),

                    ),
                  )
          ).toList(),

      ),
    );

    final middleContent = Container(
      padding: EdgeInsets.only(left: 8.0,right: 8.0,top: 2.0),
      child: Column(
        children: <Widget>[
          Divider(),
          genresList,
          Divider(),
          Text('SYNOPSIS',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey[300]),),
          SizedBox(height: 10.0,),
          Text(widget.movie.overview,style: TextStyle(color: Colors.grey[300],fontSize: 11.0),),
          SizedBox(height: 10.0,),

        ],
      ),
    );

    final castCentent = Container(
      height: 115.0,
      padding: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left:8.0,bottom: 8.0),
            child: Text('Actors',style: TextStyle(fontSize: 12.0,fontWeight: FontWeight.bold,color: Colors.grey[400]),),
          ),
          Flexible(child: ListView(
            scrollDirection: Axis.horizontal,
            children: movieCredits == null?<Widget>[Center(child: CircularProgressIndicator(),)]
                :movieCredits.cast.map((c)=>Container(
              width: 65.0,
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 28.0,
                    backgroundImage: c.profilePath!=null?NetworkImage("${baseImageUrl}w154${c.profilePath}"):AssetImage('images/no-avatar.jpg'),
                  ),
                  Padding(
                    padding:const EdgeInsets.only(top:4.0),
                    child:Text(c.name,style:TextStyle(fontSize:8.30),overflow:TextOverflow.ellipsis)
                  ),
                  Text(c.character,style:TextStyle(fontSize:8.0),overflow:TextOverflow.ellipsis)
                  
                ],
              ),
            )).toList(),
          ),),
        ],
      ),
    );


    return new Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          "Movie Details",
          style: TextStyle(
              color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: <Widget>[moviePoster, movieTitle, movieTickets,middleContent,castCentent],
      ),
    );
  }
}
