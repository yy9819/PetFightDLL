package com.robot.petFightModule.ui.controlPanel.petItem.category
{
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.userItem.SingleItemInfo;
   import com.robot.core.manager.ItemManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.ui.itemTip.ItemInfoTip;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.DisplayUtil;
   
   public class AbstractPetItemCategory implements IPetItemCategory
   {
      protected var glowFilter:GlowFilter = new GlowFilter(16777215,1,2,2,50,3);
      
      protected var _sprite:Sprite;
      
      protected var _itemID:uint;
      
      protected var _txt:TextField;
      
      private var tf:TextFormat;
      
      protected var _itemNum:uint;
      
      public function AbstractPetItemCategory(param1:uint)
      {
         super();
         _itemID = param1;
         tf = new TextFormat();
         tf.size = 12;
         tf.color = 16777215;
         tf.align = TextFormatAlign.CENTER;
         _sprite = new Sprite();
         _sprite.graphics.beginFill(0,0);
         _sprite.graphics.drawRect(0,0,50,50);
         _sprite.mouseChildren = false;
         _sprite.buttonMode = true;
         _txt = new TextField();
         _txt.name = "numTxt";
         _txt.width = 28;
         _txt.height = 20;
         _txt.filters = [glowFilter];
         _txt.x = 38;
         _txt.y = 30;
         _txt.setTextFormat(tf);
         _itemNum = ItemManager.getCollectionInfo(_itemID).itemNum;
         _txt.text = _itemNum.toString();
         _sprite.addChild(_txt);
         _sprite.addEventListener(MouseEvent.CLICK,useItem);
         _sprite.addEventListener(MouseEvent.MOUSE_OVER,overHandler);
         _sprite.addEventListener(MouseEvent.MOUSE_OUT,outHandler);
         var _loc2_:Loader = new Loader();
         _loc2_.load(new URLRequest(ItemXMLInfo.getIconURL(_itemID)));
         _sprite.addChild(_loc2_);
      }
      
      public static function dispatchOnUsePetItem() : void
      {
         EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.ON_USE_PET_ITEM));
      }
      
      protected function useItem(param1:MouseEvent) : void
      {
         EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.USE_PET_ITEM));
      }
      
      private function outHandler(param1:MouseEvent) : void
      {
         ItemInfoTip.hide();
      }
      
      protected function refreshInfo() : void
      {
         _txt.text = _itemNum.toString();
         if(_itemNum == 0)
         {
            DisplayUtil.removeForParent(_sprite);
         }
      }
      
      public function get sprite() : Sprite
      {
         return _sprite;
      }
      
      public function get itemID() : uint
      {
         return _itemID;
      }
      
      private function overHandler(param1:MouseEvent) : void
      {
         var _loc2_:SingleItemInfo = ItemManager.getCollectionInfo(_itemID);
         ItemInfoTip.show(_loc2_,false,MainManager.getStage());
      }
      
      public function destroy() : void
      {
         DisplayUtil.removeForParent(_sprite);
         _sprite.removeEventListener(MouseEvent.CLICK,useItem);
         _sprite.removeEventListener(MouseEvent.MOUSE_OVER,overHandler);
         _sprite.removeEventListener(MouseEvent.MOUSE_OUT,outHandler);
         _sprite = null;
         _txt = null;
      }
   }
}

