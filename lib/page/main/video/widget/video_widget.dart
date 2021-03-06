
import 'package:cloud_music/base_framework/ui/widget/provider_widget.dart';
import 'package:cloud_music/base_framework/utils/show_image_util.dart';
import 'package:cloud_music/base_framework/widget_state/widget_state.dart';
import 'package:cloud_music/page/main/entity/video_entity.dart';
import 'package:cloud_music/page/main/entity/video_url_entity.dart';
import 'package:cloud_music/page/main/video/public_vm.dart';
import 'package:cloud_music/page/main/video/vm/detail_vm.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

///看起来，应该给这个widget 单写一个vm

class VideoWidget extends WidgetState implements OrderListener{

  final FijkPlayer player = FijkPlayer();

  //final int parentIndex;///tab view's index
  final VideoEntity entity;


  VideoWidget(this.entity,);

  DetailVM detailVM;

  ///视频播放地址
  VideoUrlEntity urlEntity;

  bool fetching = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async{
    if(detailVM.playState == PlayState.Playing){
      detailVM.updateVideoState(PlayState.Stop);
      player.reset();
    }
    detailVM.removeOrderListener(k: entity.data.vid);
    super.dispose();
    player.release();
  }

  @override
  void stopVideo() {
    if(mounted){
      player?.stop();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<DetailVM>(
      builder: (ctx,vm,child){
        if(detailVM == null) {
          detailVM = vm;
          detailVM.addOrderListener(entity.data.vid,this);
        }
        if(detailVM.needPause(entity, player))player.pause();
        return Stack(
          alignment: Alignment.center,
          children: [
            FijkView(player: player,fit: FijkFit.fill,),
            ///cover image
            Offstage(
              offstage: !detailVM.shouldShowCover(entity),
              child: ShowImageUtil.showImageWithDefaultError(entity.data.coverUrl + ShowImageUtil.imgBanner
                  , getWidthPx(710), getWidthPx(400),borderRadius: getHeightPx(20)),
            ),
            ///play btn
            Offstage(
              offstage: !detailVM.shouldShowCover(entity),
              child: GestureDetector(
                  onTap: (){
                    if(detailVM.playState == PlayState.Playing){
                      ///播放状态
                      if(entity.data.vid == detailVM.currentVideo.data.vid){
                        ///暂停
                        pauseVideo();

                      }else{
                        ///暂停原视频，播放新的
                        playVideo();

                      }
                    }else{
                      if(detailVM.currentVideo == null){
                        ///播放新的
                        playVideo();
                      }else{
                        if(entity.data.vid == detailVM.currentVideo.data.vid){
                          ///继续
                          resumeVideo();
                        }else{
                          ///播放新的
                          playVideo();
                        }
                      }
                    }

                  },
                  child: fetching ?
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(
                      Colors.white),)
                      :
                  Icon(Icons.play_arrow,color: Colors.white.withOpacity(0.8),size: getWidthPx(80),)
              ),
            ),
          ],
        );
      },
    );
  }

  void pauseVideo()async{
    await player.pause();
  }

  void resumeVideo()async{
    await player.start();
  }

  void playVideo(){
    fetching = true;
    detailVM.updateCurrentVideo(entity);
    detailVM.notifyListeners();
//    setState(() {
//
//    });
    detailVM.getVideoUrl(entity.data.vid)
        .then((list)async{
          fetching = false;
          if(list.isNotEmpty){
            ///只会有一个
            urlEntity = list.first;
            player.setDataSource(urlEntity.url)
              .then((value) async{
              await player.start();
            });
          }

          detailVM.updateVideoState(PlayState.Playing);
          detailVM.notifyListeners();
//          setState(() {
//
//          });
    });
  }



}




















