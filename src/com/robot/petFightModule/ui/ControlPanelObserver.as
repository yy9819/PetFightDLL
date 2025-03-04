package com.robot.petFightModule.ui
{
   import com.robot.core.CommandID;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.net.SocketConnection;
   import com.robot.petFightModule.PetFightEntry;
   import com.robot.petFightModule.TimerManager;
   import com.robot.petFightModule.ui.controlPanel.BaseControlPanel;
   import com.robot.petFightModule.ui.controlPanel.FightItemPanel;
   import com.robot.petFightModule.ui.controlPanel.IAutoActionPanel;
   import com.robot.petFightModule.ui.controlPanel.IControlPanel;
   import com.robot.petFightModule.ui.controlPanel.PetSkillPanel;
   import com.robot.petFightModule.ui.controlPanel.SelectPetPanel;
   import flash.events.Event;
   import gs.TweenLite;
   
   public class ControlPanelObserver extends BasePanelObserver implements IFightToolPanel
   {
      public static var autoAction:IAutoActionPanel;
      
      public static const ON_ADD_PANEL:String = "onAddPanel";
      
      public var skillPanel:PetSkillPanel;
      
      private var petPanel:SelectPetPanel;
      
      private var panels:Array = [];
      
      private var itemPanel:FightItemPanel;
      
      public function ControlPanelObserver(param1:FightToolSubject)
      {
         super(param1);
      }
      
      private function hideAll() : void
      {
         var _loc1_:IControlPanel = null;
         for each(_loc1_ in panels)
         {
            TweenLite.to(_loc1_.panel,0.3,{"y":BaseControlPanel.PANEL_HEIGHT});
         }
      }
      
      private function onUseSkill(param1:PetFightEvent) : void
      {
         var _loc2_:uint = uint(param1.dataObj);
         SocketConnection.send(CommandID.USE_SKILL,_loc2_);
         subject.closePanel();
         TimerManager.wait();
      }
      
      public function changePet() : void
      {
         skillPanel.createSkillBtns();
      }
      
      public function init() : void
      {
         skillPanel = new PetSkillPanel();
         skillPanel.addEventListener(PetFightEvent.USE_SKILL,onUseSkill);
         itemPanel = new FightItemPanel();
         petPanel = new SelectPetPanel();
         addPanel(skillPanel,itemPanel,petPanel);
         TimerManager.autoAction = skillPanel;
      }
      
      public function open() : void
      {
         skillPanel.openBtns();
      }
      
      public function showFight() : void
      {
         TimerManager.autoAction = skillPanel;
         hideAll();
         TweenLite.to(skillPanel.panel,0.3,{"y":0});
      }
      
      private function addPanel(... rest) : void
      {
         var _loc2_:IControlPanel = null;
         for each(_loc2_ in rest)
         {
            if(panels.length > 0)
            {
               _loc2_.panel.y = BaseControlPanel.PANEL_HEIGHT;
            }
            panels.push(_loc2_);
            addChild(_loc2_.panel);
         }
         dispatchEvent(new Event(ON_ADD_PANEL));
      }
      
      public function showPet(param1:Boolean = false) : void
      {
         hideAll();
         TweenLite.to(petPanel.panel,0.3,{"y":0});
         if(param1)
         {
            TimerManager.autoAction = petPanel;
         }
         PetFightEntry.isAutoSelectPet = param1;
         petPanel.updateCurrent();
      }
      
      public function showItem() : void
      {
         hideAll();
         TweenLite.to(itemPanel.panel,0.3,{"y":0});
      }
      
      public function close() : void
      {
         showFight();
         skillPanel.closeBtns();
      }
      
      override public function destroy() : void
      {
         var _loc1_:IControlPanel = null;
         super.destroy();
         for each(_loc1_ in panels)
         {
            _loc1_.destroy();
         }
         panels = [];
         skillPanel = null;
         itemPanel = null;
         petPanel = null;
      }
   }
}

