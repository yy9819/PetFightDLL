package com.robot.petFightModule.ui
{
   import com.robot.petFightModule.IActivePanelObserver;
   
   public interface IFightToolPanel extends IActivePanelObserver
   {
      function showItem() : void;
      
      function showPet(param1:Boolean = false) : void;
      
      function showFight() : void;
   }
}

