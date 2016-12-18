with AUnit.Test_Fixtures; use AUnit.Test_Fixtures;
with AUnit.Test_Suites; use AUnit.Test_Suites;

with Test_Facet;

with Sound.Ring_Facet;

package Sound_Ring_Facet_Test is

   type Test_Item is new Integer;
   package Test_Ring is new Sound.Ring_Facet (Test_Item);

   Ring_Size_Default : constant Positive := 33;

   type Fixture is new Test_Fixture with record
      Ring : Test_Ring.Handle := null;
      Size : Positive := Ring_Size_Default;
      Item : Test_Item := 0;
   end record;

   procedure Set_Up (This : in out Fixture);
   procedure Tear_Down (This : in out Fixture);

   procedure Create_Test (This : in out Fixture);
   procedure Get_Count_Test (This : in out Fixture);
   procedure Get_Loaded_Test (This : in out Fixture);
   procedure Get_Space_Test (This : in out Fixture);
   procedure Is_Empty_Test (This : in out Fixture);
   procedure Is_Full_Test (This : in out Fixture);
   procedure Is_Half_Full_Test (This : in out Fixture);

   procedure Clear_Test (This : in out Fixture);
   procedure Drop_Test (This : in out Fixture);
   procedure Pop_Test (This : in out Fixture);
   procedure Push_Test (This : in out Fixture);

   procedure Crash_Test (This : in out Fixture);
   procedure Size_Test (This : in out Fixture);

   package Test is new Test_Facet (Fixture, "Sound.Ring_Facet");
   Cases : Test.Cases :=
      (
         Test.Create ("Create_Test", Create_Test'Access),
         Test.Create ("Get_Count_Test", Get_Count_Test'Access),
         Test.Create ("Get_Loaded_Test", Get_Loaded_Test'Access),
         Test.Create ("Get_Space_Test", Get_Space_Test'Access),
         Test.Create ("Is_Empty_Test", Is_Empty_Test'Access),
         Test.Create ("Is_Full_Test", Is_Full_Test'Access),
         Test.Create ("Is_Half_Full_Test", Is_Half_Full_Test'Access),

         Test.Create ("Clear_Test", Clear_Test'Access),
         Test.Create ("Drop_Test", Drop_Test'Access),
         Test.Create ("Pop_Test", Pop_Test'Access),
         Test.Create ("Push_Test", Push_Test'Access),

         Test.Create ("Crash_Test", Crash_Test'Access),
         Test.Create ("Size_Test", Size_Test'Access)
      );
   Suite : Access_Test_Suite := Test.Suite (Cases);

end Sound_Ring_Facet_Test;
