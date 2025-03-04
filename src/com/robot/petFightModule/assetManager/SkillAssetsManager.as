package com.robot.petFightModule.assetManager
{
   import flash.display.MovieClip;
   
   public class SkillAssetsManager
   {
      private static var instance:SkillAssetsManager;
      
      private var assetsObj:Object;
      
      public function SkillAssetsManager()
      {
         super();
      }
      
      public static function getInstance() : SkillAssetsManager
      {
         if(!instance)
         {
            instance = new SkillAssetsManager();
         }
         return instance;
      }
      
      public function getAssetsByID(param1:int) : MovieClip
      {
         return assetsObj["asset_" + param1];
      }
      
      public function deleteAsset(param1:int) : void
      {
         delete assetsObj["asset_" + param1];
      }
      
      public function clearAll() : void
      {
         assetsObj = {};
      }
      
      public function addAsset(param1:int, param2:MovieClip) : void
      {
         if(!assetsObj)
         {
            assetsObj = {};
         }
         assetsObj["asset_" + param1] = param2;
      }
   }
}

