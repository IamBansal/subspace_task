import 'package:flutter_bloc/flutter_bloc.dart';
import 'ApiService.dart';

abstract class MyBlocState {}

class MyLoadingState extends MyBlocState {}

class MySuccessState extends MyBlocState {
  final List<BlogItem> data;
  MySuccessState(this.data);
}

class MyErrorState extends MyBlocState {
  final String error;

  MyErrorState(this.error);
}

class FetchDataEvent{}

class MyBloc extends Bloc<FetchDataEvent, MyBlocState> {
  final ApiService apiService;

  MyBloc(this.apiService) : super(MyLoadingState()) {
    on<FetchDataEvent>((event, emit) async {
      try {
        final data = await apiService.fetchBlogs();

        if (data is List<dynamic>) {
          final List<BlogItem> blogItems = data.map((item) {
            return BlogItem(
              id: item['id'],
              imageUrl: item['image_url'],
              title: item['title'],
            );
          }).toList();

          emit(MySuccessState(blogItems));
        } else {
          emit(MyErrorState('Invalid response format'));
        }
      } catch (e) {
        emit(MyErrorState(e.toString()));
      }
    });
  }

}
