package com.robot.petFightModule.ui
{
   import flash.display.Sprite;
   
   public class BasePanelObserver extends Sprite
   {
      protected var subject:FightToolSubject;
      
      public function BasePanelObserver(param1:FightToolSubject)
      {
         super();
         subject = param1;
         subject.registe(this);
      }
      
      public function destroy() : void
      {
         subject = null;
      }
   }
}

