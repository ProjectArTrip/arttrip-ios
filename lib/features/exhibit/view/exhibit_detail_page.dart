import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail.dart';
import 'package:arttrip/features/exhibit/viewmodel/exhibit_detail_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// 전시 상세 페이지
class ExhibitDetailPage extends StatefulWidget {
  const ExhibitDetailPage({super.key, required this.exhibitId});

  final int exhibitId;

  @override
  State<ExhibitDetailPage> createState() => _ExhibitDetailPageState();
}

class _ExhibitDetailPageState extends State<ExhibitDetailPage>
    with SingleTickerProviderStateMixin {
  // 색상 상수
  static const _primaryColor = Color(0xFF7859FF);
  static const _tabIndicatorColor = Color(0xFFAA97FF);
  static const _textColor = Color(0xFF111111);
  static const _closedDayColor = Color(0xFFF95353);
  static const _grayBorder = Color(0xFFDBDBDB);
  static const _infoBoxBg = Color(0xFFF5F6FA);

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExhibitDetailViewModel>().fetchExhibitDetail(
        widget.exhibitId,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var vm = context.watch<ExhibitDetailViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.errorMessage != null
          ? Center(child: Text(vm.errorMessage!))
          : vm.exhibit == null
          ? const Center(child: Text('데이터를 불러올 수 없습니다'))
          : _buildContent(vm.exhibit!),
    );
  }

  Widget _buildContent(ExhibitDetail exhibit) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 포스터 이미지 + 라운드 콘텐츠 영역
          Stack(
            children: [
              _buildPosterImage(exhibit.posterUrl),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 제목/장소/기간 섹션
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(exhibit.title),
                SizedBox(height: 16.h),
                _buildSubInfo(exhibit.hallName),
                SizedBox(height: 4.h),
                _buildSubInfo(exhibit.exhibitPeriod),
                SizedBox(height: 16.h),

                // 홈페이지 바로 가기 버튼
                _buildTicketButton(exhibit.ticketUrl),
                SizedBox(height: 24.h),
              ],
            ),
          ),

          // 탭바
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: _buildTabBar(),
          ),

          // 탭 콘텐츠
          _buildTabContent(exhibit),
        ],
      ),
    );
  }

  Widget _buildPosterImage(String posterUrl) {
    debugPrint(posterUrl);

    return Image.network(
      posterUrl,
      width: double.infinity,
      height: 276.h,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 276.h,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        height: 276.h,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image_not_supported)),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: _textColor,
        height: 1.4,
      ),
    );
  }

  Widget _buildSubInfo(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: _textColor,
      ),
    );
  }

  Widget _buildTicketButton(String ticketUrl) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: () {
          // TODO: url_launcher 패키지 추가 후 구현
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Text(
          '홈페이지 바로 가기',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _grayBorder, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: _primaryColor,
        unselectedLabelColor: const Color(0xFFA5A5AF),
        labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
        indicatorColor: _tabIndicatorColor,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 2,
        dividerHeight: 0,
        tabs: const [
          Tab(text: '상세 정보'),
          Tab(text: '리뷰'),
          Tab(text: '지도'),
        ],
      ),
    );
  }

  Widget _buildTabContent(ExhibitDetail exhibit) {
    return SizedBox(
      height: 500.h,
      child: TabBarView(
        controller: _tabController,
        children: [
          // 상세 정보 탭
          _buildDetailTab(exhibit),
          // 리뷰 탭 (레이블만)
          _buildPlaceholderTab('리뷰'),
          // 지도 탭 (레이블만)
          _buildPlaceholderTab('지도'),
        ],
      ),
    );
  }

  Widget _buildDetailTab(ExhibitDetail exhibit) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 정보 박스
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: _infoBoxBg,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  iconPath: AppAssets.icLocation2,
                  label: '주소',
                  value: exhibit.hallAddress,
                ),
                SizedBox(height: 12.h),
                _buildInfoRow(
                  iconPath: AppAssets.icTime,
                  label: '운영시간',
                  value: exhibit.hallOpeningHours,
                  extraWidget: Text(
                    '휴관일: 매주 월요일',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w300,
                      color: _closedDayColor,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                _buildInfoRow(
                  iconPath: AppAssets.icPhone,
                  label: '전화번호',
                  value: exhibit.hallPhone,
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // 전시설명 섹션
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: _infoBoxBg,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '전시설명',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  exhibit.description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w300,
                    color: _textColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String iconPath,
    required String label,
    required String value,
    Widget? extraWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(iconPath, width: 20.w, height: 20.w),
        SizedBox(width: 4.w),
        SizedBox(
          width: 66.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w300,
                  color: _textColor,
                ),
              ),
              if (extraWidget != null) ...[SizedBox(height: 4.h), extraWidget],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderTab(String label) {
    return Center(
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFA5A5AF),
        ),
      ),
    );
  }
}
