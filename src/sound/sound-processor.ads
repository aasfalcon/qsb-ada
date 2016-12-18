with Ada.Containers.Vectors;

limited with Sound.Bus;
with Sound.Buffer;
with Sound.Object;
with Sound.Events;

package Sound.Processor is
   use Sound.Events;

   subtype Parent is Object.Instance;
   type Instance is abstract new Parent with private;
   subtype Class is Instance'Class;
   type Handle is access all Class;

   type Subs_Mode is (Serial, Parallel);
   type Subs_Order is (After, Before);

   overriding
   procedure Initialize (This : in out Instance);

   function Get_Bus (This : Instance) return Bus.Handle;
   procedure Set_Bus (This : in out Instance; Value : Bus.Handle);

   function Get_Id (This : Instance) return Tag;

   function Get_Index (This : Instance) return Positive;
   procedure Set_Index (This : in out Instance; Value : Natural);

   function Get_Sub (This : Instance; Index : Positive) return Handle;
   function Get_Sub_Count (This : Instance) return Natural;

   function Get_Super (This : Instance) return Handle;
   procedure Set_Super (This : in out Instance; Value : Handle);

   procedure Set_Subs_Rules (This : in out Instance;
                             Mode : Subs_Mode; Order : Subs_Order);
   procedure Emit (This : Instance; Signal : Slot;
                   Argument : Value := Empty_Value);
   procedure Show (This : Instance; Data : Slot; Argument : Data_Value);
   procedure Perform (This : in out Instance; Command : Slot;
                      Argument : Value) is null;
   procedure Insert (This : in out Instance; Sub : Handle;
                     Index : Integer := -1);
   procedure Process (This : Instance; Buf : in out Buffer.Instance) is null;
   procedure Process_Entry (This : Instance; Buf : in out Buffer.Instance);

private

   package Subs_Vectors is new Ada.Containers.Vectors (Positive, Handle);

   type Instance is abstract new Parent with
      record
         Bus : access Bus.Instance;
         Id : Tag;
         Index : Positive;
         Super : Handle;
         Subs : Subs_Vectors.Vector;
         Mode : Subs_Mode;
         Order : Subs_Order;
      end record;

end Sound.Processor;
