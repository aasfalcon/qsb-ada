with Ada.Containers.Ordered_Maps;

with Sound.Constants;
with Sound.Object;
with Sound.Ring_Facet;
with Sound.Processor;
with Sound.Events;

package Sound.Bus is

   use Sound.Events;

   subtype Parent is Object.Instance;
   type Instance is new Parent with private;
   subtype Class is Instance'Class;
   type Handle is access all Class;

   overriding
   procedure Initialize (This : in out Instance);

   function Has_Runner (This : Instance; Processor_Id : Tag) return Boolean;
   function Get_Data_Underruns (This : Instance) return Natural;
   function Get_Signal_Underruns (This : Instance) return Natural;

   procedure Add_Runner (This : in out Instance; Runner : Processor.Handle);
   procedure Analyze (This : in out Instance);
   procedure Dispatch (This : in out Instance);
   procedure Emit (This : in out Instance; Processor_Id : Tag; Signal : Slot;
                   Argument : Value := Empty_Value);
   procedure Show (This : in out Instance; Processor_Id : Tag; Data : Slot;
                   Argument : Data_Value);
   procedure Remove_Runner (This : in out Instance; Processor_Id : Tag);
   procedure Send (This : in out Instance; Processor_Id : Tag; Command : Slot;
                   Argument : Value := Empty_Value);
   procedure Set_Watcher (This : in out Instance; Processor_Id : Tag;
                          Watcher : Event_Watcher.Handle);
   procedure Set_Analyzer (This : in out Instance; Processor_Id : Tag;
                           Analyzer : Data_Analyzer.Handle);
   procedure Watch (This : in out Instance);

private

   type Bus_Object is
      record
         Runner : Processor.Handle := null;
         Watcher : Event_Watcher.Handle := null;
         Analyzer : Data_Analyzer.Handle := null;
      end record;

   package Bus_Object_Maps is
      new Ada.Containers.Ordered_Maps (Element_Type => Bus_Object,
                                       Key_Type => Tag);
   package Event_Ring is new Ring_Facet (Event);
   package Data_Ring is new Ring_Facet (Data_Event);

   type Instance is new Parent with
      record
         Commands : Event_Ring.Instance (Constants.Commands_Bus_Size);
         Signals : Event_Ring.Instance (Constants.Signals_Bus_Size);
         Data : Data_Ring.Instance (Constants.Data_Bus_Size);
         Objects : Bus_Object_Maps.Map;
         Signal_Underruns, Data_Underruns : Natural;
      end record;

end Sound.Bus;
