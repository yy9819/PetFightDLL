package com.robot.petFightModule.mode
{
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.fightInfo.CatchPetInfo;
   import com.robot.core.info.fightInfo.ChangePetInfo;
   import com.robot.core.info.fightInfo.FightPetInfo;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.info.fightInfo.attack.AttackValue;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.pet.petWar.PetWarController;
   import com.robot.petFightModule.PetFightMsgManager;
   import com.robot.petFightModule.RemainHpManager;
   import com.robot.petFightModule.TimerManager;
   import com.robot.petFightModule.control.FighterModeFactory;
   import com.robot.petFightModule.control.UseSkillController;
   import com.robot.petFightModule.view.BaseFighterPetWin;
   import com.robot.petFightModule.view.BaseFighterPropView;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.filters.GlowFilter;
   import com.robot.petFightModule.PetFightEntry;
   public class BaseFighterMode extends EventDispatcher
   {
      public static const ATTACK_OVER:String = "attackOver";
      
      public var level:uint;
      
      private var _userID:uint;
      
      protected var _propView:BaseFighterPropView;
      
      public var hp:int;
      
      protected var enemy:BaseFighterMode;
      
      public var petName:String;
      
      public var catchable:Boolean;
      
      protected var _petWin:BaseFighterPetWin;
      
      public var changeHp:Number;
      
      public var catchTime:uint;
      
      public var maxHP:uint;
      
      public var skillCon:UseSkillController;
      
      public var petID:uint;
      
      public var skinId:uint;

      public var shiny:uint;

      public function BaseFighterMode(fightPetInfo:FightPetInfo, param2:Sprite)
      {
         super();
         _userID = fightPetInfo.userID;
         petID = fightPetInfo.petID;
         var petInfo:PetInfo = PetFightEntry._petInfoMap.getValue(fightPetInfo.catchTime);
         skinId = petInfo.skinID;
         shiny = petInfo.shiny;
         // shiny = uint(1);
         petName = PetXMLInfo.getName(petID);
         catchTime = fightPetInfo.catchTime;
         hp = fightPetInfo.hp;
         maxHP = fightPetInfo.maxHP;
         level = fightPetInfo.level;
         catchable = fightPetInfo.catchable;
         addEventListener(PetFightEvent.NO_BLOOD,onNoBloodHandler);
         addEventListener(PetFightEvent.REMAIN_HP,onItemRemainHp);
      }
      
      public function createView(param1:Sprite) : void
      {
         var _loc2_:Sprite = null;
         initSkillCon();
         _loc2_ = param1["OtherInfoPanel"];
         _propView = new BaseFighterPropView(_loc2_);
         _propView.update(this);
         _petWin = new BaseFighterPetWin();
         _petWin.addEventListener(PetFightEvent.ON_OPENNING,onOpenning);
         _petWin.update(petID,shiny,skinId);
         if(MainManager.actorInfo.maxPuniLv == 2)
         {
            _petWin.petMC.filters = null;
            _petWin.petMC.filters = [new GlowFilter(16724736,1,20,20,1.6)];
         }
      }
      
      private function onItemRemainHp(param1:PetFightEvent) : void
      {
         var _loc2_:uint = uint(param1.dataObj);
         this.hp = _loc2_;
         propView.resetBar(this);
      }
      
      public function destroy() : void
      {
         removeEventListener(PetFightEvent.NO_BLOOD,onNoBloodHandler);
         removeEventListener(PetFightEvent.REMAIN_HP,onItemRemainHp);
         skillCon.removeEventListener(PetFightEvent.LOST_HP,lostHpHandler);
         skillCon.removeEventListener(PetFightEvent.GAIN_HP,gainHpHandler);
         skillCon.removeEventListener(PetFightEvent.REMAIN_HP,remainHpHandler);
         skillCon.removeEventListener(UseSkillController.MOVIE_OVER,onMovieOver);
         skillCon.destroy();
         skillCon = null;
         _propView.destroy();
         _propView = null;
         _petWin.removeEventListener(PetFightEvent.ON_OPENNING,onOpenning);
         _petWin.destroy();
         _petWin = null;
      }
      
      public function get enemyMode() : BaseFighterMode
      {
         return enemy;
      }
      
      protected function onOpenning(param1:PetFightEvent) : void
      {
      }
      
      public function changePet(changePetInfo:ChangePetInfo) : void
      {
         petID = changePetInfo.petID;
         var petInfo:PetInfo = PetFightEntry._petInfoMap.getValue(changePetInfo.catchTime);
         skinId = petInfo.skinID;
         shiny = petInfo.shiny;
         // shiny = uint(1);
         petName = PetXMLInfo.getName(petID);
         level = changePetInfo.level;
         hp = changePetInfo.hp;
         maxHP = changePetInfo.maxHp;
         _propView.update(this,true);
         _petWin.update(petID,shiny,skinId);
         if(this == FighterModeFactory.playerMode)
         {
            TimerManager.start();
         }
      }
      
      public function useSkill(param1:AttackValue) : void
      {
         trace("------------------------- BaseFighterMode::useSkill >> start");
         trace(param1.state);
         skillCon.action(param1);
         TimerManager.clearTxt();
         if(param1.skillID != 0)
         {
            PetFightMsgManager.showText(param1);
         }
         if(param1.state == 12)
         {
            _petWin.petMC.filters = null;
            _petWin.petMC.filters = [new GlowFilter(4456539,1,20,20,1.6)];
         }
         else if(param1.state == 13)
         {
            _petWin.petMC.filters = null;
            _petWin.petMC.filters = [new GlowFilter(16776960,1,20,20,1.2)];
         }
      }
      
      public function remainHp(param1:uint) : void
      {
         var _loc3_:PetInfo = null;
         var _loc2_:Number = param1 - this.hp;
         this.hp = param1;
         propView.resetBar(this,true);
         skillCon.showChangeTxt(_loc2_);
         if(userID == MainManager.actorID)
         {
            if(PetFightModel.mode == PetFightModel.PET_MELEE)
            {
               _loc3_ = PetWarController.getPetInfo(catchTime);
            }
            else
            {
               _loc3_ = PetManager.getPetInfo(catchTime);
            }
            _loc3_.hp = this.hp;
         }
      }
      
      private function onMovieOver(param1:Event) : void
      {
         dispatchEvent(new Event(ATTACK_OVER));
      }
      
      private function lostHpHandler(param1:PetFightEvent) : void
      {
         var _loc3_:PetInfo = null;
         var _loc2_:Number = Number(param1.dataObj);
         enemy.hp -= _loc2_;
         if(enemy.hp < 0)
         {
            enemy.hp = 0;
         }
         enemy.propView.resetBar(enemy);
         if(enemy.userID == MainManager.actorID)
         {
            if(PetFightModel.mode == PetFightModel.PET_MELEE)
            {
               _loc3_ = PetWarController.getPetInfo(catchTime);
            }
            else
            {
               _loc3_ = PetManager.getPetInfo(catchTime);
            }
            if(_loc3_)
            {
               _loc3_.hp = enemy.hp;
            }
         }
      }
      
      protected function initSkillCon() : void
      {
         skillCon = new UseSkillController(this);
         skillCon.addEventListener(PetFightEvent.LOST_HP,lostHpHandler);
         skillCon.addEventListener(PetFightEvent.GAIN_HP,gainHpHandler);
         skillCon.addEventListener(PetFightEvent.REMAIN_HP,remainHpHandler);
         skillCon.addEventListener(UseSkillController.MOVIE_OVER,onMovieOver);
      }
      
      private function gainHpHandler(param1:PetFightEvent) : void
      {
         var _loc3_:PetInfo = null;
         var _loc2_:Number = Number(param1.dataObj);
         this.hp += _loc2_;
         if(this.hp < 0)
         {
            this.hp = 0;
         }
         if(this.hp > this.maxHP)
         {
            this.hp = this.maxHP;
         }
         propView.resetBar(this);
         if(userID == MainManager.actorID)
         {
            if(PetFightModel.mode == PetFightModel.PET_MELEE)
            {
               _loc3_ = PetWarController.getPetInfo(catchTime);
            }
            else
            {
               _loc3_ = PetManager.getPetInfo(catchTime);
            }
            _loc3_.hp = this.hp;
         }
         param1.fun();
      }
      
      public function catchPet(param1:CatchPetInfo = null) : void
      {
         trace("catch pet socket data");
         if(!param1)
         {
            petWin.catchFail();
         }
         else if(param1.catchTime == 0)
         {
            petWin.catchFail();
         }
         else
         {
            petWin.catchSuccess(param1);
         }
      }
      
      private function remainHpHandler(param1:PetFightEvent) : void
      {
         var _loc2_:Number = Number(param1.dataObj);
         RemainHpManager.add(this,_loc2_);
      }
      
      public function get userID() : uint
      {
         return _userID;
      }
      
      public function set enemyMode(param1:BaseFighterMode) : void
      {
         enemy = param1;
      }
      
      public function get propView() : BaseFighterPropView
      {
         return _propView;
      }
      
      public function get petWin() : BaseFighterPetWin
      {
         return _petWin;
      }
      
      protected function onNoBloodHandler(param1:PetFightEvent) : void
      {
      }
   }
}

