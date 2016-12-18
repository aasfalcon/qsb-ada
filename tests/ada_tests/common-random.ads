with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;

with Sound.Events; use Sound.Events;

package Common.Random is

   type Instance is tagged limited private;

   function Make_Int (This : Instance) return Integer;
   function Make_Bool (This : Instance) return Boolean;
   function Make_Real (This : Instance) return Float;
   function Make_Bound (This : Instance; Min, Max : Natural) return Natural;
   function Make_Event (This : Instance; Id : Tag) return Event;
   function Make_Data_Event (This : Instance; Id : Tag) return Data_Event;
   function Make_Value (This : Instance) return Value;
   function Make_Data_Value (This : Instance) return Data_Value;

   procedure Initialize (This : in out Instance);

private

   package Type_Random is new Ada.Numerics.Discrete_Random (Value_Type);
   package Bool_Random is new Ada.Numerics.Discrete_Random (Boolean);
   package Int_Random is new Ada.Numerics.Discrete_Random (Integer);
   package Real_Random renames Ada.Numerics.Float_Random;
   package Bound_Random renames Ada.Numerics.Float_Random;

   type Instance is tagged limited
      record
         Is_Generators_Initialised : Boolean := False;
         Type_Gen : Type_Random.Generator;
         Bool_Gen : Bool_Random.Generator;
         Int_Gen : Int_Random.Generator;
         Real_Gen : Real_Random.Generator;
         Bound_Gen : Bound_Random.Generator;
      end record;

end Common.Random;
