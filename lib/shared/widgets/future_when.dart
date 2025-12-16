import 'package:flutter/material.dart';

class FutureWhen<T> extends StatelessWidget {
  const FutureWhen({
    super.key,
    required this.future,
    required this.data,
    this.loading,
    this.error,
  });
  final Future<T> future;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object error)? error;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // TODO: 로딩화면 수정 예정
          return loading?.call() ??
              const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // TODO: 오류 화면 수정 예정
          return error?.call(snapshot.error!) ??
              Center(
                  child: Text('오류 발생: ${snapshot.error}',
                      style: const TextStyle(color: Colors.black)));
        }

        if (snapshot.hasData) {
          return data(snapshot.data as T);
        }

        return const SizedBox.shrink();
      },
    );
  }
}
