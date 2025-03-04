package com.robot.petFightModule.control
{
   import com.robot.app.automaticFight.AutomaticFightManager;
   import com.robot.core.CommandID;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.fightInfo.CatchPetInfo;
   import com.robot.core.info.fightInfo.ChangePetInfo;
   import com.robot.core.info.fightInfo.FightPetInfo;
   import com.robot.core.info.fightInfo.FightStartInfo;
   import com.robot.core.info.fightInfo.UsePetItemInfo;
   import com.robot.core.info.fightInfo.attack.AttackValue;
   import com.robot.core.info.fightInfo.attack.FightOverInfo;
   import com.robot.core.info.fightInfo.attack.UseSkillInfo;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.petFightModule.PetFightEntry;
   import com.robot.petFightModule.PetFightMsgManager;
   import com.robot.petFightModule.RemainHpManager;
   import com.robot.petFightModule.TimerManager;
   import com.robot.petFightModule.control.petItemCon.UsePetItemController;
   import com.robot.petFightModule.data.NpcChangePetData;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import com.robot.petFightModule.mode.PlayerMode;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.filters.BlurFilter;
   import flash.filters.ColorMatrixFilter;
   import flash.utils.setTimeout;
   import org.taomee.ds.HashMap;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.DisplayUtil;
   
   public class PetFightController extends EventDispatcher
   {
      private var isReciveUseSkillCmd:Boolean = false;
      
      private var isPlaySkillMovie:Boolean = false;
      
      public var isSysError:Boolean = false;
      
      public var isDraw:Boolean = false;
      
      private var queue:Array = [];
      
      private var petContainer:Sprite;
      
      private var overData:FightOverInfo;
      
      private var isUsingItem:Boolean = false;
      
      public var isCatch:Boolean = false;
      
      public var isNpcEscape:Boolean = false;
      
      public var isEscape:Boolean = false;
      
      private var _mainPanel:Sprite;
      
      public var isOvertime:Boolean = false;
      
      private var hashMap:HashMap;
      
      public var isPlayerLost:Boolean = false;
      
      public var alarmSprite:Sprite;
      
      private var isFightOver:Boolean = false;
      
      public function PetFightController()
      {
         super();
         hashMap = new HashMap();
         createMainUI();
         SocketConnection.addCmdListener(CommandID.NOTE_USE_SKILL,onUseSkill);
         SocketConnection.addCmdListener(CommandID.FIGHT_OVER,onFightOver);
         SocketConnection.addCmdListener(CommandID.CHANGE_PET,onChangePet);
         SocketConnection.addCmdListener(CommandID.ESCAPE_FIGHT,onEscapeFight);
         SocketConnection.addCmdListener(CommandID.USE_PET_ITEM,onUsePetItem);
         SocketConnection.addCmdListener(CommandID.CATCH_MONSTER,onCatchMonster);
         SocketConnection.addCmdListener(CommandID.GET_PET_INFO,onGetPetInfo);
         EventManager.addEventListener(PetFightEvent.PET_HAS_EXIST,hasExistHandler);
         EventManager.addEventListener(PetFightEvent.ON_USE_PET_ITEM,onUsePetItemOver);
      }
      
      private static function onGetPetInfo(param1:SocketEvent) : void
      {
         var _loc2_:PetInfo = param1.data as PetInfo;
         PetManager.add(_loc2_);
      }
      
      public function destroy() : void
      {
         var _loc1_:BaseFighterMode = null;
         SocketConnection.removeCmdListener(CommandID.NOTE_USE_SKILL,onUseSkill);
         SocketConnection.removeCmdListener(CommandID.FIGHT_OVER,onFightOver);
         SocketConnection.removeCmdListener(CommandID.CHANGE_PET,onChangePet);
         SocketConnection.removeCmdListener(CommandID.ESCAPE_FIGHT,onEscapeFight);
         SocketConnection.removeCmdListener(CommandID.USE_PET_ITEM,onUsePetItem);
         SocketConnection.removeCmdListener(CommandID.CATCH_MONSTER,onCatchMonster);
         SocketConnection.removeCmdListener(CommandID.GET_PET_INFO,onGetPetInfo);
         EventManager.removeEventListener(PetFightEvent.PET_HAS_EXIST,hasExistHandler);
         EventManager.removeEventListener(PetFightEvent.ON_USE_PET_ITEM,onUsePetItemOver);
         for each(_loc1_ in hashMap.getValues())
         {
            _loc1_.removeEventListener(BaseFighterMode.ATTACK_OVER,onAttackOver);
            _loc1_.destroy();
         }
         hashMap.clear();
         hashMap = null;
         DisplayUtil.removeAllChild(_mainPanel);
         DisplayUtil.removeForParent(_mainPanel);
         _mainPanel = null;
         FighterModeFactory.clear();
         TimerManager.stop();
         petContainer = null;
      }
      
      private function onUseSkill(param1:SocketEvent) : void
      {
         if(PetFightEntry.isCanAuto && Boolean(AutomaticFightManager.isStart))
         {
            AutomaticFightManager.subTimes();
         }
         trace("------------------------- get use skill data");
         isReciveUseSkillCmd = true;
         var _loc2_:UseSkillInfo = param1.data as UseSkillInfo;
         queue = [];
         queue.push(_loc2_.firstAttackInfo);
         queue.push(_loc2_.secondAttackInfo);
         if(!isUsingItem)
         {
            execute();
         }
      }
      
      private function hasExistHandler(param1:PetFightEvent) : void
      {
         alarmSprite = Alarm.show("你已经有了一只同样的精灵，不能重复捕捉！");
         MainManager.getStage().addChild(alarmSprite);
         var _loc2_:BaseFighterMode = getFighterMode(MainManager.actorID);
         _loc2_.catchPet();
      }
      
      private function onUsePetItem(param1:SocketEvent) : void
      {
         isUsingItem = true;
         var _loc2_:UsePetItemInfo = param1.data as UsePetItemInfo;
         var _loc3_:BaseFighterMode = getFighterMode(_loc2_.userID);
         UsePetItemController.useItem(_loc3_,_loc2_);
      }
      
      private function onCatchMonster(param1:SocketEvent) : void
      {
         trace("catch pet");
         isUsingItem = true;
         var _loc2_:CatchPetInfo = param1.data as CatchPetInfo;
         var _loc3_:BaseFighterMode = getFighterMode(MainManager.actorID);
         _loc3_.catchPet(_loc2_);
      }
      
      private function onEscapeFight(param1:SocketEvent) : void
      {
         isEscape = true;
      }
      
      private function onChangePet(param1:SocketEvent) : void
      {
         var _loc3_:BaseFighterMode = null;
         var _loc2_:ChangePetInfo = param1.data as ChangePetInfo;
         if(_loc2_.userID == 0)
         {
            NpcChangePetData.add(_loc2_);
         }
         else
         {
            _loc3_ = getFighterMode(_loc2_.userID);
            _loc3_.changePet(_loc2_);
         }
      }
      
      private function createMainUI() : void
      {
         _mainPanel = new ui_mainPanel();
         petContainer = _mainPanel["petContainer"];
         initBackground();
         TimerManager.setup(_mainPanel["time_txt"]);
         PetFightMsgManager.setup(_mainPanel["msgMC"]);
      }
      
      private function addFightUI() : void
      {
         petContainer.addChild(FighterModeFactory.enemyMode.petWin);
         petContainer.addChild(FighterModeFactory.playerMode.petWin);
      }
      
      public function getFighterMode(param1:uint) : BaseFighterMode
      {
         return hashMap.getValue(param1) as BaseFighterMode;
      }
      
      public function get mainPanel() : Sprite
      {
         return _mainPanel;
      }
      
      private function initBackground() : void
      {
         DisplayUtil.removeAllChild(_mainPanel["bgContainer"]);
         var _loc1_:BitmapData = new BitmapData(MainManager.getStageWidth(),MainManager.getStageHeight());
         _loc1_.draw(MapManager.currentMap.root.getChildAt(0));
         var _loc2_:Bitmap = new Bitmap(_loc1_);
         var _loc3_:Array = [0.7,0.4,0.1,0,0,0.6,0.4,0.1,0,-10,0.5,0.4,0.1,0,-25,0,0,0,1,0];
         _loc2_.filters = [new ColorMatrixFilter(_loc3_),new BlurFilter(4,4,3)];
         _mainPanel["bgContainer"].addChild(_loc2_);
         MapManager.destroy();
      }
      
      private function onFightOver(param1:SocketEvent) : void
      {
         var date:Date;
         var event:SocketEvent = param1;
         overData = event.data as FightOverInfo;
         isFightOver = true;
         EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.FIGHT_RESULT,overData));
         if(isEscape)
         {
            RemainHpManager.showChange();
            EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.FIGHT_CLOSE,{"data":overData}));
            MapManager.refMap(false);
            return;
         }
         if(overData.reason == 1)
         {
            isPlayerLost = true;
         }
         else if(overData.reason == 2)
         {
            isOvertime = true;
         }
         else if(overData.reason == 3)
         {
            isDraw = true;
         }
         else if(overData.reason == 4)
         {
            isSysError = true;
         }
         else if(overData.reason == 5)
         {
            isNpcEscape = true;
         }
         if(!isPlaySkillMovie && !isCatch && !isUsingItem)
         {
            RemainHpManager.showChange();
            EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.FIGHT_CLOSE,{"data":overData}));
         }
         date = new Date();
         trace("////////////////////////////////////////////////////////\r//\r//\t\t\t" + date.getDate() + "-" + date.getHours() + ":" + date.getMinutes() + "  fight over data\r//\r////////////////////////////////////////////////////////");
         setTimeout(function():void
         {
            MapManager.refMap(false);
         },1000);
      }
      
      private function execute(param1:Boolean = false) : void
      {
         var _loc2_:AttackValue = null;
         var _loc3_:BaseFighterMode = null;
         if(!queue)
         {
            return;
         }
         if(queue.length > 0)
         {
            _loc2_ = queue.shift() as AttackValue;
            _loc3_ = getFighterMode(_loc2_.userID);
            _loc3_.useSkill(_loc2_);
            if(_loc2_.skillID != 0)
            {
               petContainer.addChild(_loc3_.petWin);
               TimerManager.clearTxt();
               isPlaySkillMovie = true;
            }
            else if(param1)
            {
               RemainHpManager.showChange();
               EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.FIGHT_CLOSE,{"data":overData}));
            }
            else
            {
               PetFightMsgManager.showText(_loc2_);
               execute();
               trace("------------------------- use skill[skillid == 0 && !isOver]");
            }
         }
         else if(isReciveUseSkillCmd)
         {
            RemainHpManager.showChange();
            TimerManager.start();
            PlayerMode(FighterModeFactory.playerMode).nextRound();
            isReciveUseSkillCmd = false;
         }
      }
      
      private function onAttackOver(param1:Event) : void
      {
         isPlaySkillMovie = false;
         var _loc2_:BaseFighterMode = param1.currentTarget as BaseFighterMode;
         if(isFightOver)
         {
            if(_loc2_.userID == overData.winnerID)
            {
               RemainHpManager.showChange();
               EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.FIGHT_CLOSE,{"data":overData}));
            }
            else
            {
               execute(true);
            }
         }
         else
         {
            execute();
         }
      }
      
      public function setup(param1:FightStartInfo) : void
      {
         var _loc3_:FightPetInfo = null;
         var _loc4_:BaseFighterMode = null;
         var _loc2_:Array = param1.infoArray;
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = FighterModeFactory.createMode(_loc3_,mainPanel);
            _loc4_.addEventListener(BaseFighterMode.ATTACK_OVER,onAttackOver);
            _loc4_.createView(_mainPanel);
            hashMap.add(_loc4_.userID,_loc4_);
         }
         FighterModeFactory.playerMode.enemyMode = FighterModeFactory.enemyMode;
         FighterModeFactory.enemyMode.enemyMode = FighterModeFactory.playerMode;
         addFightUI();
      }
      
      private function onUsePetItemOver(param1:PetFightEvent) : void
      {
         isUsingItem = false;
         execute();
      }
   }
}

