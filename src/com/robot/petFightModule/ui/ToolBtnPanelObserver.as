package com.robot.petFightModule.ui
{
   import com.robot.core.CommandID;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.Alert;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.taomee.effect.ColorFilter;
   
   public class ToolBtnPanelObserver extends BasePanelObserver implements IFightToolPanel
   {
      private var container:Sprite;
      
      private var pet_btn:MovieClip;
      
      private var btnArray:Array;
      
      private var escape_btn:MovieClip;
      
      private var fight_btn:MovieClip;
      
      private var item_btn:MovieClip;
      
      public function ToolBtnPanelObserver(param1:FightToolSubject, param2:Sprite)
      {
         var _loc3_:MovieClip = null;
         btnArray = [];
         super(param1);
         fight_btn = param2["fight_btn"];
         item_btn = param2["item_btn"];
         escape_btn = param2["escape_btn"];
         pet_btn = param2["pet_btn"];
         container = new Sprite();
         param2.addChild(container);
         btnArray.push(fight_btn,item_btn,escape_btn,pet_btn);
         for each(_loc3_ in btnArray)
         {
            _loc3_.isClick = false;
            _loc3_.buttonMode = true;
            _loc3_.addEventListener(MouseEvent.MOUSE_OVER,toolBtnOverHandler);
            _loc3_.addEventListener(MouseEvent.MOUSE_OUT,toolBtnOutHandler);
            _loc3_.addEventListener(MouseEvent.CLICK,clickBtn);
            container.addChild(_loc3_);
         }
      }
      
      private function resetOther() : void
      {
         var _loc1_:MovieClip = null;
         for each(_loc1_ in btnArray)
         {
            _loc1_.isClick = false;
            _loc1_.buttonMode = true;
            _loc1_.gotoAndStop(1);
            _loc1_.mouseEnabled = true;
            _loc1_.mouseChildren = true;
         }
      }
      
      override public function destroy() : void
      {
         var _loc1_:MovieClip = null;
         super.destroy();
         for each(_loc1_ in btnArray)
         {
            _loc1_.removeEventListener(MouseEvent.MOUSE_OVER,toolBtnOverHandler);
            _loc1_.removeEventListener(MouseEvent.MOUSE_OUT,toolBtnOutHandler);
            _loc1_.removeEventListener(MouseEvent.CLICK,clickBtn);
         }
         fight_btn = null;
         item_btn = null;
         escape_btn = null;
         pet_btn = null;
         btnArray = [];
         btnArray = null;
      }
      
      public function open() : void
      {
         container.mouseChildren = true;
         container.filters = [];
      }
      
      public function close() : void
      {
         container.mouseChildren = false;
         container.filters = [ColorFilter.setGrayscale()];
      }
      
      private function toolBtnOverHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_.gotoAndStop(2);
      }
      
      public function showFight() : void
      {
         resetOther();
         fight_btn.mouseEnabled = false;
         fight_btn.mouseChildren = false;
         fight_btn.gotoAndStop(2);
         fight_btn.isClick = true;
      }
      
      private function escape() : void
      {
         var mc:Sprite = null;
         if(PetFightModel.status == PetFightModel.FIGHT_WITH_PLAYER)
         {
            mc = Alarm.show("用户之间对战不能随便逃跑哦！");
            LevelManager.fightLevel.addChild(mc);
         }
         else
         {
            LevelManager.root.mouseChildren = false;
            MainManager.getStage().addChild(Alert.show("你确定要逃离这次战斗吗？",function():void
            {
               LevelManager.root.mouseChildren = true;
               SocketConnection.send(CommandID.ESCAPE_FIGHT);
            },function():void
            {
               subject.showFightPanel();
               LevelManager.root.mouseChildren = true;
            }));
         }
      }
      
      public function showPet(param1:Boolean = false) : void
      {
         if(param1)
         {
            return;
         }
         resetOther();
         pet_btn.mouseEnabled = false;
         pet_btn.mouseChildren = false;
         pet_btn.gotoAndStop(2);
         pet_btn.isClick = true;
      }
      
      private function toolBtnOutHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(!_loc2_.isClick)
         {
            _loc2_.gotoAndStop(1);
         }
      }
      
      private function clickBtn(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         switch(_loc2_)
         {
            case fight_btn:
               subject.showFightPanel();
               break;
            case item_btn:
               subject.showItemPanel();
               break;
            case pet_btn:
               if(PetFightModel.mode == PetFightModel.SINGLE_MODE)
               {
                  MainManager.getStage().addChild(Alarm.show("单挑模式下不能换宠哦"));
               }
               else
               {
                  subject.showPetPanel();
               }
               break;
            case escape_btn:
               escape();
         }
      }
      
      public function showItem() : void
      {
         resetOther();
         item_btn.mouseEnabled = false;
         item_btn.mouseChildren = false;
         item_btn.gotoAndStop(2);
         item_btn.isClick = true;
      }
   }
}

