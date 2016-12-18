package body Sound.Bus.Debug is

   procedure Initialize (This : in out Instance) is
      Empty_View : constant Statistics_View :=  (Average => 0.0, others => 0);
      Now : constant Time := Clock;
   begin
      Parent (This).Initialize;
      This.Is_Collecting := False;
      This.Stats :=  (Signals => Empty_View, Commands => Empty_View,
                      Data => Empty_View, Data_Size => Empty_View,
                      Runners => Empty_View,
                      Start => Now, Finish => Now,
                      others => 0);
   end Initialize;

   procedure Update_View (This : Instance; View : in out Statistics_View;
                          Current : Natural) is
      M : constant Long_Float := Long_Float (View.Measures + 1);
   begin
      if This.Is_Collecting then
         View.Last := Current;

         if View.Peak < Current then
            View.Peak := Current;
         end if;

         View.Average := View.Average / M *  (M + 1.0) + Long_Float (Current) /
                         M;
         View.Measures := View.Measures + 1;
      end if;
   end Update_View;

   procedure Stats_Analyze (This : Instance; Stats : out Statistics;
                            Report : out String) is
   begin
      Stats := This.Stats;
      Stats.Finish := Clock;
      Stats.Signal_Underruns := This.Signal_Underruns;
      Stats.Data_Underruns := This.Data_Underruns;

      Report := "Event bus analysis report";
   end Stats_Analyze;

   procedure Stats_Collect (This : in out Instance) is
   begin
      if This.Is_Collecting then
         raise Program_Error with "Statistics already collecting";
      end if;

      This.Initialize;
      This.Is_Collecting := True;
   end Stats_Collect;

   procedure Stats_Reset (This : in out Instance) is
      Is_Collecting : constant Boolean := This.Is_Collecting;
   begin
      This.Initialize;
      This.Is_Collecting := Is_Collecting;
   end Stats_Reset;

   --  overrides with statistics hooks
   overriding
   procedure Add_Runner (This : in out Instance; Runner : Processor.Handle) is
   begin
      Super (This).Add_Runner (Runner);
      This.Update_View (This.Stats.Runners, Natural (This.Objects.Length));
   end Add_Runner;

   overriding
   procedure Dispatch (This : in out Instance) is
   begin
      if not This.Is_Collecting then
         This.Stats_Collect;
      end if;

      This.Update_View (This.Stats.Signals, This.Signals.Get_Loaded);
      Super (This).Dispatch;
   end Dispatch;

   overriding
   procedure Show (This : in out Instance; Processor_Id : Tag;
                   Data : Slot; Argument : Data_Value) is
   begin
      Super (This).Show (Processor_Id, Data, Argument);
      This.Update_View (This.Stats.Data_Size, Argument.Count);
   end Show;

   overriding
   procedure Remove_Runner (This : in out Instance; Processor_Id : Tag) is
   begin
      Super (This).Remove_Runner (Processor_Id);
      This.Update_View (This.Stats.Runners, Natural (This.Objects.Length));
   end Remove_Runner;

   overriding
   procedure Watch (This : in out Instance) is
   begin
      if not This.Is_Collecting then
         This.Stats_Collect;
      end if;

      This.Update_View (This.Stats.Commands, This.Commands.Get_Loaded);
      This.Update_View (This.Stats.Data, This.Data.Get_Loaded);
      Super (This).Watch;
   end Watch;

end Sound.Bus.Debug;
