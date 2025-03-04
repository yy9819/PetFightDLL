package com.robot.petFightModule.loadUI
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.utils.Direction;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.setTimeout;
   import org.taomee.manager.ResourceManager;
   
   public class PetWarLoadingUI extends Sprite
   {
      private var _petIdA:Array;
      
      private var _petMcA:Array = new Array();
      
      private var _iconMc:Sprite;
      
      private const point:Point = new Point(-154.4,-53.1);
      
      private var _curIndex:uint = 0;
      
      private var _pointA:Array = [new Point(140,200),new Point(140,355),new Point(140,490),new Point(780,200),new Point(780,355),new Point(780,490)];
      
      private var loadMc:PetWarLoadingMc;
      
      public function PetWarLoadingUI(param1:Array)
      {
         super();
         _petIdA = param1;
         _curIndex = 0;
         loadMc = new PetWarLoadingMc();
         loadMc["mc1"].gotoAndStop(1);
         loadMc["mc2"].gotoAndStop(1);
         loadMc["mc3"].gotoAndStop(1);
         this.addChild(loadMc);
         loadMc.x = point.x;
         loadMc.y = point.y;
      }
      
      public function startLoad() : void
      {
         _curIndex = 0;
         loadPet(_petIdA[_curIndex]);
      }
      
      private function onSucHandler(param1:DisplayObject) : void
      {
         _petMcA.push(param1);
         ++_curIndex;
         if(_curIndex < _petIdA.length)
         {
            loadPet(_petIdA[_curIndex]);
         }
         else
         {
            onPlayHandler();
         }
      }
      
      private function closeHandler() : void
      {
         _iconMc.visible = true;
         this.dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function loadPet(param1:uint) : void
      {
         ResourceManager.getResource(ClientConfig.getPetSwfPath(param1),onSucHandler,"pet");
      }
      
      private function onPlayHandler() : void
      {
         var i1:int;
         var mc:MovieClip = null;
         _iconMc = new Sprite();
         this.addChild(_iconMc);
         loadMc["mc1"].gotoAndPlay(2);
         loadMc["mc2"].gotoAndPlay(2);
         loadMc["mc3"].gotoAndPlay(2);
         i1 = 0;
         while(i1 < _petIdA.length)
         {
            mc = _petMcA[i1] as MovieClip;
            if(i1 < 3)
            {
               mc.gotoAndStop(Direction.RIGHT_DOWN);
            }
            else
            {
               mc.gotoAndStop(Direction.LEFT_DOWN);
            }
            _iconMc.addChild(mc);
            mc.x = (_pointA[i1] as Point).x;
            mc.y = (_pointA[i1] as Point).y;
            mc.scaleX = mc.scaleY = 3;
            i1++;
         }
         _iconMc.visible = false;
         setTimeout(function():void
         {
            closeHandler();
         },6500);
      }
   }
}

