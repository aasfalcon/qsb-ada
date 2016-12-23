with Sound.Constants;

package body Common.Random is

   use Sound, Sound.Constants;

   function Make_Int (This : Instance)
      return Integer is (Int_Random.Random (This.Int_Gen));

   function Make_Bool (This : Instance)
      return Boolean is (Bool_Random.Random (This.Bool_Gen));

   function Make_Real (This : Instance)
      return Float is (Real_Random.Random (This.Real_Gen));

   function Make_Bound (This : Instance; Min, Max : Natural) return Natural is
      Ratio : constant Float := Bound_Random.Random (This.Bound_Gen);
   begin
      return Min + Natural (Ratio * Float (Max - Min));
   end Make_Bound;

   function Make_Value (This : Instance) return Value is
   begin
      return Result : Value do
         case Type_Random.Random (This.Type_Gen) is
            when Bool =>
               Result := (Bool, This.Make_Bool);
            when Int =>
               Result := (Int, This.Make_Int);
            when Real =>
               Result := (Real, This.Make_Real);
            when None =>
               Result := Empty_Value;
         end case;
      end return;
   end Make_Value;

   function Make_Data (This : Instance) return Data is
      The_Type : constant Value_Type := Type_Random.Random (This.Type_Gen);
      Count : constant Natural := This.Make_Bound (1, Packet_Max_Count);
      Bool_Elements : Data_Bools (1 .. Count);
      Int_Elements : Data_Ints (1 .. Count);
      Real_Elements : Data_Reals (1 .. Count);
   begin
      return Result : Data do
         case The_Type is
            when Bool =>
               for I in 1 .. Count loop
                  Bool_Elements (I) := This.Make_Bool;
               end loop;
               Result := (Bool, Count, Bool_Elements);

            when Int =>
               for I in 1 .. Count loop
                  Int_Elements (I) := This.Make_Int;
               end loop;
               Result := (Int, Count, Int_Elements);

            when Real =>
               for I in 1 .. Count loop
                  Real_Elements (I) := This.Make_Real;
               end loop;
               Result := (Real, Count, Real_Elements);

            when None =>
               Result := Empty_Data;
         end case;
      end return;
   end Make_Data;

   function Make_Event (This : Instance; Id : Client_Id)
      return Event is (Id, Client_Slot (This.Make_Bound (0, 10_000)),
                     This.Make_Value);

   function Make_Packet (This : Instance; Id : Client_Id)
      return Packet_Event is (Id, Client_Slot (This.Make_Bound (0, 10_000)),
                              This.Make_Data);

   procedure Initialize (This : in out Instance) is
   begin
      Type_Random.Reset (This.Type_Gen);
      Bool_Random.Reset (This.Bool_Gen);
      Int_Random.Reset (This.Int_Gen);
      Real_Random.Reset (This.Real_Gen);
      Bound_Random.Reset (This.Bound_Gen);
      This.Is_Generators_Initialised := True;
   end Initialize;

end Common.Random;
