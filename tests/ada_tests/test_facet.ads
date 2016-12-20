with AUnit.Test_Caller;
with AUnit.Test_Fixtures; use AUnit.Test_Fixtures;
with AUnit.Test_Suites; use AUnit.Test_Suites;

generic
   type Fixture is new Test_Fixture with private;
   Test_Name : String;

package Test_Facet is

   subtype Handle is Access_Test_Suite;
   package Caller is new AUnit.Test_Caller (Fixture);
   type Cases is array (Positive range <>) of Caller.Test_Case_Access;

   function Create (Name : String; Method : Caller.Test_Method)
      return Caller.Test_Case_Access is
                (Caller.Create (Test_Name & " -> " & Name, Method));
   function Suite (Test_Cases : Cases) return Access_Test_Suite;

end Test_Facet;
