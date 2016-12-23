package body Sound.Processor is

   Id_Pool : Client_Id := Empty_Id;

   overriding
   procedure Initialize (This : in out Instance) is
   begin
      Parent (This).Initialize;
      Id_Pool := Id_Pool + 1;
      This.Id := Id_Pool;
   end Initialize;

   overriding
   procedure Finalize (This : in out Instance) is
   begin
      This.Disconnect;
   end Finalize;

   overriding
   function Get_Id (This : Instance) return Client_Id is (This.Id);

   function Get (This : Instance; Parameter : Parameter_Slot) return Value is
   begin
      case Parameters.Enum (Parameter) is
         when Id =>
            return (Int, Integer (This.Id));

         when Index =>
            return (Int, This.Index);

         when Is_Muted =>
            return (Bool, This.Is_Muted);

         when Is_Bypassed =>
            return (Bool, This.Is_Bypassed);

         when Is_Parallel =>
            return (Bool, This.Is_Parallel);

         when Super_Id =>
            begin
               return (Int, Integer (This.Super.Get_Id));
            exception
               when Constraint_Error =>
                  return (Int, Integer (Empty_Id));
            end;
      end case;
--    exception
--       when Constraint_Error =>
--          return Parent (This).Get (Parameter);
   end Get;

   overriding
   procedure Set (This : in out Instance; Parameter : Parameter_Slot;
                  Argument : Value) is
   begin
      case Parameters.Enum (Parameter) is
         when Id =>
            raise Program_Error with "Parameter 'Id' is read-only";

         when Index =>
            if This.Super /= null then
               This.Super.Subs.Delete (This.Index);
               This.Index := Argument.Int;
               This.Super.Subs.Insert (This.Index, This'Unchecked_Access);
            end if;

         when Is_Muted =>
            This.Is_Muted := Argument.Bool;

         when Is_Bypassed =>
            This.Is_Bypassed := Argument.Bool;

         when Is_Parallel =>
            This.Is_Parallel := Argument.Bool;

         when Super_Id =>
            declare
               Super : constant Processor.Handle :=
                  Processor.Handle (This.Bus.Get_Client
                                    (Client_Id (Argument.Int)));
               Above : Processor.Handle := Super;
            begin
               while Above /= null loop
                  if Above = This'Unchecked_Access then
                     raise Program_Error with "Can't set one of subs as super";
                  end if;

                  Above := Above.Super;
               end loop;

               if This.Super /= null then
                  This.Super.Subs.Delete (This.Index);
               end if;

               This.Super := Super;

               if This.Super /= null then
                  This.Super.Subs.Append (This'Unchecked_Access);
                  This.Index := This.Super.Subs.Last_Index;
               else
                  This.Index := 0;
               end if;
            end;
      end case;
--    exception --  dispatch to parent
--       when Constraint_Error =>
--          Parent (This).Set (Parameter, Argument);
   end Set;

   overriding
   procedure Run (This : in out Instance; Command : Command_Slot;
                  Argument : Value := Empty_Value) is
   begin
      case Commands.Enum (Command) is
         when Expose =>
            for P in Parameter loop
               declare
                  Slot : constant Parameter_Slot := Parameters.Slot (P);
               begin
                  This.Emit (Slot, This.Get (Slot));
               end;
            end loop;

         when Expose_One =>
            declare
               Slot : constant Parameter_Slot := Parameter_Slot (Argument.Int);
            begin
               This.Emit (Slot, This.Get (Slot));
            end;

         when Destroy =>
            null; --  TODO: destroy all

         when Show_Subs =>
            null; -- TODO: show subs ids in Emit_Data
      end case;
--    exception --  dispatch to parent
--       when Constraint_Error =>
--          Parent (This).Run (Command, Arg);
   end Run;

   procedure Connect (This : in out Instance; Bus : Sound.Bus.Handle) is
      use Sound.Bus;
   begin
      if This.Bus /= Bus then
         This.Disconnect;
         This.Bus := Bus;
         This.Bus.Add_Client (This'Unchecked_Access);
         This.Emit (Signals.Slot (Connect));
      end if;
   end Connect;

   procedure Disconnect (This : in out Instance) is
      use Sound.Bus;
   begin
      if This.Bus /= null then
         This.Emit (Signals.Slot (Disconnect));
         This.Bus.Remove_Client (This'Unchecked_Access);
         This.Bus := null;
      end if;
   end Disconnect;

   procedure Emit (This : Instance; Parameter : Parameter_Slot;
                   Argument : Value := Empty_Value) is
   begin
      This.Bus.Emit (This.Id, Parameter, Argument);
   end Emit;

   procedure Emit (This : Instance; Signal : Signal_Slot;
                   Argument : Value := Empty_Value) is
   begin
      This.Bus.Emit (This.Id, Signal, Argument);
   end Emit;

   procedure Emit (This : Instance; Packet : Packet_Slot;
                   Argument : Data := Empty_Data) is
   begin
      This.Bus.Emit (This.Id, Packet, Argument);
   end Emit;

   procedure Process_Entry (This : Instance; Buf : in out Buffer.Instance) is
      use Subs_Vectors;
      C : Cursor;
      Count : constant Natural := Natural (This.Subs.Length);
   begin
      --  simple cases
      if This.Is_Bypassed then
         return;
      end if;

      if This.Is_Muted then
         Buf.Silence;
         return;
      end if;

      if This.Subs.Is_Empty then
         Class (This).Process (Buf);
         return;
      end if;

      --  full case
      if not This.Is_Parallel or else Count = 1 then
         C := This.Subs.First;

         while C /= No_Element loop
            Element (C).Process_Entry (Buf);
            Next (C);
         end loop;

      else --  process in parallel, then mix
         declare
            Sub_Buf : Buffer.Instance := Buf;
            Mix_Buf : Buffer.Instance (Buf.Frames, Buf.Channels);
         begin
            --  proces first outside loop to skip zero fill
            C := This.Subs.First;
            Element (C).Process_Entry (Sub_Buf);
            Mix_Buf := Sub_Buf;

            loop
               Next (C);
               exit when C = No_Element;

               Sub_Buf := Buf;
               Element (C).Process_Entry (Sub_Buf);
               Mix_Buf.Add (Sub_Buf);
            end loop;

            Mix_Buf.Divide (Count);
            Buf := Mix_Buf;
         end;
      end if;

      Class (This).Process (Buf);
   end Process_Entry;

end Sound.Processor;
