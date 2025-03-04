package com.robot.petFightModule.ui.controlPanel.petItem.category
{
   import com.robot.core.CommandID;
   import com.robot.core.net.SocketConnection;
   import com.robot.petFightModule.control.FighterModeFactory;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import org.taomee.utils.DisplayUtil;
   
   public class RenewBloodItemCategory extends AbstractPetItemCategory implements IPetItemCategory
   {
      private var txt:TextField;
      
      private var bottomMC:MovieClip;
      
      private var effectMC:MovieClip;
      
      private var tf:TextFormat;
      
      public function RenewBloodItemCategory(param1:uint)
      {
         super(param1);
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
         txt.x = 15;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         DisplayUtil.removeForParent(txt);
         txt = null;
         if(bottomMC)
         {
            DisplayUtil.removeForParent(bottomMC);
            DisplayUtil.removeForParent(effectMC);
         }
         bottomMC = null;
         effectMC = null;
      }
      
      override protected function useItem(param1:MouseEvent) : void
      {
         super.useItem(param1);
         SocketConnection.send(CommandID.USE_PET_ITEM,FighterModeFactory.playerMode.catchTime,_itemID,0);
         --_itemNum;
         refreshInfo();
      }
   }
}

