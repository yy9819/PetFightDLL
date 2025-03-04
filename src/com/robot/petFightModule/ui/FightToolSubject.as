package com.robot.petFightModule.ui
{
   public class FightToolSubject
   {
      private var array:Array = [];
      
      public function FightToolSubject()
      {
         super();
      }
      
      public function showFightPanel() : void
      {
         var _loc1_:IFightToolPanel = null;
         for each(_loc1_ in array)
         {
            _loc1_.showFight();
         }
         trace("显示战斗面板");
      }
      
      public function openPanel() : void
      {
         var _loc1_:IFightToolPanel = null;
         for each(_loc1_ in array)
         {
            _loc1_.open();
         }
      }
      
      public function showItemPanel() : void
      {
         var _loc1_:IFightToolPanel = null;
         for each(_loc1_ in array)
         {
            _loc1_.showItem();
         }
         trace("显示物品面板");
      }
      
      public function showPetPanel(param1:Boolean = false) : void
      {
         var _loc2_:IFightToolPanel = null;
         for each(_loc2_ in array)
         {
            _loc2_.showPet(param1);
         }
         trace("显示精灵面板");
      }
      
      public function destroy() : void
      {
         var _loc1_:IFightToolPanel = null;
         for each(_loc1_ in array)
         {
            _loc1_.destroy();
         }
         array = [];
      }
      
      public function del(param1:IFightToolPanel) : void
      {
         var _loc2_:int = int(array.indexOf(param1));
         if(_loc2_ != -1)
         {
            array.splice(_loc2_,1);
         }
      }
      
      public function closePanel() : void
      {
         var _loc1_:IFightToolPanel = null;
         for each(_loc1_ in array)
         {
            _loc1_.close();
         }
      }
      
      public function registe(... rest) : void
      {
         var _loc2_:IFightToolPanel = null;
         for each(_loc2_ in rest)
         {
            array.push(_loc2_);
         }
      }
   }
}

