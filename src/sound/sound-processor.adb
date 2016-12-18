with Sound.Bus;

package body Sound.Processor is

   Id_Pool : Tag := 0;

   procedure Initialize (This : in out Instance) is
   begin
      Parent (This).Initialize;
      Id_Pool := Id_Pool + 1;
      This.Id := Id_Pool;
      This.Bus := null;
      This.Super := null;
      This.Subs.Clear;
      This.Set_Subs_Rules (Serial, Before);
   end Initialize;

   function Get_Bus (This : Instance)
      return Bus.Handle is (This.Bus);

   procedure Set_Bus (This : in out Instance; Value : Bus.Handle) is
   begin
      This.Bus := Value;
   end Set_Bus;

   function Get_Id (This : Instance)
      return Tag is  (This.Id);

   function Get_Index (This : Instance) return Positive is
   begin
      if This.Super = null then
         raise Constraint_Error with "Trying to get index of orphan item";
      end if;

      return This.Index;
   end Get_Index;

   procedure Set_Index (This : in out Instance; Value : Natural) is
   begin
      This.Super.Subs.Swap (This.Index, Value);
      This.Index := Value;
   end Set_Index;

   function Get_Sub (This : Instance; Index : Positive)
      return Handle is (This.Subs.Element (Index));

   function Get_Sub_Count (This : Instance)
      return Natural is (Natural (This.Subs.Length));

   function Get_Super (This : Instance)
      return Handle is (This.Super);

   procedure Set_Super (This : in out Instance; Value : Handle) is
   begin
      if This.Super /= null then
         This.Super.Subs.Delete (This.Index);
      end if;

      Value.Subs.Append (This'Unchecked_Access);
      This.Bus := Value.Bus;
      This.Super := Value;
   end Set_Super;

   procedure Set_Subs_Rules (This : in out Instance;
                             Mode : Subs_Mode; Order : Subs_Order) is
   begin
      This.Mode := Mode;
      This.Order := Order;
   end Set_Subs_Rules;

   procedure Emit (This : Instance; Signal : Slot;
                   Argument : Value := Empty_Value) is
   begin
      This.Bus.Emit (This.Id, Signal, Argument);
   end Emit;

   procedure Show (This : Instance; Data : Slot; Argument : Data_Value) is
   begin
      This.Bus.Show (This.Id, Data, Argument);
   end Show;

   procedure Insert (This : in out Instance; Sub : Handle;
                     Index : Integer := -1) is
   begin
      Sub.Set_Super (This'Unchecked_Access);
      Sub.Set_Index (Index);
   end Insert;

   procedure Process_Entry (This : Instance; Buf : in out Buffer.Instance) is
      use Subs_Vectors;
      C : Cursor;
      Count : constant Natural := Natural (This.Subs.Length);
      Sub : Handle;
   begin
      if This.Order = Before then
         This.Process (Buf);
      end if;

      if not This.Subs.Is_Empty then
         if This.Mode = Serial or else Count = 1 then
            C := This.Subs.First;

            while C /= No_Element loop
               Sub := Element (C);
               Sub.Process_Entry (Buf);
               Next (C);
            end loop;

         else --  process in parallel, then mix
            declare
               Sub_Buf : Buffer.Instance := Buf;
               Mix_Buf : Buffer.Instance (Buf.Frames, Buf.Channels);
            begin
               C := This.Subs.First;

               --  proces first outside loop to skip zero fill
               Sub := Element (C);
               Sub.Process_Entry (Sub_Buf);
               Mix_Buf := Sub_Buf;

               loop
                  Next (C);
                  exit when C = No_Element;

                  Sub_Buf := Buf;
                  Sub := Element (C);
                  Sub.Process_Entry (Sub_Buf);
                  Mix_Buf.Add (Sub_Buf);
               end loop;

               Mix_Buf.Divide (Count);
               Buf := Mix_Buf;
            end;
         end if;
      end if;

      if This.Order = After then
         This.Process (Buf);
      end if;
   end Process_Entry;

end Sound.Processor;
