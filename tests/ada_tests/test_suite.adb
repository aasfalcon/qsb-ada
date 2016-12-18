with Sound_Test;

package body Test_Suite is

   function Suite return Access_Test_Suite is
      Result : constant Access_Test_Suite := New_Suite;
   begin
      Result.Add_Test (Sound_Test.Suite);
      return Result;
   end Suite;

end Test_Suite;
