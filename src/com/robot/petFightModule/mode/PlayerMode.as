package com.robot.petFightModule.mode
{
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.fightInfo.ChangePetInfo;
   import com.robot.core.info.fightInfo.FightPetInfo;
   import com.robot.petFightModule.PetFightEntry;
   import com.robot.petFightModule.TimerManager;
   import com.robot.petFightModule.data.NpcChangePetData;
   import com.robot.petFightModule.ui.ControlPanelObserver;
   import com.robot.petFightModule.ui.FightToolSubject;
   import com.robot.petFightModule.ui.ToolBtnPanelObserver;
   import com.robot.petFightModule.view.PlayerPetWin;
   import com.robot.petFightModule.view.PlayerPropView;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.DisplayUtil;

   public class PlayerMode extends BaseFighterMode
   {
      private var isPetNoBlood:Boolean = false;
      
      private var conPanelObserver:ControlPanelObserver;
      
      private var controlContainer:Sprite;
      
      public var subject:FightToolSubject;
      
      private var toolBtnObserver:ToolBtnPanelObserver;
      
      public function PlayerMode(fightPetInfo:FightPetInfo, param2:Sprite)
      {
         super(fightPetInfo,param2);
         controlContainer = param2["controlMC"];
         subject = new FightToolSubject();
         toolBtnObserver = new ToolBtnPanelObserver(subject,controlContainer);
         EventManager.addEventListener(PetFightEvent.USE_PET_ITEM,usePetItemHandler);
         subject.closePanel();
      }
      
      override public function createView(param1:Sprite) : void
      {
         var _loc2_:Sprite = null;
         initSkillCon();
         _loc2_ = param1["MyInfoPanel"];
         _propView = new PlayerPropView(_loc2_);
         _propView.update(this);
         _petWin = new PlayerPetWin();
         _petWin.addEventListener(PetFightEvent.ON_OPENNING,onOpenning);
         _petWin.update(petID,shiny,skinId);
      }
      
      public function get skillBtnViews() : Array
      {
         return conPanelObserver.skillPanel.skillBtnArray;
      }
      
      private function removePanelBG(param1:Event) : void
      {
         var _loc2_:MovieClip = controlContainer["panelBgMC"];
         DisplayUtil.removeForParent(_loc2_);
         subject.openPanel();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         controlContainer = null;
         conPanelObserver = null;
         toolBtnObserver = null;
         subject.destroy();
         subject = null;
         EventManager.removeEventListener(PetFightEvent.USE_PET_ITEM,usePetItemHandler);
      }
      
      override public function changePet(param1:ChangePetInfo) : void
      {
         super.changePet(param1);
         conPanelObserver.changePet();
         subject.showFightPanel();
         trace(PetFightEntry.isAutoSelectPet);
         if(PetFightEntry.isAutoSelectPet)
         {
            subject.openPanel();
         }
         else
         {
            subject.closePanel();
         }
      }
      
      override protected function onNoBloodHandler(param1:PetFightEvent) : void
      {
         trace("onNoBloodHandler——————————————————————");
         subject.closePanel();
         subject.showPetPanel(true);
      }
      
      public function nextRound() : void
      {
         var _loc2_:BaseFighterMode = null;
         var _loc1_:ChangePetInfo = NpcChangePetData.first();
         if(_loc1_)
         {
            _loc2_ = PetFightEntry.fighterCon.getFighterMode(_loc1_.userID);
            _loc2_.changePet(_loc1_);
         }
         subject.openPanel();
         if(this.hp == 0)
         {
            this.dispatchEvent(new PetFightEvent(PetFightEvent.NO_BLOOD));
         }
      }
      
      override protected function onOpenning(param1:PetFightEvent) : void
      {
         super.onOpenning(param1);
         trace("开场动画结束，创建技能、战斗倒计时开始");
         conPanelObserver = new ControlPanelObserver(subject);
         conPanelObserver.addEventListener(ControlPanelObserver.ON_ADD_PANEL,removePanelBG);
         conPanelObserver.init();
         controlContainer.addChild(conPanelObserver);
         TimerManager.start();
      }
      
      private function usePetItemHandler(param1:PetFightEvent) : void
      {
         TimerManager.wait();
         subject.showFightPanel();
         subject.closePanel();
      }
   }
}

