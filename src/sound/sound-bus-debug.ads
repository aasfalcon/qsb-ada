with Ada.Real_Time; use Ada.Real_Time;

with Sound.Bus;
with Sound.Processor;

package Sound.Bus.Debug is

   subtype Super is Bus.Instance;
   type Instance is new Super with private;
   subtype Class is Instance'Class;
   type Handle is access all Class;

   type Statistics_View is
      record
         Last, Peak : Natural;
         Average : Long_Float;
         Measures : Natural;
      end record;

   type Statistics is
      record
         Start, Finish : Time;
         Signals, Data, Data_Size, Commands, Runners : Statistics_View;
         Signals_Sent, Data_Sent, Commands_Sent : Natural;
         Signal_Underruns, Data_Underruns : Natural;
         Stress_Offloads : Natural;
      end record;

   procedure Initialize (This : in out Instance);
   procedure Stats_Analyze (This : Instance; Stats : out Statistics;
                            Report : out String);
   procedure Stats_Reset (This : in out Instance);

   overriding
   procedure Add_Runner (This : in out Instance; Runner : Processor.Handle);

   overriding
   procedure Dispatch (This : in out Instance);

   overriding
   procedure Show (This : in out Instance; Processor_Id : Tag;
                   Data : Slot; Argument : Data_Value);

   overriding
   procedure Remove_Runner (This : in out Instance; Processor_Id : Tag);

   overriding
   procedure Watch (This : in out Instance);

private

   type Instance is new Super with
      record
         Is_Collecting : Boolean;
         Stats : Statistics;
      end record;

   procedure Stats_Collect (This : in out Instance);
   procedure Update_View (This : Instance; View : in out Statistics_View;
                          Current : Natural);

end Sound.Bus.Debug;
