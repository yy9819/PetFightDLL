package com.robot.petFightModule.ui.controlPanel
{
   import com.robot.app.superParty.SPChannelController;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.event.ItemEvent;
   import com.robot.core.manager.ItemManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.uic.UIScrollBar;
   import com.robot.petFightModule.ui.controlPanel.petItem.PetItemCategoryFactory;
   import com.robot.petFightModule.ui.controlPanel.petItem.category.IPetItemCategory;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.taomee.utils.DisplayUtil;
   
   public class FightItemPanel extends BaseControlPanel implements IControlPanel
   {
      private var _scrollMc:UIScrollBar;
      
      private const MAX:uint = 10;
      
      private var _itemA:Array = [300001,300002,300003,300004,300005,300006,300007,300008];
      
      private var categoryArray:Array;
      
      private var idArray:Array;
      
      public function FightItemPanel()
      {
         super();
         _panel = new ui_ItemPanel();
         ItemManager.addEventListener(ItemEvent.COLLECTION_LIST,onList);
         ItemManager.getCollection();
      }
      
      private function showScroll() : void
      {
         if(!_scrollMc)
         {
            _scrollMc = new UIScrollBar(_panel["scMc"]["bar"],_panel["scMc"]["barBack"],MAX);
         }
         _scrollMc.wheelObject = _panel;
         _scrollMc.totalLength = idArray.length;
         _scrollMc.addEventListener(MouseEvent.MOUSE_MOVE,onScrollMove);
      }
      
      private function onScrollMove(param1:MouseEvent) : void
      {
         removeOldItem();
         var _loc2_:uint = uint(_scrollMc.index);
         var _loc3_:Array = idArray.slice(_scrollMc.index * MAX,(_scrollMc.index + 1) * MAX);
         showPetItem(_loc3_);
      }
      
      public function clear() : void
      {
         ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,onList);
      }
      
      private function removeOldItem() : void
      {
         var _loc1_:IPetItemCategory = null;
         if(categoryArray)
         {
            for each(_loc1_ in categoryArray)
            {
               DisplayUtil.removeForParent(_loc1_.sprite);
               _loc1_ = null;
            }
         }
      }
      
      private function showPetItem(param1:Array) : void
      {
         var _loc3_:IPetItemCategory = null;
         categoryArray = [];
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            if(Boolean(ItemXMLInfo.getIsSuper(param1[_loc2_])) && !MainManager.actorInfo.vip)
            {
               param1.splice(_loc2_,1);
               _loc2_--;
            }
            else
            {
               _loc3_ = PetItemCategoryFactory.getCategory(param1[_loc2_]);
               _loc3_.sprite.x = 24 + 56 * (_loc2_ % 5);
               _loc3_.sprite.y = 16 + 58 * Math.floor(_loc2_ / 5);
               panel.addChild(_loc3_.sprite);
               categoryArray.push(_loc3_);
            }
            _loc2_++;
         }
      }
      
      override public function destroy() : void
      {
         var _loc1_:IPetItemCategory = null;
         super.destroy();
         ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,onList);
         for each(_loc1_ in categoryArray)
         {
            _loc1_.destroy();
         }
         categoryArray = [];
      }
      
      private function onList(param1:Event) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:Array = null;
         idArray = [];
         for each(_loc2_ in ItemManager.getCollectionIDs())
         {
            if(_loc2_.toString().substr(0,1) == "3" && _loc2_ < 300024)
            {
               if(!(Boolean(ItemXMLInfo.getIsSuper(_loc2_)) && !MainManager.actorInfo.vip))
               {
                  if(SPChannelController.mapID == 52 || SPChannelController.mapID == 316)
                  {
                     if(_itemA.indexOf(_loc2_) == -1)
                     {
                        idArray.push(_loc2_);
                     }
                  }
                  else if(_loc2_ != 300009)
                  {
                     idArray.push(_loc2_);
                  }
               }
            }
         }
         removeOldItem();
         _loc3_ = idArray.slice(0,MAX + 1);
         showPetItem(_loc3_);
         if(idArray.length > MAX)
         {
            showScroll();
         }
         else if(_scrollMc)
         {
            _scrollMc.totalLength = 0;
         }
      }
   }
}

