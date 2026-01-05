import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/features/home/domain/models/banner_model.dart' as banner_model;
import 'package:stackfood_multivendor/features/home/domain/models/cashback_model.dart';
import 'package:stackfood_multivendor/features/home/domain/services/home_service_interface.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/simple_image_cache.dart';
import 'package:get/get.dart';

class HomeController extends GetxController implements GetxService {
  final HomeServiceInterface homeServiceInterface;

  HomeController({required this.homeServiceInterface});

  List<String?>? _bannerImageList;
  List<dynamic>? _bannerDataList;
  
  // Separate lists for top and middle banners
  List<String?>? _topBannerImageList;
  List<dynamic>? _topBannerDataList;
  List<String?>? _middleBannerImageList;
  List<dynamic>? _middleBannerDataList;

  List<String?>? get bannerImageList => _bannerImageList;
  List<dynamic>? get bannerDataList => _bannerDataList;
  
  List<String?>? get topBannerImageList => _topBannerImageList;
  List<dynamic>? get topBannerDataList => _topBannerDataList;
  List<String?>? get middleBannerImageList => _middleBannerImageList;
  List<dynamic>? get middleBannerDataList => _middleBannerDataList;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  List<CashBackModel>? _cashBackOfferList;
  List<CashBackModel>? get cashBackOfferList => _cashBackOfferList;

  CashBackModel? _cashBackData;
  CashBackModel? get cashBackData => _cashBackData;

  bool _showFavButton = true;
  bool get showFavButton => _showFavButton;


  Future<void> getBannerList(bool reload, {DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    debugPrint('=== BANNER CONTROLLER DEBUG ===');
    debugPrint('getBannerList called - reload: $reload, dataSource: $dataSource, fromRecall: $fromRecall');
    debugPrint('_bannerImageList is null: ${_bannerImageList == null}');
    debugPrint('_bannerImageList length: ${_bannerImageList?.length ?? 'null'}');
    
    if(_bannerImageList == null || reload || fromRecall) {
      if(!fromRecall) {
        _bannerImageList = null;
        debugPrint('Setting _bannerImageList to null (not from recall)');
      }
      banner_model.BannerModel? bannerModel;
      if(dataSource == DataSourceEnum.local){
        debugPrint('Fetching banners from LOCAL cache...');
        bannerModel = await homeServiceInterface.getBannerList(source: DataSourceEnum.local);
        debugPrint('Local bannerModel: ${bannerModel != null ? 'received' : 'null'}');
        _prepareBannerList(bannerModel);
        getBannerList(false, dataSource: DataSourceEnum.client, fromRecall: true);
      }else{
        debugPrint('Fetching banners from CLIENT (API)...');
        bannerModel = await homeServiceInterface.getBannerList(source: DataSourceEnum.client);
        debugPrint('Client bannerModel: ${bannerModel != null ? 'received' : 'null'}');
        if (bannerModel != null) {
          debugPrint('Campaigns count: ${bannerModel.campaigns?.length ?? 0}');
          debugPrint('Banners count: ${bannerModel.banners?.length ?? 0}');
        }
        _prepareBannerList(bannerModel);
        debugPrint('After _prepareBannerList - _bannerImageList length: ${_bannerImageList?.length ?? 'null'}');
        update();
      }
    } else {
      debugPrint('Skipping banner fetch - already loaded');
    }
  }


  _prepareBannerList(banner_model.BannerModel? bannerModel){
    debugPrint('=== _prepareBannerList DEBUG ===');
    debugPrint('bannerModel is null: ${bannerModel == null}');
    
    if (bannerModel != null) {
      debugPrint('Processing bannerModel...');
      debugPrint('Campaigns: ${bannerModel.campaigns?.length ?? 0}');
      debugPrint('Banners: ${bannerModel.banners?.length ?? 0}');
      debugPrint('Top Banners: ${bannerModel.topBanners?.length ?? 0}');
      debugPrint('Middle Banners: ${bannerModel.middleBanners?.length ?? 0}');
      
      // Prepare middle banners (for backward compatibility)
      _bannerImageList = [];
      _bannerDataList = [];
      
      // Prepare top banners
      _topBannerImageList = [];
      _topBannerDataList = [];
      
      // Prepare middle banners (explicit)
      _middleBannerImageList = [];
      _middleBannerDataList = [];
      
      List<String> imageUrlsToPreload = [];
      
      // Process campaigns (these go to middle banners)
      for (var campaign in bannerModel.campaigns ?? []) {
        debugPrint('Adding campaign: ${campaign.imageFullUrl}');
        _bannerImageList!.add(campaign.imageFullUrl);
        _bannerDataList!.add(campaign);
        _middleBannerImageList!.add(campaign.imageFullUrl);
        _middleBannerDataList!.add(campaign);
        if (campaign.imageFullUrl != null && campaign.imageFullUrl!.isNotEmpty) {
          imageUrlsToPreload.add(campaign.imageFullUrl!);
        }
      }
      
      // Process middle banners (use middle_banners if available, otherwise fallback to banners)
      List<banner_model.Banner> middleBannersToProcess = bannerModel.middleBanners ?? bannerModel.banners ?? [];
      for (var banner in middleBannersToProcess) {
        debugPrint('Adding middle banner: ${banner.imageFullUrl}');
        String? imageUrl = banner.imageFullUrl;
        if(_middleBannerImageList!.contains(imageUrl)){
          imageUrl = '${banner.imageFullUrl}${middleBannersToProcess.indexOf(banner)}';
        }
        _middleBannerImageList!.add(imageUrl);
        _bannerImageList!.add(imageUrl);
        
        if(banner.food != null) {
          _middleBannerDataList!.add(banner.food);
          _bannerDataList!.add(banner.food);
        }else {
          _middleBannerDataList!.add(banner.restaurant);
          _bannerDataList!.add(banner.restaurant);
        }
        if (banner.imageFullUrl != null && banner.imageFullUrl!.isNotEmpty) {
          imageUrlsToPreload.add(banner.imageFullUrl!);
        }
      }
      
      // Process top banners
      for (var banner in bannerModel.topBanners ?? []) {
        debugPrint('Adding top banner: ${banner.imageFullUrl}');
        String? imageUrl = banner.imageFullUrl;
        if(_topBannerImageList!.contains(imageUrl)){
          imageUrl = '${banner.imageFullUrl}${(bannerModel.topBanners ?? []).indexOf(banner)}';
        }
        _topBannerImageList!.add(imageUrl);
        
        if(banner.food != null) {
          _topBannerDataList!.add(banner.food);
        }else {
          _topBannerDataList!.add(banner.restaurant);
        }
        if (banner.imageFullUrl != null && banner.imageFullUrl!.isNotEmpty) {
          imageUrlsToPreload.add(banner.imageFullUrl!);
        }
      }
      
      if(ResponsiveHelper.isDesktop(Get.context) && _bannerImageList!.length % 3 != 0){
        debugPrint('Adding duplicate for desktop (length not divisible by 3)');
        _bannerImageList!.add(_bannerImageList![0]);
        _bannerDataList!.add(_bannerDataList![0]);
      }
      
      debugPrint('Final _bannerImageList length: ${_bannerImageList!.length}');
      debugPrint('Final _bannerDataList length: ${_bannerDataList!.length}');
      debugPrint('Final _topBannerImageList length: ${_topBannerImageList!.length}');
      debugPrint('Final _topBannerDataList length: ${_topBannerDataList!.length}');
      debugPrint('Final _middleBannerImageList length: ${_middleBannerImageList!.length}');
      debugPrint('Final _middleBannerDataList length: ${_middleBannerDataList!.length}');
      
      // Preload banner images for better performance
      if (imageUrlsToPreload.isNotEmpty) {
        SimpleImageCache.preloadImages(imageUrlsToPreload);
      }
    }
    update();
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }


  Future<void> getCashBackOfferList({DataSourceEnum dataSource = DataSourceEnum.local}) async {
    _cashBackOfferList = null;
    List<CashBackModel>? cashBackOfferList;

    if(dataSource == DataSourceEnum.local){
      cashBackOfferList = await homeServiceInterface.getCashBackOfferList(source: DataSourceEnum.local);
      _prepareCashBackOfferList(cashBackOfferList);
      getCashBackOfferList(dataSource: DataSourceEnum.client);
    }else{
      cashBackOfferList = await homeServiceInterface.getCashBackOfferList(source: DataSourceEnum.client);
      _prepareCashBackOfferList(cashBackOfferList);
    }
  }


  _prepareCashBackOfferList(List<CashBackModel>? cashBackOfferList){
    if(cashBackOfferList != null) {
      _cashBackOfferList = [];
      _cashBackOfferList!.addAll(cashBackOfferList);
    }
    update();
  }

  void forcefullyNullCashBackOffers() {
    _cashBackOfferList = null;
    update();
  }

  Future<void> getCashBackData(double amount) async {
    CashBackModel? cashBackModel = await homeServiceInterface.getCashBackData(amount);
    if(cashBackModel != null) {
      _cashBackData = cashBackModel;
    }
    update();
  }

  void changeFavVisibility(){
    _showFavButton = !_showFavButton;
    update();
  }

}