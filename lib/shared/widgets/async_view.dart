import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/enum.dart';
import 'package:flutter/material.dart';

class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.state,
    required this.onData,
    this.onLoading,
    this.onError,
    this.isSliverWidget = false,
  });

  final AsyncState<T> state;
  final Widget Function(T data) onData;
  final Widget Function()? onLoading;
  final Widget Function({Object? error})? onError;
  final bool isSliverWidget;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case AsyncStatus.loading:
        return onLoading?.call() ??
            (isSliverWidget
                ? const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                )
                : const Center(child: CircularProgressIndicator()));
      case AsyncStatus.error:
        AppUtil.debugLog('AsyncView Error: ${state.error}');
        return onError?.call(error: state.error) ??
            (isSliverWidget
                ? const SliverToBoxAdapter(
                  child: Text(
                    'Something went wrong',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                )
                : const Text(
                  'Something went wrong',
                  style: TextStyle(color: AppColors.textPrimary),
                ));
      case AsyncStatus.success:
        return onData(state.data as T);
    }
  }
}

class AsyncState<T> {
  const AsyncState._({required this.status, this.data, this.error});
  const AsyncState.loading() : this._(status: AsyncStatus.loading);
  const AsyncState.success(T data)
    : this._(status: AsyncStatus.success, data: data);
  const AsyncState.error({Object? error})
    : this._(status: AsyncStatus.error, error: error);

  final AsyncStatus status;
  final T? data;
  final Object? error;
}
