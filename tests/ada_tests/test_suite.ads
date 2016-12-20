with AUnit.Test_Suites;

package Test_Suite is

   subtype Handle is AUnit.Test_Suites.Access_Test_Suite;
   function Suite return Handle;

end Test_Suite;
