with Sound.Constants;

package Sound.Events is

   type Client_Id is new Natural;
   Empty_Id : constant Client_Id := 0;

   -----------
   -- Slots --
   -----------

   type Client_Slot is new Natural;

   type Parameter_Slot is new Client_Slot;
   type Command_Slot is new Client_Slot;
   type Signal_Slot is new Client_Slot;
   type Packet_Slot is new Client_Slot;

   generic
      type Enum_Value is (<>);
      type Slot_Value is new Client_Slot;
      Offset : Slot_Value := 0;
   package Slot_Enum is
      Tail : constant Slot_Value :=
         Slot_Value (Offset + Enum_Value'Pos (Enum_Value'Last) + 1);

      function Slot (Value : Enum_Value)
         return Slot_Value is (Slot_Value (Offset + Enum_Value'Pos (Value)));

      function Enum (Value : Slot_Value)
         return Enum_Value is (Enum_Value'Val (Value));
   end Slot_Enum;

   -----------
   -- Value --
   -----------

   type Value_Type is  (Bool, Real, Int, None);
   type Value (The_Type : Value_Type := None) is
      record
         case The_Type is
            when Bool =>
               Bool : Boolean;
            when Real =>
               Real : Float;
            when Int =>
               Int : Integer;
            when None => null;
         end case;
      end record;

   Empty_Value : constant Value := (others => <>);

   ------------
   -- Packet --
   ------------

   subtype Data_Count is Natural range 1 .. Constants.Packet_Max_Count;
   subtype Data_Type is Value_Type;
   type Data_Bools is array (Data_Count range <>) of Boolean;
   type Data_Reals is array (Data_Count range <>) of Float;
   type Data_Ints is array (Data_Count range <>) of Integer;

   type Data (The_Type : Data_Type := None; Count : Data_Count := 1) is
      record
         case The_Type is
            when Bool =>
               Bools : Data_Bools (1 .. Count);
            when Real =>
               Reals : Data_Reals (1 .. Count);
            when Int =>
               Ints : Data_Ints (1 .. Count);
            when None =>
               null;
         end case;
      end record;

   Empty_Data : constant Data := (others => <>);

   -----------
   -- Event --
   -----------

   type Basic_Event is abstract tagged
      record
         Id : Client_Id;
         Slot : Client_Slot;
      end record;

   type Event is new Basic_Event with
      record
         Argument : Value;
      end record;

   type Packet_Event is
      new Basic_Event with
      record
         Argument : Data;
      end record;

   ---------------
   -- Receivers --
   ---------------

   package Event_Client is
      type Instance is limited interface;
      subtype Class is Instance'Class;
      type Handle is access all Class;
      function Get_Id (This : Instance) return Client_Id is abstract;
      procedure Set (This : in out Instance; Parameter : Parameter_Slot;
                     Argument : Value) is abstract;
      procedure Run (This : in out Instance; Command : Command_Slot;
                     Argument : Value := Empty_Value) is abstract;
   end Event_Client;

   package Event_Supervisor is
      type Instance is limited interface;
      subtype Class is Instance'Class;
      type Handle is access all Class;
      procedure Watch_Parameter (This : in out Instance; E : Event) is null;
      procedure Watch_Signal (This : in out Instance; E : Event) is null;
      procedure Watch_Packet (This : in out Instance;
                              P : Packet_Event) is null;
   end Event_Supervisor;

end Sound.Events;
