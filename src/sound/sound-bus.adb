package body Sound.Bus is

   use Bus_Object_Maps;

   procedure Initialize (This : in out Instance) is
   begin
      Parent (This).Initialize;
      This.Objects.Clear;
      This.Commands.Initialize;
      This.Signals.Initialize;
      This.Data.Initialize;

      This.Signal_Underruns := 0;
      This.Data_Underruns := 0;
   end Initialize;

   function Has_Runner (This : Instance; Processor_Id : Tag)
      return Boolean is  (This.Objects.Find (Processor_Id) /= No_Element);

   function Get_Data_Underruns (This : Instance)
      return Natural is  (This.Data_Underruns);

   function Get_Signal_Underruns (This : Instance)
      return Natural is  (This.Signal_Underruns);

   procedure Analyze (This : in out Instance) is
      C : Cursor;
      E : Data_Event;
      Analyzer : Data_Analyzer.Handle;
      use Data_Analyzer;
   begin
      while not This.Data.Is_Empty loop
         This.Data.Pop (E);
         C := This.Objects.Find (E.Tag);

         if C /= No_Element then
            Analyzer := This.Objects.Constant_Reference (C).Analyzer;

            if Analyzer /= null then
               Analyzer.Analyze_Data (E);
            end if;
         end if;
      end loop;
   end Analyze;

   procedure Watch (This : in out Instance) is
      C : Cursor;
      E : Event;
      Watcher : Event_Watcher.Handle;
      use Event_Watcher;
   begin
      while not This.Signals.Is_Empty loop
         This.Signals.Pop (E);
         C := This.Objects.Find (E.Tag);

         if C /= No_Element then
            Watcher := This.Objects.Constant_Reference (C).Watcher;

            if Watcher /= null then
               Watcher.Watch_Event (E);
            end if;
         end if;
      end loop;
   end Watch;

   procedure Add_Runner (This : in out Instance; Runner : Processor.Handle) is
   begin
      This.Objects.Insert (Runner.Get_Id, (Runner, null, null));
   end Add_Runner;

   procedure Dispatch (This : in out Instance) is
      C : Cursor;
      E : Event;
   begin
      while not This.Commands.Is_Empty loop
         This.Commands.Pop (E);
         C := This.Objects.Find (E.Tag);

         if C /= No_Element then
            Element (C).Runner.Perform (E.Slot, E.Argument);
         end if;
      end loop;
   end Dispatch;

   procedure Emit (This : in out Instance; Processor_Id : Tag; Signal : Slot;
                   Argument : Value := Empty_Value) is
      E : constant Event :=  (Processor_Id, Signal, Argument);
   begin
      This.Signals.Push (E);

   exception
      when Event_Ring.Overflow_Error =>
         This.Signal_Underruns := This.Signal_Underruns + 1;
         This.Signals.Drop;
         This.Signals.Push (E);
   end Emit;

   procedure Show (This : in out Instance; Processor_Id : Tag; Data : Slot;
                   Argument : Data_Value) is
      E : constant Data_Event :=  (Processor_Id, Data, Argument);
   begin
      This.Data.Push (E);

   exception
      when Data_Ring.Overflow_Error =>
         This.Data_Underruns := This.Data_Underruns + 1;
         This.Data.Drop;
         This.Data.Push (E);
   end Show;

   procedure Send (This : in out Instance; Processor_Id : Tag; Command : Slot;
                   Argument : Value := Empty_Value) is
      E : constant Event :=  (Processor_Id, Command, Argument);
   begin
      This.Commands.Push (E);

   exception
      when Event_Ring.Overflow_Error =>
         --  stress offload and retry
         This.Dispatch;
         This.Commands.Push (E);
   end Send;

   procedure Remove_Runner (This : in out Instance; Processor_Id : Tag) is
   begin
      This.Objects.Delete (Processor_Id);
   end Remove_Runner;

   procedure Set_Watcher (This : in out Instance; Processor_Id : Tag;
                          Watcher : Event_Watcher.Handle) is
      C : constant Cursor := This.Objects.Find (Processor_Id);
   begin
      This.Objects.Reference (C).Watcher := Watcher;
   end Set_Watcher;

   procedure Set_Analyzer (This : in out Instance; Processor_Id : Tag;
                           Analyzer : Data_Analyzer.Handle) is
      C : constant Cursor := This.Objects.Find (Processor_Id);
   begin
      This.Objects.Reference (C).Analyzer := Analyzer;
   end Set_Analyzer;

end Sound.Bus;
