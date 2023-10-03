import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:subspace_task/ApiService.dart';
import 'BlocState.dart';
import 'Database.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => MyBloc(ApiService()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subspace',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Subspace'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<MyBloc>(context).add(FetchDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1E1F),
        title: const Text(
          'Checkout these blogs',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SavedBlogs()),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1C1E1F),
      body: Center(
        child: BlocBuilder<MyBloc, MyBlocState>(
          builder: (context, state) {
            if (state is MyLoadingState) {
              return const CircularProgressIndicator();
            } else if (state is MySuccessState) {
              List<BlogItem> data = state.data;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DetailScreen(data[index])),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                              color: Color(0xFFFBF9F9), width: 1),
                        ),
                        color: Colors.black,
                        // color: Colors.grey[700],
                        child: Padding(
                          padding: const EdgeInsets.all(17.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.network(data[index].imageUrl),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 10),
                                child: Text(
                                  data[index].title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (state is MyErrorState) {
              return Text('Error: ${state.error}');
            }
            return Container();
          },
        ),
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final BlogItem data;

  DetailScreen(this.data, {super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {

  bool isInDatabase = false;

  @override
  void initState() {
    super.initState();
    checkIfInDatabase();
  }

  Future<void> checkIfInDatabase() async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'blogs',
      where: 'id = ?',
      whereArgs: [widget.data.id],
    );

    setState(() {
      isInDatabase = result.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
                color: isInDatabase ? Colors.red : const Color(0xFFFBF9F9),
                width: 1),
          ),
          color: Colors.black,
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.all(17.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(widget.data.imageUrl),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                    child: Text(
                      widget.data.title,
                      // overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
              ElevatedButton(
                onPressed: () async {
                  if (isInDatabase) {
                    await DatabaseHelper.instance.deleteBlog(widget.data.id);
                  } else {
                    await DatabaseHelper.instance.insertBlog(widget.data);
                  }
                  setState(() {
                    isInDatabase = !isInDatabase;
                  });
                },
                child: Text(
                  isInDatabase ? 'Remove from favorites' : 'Add to favorites',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}

class SavedBlogs extends StatefulWidget {
  @override
  _SavedBlogsState createState() => _SavedBlogsState();
}

class _SavedBlogsState extends State<SavedBlogs> {
  List<BlogItem> favoriteBlogs = [];

  @override
  void initState() {
    super.initState();
    loadFavoriteBlogs();
  }

  Future<void> loadFavoriteBlogs() async {
    List<BlogItem> blogs = await DatabaseHelper.instance.getAllBlogs();
    setState(() {
      favoriteBlogs = blogs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1E1F),
        title: const Text('Favorite Blogs',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),),
      ),
      backgroundColor: const Color(0xFF1C1E1F),
      body: ListView.builder(
      itemCount: favoriteBlogs.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      DetailScreen(favoriteBlogs[index])),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(
                    color: Color(0xFFFBF9F9), width: 1),
              ),
              color: Colors.black,
              // color: Colors.grey[700],
              child: Padding(
                padding: const EdgeInsets.all(17.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(favoriteBlogs[index].imageUrl),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 10),
                      child: Text(
                        favoriteBlogs[index].title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    )
    );
  }
}

