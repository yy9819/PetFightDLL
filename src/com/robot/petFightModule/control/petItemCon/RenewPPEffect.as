package com.robot.petFightModule.control.petItemCon
{
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import com.robot.petFightModule.mode.PlayerMode;
   import com.robot.petFightModule.ui.controlPanel.petItem.category.AbstractPetItemCategory;
   import com.robot.petFightModule.ui.controlPanel.subui.SkillBtnView;
   import com.robot.petFightModule.view.BaseFighterPetWin;
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import org.taomee.utils.DisplayUtil;
   
   public class RenewPPEffect
   {
      private var bottomMC:MovieClip;
      
      private var mode:BaseFighterMode;
      
      private var itemID:uint;
      
      private var effectMC:MovieClip;
      
      public function RenewPPEffect(param1:BaseFighterMode, param2:uint)
      {
         var timer:Timer;
         var mode:BaseFighterMode = param1;
         var itemID:uint = param2;
         super();
         this.mode = mode;
         this.itemID = itemID;
         resetPP();
         timer = new Timer(2500,1);
         timer.addEventListener(TimerEvent.TIMER,closeTxt);
         timer.start();
         if(!bottomMC)
         {
            bottomMC = new Item_PP_Bottom();
            bottomMC.x = BaseFighterPetWin.WIN_WIDTH / 2;
            bottomMC.y = BaseFighterPetWin.WIN_HEIGHT - 15;
            effectMC = new Item_PP_Effect();
            effectMC.x = bottomMC.x;
            effectMC.y = bottomMC.y;
         }
         bottomMC.gotoAndPlay(2);
         effectMC.gotoAndPlay(2);
         mode.petWin.petContainer.addChildAt(bottomMC,0);
         mode.petWin.petContainer.addChild(effectMC);
         effectMC.addFrameScript(60,function():void
         {
            effectMC.gotoAndStop(1);
            bottomMC.gotoAndStop(1);
            effectMC.addFrameScript(60,null);
            DisplayUtil.removeForParent(bottomMC);
            DisplayUtil.removeForParent(effectMC);
         });
      }
      
      private function closeTxt(param1:TimerEvent) : void
      {
         AbstractPetItemCategory.dispatchOnUsePetItem();
      }
      
      private function resetPP() : void
      {
         var _loc1_:uint = 0;
         var _loc2_:SkillBtnView = null;
         if(mode is PlayerMode)
         {
            _loc1_ = uint(ItemXMLInfo.getPP(itemID));
            for each(_loc2_ in PlayerMode(mode).skillBtnViews)
            {
               _loc2_.changePP(_loc1_);
            }
         }
      }
   }
}

