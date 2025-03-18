package com.robot.petFightModule
{
   import com.robot.app.automaticFight.AutomaticFightManager;
   import com.robot.core.CommandID;
   import com.robot.core.SoundManager;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.FightLoadPercentInfo;
   import com.robot.core.info.fightInfo.FighetUserInfo;
   import com.robot.core.info.fightInfo.FightStartInfo;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.info.fightInfo.attack.FightOverInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.pet.petWar.PetWarController;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.petFightModule.assetManager.AssetsEvent;
   import com.robot.petFightModule.assetManager.AssetsLoadManager;
   import com.robot.petFightModule.control.PetFightController;
   import com.robot.petFightModule.loadUI.PetWarLoadingUI;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.text.TextField;
   import flash.utils.ByteArray;
   import flash.utils.setTimeout;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.manager.TaomeeManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.display.SimpleButton;
   import org.taomee.ds.HashMap;
   import flash.net.SharedObject;
   import com.robot.core.manager.SOManager;
   import org.taomee.manager.ToolTipManager;
   import com.robot.app.emotion.EmotionController;
   import com.robot.app.im.talk.TEmotionPanel;
   import com.robot.app.emotion.EmotionListItem;
   
   public class PetFightEntry
   {
      public static var fighterCon:PetFightController;
      
      public static var isAutoSelectPet:Boolean;
      
      private static var sound:Sound;
      
      private static var loadingMC:Sprite;
      
      private static var overData:FightOverInfo;
      
      public static var currentPetCatchTime:uint;
      
      private static var assetLoading:AssetsLoadManager;
      
      private static var soundChannel:SoundChannel;
      
      public static var isCanAuto:Boolean = false;

      public static var _petInfoMap:HashMap = new HashMap();

      public static var _speedMultiplierShowMC:MovieClip;

      public static var _speedMultiplierHideMC:MovieClip;

      public static var _speedMultiplier1:SimpleButton; 
      public static var _speedMultiplier2:SimpleButton; 
      public static var _speedMultiplier3:SimpleButton; 
      public static var hideBtn:MovieClip 

      public static var _emotionBtnMC:SimpleButton;
      private static var _emotionPanel:FightEmotionPanel;
      private static var _info:FightStartInfo;

      public static var so:SharedObject = SOManager.getUserSO(SOManager.LOCAL_CONFIG); 

      public function PetFightEntry()
      {
         super();
      }
      
      private static function comHandler(param1:Event) : void
      {
         var e:Event = param1;
         (loadingMC as PetWarLoadingUI).removeEventListener(Event.COMPLETE,comHandler);
         setTimeout(function():void
         {
            SocketConnection.send(CommandID.READY_TO_FIGHT);
         },4000);
      }
      private static function onEmotion(e:MouseEvent):void
      {
         if(_emotionPanel == null)
         {
            _emotionPanel = new FightEmotionPanel(_info.otherInfo.userID,fighterCon.mainPanel);
         }
         if(DisplayUtil.hasParent(_emotionPanel))
         {
            _emotionPanel.hide();
         }
         else
         {
            _emotionPanel.show(_emotionBtnMC);
         }
      }
      

      private static function onStartFight(param1:PetFightEvent) : void
      {
         LevelManager.fightLevel.addChild(fighterCon.mainPanel);
         SoundManager.stopSound();
         if(SoundManager.isPlay_b)
         {
            soundChannel = sound.play(0,9999999);
         }
         DisplayUtil.removeForParent(loadingMC);
         loadingMC = null;
         var fightStartInfo:FightStartInfo = param1.dataObj as FightStartInfo;
         isCanAuto = fightStartInfo.isCanAuto;
         if(isCanAuto && Boolean(AutomaticFightManager.isStart))
         {
            AutomaticFightManager.showFightTips();
         }
         fighterCon.setup(fightStartInfo);
         UserManager.clear();
         
         _speedMultiplierShowMC = fighterCon.mainPanel["speedMultiplierShowMC"] as MovieClip;
         _speedMultiplierHideMC = fighterCon.mainPanel["speedMultiplierHideMC"] as MovieClip;
         _emotionBtnMC = fighterCon.mainPanel["emotionBtn"] as SimpleButton;
         if(fightStartInfo.otherInfo.userID != 0)
         {
            _info = fightStartInfo;
            TaomeeManager.stage.frameRate = 30;
            _speedMultiplierShowMC.visible = false;
            _speedMultiplierHideMC.visible = false;
            _emotionBtnMC.visible = true;
            ToolTipManager.add(_emotionBtnMC,"表情");
            _emotionBtnMC.addEventListener(MouseEvent.CLICK,onEmotion);
            _emotionPanel = new FightEmotionPanel(_info.otherInfo.userID,fighterCon.mainPanel);
            return
         }
         TaomeeManager.stage.frameRate = 24 * TaomeeManager.fightSpeed;
         _emotionBtnMC.visible = false;
         _speedMultiplierShowMC.visible = true;
         _speedMultiplierShowMC.buttonMode = true;
         _speedMultiplierShowMC.mouseEnabled = true;
         _speedMultiplierHideMC.visible = false;
         _speedMultiplierHideMC.buttonMode = true;
         _speedMultiplierHideMC.mouseEnabled = true;
         hideBtn = _speedMultiplierHideMC["speedMultiplierMCHideBtn"] as MovieClip;
         for(var i:int = 1;i<=3;i++){
            _speedMultiplierHideMC["frame"+i.toString()].visible = TaomeeManager.fightSpeed == i;
         }
         hideBtn.buttonMode = true;
         hideBtn.mouseEnabled = true;
         _speedMultiplierShowMC.addEventListener(MouseEvent.CLICK,function():void{
            _speedMultiplierShowMC.visible = false;
            _speedMultiplierHideMC.visible = true;
         })
         hideBtn.addEventListener(MouseEvent.CLICK,function():void{
            _speedMultiplierShowMC.visible = true;
            _speedMultiplierHideMC.visible = false;
         })
         _speedMultiplier1 = _speedMultiplierHideMC["speedMultiplier1"] as SimpleButton;
         _speedMultiplier2 = _speedMultiplierHideMC["speedMultiplier2"] as SimpleButton;
         _speedMultiplier3 = _speedMultiplierHideMC["speedMultiplier3"] as SimpleButton;
         _speedMultiplier1.addEventListener(MouseEvent.CLICK,function():void{
            speedMultiplier(1);
         })
         _speedMultiplier2.addEventListener(MouseEvent.CLICK,function():void{
            speedMultiplier(2);
         })
         _speedMultiplier3.addEventListener(MouseEvent.CLICK,function():void{
            speedMultiplier(3);
         })
      }
      
      private static function speedMultiplier(speed:Number):void{
         TaomeeManager.fightSpeed = speed;
         if(TaomeeManager.fightSpeed > 3) TaomeeManager.fightSpeed = 1;
         so.data["speed"] = TaomeeManager.fightSpeed;
         SOManager.flush(so);
         for(var i:int = 1;i<=3;i++){
            _speedMultiplierHideMC["frame"+i.toString()].visible = TaomeeManager.fightSpeed == i;
         }
         TaomeeManager.stage.frameRate = 24 * TaomeeManager.fightSpeed;
      }

      private static function init() : void
      {
         SocketConnection.addCmdListener(CommandID.READY_TO_FIGHT,onReadyToFight);
         SocketConnection.addCmdListener(CommandID.LOAD_PERCENT,onPercent);
         fighterCon = new PetFightController();
         fighterCon.addEventListener(PetFightEvent.START_FIGHT,onStartFight);
         EventManager.addEventListener(PetFightEvent.FIGHT_CLOSE,onCloseFight);
      }
      
      public static function clear(param1:FightOverInfo, param2:Boolean = false) : void
      {
         TaomeeManager.stage.frameRate = 24 ;
         var bmp:Bitmap;
         var str:String = null;
         var data:FightOverInfo = param1;
         var isCatch:Boolean = param2;
         var bmpData:BitmapData = new BitmapData(960,560,false);
         bmpData.draw(MainManager.getStage());
         bmp = new Bitmap(bmpData);
         LevelManager.fightLevel.addChild(bmp);
         if(fighterCon.isEscape)
         {
            str = "恭喜你，逃跑成功！";
            showNormalTip(bmp,str);
            return;
         }
         if(fighterCon.isOvertime)
         {
            assetLoading.removeEventListener(AssetsEvent.LOAD_ALL_ASSETS,onLoadAll);
            assetLoading.removeEventListener(AssetsEvent.PROGRESS,onProgress);
            try
            {
               assetLoading.destroy();
            }
            catch(e:Error)
            {
            }
            if(data.winnerID == MainManager.actorID)
            {
               str = "对方操作超时，你在这场战斗中获得了胜利！";
            }
            else
            {
               str = "你操作超时了，战斗结束！";
            }
            showNormalTip(bmp,str);
            return;
         }
         if(fighterCon.isDraw)
         {
            str = "这场战斗双方打成平手！^_^";
            showNormalTip(bmp,str);
            return;
         }
         if(fighterCon.isSysError)
         {
            str = "很抱歉，系统出错，本次战斗结束";
            showNormalTip(bmp,str);
            return;
         }
         if(fighterCon.isPlayerLost)
         {
            str = "对方中途退出，你在这场战斗中获得了胜利！";
            showNormalTip(bmp,str);
            return;
         }
         if(fighterCon.isNpcEscape)
         {
            str = "很可惜，这只精灵逃跑了！";
            showNormalTip(bmp,str);
            return;
         }
         if(isCatch)
         {
            bmp.parent.removeChild(bmp);
            bmp = null;
            EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.PET_UPDATE_PROP,bmp));
            destroy();
            return;
         }
         if(data.winnerID == MainManager.actorID)
         {
            FightOverPanel.showWin(bmp,overData);
         }
         else
         {
            FightOverPanel.showLost(bmp,overData);
         }
         destroy();
      }
      
      private static function onPercent(param1:SocketEvent) : void
      {
         var _loc3_:uint = 0;
         var _loc2_:FightLoadPercentInfo = param1.data as FightLoadPercentInfo;
         if(_loc2_.id != MainManager.actorID)
         {
            if(loadingMC)
            {
               if(PetFightModel.mode != PetFightModel.PET_MELEE)
               {
                  if(loadingMC["otherPercentTxt"].text)
                  {
                     loadingMC["otherPercentTxt"].text = _loc2_.percent + "%";
                  }
               }
            }
         }
      }
      
      private static function onReadyToFight(param1:SocketEvent) : void
      {
         var _loc4_:TextField = null;
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         if(PetFightModel.mode != PetFightModel.PET_MELEE)
         {
            if(_loc3_ == MainManager.actorID)
            {
               _loc4_ = loadingMC["myPercentTxt"];
            }
            else
            {
               _loc4_ = loadingMC["otherPercentTxt"];
            }
            if(_loc4_)
            {
               _loc4_.text = "OK";
            }
         }
      }
      
      private static function onProgress(param1:AssetsEvent) : void
      {
         var _loc2_:TextField = null;
         if(PetFightModel.mode != PetFightModel.PET_MELEE)
         {
            _loc2_ = loadingMC["myPercentTxt"];
            if(_loc2_)
            {
               _loc2_.text = param1.percent.toString();
            }
         }
      }
      
      private static function onCloseFight(param1:PetFightEvent) : void
      {
         var data:FightOverInfo = null;
         var event:PetFightEvent = param1;
         data = event.dataObj["data"];
         overData = data;
         setTimeout(function():void
         {
            clear(data);
         },1000);
      }
      
      private static function destroy() : void
      {
         RemainHpManager.clear();
         if(soundChannel)
         {
            soundChannel.stop();
         }
         PetFightModel.enemyName = "";
         SocketConnection.removeCmdListener(CommandID.READY_TO_FIGHT,onReadyToFight);
         SocketConnection.removeCmdListener(CommandID.LOAD_PERCENT,onPercent);
         fighterCon.removeEventListener(PetFightEvent.START_FIGHT,onStartFight);
         fighterCon.destroy();
         fighterCon = null;
         EventManager.removeEventListener(PetFightEvent.FIGHT_CLOSE,onCloseFight);
         LevelManager.openMouseEvent();
         SoundManager.playSound();
         if(loadingMC)
         {
            loadingMC.parent.removeChild(loadingMC);
            loadingMC = null;
         }
         if(_speedMultiplierShowMC.visible || _speedMultiplierHideMC.visible)
         {
            hideBtn.removeEventListener(MouseEvent.CLICK);
            _speedMultiplierShowMC.removeEventListener(MouseEvent.CLICK);
            _speedMultiplier1.removeEventListener(MouseEvent.CLICK)
            _speedMultiplier2.removeEventListener(MouseEvent.CLICK)
            _speedMultiplier3.removeEventListener(MouseEvent.CLICK)
         }else
         {
            ToolTipManager.remove(_emotionBtnMC);
            _emotionBtnMC.removeEventListener(MouseEvent.CLICK,onEmotion);
            SocketConnection.removeCmdListener(CommandID.XIN_CHAT);
            if(_emotionPanel)
            {
               _emotionPanel = null;
            }
         }
      }
      
      private static function onLoadAll(param1:Event) : void
      {
         assetLoading.removeEventListener(AssetsEvent.LOAD_ALL_ASSETS,onLoadAll);
         assetLoading.removeEventListener(AssetsEvent.PROGRESS,onProgress);
         trace("加载完成");
         assetLoading.destroy();
         if(PetFightModel.mode == PetFightModel.PET_MELEE)
         {
            (loadingMC as PetWarLoadingUI).startLoad();
            (loadingMC as PetWarLoadingUI).addEventListener(Event.COMPLETE,comHandler);
         }
         else
         {
            SocketConnection.send(CommandID.READY_TO_FIGHT);
         }
      }
      
      public static function setup(param1:Array, param2:Array, param3:Array,petInfoMap:HashMap) : void
      {
         _petInfoMap = petInfoMap;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:FighetUserInfo = null;
         if(PetFightModel.status == PetFightModel.FIGHT_WITH_BOSS)
         {
            sound = new boss_sound();
         }
         else
         {
            sound = new FightBg_Sound();
         }
         init();
         assetLoading = new AssetsLoadManager();
         for each(_loc4_ in param2)
         {
            assetLoading.addPetID(_loc4_);
         }
         for each(_loc5_ in param3)
         {
            assetLoading.addSkillID(_loc5_);
         }
         if(!loadingMC)
         {
            if(PetFightModel.mode != PetFightModel.PET_MELEE)
            {
               loadingMC = new FightLoadingMC();
               if(PetFightModel.status == PetFightModel.FIGHT_WITH_PLAYER)
               {
                  loadingMC["iconMC"].gotoAndStop(1);
               }
               else
               {
                  loadingMC["iconMC"].gotoAndStop(2);
               }
               loadingMC["myNameTxt"].text = MainManager.actorInfo.nick;
               _loc6_ = PetFightModel.enemyName;
               for each(_loc7_ in param1)
               {
                  if(_loc7_.id != MainManager.actorID && _loc7_.nickName != "")
                  {
                     _loc6_ = _loc7_.nickName;
                     PetFightModel.enemyName = _loc6_;
                     break;
                  }
               }
               loadingMC["otherNameTxt"].text = _loc6_;
               if(PetFightModel.status != PetFightModel.FIGHT_WITH_PLAYER)
               {
                  loadingMC["otherPercentTxt"].text = "OK";
               }
            }
            else
            {
               loadingMC = new PetWarLoadingUI(PetWarController.allPetIdA);
            }
         }
         LevelManager.root.addChild(loadingMC);
         assetLoading.addEventListener(AssetsEvent.LOAD_ALL_ASSETS,onLoadAll);
         assetLoading.addEventListener(AssetsEvent.PROGRESS,onProgress);
         assetLoading.loadAssets();
      }
      
      private static function showNormalTip(param1:Bitmap, param2:String) : void
      {
         var sprite:Sprite;
         var bmp:Bitmap = param1;
         var str:String = param2;
         if(AutomaticFightManager.isStart)
         {
            AutomaticFightManager.fightOver(bmp);
            destroy();
            return;
         }
         sprite = Alarm.show(str,function():void
         {
            EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.ALARM_CLICK,overData));
            EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.PET_UPDATE_PROP,bmp));
         });
         MainManager.getStage().addChild(sprite);
         destroy();
      }
   }

}

import flash.display.Sprite;
import com.robot.app.emotion.EmotionListItem;
import flash.display.DisplayObject;
import flash.events.MouseEvent;
import com.robot.core.manager.MainManager;
import org.taomee.utils.DisplayUtil;
import org.taomee.component.manager.PopUpManager;
import com.robot.core.manager.UIManager;
import org.taomee.events.SocketEvent;
import com.robot.core.info.ChatInfo;
import com.robot.core.manager.UserManager;
import com.robot.core.net.SocketConnection;
import com.robot.core.CommandID;
import flash.utils.ByteArray;
import com.robot.core.ui.alert.Alarm;
import flash.geom.Point;
import com.robot.core.ui.DialogBox;
import flash.display.MovieClip;

class FightEmotionPanel extends Sprite
{
   private var _panel:Sprite;
   
   private var _userID:uint;

   private var _mainPanel:Sprite

   private static const MAX:int = 131;

   protected var _dialogBox:DialogBox;

   public function FightEmotionPanel(userID:uint,mainPanel:Sprite)
   {
      var item:EmotionListItem = null;
      super();
      this._userID = userID;
      this._panel = UIManager.getSprite("Panel_Background_4");
      this._panel.mouseChildren = false;
      this._panel.mouseEnabled = false;
      this._panel.cacheAsBitmap = true;
      this._panel.width = 299;
      this._panel.height = 118;
      this._panel.alpha = 0.6;
      addChild(this._panel);
      for(var i:int = 0; i < 23; i++)
      {
         item = new EmotionListItem(i);
         item.x = 6 + (item.width + 2) * int(i / 3);
         item.y = 6 + (item.height + 2) * int(i % 3);
         addChild(item);
         item.addEventListener(MouseEvent.CLICK,this.onItemClick);
      }
      this._mainPanel = mainPanel;
      SocketConnection.addCmdListener(CommandID.XIN_CHAT,this.onChat);
   }
   public function show(btn:DisplayObject) : void
   {
      PopUpManager.showForDisplayObject(this,btn,PopUpManager.TOP_RIGHT,true,new Point(-30,0));
   }
   
   public function hide() : void
   {
      DisplayUtil.removeForParent(this);
   }
   
   private function onItemClick(e:MouseEvent) : void
   {
      var item:EmotionListItem = e.currentTarget as EmotionListItem;
      var byte:ByteArray = new ByteArray();
      var msg:String = "$" + item.id.toString();
      var sLen:int = msg.length;
      var i:int = 0;
      for(i = 0; i < sLen; i++)
      {
         if(byte.length > MAX)
         {
            break;
         }
         byte.writeUTFBytes(msg.charAt(i));
      }
      byte.writeUTFBytes("0");
      SocketConnection.send(CommandID.XIN_CHAT,_userID,byte.length,byte);
      this.hide();
   }

   private function onChat(event:SocketEvent) : void
   {
      try
      {
         var data:ChatInfo = event.data as ChatInfo;
         if(Boolean(this._dialogBox))
         {
            this._dialogBox.destroy();
            this._dialogBox = null;
         }
         this._dialogBox = new DialogBox();
         this._dialogBox.name = "dialogBox";
         if(data.senderID == MainManager.actorID)
         {
            this._dialogBox.show(data.msg,
               50,
               (this._mainPanel["MyInfoPanel"] as MovieClip).height/2,
               this._mainPanel);
         }else
         {
            this._dialogBox.show(data.msg,
               (this._mainPanel["OtherInfoPanel"] as MovieClip).x + 250,
               (this._mainPanel["OtherInfoPanel"] as MovieClip).height/2,
               this._mainPanel);
         }
      }
      catch (error:Error)
      {
         Alarm.show(error + "  " + data.msg)
      }
   }
}
