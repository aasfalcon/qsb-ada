with Sound.Constants;

package Sound.Events is

   type Receiver_Tag is new Natural;
   Empty_Id : constant Receiver_Tag := 0;

   -----------
   -- Slots --
   -----------

   type Receiver_Slot is new Natural;

   type Parameter_Slot is new Receiver_Slot;
   type Command_Slot is new Receiver_Slot;
   type Signal_Slot is new Receiver_Slot;
   type Packet_Slot is new Receiver_Slot;

   generic
      type Enum is (<>);
      type Slot is new Natural;
      Offset : Natural := 0;
   package Slot_Enum is
      Tail : constant Slot := Slot (Offset + Enum'Pos (Enum'Last) + 1);

      function To_Slot (Value : Enum)
         return Slot is (Slot (Offset + Enum'Pos (Value)));

      function To_Enum (Value : Slot)
         return Enum is (Enum'Val (Value));
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

   type Packet_Count is range 1 .. Constants.Packet_Max_Count;
   type Packet_Bools is array (Packet_Count range <>) of Boolean;
   type Packet_Reals is array (Packet_Count range <>) of Float;
   type Packet_Ints is array (Packet_Count range <>) of Integer;

   type Data (The_Type : Value_Type := None; Count : Packet_Count := 1) is
      record
         case The_Type is
            when Bool =>
               Bools : Packet_Bools (1 .. Count);
            when Real =>
               Reals : Packet_Reals (1 .. Count);
            when Int =>
               Ints : Packet_Ints (1 .. Count);
            when None =>
               null;
         end case;
      end record;

   Empty_Data : constant Data := (others => <>);

   -----------
   -- Event --
   -----------

   type Event_Base is tagged
      record
         Id : Receiver_Tag;
         Slot : Receiver_Slot;
      end record;

   type Event is new Event_Base with
      record
         Argument : Value;
      end record;

   type Packet is
      new Event_Base with
      record
         Argument : Data;
      end record;

   ---------------
   -- Receivers --
   ---------------

   package Event_Receiver is
      type Instance is limited interface;
      subtype Class is Instance'Class;
      type Handle is access all Class;
      function Get_Id (This : Instance) return Receiver_Tag is abstract;
      procedure Set (This : in out Instance; Parameter : Parameter_Slot;
                     Argument : Value) is abstract;
      procedure Run (This : in out Instance; Command : Command_Slot;
                     Argument : Value := Empty_Value) is abstract;
   end Event_Receiver;

   package Event_Supervisor is
      type Instance is limited interface;
      subtype Class is Instance'Class;
      type Handle is access all Class;
      procedure Watch_Event (This : in out Instance; E : Event) is abstract;
      procedure Analyze_Packet (This : in out Instance;
                                P : Packet) is abstract;
   end Event_Supervisor;

end Sound.Events;
