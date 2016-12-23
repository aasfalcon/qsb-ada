with Sound.Constants;

package body Fixture.Sound_Bus_Test is

   use Sound.Processor, Sound.Constants;

   -----------------------
   -- Fixture_Processor --
   -----------------------

   overriding
   procedure Set (This : in out Fixture_Processor; Parameter : Parameter_Slot;
                  Argument : Value) is
      E : constant Event := (This.Get_Id, Client_Slot (Parameter), Argument);
   begin
      Processor.Instance (This).Set (Parameter, Argument);
      This.Received_Parameters.Append (E);
   end Set;

   overriding
   procedure Run (This : in out Fixture_Processor; Command : Command_Slot;
                  Argument : Value := Empty_Value) is
      E : constant Event := (This.Get_Id, Client_Slot (Command), Argument);
   begin
      Processor.Instance (This).Run (Command, Argument);
      This.Received_Commands.Append (E);
   end Run;

   overriding
   procedure Process (This : Fixture_Processor;
                      Buf : in out Sound.Buffer.Instance) is null;

   -------------
   -- Fixture --
   -------------

   procedure Set_Up (This : in out Instance) is
   begin
      This.Random.Initialize;

      This.Processor := new Fixture_Processor;
      This.Bus := new Sound.Bus.Instance;
      This.Processor.Connect (This.Bus);
      This.Bus.Watch; --  skip Connect signal

      This.Bus.Add_Supervisor (This'Unchecked_Access);

      This.Received_Parameters.Clear;
      This.Received_Signals.Clear;
      This.Received_Packets.Clear;

      This.Reference.Input.Clear;
      This.Reference.Output.Clear;
      This.Reference.Commands.Clear;
      This.Reference.Signals.Clear;
      This.Reference.Packets.Clear;
   end Set_Up;

   --  Does not clear, nor checks if empty
   procedure Random_Fill (This : in out Instance;
                          Scope : Fill_Scope := Fill_All) is
      E : Event;
      P : Packet_Event;
   begin
      case Scope is
         when Fill_Input =>
            for I in 1 .. This.Random.Make_Bound
                             (1, Input_Bus_Size - 1)
            loop
               E.Id := This.Processor.Get_Id;
               E.Slot := Client_Slot (Parameters.Slot (Is_Muted));
               E.Argument := (Bool, True);
               This.Reference.Input.Append (E);
               This.Bus.Send (E.Id, Parameter_Slot (E.Slot), E.Argument);
            end loop;

         when Fill_Output =>
            for I in 1 .. This.Random.Make_Bound
                             (1, Output_Bus_Size - 1)
            loop
               E := This.Random.Make_Event (This.Processor.Get_Id);
               This.Reference.Output.Append (E);
               This.Bus.Emit (E.Id, Parameter_Slot (E.Slot), E.Argument);
            end loop;

         when Fill_Commands =>
            for I in 1 .. This.Random.Make_Bound
                             (1, Commands_Bus_Size - 1)
            loop
               E := This.Random.Make_Event (This.Processor.Get_Id);
               E.Slot := Client_Slot (Commands.Slot (Show_Subs));
               This.Reference.Commands.Append (E);
               This.Bus.Send (E.Id, Command_Slot (E.Slot), E.Argument);
            end loop;

         when Fill_Signals =>
            for I in 1 .. This.Random.Make_Bound
                             (1, Signals_Bus_Size - 1)
            loop
               E := This.Random.Make_Event (This.Processor.Get_Id);
               This.Reference.Signals.Append (E);
               This.Bus.Emit (E.Id, Signal_Slot (E.Slot), E.Argument);
            end loop;

         when Fill_Packets =>
            for I in 1 .. This.Random.Make_Bound (1, Packets_Bus_Size - 1)
            loop
               P := This.Random.Make_Packet (This.Processor.Get_Id);
               This.Reference.Packets.Append (P);
               This.Bus.Emit (P.Id, Packet_Slot (P.Slot), P.Argument);
            end loop;

         when Fill_All =>
            for S in Fill_Input .. Fill_Packets loop
               This.Random_Fill (S);
            end loop;
      end case;
   end Random_Fill;

   overriding
   procedure Watch_Parameter (This : in out Instance; E : Event) is
   begin
      This.Received_Parameters.Append (E);
   end Watch_Parameter;

   overriding
   procedure Watch_Signal (This : in out Instance; E : Event) is
   begin
      This.Received_Signals.Append (E);
   end Watch_Signal;

   overriding
   procedure Watch_Packet (This : in out Instance; P : Packet_Event) is
   begin
      This.Received_Packets.Append (P);
   end Watch_Packet;

end Fixture.Sound_Bus_Test;
