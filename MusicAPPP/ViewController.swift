//
//  ViewController.swift
//  Music APP
//
//  Created by 江庸冊 on 2021/11/1.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var MusicTitleLabel: UILabel!
    
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var PlayButton: UIButton!
    
    @IBOutlet weak var ReplayButton: UIButton!
    
    @IBOutlet weak var LikeButton: UIButton!
    
    @IBOutlet weak var MusicSlider: UISlider!
    
    @IBOutlet weak var PlayTimeLabel: UILabel!

    @IBOutlet weak var ProcessTimeLabel: UILabel!
    
    let player : AVQueuePlayer = AVQueuePlayer()
    
    var looper : AVPlayerLooper?
    
    var replayflag = 0
    
    var heartflag = 0

    var timeObserverToken : Any?
    
    var pauseflag = 0
    
    var song = 0 //現在第幾首歌
    
    let music = ["不屑","誰讓你流淚"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        musicinfo()
        
        //自動下一首
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,object: nil,queue:.main){ (_) in
            if self.replayflag == 0{
                self.song+=1
                self.musicinfo()
                self.player.removeTimeObserver(self.PlayObserver!)
            }else{
                self.musicinfo()
                self.player.removeTimeObserver(self.PlayObserver!)
            }
        }
    }
    //執行播放或暫停按鈕
    @IBAction func StopMusic(_ sender: UIButton) {
        switch pauseflag {
        case 0 :
            PlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            player.pause()
            pauseflag = 1
        case 1 :
            PlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            player.play()
            pauseflag = 0
        default : break
        }
    }
    //跳下一首歌按鈕
    @IBAction func PlayNextMusic(_ sender: UIButton) {
        //播放&重複播放按鈕回歸原狀
        PlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        ReplayButton.setImage(UIImage(systemName: "arrow.counterclockwise.circle"), for: .normal)
        replayflag = 0
        song+=1
        musicinfo()
    }
    //跳上一首歌按鈕
    @IBAction func PlayPreviousMusic(_ sender: UIButton) {
        //播放&重複播放按鈕回歸原狀
        PlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        ReplayButton.setImage(UIImage(systemName: "arrow.counterclockwise.circle"), for: .normal)
        replayflag = 0
        song-=1
        musicinfo()
    }
    //讓歌曲重複播放
    @IBAction func ReplayMusic(_ sender: UIButton) {
        switch replayflag{
        case 0 :
            ReplayButton.setImage(UIImage(systemName: "arrow.counterclockwise.circle.fill"), for: .normal)
            replayflag = 1
        case 1:
            ReplayButton.setImage(UIImage(systemName: "arrow.counterclockwise.circle"), for: .normal)
            replayflag = 0
        default: break
        }
    }
    //喜歡歌曲點擊按鈕
    @IBAction func LikeMusic(_ sender: UIButton) {
        switch heartflag {
        case 0:
            LikeButton.setImage(UIImage(systemName: "heart.circle.fill"), for: .normal)
            heartflag = 1
        case 1:
            LikeButton.setImage(UIImage(systemName: "heart.circle"), for: .normal)
            heartflag = 0
        default: break
        }
        print(heartflag)
    }
    //調整Slider
    @IBAction func SliderMusic(_ sender: UISlider) {
        let currenttime = Int64(MusicSlider.value)
        let targettime:CMTime = CMTimeMake(value: currenttime, timescale: 1)
        player.seek(to: targettime)
    }
    //play music!
        func musicinfo(){
            if song<music.count, song>=0{
            //播放歌曲
            if let fileurl = Bundle.main.url(forResource: music[song], withExtension: "mp3"){
                let playItem = AVPlayerItem(url: fileurl)
                player.replaceCurrentItem(with: playItem)
                looper = AVPlayerLooper(player: player, templateItem: playItem)
                player.play()
    //計算歌曲長度
    let time = CMTimeGetSeconds(playItem.asset.duration).rounded()
    ProcessTimeLabel.text = String(format: "%d:%d:%d", Int(time)/3600, (Int(time)%3600)/60, (Int(time)%3600)%60)
                
    //設定MusicSlider
                MusicSlider.minimumValue = 0
                MusicSlider.maximumValue = Float(time)
                MusicSlider.isContinuous = true
                timeobserver()
    //其他label, 專輯照片, （也可建立TextLable歌詞）等等同時改變，圖片與歌曲名稱，取名一致
                MusicTitleLabel.text = music[song]
                ImageView.image = UIImage(named: music[song])
            }}else if song<0{
            song = music.count-1
            musicinfo()
        }else{
            song = 0
            musicinfo()
        }
            
  }
        
        //監控播放的歌曲
        var PlayObserver :Any!
        func timeobserver() {
              PlayObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { (CMTime) in
                      if self.player.currentItem?.status == .readyToPlay {
                          let currentTime = CMTimeGetSeconds(self.player.currentTime())
                        self.MusicSlider.value = Float(currentTime)
                        self.PlayTimeLabel.text = String(format: "%d:%d:%d", Int(currentTime)/3600, (Int(currentTime)%3600)/60, (Int(currentTime)%3600)%60)
                      }
                  })
              }
}
