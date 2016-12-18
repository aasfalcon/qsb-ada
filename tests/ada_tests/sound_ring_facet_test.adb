with Ada.Unchecked_Deallocation, Ada.Numerics.Discrete_Random;
with AUnit.Assertions; use AUnit.Assertions;

package body Sound_Ring_Facet_Test is

   function Random_Size (This : in out Fixture) return Positive;
   procedure Size_Test_Pefrorm (This : in out Fixture; Size : Positive);

   procedure Set_Up (This : in out Fixture) is
   begin
      This.Ring := new Test_Ring.Instance (This.Size + 1);
      This.Ring.Initialize;
   end Set_Up;

   procedure Tear_Down (This : in out Fixture) is
      procedure Delete_Ring is
         new Ada.Unchecked_Deallocation (Test_Ring.Class, Test_Ring.Handle);
   begin
      Delete_Ring (This.Ring);
      This.Ring := null;
   end Tear_Down;

   procedure Create_Test (This : in out Fixture) is
   begin
      Assert (This.Ring.Get_Count = This.Size, "Wrong size of ring");
      Assert (This.Ring.Get_Loaded = 0, "Wrong loaded count");
      Assert (This.Ring.Get_Space = This.Ring.Get_Count, "Wrong space count");
      Assert (This.Ring.Is_Empty, "Not empty on create");
      Assert (not This.Ring.Is_Full, "Is full on create");
      Assert (not This.Ring.Is_Half_Full, "Is half full on create");
   end Create_Test;

   procedure Get_Count_Test (This : in out Fixture) is
   begin
      Assert (This.Ring.Get_Count = This.Size, "Wrong ring count");
   end Get_Count_Test;

   procedure Get_Loaded_Test (This : in out Fixture) is
   begin
      for I in 1 .. This.Size loop
         This.Ring.Push (This.Item);
         Assert (This.Ring.Get_Loaded = I, "Wrong loaded count on push");
      end loop;

      for I in reverse 1 .. This.Size loop
         This.Ring.Pop (This.Item);
         Assert (This.Ring.Get_Loaded = I - 1, "Wrong loaded count on pop");
      end loop;
   end Get_Loaded_Test;

   procedure Get_Space_Test (This : in out Fixture) is
   begin
      for I in 1 .. This.Size loop
         This.Ring.Push (This.Item);
         Assert (This.Ring.Get_Space = This.Size - I,
                 "Wrong space count on push");
      end loop;

      for I in 1 .. This.Size loop
         This.Ring.Pop (This.Item);
         Assert (This.Ring.Get_Space = I, "Wrong space count on pop");
      end loop;
   end Get_Space_Test;

   procedure Is_Empty_Test (This : in out Fixture) is
   begin
      Assert (This.Ring.Is_Empty, "Not empty when created");

      for I in 1 .. This.Size loop
         This.Ring.Push (This.Item);
         Assert (not This.Ring.Is_Empty, "Not empty after push");
      end loop;

      for I in 1 .. This.Size loop
         This.Ring.Pop (This.Item);
         Assert (not This.Ring.Is_Empty or else I = This.Size,
                 "Wrong empty after pop");
      end loop;
   end Is_Empty_Test;

   procedure Is_Full_Test (This : in out Fixture) is
   begin
      Assert (This.Ring.Is_Empty, "Is full when created");

      for I in 1 .. This.Size loop
         This.Ring.Push (This.Item);
         Assert (not This.Ring.Is_Full or else I = This.Size,
                 "Wrong full after push");
      end loop;

      for I in 1 .. This.Size loop
         This.Ring.Pop (This.Item);
         Assert (not This.Ring.Is_Full, "Still full after pop");
      end loop;
   end Is_Full_Test;

   procedure Is_Half_Full_Test (This : in out Fixture) is
      Test_Half : constant Positive :=
         (if This.Size / 2 = 0 then 1 else This.Size / 2);
   begin
      Assert (This.Ring.Is_Empty, "Is half full when created");

      for I in 1 .. This.Size loop
         This.Ring.Push (This.Item);
         Assert (not This.Ring.Is_Half_Full or else I >= Test_Half,
                 "Wrong half full value after push");
      end loop;

      for I in reverse 1 .. This.Size loop
         This.Ring.Pop (This.Item);
         Assert (This.Ring.Is_Half_Full or else I <= Test_Half,
                 "Wrong half full value after pop");
      end loop;
   end Is_Half_Full_Test;

   procedure Clear_Test (This : in out Fixture) is
   begin
      for I in 1 .. This.Random_Size loop
         This.Ring.Push (This.Item);
      end loop;

      This.Ring.Clear;

      This.Create_Test;
   end Clear_Test;

   procedure Drop_Test (This : in out Fixture) is
      Count : constant Positive := This.Random_Size;
   begin
      for I in 1 .. Count loop
         This.Ring.Push (This.Item);
      end loop;

      This.Ring.Drop;

      Assert (This.Ring.Get_Loaded = Count - 1, "Wrong count after drop");
   end Drop_Test;

   procedure Pop_Test (This : in out Fixture) is
   begin
      for I in 1 .. This.Size loop
         This.Item := Test_Item (I);
         This.Ring.Push (This.Item);
      end loop;

      for I in 1 .. This.Size loop
         This.Ring.Pop (This.Item);
         Assert (This.Item = Test_Item (I), "Values don't match");
      end loop;
   end Pop_Test;

   procedure Push_Test (This : in out Fixture) is
      Push_Value : constant Test_Item := 11122233;
      Clear_Value : constant Test_Item := 0;
   begin
      This.Item := Push_Value;
      This.Ring.Push (This.Item);
      This.Item := Clear_Value;
      This.Ring.Pop (This.Item);
      Assert (This.Item = Push_Value, "Values don't match");
   end Push_Test;

   procedure Crash_Test (This : in out Fixture) is
   begin
      --  underflow error
      begin
         This.Ring.Pop (This.Item);
         Assert (False, "Underflow error not raised");
      exception
         when Test_Ring.Underflow_Error => null;
      end;

      --  overflow error
      for I in 1 .. This.Size loop
         This.Ring.Push (This.Item);
      end loop;

      begin
         This.Ring.Push (This.Item);
         Assert (False, "Overflow error not raised");
      exception
         when Test_Ring.Overflow_Error => null;
      end;
   end Crash_Test;

   procedure Size_Test (This : in out Fixture) is
      Max_Random_Size : constant Positive := 1_000;
      Size_Save : constant Positive := This.Size;
   begin
      for I in 1 .. 5 loop --  each low size
         This.Size_Test_Pefrorm (I);
      end loop;

      for I in 1 .. 5 loop --  random big sizes
         This.Size := Max_Random_Size;
         This.Size_Test_Pefrorm (This.Random_Size);
      end loop;

      This.Size := Size_Save;
   end Size_Test;

   --  Hidden private methods

   function Random_Size (This : in out Fixture) return Positive is
      Min : constant Positive := 1;
      Max : constant Positive := This.Size;

      subtype Result_Range is Positive range Min .. Max;
      package R is new Ada.Numerics.Discrete_Random (Result_Range);

      Generator : R.Generator;
   begin
      R.Reset (Generator);
      return R.Random (Generator);
   end Random_Size;

   procedure Size_Test_Pefrorm (This : in out Fixture; Size : Positive) is
   begin
      This.Tear_Down;
      This.Size := Size;
      This.Set_Up;

      This.Get_Count_Test;
      This.Get_Loaded_Test;
      This.Get_Space_Test;
      This.Is_Empty_Test;
      This.Is_Full_Test;
      This.Is_Half_Full_Test;
      This.Crash_Test;
   end Size_Test_Pefrorm;

end Sound_Ring_Facet_Test;
