with Sound_Buffer_Test;
with Sound_Bus_Test;
with Sound_Processor_Test;
with Sound_Ring_Facet_Test;

package body Sound_Test is

   function Suite return Access_Test_Suite is
   begin
      return Result : constant Access_Test_Suite := New_Suite do
         Result.Add_Test (Sound_Buffer_Test.Suite);
         Result.Add_Test (Sound_Bus_Test.Suite);
         Result.Add_Test (Sound_Processor_Test.Suite);
         Result.Add_Test (Sound_Ring_Facet_Test.Suite);
      end return;
   end Suite;

end Sound_Test;
