with Sound_Test;

package body Test_Suite is

   function Suite return Handle is
   begin
      return Result : constant Handle := AUnit.Test_Suites.New_Suite do
         Result.Add_Test (Sound_Test.Suite);
      end return;
   end Suite;

end Test_Suite;
