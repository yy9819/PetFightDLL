package com.robot.petFightModule.control.petItemCon
{
   import com.robot.petFightModule.mode.BaseFighterMode;
   import com.robot.petFightModule.ui.controlPanel.petItem.category.AbstractPetItemCategory;
   import com.robot.petFightModule.view.BaseFighterPetWin;
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Timer;
   import gs.TweenLite;
   import org.taomee.utils.DisplayUtil;
   import com.robot.core.manager.MainManager;
   
   public class RenewBloodEffect
   {
      private var txt:TextField;
      
      private var bottomMC:MovieClip;
      
      private var effectMC:MovieClip;
      
      private var tf:TextFormat;
      
      private var _oldMode:BaseFighterMode;
      
      public function RenewBloodEffect(param1:BaseFighterMode, param2:uint, param3:int)
      {
         var timer:Timer;
         var mode:BaseFighterMode = param1;
         var itemID:uint = param2;
         var changeHp:int = param3;
         super();
         tf = new TextFormat();
         tf.font = "Arial";
         tf.color = 52224;
         tf.size = 45;
         tf.bold = true;
         tf.align = TextFormatAlign.CENTER;
         txt = new TextField();
         txt.filters = [new GlowFilter(16777215,1,6,6,5)];
         txt.width = 150;
         txt.height = 50;
         txt.x = param1.userID != MainManager.actorID ? 15 : 100;
         if(changeHp < 0)
         {
            txt.text = "-" + Math.abs(changeHp);
         }
         else
         {
            txt.text = "+" + Math.abs(changeHp);
         }
         txt.setTextFormat(tf);
         mode.petWin.petContainer.addChild(txt);
         TweenLite.to(txt,1,{"y":-30});
         timer = new Timer(2500,1);
         timer.addEventListener(TimerEvent.TIMER,closeTxt);
         timer.start();
         if(!bottomMC)
         {
            bottomMC = new Item_Blood_Bottom();
            bottomMC.x = BaseFighterPetWin.WIN_WIDTH / 2;
            bottomMC.y = BaseFighterPetWin.WIN_HEIGHT - 15;
            effectMC = new Item_Blood_Effect();
            effectMC.x = bottomMC.x;
            effectMC.y = bottomMC.y;
         }
         bottomMC.gotoAndPlay(2);
         effectMC.gotoAndPlay(2);
         mode.petWin.petContainer.addChildAt(bottomMC,0);
         mode.petWin.petContainer.addChild(effectMC);
         effectMC.addFrameScript(71,function():void
         {
            effectMC.gotoAndStop(1);
            bottomMC.gotoAndStop(1);
            effectMC.addFrameScript(71,null);
            DisplayUtil.removeForParent(bottomMC);
            DisplayUtil.removeForParent(effectMC);
         });
      }
      
      private function closeTxt(param1:TimerEvent) : void
      {
         if(txt)
         {
            DisplayUtil.removeForParent(txt);
            txt = null;
         }
         AbstractPetItemCategory.dispatchOnUsePetItem();
      }
   }
}

