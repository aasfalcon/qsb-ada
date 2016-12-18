with Sound.Constants;

package body Sound_Bus_Test_Fixture is

   -----------------------
   -- Fixture_Processor --
   -----------------------

   overriding
   procedure Perform (This : in out Fixture_Processor; Command : Slot;
                      Argument : Value := Empty_Value) is
      E : constant Event := (This.Get_Id, Command, Argument);
   begin
      Processor.Instance (This).Perform (Command, Argument);
      This.Received_Commands.Append (E);
   end Perform;

   overriding
   procedure Initialize (This : in out Fixture_Processor) is
   begin
      Processor.Instance (This).Initialize;
      This.Received_Commands.Clear;
   end Initialize;

   -------------
   -- Fixture --
   -------------

   procedure Set_Up (This : in out Instance) is
   begin
      This.Bus.Initialize;
      This.Processor.Initialize;
      This.Random.Initialize;

      This.Bus.Add_Runner (This.Processor'Unchecked_Access);
      This.Bus.Set_Watcher (This.Processor.Get_Id, This'Unchecked_Access);
      This.Bus.Set_Analyzer (This.Processor.Get_Id, This'Unchecked_Access);

      This.Received_Signals.Clear;
      This.Received_Data.Clear;

      This.Reference.Commands.Clear;
      This.Reference.Signals.Clear;
      This.Reference.Data.Clear;
   end Set_Up;

   --  Does not clear, nor checks if empty
   procedure Random_Fill (This : in out Instance;
                          Scope : Fill_Scope := Fill_All) is
      E : Event;
      D : Data_Event;
   begin
      case Scope is
         when Fill_Commands =>
            for I in 1 .. This.Random.Make_Bound
                             (1, Constants.Commands_Bus_Size)
            loop
               E := This.Random.Make_Event (This.Processor.Get_Id);
               This.Reference.Commands.Append (E);
               This.Bus.Send (E.Tag, E.Slot, E.Argument);
            end loop;

         when Fill_Signals =>
            for I in 1 .. This.Random.Make_Bound
                             (1, Constants.Signals_Bus_Size)
            loop
               E := This.Random.Make_Event (This.Processor.Get_Id);
               This.Reference.Signals.Append (E);
               This.Bus.Emit (E.Tag, E.Slot, E.Argument);
            end loop;

         when Fill_Data =>
            for I in 1 .. This.Random.Make_Bound (1, Constants.Data_Bus_Size)
            loop
               D := This.Random.Make_Data_Event (This.Processor.Get_Id);
               This.Reference.Data.Append (D);
               This.Bus.Show (D.Tag, D.Slot, D.Argument);
            end loop;

         when Fill_All =>
            This.Random_Fill (Fill_Commands);
            This.Random_Fill (Fill_Signals);
            This.Random_Fill (Fill_Data);
      end case;
   end Random_Fill;

   procedure Watch_Event (This : in out Instance; E : Event) is
   begin
      This.Received_Signals.Append (E);
   end Watch_Event;

   procedure Analyze_Data (This : in out Instance; E : Data_Event) is
   begin
      This.Received_Data.Append (E);
   end Analyze_Data;

end Sound_Bus_Test_Fixture;
