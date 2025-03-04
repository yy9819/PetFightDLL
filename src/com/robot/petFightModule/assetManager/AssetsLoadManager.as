package com.robot.petFightModule.assetManager
{
   import com.robot.core.CommandID;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.net.SocketConnection;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.TimerEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.utils.Timer;
   
   public class AssetsLoadManager extends EventDispatcher
   {
      private static const PET_PATH:String = "resource/fightResource/pet/swf/";
      
      private static const SKILL_PATH:String = "resource/fightResource/skill/swf/";
      
      private var skillLoader:Loader;
      
      private var timer:Timer;
      
      private var _percent:Number = 0;
      
      private var skillIDArray:Array = [];
      
      private var P:Number;
      
      private var petLoader:Loader;
      
      private var currentPercent:Number = 0;
      
      private var currentID:int;
      
      private var currentIndex:int = 0;
      
      private var petIDArray:Array = [];
      
      public function AssetsLoadManager()
      {
         super();
         petLoader = new Loader();
         petLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadPetAsset);
         petLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,errorLoadHandler);
         petLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,onPetProgress);
         skillLoader = new Loader();
         skillLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadSkillAsset);
         skillLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,errorLoadHandler);
         skillLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,onSkillProgress);
         timer = new Timer(2000);
         timer.addEventListener(TimerEvent.TIMER,onTimer);
      }
      
      private function loadPets() : void
      {
         var _loc1_:String = null;
         if(petIDArray.length == 0)
         {
            return;
         }
         if(currentIndex < petIDArray.length)
         {
            currentID = petIDArray[currentIndex];
            _loc1_ = formatID(currentID);
            trace("AssetsLoading...pet",_loc1_);
            petLoader.load(new URLRequest(PET_PATH + _loc1_ + ".swf"));
         }
         else
         {
            currentIndex = 0;
            loadSkills();
         }
      }
      
      public function loadAssets() : void
      {
         var _loc1_:int = int(petIDArray.indexOf(PetFightModel.defaultNpcID));
         if(_loc1_ == -1 && PetFightModel.defaultNpcID != 0)
         {
            petIDArray.push(PetFightModel.defaultNpcID);
         }
         else
         {
            timer.start();
         }
         P = 1 / (petIDArray.length + skillIDArray.length);
         loadPets();
      }
      
      public function addSkillID(... rest) : void
      {
         var _loc2_:int = 0;
         for each(_loc2_ in rest)
         {
            skillIDArray.push(_loc2_);
         }
      }
      
      private function stopAll() : void
      {
         try
         {
            petLoader.close();
         }
         catch(e:Error)
         {
         }
         try
         {
            skillLoader.close();
         }
         catch(e:Error)
         {
         }
      }
      
      private function loadSkills() : void
      {
         var _loc1_:String = null;
         if(skillIDArray.length == 0)
         {
            dispatchEvent(new AssetsEvent(AssetsEvent.LOAD_ALL_ASSETS));
            SocketConnection.send(CommandID.LOAD_PERCENT,100);
            return;
         }
         if(currentIndex < skillIDArray.length)
         {
            currentID = skillIDArray[currentIndex];
            _loc1_ = formatID(currentID);
            trace("AssetsLoading...skill",_loc1_);
            skillLoader.load(new URLRequest(SKILL_PATH + _loc1_ + ".swf"));
         }
         else
         {
            dispatchEvent(new AssetsEvent(AssetsEvent.LOAD_ALL_ASSETS));
            currentIndex = 0;
         }
      }
      
      private function onLoadPetAsset(param1:Event) : void
      {
         var _loc2_:ApplicationDomain = (param1.target as LoaderInfo).applicationDomain;
         PetAssetsManager.getInstance().addAsset(currentID,_loc2_);
         ++currentIndex;
         loadPets();
         currentPercent = _percent;
         trace("某赛尔精灵加载完成---------------------",currentPercent);
      }
      
      private function onSkillProgress(param1:ProgressEvent) : void
      {
         var _loc2_:Number = Math.floor(param1.bytesLoaded / param1.bytesTotal * P * 100);
         _percent = currentPercent + _loc2_;
         dispatchEvent(new AssetsEvent(AssetsEvent.PROGRESS,_percent));
      }
      
      private function errorLoadHandler(param1:IOErrorEvent) : void
      {
         throw new Error("AssetsLoading加载出错..." + currentID);
      }
      
      private function formatID(param1:uint, param2:uint = 3) : String
      {
         var _loc5_:int = 0;
         var _loc3_:String = param1.toString();
         var _loc4_:uint = uint(_loc3_.length);
         if(_loc4_ < param2)
         {
            _loc5_ = 0;
            while(_loc5_ < param2 - _loc4_)
            {
               _loc3_ = "0" + _loc3_;
               _loc5_++;
            }
         }
         return _loc3_;
      }
      
      private function onPetProgress(param1:ProgressEvent) : void
      {
         var _loc2_:Number = Math.floor(param1.bytesLoaded / param1.bytesTotal * P * 100);
         _percent = currentPercent + _loc2_;
         dispatchEvent(new AssetsEvent(AssetsEvent.PROGRESS,_percent));
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         SocketConnection.send(CommandID.LOAD_PERCENT,_percent);
      }
      
      private function onLoadSkillAsset(param1:Event) : void
      {
         trace("onLoadSkillAsset",currentID);
         var _loc2_:Class = (param1.target as LoaderInfo).applicationDomain.getDefinition("skill") as Class;
         var _loc3_:MovieClip = new _loc2_() as MovieClip;
         SkillAssetsManager.getInstance().addAsset(currentID,_loc3_);
         ++currentIndex;
         loadSkills();
         currentPercent = _percent;
         trace("某技能加载完成---------------------",currentPercent);
      }
      
      public function addPetID(... rest) : void
      {
         var _loc2_:int = 0;
         for each(_loc2_ in rest)
         {
            petIDArray.push(_loc2_);
         }
      }
      
      public function destroy() : void
      {
         timer.stop();
         timer.removeEventListener(TimerEvent.TIMER,onTimer);
         timer = null;
         stopAll();
         petLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoadPetAsset);
         petLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,errorLoadHandler);
         petLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,onPetProgress);
         skillLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoadSkillAsset);
         skillLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,errorLoadHandler);
         skillLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,onSkillProgress);
         petLoader = null;
         skillLoader = null;
      }
   }
}

