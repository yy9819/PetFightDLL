package com.robot.petFightModule.data
{
   import com.robot.core.info.fightInfo.ChangePetInfo;
   
   public class NpcChangePetData
   {
      private static var array:Array = [];
      
      public function NpcChangePetData()
      {
         super();
      }
      
      public static function add(param1:ChangePetInfo) : void
      {
         array.push(param1);
      }
      
      public static function first() : ChangePetInfo
      {
         return array.shift() as ChangePetInfo;
      }
   }
}

