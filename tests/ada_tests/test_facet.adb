package body Test_Facet is

   function Suite (Test_Cases : Cases) return Access_Test_Suite is
      Result : constant Access_Test_Suite := New_Suite;
   begin
      for Test of Test_Cases loop
         Result.Add_Test (Test);
      end loop;

      return Result;
   end Suite;

end Test_Facet;
