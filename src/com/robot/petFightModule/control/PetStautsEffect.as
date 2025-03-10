package com.robot.petFightModule.control
{
   import com.robot.petFightModule.PetFightEntry;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import org.taomee.ds.HashMap;
   
   public class PetStautsEffect
   {
      private static var hashMap:HashMap = new HashMap();
      
      setup();
      
      public function PetStautsEffect()
      {
         super();
      }
      
      public static function addEffect(param1:uint, param2:uint) : void
      {
         var _loc3_:BaseFighterMode = null;
         var _loc4_:Class = null;
         if(hashMap.getValue(param2))
         {
            _loc3_ = PetFightEntry.fighterCon.getFighterMode(param1);
            _loc4_ = hashMap.getValue(param2) as Class;
            _loc3_.propView.addEffect(_loc4_,param2);
         }
      }
      
      private static function setup() : void
      {
         hashMap.add(0,Effect_Narcosis_Icon);
         hashMap.add(1,Effect_Poisoning_Icon);
         hashMap.add(2,Effect_Fire_Icon);
         hashMap.add(3,null);
         hashMap.add(4,null);
         hashMap.add(5,Effect_Freeze_Icon);
         hashMap.add(6,Effect_Afraid_Icon);
         hashMap.add(7,Effect_Tired_Icon);
         hashMap.add(8,Effect_Sleep_Icon);
         hashMap.add(9,null);
      }
   }
}

